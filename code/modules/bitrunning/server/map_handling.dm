/// Gives all current occupants a notification that the server is going down
/obj/machinery/quantum_server/proc/begin_shutdown(mob/user)
	if(isnull(generated_domain))
		return

	if(!length(avatar_connection_refs))
		balloon_alert_to_viewers("powering down domain...")
		playsound(src, 'sound/machines/terminal_off.ogg', 40, 2)
		reset()
		return

	balloon_alert_to_viewers("notifying clients...")
	playsound(src, 'sound/machines/terminal_alert.ogg', 100, TRUE)
	user.visible_message(
		span_danger("[user] begins depowering the server!"),
		span_notice("You start disconnecting clients..."),
		span_danger("You hear frantic keying on a keyboard."),
	)

	SEND_SIGNAL(src, COMSIG_BITRUNNER_SHUTDOWN_ALERT, user)

	if(!do_after(user, 20 SECONDS, src))
		return

	reset()

/**
 * ### Quantum Server Cold Boot
 * Procedurally links the 3 booting processes together.
 *
 * This is the starting point if you have an id. Does validation and feedback on steps
 */
/obj/machinery/quantum_server/proc/cold_boot_map(map_key)
	if(!is_ready)
		return FALSE

	if(isnull(map_key))
		balloon_alert_to_viewers("no domain specified.")
		return FALSE

	if(generated_domain)
		balloon_alert_to_viewers("stop the current domain first.")
		return FALSE

	if(length(avatar_connection_refs))
		balloon_alert_to_viewers("all clients must disconnect!")
		return FALSE

	is_ready = FALSE
	playsound(src, 'sound/machines/terminal_processing.ogg', 30, 2)

	/// If any one of these fail, it reverts the entire process
	if(!load_domain(map_key) || !load_safehouse() || !load_map_items() || !load_map_segments() || !load_mob_segments())
		balloon_alert_to_viewers("initialization failed.")
		scrub_vdom()
		is_ready = TRUE
		return FALSE

	if(prob(threat * glitch_chance))
		addtimer(CALLBACK(src, PROC_REF(spawn_glitch)), rand(5, 10) SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_DELETE_ME)

	is_ready = TRUE
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 30, 2)
	balloon_alert_to_viewers("domain loaded.")
	generated_domain.start_time = world.time
	points -= generated_domain.cost
	update_use_power(ACTIVE_POWER_USE)
	update_appearance()

	return TRUE

/// Initializes a new domain if the given key is valid and the user has enough points
/obj/machinery/quantum_server/proc/load_domain(map_key)
	for(var/datum/lazy_template/virtual_domain/available as anything in subtypesof(/datum/lazy_template/virtual_domain))
		if(map_key == initial(available.key) && points >= initial(available.cost))
			generated_domain = new available()
			RegisterSignal(generated_domain, COMSIG_LAZY_TEMPLATE_LOADED, PROC_REF(on_template_loaded))
			generated_domain.lazy_load()
			return TRUE

	return FALSE

/// Loads in necessary map items, sets mutation targets, etc
/obj/machinery/quantum_server/proc/load_map_items()
	var/turf/goal_turfs = list()
	var/turf/crate_turfs = list()

	for(var/thing in GLOB.landmarks_list)
		if(istype(thing, /obj/effect/landmark/bitrunning/hololadder_spawn))
			exit_turfs += get_turf(thing)
			qdel(thing) // i'm worried about multiple servers getting confused so lets clean em up
			continue

		if(istype(thing, /obj/effect/landmark/bitrunning/cache_goal_turf))
			var/turf/tile = get_turf(thing)
			goal_turfs += tile
			RegisterSignal(tile, COMSIG_ATOM_ENTERED, PROC_REF(on_goal_turf_entered))
			RegisterSignal(tile, COMSIG_ATOM_EXAMINE, PROC_REF(on_goal_turf_examined))
			qdel(thing)
			continue

		if(istype(thing, /obj/effect/landmark/bitrunning/cache_spawn))
			crate_turfs += get_turf(thing)
			qdel(thing)
			continue

	if(!length(exit_turfs))
		CRASH("Failed to find exit turfs on generated domain.")
	if(!length(goal_turfs))
		CRASH("Failed to find send turfs on generated domain.")

	if(length(crate_turfs))
		shuffle_inplace(crate_turfs)
		new /obj/structure/closet/crate/secure/bitrunning/encrypted(pick(crate_turfs))

	return TRUE

