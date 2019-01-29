/datum/round_event_control/fugitives
	name = "Spawn Fugitives"
	typepath = /datum/round_event/ghost_role/fugitives
	max_occurrences = 1
	min_players = 20
	earliest_start = 30 MINUTES //deadchat sink, lets not even consider it early on.

/datum/round_event/ghost_role/fugitives
	minimum_required = 1
	role_name = "fugitive"
	fakeable = FALSE

/datum/round_event/ghost_role/fugitives/spawn_role()
	var/list/candidates = get_candidates(ROLE_TRAITOR, null, ROLE_TRAITOR)
	if(candidates.len < 4)
		return NOT_ENOUGH_PLAYERS

	var/turf/landing_turf = pick(GLOB.xeno_spawn)
	if(!landing_turf)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	var/backstory = pick(list("prisoner", "cultists", "waldo", "synth"))
	var/member_size = 3
	var/leader
	switch(backstory)
		if("cultists" || "synth")
			leader = pick_n_take(candidates)
		if("waldo")
			var/member_size = 0 //no leader, so it will be bumped to the one and only waldo
	var/list/members = list()
	var/list/spawned_mobs = list()
	if(isnull(leader))
		member_size++ //if there is no leader role, then the would be leader is a normal member of the team.

	for(var/i in 1 to member_size)
		members += pick_n_take(candidates)

	for(var/mob/dead/selected in members)
		var/mob/living/carbon/human/S = gear_fugitive(selected)
		spawned_mobs += S
	if(!isnull(leader))
		gear_special(leader, spawned_members)


//after spawning
	playsound(src, 'sound/weapons/emitter.ogg', 50, 1)
	new /obj/item/storage/toolbox/mechanical(landing_turf) //so they can actually escape maint
	addtimer(CALLBACK(src, .proc/spawn_security), 6000) //10 minutes
	return SUCCESSFUL_SPAWN

/datum/round_event/ghost_role/fugitives/proc/gear_fugitive(var/mob/dead/selected) //spawns normal fugitive
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE
	var/mob/living/carbon/human/S = new(landing_turf)
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Fugitive"
	player_mind.special_role = "Fugitive"
	player_mind.add_antag_datum(/datum/antagonist/fugitive) //they are not antagonists, but will show up roundend to see how they fared (and their origin)
	var/datum/antagonist/fugitive/fugitiveantag = player_mind.has_antag_datum(/datum/antagonist/fugitive)
	fugitiveantag.greet(backstory)

	switch(backstory)
		if("prisoner")
			S.fully_replace_character_name(null,"NTP #CC-0[rand(111,999)]") //same as the lavaland prisoner transport, but this time they are from CC, or CentCom
			S.equipOutfit(/datum/outfit/prisoner)
		if("cultist")
			S.equipOutfit(/datum/outfit/yalp_cultist)
		if("waldo")
			S.equipOutfit(/datum/outfit/waldo)
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Fugitive by an event.")
	log_game("[key_name(S)] was spawned as a Fugitive by an event.")
	spawned_mobs += S
	return S

/datum/round_event/ghost_role/fugitives/proc/gear_special(var/mob/dead/leader, list/spawned_mobs) //spawns the leader of the fugitive group, if they have one.
	switch(backstory)
		if("cultist")
			var/mob/camera/yalp_elor/yalp = new(landing_turf)
			player_mind.transfer_to(yalp)
			player_mind.assigned_role = "Yalp Elor"
			player_mind.special_role = "Old God"
			player_mind.add_antag_datum(/datum/antagonist/fugitive)
			for(var/mob/living/L in spawned_mobs)
				yalp.the_faithful += L

//security team gets called in after 10 minutes of prep to find the refugees
/datum/round_event/ghost_role/fugitives/proc/spawn_security()
	var/list/candidates = get_candidates(ROLE_TRAITOR, null, ROLE_TRAITOR)
	if(!candidates.len)
		return
	//wip
