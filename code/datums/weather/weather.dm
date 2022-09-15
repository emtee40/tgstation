/**
 * Causes weather to occur on a z level in certain area types
 *
 * The effects of weather occur across an entire z-level. For instance, lavaland has periodic ash storms that scorch most unprotected creatures.
 * Weather always occurs on different z levels at different times, regardless of weather type.
 * Can have custom durations, targets, and can automatically protect indoor areas.
 *
 */

/datum/weather
	/// name of weather
	var/name = "space wind"
	/// description of weather
	var/desc = "Heavy gusts of wind blanket the area, periodically knocking down anyone caught in the open."
	/// The message displayed in chat to foreshadow the weather's beginning
	var/telegraph_message = "<span class='warning'>The wind begins to pick up.</span>"
	/// In deciseconds, how long from the beginning of the telegraph until the weather begins
	var/telegraph_duration = 300
	/// The sound file played to everyone on an affected z-level
	var/telegraph_sound
	/// The overlay applied to all tiles on the z-level
	var/telegraph_overlay

	/// Displayed in chat once the weather begins in earnest
	var/weather_message = "<span class='userdanger'>The wind begins to blow ferociously!</span>"
	/// In deciseconds, how long the weather lasts once it begins
	var/weather_duration = 1200
	/// See above - this is the lowest possible duration
	var/weather_duration_lower = 1200
	/// See above - this is the highest possible duration
	var/weather_duration_upper = 1500
	/// Looping sound while weather is occuring
	var/weather_sound
	/// Area overlay while the weather is occuring
	var/weather_overlay
	/// Color to apply to the area while weather is occuring
	var/weather_color = null

	/// Displayed once the weather is over
	var/end_message = "<span class='danger'>The wind relents its assault.</span>"
	/// In deciseconds, how long the "wind-down" graphic will appear before vanishing entirely
	var/end_duration = 300
	/// Sound that plays while weather is ending
	var/end_sound
	/// Area overlay while weather is ending
	var/end_overlay

	/// Types of area to affect
	var/area_type = /area/space
	/// TRUE value protects areas with outdoors marked as false, regardless of area type
	var/protect_indoors = FALSE
	/// Areas to be affected by the weather, calculated when the weather begins
	var/list/impacted_areas = list()
	/// Areas that are protected and excluded from the affected areas.
	var/list/protected_areas = list()
	/// The list of z-levels that this weather is actively affecting
	var/impacted_z_levels

	/// Since it's above everything else, this is the layer used by default. TURF_LAYER is below mobs and walls if you need to use that.
	var/overlay_layer = AREA_LAYER
	/// Plane for the overlay
	var/overlay_plane = AREA_PLANE
	/// If the weather has no purpose other than looks
	var/aesthetic = FALSE
	/// Used by mobs (or movables containing mobs, such as enviro bags) to prevent them from being affected by the weather.
	var/immunity_type
	/// If this bit of weather should also draw an overlay that's uneffected by lighting onto the area
	/// Taken from weather_glow.dmi
	var/use_glow = TRUE
	var/list/offsets_to_overlays

	/// The stage of the weather, from 1-4
	var/stage = END_STAGE

	/// Weight amongst other eligible weather. If zero, will never happen randomly.
	var/probability = 0
	/// The z-level trait to affect when run randomly or when not overridden.
	var/target_trait = ZTRAIT_STATION

	/// Whether a barometer can predict when the weather will happen
	var/barometer_predictable = FALSE
	/// For barometers to know when the next storm will hit
	var/next_hit_time = 0
	/// This causes the weather to only end if forced to
	var/perpetual = FALSE

/datum/weather/New(z_levels)
	..()
	impacted_z_levels = z_levels

/**
 * Telegraphs the beginning of the weather on the impacted z levels
 *
 * Sends sounds and details to mobs in the area
 * Calculates duration and hit areas, and makes a callback for the actual weather to start
 *
 */
/datum/weather/proc/telegraph()
	if(stage == STARTUP_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_TELEGRAPH(type))
	stage = STARTUP_STAGE
	var/list/affectareas = list()
	for(var/V in get_areas(area_type))
		affectareas += V
	for(var/V in protected_areas)
		affectareas -= get_areas(V)
	for(var/V in affectareas)
		var/area/A = V
		if(protect_indoors && !A.outdoors)
			continue
		if(A.z in impacted_z_levels)
			impacted_areas |= A
	weather_duration = rand(weather_duration_lower, weather_duration_upper)
	SSweather.processing |= src
	update_areas()
	for(var/z_level in impacted_z_levels)
		for(var/mob/player as anything in SSmobs.clients_by_zlevel[z_level])
			var/turf/mob_turf = get_turf(player)
			if(!mob_turf)
				continue
			if(telegraph_message)
				to_chat(player, telegraph_message)
			if(telegraph_sound)
				SEND_SOUND(player, sound(telegraph_sound))
	addtimer(CALLBACK(src, .proc/start), telegraph_duration)

/**
 * Starts the actual weather and effects from it
 *
 * Updates area overlays and sends sounds and messages to mobs to notify them
 * Begins dealing effects from weather to mobs in the area
 *
 */
