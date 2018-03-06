GLOBAL_LIST_INIT(dangerous_turfs, typecacheof(list(
	/turf/open/lava,
	/turf/open/chasm)))


#define STATE_IDLE		0
#define STATE_MOVINGTO	1
#define STATE_ACTING	2

#define MOVETYPE_ASTAR 1
#define MOVETYPE_FAKESTAR 2
#define MOVETYPE_DUMB 3

//#define GOAP_DEBUG_ENABLE "fart"

#ifdef GOAP_DEBUG_ENABLE
#define goap_debug(string) world.log << "GOAP: [string]"
#else
#define goap_debug(string) ;
#endif
/datum/goap_agent
	var/brain_state = STATE_IDLE
	var/list/our_actions //The actions available to us (/datum/goap_action)
	var/list/action_queue //The actions of our current plan (if any) (/datum/goap_action)

	//How we plan (Imagine a specific planner that ALWAYS prefers actions involving murder, regardless of cost, bloodlust agent!)
	var/datum/goap_planner/planner = /datum/goap_planner

	//Provides Info to the agent
	var/datum/goap_info_provider/info = /datum/goap_info_provider

	var/atom/agent //The actual atom that uses this brain (who knows, maybe you want to give a donut intelligence?)

	var/list/path
	var/turf/dest
	var/turf/last_node
	var/tries = 0
	var/obj/item/card/id/given_pathfind_access
	var/movement_type = MOVETYPE_ASTAR
	var/turf/current_loc
	var/is_megafauna = FALSE
	var/actions_halted = FALSE
	var/already_acting = FALSE
	var/works_when_alone = FALSE

	var/fuck_you_astar = FALSE

/datum/goap_agent/proc/has_action(var/ACT)
	for(var/datum/goap_action/A in our_actions)
		if(istype(A, ACT) && !A.OnCooldown())
			return TRUE
	return FALSE

/datum/goap_agent/New()
	our_actions = list()
	action_queue = list()

	if(ispath(info))
		info = new info()
	else
		CRASH("OH GOD HELP ME I DONT UNDERSTAND THE WORLD")
		return

	if(ispath(planner))
		planner = new planner()
	else
		CRASH("OH GOD HELP ME I DONT KNOW HOW TO THINK STRAIGHT")
		return

	START_PROCESSING(SSgoap, src)

/datum/goap_agent/Destroy()
	STOP_PROCESSING(SSgoap, src)
	return ..()

/datum/goap_agent/proc/able_to_run()
	if(!agent)
		qdel(src)
		return FALSE
	if(works_when_alone)
		return TRUE
	for(var/I in GLOB.alive_mob_list & SSmobs.clients_by_zlevel[agent.z])
		var/mob/M = I
		if(get_dist(M, agent) <= 14)
			return TRUE
	return FALSE

/datum/goap_agent/proc/goap_process()
	if(!agent)
		return FALSE
	if(actions_halted)
		return FALSE
	goap_debug("GOAP Processing: [agent] State: [brain_state]")
	switch(brain_state)
		if(STATE_IDLE)
			idle_state()
		if(STATE_MOVINGTO)
			moving_state()
		if(STATE_ACTING)
			act_state()

/datum/goap_agent/proc/act_state()
	if(!LAZYLEN(action_queue))
		brain_state = STATE_IDLE
		return
	var/datum/goap_action/curr_action = action_queue[action_queue.len]
	curr_action = action_queue[action_queue.len]
	var/range_check = curr_action.IsInRange(agent)
	if(curr_action.CheckDone(agent))
		action_queue.len--
		if(!LAZYLEN(action_queue))
			return
	if(already_acting)
		return

	if(!range_check)
		brain_state = STATE_MOVINGTO
		return
	already_acting = TRUE
	if(!curr_action.Perform(agent))
		goap_debug("PERFORM FAILED [curr_action]")
		brain_state = STATE_IDLE
		LAZYCLEARLIST(path)
		info.PlanAborted(curr_action)
		already_acting = FALSE
	else
		goap_debug("PERFORMED [curr_action]")
		if(action_queue.len == 1 && action_queue[1] == curr_action)
			brain_state = STATE_IDLE
			LAZYCLEARLIST(path)
			already_acting = FALSE
			return
		LAZYCLEARLIST(path)
		already_acting = FALSE

