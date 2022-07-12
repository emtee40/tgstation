/datum/round_event_control/space_dust
	name = "Minor Space Dust"
	typepath = /datum/round_event/space_dust
	weight = 200
	max_occurrences = 1000
	earliest_start = 0 MINUTES
	alert_observers = FALSE
	category = EVENT_CAT_SPACE
	description = "A single space dust is hurled at the station."

/datum/round_event/space_dust
	startWhen = 1
	endWhen = 2
	fakeable = FALSE

/datum/round_event/space_dust/start()
	spawn_meteors(1, GLOB.meteorsC)

/datum/round_event_control/sandstorm
	name = "Sandstorm"
	typepath = /datum/round_event/sandstorm
	weight = 0
	max_occurrences = 0
	earliest_start = 0 MINUTES
	category = EVENT_CAT_SPACE
	description = "The station is pelted by an extreme amount of sand for several minutes."

/datum/round_event/sandstorm
	startWhen = 1
	endWhen = 150 // ~5 min
	announceWhen = 0
	fakeable = FALSE

/datum/round_event/sandstorm/tick()
	spawn_meteors(10, GLOB.meteorsC)
