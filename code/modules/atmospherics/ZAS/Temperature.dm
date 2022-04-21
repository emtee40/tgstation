#define MIN_TEMPERATURE_COEFFICIENT 1
#define MAX_TEMPERATURE_COEFFICIENT 10

/atom/var/temperature = T20C
/atom/var/temperature_coefficient = MAX_TEMPERATURE_COEFFICIENT

/atom/movable/Entered(var/atom/movable/atom, var/atom/old_loc)
	. = ..()
	QUEUE_TEMPERATURE_ATOMS(atom)

/obj/temperature_coefficient = null

/mob/temperature_coefficient = null

/turf/temperature_coefficient = MIN_TEMPERATURE_COEFFICIENT

/obj/Initialize()
	. = ..()
	temperature_coefficient = isnull(temperature_coefficient) ? clamp(MAX_TEMPERATURE_COEFFICIENT - w_class, MIN_TEMPERATURE_COEFFICIENT, MAX_TEMPERATURE_COEFFICIENT) : temperature_coefficient

/obj/proc/HandleObjectHeating(var/obj/item/heated_by, var/mob/user, var/adjust_temp)
	if(ATOM_IS_TEMPERATURE_SENSITIVE(src))
		visible_message(span_notice("\The [user] carefully heats \the [src] with \the [heated_by]."))
		var/diff_temp = (adjust_temp - temperature)
		if(diff_temp >= 0)
			var/altered_temp = max(temperature + (ATOM_TEMPERATURE_EQUILIBRIUM_CONSTANT * temperature_coefficient * diff_temp), 0)
			ADJUST_ATOM_TEMPERATURE(src, min(adjust_temp, altered_temp))

/mob/living/Initialize()
	. = ..()
	temperature_coefficient = isnull(temperature_coefficient) ? clamp(MAX_TEMPERATURE_COEFFICIENT - FLOOR(mob_size/4, 1), MIN_TEMPERATURE_COEFFICIENT, MAX_TEMPERATURE_COEFFICIENT) : temperature_coefficient

/atom/proc/process_atmos_exposure()
	// Get our location temperature if possible.
	// Nullspace is room temperature, clearly.
	var/adjust_temp
	var/datum/gas_mixture/local_air
	if(loc)
		if(!loc.simulated)
			adjust_temp = loc.temperature
		else
			//var/turf/simulated/T = loc
			var/turf/T = get_turf(loc)
			if(!istype(T))
				return
			if(T.zone && T.zone.air)
				adjust_temp = T.zone.air.temperature
				SEND_SIGNAL(T, COMSIG_TURF_EXPOSE, T.zone.air, T.zone.air.temperature)
				atmos_expose(T.zone.air, T.zone.air.temperature)
				local_air = T.zone.air
			else
				adjust_temp = T20C
	else
		adjust_temp = T20C

	var/diff_temp = adjust_temp - temperature
	if(abs(diff_temp) >= ATOM_TEMPERATURE_EQUILIBRIUM_THRESHOLD)
		var/altered_temp = max(temperature + (ATOM_TEMPERATURE_EQUILIBRIUM_CONSTANT * temperature_coefficient * diff_temp), 0)
		ADJUST_ATOM_TEMPERATURE(src, (diff_temp > 0) ? min(adjust_temp, altered_temp) : max(adjust_temp, altered_temp))
		var/tempvar = null

	else if(local_air && should_atmos_process(local_air, local_air.temperature))
		return

	else
		temperature = adjust_temp
		flags_1 &= ~ATMOS_IS_PROCESSING_1
		return PROCESS_KILL

#undef MIN_TEMPERATURE_COEFFICIENT
#undef MAX_TEMPERATURE_COEFFICIENT
