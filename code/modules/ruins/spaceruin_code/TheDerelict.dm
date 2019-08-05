///////////	thederelict items

/obj/item/paper/fluff/ruins/thederelict/equipment
	info = "If the equipment breaks there should be enough spare parts in our engineering storage near the north east solar array."
	name = "Equipment Inventory"

/obj/item/paper/fluff/ruins/thederelict/syndie_mission
	name = "Mission Objectives"
	info = "The Syndicate have cunningly disguised a Syndicate Uplink as your PDA. Simply enter the code \"678 Bravo\" into the ringtone select to unlock its hidden features. <br><br><b>Objective #1</b>. Kill the God damn AI in a fire blast that it rocks the station. <b>Success!</b>  <br><b>Objective #2</b>. Escape alive. <b>Failed.</b>"

/obj/item/paper/fluff/ruins/thederelict/nukie_objectives
	name = "Objectives of a Nuclear Operative"
	info = "<b>Objective #1</b>: Destroy the station with a nuclear device."

/obj/item/paper/crumpled/bloody/ruins/thederelict/unfinished
	name = "unfinished paper scrap"
	desc = "Looks like someone started shakily writing a will in space common, but were interrupted by something bloody..."
	info = "I, Victor Belyakov, do hereby leave my _- "
/obj/item/paper/fluff/ruins/thederelict/vaultraider
	name = "Vault Raider Objectives"
	info = "<b>Objectives #1</b>: Find out what is hidden in Kosmicheskaya Stantsiya 13s Vault"


/// Vault controller for use on the derelict/KS13.
/obj/machinery/computer/vaultcontroller
	name = "vault controller"
	desc = "It seems to be powering and controlling the vault locks."
	icon_screen = "power"
	icon_keyboard = "power_key"
	light_color = LIGHT_COLOR_YELLOW
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/obj/structure/cable/attached_cable
	var/obj/machinery/door/airlock/vault/derelict/door1
	var/obj/machinery/door/airlock/vault/derelict/door2
	var/locked = TRUE
	var/siphoned_power = 0
	var/siphon_max = 1e7


/obj/machinery/computer/monitor/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It appears to be powered via a cable connector.</span>"


//Initializing airlock links.
/obj/machinery/computer/vaultcontroller/Initialize()
	..()
	for(var/obj/machinery/door/airlock/vault/derelict/A in GLOB.airlocks)
		if(A.id_tag == "derelictvault")
			if(!door1)
				door1 = A
			if(door1 && !door2)
				door2 = A
			if(door1 && door2)
				break


//Checks for cable connection, charges if possible.
/obj/machinery/computer/vaultcontroller/process()
	if(siphoned_power >= siphon_max)
		return
	update_cable()
	if(attached_cable)
		attempt_siphon()


///Looks for a cable connection beneath the machine.
/obj/machinery/computer/vaultcontroller/proc/update_cable()
	var/turf/T = get_turf(src)
	attached_cable = locate(/obj/structure/cable) in T


///Tries to charge from powernet excess, no upper limit except max charge.
/obj/machinery/computer/vaultcontroller/proc/attempt_siphon()
	var/surpluspower = CLAMP(attached_cable.surplus(), 0, (siphon_max - siphoned_power))
	if(surpluspower)
		attached_cable.add_load(surpluspower)
		siphoned_power += surpluspower


///Attempts to lock/unlock vault doors, if machine is charged.
/obj/machinery/computer/vaultcontroller/proc/activate_lock()
	if(siphoned_power < siphon_max)
		return
	if(locked)
		unlock_vault()
	else
		lock_vault()


///Attempts to lock the vault doors
/obj/machinery/computer/vaultcontroller/proc/lock_vault()
	if(door1 && !door1.density)
		door1.safe = FALSE //Make sure its forced closed, always
		door1.unbolt()
		door1.close()
		door1.bolt()
	if(door2 && !door2.density)
		door2.safe = FALSE //Make sure its forced closed, always
		door2.unbolt()
		door2.close()
		door2.bolt()
	if(door1.density && door1.locked && door2.density && door2.locked)
		locked = TRUE


///Attempts to unlock the vault doors
/obj/machinery/computer/vaultcontroller/proc/unlock_vault()
	if(door1 && door1.density)
		door1.unbolt()
		door1.open()
		door1.bolt()
	if(door2 && door2.density)
		door2.unbolt()
		door2.open()
		door2.bolt()
	if(!door1.density && door1.locked && !door2.density && door2.locked)
		locked = FALSE


/obj/machinery/computer/vaultcontroller/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
											datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "vault_controller", name, 300, 150, master_ui, state)
		ui.open()


/obj/machinery/computer/vaultcontroller/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("togglelock")
			activate_lock()


/obj/machinery/computer/vaultcontroller/ui_data()
	var/list/data = list()
	data["stored"] = siphoned_power
	data["max"] = siphon_max
	data["doorstatus"] = locked

	return data


//Airlock that can't be deconstructed, broken or hacked.
/obj/machinery/door/airlock/vault/derelict
	locked = TRUE
	move_resist = INFINITY
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	id_tag = "derelictvault"


//Overrides rcd_act to prevent all deconstruction.
/obj/machinery/door/airlock/vault/derelict/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	return


//Overrides tool_act to prevent all deconstruction and hacking.
/obj/machinery/door/airlock/vault/derelict/tool_act(mob/living/user, obj/item/I, tool_type)
	return
