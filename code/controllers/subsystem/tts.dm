#define TARGET_INDEX 1
#define IDENTIFIER_INDEX 2
#define TIMEOUT_INDEX 3
#define REQUEST_INDEX 4
#define MESSAGE_INDEX 5
#define EXTRA_TARGETS_INDEX 6
#define LANGUAGE_INDEX 7
#define LOCAL_INDEX 8

SUBSYSTEM_DEF(tts)
	name = "Text To Speech"
	wait = 0.05 SECONDS
	priority = FIRE_PRIORITY_TTS

	/// Queued HTTP requests that have yet to be sent
	var/list/queued_tts_messages = list()

	/// HTTP requests currently in progress but not being processed yet
	var/list/in_process_tts_messages = list()

	/// HTTP requests that are being processed to see if they've been finished
	var/list/current_processing_tts_messages = list()

	/// A list of available speakers
	var/list/available_speakers = list()

	var/list/cached_voices = list()

	/// Whether TTS is enabled or not
	var/tts_enabled = FALSE

	var/message_timeout = 7 SECONDS

	/// Messages can be timed out earlier if the algorithm thinks that
	/// it's going to take too long for their message to be processed.
	/// This'll determine the minimum extent of how late it is allowed to begin timing messages out
	var/message_timeout_early_minimum = 5 SECONDS

	var/max_concurrent_requests = 20

/datum/controller/subsystem/tts/vv_edit_var(var_name, var_value)
	// tts being enabled depends on whether it actually exists
	if(NAMEOF(src, tts_enabled) == var_name)
		return FALSE
	return ..()

/datum/controller/subsystem/tts/Initialize()
	if(!CONFIG_GET(string/tts_http_url))
		return SS_INIT_NO_NEED

	var/datum/http_request/request = new()
	var/list/headers = list()
	headers["Authorization"] = CONFIG_GET(string/tts_http_token)
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/tts_http_url)]/tts-voices", "", headers)
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code != 200)
		return SS_INIT_FAILURE
	available_speakers = json_decode(response.body)
	tts_enabled = TRUE
	rustg_file_write(json_encode(available_speakers), "data/cached_tts_voices.json")
	rustg_file_write("rustg HTTP requests can't write to folders that don't exist, so we need to make it exist.", "tmp/tts/init.txt")
	return SS_INIT_SUCCESS

/datum/controller/subsystem/tts/proc/play_tts(target, sound, datum/language/language, local)
	if(local)
		SEND_SOUND(target, sound)
		return

	var/turf/turf_source = get_turf(target)
	if(!turf_source)
		return

	var/channel = SSsounds.random_available_channel()
	var/listeners = get_hearers_in_view(SOUND_RANGE, turf_source)

	for(var/mob/listening_mob in listeners | SSmobs.dead_players_by_zlevel[turf_source.z])//observers always hear through walls
		var/datum/language_holder/holder = listening_mob.get_language_holder()
		if(!listening_mob.client?.prefs.read_preference(/datum/preference/toggle/sound_tts))
			continue

		if(get_dist(listening_mob, turf_source) <= SOUND_RANGE && holder.has_language(language, spoken = FALSE))
			listening_mob.playsound_local(
				turf_source,
				sound,
				vol = listening_mob == target? 60 : 85,
				falloff_exponent = SOUND_FALLOFF_EXPONENT,
				channel = channel,
				pressure_affected = TRUE,
				sound_to_use = sound,
				max_distance = SOUND_RANGE,
				falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE,
				distance_multiplier = 1,
				use_reverb = TRUE
			)

/datum/controller/subsystem/tts/proc/handle_request(list/entry)
	var/time_left = entry[TIMEOUT_INDEX]
	if(time_left < world.time)
		cached_voices -= entry[IDENTIFIER_INDEX]
		return
	var/datum/http_request/request = entry[REQUEST_INDEX]
	request.begin_async()
	in_process_tts_messages += list(entry)