/datum/goap_agent/proc/moving_state()
	if(fuck_you_astar)
		return
	var/datum/goap_action/curr_action = action_queue[action_queue.len]

	if(curr_action.RequiresInRange(agent) && !curr_action.target)
		goap_debug("An action ([curr_action]) requires a target, but did not get one set")
		brain_state = STATE_IDLE
		return
	var/dense_garbage
	for(var/obj/I in get_turf(curr_action.target))
		if(I.density)
			dense_garbage = TRUE
			break
	var/proc_to_use = /turf/proc/reachableTurftest
	switch(movement_type)
		if(MOVETYPE_ASTAR) // AStar, Full
			if(!path || !path.len)
				fuck_you_astar = TRUE
				if(!curr_action.path_to_use)
					if(!isturf(curr_action.target))
						path = get_path_to(agent, get_turf(curr_action.target), /turf/proc/Distance_cardinal, 0, 200, adjacent = proc_to_use, id=given_pathfind_access, mintargetdist = dense_garbage)
					else
						path = get_path_to(agent, curr_action.target, /turf/proc/Distance_cardinal, 0, 200, adjacent = proc_to_use, id=given_pathfind_access, mintargetdist = dense_garbage)
					if(!path || !path.len) // still can't path
						goap_debug("Can't path to plan, giving up")
						brain_state = STATE_IDLE
						fuck_you_astar = FALSE
						return
				else
					path = curr_action.path_to_use
			fuck_you_astar = FALSE
			last_node = get_turf(path[path.len]) //This is the turf at the end of the path, it should be equal to dest.
			current_loc = get_turf(agent)
			curr_action.PerformWhileMoving(agent)
			MoveTo_AStar(curr_action, path)
		if(MOVETYPE_FAKESTAR) // AStar, Fake
			curr_action.PerformWhileMoving(agent)
			MoveTo_FakeStar(curr_action)
		if(MOVETYPE_DUMB) // No Pathfinding, Straight Line
			curr_action.PerformWhileMoving(agent)
			MoveTo(curr_action)

/datum/goap_agent/proc/idle_state()
	var/list/worldstate = info.GetWorldState(src)
	var/list/goal = info.GetGoal(src)

	var/list/plan = planner.Plan(agent, our_actions, worldstate, goal)

	if(!LAZYLEN(plan))
		info.PlanFailed(goal)
		return
	goap_debug("I am gonna act")
	goap_debug(plan.len)

	for(var/i in plan)
		goap_debug(i)

	action_queue = plan
	info.PlanFound(goal, plan)
	brain_state = STATE_ACTING

/datum/goap_agent/proc/MoveTo_AStar(datum/goap_action/curr_action, list/path)
	var/turf/dest = get_turf(curr_action.target)
	if(!path)
		return FALSE
	if(!last_node.Adjacent(dest))
		path = null // force a new path
		return FALSE
	if(path.len > 1)
		step_towards(agent, path[1])
		if(get_turf(agent) == path[1]) //Successful move
			path -= path[1]
	if(path.len == 1)
		step_to(src, dest)
		path = list()
		curr_action.inn_range = TRUE
		brain_state = STATE_ACTING
	return TRUE

/datum/goap_agent/proc/MoveTo_FakeStar(datum/goap_action/action)
	if(action.target)
		if(get_dist(agent, action.target) > 1)
			if(!is_type_in_typecache(get_step(agent, get_dir(agent, action.target)), GLOB.dangerous_turfs))
				step_to(agent, action.target)
		if(get_dist(agent, action.target) <= 1)
			action.inn_range = TRUE
			brain_state = STATE_ACTING

/datum/goap_agent/proc/MoveTo(datum/goap_action/action)
	if(action.target)
		if(get_dist(agent, action.target) > 1)
			if(!is_type_in_typecache(get_step(agent, get_dir(agent, action.target)), GLOB.dangerous_turfs))
				step_towards(agent, action.target)
		if(get_dist(agent, action.target) <= 1)
			action.inn_range = TRUE
			brain_state = STATE_ACTING