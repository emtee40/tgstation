// This is the base type that does all the hardware stuff.
// Other types expand it - tablets use a direct subtypes, and
// consoles and laptops use "procssor" item that is held inside machinery piece
/obj/item/modular_computer
	name = "modular microcomputer"
	desc = "A small portable microcomputer."

	var/enabled = 0											// Whether the computer is turned on.
	var/screen_on = 1										// Whether the computer is active/opened/it's screen is on.
	var/datum/computer_file/program/active_program = null	// A currently active program running on the computer.
	var/hardware_flag = 0									// A flag that describes this device type
	var/last_power_usage = 0
	var/last_battery_percent = 0							// Used for deciding if battery percentage has chandged
	var/last_world_time = "00:00"
	var/list/last_header_icons
	var/emagged = 0											// Whether the computer is emagged.

	var/base_active_power_usage = 50						// Power usage when the computer is open (screen is active) and can be interacted with. Remember hardware can use power too.
	var/base_idle_power_usage = 5							// Power usage when the computer is idle and screen is off (currently only applies to laptops)

	// Modular computers can run on various devices. Each DEVICE (Laptop, Console, Tablet,..)
	// must have it's own DMI file. Icon states must be called exactly the same in all files, but may look differently
	// If you create a program which is limited to Laptops and Consoles you don't have to add it's icon_state overlay for Tablets too, for example.

	icon = 'icons/obj/computer.dmi'
	icon_state = "laptop-open"
	var/icon_state_unpowered = null							// Icon state when the computer is turned off.
	var/icon_state_powered = null							// Icon state when the computer is turned on.
	var/icon_state_menu = "menu"							// Icon state overlay when the computer is turned on, but no program is loaded that would override the screen.
	var/max_hardware_size = 0								// Maximal hardware w_class. Tablets/PDAs have 1, laptops 2, consoles 4.
	var/steel_sheet_cost = 5								// Amount of steel sheets refunded when disassembling an empty frame of this computer.

	// Damage of the chassis. If the chassis takes too much damage it will break apart.
	var/damage = 0				// Current damage level
	var/broken_damage = 50		// Damage level at which the computer ceases to operate
	var/max_damage = 100		// Damage level at which the computer breaks apart.

	// Important hardware (must be installed for computer to work)
	var/obj/item/weapon/computer_hardware/processor_unit/processor_unit				// CPU. Without it the computer won't run. Better CPUs can run more programs at once.
	var/obj/item/weapon/computer_hardware/hard_drive/hard_drive						// Hard Drive component of this computer. Stores programs and files.

	var/obj/item/weapon/computer_hardware/battery/battery_module					// Power cell connector. Power cell can be recharged.
																					// OR
	var/obj/item/weapon/computer_hardware/recharger/recharger 						// Recharger. Can be used to recharge power cell or power the PC without it.

	// Optional hardware (improves functionality, but is not critical for computer to work)
	var/obj/item/weapon/computer_hardware/network_card/network_card					// Network Card component of this computer. Allows connection to NTNet.
	var/obj/item/weapon/computer_hardware/card_slot/card_slot						// ID Card slot component of this computer.
	var/obj/item/weapon/computer_hardware/printer/printer							// Printer component of this computer, for your everyday paperwork needs.
	var/obj/item/weapon/computer_hardware/hard_drive/portable/portable_drive		// Portable data storage

	var/list/all_components = list()

	var/list/idle_threads = list()							// Idle programs on background. They still receive process calls but can't be interacted with.
	var/obj/physical = null									// Object that represents our computer. It's used for Adjacent() and UI visibility checks.



/obj/item/modular_computer/New()
	START_PROCESSING(SSobj, src)
	update_icon()
	if(!physical)
		physical = src
	..()

/obj/item/modular_computer/Destroy()
	kill_program(1)
	STOP_PROCESSING(SSobj, src)
	for(var/H in all_components)
		qdel(H)
	return ..()

// Eject ID card from computer, if it has ID slot with card inside.
/obj/item/modular_computer/verb/eject_id()
	set name = "Eject ID"
	set category = "Object"
	set src in view(1)

	if(issilicon(usr))
		return

	if (usr.canUseTopic(src))
		proc_eject_id(usr)

// Eject ID card from computer, if it has ID slot with card inside.
/obj/item/modular_computer/verb/eject_disk()
	set name = "Eject Data Disk"
	set category = "Object"
	set src in view(1)

	if(issilicon(usr))
		return

	if (usr.canUseTopic(src))
		proc_eject_disk(usr)

/obj/item/modular_computer/proc/proc_eject_id(mob/user, slot)
	if(!user)
		user = usr

	if(!card_slot)
		user << "<span class='warning'>\The [src] does not have an ID card slot!</span>"
		return

	card_slot.try_eject(slot, user)

/obj/item/modular_computer/proc/proc_eject_disk(mob/user)
	if(!user)
		user = usr

	if(!portable_drive)
		user << "<span class='warning'>There is no data disk in \the [src]!</span>"
		return

	var/obj/item/I = portable_drive
	if(uninstall_component(portable_drive, user))
		I.verb_pickup()

