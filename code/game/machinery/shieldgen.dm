/obj/structure/emergency_shield
	name = "emergency energy shield"
	desc = "An energy shield used to contain hull breaches."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-old"
	density = TRUE
	move_resist = INFINITY
	opacity = FALSE
	anchored = TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	max_integrity = 200 //The shield can only take so much beating (prevents perma-prisons)
	can_atmos_pass = ATMOS_PASS_DENSITY

/obj/structure/emergency_shield/Initialize(mapload)
	. = ..()
	setDir(pick(GLOB.cardinals))
	air_update_turf(TRUE, TRUE)

/obj/structure/emergency_shield/Destroy()
	air_update_turf(TRUE, FALSE)
	. = ..()

/obj/structure/emergency_shield/Move()
	var/turf/T = loc
	. = ..()
	move_update_air(T)

/obj/structure/emergency_shield/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			take_damage(50, BRUTE, ENERGY, 0)

/obj/structure/emergency_shield/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BURN)
			playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)
		if(BRUTE)
			playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)

/obj/structure/emergency_shield/take_damage(damage, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(.) //damage was dealt
		new /obj/effect/temp_visual/impact_effect/ion(loc)

/// Subtype of shields that repair over time after sustaining integrity damage
/obj/structure/emergency_shield/regenerating
	name = "energy shield"
	desc = "An energy shield used to let ships through, but keep out the void of space."
	max_integrity = 400
	/// How much integrity is healed per second (per process multiplied by seconds per tick)
	var/heal_rate_per_second = 5

/obj/structure/emergency_shield/regenerating/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)

/obj/structure/emergency_shield/regenerating/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/emergency_shield/regenerating/take_damage(damage, damage_type, damage_flag, sound_effect, attack_dir)
	. = ..()
	if(.)
		// We took some damage so we'll start processing to heal said damage.
		START_PROCESSING(SSobj, src)

/obj/structure/emergency_shield/regenerating/process(seconds_per_tick)
	var/repaired_amount = repair_damage(heal_rate_per_second * seconds_per_tick)
	if(repaired_amount <= 0)
		// 0 damage repaired means we're at the max integrity, so don't need to process anymore
		STOP_PROCESSING(SSobj, src)

/obj/structure/emergency_shield/cult
	name = "cult barrier"
	desc = "A shield summoned by cultists to keep heretics away."
	max_integrity = 100
	icon_state = "shield-red"

/obj/structure/emergency_shield/cult/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)

/obj/structure/emergency_shield/cult/narsie
	name = "sanguine barrier"
	desc = "A potent shield summoned by cultists to defend their rites."
	max_integrity = 60

/obj/structure/emergency_shield/cult/weak
	name = "Invoker's Shield"
	desc = "A weak shield summoned by cultists to protect them while they carry out delicate rituals."
	color = "#FF0000"
	max_integrity = 20
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER

/obj/structure/emergency_shield/cult/barrier
	density = FALSE //toggled on right away by the parent rune
	can_atmos_pass = ATMOS_PASS_DENSITY
	///The rune that created the shield itself. Used to delete the rune when the shield is destroyed.
	var/obj/effect/rune/parent_rune

/obj/structure/emergency_shield/cult/barrier/attack_hand(mob/living/user, list/modifiers)
	parent_rune.attack_hand(user, modifiers)

/obj/structure/emergency_shield/cult/barrier/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(IS_CULTIST(user))
		parent_rune.attack_animal(user)
	else
		..()

/obj/structure/emergency_shield/cult/barrier/Destroy()
	if(parent_rune)
		parent_rune.visible_message(span_danger("The [parent_rune] fades away as [src] is destroyed!"))
		QDEL_NULL(parent_rune)
	return ..()

/**
*Turns the shield on and off.
*
*The shield has 2 states: on and off. When on, it will block movement,projectiles, items, etc. and be clearly visible, and block atmospheric gases.
*When off, the rune no longer blocks anything and turns invisible.
*The barrier itself is not intended to interact with the conceal runes cult spell for balance purposes.
*/
/obj/structure/emergency_shield/cult/barrier/proc/Toggle()
	set_density(!density)
	air_update_turf(TRUE, !density)
	invisibility = initial(invisibility)
	if(!density)
		invisibility = INVISIBILITY_OBSERVER

/obj/machinery/shieldgen
	name = "anti-breach shielding projector"
	desc = "Used to seal minor hull breaches."
	icon = 'icons/obj/objects.dmi'
	icon_state = "shieldoff"
	density = TRUE
	opacity = FALSE
	anchored = FALSE
	pressure_resistance = 2*ONE_ATMOSPHERE
	req_access = list(ACCESS_ENGINEERING)
	max_integrity = 100
	var/active = FALSE
	var/list/deployed_shields
	var/locked = FALSE
	var/shield_range = 4

/obj/machinery/shieldgen/Initialize(mapload)
	. = ..()
	deployed_shields = list()
	if(mapload && active && anchored)
		shields_up()

/obj/machinery/shieldgen/Destroy()
	QDEL_LIST(deployed_shields)
	return ..()


