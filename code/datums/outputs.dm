GLOBAL_LIST_EMPTY(outputs_list)

/datum/outputs
	var/text = "You hear broken code."
	var/list/sounds = list('sound/items/airhorn.ogg'=1) //weighted, put multiple for random selection between sounds
	var/state = "circle"
	var/image/icon

/datum/outputs/New()
	GLOB.outputs_list[src.type] = src
	icon = image('icons/sound_icon.dmi', , state, HUD_LAYER)

/datum/outputs/proc/send_info(mob/receiver, turf/turf_source, vol as num, vary, frequency, falloff, channel = 0, pressure_affected = TRUE, sound/S)
	var/sound = pickweight(sounds)
	if(receiver.client)
		//Handle sound
		if(sound && receiver.can_hear())
			if(!S)
				S = sound(get_sfx(sound))

			S.wait = 0 //No queue
			S.channel = channel || open_sound_channel()
			S.volume = vol

			if(vary)
				if(frequency)
					S.frequency = frequency
				else
					S.frequency = get_rand_frequency()

			if(isturf(turf_source))
				var/turf/T = get_turf(src)

				//sound volume falloff with distance
				var/distance = get_dist(T, turf_source)

				S.volume -= max(distance - world.view, 0) * 2 //multiplicative falloff to add on top of natural audio falloff.

				if(pressure_affected)
					//Atmosphere affects sound
					var/pressure_factor = 1
					var/datum/gas_mixture/hearer_env = T.return_air()
					var/datum/gas_mixture/source_env = turf_source.return_air()

					if(hearer_env && source_env)
						var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
						if(pressure < ONE_ATMOSPHERE)
							pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
					else //space
						pressure_factor = 0

					if(distance <= 1)
						pressure_factor = max(pressure_factor, 0.15) //touching the source of the sound

					S.volume *= pressure_factor
					//End Atmosphere affecting sound

				if(S.volume <= 0)
					return //No sound

				var/dx = turf_source.x - T.x // Hearing from the right/left
				S.x = dx
				var/dz = turf_source.y - T.y // Hearing from infront/behind
				S.z = dz
				// The y value is for above your head, but there is no ceiling in 2d spessmens.
				S.y = 1
				S.falloff = (falloff ? falloff : FALLOFF_SOUNDS)

			SEND_SOUND(receiver, S)
	//Handle icon
	if(isliving(receiver))
		var/mob/living/L = receiver
		if(icon && L.audiolocation)
			var/image/I = new icon
			if(sound && vol)
				I.alpha = I.alpha * (vol / 100)
			I.loc = turf_source
			receiver.client.images += I
			addtimer(CALLBACK(src, .proc/remove_image, I, receiver), 7, TIMER_UNIQUE)
	//Handle text
	if(text && receiver.can_hear())
		to_chat(receiver, text)

/datum/outputs/proc/remove_image(image, mob/living/receiver)
	receiver.client.images -= image

/datum/outputs/bikehorn
	text = "You hear a HONK."
	sounds = list('sound/items/airhorn.ogg'=1, 'sound/items/airhorn.ogg'=1)

