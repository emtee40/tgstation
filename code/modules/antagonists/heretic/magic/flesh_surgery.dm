/datum/action/cooldown/spell/touch/flesh_surgery
	name = "Knit Flesh"
	desc = "A touch spell that allows you to extract the organs of a victim without needing to complete surgery or disembowel. \
		Can also be used to restore failing or destroyed organs to optimal condition, or restore health to your minions and summons."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mad_touch"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS
	invocation = "CL'M M'N!" // "CLAIM MINE", but also almost "KALI MA"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE

	hand_path = /obj/item/melee/touch_attack/flesh_surgery

	/// If used on an organ, how much percent of the organ's HP do we restore
	var/organ_percent_healing = 0.5
	/// If used on a heretic mob, how much brute do we heal
	var/monster_brute_healing = 10
	/// If used on a heretic mob, how much burn do we heal
	var/monster_burn_healing = 5

/datum/action/cooldown/spell/touch/flesh_surgery/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	if(isorgan(victim))
		return heal_organ(hand, victim, caster)

	if(isliving(victim))
		var/mob/living/mob_victim = victim
		if(mob_victim.stat != DEAD && IS_HERETIC_MONSTER(mob_victim))
			return heal_heretic_monster(hand, mob_victim, caster)
		else
			return steal_organ_from_mob(hand, mob_victim, caster)

	return FALSE

/// If cast on an organ, we'll restore it's health and even un-fail it.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/heal_organ(obj/item/melee/touch_attack/hand, obj/item/organ/to_heal, mob/living/carbon/caster)
	to_heal.balloon_alert(caster, "healing organ...")
	if(!do_after(caster, 1 SECONDS, to_heal, extra_checks = CALLBACK(src, .proc/heal_checks, hand, to_heal, caster)))
		to_heal.balloon_alert(caster, "interrupted!")
		return FALSE

	var/organ_hp_to_heal = to_heal.maxHealth * organ_percent_healing
	if(to_heal.damage < organ_hp_to_heal)
		to_heal.setOrganDamage(organ_hp_to_heal)
		to_heal.balloon_alert(caster, "organ healed")
		playsound(to_heal, 'sound/magic/staff_healing.ogg', 30)
		new /obj/effect/temp_visual/cult/sparks(get_turf(to_heal))
		caster.visible_message(
			span_warning("[caster]'s hand glows a brilliant red as [caster.p_they()] restore \the [to_heal] to good condition!"),
			span_notice("Your hand glows a brilliant red as you restore \the [to_heal] to good condition!"),
		)
	else
		to_heal.balloon_alert(caster, "already in good condition!")

	return TRUE

/// If cast on a heretic monster who's not dead we'll heal it a bit.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/heal_heretic_monster(obj/item/melee/touch_attack/hand, mob/living/to_heal, mob/living/carbon/caster)
	var/what_are_we = ishuman(to_heal) ? "minion" : "summon"
	to_heal.balloon_alert(caster, "healing [what_are_we]...")
	if(!do_after(caster, 1 SECONDS, to_heal, extra_checks = CALLBACK(src, .proc/heal_checks, hand, to_heal, caster)))
		to_heal.balloon_alert(caster, "interrupted!")
		return FALSE

	// Keep in mind that, for simplemobs(summons), this will just flat heal the combined value of both brute and burn healing,
	// while for human minions(ghouls), this will heal brute and burn like normal. So be careful adjusting to bigger numbers
	to_heal.balloon_alert(caster, "[what_are_we] healed")
	to_heal.heal_overall_damage(monster_brute_healing, monster_burn_healing)
	playsound(to_heal, 'sound/magic/staff_healing.ogg', 30)
	new /obj/effect/temp_visual/cult/sparks(get_turf(to_heal))
	caster.visible_message(
		span_warning("[caster]'s hand glows a brilliant red as [caster.p_they()] restore [to_heal] to good condition!"),
		span_notice("Your hand glows a brilliant red as you restore [to_heal] to good condition!"),
	)
	return TRUE

