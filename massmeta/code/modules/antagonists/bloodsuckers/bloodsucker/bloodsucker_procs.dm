/datum/antagonist/bloodsucker/proc/on_examine(datum/source, mob/examiner, examine_text)
	SIGNAL_HANDLER

	if(!iscarbon(source))
		return
	var/vamp_examine = return_vamp_examine(examiner)
	if(vamp_examine)
		examine_text += vamp_examine

///Called when a Bloodsucker buys a power: (power)
/datum/antagonist/bloodsucker/proc/BuyPower(datum/action/bloodsucker/power)
	powers += power
	power.Grant(owner.current)
	log_uplink("[key_name(owner.current)] purchased [power].")

///Called when a Bloodsucker loses a power: (power)
/datum/antagonist/bloodsucker/proc/RemovePower(datum/action/bloodsucker/power)
	if(power.active)
		power.DeactivatePower()
	powers -= power
	power.Remove(owner.current)

///When a Bloodsucker breaks the Masquerade, they get their HUD icon changed, and Malkavian Bloodsuckers get alerted.
/datum/antagonist/bloodsucker/proc/break_masquerade()
	if(broke_masquerade)
		return
	owner.current.playsound_local(null, 'fulp_modules/features/antagonists/bloodsuckers/sounds/lunge_warn.ogg', 100, FALSE, pressure_affected = FALSE)
	to_chat(owner.current, span_cultboldtalic("You have broken the Masquerade!"))
	to_chat(owner.current, span_warning("Bloodsucker Tip: When you break the Masquerade, you become open for termination by fellow Bloodsuckers, and your Vassals are no longer completely loyal to you, as other Bloodsuckers can steal them for themselves!"))
	broke_masquerade = TRUE
	antag_hud_name = "masquerade_broken"
	add_team_hud(owner.current)
	for(var/mob/living/all_malkavians as anything in GLOB.bloodsucker_clan_members[CLAN_MALKAVIAN])
		if(!isliving(all_malkavians))
			continue
		to_chat(all_malkavians, span_userdanger("[owner.current] has broken the Masquerade! Ensure [owner.current.p_they()] [owner.current.p_are()] eliminated at all costs!"))
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = all_malkavians.mind.has_antag_datum(/datum/antagonist/bloodsucker)
		var/datum/objective/assassinate/masquerade_objective = new /datum/objective/assassinate
		masquerade_objective.target = owner.current
		masquerade_objective.objective_name = "Clan Objective"
		masquerade_objective.explanation_text = "Ensure [owner.current], who has broken the Masquerade, succumbs to Final Death."
		bloodsuckerdatum.objectives += masquerade_objective
		all_malkavians.mind.announce_objectives()

///This is admin-only of reverting a broken masquerade, sadly it doesn't remove the Malkavian objectives yet.
/datum/antagonist/bloodsucker/proc/fix_masquerade()
	if(!broke_masquerade)
		return
	to_chat(owner.current, span_cultboldtalic("You have re-entered the Masquerade."))
	broke_masquerade = FALSE

/datum/antagonist/bloodsucker/proc/give_masquerade_infraction()
	if(broke_masquerade)
		return
	masquerade_infractions++
	if(masquerade_infractions >= 3)
		break_masquerade()
	else
		to_chat(owner.current, span_cultbold("You violated the Masquerade! Break the Masquerade [3 - masquerade_infractions] more times and you will become a criminal to the Bloodsucker's Cause!"))

/datum/antagonist/bloodsucker/proc/RankUp()
	if(!owner || !owner.current || IS_FAVORITE_VASSAL(owner.current))
		return
	bloodsucker_level_unspent++
	if(!my_clan)
		to_chat(owner.current, span_notice("You have gained a rank. Join a Clan to spend it."))
		return
	// Spend Rank Immediately?
	if(my_clan.rank_up_type == BLOODSUCKER_RANK_UP_NORMAL)
		if(!istype(owner.current.loc, /obj/structure/closet/crate/coffin))
			to_chat(owner, span_notice("<EM>You have grown more ancient! Sleep in a coffin that you have claimed to thicken your blood and become more powerful.</EM>"))
			if(bloodsucker_level_unspent >= 2)
				to_chat(owner, span_announce("Bloodsucker Tip: If you cannot find or steal a coffin to use, you can build one from wood or metal."))
			return
		SpendRank()
	if(my_clan.rank_up_type == BLOODSUCKER_RANK_UP_VASSAL)
		to_chat(owner, span_announce("You have recieved a new Rank to level up your Favorite Vassal with!"))

