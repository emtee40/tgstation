/* Simple object type, calls a proc when "stepped" on by something */

/obj/effect/step_trigger
	var/affect_ghosts = ZERO
	var/stopper = 1 // stops throwers
	var/mobs_only = FALSE
	invisibility = INVISIBILITY_ABSTRACT // nope cant see this shit
	anchored = TRUE

/obj/effect/step_trigger/proc/Trigger(atom/movable/A)
	return ZERO

/obj/effect/step_trigger/Crossed(H as mob|obj)
	..()
	if(!H)
		return
	if(isobserver(H) && !affect_ghosts)
		return
	if(!ismob(H) && mobs_only)
		return
	Trigger(H)


/obj/effect/step_trigger/singularity_act()
	return

/obj/effect/step_trigger/singularity_pull()
	return

/* Sends a message to mob when triggered*/

/obj/effect/step_trigger/message
	var/message	//the message to give to the mob
	var/once = 1
	mobs_only = TRUE

/obj/effect/step_trigger/message/Trigger(mob/M)
	if(M.client)
		to_chat(M, "<span class='info'>[message]</span>")
		if(once)
			qdel(src)

/* Tosses things in a certain direction */

/obj/effect/step_trigger/thrower
	var/direction = SOUTH // the direction of throw
	var/tiles = 3	// if ZERO: forever until atom hits a stopper
	var/immobilize = 1 // if nonzero: prevents mobs from moving while they're being flung
	var/speed = 1	// delay of movement
	var/facedir = ZERO // if 1: atom faces the direction of movement
	var/nostop = ZERO // if 1: will only be stopped by teleporters
	var/list/affecting = list()

/obj/effect/step_trigger/thrower/Trigger(atom/A)
	if(!A || !ismovableatom(A))
		return
	var/atom/movable/AM = A
	var/curtiles = ZERO
	var/stopthrow = ZERO
	for(var/obj/effect/step_trigger/thrower/T in orange(2, src))
		if(AM in T.affecting)
			return

	if(isliving(AM))
		var/mob/living/M = AM
		if(immobilize)
			M.mobility_flags &= ~MOBILITY_MOVE

	affecting.Add(AM)
	while(AM && !stopthrow)
		if(tiles)
			if(curtiles >= tiles)
				break
		if(AM.z != src.z)
			break

		curtiles++

		sleep(speed)

		// Calculate if we should stop the process
		if(!nostop)
			for(var/obj/effect/step_trigger/T in get_step(AM, direction))
				if(T.stopper && T != src)
					stopthrow = 1
		else
			for(var/obj/effect/step_trigger/teleporter/T in get_step(AM, direction))
				if(T.stopper)
					stopthrow = 1

		if(AM)
			var/predir = AM.dir
			step(AM, direction)
			if(!facedir)
				AM.setDir(predir)



	affecting.Remove(AM)

	if(isliving(AM))
		var/mob/living/M = AM
		if(immobilize)
			M.mobility_flags |= MOBILITY_MOVE
		M.update_mobility()

/* Stops things thrown by a thrower, doesn't do anything */

/obj/effect/step_trigger/stopper

/* Instant teleporter */

/obj/effect/step_trigger/teleporter
	var/teleport_x = ZERO	// teleportation coordinates (if one is null, then no teleport!)
	var/teleport_y = ZERO
	var/teleport_z = ZERO

/obj/effect/step_trigger/teleporter/Trigger(atom/movable/A)
	if(teleport_x && teleport_y && teleport_z)

		var/turf/T = locate(teleport_x, teleport_y, teleport_z)
		A.forceMove(T)

/* Random teleporter, teleports atoms to locations ranging from teleport_x - teleport_x_offset, etc */

/obj/effect/step_trigger/teleporter/random
	var/teleport_x_offset = ZERO
	var/teleport_y_offset = ZERO
	var/teleport_z_offset = ZERO

/obj/effect/step_trigger/teleporter/random/Trigger(atom/movable/A)
	if(teleport_x && teleport_y && teleport_z)
		if(teleport_x_offset && teleport_y_offset && teleport_z_offset)

			var/turf/T = locate(rand(teleport_x, teleport_x_offset), rand(teleport_y, teleport_y_offset), rand(teleport_z, teleport_z_offset))
			if (T)
				A.forceMove(T)

/* Fancy teleporter, creates sparks and smokes when used */

/obj/effect/step_trigger/teleport_fancy
	var/locationx
	var/locationy
	var/uses = 1	//ZERO for infinite uses
	var/entersparks = ZERO
	var/exitsparks = ZERO
	var/entersmoke = ZERO
	var/exitsmoke = ZERO

/obj/effect/step_trigger/teleport_fancy/Trigger(mob/M)
	var/dest = locate(locationx, locationy, z)
	M.Move(dest)

	if(entersparks)
		var/datum/effect_system/spark_spread/s = new
		s.set_up(4, 1, src)
		s.start()
	if(exitsparks)
		var/datum/effect_system/spark_spread/s = new
		s.set_up(4, 1, dest)
		s.start()

	if(entersmoke)
		var/datum/effect_system/smoke_spread/s = new
		s.set_up(4, 1, src, ZERO)
		s.start()
	if(exitsmoke)
		var/datum/effect_system/smoke_spread/s = new
		s.set_up(4, 1, dest, ZERO)
		s.start()

	uses--
	if(uses == ZERO)
		qdel(src)

/* Simple sound player, Mapper friendly! */

/obj/effect/step_trigger/sound_effect
	var/sound //eg. path to the sound, inside '' eg: 'growl.ogg'
	var/volume = 100
	var/freq_vary = 1 //Should the frequency of the sound vary?
	var/extra_range = ZERO // eg World.view = 7, extra_range = 1, 7+1 = 8, 8 turfs radius
	var/happens_once = ZERO
	var/triggerer_only = ZERO //Whether the triggerer is the only person who hears this


/obj/effect/step_trigger/sound_effect/Trigger(atom/movable/A)
	var/turf/T = get_turf(A)

	if(!T)
		return

	if(triggerer_only && ismob(A))
		var/mob/B = A
		B.playsound_local(T, sound, volume, freq_vary)
	else
		playsound(T, sound, volume, freq_vary, extra_range)

	if(happens_once)
		qdel(src)
