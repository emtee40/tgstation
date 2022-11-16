/// Test to verify message mods are parsed correctly
/datum/unit_test/get_message_mods
	var/mob/host_mob

/datum/unit_test/get_message_mods/Run()
	host_mob = allocate(/mob/living/carbon/human)

	test("Hello", "Hello", list())
	test(";HELP", "HELP", list(MODE_HEADSET = TRUE))
	test(";%Never gonna give you up", "Never gonna give you up", list(MODE_HEADSET = TRUE, MODE_SING = TRUE))
	test(".s Gun plz", "Gun plz", list(RADIO_KEY = RADIO_KEY_SECURITY, RADIO_EXTENSION = RADIO_CHANNEL_SECURITY))
	test("...What", "...What", list())

/datum/unit_test/get_message_mods/proc/test(message, expected_message, list/expected_mods)
	var/list/mods = list()
	TEST_ASSERT_EQUAL(host_mob.get_message_mods(message, mods), expected_message, "Chopped message was not what we expected. Message: [message]")

	for (var/mod_key in mods)
		TEST_ASSERT_EQUAL(mods[mod_key], expected_mods[mod_key], "The value for [mod_key] was not what we expected. Message: [message]")
		expected_mods -= mod_key

	TEST_ASSERT(!expected_mods.len,
		"Some message mods were expected, but were not returned by get_message_mods: [json_encode(expected_mods)]. Message: [message]")

/// Test to verify COMSIG_MOB_SAY is sent the exact same list as the message args, as they're operated on
/datum/unit_test/say_signal

/datum/unit_test/say_signal/Run()
	var/mob/living/dummy = allocate(/mob/living)

	RegisterSignal(dummy, COMSIG_MOB_SAY, PROC_REF(check_say))
	dummy.say("Make sure the say signal gets the arglist say is past, no copies!")

/datum/unit_test/say_signal/proc/check_say(mob/living/source, list/say_args)
	SIGNAL_HANDLER

	TEST_ASSERT_EQUAL(REF(say_args), source.last_say_args_ref, "Say signal didn't get the argslist of say as a reference. \
		This is required for the signal to function in most places - do not create a new instance of a list when passing it in to the signal.")

// For the above test to track the last use of say's message args.
/mob/living
	var/last_say_args_ref

/// This unit test translates a string from one language to another depending on if the person can understand the language
/datum/unit_test/translate_language
	var/mob/host_mob

/datum/unit_test/translate_language/Run()
	host_mob = allocate(/mob/living/carbon/human)
	var/surfer_quote = "surfing in the USA"

	host_mob.grant_language(/datum/language/beachbum, spoken=TRUE, understood=FALSE) // can speak but can't understand
	host_mob.add_blocked_language(subtypesof(/datum/language) - /datum/language/beachbum, LANGUAGE_STONER)
	TEST_ASSERT_NOTEQUAL(surfer_quote, host_mob.translate_language(host_mob, /datum/language/beachbum, surfer_quote), "Language test failed. Mob was supposed to understand: [surfer_quote]")

	host_mob.grant_language(/datum/language/beachbum, spoken=TRUE, understood=TRUE) // can now understand
	TEST_ASSERT_EQUAL(surfer_quote, host_mob.translate_language(host_mob, /datum/language/beachbum, surfer_quote), "Language test failed. Mob was supposed NOT to understand: [surfer_quote]")

/// This runs some simple speech tests on a speaker and listener and determines if a person can hear whispering or speaking as they are moved a distance away
/datum/unit_test/speech
	var/list/handle_speech_result = null
	var/list/handle_hearing_result = null
	var/mob/living/carbon/human/speaker
	var/mob/living/carbon/human/listener