/obj/machinery/shieldgen/proc/shields_up()
	active = TRUE
	update_appearance()
	move_resist = INFINITY

	for(var/turf/target_tile as anything in RANGE_TURFS(shield_range, src))
		if(isspaceturf(target_tile) && !(locate(/obj/structure/emergency_shield) in target_tile))
			if(!(machine_stat & BROKEN) || prob(33))
				deployed_shields += new /obj/structure/emergency_shield(target_tile)

/obj/machinery/shieldgen/proc/shields_down()
	active = FALSE
	move_resist = initial(move_resist)
	update_appearance()
	QDEL_LIST(deployed_shields)

/obj/machinery/shieldgen/process(seconds_per_tick)
	if((machine_stat & BROKEN) && active)
		if(deployed_shields.len && SPT_PROB(2.5, seconds_per_tick))
			qdel(pick(deployed_shields))


/obj/machinery/shieldgen/deconstruct(disassembled = TRUE)
	atom_break()
	locked = pick(0,1)

/obj/machinery/shieldgen/interact(mob/user)
	. = ..()
	if(.)
		return
	if(locked && !issilicon(user))
		to_chat(user, span_warning("The machine is locked, you are unable to use it!"))
		return
	if(panel_open)
		to_chat(user, span_warning("The panel must be closed before operating this machine!"))
		return

	if (active)
		user.visible_message(span_notice("[user] deactivated \the [src]."), \
			span_notice("You deactivate \the [src]."), \
			span_hear("You hear heavy droning fade out."))
		shields_down()
	else
		if(anchored)
			user.visible_message(span_notice("[user] activated \the [src]."), \
				span_notice("You activate \the [src]."), \
				span_hear("You hear heavy droning."))
			shields_up()
		else
			to_chat(user, span_warning("The device must first be secured to the floor!"))
	return

/obj/machinery/shieldgen/screwdriver_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src, 100)
	toggle_panel_open()
	if(panel_open)
		to_chat(user, span_notice("You open the panel and expose the wiring."))
	else
		to_chat(user, span_notice("You close the panel."))
	return TRUE

/obj/machinery/shieldgen/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(locked)
		to_chat(user, span_warning("The bolts are covered! Unlocking this would retract the covers."))
		return
	if(!anchored && !isinspace())
		tool.play_tool_sound(src, 100)
		balloon_alert(user, "secured")
		set_anchored(TRUE)
	else if(anchored)
		tool.play_tool_sound(src, 100)
		balloon_alert(user, "unsecured")
		if(active)
			to_chat(user, span_notice("\The [src] shuts off!"))
			shields_down()
		set_anchored(FALSE)


/obj/machinery/shieldgen/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/cable_coil) && (machine_stat & BROKEN) && panel_open)
		var/obj/item/stack/cable_coil/coil = W
		if (coil.get_amount() < 1)
			to_chat(user, span_warning("You need one length of cable to repair [src]!"))
			return
		to_chat(user, span_notice("You begin to replace the wires..."))
		if(do_after(user, 30, target = src))
			if(coil.get_amount() < 1)
				return
			coil.use(1)
			atom_integrity = max_integrity
			set_machine_stat(machine_stat & ~BROKEN)
			to_chat(user, span_notice("You repair \the [src]."))
			update_appearance()

	else if(W.GetID())
		if(allowed(user) && !(obj_flags & EMAGGED))
			locked = !locked
			to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the controls."))
		else if(obj_flags & EMAGGED)
			to_chat(user, span_danger("Error, access controller damaged!"))
		else
			to_chat(user, span_danger("Access denied."))

	else
		return ..()

/obj/machinery/shieldgen/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("The access controller is damaged!"))
		return
	obj_flags |= EMAGGED
	locked = FALSE
	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	to_chat(user, span_warning("You short out the access controller."))

/obj/machinery/shieldgen/update_icon_state()
	icon_state = "shield[active ? "on" : "off"][(machine_stat & BROKEN) ? "br" : null]"
	return ..()

#define ACTIVE_SETUPFIELDS 1
#define ACTIVE_HASFIELDS 2
/obj/machinery/power/shieldwallgen
	name = "shield wall generator"
	desc = "A shield generator."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "shield_wall_gen"
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_TELEPORTER)
	flags_1 = CONDUCT_1
	use_power = NO_POWER_USE
	max_integrity = 300
	var/active = FALSE
	var/locked = TRUE
	var/shield_range = 8
	var/obj/structure/cable/attached // the attached cable

/obj/machinery/power/shieldwallgen/xenobiologyaccess //use in xenobiology containment
	name = "xenobiology shield wall generator"
	desc = "A shield generator meant for use in xenobiology."
	req_access = list(ACCESS_XENOBIOLOGY)

/obj/machinery/power/shieldwallgen/anchored
	anchored = TRUE

/obj/machinery/power/shieldwallgen/unlocked //for use in ruins, etc
	locked = FALSE
	req_access = null

/obj/machinery/power/shieldwallgen/unlocked/anchored
	anchored = TRUE

