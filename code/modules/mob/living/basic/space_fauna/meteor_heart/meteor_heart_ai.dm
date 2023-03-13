/// A spellcasting AI which does not move
/datum/ai_controller/basic_controller/meteor_heart
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/ground_spikes,
		/datum/ai_planning_subtree/use_mob_ability/spine_traps,
	)

/datum/ai_planning_subtree/targeted_mob_ability/ground_spikes
	ability_key = BB_METEOR_HEART_GROUND_SPIKES
	finish_planning = FALSE

/datum/ai_planning_subtree/use_mob_ability/spine_traps
	ability_key = BB_METEOR_HEART_SPINE_TRAPS
