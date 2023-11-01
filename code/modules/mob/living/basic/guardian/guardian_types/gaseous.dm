/// Not particularly resistant, but versatile due to the selection of gases it can generate.
/mob/living/basic/guardian/gaseous
	guardian_type = GUARDIAN_GASEOUS
	melee_damage_lower = 10
	melee_damage_upper = 10
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 0)
	range = 7
	playstyle_string = span_holoparasite("As a <b>gaseous</b> type, you have only light damage resistance, but you can expel gas in an area. In addition, your punches cause sparks, and you make your summoner inflammable.")
	creator_name = "Gaseous"
	creator_desc = "Creates sparks on touch and continuously expels a gas of its choice. Automatically extinguishes the user if they catch on fire."
	creator_icon = "gaseous"
	toggle_button_type = /atom/movable/screen/guardian/toggle_mode/gases
	/// Ability we use to select gases
	var/datum/action/cooldown/mob_cooldown/expel_gas/gas
	/// Rate of temperature stabilization per second.
	var/temp_stabilization_rate = 0.1

/mob/living/basic/guardian/gaseous/Initialize(mapload, theme)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_PRE_PRESSURE_PUSH, PROC_REF(pre_pressure_moved))
	gas = new(src)
	gas.owner_has_control = FALSE // It's nicely integrated with the Guardian UI, no need to have two buttons
	gas.Grant(src)

/mob/living/basic/guardian/gaseous/Destroy()
	QDEL_NULL(gas)
	return ..()

/mob/living/basic/guardian/gaseous/toggle_modes()
	gas.Trigger()

/mob/living/basic/guardian/gaseous/Life(seconds_per_tick, times_fired)
	. = ..()
	if (isnull(summoner))
		return
	summoner.extinguish_mob()
	summoner.set_fire_stacks(0, remove_wet_stacks = FALSE)
	summoner.adjust_bodytemperature(get_temp_change_amount((summoner.get_body_temp_normal() - summoner.bodytemperature), temp_stabilization_rate * seconds_per_tick))

/mob/living/basic/guardian/gaseous/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!. || !isliving(target))
		return
	do_sparks(1, TRUE, target)

/mob/living/basic/guardian/gaseous/recall_effects()
	. = ..()
	if(!isnull(summoner))
		UnregisterSignal(summoner, COMSIG_ATOM_PRE_PRESSURE_PUSH)

/mob/living/basic/guardian/gaseous/manifest_effects()
	. = ..()
	if (!isnull(summoner))
		RegisterSignal(summoner, COMSIG_ATOM_PRE_PRESSURE_PUSH, PROC_REF(pre_pressure_moved))

/// We stand firm in the face of gas
/mob/living/basic/guardian/gaseous/proc/pre_pressure_moved(datum/source)
	SIGNAL_HANDLER
	return COMSIG_ATOM_BLOCKS_PRESSURE


/// Expel a range of gases
/datum/action/cooldown/mob_cooldown/expel_gas
	name = "Release Gas"
	desc = "Start or stop expelling a selected gas into the environment."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "smoke"
	cooldown_time = 0 SECONDS // We're here for the interface not the cooldown
	melee_cooldown_time = 0 SECONDS
	click_to_activate = FALSE
	/// Gas being expelled.
	var/active_gas = null
	/// Associative list of types of gases to moles we create every life tick.
	var/static/list/possible_gases = list(
		/datum/gas/oxygen = 50,
		/datum/gas/nitrogen = 750, //overpressurizing is hard!.
		/datum/gas/water_vapor = 1, //you need incredibly little water vapor for the effects to kick in
		/datum/gas/nitrous_oxide = 15,
		/datum/gas/carbon_dioxide = 50,
		/datum/gas/plasma = 3,
		/datum/gas/bz = 10,
	)
	/// Associative list of types of gases to particle effect colour.
	var/static/list/gas_colors = list(
		/datum/gas/oxygen = "#63BFDD", //color of frozen oxygen
		/datum/gas/nitrogen = "#777777", //grey (grey)
		/datum/gas/water_vapor = "#96ADCF", //water is slightly blue
		/datum/gas/nitrous_oxide = "#FEFEFE", //white like the sprite
		/datum/gas/carbon_dioxide = "#222222", //black like coal
		/datum/gas/plasma = "#B233CC", //color of the plasma sprite
		/datum/gas/bz = "#FAFF00", //color of the bz metabolites reagent
	)

/datum/action/cooldown/mob_cooldown/expel_gas/Grant(mob/granted_to)
	. = ..()
	if (isnull(owner))
		return
	RegisterSignal(owner, COMSIG_GUARDIAN_RECALLED, PROC_REF(stop_gas))

/datum/action/cooldown/mob_cooldown/expel_gas/Remove(mob/removed_from)
	. = ..()
	UnregisterSignal(owner, list(COMSIG_GUARDIAN_RECALLED, COMSIG_LIVING_LIFE))

/datum/action/cooldown/mob_cooldown/expel_gas/Activate(atom/target)
	// Regeneated each time just in case someone fucks with our list
	var/list/gas_selection = list("None")
	for(var/datum/gas/gas as anything in possible_gases)
		gas_selection[initial(gas.name)] = gas

	var/picked_gas = tgui_input_list(src, "Select a gas to emit.", "Gas Producer", gas_selection)
	if(picked_gas == "None")
		stop_gas()
		return

	var/gas_type = gas_selection[picked_gas]
	if(isnull(picked_gas) || isnull(gas_type))
		return
	to_chat(owner, span_bolddanger("You start releasing [picked_gas]."))
	owner.investigate_log("set their gas type to [picked_gas].", INVESTIGATE_ATMOS)
	active_gas = gas_type
	if(!owner.particles)
		owner.particles = new /particles/smoke/steam()
		owner.particles.position = list(-1, 8, 0)
		owner.particles.fadein = 5
		owner.particles.height = 200
	owner.particles.color = gas_colors[gas_type]
	RegisterSignal(owner, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/// Turns off the gas
/datum/action/cooldown/mob_cooldown/expel_gas/proc/stop_gas()
	SIGNAL_HANDLER
	if (!isnull(active_gas))
		to_chat(src, span_notice("You stop releasing gas."))
	active_gas = null
	QDEL_NULL(owner.particles)
	UnregisterSignal(owner, COMSIG_LIVING_LIFE)

/// Release gas every life tick while active
/datum/action/cooldown/mob_cooldown/expel_gas/proc/on_life(datum/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if (isnull(active_gas))
		return // We shouldn't even be registered at this point but just in case
	var/datum/gas_mixture/mix_to_spawn = new()
	mix_to_spawn.add_gas(active_gas)
	mix_to_spawn.gases[active_gas][MOLES] = possible_gases[active_gas] * seconds_per_tick
	mix_to_spawn.temperature = T20C
	var/turf/open/our_turf = get_turf(owner)
	our_turf.assume_air(mix_to_spawn)
