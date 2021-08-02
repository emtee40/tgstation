///Get all the mobs and potential dangerous machines we can see.
/datum/ai_behavior/find_potential_targets
	var/hostile_machines = typecacheof(list(/obj/machinery/porta_turret, /obj/vehicle/sealed/mecha))

/datum/ai_behavior/find_potential_targets/perform(delta_time, datum/ai_controller/controller, potential_targets_key)
	var/list/potential_targets
	var/mob/living/basic/basic_mob = controller.pawn

	potential_targets = basic_mob.hearers(vision_range, controller.pawn) - basic_mob //Remove self, so we don't suicide

	for(var/HM in typecache_filter_list(range(vision_range, basic_mob), hostile_machines)) //Can we see any hostile machines?
		if(can_see(basic_mob, HM, vision_range))
			potential_targets += HM

	if(!potential_targets.len)
		finish_target(controller, FALSE)
		return

	controller.blackboard[potential_targets_key] = potential_targets
	finish_target(controller, TRUE)


///Select the target from the list of things in our vision
/datum/ai_behavior/select_target


/datum/ai_behavior/select_target/perform(delta_time, datum/ai_controller/controller, target_key, possible_targets_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/mob/living/basic/basic_mob = controller.pawn

	var/list/filtered_targets = list()

	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]

	if(!targetting_datum)
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	for(var/pos_targ in controller.blackboard[possible_targets_key])
		var/atom/A = pos_targ

		if(targetting_datum.can_attack(basic_mob, A))//Can we attack it?
			filtered_targets += A
			continue

	if(!filter_targets.len)
		finish_target(controller, FALSE)
		return

	var/atom/target = pick(filtered_targets)
	controller.blackboard[target_key] = target

	var/atom/potential_hiding_location = targetting_datum.find_hidden_mobs(basic_mob, A)

	if(potential_hiding_location) //If they're hiding inside of something, we need to know so we can go for that instead initially.
		controller.blackboard[hiding_location_key] = potential_hiding_location

	finish_target(controller, TRUE)
