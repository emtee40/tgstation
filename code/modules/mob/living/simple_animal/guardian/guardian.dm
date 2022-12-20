GLOBAL_LIST_EMPTY(parasites) //all currently existing/living guardians

#define SUMMONER_HEALTH_PERCENTAGE ((iscarbon(summoner) ? (abs(HEALTH_THRESHOLD_DEAD - summoner.health) / abs(HEALTH_THRESHOLD_DEAD - summoner.maxHealth)) : (summoner.health / summoner.maxHealth)) * 100)

/mob/living/simple_animal/hostile/guardian
	name = "Guardian Spirit"
	real_name = "Guardian Spirit"
	desc = "A mysterious being that stands by its charge, ever vigilant."
	speak_emote = list("hisses")
	gender = NEUTER
	mob_biotypes = NONE
	bubble_icon = "guardian"
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	icon = 'icons/mob/nonhuman-player/guardian.dmi'
	icon_state = "magicbase"
	icon_living = "magicbase"
	icon_dead = "magicbase"
	speed = 0
	combat_mode = TRUE
	stop_automated_movement = 1
	attack_sound = 'sound/weapons/punch1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	maxHealth = INFINITY //The spirit itself is invincible
	health = INFINITY
	healable = FALSE //don't brusepack the guardian
	damage_coeff = list(BRUTE = 0.5, BURN = 0.5, TOX = 0.5, CLONE = 0.5, STAMINA = 0, OXY = 0.5) //how much damage from each damage type we transfer to the owner
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 40
	melee_damage_lower = 15
	melee_damage_upper = 15
	butcher_results = list(/obj/item/ectoplasm = 1)
	del_on_death = TRUE
	AIStatus = AI_OFF
	can_have_ai = FALSE
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_on = FALSE
	hud_type = /datum/hud/guardian
	dextrous_hud_type = /datum/hud/dextrous/guardian //if we're set to dextrous, account for it.
	faction = list()

	/// The guardian's color, used for their sprite, chat, and some effects made by it.
	var/guardian_color
	/// Do we recolor our entire sprite with our guardian color, rather than just having an overlay?
	var/recolor_entire_sprite = FALSE
	/// List of overlays we use.
	var/list/guardian_overlays[GUARDIAN_TOTAL_LAYERS]

	/// The summoner of the guardian, the one it's intended to guard!
	var/mob/living/summoner
	/// How far from the summoner the guardian can be.
	var/range = 10

	/// Which toggle button the HUD uses.
	var/toggle_button_type = /atom/movable/screen/guardian/toggle_mode/inactive
	/// Name used by the guardian creator.
	var/creator_name = "Error"
	/// Description used by the guardian creator.
	var/creator_desc = "This shouldn't be here! Report it on GitHub!"
	/// Icon used by the guardian creator.
	var/creator_icon = "fuck"

	/// A string explaining to the guardian what they can do.
	var/playstyle_string = span_boldholoparasite("You are a Guardian without any type. You shouldn't exist!")
	/// The fluff string we actually use.
	var/used_fluff_string
	/// Fluff string from tarot cards.
	var/magic_fluff_string = span_holoparasite("You draw the Coder, symbolizing bugs and errors. This shouldn't happen! Submit a bug report!")
	/// Fluff string from holoparasite injectors.
	var/tech_fluff_string = span_holoparasite("BOOT SEQUENCE COMPLETE. ERROR MODULE LOADED. THIS SHOULDN'T HAPPEN. Submit a bug report!")
	/// Fluff string from holocarp fishsticks.
	var/carp_fluff_string = span_holoparasite("CARP CARP CARP SOME SORT OF HORRIFIC BUG BLAME THE CODERS CARP CARP CARP")
	/// Fluff string from the dusty shard.
	var/miner_fluff_string = span_holoparasite("You encounter... Mythril, it shouldn't exist... Submit a bug report!")

	/// Are we forced to not be able to manifest/recall?
	var/locked = FALSE
	/// Cooldown between manifests/recalls.
	COOLDOWN_DECLARE(manifest_cooldown)
	/// Cooldown between the summoner resetting the guardian's client.
	COOLDOWN_DECLARE(resetting_cooldown)