/datum/weather/proc/start()
	if(stage >= MAIN_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_START(type))
	stage = MAIN_STAGE
	update_areas()
	for(var/z_level in impacted_z_levels)
		for(var/mob/player as anything in SSmobs.clients_by_zlevel[z_level])
			var/turf/mob_turf = get_turf(player)
			if(!mob_turf)
				continue
			if(weather_message)
				to_chat(player, weather_message)
			if(weather_sound)
				SEND_SOUND(player, sound(weather_sound))
	if(!perpetual)
		addtimer(CALLBACK(src, .proc/wind_down), weather_duration)

/**
 * Weather enters the winding down phase, stops effects
 *
 * Updates areas to be in the winding down phase
 * Sends sounds and messages to mobs to notify them
 *
 */
/datum/weather/proc/wind_down()
	if(stage >= WIND_DOWN_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_WINDDOWN(type))
	stage = WIND_DOWN_STAGE
	update_areas()
	for(var/z_level in impacted_z_levels)
		for(var/mob/player as anything in SSmobs.clients_by_zlevel[z_level])
			var/turf/mob_turf = get_turf(player)
			if(!mob_turf)
				continue
			if(end_message)
				to_chat(player, end_message)
			if(end_sound)
				SEND_SOUND(player, sound(end_sound))
	addtimer(CALLBACK(src, .proc/end), end_duration)

/**
 * Fully ends the weather
 *
 * Effects no longer occur and area overlays are removed
 * Removes weather from processing completely
 *
 */
/datum/weather/proc/end()
	if(stage == END_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_END(type))
	stage = END_STAGE
	SSweather.processing -= src
	update_areas()

/**
 * Returns TRUE if the living mob can be affected by the weather
 *
 */
/datum/weather/proc/can_weather_act(mob/living/mob_to_check)
	var/turf/mob_turf = get_turf(mob_to_check)

	if(!mob_turf)
		return

	if(!(mob_turf.z in impacted_z_levels))
		return

	if((immunity_type && HAS_TRAIT(mob_to_check, immunity_type)) || HAS_TRAIT(mob_to_check, TRAIT_WEATHER_IMMUNE))
		return

	var/atom/loc_to_check = mob_to_check.loc
	while(loc_to_check != mob_turf)
		if((immunity_type && HAS_TRAIT(loc_to_check, immunity_type)) || HAS_TRAIT(loc_to_check, TRAIT_WEATHER_IMMUNE))
			return
		loc_to_check = loc_to_check.loc

	if(!(get_area(mob_to_check) in impacted_areas))
		return

	return TRUE

/**
 * Affects the mob with whatever the weather does
 *
 */
/datum/weather/proc/weather_act(mob/living/L)
	return

/**
 * Updates the overlays on impacted areas
 *
 */
/datum/weather/proc/update_areas()
	var/using_icon_state = ""
	switch(stage)
		if(STARTUP_STAGE)
			using_icon_state = telegraph_overlay
		if(MAIN_STAGE)
			using_icon_state = weather_overlay
		if(WIND_DOWN_STAGE)
			using_icon_state = end_overlay
		if(END_STAGE)
			using_icon_state = ""

	// Note: what we do here is effectively apply two overlays to each area, for every unique multiz layer they inhabit
	// One is the base, which will be masked by lighting. the other is "glowing", and provides a nice contrast
	// This method of applying one overlay per z layer has some minor downsides, in that it could lead to improperly doubled effects if some have alpha
	// I prefer it to creating 2 extra plane masters however, so it's a cost I'm willing to pay
	// LU
	var/list/new_offsets_to_overlays = list()
	for(var/V in impacted_areas)
		var/area/N = V

		// List of overlays this area uses
		var/list/mutable_appearance/overlays = list()
		// List of offsets this area wants, based off its z range
		var/list/offsets = list()
		for(var/z_index in 1 to length(N.zs_we_have))
			if(!N.zs_we_have[z_index])
				continue
			offsets |= GET_Z_PLANE_OFFSET(z_index)

		// Now that we have all the offsets this area COULD be effecting, we give it overlays
		for(var/offset in offsets)
			var/keyd_offset = offset + 1
			if(length(new_offsets_to_overlays) < keyd_offset)
				new_offsets_to_overlays.len = keyd_offset
			var/list/mutable_appearance/existing_appearances = new_offsets_to_overlays[keyd_offset]
			if(existing_appearances)
				overlays += existing_appearances
				continue

			var/list/offset_overlays = list()
			var/mutable_appearance/glow_overlay = mutable_appearance('icons/effects/glow_weather.dmi', using_icon_state, overlay_layer, N, ABOVE_LIGHTING_PLANE, 100, offset_const = offset)
			glow_overlay.color = weather_color
			offset_overlays += glow_overlay

			if(stage != END_STAGE)
				var/mutable_appearance/weather_overlay = mutable_appearance('icons/effects/weather_effects.dmi', using_icon_state, overlay_layer, plane = overlay_plane, offset_const = offset)
				weather_overlay.color = weather_color
				offset_overlays += weather_overlay

			new_offsets_to_overlays[keyd_offset] = offset_overlays
			overlays += offset_overlays

		var/list/mutable_appearance/old_glows = list()
		for(var/offset in offsets)
			offset = offset + 1
			if(length(offsets_to_overlays) >= offset)
				old_glows += offsets_to_overlays[offset]

		if(length(old_glows))
			N.overlays -= old_glows
		if(length(overlays))
			N.overlays += overlays

	offsets_to_overlays = new_offsets_to_overlays