/datum/antagonist/bloodsucker/proc/RankDown()
	bloodsucker_level_unspent--

/datum/antagonist/bloodsucker/proc/remove_nondefault_powers()
	for(var/datum/action/bloodsucker/power as anything in powers)
		if(power.purchase_flags & BLOODSUCKER_DEFAULT_POWER)
			continue
		RemovePower(power)

/datum/antagonist/bloodsucker/proc/LevelUpPowers()
	for(var/datum/action/bloodsucker/power as anything in powers)
		if(istype(power, /datum/action/bloodsucker/targeted/tremere))
			continue
		power.upgrade_power()

///Disables all powers, accounting for torpor
/datum/antagonist/bloodsucker/proc/DisableAllPowers(forced = FALSE)
	for(var/datum/action/bloodsucker/power as anything in powers)
		if(forced || ((power.check_flags & BP_CANT_USE_IN_TORPOR) && HAS_TRAIT(owner.current, TRAIT_NODEATH)))
			if(power.active)
				power.DeactivatePower()

/datum/antagonist/bloodsucker/proc/SpendRank(mob/living/carbon/human/target, cost_rank = TRUE, blood_cost)
	if(!owner || !owner.current || !owner.current.client || (cost_rank && bloodsucker_level_unspent <= 0))
		return
	SEND_SIGNAL(my_clan, BLOODSUCKER_RANK_UP, src, target, cost_rank, blood_cost)

/**
 * Called when a Bloodsucker reaches Final Death
 * Releases all Vassals and gives them the ex_vassal datum.
 */
/datum/antagonist/bloodsucker/proc/free_all_vassals()
	for(var/datum/antagonist/vassal/all_vassals in vassals)
		// Skip over any Bloodsucker Vassals, they're too far gone to have all their stuff taken away from them
		if(all_vassals.owner.has_antag_datum(/datum/antagonist/bloodsucker))
			all_vassals.owner.current.remove_status_effect(/datum/status_effect/agent_pinpointer/vassal_edition)
			continue
		if(all_vassals.special_type == REVENGE_VASSAL)
			continue
		all_vassals.owner.add_antag_datum(/datum/antagonist/ex_vassal)
		all_vassals.owner.remove_antag_datum(/datum/antagonist/vassal)

/**
 * Returns a Vampire's examine strings.
 * Args:
 * viewer - The person examining.
 */
/datum/antagonist/bloodsucker/proc/return_vamp_examine(mob/living/viewer)
	if(!viewer.mind)
		return FALSE
	// Viewer is Target's Vassal?
	if(viewer.mind.has_antag_datum(/datum/antagonist/vassal) in vassals)
		var/returnString = "\[<span class='warning'><EM>This is your Master!</EM></span>\]"
		var/returnIcon = "[icon2html('fulp_modules/features/antagonists/bloodsuckers/icons/vampiric.dmi', world, "bloodsucker")]"
		returnString += "\n"
		return returnIcon + returnString
	// Viewer not a Vamp AND not the target's vassal?
	if(!viewer.mind.has_antag_datum((/datum/antagonist/bloodsucker)) && !(viewer in vassals))
		if(!(HAS_TRAIT(viewer.mind, TRAIT_BLOODSUCKER_HUNTER) && broke_masquerade))
			return FALSE
	// Default String
	var/returnString = "\[<span class='warning'><EM>[return_full_name()]</EM></span>\]"
	var/returnIcon = "[icon2html('fulp_modules/features/antagonists/bloodsuckers/icons/vampiric.dmi', world, "bloodsucker")]"

	// In Disguise (Veil)?
	//if (name_override != null)
	//	returnString += "<span class='suicide'> ([real_name] in disguise!) </span>"

	//returnString += "\n"  Don't need spacers. Using . += "" in examine.dm does this on its own.
	return returnIcon + returnString