/obj/item/modular_computer/AltClick(mob/user)
	..()
	if(issilicon(user))
		return

	if(user.canUseTopic(src))
		if(portable_drive)
			proc_eject_disk(user)
		else if(card_slot)
			proc_eject_id(user)


// Gets IDs/access levels from card slot. Would be useful when/if PDAs would become modular PCs.
/obj/item/modular_computer/GetAccess()
	if(card_slot)
		return card_slot.GetAccess()
	return ..()

/obj/item/modular_computer/GetID()
	if(card_slot)
		return card_slot.GetID()
	return ..()

/obj/item/modular_computer/MouseDrop(obj/over_object, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /obj/screen)) && usr.canUseTopic(src))
		return attack_self(M)
	return

/obj/item/modular_computer/attack_ghost(mob/dead/observer/user)
	if(enabled)
		ui_interact(user)
	else if(IsAdminGhost(user))
		var/response = alert(user, "This computer is turned off. Would you like to turn it on?", "Admin Override", "Yes", "No")
		if(response == "Yes")
			turn_on(user)

/obj/item/modular_computer/emag_act(mob/user)
	if(emagged)
		user << "<span class='warning'>\The [src] was already emagged.</span>"
		return 0
	else
		emagged = 1
		user << "<span class='notice'>You emag \the [src]. It's screen briefly shows a \"OVERRIDE ACCEPTED: New software downloads available.\" message.</span>"
		return 1

/obj/item/modular_computer/examine(mob/user)
	..()
	if(damage > broken_damage)
		user << "<span class='danger'>It is heavily damaged!</span>"
	else if(damage)
		user << "<span class='warning'>It is damaged.</span>"

/obj/item/modular_computer/update_icon()
	cut_overlays()
	if(!enabled)
		icon_state = icon_state_unpowered
	else
		icon_state = icon_state_powered
		if(active_program)
			add_overlay(active_program.program_icon_state ? active_program.program_icon_state : icon_state_menu)
		else
			add_overlay(icon_state_menu)

	if(damage > broken_damage)
		add_overlay("bsod")
		add_overlay("broken")


// On-click handling. Turns on the computer if it's off and opens the GUI.
/obj/item/modular_computer/attack_self(mob/user)
	if(enabled)
		ui_interact(user)
	else
		turn_on(user)

/obj/item/modular_computer/proc/turn_on(mob/user)
	var/issynth = issilicon(user) // Robots and AIs get different activation messages.
	if(damage > broken_damage)
		if(issynth)
			user << "<span class='warning'>You send an activation signal to \the [src], but it responds with an error code. It must be damaged.</span>"
		else
			user << "<span class='warning'>You press the power button, but the computer fails to boot up, displaying variety of errors before shutting down again.</span>"
		return

	// If we have a recharger, enable it automatically. Lets computer without a battery work.
	if(recharger)
		recharger.enabled = 1

	if(processor_unit && use_power()) // use_power() checks if the PC is powered
		if(issynth)
			user << "<span class='notice'>You send an activation signal to \the [src], turning it on.</span>"
		else
			user << "<span class='notice'>You press the power button and start up \the [src].</span>"
		enabled = 1
		update_icon()
		ui_interact(user)
	else // Unpowered
		if(issynth)
			user << "<span class='warning'>You send an activation signal to \the [src] but it does not respond.</span>"
		else
			user << "<span class='warning'>You press the power button but \the [src] does not respond.</span>"

// Process currently calls handle_power(), may be expanded in future if more things are added.
/obj/item/modular_computer/process()
	if(!enabled) // The computer is turned off
		last_power_usage = 0
		return 0

	if(damage > broken_damage)
		shutdown_computer()
		return 0

	if(active_program && active_program.requires_ntnet && !get_ntnet_status(active_program.requires_ntnet_feature))
		active_program.event_networkfailure(0) // Active program requires NTNet to run but we've just lost connection. Crash.

	for(var/I in idle_threads)
		var/datum/computer_file/program/P = I
		if(P.requires_ntnet && !get_ntnet_status(P.requires_ntnet_feature))
			P.event_networkfailure(1)

	if(active_program)
		if(active_program.program_state != PROGRAM_STATE_KILLED)
			active_program.process_tick()
			active_program.ntnet_status = get_ntnet_status()
			active_program.emagged = emagged
		else
			active_program = null

	for(var/I in idle_threads)
		var/datum/computer_file/program/P = I
		if(P.program_state != PROGRAM_STATE_KILLED)
			P.process_tick()
			P.ntnet_status = get_ntnet_status()
			P.emagged = emagged
		else
			idle_threads.Remove(P)

	handle_power() // Handles all computer power interaction
	//check_update_ui_need()