/obj/machinery/power/shieldwallgen/Initialize(mapload)
	. = ..()
	if(anchored)
		connect_to_network()
	RegisterSignal(src, COMSIG_ATOM_SINGULARITY_TRY_MOVE, PROC_REF(block_singularity_if_active))

/obj/machinery/power/shieldwallgen/Destroy()
	for(var/d in GLOB.cardinals)
		cleanup_field(d)
	return ..()

/obj/machinery/power/shieldwallgen/should_have_node()
	return anchored

/obj/machinery/power/shieldwallgen/connect_to_network()
	if(!anchored)
		return FALSE
	. = ..()

/obj/machinery/power/shieldwallgen/process()
	if(active)
		icon_state = "shield_wall_gen_on"
		if(active == ACTIVE_SETUPFIELDS)
			var/fields = 0
			for(var/d in GLOB.cardinals)
				if(setup_field(d))
					fields++
			if(fields)
				active = ACTIVE_HASFIELDS
		if(!active_power_usage || surplus() >= active_power_usage)
			add_load(active_power_usage)
		else
			visible_message(span_danger("The [src.name] shuts down due to lack of power!"), \
				"If this message is ever seen, something is wrong.",
				span_hear("You hear heavy droning fade out."))
			icon_state = "shield_wall_gen"
			active = FALSE
			log_game("[src] deactivated due to lack of power at [AREACOORD(src)]")
			for(var/d in GLOB.cardinals)
				cleanup_field(d)
	else
		icon_state = "shield_wall_gen"
		for(var/d in GLOB.cardinals)
			cleanup_field(d)

/// Constructs the actual field walls in the specified direction, cleans up old/stuck shields before doing so
/obj/machinery/power/shieldwallgen/proc/setup_field(direction)
	if(!direction)
		return

	var/turf/T = loc
	var/obj/machinery/power/shieldwallgen/G
	var/steps = 0
	var/opposite_direction = turn(direction, 180)

	for(var/i in 1 to shield_range) //checks out to 8 tiles away for another generator
		T = get_step(T, direction)
		G = locate(/obj/machinery/power/shieldwallgen) in T
		if(G)
			if(!G.active)
				return
			G.cleanup_field(opposite_direction)
			break
		else
			steps++

	if(!G || !steps) //no shield gen or no tiles between us and the gen
		return

	for(var/i in 1 to steps) //creates each field tile
		T = get_step(T, opposite_direction)
		new/obj/machinery/shieldwall(T, src, G)
	return TRUE

/// cleans up fields in the specified direction if they belong to this generator
/obj/machinery/power/shieldwallgen/proc/cleanup_field(direction)
	var/obj/machinery/shieldwall/F
	var/obj/machinery/power/shieldwallgen/G
	var/turf/T = loc

	for(var/i in 1 to shield_range)
		T = get_step(T, direction)

		G = (locate(/obj/machinery/power/shieldwallgen) in T)
		if(G && !G.active)
			break

		F = (locate(/obj/machinery/shieldwall) in T)
		if(F && (F.gen_primary == src || F.gen_secondary == src)) //it's ours, kill it.
			qdel(F)

/obj/machinery/power/shieldwallgen/proc/block_singularity_if_active()
	SIGNAL_HANDLER

	if (active)
		return SINGULARITY_TRY_MOVE_BLOCK

/obj/machinery/power/shieldwallgen/can_be_unfasten_wrench(mob/user, silent)
	if(active)
		if(!silent)
			to_chat(user, span_warning("Turn off the shield generator first!"))
		return FAILED_UNFASTEN
	return ..()


/obj/machinery/power/shieldwallgen/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	. |= default_unfasten_wrench(user, tool, time = 0)
	var/turf/T = get_turf(src)
	update_cable_icons_on_turf(T)
	if(. == SUCCESSFUL_UNFASTEN && anchored)
		connect_to_network()


/obj/machinery/power/shieldwallgen/attackby(obj/item/W, mob/user, params)
	if(W.GetID())
		if(allowed(user) && !(obj_flags & EMAGGED))
			locked = !locked
			to_chat(user, span_notice("You [src.locked ? "lock" : "unlock"] the controls."))
		else if(obj_flags & EMAGGED)
			to_chat(user, span_danger("Error, access controller damaged!"))
		else
			to_chat(user, span_danger("Access denied."))

	else
		add_fingerprint(user)
		return ..()

/obj/machinery/power/shieldwallgen/interact(mob/user)
	. = ..()
	if(.)
		return
	if(!anchored)
		to_chat(user, span_warning("\The [src] needs to be firmly secured to the floor first!"))
		return
	if(locked && !issilicon(user))
		to_chat(user, span_warning("The controls are locked!"))
		return
	if(!powernet)
		to_chat(user, span_warning("\The [src] needs to be powered by a wire!"))
		return

	if(active)
		user.visible_message(span_notice("[user] turned \the [src] off."), \
			span_notice("You turn off \the [src]."), \
			span_hear("You hear heavy droning fade out."))
		active = FALSE
		user.log_message("deactivated [src].", LOG_GAME)
	else
		user.visible_message(span_notice("[user] turned \the [src] on."), \
			span_notice("You turn on \the [src]."), \
			span_hear("You hear heavy droning."))
		active = ACTIVE_SETUPFIELDS
		user.log_message("activated [src].", LOG_GAME)
	add_fingerprint(user)

