
/*

	All telecommunications interactions:

*/

/obj/machinery/telecomms
	var/temp = "" // output message
	var/tempfreq = FREQ_COMMON
	var/mob/living/operator
	///Illegal frequencies that can't be listened to by telecommunication servers.
	var/list/banned_frequencies = list(
		FREQ_SYNDICATE,
		FREQ_CENTCOM,
		FREQ_CTF_RED,
		FREQ_CTF_YELLOW,
		FREQ_CTF_GREEN,
		FREQ_CTF_BLUE,
	)

/obj/machinery/telecomms/attackby(obj/item/P, mob/user, params)

	var/icon_closed = initial(icon_state)
	var/icon_open = "[initial(icon_state)]_o"
	if(!on)
		icon_closed = "[initial(icon_state)]_off"
		icon_open = "[initial(icon_state)]_o_off"

	if(default_deconstruction_screwdriver(user, icon_open, icon_closed, P))
		return
	// Using a multitool lets you access the receiver's interface
	else if(P.tool_behaviour == TOOL_MULTITOOL)
		attack_hand(user)

	else if(default_deconstruction_crowbar(P))
		return
	else
		return ..()

/obj/machinery/telecomms/ui_interact(mob/user, datum/tgui/ui)
	operator = user
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Telecomms")
		ui.open()

/obj/machinery/telecomms/ui_data(mob/user)
	var/list/data = list()

	data += add_option()

	data["minfreq"] = MIN_FREE_FREQ
	data["maxfreq"] = MAX_FREE_FREQ
	data["frequency"] = tempfreq

	var/obj/item/multitool/heldmultitool = get_multitool(user)
	data["multitool"] = heldmultitool

	if(heldmultitool)
		data["multibuff"] = heldmultitool.buffer

	data["toggled"] = toggled
	data["id"] = id
	data["network"] = network
	data["prefab"] = autolinkers.len ? TRUE : FALSE

	var/list/linked = list()
	var/i = 0
	data["linked"] = list()
	for(var/obj/machinery/telecomms/machine in links)
		i++
		if(machine.hide && !hide)
			continue
		var/list/entry = list()
		entry["index"] = i
		entry["name"] = machine.name
		entry["id"] = machine.id
		linked += list(entry)
	data["linked"] = linked

	var/list/frequencies = list()
	data["frequencies"] = list()
	for(var/x in freq_listening)
		frequencies += list(x)
	data["frequencies"] = frequencies

	return data

/obj/machinery/telecomms/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(!issilicon(usr))
		if(!istype(usr.get_active_held_item(), /obj/item/multitool))
			return

	var/obj/item/multitool/heldmultitool = get_multitool(operator)

	switch(action)
		if("toggle")
			toggled = !toggled
			update_power()
			update_appearance()
			operator.log_message("toggled [toggled ? "On" : "Off"] [src].", LOG_GAME)
			. = TRUE
		if("id")
			if(params["value"])
				if(length(params["value"]) > 32)
					to_chat(operator, span_warning("Error: Machine ID too long!"))
					playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
					return
				else
					id = params["value"]
					operator.log_message("has changed the ID for [src] to [id].", LOG_GAME)
					. = TRUE
		if("network")
			if(params["value"])
				if(length(params["value"]) > 15)
					to_chat(operator, span_warning("Error: Network name too long!"))
					playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
					return
				else
					for(var/obj/machinery/telecomms/T in links)
						remove_link(T)
					network = params["value"]
					links = list()
					operator.log_message("has changed the network for [src] to [network].", LOG_GAME)
					. = TRUE
		if("tempfreq")
			if(params["value"])
				tempfreq = text2num(params["value"]) * 10
		if("freq")
			if(tempfreq in banned_frequencies)
				to_chat(operator, span_warning("Error: Interference preventing filtering frequency: \"[tempfreq / 10] kHz\""))
				playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
			else
				if(!(tempfreq in freq_listening))
					freq_listening.Add(tempfreq)
					operator.log_message("added frequency [tempfreq] for [src].", LOG_GAME)
					. = TRUE
		if("delete")
			freq_listening.Remove(params["value"])
			operator.log_message("removed frequency [params["value"]] for [src].", LOG_GAME)
			. = TRUE
		if("unlink")
			var/obj/machinery/telecomms/T = links[text2num(params["value"])]
			if(T)
				. = remove_link(T, operator)
		if("link")
			if(heldmultitool)
				var/obj/machinery/telecomms/T = heldmultitool.buffer
				. = add_new_link(T, operator)
		if("buffer")
			heldmultitool.buffer = src
			. = TRUE
		if("flush")
			heldmultitool.buffer = null
			. = TRUE

	add_act(action, params)
	. = TRUE

