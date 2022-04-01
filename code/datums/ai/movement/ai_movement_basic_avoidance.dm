///Uses Byond's basic obstacle avoidance mvovement
/datum/ai_movement/basic_avoidance
	max_pathing_attempts = 10

/datum/ai_movement/basic_avoidance/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	var/min_dist = controller.blackboard[BB_CURRENT_MIN_MOVE_DISTANCE]
	var/delay = controller.movement_delay
	var/datum/move_loop/loop = SSmove_manager.move_to(moving, current_movement_target, min_dist, delay, subsystem = SSai_movement, extra_info = controller)
	register_signal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, .proc/pre_move)
	register_signal(loop, COMSIG_MOVELOOP_POSTPROCESS, .proc/post_move)

/datum/ai_movement/basic_avoidance/allowed_to_move(datum/move_loop/has_target/dist_bound/source)
	. = ..()
	var/turf/target_turf = get_step_towards(source.moving, source.target)

	if(is_type_in_typecache(target_turf, GLOB.dangerous_turfs))
		. = FALSE
	return .
