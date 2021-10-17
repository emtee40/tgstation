/obj/machinery/portable_atmospherics
	name = "portable_atmospherics"
	icon = 'icons/obj/atmos.dmi'
	use_power = NO_POWER_USE
	max_integrity = 250
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 60, ACID = 30)
	anchored = FALSE

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	///Stores the gas mixture of the portable component. Don't access this directly, use return_air() so you support the temporary processing it provides
	var/datum/gas_mixture/air_contents
	///Stores the reference of the connecting port
	var/obj/machinery/atmospherics/components/unary/portables_connector/connected_port
	///Stores the reference of the tank the machine is holding
	var/obj/item/tank/holding
	///Volume (in L) of the inside of the machine
	var/volume = 0
	///Used to track if anything of note has happen while running process_atmos()
	var/excited = TRUE

/obj/machinery/portable_atmospherics/Initialize(mapload)
	. = ..()
	air_contents = new
	air_contents.volume = volume
	air_contents.temperature = T20C
	SSair.start_processing_machine(src)

/obj/machinery/portable_atmospherics/Destroy()
	disconnect()
	air_contents = null
	SSair.stop_processing_machine(src)

	return ..()

/obj/machinery/portable_atmospherics/ex_act(severity, target)
	if(resistance_flags & INDESTRUCTIBLE)
		return FALSE //Indestructable cans shouldn't release air

	if(severity == EXPLODE_DEVASTATE || target == src)
		//This explosion will destroy the can, release its air.
		var/turf/local_turf = get_turf(src)
		local_turf.assume_air(air_contents)

	return ..()

/obj/machinery/portable_atmospherics/process_atmos()
	if(!connected_port) // Pipe network handles reactions if connected, and we can't stop processing if there's a port effecting our mix
		excited = (excited | air_contents.react(src))
		if(!excited)
			return PROCESS_KILL
	excited = FALSE

/obj/machinery/portable_atmospherics/return_air()
	SSair.start_processing_machine(src)
	return air_contents

/obj/machinery/portable_atmospherics/return_analyzable_air()
	return air_contents

/**
 * Allow the portable machine to be connected to a connector
 * Arguments:
 * * new_port - the connector that we trying to connect to
 */
/obj/machinery/portable_atmospherics/proc/connect(obj/machinery/atmospherics/components/unary/portables_connector/new_port, mouse_drop = FALSE)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return FALSE

	//Make sure are close enough for a valid connection
	if(new_port.loc != get_turf(src) && !mouse_drop)
		return FALSE

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src
	var/datum/pipeline/connected_port_parent = connected_port.parents[1]
	connected_port_parent.reconcile_air()

	set_anchored(TRUE) //Prevent movement
	pixel_x = new_port.pixel_x
	pixel_y = new_port.pixel_y + 5

	SSair.start_processing_machine(src)
	update_appearance()
	return TRUE

/obj/machinery/portable_atmospherics/Move()
	. = ..()
	if(.)
		disconnect()

/**
 * Allow the portable machine to be disconnected from the connector
 */
/obj/machinery/portable_atmospherics/proc/disconnect()
	if(!connected_port)
		return FALSE
	set_anchored(FALSE)
	connected_port.connected_device = null
	connected_port = null
	pixel_x = 0
	pixel_y = 0

	SSair.start_processing_machine(src)
	update_appearance()
	return TRUE

/obj/machinery/portable_atmospherics/AltClick(mob/living/user)
	. = ..()
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)) || !can_interact(user))
		return
	if(!holding)
		return
	to_chat(user, span_notice("You remove [holding] from [src]."))
	replace_tank(user, TRUE)

/obj/machinery/portable_atmospherics/examine(mob/user)
	. = ..()
	. += span_notice("You can drag [src] on a connector while holding a wrench to connect it.")
	if(!holding)
		return
	. += span_notice("\The [src] contains [holding]. Alt-click [src] to remove it.")+\
		span_notice("Click [src] with another gas tank to hot swap [holding].")

/**
 * Allow the player to place a tank inside the machine.
 * Arguments:
 * * User: the player doing the act
 * * close_valve: used in the canister.dm file, check if the valve is open or not
 * * new_tank: the tank we are trying to put in the machine
 */
/obj/machinery/portable_atmospherics/proc/replace_tank(mob/living/user, close_valve, obj/item/tank/new_tank)
	if(!user)
		return FALSE
	if(holding)
		user.put_in_hands(holding)
		holding = null
	if(new_tank)
		holding = new_tank

	SSair.start_processing_machine(src)
	update_appearance()
	return TRUE