/datum/controller/subsystem/tts/fire(resumed)
	if(!tts_enabled)
		flags |= SS_NO_FIRE
		return

	if(!resumed)
		while(length(in_process_tts_messages) < max_concurrent_requests && queued_tts_messages.len > 0)
			var/list/entry = popleft(queued_tts_messages)
			handle_request(entry)
		current_processing_tts_messages = in_process_tts_messages.Copy()

	// For speed
	var/list/processing_messages = current_processing_tts_messages
	while(processing_messages.len)
		var/current_message = processing_messages[processing_messages.len]
		processing_messages.len--
		if(current_message[TIMEOUT_INDEX] < world.time)
			in_process_tts_messages -= list(current_message)
			cached_voices -= current_message[IDENTIFIER_INDEX]
			continue

		var/datum/http_request/request = current_message[REQUEST_INDEX]
		if(!request.is_complete())
			continue

		var/datum/http_response/response = request.into_response()
		in_process_tts_messages -= list(current_message)
		if(response.errored)
			cached_voices -= current_message[IDENTIFIER_INDEX]
			continue
		var/identifier = current_message[IDENTIFIER_INDEX]
		var/sound/new_sound = new("tmp/tts/[identifier].ogg")
		play_tts(current_message[TARGET_INDEX], new_sound, current_message[LANGUAGE_INDEX], current_message[LOCAL_INDEX])
		for(var/extra_target in current_message[EXTRA_TARGETS_INDEX])
			play_tts(extra_target["target"], new_sound, current_message[LANGUAGE_INDEX], extra_target["local"])
		cached_voices -= identifier
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/tts/proc/queue_tts_message(target, message, datum/language/language, speaker, filter, local = FALSE)
	if(!tts_enabled)
		return

	var/static/regex/contains_alphanumeric = regex("\[a-zA-Z0-9]", "g")
	// If there is no alphanumeric char, the output will usually be static, so
	// don't bother sending
	if(contains_alphanumeric.Find(message) == 0)
		return

	var/shell_scrubbed_input = tts_alphanumeric_filter(message)
	shell_scrubbed_input = copytext(shell_scrubbed_input, 1, 300)
	var/identifier = sha1(speaker + shell_scrubbed_input + filter)
	var/cached_voice = cached_voices[identifier]
	if(islist(cached_voice))
		cached_voice[EXTRA_TARGETS_INDEX] += list(list(target = target, local = local))
		return
	else if(fexists("tmp/tts/[identifier].ogg"))
		var/sound/new_sound = new("tmp/tts/[identifier].ogg")
		play_tts(target, new_sound, language, local)
		return
	if(!(speaker in available_speakers))
		return
	speaker = tts_alphanumeric_filter(speaker)

	var/list/headers = list()
	headers["Content-Type"] = "application/json"
	headers["Authorization"] = CONFIG_GET(string/tts_http_token)
	var/datum/http_request/request = new()
	var/file_name = "tmp/tts/[identifier].ogg"
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/tts_http_url)]/tts?voice=[speaker]&identifier=[identifier]&filter=[url_encode(filter)]", json_encode(list("text" = shell_scrubbed_input)), headers, file_name)
	var/list/waiting_list = queued_tts_messages
	if(length(in_process_tts_messages) < max_concurrent_requests)
		request.begin_async()
		waiting_list = in_process_tts_messages

	var/list/data = list(
		// TARGET_INDEX = 1
		target,
		// IDENTIFIER_INDEX = 2
		identifier,
		// TIMEOUT_INDEX = 3
		world.time + message_timeout,
		// REQUEST_INDEX = 4
		request,
		// MESSAGE_INDEX = 5
		shell_scrubbed_input,
		// EXTRA_TARGETS_INDEX = 6
		list(),
		// LANGUAGE_INDEX = 7
		language,
		// LOCAL_INDEX = 8
		local,
	)
	cached_voices[identifier] = data
	waiting_list += list(data)

#undef TARGET_INDEX
#undef IDENTIFIER_INDEX
#undef TIMEOUT_INDEX
#undef REQUEST_INDEX
#undef MESSAGE_INDEX
#undef EXTRA_TARGETS_INDEX
#undef LANGUAGE_INDEX
#undef LOCAL_INDEX
