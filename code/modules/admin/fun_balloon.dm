/obj/item/fun_balloon
	name = "fun balloon"
	desc = "This is going to be a laugh riot."
	icon = 'icons/obj/balloons.dmi'
	icon_state = "syndballoon"
	anchored = TRUE
	var/popped = FALSE
	var/pop_sound_effect = 'sound/items/party_horn.ogg'

/obj/item/fun_balloon/Initialize()
	. = ..()
	SSobj.processing |= src

/obj/item/fun_balloon/Destroy()
	SSobj.processing -= src
	. = ..()

/obj/item/fun_balloon/process()
	if(!popped && check() && !QDELETED(src))
		popped = TRUE
		effect()
		pop()

/obj/item/fun_balloon/proc/check()
	return FALSE

/obj/item/fun_balloon/proc/effect()
	return

/obj/item/fun_balloon/proc/pop()
	visible_message("<span class='notice'>[src] pops!</span>")
	playsound(get_turf(src), pop_sound_effect, 50, TRUE, -1)
	qdel(src)

//ATTACK GHOST IGNORING PARENT RETURN VALUE
// /obj/item/fun_balloon/attack_ghost(mob/user)
// 	if(!user.client || !user.client.holder || popped)
// 		return
// 	var/confirmation = alert("Pop [src]?","Fun Balloon","Yes","No")
// 	if(confirmation == "Yes" && !popped)
// 		popped = TRUE
// 		effect()
// 		pop()

/////////////////////////////Sentience Balloon/////////////////////////////
/obj/item/fun_balloon/sentience
	name = "sentience fun balloon"
	desc = "When this pops, things are gonna get more aware around here."
	var/effect_range = 3
	var/group_name = "a bunch of giant spiders"
	var/mob_type = new /mob/living

/obj/item/fun_balloon/sentience/ui_interact(mob/user, datum/tgui/ui)
	if(!check_rights(R_ADMIN))
		return // todo: show examine description if not an admin
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SentienceFunBalloon", name)
		ui.open()

/obj/item/fun_balloon/sentience/ui_data(mob/user)
	var/list/data = list()
	data["group_name"] = group_name
	data["pop_sound"] = pop_sound_effect
	data["range"] = effect_range
	data["mob_type"] = mob_type
	return data

/obj/item/fun_balloon/sentience/ui_state(mob/user)
	return GLOB.admin_state

/obj/item/fun_balloon/sentience/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("group_name")
			group_name = params["updated_name"]

		if("effect_range")
			effect_range = params["updated_range"] // todo: ensure it's a number

		if("mob_type")
			effect_range = params["updated_mob_type"] // todo: make this a search

		if("pop_sound")
			var/soundInput = input(src, "Please pick a sound file to play when the balloon pops!", "Pick a Sound File") as null|sound
			if (isnull(soundInput))
				return
			pop_sound_effect = sound(soundInput)

		if("pop")
			popped = TRUE
			effect()
			pop()

	return TRUE

/obj/item/fun_balloon/sentience/effect()
	var/list/bodies = list()
	for(var/mob/living/possessable in range(effect_range, get_turf(src)))
		if (!possessable.ckey && possessable.stat == CONSCIOUS) // Only assign ghosts to living, non-occupied mobs!
			bodies += possessable

	var/question = "Would you like to be [group_name]?"
	var/list/candidates = pollCandidatesForMobs(question, ROLE_PAI, null, FALSE, 100, bodies)
	while(LAZYLEN(candidates) && LAZYLEN(bodies))
		var/mob/dead/observer/C = pick_n_take(candidates)
		var/mob/living/body = pick_n_take(bodies)

		message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(body)])")
		body.ghostize(FALSE)
		body.key = C.key
		new /obj/effect/temp_visual/gravpush(get_turf(body))

/////////////////////////////Emergency Shuttle Balloon/////////////////////////////
/obj/item/fun_balloon/sentience/emergency_shuttle
	name = "shuttle sentience fun balloon"
	var/trigger_time = 60

/obj/item/fun_balloon/sentience/emergency_shuttle/check()
	. = FALSE
	if(SSshuttle.emergency && (SSshuttle.emergency.timeLeft() <= trigger_time) && (SSshuttle.emergency.mode == SHUTTLE_CALL))
		. = TRUE

/////////////////////////////Scatter Balloon/////////////////////////////
/obj/item/fun_balloon/scatter
	name = "scatter fun balloon"
	desc = "When this pops, you're not going to be around here anymore."
	var/effect_range = 5

/obj/item/fun_balloon/scatter/effect()
	for(var/mob/living/M in range(effect_range, get_turf(src)))
		var/turf/T = find_safe_turf()
		new /obj/effect/temp_visual/gravpush(get_turf(M))
		M.forceMove(T)
		to_chat(M, "<span class='notice'>Pop!</span>", confidential = TRUE)

/////////////////////////////Station Crash/////////////////////////////
// Can't think of anywhere better to put it right now
/obj/effect/station_crash
	name = "station crash"
	desc = "With no survivors!"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "syndballoon"
	anchored = TRUE
	var/min_crash_strength = 3
	var/max_crash_strength = 15

/obj/effect/station_crash/Initialize()
	..()
	shuttle_crash()
	return INITIALIZE_HINT_QDEL

/obj/effect/station_crash/proc/shuttle_crash()
	var/crash_strength = rand(min_crash_strength,max_crash_strength)
	for (var/S in SSshuttle.stationary)
		var/obj/docking_port/stationary/SM = S
		if (SM.id == "emergency_home")
			var/new_dir = turn(SM.dir, 180)
			SM.forceMove(get_ranged_target_turf(SM, new_dir, crash_strength))
			break

/obj/effect/station_crash/devastating
	name = "devastating station crash"
	desc = "Absolute Destruction. Will crash the shuttle far into the station."
	min_crash_strength = 15
	max_crash_strength = 25