/datum/unit_test/speech/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	TEST_ASSERT(speech_args[SPEECH_MESSAGE], "Handle speech signal does not have a message arg")
	TEST_ASSERT(speech_args[SPEECH_SPANS], "Handle speech signal does not have spans arg")
	TEST_ASSERT(speech_args[SPEECH_LANGUAGE], "Handle speech signal does not have a language arg")
	TEST_ASSERT(speech_args[SPEECH_RANGE], "Handle speech signal does not have a range arg")

	handle_speech_result = speech_args

/datum/unit_test/speech/proc/handle_hearing(datum/source, list/hearing_args)
	SIGNAL_HANDLER

	TEST_ASSERT(hearing_args[HEARING_MESSAGE], "Handle hearing signal does not have a message arg")
	TEST_ASSERT(hearing_args[HEARING_SPEAKER], "Handle hearing signal does not have a speaker arg")
	TEST_ASSERT(hearing_args[HEARING_LANGUAGE], "Handle hearing signal does not have a language arg")
	TEST_ASSERT(hearing_args[HEARING_RAW_MESSAGE], "Handle hearing signal does not have a raw message arg")
	// TODO radio unit tests
	//TEST_ASSERT(hearing_args[HEARING_RADIO_FREQ], "Handle hearing signal does not have a radio freq arg")
	TEST_ASSERT(hearing_args[HEARING_SPANS], "Handle hearing signal does not have a spans arg")
	TEST_ASSERT(hearing_args[HEARING_MESSAGE_MODE], "Handle hearing signal does not have a message mode arg")

	handle_hearing_result = hearing_args

/datum/unit_test/speech/Run()
	speaker = allocate(/mob/living/carbon/human)
	listener = allocate(/mob/living/carbon/human)

	RegisterSignal(speaker, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	RegisterSignal(listener, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))

	// speaking and whispering should be hearable
	conversation(distance=1)
	// speaking should be hearable but not whispering
	conversation(distance=5)
	// neither speaking or whispering should be hearable
	conversation(distance=10)

	// Language test
	speaker.grant_language(/datum/language/beachbum)
	listener.add_blocked_language(/datum/language/beachbum)
	// speaking and whispering should be hearable
	conversation(distance=1, language=/datum/language/beachbum)
	// speaking should be hearable but not whispering
	conversation(distance=5, language=/datum/language/beachbum)
	// neither speaking or whispering should be hearable
	conversation(distance=10, language=/datum/language/beachbum)

#define NORMAL_HEARING_RANGE 7
#define WHISPER_HEARING_RANGE 1

/datum/unit_test/speech/proc/conversation(distance = 0, datum/language/language)
	speaker.forceMove(run_loc_floor_bottom_left)
	listener.forceMove(locate(run_loc_floor_bottom_left.x + distance, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))

	var/pangram_quote = "The quick brown fox jumps over the lazy dog"

	// speaking
	speaker.say(pangram_quote, language = language)
	TEST_ASSERT(handle_speech_result, "Handle speech signal was not fired")
	TEST_ASSERT_EQUAL(islist(handle_hearing_result), distance <= NORMAL_HEARING_RANGE, "Handle hearing signal was not fired")

	if(language && handle_hearing_result)
		if(listener.has_language(language))
			TEST_ASSERT_EQUAL(pangram_quote, handle_hearing_result[HEARING_MESSAGE], "Language test failed. Mob was supposed to understand: [pangram_quote] using language [language]")
		else
			TEST_ASSERT_NOTEQUAL(pangram_quote, handle_hearing_result[HEARING_MESSAGE], "Language test failed. Mob was NOT supposed to understand: [pangram_quote] using language [language]")

	handle_speech_result = null
	handle_hearing_result = null

	// whispering
	speaker.whisper(pangram_quote, language = language)
	TEST_ASSERT(handle_speech_result, "Handle speech signal was not fired")
	TEST_ASSERT_EQUAL(islist(handle_hearing_result), distance <= WHISPER_HEARING_RANGE, "Handle hearing signal was not fired")

	handle_speech_result = null
	handle_hearing_result = null

#undef NORMAL_HEARING_RANGE
#undef WHISPER_HEARING_RANGE
