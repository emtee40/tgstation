/datum/proximity_monitor/advanced/gravity
	name = "modified gravity zone"
	var/gravity_value = 0
	var/list/modified_turfs = list()

/datum/proximity_monitor/advanced/gravity/setup_field_turf(turf/T)
	. = ..()

	if (!isnull(modified_turfs[T]))
		T.AddElement(/datum/element/forced_gravity, gravity_value)

/datum/proximity_monitor/advanced/gravity/cleanup_field_turf(turf/T)
	. = ..()
	if(isnull(modified_turfs[T]))
		return
	T.RemoveElement(/datum/element/forced_gravity, modified_turfs[T])
	modified_turfs -= T