/obj/machinery/portable_atmospherics/attackby(obj/item/item, mob/user, params)
	if(!istype(item, /obj/item/tank))
		return ..()
	if(machine_stat & BROKEN)
		return FALSE
	var/obj/item/tank/insert_tank = item
	if(!user.transferItemToLoc(insert_tank, src))
		return FALSE
	to_chat(user, span_notice("[holding ? "In one smooth motion you pop [holding] out of [src]'s connector and replace it with [insert_tank]" : "You insert [insert_tank] into [src]"]."))
	investigate_log("had its internal [holding] swapped with [insert_tank] by [key_name(user)].", INVESTIGATE_ATMOS)
	replace_tank(user, FALSE, insert_tank)
	update_appearance()

/obj/machinery/portable_atmospherics/wrench_act(mob/living/user, obj/item/wrench)
	if(machine_stat & BROKEN)
		return FALSE
	if(connected_port)
		investigate_log("was disconnected from [connected_port] by [key_name(user)].", INVESTIGATE_ATMOS)
		disconnect()
		wrench.play_tool_sound(src)
		user.visible_message( \
			"[user] disconnects [src].", \
			span_notice("You unfasten [src] from the port."), \
			span_hear("You hear a ratchet."))
		update_appearance()
		change_density(TRUE)
		return TRUE

	var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port
	for(var/obj/machinery/atmospherics/components/unary/portables_connector/port in loc)
		if(port.connected_device)
			continue
		possible_port = port
		break //found the port, let's get out of here

	if(!possible_port)
		to_chat(user, span_notice("Nothing happens."))
		return FALSE
	if(!connect(possible_port))
		to_chat(user, span_notice("[name] failed to connect to the port."))
		return FALSE
	wrench.play_tool_sound(src)
	user.visible_message( \
		"[user] connects [src].", \
		span_notice("You fasten [src] to the port."), \
		span_hear("You hear a ratchet."))
	update_appearance()
	investigate_log("was connected to [possible_port] by [key_name(user)].", INVESTIGATE_ATMOS)
	change_density()
	return TRUE

/obj/machinery/portable_atmospherics/proc/change_density(set_density)
	if(!isnull(set_density))
		density = set_density
		return

	var/turf/our_turf = get_turf(src)
	var/portable_amounts = 0
	for(var/obj/machinery/portable_atmospherics/portable in our_turf.contents)
		if(portable == src)
			continue
		portable_amounts++
		portable.change_density(TRUE)

	if(portable_amounts > 0)
		density = TRUE
		return

	if(connected_port.piping_layer == PIPING_LAYER_MIN || connected_port.piping_layer == PIPING_LAYER_MAX)
		density = FALSE
		return

	density = TRUE

/obj/machinery/portable_atmospherics/MouseDrop(obj/machinery/atmospherics/components/unary/portables_connector/connector)
	. = ..()

	var/mob/user = usr

	if(!istype(connector) || connected_port || connector.connected_device)
		return

	if(get_dist(user, connector) > 1 || get_dist(user, src) > 1)
		return

	var/obj/item/held_item = user.get_active_held_item()
	if (isnull(held_item))
		return
	var/tool_behaviour = held_item.tool_behaviour

	if(tool_behaviour != TOOL_WRENCH)
		to_chat(user, span_notice("You need a wrench in hand for that."))
		return

	if(!connect(connector, TRUE))
		return

	held_item.play_tool_sound(src)
	user.visible_message( \
		"[user] connects [src].", \
		span_notice("You fasten [src] to the port."), \
		span_hear("You hear a ratchet."))
	forceMove(connector.loc)
	change_density()

/obj/machinery/portable_atmospherics/attacked_by(obj/item/item, mob/user)
	if(item.force < 10 && !(machine_stat & BROKEN))
		take_damage(0)
		return
	investigate_log("was smacked with \a [item] by [key_name(user)].", INVESTIGATE_ATMOS)
	add_fingerprint(user)
	return ..()

/obj/machinery/portable_atmospherics/rad_act(strength)
	. = ..()
	var/gas_change = FALSE
	var/list/cached_gases = air_contents.gases
	if(cached_gases[/datum/gas/oxygen] && cached_gases[/datum/gas/carbon_dioxide] && air_contents.temperature <= PLUOXIUM_TEMP_CAP)
		gas_change = TRUE
		var/pulse_strength = min(strength, cached_gases[/datum/gas/oxygen][MOLES] * 1000, cached_gases[/datum/gas/carbon_dioxide][MOLES] * 2000)
		cached_gases[/datum/gas/carbon_dioxide][MOLES] -= pulse_strength / 2000
		cached_gases[/datum/gas/oxygen][MOLES] -= pulse_strength / 1000
		ASSERT_GAS(/datum/gas/pluoxium, air_contents)
		cached_gases[/datum/gas/pluoxium][MOLES] += pulse_strength / 4000
		strength -= pulse_strength

	if(cached_gases[/datum/gas/hydrogen])
		gas_change = TRUE
		var/pulse_strength = min(strength, cached_gases[/datum/gas/hydrogen][MOLES] * 1000)
		cached_gases[/datum/gas/hydrogen][MOLES] -= pulse_strength / 1000
		ASSERT_GAS(/datum/gas/tritium, air_contents)
		cached_gases[/datum/gas/tritium][MOLES] += pulse_strength / 1000
		strength -= pulse_strength

	if(gas_change)
		air_contents.garbage_collect()
		SSair.start_processing_machine(src)