/obj/machinery/power/shieldwallgen/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("The access controller is damaged!"))
		return
	obj_flags |= EMAGGED
	locked = FALSE
	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	to_chat(user, span_warning("You short out the access controller."))

//////////////Containment Field START
/obj/machinery/shieldwall
	name = "shield wall"
	desc = "An energy shield."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldwall"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_range = 3
	var/needs_power = FALSE
	var/obj/machinery/power/shieldwallgen/gen_primary
	var/obj/machinery/power/shieldwallgen/gen_secondary

/obj/machinery/shieldwall/Initialize(mapload, obj/machinery/power/shieldwallgen/first_gen, obj/machinery/power/shieldwallgen/second_gen)
	. = ..()
	gen_primary = first_gen
	gen_secondary = second_gen
	if(gen_primary && gen_secondary)
		needs_power = TRUE
		setDir(get_dir(gen_primary, gen_secondary))
	for(var/mob/living/L in get_turf(src))
		visible_message(span_danger("\The [src] is suddenly occupying the same space as \the [L]!"))
		L.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
		L.gib()
	RegisterSignal(src, COMSIG_ATOM_SINGULARITY_TRY_MOVE, PROC_REF(block_singularity))

/obj/machinery/shieldwall/Destroy()
	gen_primary = null
	gen_secondary = null
	return ..()

/obj/machinery/shieldwall/process()
	if(needs_power)
		if(!gen_primary || !gen_primary.active || !gen_secondary || !gen_secondary.active)
			qdel(src)
			return

		drain_power(10)

/obj/machinery/shieldwall/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BURN)
			playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)
		if(BRUTE)
			playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)

//the shield wall is immune to damage but it drains the stored power of the generators.
/obj/machinery/shieldwall/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(damage_type == BRUTE || damage_type == BURN)
		drain_power(damage_amount)

/// succs power from the connected shield wall generator
/obj/machinery/shieldwall/proc/drain_power(drain_amount)
	if(needs_power && gen_primary)
		gen_primary.add_load(drain_amount * 0.5)
		if(gen_secondary) //using power may cause us to be destroyed
			gen_secondary.add_load(drain_amount * 0.5)

/obj/machinery/shieldwall/proc/block_singularity()
	SIGNAL_HANDLER

	return SINGULARITY_TRY_MOVE_BLOCK

/obj/machinery/shieldwall/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover) && (mover.pass_flags & PASSGLASS))
		return prob(20)
	else
		if(isprojectile(mover))
			return prob(10)

#undef ACTIVE_SETUPFIELDS
#undef ACTIVE_HASFIELDS

//Modular Shield Generator Start
/obj/machinery/modular_shield_generator
	name = "Modular Shield Generator"
	desc = "A forcefield generator, it seems more stationary than its cousins."
	icon = 'icons/obj/machines/modular_shield_generator.dmi'
	icon_state = "gen_recovering_closed"
	density = TRUE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.5
	circuit = /obj/item/circuitboard/machine/modular_shield_generator
	processing_flags = START_PROCESSING_ON_INIT

	///Doesnt actually control it, just tells us if its running or not, you can control by calling procs activate_shields and deactivate_shields
	var/active = FALSE

	///Determins if we can turn it on or not, no longer recovering when back to max strength
	var/recovering = TRUE

	///Determins max health of the shield
	var/max_strength = 40

	///Current health of shield
	var/stored_strength = 0 //starts at 0 to prevent rebuild abuse

	///Shield Regeneration when at 100% efficiency
	var/max_regeneration = 3

	///The regeneration that the shield can support
	var/current_regeneration

	///Determins the max radius the shield can support
	var/max_radius = 3

	///Current radius the shield is set to, minimum 3
	var/radius = 3

	///Determins if we only generate a shield on space turfs or not
	var/exterior_only = FALSE

	///The list of shields that are ours
	var/list/deployed_shields = list()

	///The list of turfs that are within the shield
	var/list/inside_shield = list()

	///The list of machines that are connected to and boosting us
	var/list/obj/machinery/modular_shield/module/connected_modules = list()

	///Regeneration gained from machines connected to us
	var/regen_boost = 0

	///Max Radius gained from machines connected to us
	var/radius_boost = 0

	///Max Strength gained from machines connected to us
	var/max_strength_boost = 0

	///Regeneration gained from our own parts
	var/innate_regen

	///Max radius gained from our own parts
	var/innate_radius

	///Max strength gained from our own parts
	var/innate_strength

	///This is the list of perimeter turfs that we grab when making large shields of 10 or more radius
	var/list/list_of_turfs = list()

/obj/machinery/modular_shield_generator/power_change()
	. = ..()
	if(!(machine_stat & NOPOWER))
		begin_processing()
		return

	deactivate_shields()
	end_processing()

