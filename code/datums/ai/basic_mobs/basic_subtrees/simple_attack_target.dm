/datum/ai_planning_subtree/simple_attack_target

/datum/ai_planning_subtree/simple_attack_target/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		return
	AddBehavior(/datum/ai_behavior/basic_melee_attack, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
