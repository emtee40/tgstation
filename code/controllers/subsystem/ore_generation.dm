#define MAX_BOULDERS_PER_VENT 10

SUBSYSTEM_DEF(ore_generation)
	name = "Ore_generation"
	wait = 0.1 MINUTES
	init_order = INIT_ORDER_DEFAULT
	runlevels = RUNLEVEL_GAME
	flags = SS_NO_INIT

	var/list/processed_vents = list()
	var/list/available_boulders = list()



/datum/controller/subsystem/ore_generation/fire(resumed)

	available_boulders = list() // reset upon new fire.
	for(var/vent in processed_vents)
		var/obj/structure/ore_vent/current_vent = vent

		var/local_vent_count = 0
		for(var/obj/item/old_rock as anything in current_vent.loc) /// This is expensive and bad, I know. Optimize?
			if(!isitem(old_rock))
				continue
			available_boulders += old_rock
			local_vent_count++

		if(local_vent_count >= MAX_BOULDERS_PER_VENT)
			return //We don't want to be accountable for literally hundreds of unprocessed boulders for no reason.
		var/obj/item/boulder/new_rock
		if(current_vent.artifact_chance)
			if(prob(current_vent.artifact_chance))
				new_rock = new /obj/item/boulder/artifact(current_vent.loc)
				available_boulders += new_rock
				return

		var/obj/item/boulder/new_rock = new (current_vent.loc)
		var/list/mats_list = current_vent.create_mineral_contents()
		current_vent.Shake(duration = 1.5 SECONDS)
		new_rock.set_custom_materials(mats_list)
		available_boulders += new_rock



