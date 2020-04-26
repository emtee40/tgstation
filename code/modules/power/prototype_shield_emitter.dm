/obj/machinery/power/proto_sh_emitter
	name = "Prototype Shield Emitter"
	desc = "This is a Prototype Shield Emitter that create in front of it a box made of shielding elements to protect the station from heat and pressure"
	icon = 'icons/obj/power.dmi'
	icon_state = "proto_sh_emitter"
	anchored = FALSE
	density = TRUE
	max_integrity = 350
	integrity_failure = 0.2
	circuit = /obj/item/circuitboard/machine/proto_sh_emitter
	var/list/signs = list()
	var/is_on = FALSE
	var/locked = FALSE

/obj/machinery/power/proto_sh_emitter/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS, null, CALLBACK(src, .proc/can_be_rotated))

/obj/machinery/power/proto_sh_emitter/anchored
	anchored = TRUE

/obj/machinery/power/proto_sh_emitter/Destroy()
	if(SSticker.IsRoundInProgress())
		var/turf/T = get_turf(src)
		message_admins("Prototype Shield Emitter deleted at [ADMIN_VERBOSEJMP(T)]")
		log_game("Prototype Shield Emitter deleted at [AREACOORD(T)]")
	for(var/H in signs)
		qdel(H)
	return ..()

/obj/machinery/power/proto_sh_emitter/update_icon_state()
	if(is_on == TRUE)
		icon_state = "proto_sh_emitter_on"
	else
		icon_state = "proto_sh_emitter"

/obj/machinery/power/proto_sh_emitter/proc/can_be_rotated(mob/user,rotation_type)
	if(anchored)
		to_chat(user, "<span class='warning'>It is fastened to the floor!</span>")
		return FALSE
	return TRUE

/obj/machinery/power/proto_sh_emitter/wrench_act(mob/living/user, obj/item/I)
	if(is_on == TRUE)
		to_chat(user, "<span class='warning'>You have to turn the [src] off first!</span>")
		return TRUE
	if(!anchored)
		anchored = TRUE
		to_chat(user, "<span class='warning'>You bolt the [src] to the floor!</span>")
	else
		anchored = FALSE
		to_chat(user, "<span class='warning'>You unbolt the [src] from the floor!</span>")
	return TRUE

/obj/machinery/power/proto_sh_emitter/process()
	var/area/a = get_area(src)
	var/turf/Turf = get_turf(src)
	if(a.power_equip == FALSE)
		is_on = FALSE
		update_icon_state()
		message_admins("Prototype Shield Emitter turned off at [ADMIN_VERBOSEJMP(Turf)]")
		log_game("Prototype Shield Emitter turned off at [AREACOORD(Turf)]")

/obj/machinery/power/proto_sh_emitter/interact(mob/user)
	var/turf/T = /turf
	var/turf/Turf = get_turf(src)
	var/list/outline = list()
	var/list/internal = list()
	var/area/a = get_area(src)
	add_fingerprint(user)
	if(!anchored)
		to_chat(user, "<span class='warning'>You need to anchor the [src] first!</span>")
		return
	if(a.power_equip == FALSE)
		to_chat(user, "<span class='warning'>There is no power in this area!!</span>")
		return
	if(locked)
		to_chat(user, "<span class='warning'>The controls are locked!</span>")
		return
	if(is_on == TRUE)
		to_chat(user, "<span class='warning'>You turn off the [src] and the generated shields!</span>")
		message_admins("Prototype Shield Emitter turned off at [ADMIN_VERBOSEJMP(Turf)]")
		log_game("Prototype Shield Emitter turned off at [AREACOORD(Turf)]")
		is_on = FALSE
		for(var/H in signs)
			qdel(H)
		update_icon_state()
	else
		to_chat(user, "<span class='warning'>You turn on the [src] and the generated shields!</span>")
		message_admins("Prototype Shield Emitter turned on at [ADMIN_VERBOSEJMP(Turf)]")
		log_game("Prototype Shield Emitter turned on at [AREACOORD(Turf)]")
		is_on = TRUE
		update_icon_state()
		switch(dir)
			if(NORTH)
				for(T in block(locate(src.x - 2, src.y + 1, src.z), locate(src.x + 2, src.y + 5, src.z)))
					outline += T
				for(T in block(locate(src.x - 1, src.y + 2, src.z), locate(src.x + 1, src.y + 4, src.z)))
					outline -= T
				for(T in outline)
					new /obj/machinery/holosign/barrier/power_shield/wall(T, src)
				for(T in block(locate(src.x - 1, src.y + 2, src.z), locate(src.x + 1, src.y + 4, src.z)))
					internal += T
				for(T in internal)
					new /obj/machinery/holosign/barrier/power_shield/floor(T, src)
			if(SOUTH)
				for(T in block(locate(src.x - 2, src.y - 1, src.z), locate(src.x + 2, src.y - 5, src.z)))
					outline += T
				for(T in block(locate(src.x - 1, src.y - 2, src.z), locate(src.x + 1, src.y - 4, src.z)))
					outline -= T
				for(T in outline)
					new /obj/machinery/holosign/barrier/power_shield/wall(T, src)
				for(T in block(locate(src.x - 1, src.y - 2, src.z), locate(src.x + 1, src.y - 4, src.z)))
					internal += T
				for(T in internal)
					new /obj/machinery/holosign/barrier/power_shield/floor(T, src)
			if(EAST)
				for(T in block(locate(src.x +1, src.y -2, src.z), locate(src.x +5, src.y +2, src.z)))
					outline += T
				for(T in block(locate(src.x +2, src.y -1, src.z), locate(src.x +4, src.y +1, src.z)))
					outline -= T
				for(T in outline)
					new /obj/machinery/holosign/barrier/power_shield/wall(T, src)
				for(T in block(locate(src.x +2, src.y -1, src.z), locate(src.x +4, src.y +1, src.z)))
					internal += T
				for(T in internal)
					new /obj/machinery/holosign/barrier/power_shield/floor(T, src)
			if(WEST)
				for(T in block(locate(src.x -1, src.y -2, src.z), locate(src.x -5, src.y +2, src.z)))
					outline += T
				for(T in block(locate(src.x -2, src.y -1, src.z), locate(src.x -4, src.y +1, src.z)))
					outline -= T
				for(T in outline)
					new /obj/machinery/holosign/barrier/power_shield/wall(T, src)
				for(T in block(locate(src.x -2, src.y -1, src.z), locate(src.x -4, src.y +1, src.z)))
					internal += T
				for(T in internal)
					new /obj/machinery/holosign/barrier/power_shield/floor(T, src)

/obj/machinery/power/proto_sh_emitter/attackby(obj/item/I, mob/user, params)
	if(I.GetID())
		if(allowed(user))
			if(is_on)
				locked = !locked
				to_chat(user, "<span class='notice'>You [src.locked ? "lock" : "unlock"] the controls.</span>")
			else
				to_chat(user, "<span class='warning'>The controls can only be locked when \the [src] is online!</span>")
		else
			to_chat(user, "<span class='danger'>Access denied.</span>")
		return
