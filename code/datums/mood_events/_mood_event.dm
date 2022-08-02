/datum/mood_event
	/// Description of the mood event
	var/description
	/// The amount the mood will change
	var/mood_change = 0
	/// How long this mood event should last
	var/timeout = 0
	/// Is this mood event hidden on examine
	var/hidden = FALSE
	/// string of what category this mood was added in as
	var/category
	/// Icon state of the unique mood event icon, if applicable
	var/special_screen_obj
	/// if false, it will be an overlay instead
	var/special_screen_replace = TRUE
	/// Owner of this mood event
	var/mob/owner
	/// List of required jobs for this mood event
	var/list/required_job = list()

/datum/mood_event/New(mob/M, ...)
	owner = M
	var/list/params = args.Copy(2)
	if ((length(required_job) > 0) && M.mind && !(M.mind.assigned_role.type in required_job))
		qdel(src)
		return
	add_effects(arglist(params))

/datum/mood_event/Destroy()
	remove_effects()
	owner = null
	return ..()

/datum/mood_event/proc/add_effects(param)
	return

/datum/mood_event/proc/remove_effects()
	return
