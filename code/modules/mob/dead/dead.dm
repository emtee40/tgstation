//Dead mobs can exist whenever. This is needful

INITIALIZE_IMMEDIATE(/mob/dead)

/mob/dead
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	move_resist = INFINITY
	throwforce = 0

/mob/dead/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1
	// Initial is non standard here, but ghosts move before they get here so it's needed. this is a cold path too so it's ok
	SET_PLANE_IMPLICIT(src, initial(plane))
	add_to_mob_list()

	prepare_huds()

	if(length(CONFIG_GET(keyed_list/cross_server)))
		add_verb(src, /mob/dead/proc/server_hop)
	set_focus(src)
	become_hearing_sensitive()
	log_mob_tag("TAG: [tag] CREATED: [key_name(src)] \[[src.type]\]")
	return INITIALIZE_HINT_NORMAL

/mob/dead/canUseStorage()
	return FALSE

/mob/dead/get_status_tab_items()
	. = ..()
	if(SSticker.HasRoundStarted())
		return
	var/time_remaining = SSticker.GetTimeLeft()
	if(time_remaining > 0)
		. += "Time To Start: [round(time_remaining/10)]s"
	else if(time_remaining == -10)
		. += "Time To Start: DELAYED"
	else
		. += "Time To Start: SOON"

	. += "Players: [LAZYLEN(GLOB.clients)]"
	if(client.holder)
		. += "Players Ready: [SSticker.totalPlayersReady]"
		. += "Admins Ready: [SSticker.total_admins_ready] / [length(GLOB.admins)]"

#define SERVER_HOPPER_TRAIT "server_hopper"

/mob/dead/proc/server_hop()
	set category = "OOC"
	set name = "Server Hop"
	set desc= "Jump to the other server"
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM)) // in case the round is ending and a cinematic is already playing we don't wanna clash with that (yes i know)
		return
	var/list/our_id = CONFIG_GET(string/cross_comms_name)
	var/list/csa = CONFIG_GET(keyed_list/cross_server) - our_id
	var/pick
	switch(length(csa))
		if(0)
			remove_verb(src, /mob/dead/proc/server_hop)
			to_chat(src, span_notice("Server Hop has been disabled."))
		if(1)
			pick = csa[1]
		else
			pick = tgui_input_list(src, "Server to jump to", "Server Hop", csa)

	if(isnull(pick))
		return

	var/addr = csa[pick]

	if(tgui_alert(usr, "Jump to server [pick] ([addr])?", "Server Hop", list("Yes", "No")) != "Yes")
		return

	var/client/C = client
	to_chat(C, span_notice("Sending you to [pick]."))
	new /atom/movable/screen/splash(null, null, C)

	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, SERVER_HOPPER_TRAIT)
	sleep(2.9 SECONDS) //let the animation play
	REMOVE_TRAIT(src, TRAIT_NO_TRANSFORM, SERVER_HOPPER_TRAIT)

	if(!C)
		return

	winset(src, null, "command=.options") //other wise the user never knows if byond is downloading resources

	C << link("[addr]")

#undef SERVER_HOPPER_TRAIT

/mob/dead/proc/update_z(new_z) // 1+ to register, null to unregister
	if(!client || !new_z)
		registered_z = null
		return
	if(registered_z == new_z)
		return
	if(registered_z)
		SSmobs.dead_players_by_zlevel[registered_z] -= src
	registered_z = new_z
	//this check prevents issues such as ghosting, which puts you in several times.
	if(!(src in SSmobs.dead_players_by_zlevel[registered_z]))
		SSmobs.dead_players_by_zlevel[new_z] += src

/mob/dead/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	var/turf/T = get_turf(src)
	if (isturf(T))
		update_z(T.z)

/mob/dead/auto_deadmin_on_login()
	return

/mob/dead/Logout()
	update_z(null)
	return ..()

/mob/dead/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	..()
	update_z(new_turf?.z)