/obj/machinery/modular_shield_generator/RefreshParts()
	. = ..()

	innate_regen = 3
	innate_radius = 3
	innate_strength = 40

	for(var/datum/stock_part/capacitor/new_capacitor in component_parts)
		innate_strength += new_capacitor.tier * 10

	for(var/datum/stock_part/servo/new_servo in component_parts)
		innate_regen += new_servo.tier

	for(var/datum/stock_part/micro_laser/new_laser in component_parts)
		innate_radius += new_laser.tier * 0.25

	calculate_regeneration()
	calculate_max_strength()
	calculate_radius()


/obj/machinery/modular_shield_generator/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/modular_shield_generator(src)
	if(mapload && active && anchored)
		activate_shields()

/datum/wires/modular_shield_generator
	proper_name = "Modular shield generator"
	randomize = FALSE
	holder_type = /obj/machinery/modular_shield_generator

/datum/wires/modular_shield_generator/New(atom/holder)
	wires = list(WIRE_HACK)
	..()

/datum/wires/modular_shield_generator/on_pulse(wire)

	var/obj/machinery/modular_shield_generator/shield_gen = holder
	switch(wire)
		if(WIRE_HACK)
			shield_gen.toggle_shields()
			return
	..()

///qdels the forcefield and calls calculate regen to update the regen value accordingly
/obj/machinery/modular_shield_generator/proc/deactivate_shields()
	active = FALSE
	QDEL_LIST(deployed_shields)
	calculate_regeneration()

/obj/machinery/modular_shield_generator/attackby(obj/item/W, mob/user, params)

	if(default_deconstruction_screwdriver(user,"gen_[!(machine_stat & NOPOWER) ? "[recovering ? "recovering_" : "ready_"]" : "no_power_"]open",
		"gen_[!(machine_stat & NOPOWER) ? "[recovering ? "recovering_" : "ready_"]" : "no_power_"]closed",  W))
		return

	if(default_deconstruction_crowbar(W) && !(active) && !(recovering))
		return

	if(is_wire_tool(W) && panel_open)
		wires.interact(user)
		return

	return ..()

///toggles the forcefield on and off
/obj/machinery/modular_shield_generator/proc/toggle_shields()
	if(active)
		deactivate_shields()
		return
	if (recovering)
		return
	activate_shields()


///generates the forcefield based on the given radius and calls calculate_regen to update the regen value accordingly
/obj/machinery/modular_shield_generator/proc/activate_shields()
	if(active) //bug or did admin call proc on already active shield gen?
		return
	if(radius < 0)//what the fuck are admins doing
		radius = initial(radius)
	active = TRUE

	if(radius >= 10) //the shield is large so we are going to use the midpoint formula and clamp it to the lowest full number in order to save processing power
		var/fradius = round(radius)
		var/list/inside_shield = circle_range_turfs(src, fradius - 1)//in the future we might want to apply an effect to turfs inside the shield
		var/t1 = fradius/16
		var/dx = fradius
		var/dy = 0
		var/t2
		var/list/list_of_turfs = list()
		while(dx >= dy)
			list_of_turfs += locate(x + dx, y + dy, z)
			list_of_turfs += locate(x - dx, y + dy, z)
			list_of_turfs += locate(x + dx, y - dy, z)
			list_of_turfs += locate(x - dx, y - dy, z)
			list_of_turfs += locate(x + dy, y + dx, z)
			list_of_turfs += locate(x - dy, y + dx, z)
			list_of_turfs += locate(x + dy, y - dx, z)
			list_of_turfs += locate(x - dy, y - dx, z)
			dy += 1
			t1 += dy
			t2 = t1 - dx
			if(t2 > 0)
				t1 = t2
				dx -= 1

		if(exterior_only)
			for(var/turf/target_tile as anything in list_of_turfs)
				if (!(target_tile in inside_shield) && isspaceturf(target_tile) && !(locate(/obj/structure/emergency_shield/modular) in target_tile))
					var/obj/structure/emergency_shield/modular/deploying_shield = new(target_tile)
					deploying_shield.shield_generator = src
					deployed_shields += deploying_shield
			calculate_regeneration()
			active_power_usage += deployed_shields.len * BASE_MACHINE_ACTIVE_CONSUMPTION * 0.1
			return

		for(var/turf/target_tile as anything in list_of_turfs)
			if (!(target_tile in inside_shield) && isopenturf(target_tile) && !(locate(/obj/structure/emergency_shield/modular) in target_tile))
				var/obj/structure/emergency_shield/modular/deploying_shield = new(target_tile)
				deploying_shield.shield_generator = src
				deployed_shields += deploying_shield
		calculate_regeneration()
		active_power_usage += deployed_shields.len * BASE_MACHINE_ACTIVE_CONSUMPTION * 0.1
		return

	//this code only runs on radius less than 10 and gives us a more accurate circle that is more compatible with decimal values
	var/list/inside_shield = circle_range_turfs(src, radius - 1)//in the future we might want to apply an effect to the turfs inside the shield
	if(exterior_only)
		for(var/turf/target_tile as anything in circle_range_turfs(src, radius))
			if (!(target_tile in inside_shield) && isspaceturf(target_tile) && !(locate(/obj/structure/emergency_shield/modular) in target_tile))
				var/obj/structure/emergency_shield/modular/deploying_shield = new(target_tile)
				deploying_shield.shield_generator = src
				deployed_shields += deploying_shield
		calculate_regeneration()
		active_power_usage += deployed_shields.len * BASE_MACHINE_ACTIVE_CONSUMPTION * 0.1
		return

	for(var/turf/target_tile as anything in circle_range_turfs(src, radius))
		if (!(target_tile in inside_shield) && isopenturf(target_tile) && !(locate(/obj/structure/emergency_shield/modular) in target_tile))
			var/obj/structure/emergency_shield/modular/deploying_shield = new(target_tile)
			deploying_shield.shield_generator = src
			deployed_shields += deploying_shield
	calculate_regeneration()
	active_power_usage += deployed_shields.len * BASE_MACHINE_ACTIVE_CONSUMPTION * 0.1