// Function used by NanoUI's to obtain data for header. All relevant entries begin with "PC_"
/obj/item/modular_computer/proc/get_header_data()
	var/list/data = list()

	if(battery_module && battery_module.battery)
		switch(battery_module.battery.percent())
			if(80 to 200) // 100 should be maximal but just in case..
				data["PC_batteryicon"] = "batt_100.gif"
			if(60 to 80)
				data["PC_batteryicon"] = "batt_80.gif"
			if(40 to 60)
				data["PC_batteryicon"] = "batt_60.gif"
			if(20 to 40)
				data["PC_batteryicon"] = "batt_40.gif"
			if(5 to 20)
				data["PC_batteryicon"] = "batt_20.gif"
			else
				data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "[round(battery_module.battery.percent())] %"
		data["PC_showbatteryicon"] = 1
	else
		data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "N/C"
		data["PC_showbatteryicon"] = battery_module ? 1 : 0

	if(recharger && recharger.enabled && recharger.check_functionality() && recharger.use_power(0))
		data["PC_apclinkicon"] = "charging.gif"

	switch(get_ntnet_status())
		if(0)
			data["PC_ntneticon"] = "sig_none.gif"
		if(1)
			data["PC_ntneticon"] = "sig_low.gif"
		if(2)
			data["PC_ntneticon"] = "sig_high.gif"
		if(3)
			data["PC_ntneticon"] = "sig_lan.gif"

	if(idle_threads.len)
		var/list/program_headers = list()
		for(var/I in idle_threads)
			var/datum/computer_file/program/P = I
			if(!P.ui_header)
				continue
			program_headers.Add(list(list(
				"icon" = P.ui_header
			)))

		data["PC_programheaders"] = program_headers

	data["PC_stationtime"] = worldtime2text()
	data["PC_hasheader"] = 1
	data["PC_showexitprogram"] = active_program ? 1 : 0 // Hides "Exit Program" button on mainscreen
	return data

// Relays kill program request to currently active program. Use this to quit current program.
/obj/item/modular_computer/proc/kill_program(forced = 0)
	if(active_program)
		active_program.kill_program(forced)
		active_program = null
	var/mob/user = usr
	if(user && istype(user))
		ui_interact(user) // Re-open the UI on this computer. It should show the main screen now.
	update_icon()

// Returns 0 for No Signal, 1 for Low Signal and 2 for Good Signal. 3 is for wired connection (always-on)
/obj/item/modular_computer/proc/get_ntnet_status(specific_action = 0)
	if(network_card)
		return network_card.get_signal(specific_action)
	else
		return 0

/obj/item/modular_computer/proc/add_log(text)
	if(!get_ntnet_status())
		return 0
	return ntnet_global.add_log(text, network_card)

/obj/item/modular_computer/proc/shutdown_computer(loud = 1)
	kill_program(1)
	for(var/datum/computer_file/program/P in idle_threads)
		P.kill_program(1)
		idle_threads.Remove(P)
	if(loud)
		physical.visible_message("<span class='notice'>\The [src] shuts down.</span>")
	enabled = 0
	update_icon()
	return


/obj/item/modular_computer/attackby(obj/item/weapon/W as obj, mob/user as mob)
	// Insert items into the components
	for(var/h in all_components)
		var/obj/item/weapon/computer_hardware/H = h
		if(H.try_insert(W, user))
			return

	// Insert new hardware
	if(istype(W, /obj/item/weapon/computer_hardware))
		if(install_component(W, user))
			return

	if(istype(W, /obj/item/weapon/wrench))
		if(all_components.len)
			user << "<span class='warning'>Remove all components from \the [src] before disassembling it.</span>"
			return
		new /obj/item/stack/sheet/metal( get_turf(src.loc), steel_sheet_cost )
		physical.visible_message("\The [src] has been disassembled by [user].")
		relay_qdel()
		qdel(src)
		return

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.isOn())
			user << "<span class='warning'>\The [W] is off.</span>"
			return

		if(!damage)
			user << "<span class='warning'>\The [src] does not require repairs.</span>"
			return

		user << "<span class='notice'>You begin repairing damage to \the [src]...</span>"
		if(WT.remove_fuel(round(damage/75)) && do_after(usr, damage/10))
			damage = 0
			user << "<span class='notice'>You repair \the [src].</span>"
		return

	if(istype(W, /obj/item/weapon/screwdriver))
		if(!all_components.len)
			user << "<span class='warning'>This device doesn't have any components installed.</span>"
			return
		var/list/component_names = list()
		for(var/obj/item/weapon/computer_hardware/H in all_components)
			component_names.Add(H.name)

		var/choice = input(usr, "Which component do you want to uninstall?", "Computer maintenance", null) as null|anything in component_names

		if(!choice)
			return

		if(!Adjacent(usr))
			return

		var/obj/item/weapon/computer_hardware/H = find_hardware_by_name(choice)

		if(!H)
			return

		uninstall_component(H, user)
		return

	..()

// Used by processor to relay qdel() to machinery type.
/obj/item/modular_computer/proc/relay_qdel()
	return

// Perform adjacency checks on our physical counterpart, if any.
/obj/item/modular_computer/Adjacent(atom/neighbor)
	if(physical && physical != src)
		return physical.Adjacent(neighbor)
	return ..()