/// Loads the safehouse
/obj/machinery/quantum_server/proc/load_safehouse()
	var/obj/effect/landmark/bitrunning/safehouse_spawn/spawner = locate() in GLOB.landmarks_list
	if(isnull(spawner))
		CRASH("vdom: failed to find safehouse spawn landmark")

	generated_safehouse = new generated_domain.safehouse_path()
	if(!generated_safehouse.load(get_turf(spawner)))
		CRASH("vdom: failed to load safehouse")

	return TRUE

/// Loads in modular segments of the map
/obj/machinery/quantum_server/proc/load_map_segments()
	if(!length(generated_domain.room_modules))
		return TRUE

	var/current_index = 1
	shuffle_inplace(generated_domain.room_modules)

	for(var/obj/effect/landmark/bitrunning/map_segment/landmark in GLOB.landmarks_list)
		if(current_index > length(generated_domain.room_modules))
			CRASH("vdom: map segments are set to unique, but there are more landmarks than available segments")

		var/path
		if(generated_domain.modular_unique_rooms)
			path = generated_domain.room_modules[current_index]
			current_index += 1
		else
			path = pick(generated_domain.room_modules)

		var/datum/map_template/modular/segment = new path()
		if(!segment.load(get_turf(landmark)))
			CRASH("vdom: failed to load map segment [segment]")

		qdel(landmark)

	return TRUE

/// Loads in any mob segments of the map
/obj/machinery/quantum_server/proc/load_mob_segments()
	if(!length(generated_domain.room_modules))
		return TRUE

	var/current_index = 1
	shuffle_inplace(generated_domain.mob_modules)

	for(var/obj/effect/landmark/bitrunning/mob_segment/landmark in GLOB.landmarks_list)
		if(current_index > length(generated_domain.mob_modules))
			stack_trace("vdom: mobs segments are set to unique, but there are more landmarks than available segments")
			return FALSE

		var/path
		if(generated_domain.modular_unique_mobs)
			path = generated_domain.mob_modules[current_index]
			current_index += 1
		else
			path = pick(generated_domain.mob_modules)

		var/datum/modular_mob_segment/segment = new path()
		segment.spawn_mobs(get_turf(landmark))
		qdel(landmark)

	return TRUE

