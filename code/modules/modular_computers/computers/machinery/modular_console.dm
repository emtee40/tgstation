/obj/machinery/modular_computer/console
	name = "console"
	desc = "A stationary computer."

	icon = 'icons/obj/modular_console.dmi'
	icon_state = "console"
	icon_state_powered = "console"
	icon_state_unpowered = "console-off"
	screen_icon_state_menu = "menu"
	hardware_flag = PROGRAM_CONSOLE
	var/console_department = "" // Used in New() to set network tag according to our area.
	anchored = 1
	density = 1
	base_idle_power_usage = 100
	base_active_power_usage = 500
	max_hardware_size = 4
	steel_sheet_cost = 10
	light_strength = 2
	health = 300
	maxhealth = 300
	broken_health = 150

/obj/machinery/modular_computer/console/buildable/New()
	..()
	// User-built consoles start as empty frames.
	var/obj/item/weapon/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	var/obj/item/weapon/computer_hardware/hard_drive/network_card = cpu.all_components[MC_NET]
	var/obj/item/weapon/computer_hardware/hard_drive/recharger = cpu.all_components[MC_CHARGE]
	qdel(recharger)
	qdel(network_card)
	qdel(hard_drive)

/obj/machinery/modular_computer/console/New()
	..()
	var/obj/item/weapon/computer_hardware/battery/battery_module = cpu.all_components[MC_CELL]
	if(battery_module)
		qdel(battery_module)

	var/obj/item/weapon/computer_hardware/network_card/wired/network_card = new()

	cpu.install_component(network_card)
	cpu.install_component(new /obj/item/weapon/computer_hardware/recharger/APC)
	cpu.install_component(new /obj/item/weapon/computer_hardware/hard_drive/super) // Consoles generally have better HDDs due to lower space limitations

	var/area/A = get_area(src)
	// Attempts to set this console's tag according to our area. Since some areas have stuff like "XX - YY" in their names we try to remove that too.
	if(A && console_department)
		network_card.identification_string = replacetext(replacetext(replacetext("[A.name] [console_department] Console", " ", "_"), "-", ""), "__", "_") // Replace spaces with "_"
	else if(A)
		network_card.identification_string = replacetext(replacetext(replacetext("[A.name] Console", " ", "_"), "-", ""), "__", "_")
	else if(console_department)
		network_card.identification_string = replacetext(replacetext(replacetext("[console_department] Console", " ", "_"), "-", ""), "__", "_")
	else
		network_card.identification_string = "Unknown Console"
	if(cpu)
		cpu.screen_on = 1
	update_icon()