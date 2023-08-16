/datum/ai_controller/basic_controller/regal_rat
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	// we pretty much do cheesy things (make the station worse) and don't deal with peasants (crew) unless they start to get in the way
	// summon the horde if we get into a fight and then let the horde take care of it while we skedaddle
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/riot,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/targeted_mob_ability/domain,
	)

/datum/ai_planning_subtree/targeted_mob_ability/riot
	ability_key = BB_RAISE_HORDE_ABILITY

/datum/ai_planning_subtree/targeted_mob_ability/domain
	ability_key = BB_DOMAIN_ABILITY
