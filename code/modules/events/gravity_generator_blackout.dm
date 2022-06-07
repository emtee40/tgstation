/datum/round_event_control/gravity_generator_blackout
	name = "Gravity Generator Blackout"
	typepath = /datum/round_event/gravity_generator_blackout
	weight = 30

/datum/round_event_control/gravity_generator_blackout/canSpawnEvent()
	for(var/obj/machinery/gravity_generator/main/the_generator in GLOB.machines)
		if(!the_generator)
			return FALSE

	return ..()

/datum/round_event/gravity_generator_blackout
	announceWhen = 1
	startWhen = 1
	announceChance = 33

/datum/round_event/gravity_generator_blackout/announce(fake)
	priority_announce("Gravnospheric anomalies detected near [station_name()]. Manual reset of generators is required.", "Anomaly Alert", ANNOUNCER_GRANOMALIES)

/datum/round_event/gravity_generator_blackout/start()
	for(var/obj/machinery/gravity_generator/main/the_generator in GLOB.machines)
		if(is_station_level(the_generator.z))
			the_generator.blackout()