/obj/machinery/modular_shield_generator/Destroy()
	QDEL_LIST(deployed_shields)
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.5
	return ..()

/obj/machinery/modular_shield_generator/update_icon_state()

	icon_state = ("gen_[!(machine_stat & NOPOWER)?"[recovering ?"recovering_":"ready_"]":"no_power_"][(panel_open)?"open":"closed"]")
	return ..()

//ui stuff
/obj/machinery/modular_shield_generator/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ModularShieldGen")
		ui.open()

/obj/machinery/modular_shield_generator/ui_data(mob/user)

	var/list/data = list()
	data["max_radius"] = max_radius
	data["current_radius"] = radius
	data["max_strength"] = max_strength
	data["max_regeneration"] = max_regeneration
	data["current_regeneration"] = current_regeneration
	data["current_strength"] = stored_strength
	data["active"] = active
	data["recovering"] = recovering
	data["exterior_only"] = exterior_only
	return data

/obj/machinery/modular_shield_generator/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if ("set_radius")
			if (active)
				return
			var/change_radius = max(1,(text2num(params["new_radius"])))
			if(change_radius >= 10)
				radius = round(change_radius)//if its over 10 we dont allow decimals
				return
			radius = change_radius

		if ("toggle_shields")
			toggle_shields()

		if ("toggle_exterior")
			exterior_only = !exterior_only


///calculations for the stats supplied by the network of machines that boost us
/obj/machinery/modular_shield_generator/proc/calculate_boost()

	regen_boost = initial(regen_boost)
	for (var/obj/machinery/modular_shield/module/charger/new_charger in connected_modules)
		regen_boost += new_charger.charge_boost

	calculate_regeneration()

	max_strength_boost = initial(max_strength_boost)
	for (var/obj/machinery/modular_shield/module/well/new_well in connected_modules)
		max_strength_boost += new_well.strength_boost

	calculate_max_strength()

	radius_boost = initial(radius_boost)
	for (var/obj/machinery/modular_shield/module/relay/new_relay in connected_modules)
		radius_boost += new_relay.range_boost

	calculate_radius()

///Calculates the max radius the shield generator can support, modifiers go here
/obj/machinery/modular_shield_generator/proc/calculate_radius()

	max_radius = innate_radius + radius_boost

	if(radius > max_radius)//the generator can no longer function at this capacity
		deactivate_shields()
		radius = max_radius

///Calculates the max strength or health of the forcefield, modifiers go here
/obj/machinery/modular_shield_generator/proc/calculate_max_strength()

	max_strength = innate_strength + max_strength_boost
	begin_processing()

///Calculates the regeneration based on the status of the generator and boosts from network, modifiers go here
/obj/machinery/modular_shield_generator/proc/calculate_regeneration()

	max_regeneration = innate_regen + regen_boost

	if(!active)
		if(recovering)
			current_regeneration = max_regeneration * 0.25
			return
		current_regeneration = max_regeneration
		return

	//we lose more than half the regeneration rate when generating a shield that is near the max
	//radius that we can handle but if we generate a shield with a very small fraction
	//of the max radius we can support we get a very small bonus multiplier
	current_regeneration = (max_regeneration / (0.5 + (radius * 2)/max_radius))

	if(!exterior_only)
		current_regeneration *=0.5

///Reduces the strength of the shield based on the given integer
/obj/machinery/modular_shield_generator/proc/shield_drain(damage_amount)
	stored_strength -= damage_amount
	begin_processing()
	if (stored_strength < 5)
		recovering = TRUE
		deactivate_shields()
		stored_strength = 0
		update_icon_state()

/obj/machinery/modular_shield_generator/process(seconds_per_tick)
	stored_strength = min((stored_strength + (current_regeneration * seconds_per_tick)),max_strength)
	if(stored_strength == max_strength)
		if (recovering)
			recovering = FALSE
			calculate_regeneration()
			update_icon_state()
		end_processing() //we dont care about continuing to update the alpha, we want to show history of damage to show its unstable
	if (active)
		var/random_num = rand(1,deployed_shields.len)
		var/obj/structure/emergency_shield/modular/random_shield = deployed_shields[random_num]
		random_shield.alpha = max(255 * (stored_strength/max_strength), 40)



