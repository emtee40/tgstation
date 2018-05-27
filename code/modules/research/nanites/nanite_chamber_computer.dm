/obj/machinery/computer/nanite_chamber_control
	name = "nanite chamber control console"
	desc = "Controls a connected nanite chamber. Can inoculate nanites, load programs, and analyze existing nanite swarms."
	var/obj/machinery/nanite_chamber/chamber
	var/obj/item/disk/nanite_program/disk
	circuit = /obj/item/circuitboard/computer/nanite_chamber_control
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "nanite_chamber_control"

/obj/machinery/computer/nanite_chamber_control/Initialize()
	. = ..()
	find_chamber()

/obj/machinery/computer/nanite_chamber_control/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/disk/nanite_program))
		var/obj/item/disk/nanite_program/N = I
		if(disk)
			eject()
		if(user.transferItemToLoc(N, src))
			to_chat(user, "<span class='notice'>You insert [N] into [src]</span>")
			disk = N
	else
		..()

/obj/machinery/computer/nanite_chamber_control/proc/eject()
	if(!disk)
		return
	disk.forceMove(drop_location()) //TODO: put in mob active hand
	disk = null

/obj/machinery/computer/nanite_chamber_control/proc/find_chamber()
	for(var/direction in GLOB.cardinals)
		var/C = locate(/obj/machinery/nanite_chamber, get_step(src, direction))
		if(C)
			var/obj/machinery/nanite_chamber/NC = C
			chamber = NC
			NC.console = src

/obj/machinery/computer/nanite_chamber_control/interact()
	if(!chamber)
		find_chamber()
	..()

/obj/machinery/computer/nanite_chamber_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "nanite_chamber_control", name, 600, 1200, master_ui, state)
		ui.open()

/obj/machinery/computer/nanite_chamber_control/ui_data()
	var/list/data = list()
	if(disk)
		data["has_disk"] = TRUE
		var/list/disk_data = list()
		var/datum/nanite_program/P = disk.program
		disk_data["name"] = P.name
		disk_data["desc"] = P.desc

		disk_data["activated"] = P.activated
		disk_data["activation_delay"] = P.activation_delay
		disk_data["timer"] = P.timer
		disk_data["activation_code"] = P.activation_code
		disk_data["deactivation_code"] = P.deactivation_code
		disk_data["kill_code"] = P.kill_code
		disk_data["trigger_code"] = P.trigger_code
		disk_data["timer_type"] = P.get_timer_type_text()

		if(istype(P, /datum/nanite_program/relay))
			var/datum/nanite_program/relay/S = P
			disk_data["relay_code"] = S.relay_code
		data["disk"] = disk_data

	if(!chamber)
		data["status_msg"] = "No chamber detected."
		return data

	data["scan_level"] = chamber.scan_level

	if(!chamber.occupant)
		data["status_msg"] = "No occupant detected."
		return data

	if(chamber.busy)
		data["status_msg"] = chamber.busy_message

	data["occupant_name"] = chamber.occupant.name

	GET_COMPONENT_FROM(nanites, /datum/component/nanites, chamber.occupant)
	if(nanites)
		data["has_nanites"] = TRUE
		data["nanite_volume"] = nanites.nanite_volume
		data["regen_rate"] = nanites.regen_rate
		data["safety_threshold"] = nanites.safety_threshold
		var/list/mob_programs = list()
		for(var/datum/nanite_program/P in nanites.programs)
			var/list/mob_program = list()
			var/id = 1
			mob_program["name"] = P.name
			mob_program["desc"] = P.desc
			mob_program["id"] = id

			if(chamber.scan_level >= 2)
				mob_program["activated"] = P.activated
				mob_program["use_rate"] = P.use_rate
				mob_program["can_trigger"] = P.can_trigger
				mob_program["trigger_cost"] = P.trigger_cost
				mob_program["trigger_cooldown"] = P.trigger_cooldown / 10

			if(chamber.scan_level >= 3)
				mob_program["activation_delay"] = P.activation_delay
				mob_program["timer"] = P.timer
				mob_program["timer_type"] = P.get_timer_type_text()

			if(chamber.scan_level >= 4)
				mob_program["activation_code"] = P.activation_code
				mob_program["deactivation_code"] = P.deactivation_code
				mob_program["kill_code"] = P.kill_code
				mob_program["trigger_code"] = P.trigger_code
				if(istype(P, /datum/nanite_program/relay))
					var/datum/nanite_program/relay/S = P
					mob_program["relay_code"] = S.relay_code
			id++
			mob_programs += mob_program
		data["mob_programs"] = mob_programs

	return data

/obj/machinery/computer/nanite_chamber_control/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("toggle_lock")
			chamber.locked = !chamber.locked
			. = TRUE
		if("eject")
			eject()
			. = TRUE
		if("set_safety")
			var/threshold = input("Set safety threshold (0-500):", name, null) as null|num
			if(!isnull(threshold))
				chamber.set_safety(threshold)
			. = TRUE
		if("connect_chamber")
			find_chamber()
			. = TRUE
		if("nanite_injection")
			chamber.inject_nanites()
			. = TRUE
		if("add_program")
			if(!disk || !chamber || !chamber.occupant)
				return
			chamber.install_program(disk.program)
			. = TRUE
		if("remove_program")
			if(!chamber || !chamber.occupant)
				return
			GET_COMPONENT_FROM(nanites, /datum/component/nanites, chamber.occupant)
			if(nanites)
				var/datum/nanite_program/P = nanites.programs[params["program_id"]]
				chamber.uninstall_program(P)
			. = TRUE