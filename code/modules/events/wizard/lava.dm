/datum/round_event_control/wizard/lava //THE LEGEND NEVER DIES
	name = "The Floor Is LAVA!"
	weight = 2
	typepath = /datum/round_event/wizard/lava
	max_occurrences = 3
	earliest_start = ZERO MINUTES

/datum/round_event/wizard/lava
	endWhen = ZERO
	var/started = FALSE

/datum/round_event/wizard/lava/start()
	if(!started)
		started = TRUE
		SSweather.run_weather(/datum/weather/floor_is_lava)
