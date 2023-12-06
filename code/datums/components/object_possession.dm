/// Component that allows admins to control any object as if it were a mob.
/datum/component/object_possession
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Stores a reference to the obj that we are currently possessing.
	var/obj/possessed = null
	/// Ref to the screen object that is currently being displayed.
	var/datum/weakref/screen_alert_ref = null
	/**
	  * back up of the real name during admin possession
	  *
	  * When a user possesses an object it's real name is set to the user name and this
	  * stores whatever the real name was previously. When possession ends, the real name
	  * is reset to this value
	  */
	var/stashed_name = null

/datum/component/object_possession/Initialize(obj/target)
	. = ..()
	if(!isobj(target) || !ismob(parent))
		return COMPONENT_INCOMPATIBLE

	if((target.obj_flags & DANGEROUS_POSSESSION) && CONFIG_GET(flag/forbid_singulo_possession))
		to_chat(parent, "[target] is too powerful for you to possess.", confidential = TRUE)
		return COMPONENT_INCOMPATIBLE

	bind_to_new_object(target)

/datum/component/object_possession/Destroy()
	cleanup_object_binding()
	possessed = null
	return ..()

/datum/component/object_possession/InheritComponent(datum/component/object_possession/old_component, i_am_original, obj/target)
	cleanup_object_binding()
	bind_to_new_object(target)
	stashed_name = old_component.stashed_name

/// Binds the mob to the object and sets up the naming and everything
/datum/component/object_possession/proc/bind_to_new_object(obj/target)
	var/mob/user = parent
	ADD_TRAIT(user, TRAIT_CURRENTLY_CONTROLLING_OBJECT, REF(target))

	stashed_name = user.real_name
	possessed = target

	user.forceMove(target)
	user.real_name = target.name
	user.name = target.name
	user.reset_perspective(target)

	target.AddElement(/datum/element/weather_listener, /datum/weather/ash_storm, ZTRAIT_ASHSTORM, GLOB.ash_storm_sounds)

	RegisterSignal(user, COMSIG_MOB_CLIENT_PRE_NON_LIVING_MOVE, PROC_REF(on_move))
	RegisterSignal(user, COMSIG_MOB_GHOSTIZED, PROC_REF(end_possession)) // aghost compatibility

	screen_alert_ref = WEAKREF(user.throw_alert(ALERT_UNPOSSESS_OBJECT, /atom/movable/screen/alert/unpossess_object))

/// Cleans up everything when the admin wants out.
/datum/component/object_possession/proc/cleanup_object_binding()
	var/mob/poltergeist = parent

	possessed.RemoveElement(/datum/element/weather_listener, /datum/weather/ash_storm, ZTRAIT_ASHSTORM, GLOB.ash_storm_sounds)

	if(!isnull(stashed_name))
		poltergeist.real_name = stashed_name
		poltergeist.name = stashed_name
		if(ishuman(poltergeist))
			var/mob/living/carbon/human/human_user = poltergeist
			human_user.name = human_user.get_visible_name()

	poltergeist.forceMove(get_turf(possessed))
	poltergeist.reset_perspective()

	UnregisterSignal(poltergeist, list(COMSIG_MOB_CLIENT_PRE_NON_LIVING_MOVE, COMSIG_MOB_GHOSTIZED))
	REMOVE_TRAIT(poltergeist, TRAIT_CURRENTLY_CONTROLLING_OBJECT, REF(possessed))

	var/atom/movable/screen/alert/alert_to_clear = screen_alert_ref?.resolve()
	if(isnull(alert_to_clear))
		return

	poltergeist.clear_alert(ALERT_UNPOSSESS_OBJECT)

/**
 * force move the parent object instead of the source mob.
 *
 * Has no sanity other than checking density
 */
/datum/component/object_possession/proc/on_move(datum/source, new_loc, direct)
	SIGNAL_HANDLER
	if(QDELETED(possessed))
		qdel(src)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_NON_LIVING_MOVE

	if(!possessed.density)
		possessed.forceMove(get_step(possessed, direct))
	else
		step(possessed, direct)

	if(QDELETED(possessed))
		qdel(src)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_NON_LIVING_MOVE

	possessed.setDir(direct)
	return COMSIG_MOB_CLIENT_BLOCK_PRE_NON_LIVING_MOVE

/datum/component/object_possession/proc/end_possession(datum/source)
	SIGNAL_HANDLER
	qdel(src)
