#define MINOR_INSANITY_PEN 5
#define MAJOR_INSANITY_PEN 10

/datum/mood
	/// Weakref to the parent (living) mob
	var/datum/weakref/parent

	/// Mob's mood
	var/mood
	/// Mob's sanity
	var/sanity = SANITY_NEUTRAL
	/// The displayed mood
	var/shown_mood
	/// Modifier to allow certain mobs to be less affected by moodlets
	var/mood_modifier = 1
	/// Used to track what stage of moodies they're on
	var/mood_level = 5
	/// To track what stage of sanity they're on
	var/sanity_level = SANITY_LEVEL_NEUTRAL
	/// Is the owner being punished for low mood? if so, how much?
	var/insanity_effect = 0
	/// The screen object for the current mood level
	var/atom/movable/screen/mood/mood_screen_object

	/// List of mood events currently active on this datum
	var/list/mood_events

/datum/mood/New(mob/living/mob_to_make_moody)
	if (!istype(mob_to_make_moody))
		stack_trace("Tried to apply mood to a non-living atom!")
		qdel(src)
		return

	START_PROCESSING(SSmood, src)

	parent = WEAKREF(mob_to_make_moody)
	mood_events = list()

	RegisterSignal(mob_to_make_moody, COMSIG_MOB_HUD_CREATED, .proc/modify_hud)
	RegisterSignal(mob_to_make_moody, COMSIG_ENTER_AREA, .proc/check_area_mood)
	RegisterSignal(mob_to_make_moody, COMSIG_LIVING_REVIVE, .proc/on_revive)

	mob_to_make_moody.become_area_sensitive(MOOD_DATUM_TRAIT)
	if(mob_to_make_moody.hud_used)
		modify_hud()
		var/datum/hud/hud = mob_to_make_moody.hud_used
		hud.show_hud(hud.hud_version)

/datum/mood/Destroy(force, ...)
	STOP_PROCESSING(SSmood, src)

	unmodify_hud()
	var/mob/living/mob_parent = parent?.resolve()
	mob_parent.lose_area_sensitivity(MOOD_DATUM_TRAIT)

	UnregisterSignal(mob_parent, list(COMSIG_MOB_HUD_CREATED, COMSIG_ENTER_AREA))
	return ..()

/datum/mood/process(delta_time)
	var/mob/living/mob_parent = parent?.resolve()

	if (mob_parent.stat == DEAD)
		return

	switch(mood_level)
		if(1)
			set_sanity(sanity - 0.3 * delta_time, SANITY_INSANE)
		if(2)
			set_sanity(sanity - 0.15 * delta_time, SANITY_INSANE)
		if(3)
			set_sanity(sanity - 0.1 * delta_time, SANITY_CRAZY)
		if(4)
			set_sanity(sanity - 0.05 * delta_time, SANITY_UNSTABLE)
		if(5)
			set_sanity(sanity, SANITY_UNSTABLE) //This makes sure that mood gets increased should you be below the minimum.
		if(6)
			set_sanity(sanity + 0.2 * delta_time, SANITY_UNSTABLE)
		if(7)
			set_sanity(sanity + 0.3 * delta_time, SANITY_UNSTABLE)
		if(8)
			set_sanity(sanity + 0.4 * delta_time, SANITY_NEUTRAL, SANITY_MAXIMUM)
		if(9)
			set_sanity(sanity + 0.6 * delta_time, SANITY_NEUTRAL, SANITY_MAXIMUM)
	handle_nutrition()

	// 0.416% is 15 successes / 3600 seconds. Calculated with 2 minute
	// mood runtime, so 50% average uptime across the hour.
	if(HAS_TRAIT(mob_parent, TRAIT_DEPRESSION) && DT_PROB(0.416, delta_time))
		add_mood_event("depression_mild", /datum/mood_event/depression_mild)

	if(HAS_TRAIT(mob_parent, TRAIT_JOLLY) && DT_PROB(0.416, delta_time))
		add_mood_event("jolly", /datum/mood_event/jolly)

