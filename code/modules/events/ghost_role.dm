/datum/round_event/ghost_role
	// We expect 0 or more /clients in this list
	var/list/priority_candidates = list()
	var/minimum_required = 1
	var/role_name = "cancer rat" // Q U A L I T Y  M E M E S

/datum/round_event/ghost_role/start()
	try_spawning()

/datum/round_event/ghost_role/proc/try_spawning(sanity = 0)
	// The event does not run until the spawning has been attempted
	// to prevent us from getting gc'd halfway through
	processing = FALSE

	var/status = spawn_role()
	if(status == WAITING_FOR_SOMETHING)
		message_admins("The event will not spawn a [role_name] until certain \
			conditions are met. Waiting 30s and then retrying.")
		spawn(300)
			// I hope this doesn't end up running out of stack space
			try_spawning()
		return

	if(status == MAP_ERROR)
		message_admins("[role_name] cannot be spawned due to a map error.")
	else if(status == NOT_ENOUGH_PLAYERS)
		message_admins("[role_name] cannot be spawned due to lack of players \
			signing up.")
	else if(status == SUCCESSFUL_SPAWN)
		message_admins("[role_name] spawned successfully.")
	else
		message_admins("An attempt to spawn [role_name] returned [status], \
			this is a bug.")

	processing = TRUE

/datum/round_event/ghost_role/proc/spawn_role()
	// Return true if role was successfully spawned, false if insufficent
	// players could be found, and just runtime if anything else happens
	return TRUE

/datum/round_event/ghost_role/proc/get_candidates(jobban, gametypecheck, be_special)
	// Returns a list of candidates in priority order, with candidates from
	// `priority_candidates` first, and ghost roles randomly shuffled and
	// appended after
	var/list/mob/dead/observer/regular_candidates = pollCandidates("Do you wish to be considered for the special role of '[role_name]'?", jobban, gametypecheck, be_special)
	shuffle(regular_candidates)

	var/list/candidates = priority_candidates + regular_candidates

	return candidates

