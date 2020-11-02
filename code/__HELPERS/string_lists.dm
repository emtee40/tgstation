GLOBAL_LIST_EMPTY(string_lists)

/**
  * Caches lists with non-numeric stringify-able values (text or typepath).
  */
/datum/proc/string_list(list/values)
	var/string_id = values.Join("-")

	. = GLOB.string_lists[string_id]

	if(.)
		return

	return GLOB.string_lists[string_id] = values

///A wrapper for baseturf string lists, for support for non list values, and a stack_trace if we have major issues
/proc/baseturfs_string_list(list/values, turf/baseturf_holder)
	if(!islist(values))
		values = list(values)
	//	return values
	if(length(values) > 10)
		stack_trace("The baseturfs list of [T] at [T.x], [T.y], [T.x] is [length(values)], it should never be this long, investigate. I've set baseturfs to a chasm as a visual queue")
		return string_list(list(/turf/closed/indestructible/baseturfs_ded)) //I want this reported god damn it
	return string_list(values)

/turf/closed/indestructible/baseturfs_ded
	name = "Report this"
	desc = "It looks like base turfs went to the fucking moon, TELL YOUR LOCAL CODER TODAY"
	icon = 'icons/turf/debug.dmi'
	icon_state = "fucked_baseturfs"