///adds new_connection to src's links list AND vice versa. also updates links_by_telecomms_type
/obj/machinery/telecomms/proc/add_new_link(obj/machinery/telecomms/new_connection, mob/user)
	if(!istype(new_connection) || new_connection == src)
		return FALSE

	if((new_connection in links) && (src in new_connection.links))
		return FALSE

	links |= new_connection
	new_connection.links |= src

	LAZYADDASSOCLIST(links_by_telecomms_type, new_connection.telecomms_type, new_connection)
	LAZYADDASSOCLIST(new_connection.links_by_telecomms_type, telecomms_type, src)

	if(user)
		user.log_message("linked [src] for [new_connection].", LOG_GAME)
	return TRUE

///removes old_connection from src's links list AND vice versa. also updates links_by_telecomms_type
/obj/machinery/telecomms/proc/remove_link(obj/machinery/telecomms/old_connection, mob/user)
	if(!istype(old_connection) || old_connection == src)
		return FALSE

	if(old_connection in links)
		links -= old_connection
		LAZYREMOVEASSOC(links_by_telecomms_type, old_connection.telecomms_type, old_connection)

	if(src in old_connection.links)
		old_connection.links -= src
		LAZYREMOVEASSOC(old_connection.links_by_telecomms_type, telecomms_type, src)

	if(user)
		user.log_message("unlinked [src] and [old_connection].", LOG_GAME)

	return TRUE

/obj/machinery/telecomms/proc/add_option()
	return

/obj/machinery/telecomms/bus/add_option()
	var/list/data = list()
	data["type"] = "bus"
	data["changefrequency"] = change_frequency
	return data

/obj/machinery/telecomms/relay/add_option()
	var/list/data = list()
	data["type"] = "relay"
	data["broadcasting"] = broadcasting
	data["receiving"] = receiving
	return data

/obj/machinery/telecomms/proc/add_act(action, params)

/obj/machinery/telecomms/relay/add_act(action, params)
	switch(action)
		if("broadcast")
			broadcasting = !broadcasting
			. = TRUE
		if("receive")
			receiving = !receiving
			. = TRUE

/obj/machinery/telecomms/bus/add_act(action, params)
	switch(action)
		if("change_freq")
			var/newfreq = text2num(params["value"]) * 10
			if(newfreq)
				if(newfreq < 10000)
					change_frequency = newfreq
					. = TRUE
				else
					change_frequency = 0

// Returns a multitool from a user depending on their mobtype.

/obj/machinery/telecomms/proc/get_multitool(mob/user)
	var/obj/item/multitool/P = null
	// Let's double check
	if(!issilicon(user) && istype(user.get_active_held_item(), /obj/item/multitool))
		P = user.get_active_held_item()
	else if(isAI(user))
		var/mob/living/silicon/ai/U = user
		P = U.aiMulti
	else if(iscyborg(user) && in_range(user, src))
		if(istype(user.get_active_held_item(), /obj/item/multitool))
			P = user.get_active_held_item()
	return P

/obj/machinery/telecomms/proc/canAccess(mob/user)
	if(issilicon(user) || in_range(user, src))
		return TRUE
	return FALSE

/obj/machinery/telecomms/multitool_act_secondary(mob/living/user, obj/item/tool)
	var/obj/item/multitool/multitool = tool
	var/obj/machinery/telecomms/telecomms_machine = multitool.buffer
	if(QDELETED(multitool.buffer) || !multitool.buffer || !istype(telecomms_machine) || telecomms_machine == src) //sanity + user sanity
		return FALSE
	if(multitool.buffer in links)
		to_chat(user, span_notice("Unlinked [telecomms_machine] ([telecomms_machine.id]) from the [src]."))
		remove_link(multitool.buffer,user)
	else
		to_chat(user, span_notice("Linked [telecomms_machine] ([telecomms_machine.id]) to the [src]."))
		add_new_link(multitool.buffer,user)
	return TRUE