//Start of other machines
///The general code used for machines that want to connect to the network
/obj/machinery/modular_shield/module

	name = "Modular Shield Debugger" //Filler name and sprite for testing
	desc = "This is filler for testing you shouldn`t see this."
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_port"
	density = TRUE

	///The shield generator we are connected to if we find one or a node provides us one
	var/obj/machinery/modular_shield_generator/shield_generator

	///The node we are connected to if we find one
	var/obj/machinery/modular_shield/module/node/connected_node

	///This is the turf that we are facing and able to search for connections through
	var/turf/connected_turf

/obj/machinery/modular_shield/module/Initialize(mapload)
	. = ..()

	connected_turf = get_step(loc, dir)

/obj/machinery/modular_shield/module/Destroy()

	if(shield_generator)
		shield_generator.connected_modules -= (src)
		shield_generator.calculate_boost()
	if(connected_node)
		connected_node.connected_through_us -= (src)
	return ..()

/obj/machinery/modular_shield/module/attackby(obj/item/I, mob/user, params)

	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		panel_open = !(panel_open)
		I.play_tool_sound(src, 50)
		update_icon_state()
		if(panel_open)
			to_chat(user, span_notice("You open the maintenance hatch of [src]."))
			return TRUE
		to_chat(user, span_notice("You close the maintenance hatch of [src]."))
		return TRUE

	//rather than automatically checking for connections its probably alot less
	//expensive to just make the players manually multi tool sync each part
	if(I.tool_behaviour == TOOL_MULTITOOL)
		try_connect(user)
		return

	if(default_change_direction_wrench(user, I))
		if(shield_generator)
			shield_generator.connected_modules -= (src)
			shield_generator.calculate_boost()
			shield_generator = null
			update_icon_state()
		if(connected_node)
			connected_node.connected_through_us -= (src)
			connected_node = null
		connected_turf = get_step(loc, dir)
		return TRUE

	if(default_deconstruction_crowbar(I))
		return TRUE
	return..()

/obj/machinery/modular_shield/module/setDir(new_dir)
	. = ..()
	connected_turf = get_step(loc, dir)

/obj/machinery/modular_shield/module/proc/try_connect(user)

	if(shield_generator || connected_node)
		balloon_alert(user, "already connected to something")
		return

	shield_generator = (locate(/obj/machinery/modular_shield_generator) in connected_turf)

	if(shield_generator)

		shield_generator.connected_modules |= (src)
		balloon_alert(user, "connected to generator")
		update_icon_state()
		if(istype(src, /obj/machinery/modular_shield/module/node))
			var/obj/machinery/modular_shield/module/node/connected_node = src
			connected_node.connect_connected_through_us()
		shield_generator.calculate_boost()
		return

	connected_node	= (locate(/obj/machinery/modular_shield/module/node) in connected_turf)

	if(connected_node)

		connected_node.connected_through_us |= (src)
		shield_generator = connected_node.shield_generator
		if(shield_generator)
			shield_generator.connected_modules |= (src)
			balloon_alert(user, "connected to generator through node")
			update_icon_state()
			if(istype(src, /obj/machinery/modular_shield/module/node))
				var/obj/machinery/modular_shield/module/node/connected_node = src
				connected_node.connect_connected_through_us()
			shield_generator.calculate_boost()
			return
		balloon_alert(user, "connected to node")
		return
	balloon_alert(user, "failed to find connection!")



/obj/machinery/modular_shield/module/node

	name = "Modular Shield Node"
	desc = "A waist high mess of humming pipes and wires that extend the modular shield network."
	icon = 'icons/obj/machines/modular_shield_generator.dmi'
	icon_state = "node_off_closed"
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.5
	circuit = /obj/item/circuitboard/machine/modular_shield_node
	///The list of machines that are connected to us and want connection to a generator
	var/list/connected_through_us = list()

/obj/machinery/modular_shield/module/node/update_icon_state()
	. = ..()
	if(isnull(shield_generator) || (machine_stat & NOPOWER))
		icon_state = "node_off_[panel_open ?"open":"closed"]"
		return
	icon_state = "node_on_[panel_open ?"open":"closed"]"

/obj/machinery/modular_shield/module/node/setDir(new_dir)
	. = ..()

	disconnect_connected_through_us()
	if(isnull(shield_generator))
		return
	shield_generator.connected_modules -= (src)
	shield_generator.calculate_boost()
	shield_generator = null
	update_icon_state()

/obj/machinery/modular_shield/module/node/Destroy()
	. = ..()

	disconnect_connected_through_us()
	for(var/obj/machinery/modular_shield/module/connected in connected_through_us)
		connected.connected_node = null
	if(shield_generator)
		shield_generator.calculate_boost()

///If we are connected to a shield generator this proc will connect anything connected to us to that generator
/obj/machinery/modular_shield/module/node/proc/connect_connected_through_us()

	if(shield_generator)
		for(var/obj/machinery/modular_shield/module/connected in connected_through_us)
			shield_generator.connected_modules |= connected
			connected.shield_generator = shield_generator
			if(istype(connected, /obj/machinery/modular_shield/module/node))
				var/obj/machinery/modular_shield/module/node/connected_node = connected
				connected_node.connect_connected_through_us()
			connected.update_icon_state()