/// Stops the current virtual domain and disconnects all users
/obj/machinery/quantum_server/proc/reset(fast = FALSE)
	is_ready = FALSE

	SEND_SIGNAL(src, COMSIG_BITRUNNER_SEVER_AVATAR)

	if(!fast)
		notify_spawned_threats()
		addtimer(CALLBACK(src, PROC_REF(scrub_vdom)), 15 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
	else
		scrub_vdom() // used in unit testing, no need to wait for callbacks

	addtimer(CALLBACK(src, PROC_REF(cool_off)), min(server_cooldown_time * capacitor_coefficient), TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_DELETE_ME)
	update_appearance()

	update_use_power(IDLE_POWER_USE)
	domain_randomized = FALSE
	domain_threats = 0
	retries_spent = 0

/// Deletes all the tile contents
/obj/machinery/quantum_server/proc/scrub_vdom()
	SEND_SIGNAL(src, COMSIG_BITRUNNER_SEVER_AVATAR) /// just in case someone's connected
	SEND_SIGNAL(src, COMSIG_BITRUNNER_DOMAIN_SCRUBBED) // avatar cleanup just in case

	if(length(generated_domain.reservations))
		var/datum/turf_reservation/res = generated_domain.reservations[1]
		res.Release()

	var/list/datum/weakref/creatures = spawned_threat_refs + mutation_candidate_refs
	for(var/datum/weakref/creature_ref as anything in creatures)
		var/mob/living/creature = creature_ref?.resolve()
		if(isnull(creature))
			continue

		creature.dust() // sometimes mobs just don't die

	avatar_connection_refs.Cut()
	exit_turfs = list()
	generated_domain = null
	generated_safehouse = null
	mutation_candidate_refs.Cut()
	spawned_threat_refs.Cut()

/datum/wfc
	var/grid_size
	var/list/grid = list()
	var/list/patterns = list("A", "B", "C", "D")
	var/list/allowed_neighbors = list()

/datum/wfc/New(size = 5)
	src.grid_size = size

	allowed_neighbors["A"] = list("B", "D")
	allowed_neighbors["B"] = list("A", "C")
	allowed_neighbors["C"] = list("B", "D")
	allowed_neighbors["D"] = list("A", "C")

	for(var/y in 1 to grid_size)
		var/list/row = list()
		for(var/x in 1 to grid_size)
			row += list(patterns)
		grid += row  // Change made here

/datum/wfc/proc/observe()
	var/min_entropy = INFINITY
	var/target_cell_x
	var/target_cell_y

	for(var/y in 1 to grid_size)
		for(var/x in 1 to grid_size)
			var/list/cell = grid[y][x]
			if(length(cell) > 1 && length(cell) < min_entropy)
				min_entropy = length(cell)
				target_cell_x = x
				target_cell_y = y

	// If we found a cell with the least number of possibilities
	if(min_entropy != INFINITY)
		// Step 3: Randomly resolve the selected cell to one of its patterns
		var/chosen_pattern = pick(grid[target_cell_y][target_cell_x])
		grid[target_cell_y][target_cell_x] = list(chosen_pattern)

/datum/wfc/proc/propagate()
	var/changed = TRUE

	while(changed)
		changed = FALSE
		for(var/y in 1 to grid_size)
			for(var/x in 1 to grid_size)
				var/cell = grid[y][x]
				if(length(cell) != 1)
					continue

				var/pattern = cell[1]
				// Left neighbor
				if(x > 1)
					for(var/p in grid[y][x-1])
						if(!(p in allowed_neighbors[pattern]) && (p in grid[y][x-1]))
							grid[y][x-1] -= p
							changed = TRUE
				// Right neighbor
				if(x < grid_size)
					for(var/p in grid[y][x+1])
						if(!(p in allowed_neighbors[pattern]) && (p in grid[y][x+1]))
							grid[y][x+1] -= p
							changed = TRUE
				// Up neighbor
				if(y > 1)
					for(var/p in grid[y-1][x])
						if(!(p in allowed_neighbors[pattern]) && (p in grid[y-1][x]))
							grid[y-1][x] -= p
							changed = TRUE

				// Down neighbor
				if(y < grid_size)
					for(var/p in grid[y+1][x])
						if(!(p in allowed_neighbors[pattern]) && (p in grid[y+1][x]))
							grid[y+1][x] -= p
							changed = TRUE

/datum/wfc/proc/contradiction_exists()
	for(var/y in 1 to grid_size)
		for(var/x in 1 to grid_size)
			if(!length(grid[y][x])) // If a cell has no valid patterns left
				return TRUE
	return FALSE

/datum/wfc/proc/grids_are_equal(list/grid1, list/grid2)
	for(var/y in 1 to grid_size)
		for(var/x in 1 to grid_size)
			if(grid1[y][x] != grid2[y][x])
				return FALSE
	return TRUE

/datum/wfc/proc/create_new()
	var/previous_grid
	var/max_iterations = 1000
	var/current_iteration = 1

	while(TRUE)
		previous_grid = deep_copy_list(grid)
		observe()
		propagate()

		current_iteration++
		if(current_iteration >= max_iterations)
			break

		if(grids_are_equal(grid, previous_grid))
			break

		if(contradiction_exists())
			break