/mob/living/simple_animal/hostile/guardian/Initialize(mapload, theme)
	. = ..()
	GLOB.parasites += src
	update_theme(theme)
	AddElement(/datum/element/simple_flying)

/// Setter for our summoner mob.
/mob/living/simple_animal/hostile/guardian/proc/set_summoner(mob/to_who, different_person = FALSE)
	if(summoner)
		cut_summoner(different_person)
	summoner = to_who
	update_health_hud()
	med_hud_set_health()
	med_hud_set_status()
	add_verb(to_who, list(
		/mob/living/proc/guardian_comm,
		/mob/living/proc/guardian_recall,
		/mob/living/proc/guardian_reset,
	))
	if(mind && different_person)
		mind.enslave_mind_to_creator(to_who)
	remove_all_languages(LANGUAGE_MASTER)
	copy_languages(to_who, LANGUAGE_MASTER) // make sure holoparasites speak same language as master
	update_atom_languages()
	RegisterSignal(to_who, COMSIG_MOVABLE_MOVED, PROC_REF(snapback))
	RegisterSignal(to_who, COMSIG_PARENT_QDELETING, PROC_REF(on_summoner_deletion))
	RegisterSignal(to_who, COMSIG_LIVING_DEATH, PROC_REF(on_summoner_death))
	RegisterSignal(to_who, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_summoner_health_update))
	RegisterSignal(to_who, COMSIG_LIVING_ON_WABBAJACKED, PROC_REF(on_summoner_wabbajacked))
	RegisterSignal(to_who, COMSIG_LIVING_SHAPESHIFTED, PROC_REF(on_summoner_shapeshifted))
	RegisterSignal(to_who, COMSIG_LIVING_UNSHAPESHIFTED, PROC_REF(on_summoner_unshapeshifted))
	Recall(forced = TRUE)

/mob/living/simple_animal/hostile/guardian/proc/cut_summoner(different_person = FALSE)
	forceMove(get_turf(src))
	recall_effects()
	UnregisterSignal(summoner, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH, COMSIG_LIVING_HEALTH_UPDATE, COMSIG_LIVING_ON_WABBAJACKED, COMSIG_LIVING_SHAPESHIFTED, COMSIG_LIVING_UNSHAPESHIFTED))
	if(different_person)
		faction = list()
		mind.remove_all_antag_datums()
	if(!length(summoner.get_all_linked_holoparasites() - src))
		remove_verb(summoner, list(
			/mob/living/proc/guardian_comm,
			/mob/living/proc/guardian_recall,
			/mob/living/proc/guardian_reset,
		))
	summoner = null

/// Signal proc for [COMSIG_LIVING_ON_WABBAJACKED], when our summoner is wabbajacked we should be alerted.
/mob/living/simple_animal/hostile/guardian/proc/on_summoner_wabbajacked(mob/living/source, mob/living/new_mob)
	SIGNAL_HANDLER

	set_summoner(new_mob)
	to_chat(src, span_holoparasite("Your summoner has changed form!"))

/// Signal proc for [COMSIG_LIVING_SHAPESHIFTED], when our summoner is shapeshifted we should change to the new mob
/mob/living/simple_animal/hostile/guardian/proc/on_summoner_shapeshifted(mob/living/source, mob/living/new_shape)
	SIGNAL_HANDLER

	set_summoner(new_shape)
	to_chat(src, span_holoparasite("Your summoner has shapeshifted into that of a [new_shape]!"))

/// Signal proc for [COMSIG_LIVING_UNSHAPESHIFTED], when our summoner unshapeshifts go back to that mob
/mob/living/simple_animal/hostile/guardian/proc/on_summoner_unshapeshifted(mob/living/source, mob/living/old_summoner)
	SIGNAL_HANDLER

	set_summoner(old_summoner)
	to_chat(src, span_holoparasite("Your summoner has shapeshifted back into their normal form!"))

// Ha, no
/mob/living/simple_animal/hostile/guardian/wabbajack(what_to_randomize, change_flags = WABBAJACK)
	visible_message(span_warning("[src] resists the polymorph!"))