/// If cast on a carbon, we'll try to steal one of their organs directly from their person.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/steal_organ_from_mob(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	var/mob/living/carbon/carbon_victim = victim
	if(!istype(carbon_victim) || !length(carbon_victim.internal_organs))
		victim.balloon_alert(caster, "no organs!")
		return FALSE

	// Round u pto the nearest generic zone (body, chest, arm)
	var/zone_to_check = check_zone(caster.zone_selected)
	var/parsed_zone = parse_zone(zone_to_check)

	var/list/organs_we_can_remove = list()
	for(var/obj/item/organ/organ as anything in carbon_victim.internal_organs)
		// Only show organs which are in our generic zone
		if(deprecise_zone(organ.zone) != zone_to_check)
			continue
		// Also, some organs to exclude. Don't remove vital (brains), don't remove synthetics, and don't remove unremovable
		if(organ.organ_flags & (ORGAN_SYNTHETIC|ORGAN_VITAL|ORGAN_UNREMOVABLE))
			continue

		organs_we_can_remove[organ.name] = organ

	if(!length(organs_we_can_remove))
		victim.balloon_alert(caster, "no organs there!")
		return FALSE

	var/chosen_organ = tgui_input_list(caster, "Which organ do you want to extract?", name, sort_list(organs_we_can_remove))
	if(isnull(chosen_organ))
		return FALSE
	var/obj/item/organ/picked_organ = organs_we_can_remove[chosen_organ]
	if(!istype(picked_organ) || !extraction_checks(picked_organ, hand, victim, caster))
		return FALSE

	// Don't let people stam crit into steal heart true combo
	var/time_it_takes = carbon_victim.stat == DEAD ? 3 SECONDS : 15 SECONDS

	// Sure you can remove your own organs, fun party trick
	if(carbon_victim == caster)
		var/are_you_sure = tgui_alert(caster, "Are you sure you want to remove your own [chosen_organ]?", "Are you sure?", list("Yes", "No"))
		if(are_you_sure != "Yes" || !extraction_checks(picked_organ, hand, victim, caster))
			return FALSE

		time_it_takes = 6 SECONDS
		caster.visible_message(
			span_danger("[caster]'s hand glows a brilliant red as [caster.p_they()] reach directly into [caster.p_their()] own [parsed_zone]!"),
			span_userdanger("Your hand glows a brilliant red as you reach directly into your own [parsed_zone]!"),
		)

	else
		carbon_victim.visible_message(
			span_danger("[caster]'s hand glows a brilliant red as [caster.p_they()] reach directly into [carbon_victim]'s [parsed_zone]!"),
			span_userdanger("[caster]'s hand glows a brilliant red as [caster.p_they()] reach directly into your [parsed_zone]!"),
		)

	carbon_victim.balloon_alert(caster, "extracting [chosen_organ]...")
	playsound(victim, 'sound/effects/dismember.ogg', 50, TRUE)
	carbon_victim.add_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_DARK_RED)
	if(!do_after(caster, time_it_takes, carbon_victim, extra_checks = CALLBACK(src, .proc/extraction_checks, picked_organ, hand, victim, caster)))
		carbon_victim.balloon_alert(caster, "interrupted!")
		return FALSE

	// Visible message done before Remove()
	// Mainly so it gets across if you're taking the eyes of someone who's conscious
	if(carbon_victim == caster)
		caster.visible_message(
			span_bolddanger("[caster] pulls [caster.p_their()] own [chosen_organ] out of [caster.p_their()] [parsed_zone]!!"),
			span_userdanger("You pull your own [chosen_organ] out of your [parsed_zone]!!"),
		)

	else
		carbon_victim.visible_message(
			span_bolddanger("[caster]'s pulls [carbon_victim]'s [chosen_organ] out of [carbon_victim.p_their()] [parsed_zone]!!"),
			span_userdanger("[caster]'s pulls your [chosen_organ] out of [carbon_victim.p_their()] [parsed_zone]!!"),
		)

	picked_organ.Remove(carbon_victim)
	carbon_victim.balloon_alert(caster, "[chosen_organ] removed")
	carbon_victim.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_DARK_RED)
	playsound(victim, 'sound/effects/blobattack.ogg', 50, TRUE)
	if(carbon_victim.stat == CONSCIOUS)
		carbon_victim.adjust_timed_status_effect(15 SECONDS, /datum/status_effect/speech/slurring/heretic)
		carbon_victim.emote("scream")

	// We need to wait for the spell to actually finish casting to put the organ in their hands, hence, 1 ms timer.
	addtimer(CALLBACK(caster, /mob.proc/put_in_hands, picked_organ), 1)
	return TRUE

/// Extra checks ran while we're extracting an organ to make sure we can continue to do.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/extraction_checks(obj/item/organ/picked_organ, obj/item/melee/touch_attack/hand, mob/living/carbon/victim, mob/living/carbon/caster)
	if(QDELETED(hand) || QDELETED(picked_organ) || QDELETED(victim) || !IsAvailable())
		return FALSE

	return TRUE

/// Extra checks ran while we're healing something (organ, mob).
/datum/action/cooldown/spell/touch/flesh_surgery/proc/heal_checks(obj/item/melee/touch_attack/hand, atom/healing, mob/living/carbon/caster)
	if(QDELETED(hand) ||QDELETED(healing) || !IsAvailable())
		return FALSE

	return TRUE

/obj/item/melee/touch_attack/flesh_surgery
	name = "\improper knit flesh"
	desc = "Let's go practice medicine."
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
