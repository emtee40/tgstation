#define CAPTIVE_XENO_DEAD "captive_xeno_dead"
#define CAPTIVE_XENO_FAIL "captive_xeno_failed"
#define CAPTIVE_XENO_PASS "captive_xeno_escaped"

/datum/team/xeno
	name = "\improper Aliens"

//Simply lists them.
/datum/team/xeno/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>The [name] were:</span>"
	parts += printplayerlist(members)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/antagonist/xeno
	name = "\improper Xenomorph"
	job_rank = ROLE_ALIEN
	show_in_antagpanel = FALSE
	antagpanel_category = ANTAG_GROUP_XENOS
	prevent_roundtype_conversion = FALSE
	show_to_ghosts = TRUE
	var/datum/team/xeno/xeno_team

/datum/antagonist/xeno/create_team(datum/team/xeno/new_team)
	if(!new_team)
		for(var/datum/antagonist/xeno/X in GLOB.antagonists)
			if(!X.owner || !X.xeno_team || !istype(X.xeno_team, new_team)) //Istype check makes sure captive/regular xenomorphs don't get mixed up
				continue
			xeno_team = X.xeno_team
			return
		xeno_team = new
	else
		if(!istype(new_team))
			CRASH("Wrong xeno team type provided to create_team")
		xeno_team = new_team

/datum/antagonist/xeno/get_team()
	return xeno_team

/datum/antagonist/xeno/get_preview_icon()
	return finish_preview_icon(icon('icons/mob/nonhuman-player/alien.dmi', "alienh"))

/datum/antagonist/xeno/captive
	name = "\improper Captive Xenomorph"
	var/datum/team/xeno/captive/captive_team

/datum/antagonist/xeno/captive/create_team(datum/team/xeno/captive/new_team)
	if(!new_team)
		for(var/datum/antagonist/xeno/captive/captive_xeno in GLOB.antagonists)
			if(!captive_xeno.owner || !captive_xeno.captive_team)
				continue
			captive_team = captive_xeno.captive_team
			return
		captive_team = new
		captive_team.progenitor = owner
	else
		if(!istype(new_team))
			CRASH("Wrong xeno team type provided to create_team")
		captive_team = new_team

/datum/antagonist/xeno/captive/get_team()
	return captive_team

/datum/antagonist/xeno/captive/forge_objectives()

	return

/datum/team/xeno/captive
	name = "\improper Captive Aliens"
	///The first member of this team, presumably the queen.
	var/datum/mind/progenitor

/datum/team/xeno/captive/roundend_report()
	var/list/parts = list()
	var/escape_count = 0 //counts the number of xenomorphs that were born in captivity who ended the round outside of it
	var/captive_count = 0 //counts the number of xenomorphs born in captivity who remained there until the end of the round (losers)

	parts += "<span class='header'>The [name] were: </span>"

	for(var/datum/mind/alien_mind in members)
		switch(check_captivity(alien_mind.current))
			if(CAPTIVE_XENO_DEAD)
				parts += "[alien_mind] died as [alien_mind.current]!"
			if(CAPTIVE_XENO_FAIL)
				parts += "[alien_mind] remained alive and in captivity!"
				captive_count++
			if(CAPTIVE_XENO_PASS)
				parts += "[alien_mind] survived and managed to escape captivity!"
				escape_count++

	parts += "Overall, [captive_count] xenomorphs remained alive and in captivity, and [escape_count] managed to escape!"

	var/thank_you_message

	if(captive_count > escape_count)
		thank_you_message = ""
	else
		thank_you_message = ""

	parts += "Nanotrasen thanks the crew of [station_name()] for providing much needed data on [thank_you_message]"

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/xeno/captive/proc/check_captivity(mob/living/captive_alien)
	if(!captive_alien || captive_alien.stat == DEAD)
		return CAPTIVE_XENO_DEAD

	if(istype(get_area(captive_alien), /area/station/science/xenobiology))
		return CAPTIVE_XENO_FAIL

	return CAPTIVE_XENO_PASS

//XENO
/mob/living/carbon/alien/mind_initialize()
	..()
	if(!mind.has_antag_datum(/datum/antagonist/xeno))
		if(SScommunications.xenomorph_egg_delivered && istype(get_area(src), /area/station/science/xenobiology))
			mind.add_antag_datum(/datum/antagonist/xeno/captive)
		else
			mind.add_antag_datum(/datum/antagonist/xeno)

		mind.set_assigned_role(SSjob.GetJobType(/datum/job/xenomorph))
		mind.special_role = ROLE_ALIEN

/mob/living/carbon/alien/on_wabbajacked(mob/living/new_mob)
	. = ..()
	if(!mind)
		return
	if(isalien(new_mob))
		return
	mind.remove_antag_datum(/datum/antagonist/xeno)
	mind.set_assigned_role(SSjob.GetJobType(/datum/job/unassigned))
	mind.special_role = null

#undef CAPTIVE_XENO_DEAD
#undef CAPTIVE_XENO_FAIL
#undef CAPTIVE_XENO_PASS