/datum/mood/proc/handle_nutrition()
	var/mob/living/mob_parent = parent?.resolve()
	if (HAS_TRAIT(mob_parent, TRAIT_NOHUNGER))
		return FALSE // no moods for nutrition
	switch(mob_parent.nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			if (!HAS_TRAIT(mob_parent, TRAIT_VORACIOUS))
				add_mood_event("nutrition", /datum/mood_event/fat)
			else
				add_mood_event("nutrition", /datum/mood_event/wellfed) // round and full
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			add_mood_event("nutrition", /datum/mood_event/wellfed)
		if( NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			add_mood_event("nutrition", /datum/mood_event/fed)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			clear_mood_event("nutrition")
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			add_mood_event("nutrition", /datum/mood_event/hungry)
		if(0 to NUTRITION_LEVEL_STARVING)
			add_mood_event("nutrition", /datum/mood_event/starving)

/datum/mood/proc/add_mood_event(category, type, ...)
	if (!ispath(type, /datum/mood_event))
		return
	if (!istext(category))
		category = REF(category)

	var/datum/mood_event/the_event
	if (mood_events[category])
		the_event = mood_events[category]
		if (the_event.type != type)
			clear_mood_event(category)
		else
			if (the_event.timeout)
				addtimer(CALLBACK(src, .proc/clear_mood_event, category), the_event.timeout, (TIMER_UNIQUE|TIMER_OVERRIDE))
			return // Don't need to update the event.
	var/list/params = args.Copy(3)

	var/mob/living/parent_mob = parent?.resolve()
	if (!parent_mob)
		return
	params.Insert(1, parent_mob)
	the_event = new type(arglist(params))

	mood_events[category] = the_event
	the_event.category = category
	update_mood()

	if (the_event.timeout)
		addtimer(CALLBACK(src, .proc/clear_mood_event, category), the_event.timeout, (TIMER_UNIQUE|TIMER_OVERRIDE))

/datum/mood/proc/clear_mood_event(category)
	if (!istext(category))
		category = REF(category)

	var/datum/mood_event/event = mood_events[category]
	if (!event)
		return

	mood_events -= category
	qdel(event)
	update_mood()

/// Updates the mobs mood.
/// Called after mood events have been added/removed.
/datum/mood/proc/update_mood()
	mood = 0
	shown_mood = 0

	for(var/mood_event in mood_events)
		var/datum/mood_event/the_event = mood_events[mood_event]
		mood += the_event.mood_change
		if (!the_event.hidden)
			shown_mood += the_event.mood_change
	mood *= mood_modifier
	shown_mood *= mood_modifier

	switch(mood)
		if (-INFINITY to MOOD_LEVEL_SAD4)
			mood_level = 1
		if (MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
			mood_level = 2
		if (MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
			mood_level = 3
		if (MOOD_LEVEL_SAD2 to MOOD_LEVEL_SAD1)
			mood_level = 4
		if (MOOD_LEVEL_SAD1 to MOOD_LEVEL_HAPPY1)
			mood_level = 5
		if (MOOD_LEVEL_HAPPY1 to MOOD_LEVEL_HAPPY2)
			mood_level = 6
		if (MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
			mood_level = 7
		if (MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
			mood_level = 8
		if (MOOD_LEVEL_HAPPY4 to INFINITY)
			mood_level = 9

	update_mood_icon()

/// Updates the mob's mood icon
/datum/mood/proc/update_mood_icon()
	var/mob/living/parent_mob = parent?.resolve()
	if (!parent_mob)
		return

	if (!(parent_mob.client || parent_mob.hud_used))
		return

	mood_screen_object.cut_overlays()
	mood_screen_object.color = initial(mood_screen_object.color)

	// lets see if we have an special icons to show instead of the normal mood levels
	var/list/conflicting_moodies = list()
	var/highest_absolute_mood = 0
	for (var/mood_event in mood_events)
		var/datum/mood_event/the_event = mood_events[mood_event]
		if (!the_event.special_screen_obj)
			continue
		if (!the_event.special_screen_replace)
			mood_screen_object.add_overlay(the_event.special_screen_obj)
		else
			conflicting_moodies += the_event
			var/absmood = abs(the_event.mood_change)
			highest_absolute_mood = absmood > highest_absolute_mood ? absmood : highest_absolute_mood

	switch(sanity_level)
		if (SANITY_LEVEL_GREAT)
			mood_screen_object.color = "#2eeb9a"
		if (SANITY_LEVEL_NEUTRAL)
			mood_screen_object.color = "#86d656"
		if (SANITY_LEVEL_DISTURBED)
			mood_screen_object.color = "#4b96c4"
		if (SANITY_LEVEL_UNSTABLE)
			mood_screen_object.color = "#dfa65b"
		if (SANITY_LEVEL_CRAZY)
			mood_screen_object.color = "#f38943"
		if (SANITY_LEVEL_INSANE)
			mood_screen_object.color = "#f15d36"

	if (!conflicting_moodies.len) // theres no special icons, use the normal icon states
		mood_screen_object.icon_state = "mood[mood_level]"
		return

	for (var/datum/mood_event/conflicting_event as anything in conflicting_moodies)
		if (abs(conflicting_event.mood_change) == highest_absolute_mood)
			mood_screen_object.icon_state = "[conflicting_event.special_screen_obj]"
			break

/datum/mood/proc/modify_hud(datum/source)
	SIGNAL_HANDLER

	var/mob/living/owner = parent?.resolve()
	if (!owner)
		return

	var/datum/hud/hud = owner.hud_used
	mood_screen_object = new
	mood_screen_object.color = "#4b96c4"
	hud.infodisplay += mood_screen_object
	RegisterSignal(hud, COMSIG_PARENT_QDELETING, .proc/unmodify_hud)
	RegisterSignal(mood_screen_object, COMSIG_CLICK, .proc/hud_click)

/datum/mood/proc/unmodify_hud(datum/source)
	SIGNAL_HANDLER

	if(!mood_screen_object)
		return
	var/mob/living/mob_parent = parent?.resolve()
	var/datum/hud/hud = mob_parent.hud_used
	if(hud?.infodisplay)
		hud.infodisplay -= mood_screen_object
	QDEL_NULL(mood_screen_object)

/datum/mood/proc/hud_click(datum/source, location, control, params, mob/user)
	SIGNAL_HANDLER

	var/mob/living/mob_parent = parent?.resolve()

	if(user != mob_parent)
		return
	print_mood(user)

/datum/mood/proc/print_mood(mob/user)
	var/msg = "[span_info("<EM>My current mental status:</EM>")]\n"
	msg += span_notice("My current sanity: ") //Long term
	switch(sanity)
		if(SANITY_GREAT to INFINITY)
			msg += "[span_boldnicegreen("My mind feels like a temple!")]\n"
		if(SANITY_NEUTRAL to SANITY_GREAT)
			msg += "[span_nicegreen("I have been feeling great lately!")]\n"
		if(SANITY_DISTURBED to SANITY_NEUTRAL)
			msg += "[span_nicegreen("I have felt quite decent lately.")]\n"
		if(SANITY_UNSTABLE to SANITY_DISTURBED)
			msg += "[span_warning("I'm feeling a little bit unhinged...")]\n"
		if(SANITY_CRAZY to SANITY_UNSTABLE)
			msg += "[span_warning("I'm freaking out!!")]\n"
		if(SANITY_INSANE to SANITY_CRAZY)
			msg += "[span_boldwarning("AHAHAHAHAHAHAHAHAHAH!!")]\n"

	msg += span_notice("My current mood: ") //Short term
	switch(mood_level)
		if(1)
			msg += "[span_boldwarning("I wish I was dead!")]\n"
		if(2)
			msg += "[span_boldwarning("I feel terrible...")]\n"
		if(3)
			msg += "[span_boldwarning("I feel very upset.")]\n"
		if(4)
			msg += "[span_warning("I'm a bit sad.")]\n"
		if(5)
			msg += "[span_grey("I'm alright.")]\n"
		if(6)
			msg += "[span_nicegreen("I feel pretty okay.")]\n"
		if(7)
			msg += "[span_boldnicegreen("I feel pretty good.")]\n"
		if(8)
			msg += "[span_boldnicegreen("I feel amazing!")]\n"
		if(9)
			msg += "[span_boldnicegreen("I love life!")]\n"

	msg += "[span_notice("Moodlets:")]\n"//All moodlets
	if(mood_events.len)
		for(var/i in mood_events)
			var/datum/mood_event/event = mood_events[i]
			switch(event.mood_change)
				if(-INFINITY to MOOD_LEVEL_SAD2)
					msg += span_boldwarning(event.description + "\n")
				if(MOOD_LEVEL_SAD2 to MOOD_LEVEL_SAD1)
					msg += span_warning(event.description + "\n")
				if(MOOD_LEVEL_SAD1 to MOOD_LEVEL_HAPPY1)
					msg += span_grey(event.description + "\n")
				if(MOOD_LEVEL_HAPPY1 to MOOD_LEVEL_HAPPY2)
					msg += span_nicegreen(event.description + "\n")
				if(MOOD_LEVEL_HAPPY2 to INFINITY)
					msg += span_boldnicegreen(event.description + "\n")
	else
		msg += "[span_grey("I don't have much of a reaction to anything right now.")]\n"
	to_chat(user, examine_block(msg))

/datum/mood/proc/check_area_mood(datum/source, area/new_area)
	SIGNAL_HANDLER

	update_beauty(new_area)
	if (new_area.mood_bonus && (!new_area.mood_trait || HAS_TRAIT(source, new_area.mood_trait)))
		add_mood_event("area", /datum/mood_event/area, new_area.mood_bonus, new_area.mood_message)
	else
		clear_mood_event("area")

/datum/mood/proc/update_beauty(area/area_to_beautify)
	if (area_to_beautify.outdoors) // if we're outside, we don't care
		clear_mood_event("area_beauty")
		return

	var/mob/living/mob_parent = parent?.resolve()
	if(HAS_TRAIT(mob_parent, TRAIT_SNOB))
		switch(area_to_beautify.beauty)
			if(-INFINITY to BEAUTY_LEVEL_HORRID)
				add_mood_event("area_beauty", /datum/mood_event/horridroom)
				return
			if(BEAUTY_LEVEL_HORRID to BEAUTY_LEVEL_BAD)
				add_mood_event("area_beauty", /datum/mood_event/badroom)
				return
	switch(area_to_beautify.beauty)
		if(BEAUTY_LEVEL_BAD to BEAUTY_LEVEL_DECENT)
			clear_mood_event("area_beauty")
		if(BEAUTY_LEVEL_DECENT to BEAUTY_LEVEL_GOOD)
			add_mood_event("area_beauty", /datum/mood_event/decentroom)
		if(BEAUTY_LEVEL_GOOD to BEAUTY_LEVEL_GREAT)
			add_mood_event("area_beauty", /datum/mood_event/goodroom)
		if(BEAUTY_LEVEL_GREAT to INFINITY)
			add_mood_event("area_beauty", /datum/mood_event/greatroom)

/// Called when parent is ahealed.
/datum/mood/proc/on_revive(datum/source, full_heal)
	SIGNAL_HANDLER

	if (!full_heal)
		return
	remove_temp_moods()
	set_sanity(initial(sanity), override = TRUE)

/// Sets sanity to the specified amount and applies effects.
/datum/mood/proc/set_sanity(amount, minimum = SANITY_INSANE, maximum = SANITY_GREAT, override = FALSE)
	// If we're out of the acceptable minimum-maximum range move back towards it in steps of 0.7
	// If the new amount would move towards the acceptable range faster then use it instead
	if(amount < minimum)
		amount += clamp(minimum - amount, 0, 0.7)
	if((!override && HAS_TRAIT(parent, TRAIT_UNSTABLE)) || amount > maximum)
		amount = min(sanity, amount)
	if(amount == sanity) //Prevents stuff from flicking around.
		return
	sanity = amount
	var/mob/living/master = parent?.resolve()
	SEND_SIGNAL(master, COMSIG_CARBON_SANITY_UPDATE, amount) // NOVA TODO: remove
	switch(sanity)
		if(SANITY_INSANE to SANITY_CRAZY)
			set_insanity_effect(MAJOR_INSANITY_PEN)
			master.add_movespeed_modifier(/datum/movespeed_modifier/sanity/insane)
			master.add_actionspeed_modifier(/datum/actionspeed_modifier/low_sanity)
			sanity_level = SANITY_LEVEL_INSANE
		if(SANITY_CRAZY to SANITY_UNSTABLE)
			set_insanity_effect(MINOR_INSANITY_PEN)
			master.add_movespeed_modifier(/datum/movespeed_modifier/sanity/crazy)
			master.add_actionspeed_modifier(/datum/actionspeed_modifier/low_sanity)
			sanity_level = SANITY_LEVEL_CRAZY
		if(SANITY_UNSTABLE to SANITY_DISTURBED)
			set_insanity_effect(0)
			master.add_movespeed_modifier(/datum/movespeed_modifier/sanity/disturbed)
			master.add_actionspeed_modifier(/datum/actionspeed_modifier/low_sanity)
			sanity_level = SANITY_LEVEL_UNSTABLE
		if(SANITY_DISTURBED to SANITY_NEUTRAL)
			set_insanity_effect(0)
			master.remove_movespeed_modifier(MOVESPEED_ID_SANITY)
			master.remove_actionspeed_modifier(ACTIONSPEED_ID_SANITY)
			sanity_level = SANITY_LEVEL_DISTURBED
		if(SANITY_NEUTRAL+1 to SANITY_GREAT+1) //shitty hack but +1 to prevent it from responding to super small differences
			set_insanity_effect(0)
			master.remove_movespeed_modifier(MOVESPEED_ID_SANITY)
			master.add_actionspeed_modifier(/datum/actionspeed_modifier/high_sanity)
			sanity_level = SANITY_LEVEL_NEUTRAL
		if(SANITY_GREAT+1 to INFINITY)
			set_insanity_effect(0)
			master.remove_movespeed_modifier(MOVESPEED_ID_SANITY)
			master.add_actionspeed_modifier(/datum/actionspeed_modifier/high_sanity)
			sanity_level = SANITY_LEVEL_GREAT
	update_mood_icon()

/datum/mood/proc/set_insanity_effect(newval)
	if (newval == insanity_effect)
		return
	var/mob/living/mob_parent = parent?.resolve()
	mob_parent.crit_threshold = (mob_parent.crit_threshold - insanity_effect) + newval
	insanity_effect = newval

/// Removes all temporary moods
/datum/mood/proc/remove_temp_moods()
	for (var/category in mood_events)
		var/datum/mood_event/moodlet = mood_events[category]
		if (!moodlet || !moodlet.timeout)
			continue
		mood_events -= moodlet.category
		qdel(moodlet)
	update_mood()

/datum/mood/proc/direct_sanity_drain(amount)
	set_sanity(sanity + amount, override = TRUE)

#undef MINOR_INSANITY_PEN
#undef MAJOR_INSANITY_PEN
