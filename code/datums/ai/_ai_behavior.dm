///Abstract class for an action an AI can take, can range from movement to grabbing a nearby weapon.
/datum/ai_behavior
	///What distance you need to be from the target to perform the action
	var/required_distance = 1
	///Flags for extra behavior
	var/behavior_flags = NONE
	///Cooldown between actions performances, defaults to the value of CLICK_CD_MELEE because that seemed like a nice standard for the speed of AI behavior
	var/action_cooldown = CLICK_CD_MELEE

/// Called by the ai controller when first being added. Additional arguments depend on the behavior type.
/// Return FALSE to cancel
/datum/ai_behavior/proc/setup(datum/ai_controller/controller, ...)
	return TRUE

/datum/ai_behavior/proc/need_movement(datum/ai_controller/controller)
	if(behavior_flags & AI_BEHAVIOR_REQUIRE_LOS)
		if(COOLDOWN_FINISHED(controller, los_cooldown))
			controller.last_LOS_check_result = can_see(controller.pawn, controller.current_movement_target)
			COOLDOWN_START(controller, los_cooldown, 1 SECONDS)
		if(!controller.last_LOS_check_result)
			return TRUE

	if(required_distance >= get_dist(controller.pawn, controller.current_movement_target))
		return FALSE
	return TRUE

///Called by the AI controller when this action is performed
/datum/ai_behavior/proc/perform(delta_time, datum/ai_controller/controller, ...)
	controller.behavior_cooldowns[src] = world.time + action_cooldown
	return

///Called when the action is finished. This needs the same args as perform besides the default ones
/datum/ai_behavior/proc/finish_action(datum/ai_controller/controller, succeeded, ...)
	LAZYREMOVE(controller.current_behaviors, src)
	controller.behavior_args -= type
	if(behavior_flags & AI_BEHAVIOR_REQUIRE_MOVEMENT) //If this was a movement task, reset our movement target.
		controller.current_movement_target = null
		controller.ai_movement.stop_moving_towards(controller)
	if(!controller.can_currently_plan)
		var/can_start_planning = TRUE
		for(var/datum/ai_behavior/ai_behavior as anything in controller.current_behaviors)
			if(ai_behavior.behavior_flags & AI_BEHAVIOR_ALLOWS_REPLANNING)
				continue
			can_start_planning = FALSE
		controller.can_currently_plan = can_start_planning