/mob/living/simple_animal/hostile/guardian/proc/on_summoner_health_update(mob/living/source)
	SIGNAL_HANDLER

	update_health_hud()
	med_hud_set_health()
	med_hud_set_status()

/mob/living/simple_animal/hostile/guardian/med_hud_set_health()
	if(summoner)
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = "hud[RoundHealth(summoner)]"

/mob/living/simple_animal/hostile/guardian/med_hud_set_status()
	if(summoner)
		var/image/holder = hud_list[STATUS_HUD]
		var/icon/I = icon(icon, icon_state, dir)
		holder.pixel_y = I.Height() - world.icon_size
		if(summoner.stat == DEAD)
			holder.icon_state = "huddead"
		else
			holder.icon_state = "hudhealthy"

/mob/living/simple_animal/hostile/guardian/Destroy()
	GLOB.parasites -= src
	return ..()

/mob/living/simple_animal/hostile/guardian/proc/update_theme(theme) //update the guardian's theme
	if(!theme)
		theme = pick(GUARDIAN_THEME_MAGIC, GUARDIAN_THEME_TECH, GUARDIAN_THEME_CARP, GUARDIAN_THEME_MINER)
	switch(theme)//should make it easier to create new stand designs in the future if anyone likes that
		if(GUARDIAN_THEME_MAGIC)
			name = "Guardian Spirit"
			real_name = "Guardian Spirit"
			bubble_icon = "guardian"
			icon_state = "magicbase"
			icon_living = "magicbase"
			icon_dead = "magicbase"
			used_fluff_string = magic_fluff_string
		if(GUARDIAN_THEME_TECH)
			name = "Holoparasite"
			real_name = "Holoparasite"
			bubble_icon = "holo"
			icon_state = "techbase"
			icon_living = "techbase"
			icon_dead = "techbase"
			used_fluff_string = tech_fluff_string
		if(GUARDIAN_THEME_MINER)
			name = "Power Miner"
			real_name = "Power Miner"
			bubble_icon = "guardian"
			icon_state = "minerbase"
			icon_living = "minerbase"
			icon_dead = "minerbase"
			used_fluff_string = miner_fluff_string
		if(GUARDIAN_THEME_CARP)
			name = "Holocarp"
			real_name = "Holocarp"
			bubble_icon = "holo"
			icon_state = "holocarp"
			icon_living = "holocarp"
			icon_dead = "holocarp"
			speak_emote = string_list(list("gnashes"))
			desc = "A mysterious fish that stands by its charge, ever vigilant."
			attack_verb_continuous = "bites"
			attack_verb_simple = "bite"
			attack_sound = 'sound/weapons/bite.ogg'
			attack_vis_effect = ATTACK_EFFECT_BITE
			recolor_entire_sprite = TRUE
			used_fluff_string = carp_fluff_string
	if(!recolor_entire_sprite) //we want this to proc before stand logs in, so the overlay isn't gone for some reason
		guardian_overlays[GUARDIAN_COLOR_LAYER] = mutable_appearance(icon, theme)
		apply_overlay(GUARDIAN_COLOR_LAYER)

/mob/living/simple_animal/hostile/guardian/Login() //if we have a mind, set its name to ours when it logs in
	. = ..()
	if(!. || !client)
		return FALSE
	if(!summoner)
		to_chat(src, span_boldholoparasite("For some reason, somehow, you have no summoner. Please report this bug immediately."))
		return
	to_chat(src, span_holoparasite("You are a <b>[real_name]</b>, bound to serve [summoner.real_name]."))
	to_chat(src, span_holoparasite("You are capable of manifesting or recalling to your master with the buttons on your HUD. You will also find a button to communicate with [summoner.p_them()] privately there."))
	to_chat(src, span_holoparasite("While personally invincible, you will die if [summoner.real_name] does, and any damage dealt to you will have a portion passed on to [summoner.p_them()] as you feed upon [summoner.p_them()] to sustain yourself."))
	to_chat(src, playstyle_string)
	if(!guardian_color)
		locked = TRUE
		guardianrename()
		guardianrecolor()
		locked = FALSE

