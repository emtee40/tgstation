/datum/round_event_control/bitrunning_glitch
	name = "Spawn Bitrunning Glitch"
	admin_setup = list(
		/datum/event_admin_setup/minimum_candidate_requirement/bitrunning_glitch,
		/datum/event_admin_setup/listed_options/bitrunning_glitch,
	)
	category = EVENT_CATEGORY_INVASION
	description = "Causes a short term antagonist to spawn in the virtual domain."
	dynamic_should_hijack = FALSE
	min_players = 1
	max_occurrences = 0
	typepath = /datum/round_event/ghost_role/bitrunning_glitch
	weight = 100
	/// List of servers on the station
	var/list/active_servers = list()

/datum/round_event_control/bitrunning_glitch/can_spawn_event(players_amt, allow_magic = FALSE)
	. = ..()
	if(!.)
		return .

	active_servers.Cut()

	validate_servers()

	if(length(active_servers))
		return TRUE

/// All servers currently running, has players in it, and map has valid mobs
/datum/round_event_control/bitrunning_glitch/proc/validate_servers()
	for(var/obj/machinery/quantum_server/server in SSmachines.get_machines_by_type(/obj/machinery/quantum_server))
		if(server.validate_mutation_candidates())
			active_servers.Add(server)

	return length(active_servers) > 0

/datum/event_admin_setup/listed_options/bitrunning_glitch
	input_text = "Select a role to spawn."

/datum/event_admin_setup/listed_options/bitrunning_glitch/get_list()
	var/list/available = list("Random")
	available += subtypesof(/datum/antagonist/bitrunning_glitch)

	return available

/datum/event_admin_setup/listed_options/bitrunning_glitch/apply_to_event(datum/round_event/ghost_role/bitrunning_glitch/event)
	if(chosen == "Random")
		event.forced_role = null
	else
		event.forced_role = chosen

/datum/event_admin_setup/minimum_candidate_requirement/bitrunning_glitch
	output_text = "There must be valid mobs to mutate or players in the domain!"

/datum/event_admin_setup/minimum_candidate_requirement/bitrunning_glitch/count_candidates()
	var/datum/round_event_control/bitrunning_glitch/cyber_control = event_control
	cyber_control.validate_servers()

	var/total = 0
	for(var/obj/machinery/quantum_server/server in cyber_control.active_servers)
		total += length(server.mutation_candidate_refs)

	return total

/datum/round_event/ghost_role/bitrunning_glitch
	minimum_required = 1
	role_name = "Bitrunning Glitch"
	fakeable = FALSE
	/// Admin customization: What to spawn
	var/forced_role

/datum/round_event/ghost_role/bitrunning_glitch/spawn_role()
	var/datum/round_event_control/bitrunning_glitch/cyber_control = control

	var/obj/machinery/quantum_server/unlucky_server = pick(cyber_control.active_servers)
	cyber_control.active_servers.Cut()

	if(!unlucky_server.validate_mutation_candidates())
		return MAP_ERROR

	unlucky_server.setup_glitch(forced_role)

	return SUCCESSFUL_SPAWN

