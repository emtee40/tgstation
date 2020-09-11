/**
  *
  */
/datum/element/alloy_regen
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	/// The rate of regeneration as a function of maximum integrity.
	var/rate
	/// The objects that are regenerating due to this element.
	var/list/processing = list()
	/// The current stack of objects we are processing.
	var/list/currentrun
	/// Whether we stopped processing early the last tick.
	var/resumed = FALSE


/datum/element/alloy_regen/Attach(obj/target, _rate=0)
	. = ..()
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE
	if(_rate <= 0)
		return ELEMENT_INCOMPATIBLE

	rate = _rate
	RegisterSignal(target, COMSIG_OBJ_TAKE_DAMAGE, .proc/on_take_damage)

/datum/element/alloy_regen/Detach(obj/target)
	UnregisterSignal(target, COMSIG_OBJ_TAKE_DAMAGE)
	processing -= target
	if(!length(processing))
		STOP_PROCESSING(SSobj, src)

/datum/element/alloy_regen/proc/on_take_damage(obj/target, damage_amt)
	if(!damage_amt)
		return
	if(!length(processing))
		START_PROCESSING(SSobj, src)
	processing |= target


/// Handle regenerating attached objects.
/datum/element/alloy_regen/process(delta_time)
	set waitfor = FALSE

	if(!resumed)
		currentrun = processing.Copy()

	resumed = FALSE
	var/list/cached_run = currentrun
	if(!length(cached_run))
		if(!length(processing))
			STOP_PROCESSING(SSobj, src)
			return
		return

	var/cached_rate = rate
	while(length(cached_run))
		var/obj/regen_obj = cached_run[cached_run.len]
		cached_run.len--

		if(QDELETED(regen_obj))
			processing -= regen_obj
			if(!length(processing))
				STOP_PROCESSING(SSobj, src)
				return PROCESS_KILL
			if(CHECK_TICK)
				resumed = TRUE
				return
			continue

		regen_obj.obj_integrity = clamp(regen_obj.obj_integrity + (regen_obj.max_integrity * cached_rate), 0, regen_obj.max_integrity)
		if(regen_obj.obj_integrity == regen_obj.max_integrity)
			processing -= regen_obj
			if(!length(processing))
				STOP_PROCESSING(SSobj, src)
				return PROCESS_KILL

		if(CHECK_TICK)
			resumed = TRUE
			return