/mob/living/simple_animal/hostile/guardian/mind_initialize()
	. = ..()
	if(!summoner)
		to_chat(src, span_boldholoparasite("For some reason, somehow, you have no summoner. Please report this bug immediately."))
		return
	mind.enslave_mind_to_creator(summoner) //once our mind is created, we become enslaved to our summoner. cant be done in the first run of set_summoner, because by then we dont have a mind yet.

/mob/living/simple_animal/hostile/guardian/proc/guardianrecolor()
	if(!client)
		return
	guardian_color = input(src, "What would you like your color to be?","Choose Your Color","#ffffff") as color|null
	if(!guardian_color) //redo proc until we get a color
		to_chat(src, span_warning("Not a valid color, please try again."))
		guardianrecolor()
		return
	set_light_color(guardian_color)
	if(!recolor_entire_sprite)
		var/mutable_appearance/guardian_color_overlay = guardian_overlays[GUARDIAN_COLOR_LAYER]
		remove_overlay(GUARDIAN_COLOR_LAYER)
		guardian_color_overlay.color = guardian_color
		guardian_overlays[GUARDIAN_COLOR_LAYER] = guardian_color_overlay
		apply_overlay(GUARDIAN_COLOR_LAYER)
	else
		add_atom_colour(guardian_color, FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/hostile/guardian/proc/guardianrename()
	if(!client)
		return
	var/new_name = sanitize_name(reject_bad_text(tgui_input_text(src, "What would you like your name to be?", "Choose Your Name", real_name, MAX_NAME_LEN)))
	if(!new_name) //redo proc until we get a good name
		to_chat(src, span_warning("Not a valid name, please try again."))
		guardianrename()
		return
	to_chat(src, span_notice("Your new name [span_name("[new_name]")] anchors itself in your mind."))
	fully_replace_character_name(null, new_name)

/mob/living/simple_animal/hostile/guardian/proc/on_summoner_death(mob/living/source)
	SIGNAL_HANDLER

	cut_summoner()
	forceMove(source.loc)
	to_chat(src, span_danger("Your summoner has died!"))
	visible_message(span_bolddanger("\The [src] dies along with its user!"))
	source.visible_message(span_bolddanger("[source]'s body is completely consumed by the strain of sustaining [src]!"))
	source.dust(drop_items = TRUE)
	death(TRUE)

/mob/living/simple_animal/hostile/guardian/proc/on_summoner_deletion(mob/living/source)
	SIGNAL_HANDLER

	cut_summoner()
	to_chat(src, span_danger("Your summoner is gone!"))
	qdel(src)

/mob/living/simple_animal/hostile/guardian/get_status_tab_items()
	. += ..()
	if(summoner)
		var/healthpercent = SUMMONER_HEALTH_PERCENTAGE
		. += "Summoner Health: [round(healthpercent, 0.5)]%"
	if(!COOLDOWN_FINISHED(src, manifest_cooldown))
		. += "Manifest/Recall Cooldown Remaining: [DisplayTimeText(COOLDOWN_TIMELEFT(src, manifest_cooldown))]"

/mob/living/simple_animal/hostile/guardian/Move() //Returns to summoner if they move out of range
	. = ..()
	snapback()

/mob/living/simple_animal/hostile/guardian/proc/snapback()
	SIGNAL_HANDLER

	if(!summoner)
		return
	if(get_dist(get_turf(summoner), get_turf(src)) <= range)
		return
	to_chat(src, span_holoparasite("You moved out of range, and were pulled back! You can only move [range] meters from [summoner.real_name]!"))
	visible_message(span_danger("\The [src] jumps back to its user."))
	if(istype(summoner.loc, /obj/effect))
		Recall(forced = TRUE)
	else
		new /obj/effect/temp_visual/guardian/phase/out(loc)
		forceMove(summoner.loc)
		new /obj/effect/temp_visual/guardian/phase(loc)

/mob/living/simple_animal/hostile/guardian/canSuicide()
	return FALSE

/mob/living/simple_animal/hostile/guardian/proc/is_deployed()
	return loc != summoner

/mob/living/simple_animal/hostile/guardian/AttackingTarget(atom/attacked_target)
	if(!is_deployed())
		to_chat(src, span_bolddanger("You must be manifested to attack!"))
		return FALSE
	else
		return ..()

/mob/living/simple_animal/hostile/guardian/death(gibbed)
	. = ..()
	if(!QDELETED(summoner))
		to_chat(summoner, span_bolddanger("Your [name] died somehow!"))
		summoner.dust()

/mob/living/simple_animal/hostile/guardian/update_health_hud()
	if(!summoner)
		return
	var/severity = 0
	var/healthpercent = SUMMONER_HEALTH_PERCENTAGE
	switch(healthpercent)
		if(100 to INFINITY)
			severity = 0
		if(85 to 100)
			severity = 1
		if(70 to 85)
			severity = 2
		if(55 to 70)
			severity = 3
		if(40 to 55)
			severity = 4
		if(25 to 40)
			severity = 5
		else
			severity = 6
	if(severity > 0)
		overlay_fullscreen("brute", /atom/movable/screen/fullscreen/brute, severity)
	else
		clear_fullscreen("brute")
	if(hud_used?.healths)
		hud_used.healths.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#efeeef'>[round(healthpercent, 0.5)]%</font></div>")

/mob/living/simple_animal/hostile/guardian/adjustHealth(amount, updating_health = TRUE, forced = FALSE) //The spirit is invincible, but passes on damage to the summoner
	. = amount
	if(summoner)
		if(loc == summoner)
			return FALSE
		summoner.adjustBruteLoss(amount)
		if(amount > 0 && !QDELETED(summoner))
			to_chat(summoner, span_bolddanger("Your [name] is under attack! You take damage!"))
			summoner.visible_message(span_bolddanger("Blood sprays from [summoner] as [src] takes damage!"))
			switch(summoner.stat)
				if(UNCONSCIOUS, HARD_CRIT)
					to_chat(summoner, span_bolddanger("Your body can't take the strain of sustaining [src] in this condition, it begins to fall apart!"))
					summoner.adjustCloneLoss(amount * 0.5) //dying hosts take 50% bonus damage as cloneloss

/mob/living/simple_animal/hostile/guardian/ex_act(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			investigate_log("has been gibbed by an explosion.", INVESTIGATE_DEATHS)
			gib()
			return TRUE
		if(EXPLODE_HEAVY)
			adjustBruteLoss(60)
		if(EXPLODE_LIGHT)
			adjustBruteLoss(30)

/mob/living/simple_animal/hostile/guardian/gib()
	death(TRUE)

/mob/living/simple_animal/hostile/guardian/dust(just_ash, drop_items, force)
	death(TRUE)

//HAND HANDLING

/mob/living/simple_animal/hostile/guardian/equip_to_slot(obj/item/I, slot)
	if(!slot)
		return FALSE
	if(!istype(I))
		return FALSE

	. = TRUE
	var/index = get_held_index_of_item(I)
	if(index)
		held_items[index] = null
		update_held_items()

	if(I.pulledby)
		I.pulledby.stop_pulling()

	I.screen_loc = null // will get moved if inventory is visible
	I.forceMove(src)
	I.equipped(src, slot)
	SET_PLANE_EXPLICIT(I, ABOVE_HUD_PLANE, src)

/mob/living/simple_animal/hostile/guardian/proc/apply_overlay(cache_index)
	if((. = guardian_overlays[cache_index]))
		add_overlay(.)

/mob/living/simple_animal/hostile/guardian/proc/remove_overlay(cache_index)
	var/I = guardian_overlays[cache_index]
	if(I)
		cut_overlay(I)
		guardian_overlays[cache_index] = null

/mob/living/simple_animal/hostile/guardian/update_held_items()
	remove_overlay(GUARDIAN_HANDS_LAYER)
	var/list/hands_overlays = list()
	var/obj/item/l_hand = get_item_for_held_index(1)
	var/obj/item/r_hand = get_item_for_held_index(2)

	if(r_hand)
		hands_overlays += r_hand.build_worn_icon(default_layer = GUARDIAN_HANDS_LAYER, default_icon_file = r_hand.righthand_file, isinhands = TRUE)

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			SET_PLANE_EXPLICIT(r_hand, ABOVE_HUD_PLANE, src)
			r_hand.screen_loc = ui_hand_position(get_held_index_of_item(r_hand))
			client.screen |= r_hand

	if(l_hand)
		hands_overlays += l_hand.build_worn_icon(default_layer = GUARDIAN_HANDS_LAYER, default_icon_file = l_hand.lefthand_file, isinhands = TRUE)

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			SET_PLANE_EXPLICIT(l_hand, ABOVE_HUD_PLANE, src)
			l_hand.screen_loc = ui_hand_position(get_held_index_of_item(l_hand))
			client.screen |= l_hand

	if(length(hands_overlays))
		guardian_overlays[GUARDIAN_HANDS_LAYER] = hands_overlays
	apply_overlay(GUARDIAN_HANDS_LAYER)

/mob/living/simple_animal/hostile/guardian/regenerate_icons()
	update_held_items()

//MANIFEST, RECALL, TOGGLE MODE/LIGHT, SHOW TYPE

/mob/living/simple_animal/hostile/guardian/proc/Manifest(forced)
	if(istype(summoner.loc, /obj/effect) || (!COOLDOWN_FINISHED(src, manifest_cooldown) && !forced) || locked)
		return FALSE
	if(loc == summoner)
		forceMove(summoner.loc)
		new /obj/effect/temp_visual/guardian/phase(loc)
		COOLDOWN_START(src, manifest_cooldown, 1 SECONDS)
		reset_perspective()
		summon_effects()
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/guardian/proc/Recall(forced)
	if(!summoner || loc == summoner || (!COOLDOWN_FINISHED(src, manifest_cooldown) && !forced) || locked)
		return FALSE
	new /obj/effect/temp_visual/guardian/phase/out(loc)
	forceMove(summoner)
	COOLDOWN_START(src, manifest_cooldown, 1 SECONDS)
	recall_effects()
	return TRUE

/mob/living/simple_animal/hostile/guardian/proc/summon_effects()
	return

/mob/living/simple_animal/hostile/guardian/proc/recall_effects()
	return

/mob/living/simple_animal/hostile/guardian/proc/ToggleMode()
	to_chat(src, span_bolddanger("You don't have another mode!"))

/mob/living/simple_animal/hostile/guardian/proc/ToggleLight()
	if(!light_on)
		to_chat(src, span_notice("You activate your light."))
		set_light_on(TRUE)
	else
		to_chat(src, span_notice("You deactivate your light."))
		set_light_on(FALSE)


/mob/living/simple_animal/hostile/guardian/verb/ShowType()
	set name = "Check Guardian Type"
	set category = "Guardian"
	set desc = "Check what type you are."
	to_chat(src, playstyle_string)

//COMMUNICATION

/mob/living/simple_animal/hostile/guardian/proc/Communicate()
	if(summoner)
		var/sender_key = key
		var/input = tgui_input_text(src, "Enter a message to tell your summoner", "Guardian")
		if(sender_key != key || !input) //guardian got reset, or did not enter anything
			return

		var/preliminary_message = span_boldholoparasite("[input]") //apply basic color/bolding
		var/my_message = "<font color=\"[guardian_color]\"><b><i>[src]:</i></b></font> [preliminary_message]" //add source, color source with the guardian's color

		to_chat(summoner, "<span class='say'>[my_message]</span>")
		var/list/guardians = summoner.get_all_linked_holoparasites()
		for(var/para in guardians)
			to_chat(para, "<span class='say'>[my_message]</span>")
		for(var/M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "<span class='say'>[link] [my_message]</span>")

		src.log_talk(input, LOG_SAY, tag="guardian")

/mob/living/proc/guardian_comm()
	set name = "Communicate"
	set category = "Guardian"
	set desc = "Communicate telepathically with your guardian."
	var/input = tgui_input_text(src, "Enter a message to tell your guardian", "Message")
	if(!input)
		return

	var/preliminary_message = span_boldholoparasite("[input]") //apply basic color/bolding
	var/my_message = span_boldholoparasite("<i>[src]:</i> [preliminary_message]") //add source, color source with default grey...

	to_chat(src, "<span class='say'>[my_message]</span>")
	var/list/guardians = get_all_linked_holoparasites()
	for(var/para in guardians)
		var/mob/living/simple_animal/hostile/guardian/G = para
		to_chat(G, "<span class='say'><font color=\"[G.guardian_color]\"><b><i>[src]:</i></b></font> [preliminary_message]</span>" )
	for(var/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, src)
		to_chat(M, "<span class='say'>[link] [my_message]</span>")

	src.log_talk(input, LOG_SAY, tag="guardian")

//FORCE RECALL/RESET

/mob/living/proc/guardian_recall()
	set name = "Recall Guardian"
	set category = "Guardian"
	set desc = "Forcibly recall your guardian."
	var/list/guardians = get_all_linked_holoparasites()
	for(var/mob/living/simple_animal/hostile/guardian/guardian in guardians)
		guardian.Recall()

/mob/living/proc/guardian_reset()
	set name = "Reset Guardian Player (5 Minute Cooldown)"
	set category = "Guardian"
	set desc = "Re-rolls which ghost will control your Guardian. Can be used once per 5 minutes."

	var/list/guardians = get_all_linked_holoparasites()
	for(var/mob/living/simple_animal/hostile/guardian/resetting_guardian as anything in guardians)
		if(!COOLDOWN_FINISHED(resetting_guardian, resetting_cooldown))
			guardians -= resetting_guardian //clear out guardians that are already reset

	var/mob/living/simple_animal/hostile/guardian/chosen_guardian = tgui_input_list(src, "Pick the guardian you wish to reset", "Guardian Reset", sort_names(guardians))
	if(isnull(chosen_guardian))
		to_chat(src, span_holoparasite("You decide not to reset [length(guardians) > 1 ? "any of your guardians":"your guardian"]."))
		return

	to_chat(src, span_holoparasite("You attempt to reset <font color=\"[chosen_guardian.guardian_color]\"><b>[chosen_guardian.real_name]</b></font>'s personality..."))
	var/list/mob/dead/observer/ghost_candidates = poll_ghost_candidates("Do you want to play as [src.real_name]'s Guardian Spirit?", ROLE_PAI, FALSE, 100)
	if(!LAZYLEN(ghost_candidates))
		to_chat(src, span_holoparasite("There were no ghosts willing to take control of <font color=\"[chosen_guardian.guardian_color]\"><b>[chosen_guardian.real_name]</b></font>. Looks like you're stuck with it for now."))
		return

	var/mob/dead/observer/candidate = pick(ghost_candidates)
	to_chat(chosen_guardian, span_holoparasite("Your user reset you, and your body was taken over by a ghost. Looks like they weren't happy with your performance."))
	to_chat(src, span_boldholoparasite("Your <font color=\"[chosen_guardian.guardian_color]\">[chosen_guardian.real_name]</font> has been successfully reset."))
	message_admins("[key_name_admin(candidate)] has taken control of ([ADMIN_LOOKUPFLW(chosen_guardian)])")
	chosen_guardian.ghostize(FALSE)
	chosen_guardian.key = candidate.key
	COOLDOWN_START(chosen_guardian, resetting_cooldown, 5 MINUTES)
	chosen_guardian.guardianrename() //give it a new color and name, to show it's a new person
	chosen_guardian.guardianrecolor()

////////parasite tracking/finding procs

/// Returns a list of all holoparasites that has this mob as a summoner.
/mob/living/proc/get_all_linked_holoparasites()
	RETURN_TYPE(/list)
	var/list/all_parasites = list()
	for(var/mob/living/simple_animal/hostile/guardian/stand as anything in GLOB.parasites)
		if(stand.summoner != src)
			continue
		all_parasites += stand
	return all_parasites

/// Returns true if this holoparasite has the same summoner as the passed holoparasite.
/mob/living/simple_animal/hostile/guardian/proc/hasmatchingsummoner(mob/living/simple_animal/hostile/guardian/other_guardian)
	return istype(other_guardian) && other_guardian.summoner == summoner

#undef SUMMONER_HEALTH_PERCENTAGE