///This proc disconnects modules connected through us from the shield generator in the event that we lose connection
/obj/machinery/modular_shield/module/node/proc/disconnect_connected_through_us()

	for(var/obj/machinery/modular_shield/module/connected in connected_through_us)
		shield_generator.connected_modules -= connected
		if(istype(connected, /obj/machinery/modular_shield/module/node))
			var/obj/machinery/modular_shield/module/node/connected_node = connected
			connected_node.disconnect_connected_through_us()
		connected.shield_generator = null
		connected.update_icon_state()

/obj/machinery/modular_shield/module/charger

	name = "Modular Shield Charger"
	desc = "A machine that somehow fabricates hardlight using electrons."
	icon = 'icons/obj/machines/modular_shield_generator.dmi'
	icon_state = "charger_off_closed"

	circuit = /obj/item/circuitboard/machine/modular_shield_charger

	///Amount of regeneration this machine grants the connected generator
	var/charge_boost = 0

/obj/machinery/modular_shield/module/charger/update_icon_state()
	. = ..()
	if(isnull(shield_generator) || (machine_stat & NOPOWER))
		icon_state = "charger_off_[panel_open ?"open":"closed"]"
		return
	icon_state = "charger_on_[panel_open ?"open":"closed"]"

/obj/machinery/modular_shield/module/charger/RefreshParts()
	. = ..()
	charge_boost = initial(charge_boost)
	for(var/datum/stock_part/servo/new_servo in component_parts)
		charge_boost += new_servo.tier

	if(shield_generator)
		shield_generator.calculate_boost()

/obj/machinery/modular_shield/module/relay

	name = "Modular Shield Relay"
	desc = "It helps the shield generator project farther out."
	icon = 'icons/obj/machines/modular_shield_generator.dmi'
	icon_state = "relay_off_closed"

	circuit = /obj/item/circuitboard/machine/modular_shield_relay

	///Amount of max range this machine grants the connected generator
	var/range_boost = 0

/obj/machinery/modular_shield/module/relay/update_icon_state()
	. = ..()
	if(isnull(shield_generator) || (machine_stat & NOPOWER))
		icon_state = "relay_off_[panel_open ?"open":"closed"]"
		return
	icon_state = "relay_on_[panel_open ?"open":"closed"]"

/obj/machinery/modular_shield/module/relay/RefreshParts()
	. = ..()
	range_boost = initial(range_boost)
	for(var/datum/stock_part/micro_laser/new_laser in component_parts)
		range_boost += new_laser.tier * 0.25

	if(shield_generator)
		shield_generator.calculate_boost()

/obj/machinery/modular_shield/module/well

	name = "Modular Shield Well"
	desc = "A device used to hold more hardlight for the modular shield generator."
	icon = 'icons/obj/machines/modular_shield_generator.dmi'
	icon_state = "well_off_closed"

	circuit = /obj/item/circuitboard/machine/modular_shield_well

	///Amount of max strength this machine grants the connected generator
	var/strength_boost = 0

/obj/machinery/modular_shield/module/well/RefreshParts()
	. = ..()
	strength_boost = initial(strength_boost)
	for(var/datum/stock_part/capacitor/new_capacitor in component_parts)
		strength_boost += new_capacitor.tier * 10

	if(shield_generator)
		shield_generator.calculate_boost()

/obj/machinery/modular_shield/module/well/update_icon_state()
	. = ..()
	if(isnull(shield_generator) || (machine_stat & NOPOWER))
		icon_state = "well_off_[panel_open ?"open":"closed"]"
		return
	icon_state = "well_on_[panel_open ?"open":"closed"]"


//The shield itself
/obj/structure/emergency_shield/modular
	name = "Modular energy shield"
	desc = "An energy shield with varying configurations."
	color = "#00ffff"
	resistance_flags = INDESTRUCTIBLE //the shield itself is indestructible or atleast should be
	//our parent
	var/obj/machinery/modular_shield_generator/shield_generator


/obj/structure/emergency_shield/modular/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive, mapload)

/obj/structure/emergency_shield/modular/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > (T0C + 400) //starts taking damage from high temps at the same temperature that nonreinforced glass does

/obj/structure/emergency_shield/modular/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	if(isnull(shield_generator))
		qdel(src)
		return

	shield_generator.shield_drain(round(air.return_volume() / 400))//400 integer determines how much damage the shield takes from hot atmos (higher value = less damage)


//How the shield loses strength
/obj/structure/emergency_shield/modular/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(damage_type == BRUTE || damage_type == BURN)
		if(isnull(shield_generator))
			qdel(src)
			return

		shield_generator.shield_drain(damage_amount)//can add or subtract a flat value to buff or nerf crowd damage

/obj/structure/emergency_shield/modular/emp_act(severity)
	if(isnull(shield_generator))
		qdel(src)
		return

	shield_generator.shield_drain(15 / severity) //Light is 2 heavy is 1, note emp is usually a large aoe, tweak the number if not enough damage
