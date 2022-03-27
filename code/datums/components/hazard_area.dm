/**
 * This is a relatively simple component that attempts to deter the parent of the component away
 * from a specific area or areas. By default it simply applies a penalty where all movement is
 * four times slower than usual and any action that would affect your 'next move' has a penalty
 * multiplier of 4 attached.
 */
/datum/component/hazard_area
	/// The blacklist of areas that the parent will be penalized for entering
	var/list/area_blacklist
	/// The whitelist of areas that the parent is allowed to be in. If set this overrides the blacklist
	var/list/area_whitelist
	/// A variable storing the typepath of the last checked area to prevent any further logic running if it has not changed
	VAR_PRIVATE/last_parent_area

/datum/component/hazard_area/Initialize(area_blacklist, area_whitelist)
	. = ..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	if(!islist(area_blacklist) && !islist(area_whitelist))
		stack_trace("[type] - neither area_blacklist nor area_whitelist were provided.")
		return COMPONENT_INCOMPATIBLE
	src.area_blacklist = area_blacklist
	src.area_whitelist = area_whitelist

/datum/component/hazard_area/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLIENT_MOVED, .proc/handle_parent_move)

/datum/component/hazard_area/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_CLIENT_MOVED)

/**
 * Checks if the area being checked is considered hazardous
 * The whitelist is checked first if it exists, otherwise it checks if it is in the blacklist
 *
 * * checking - This should be the typepath of the area being checked, but there is a conversion handler if you pass in a reference instead
 */
/datum/component/hazard_area/proc/check_area_hazardous(area/checking)
	if(!ispath(checking))
		checking = checking.type
	if(area_whitelist)
		return !(checking in area_whitelist)
	return checking in area_blacklist

/**
 * This proc handles the status effect applied to the parent, most noteably applying or removing it as required
 */
/datum/component/hazard_area/proc/update_parent_status_effect()
	if(QDELETED(parent))
		return

	var/mob/living/parent_living = parent
	var/datum/status_effect/hazard_area/effect = parent_living.has_status_effect(/datum/status_effect/hazard_area)
	var/should_have_status_effect = check_area_hazardous(last_parent_area)

	if(should_have_status_effect && !effect) // Should have the status - and doesnt
		parent_living.apply_status_effect(/datum/status_effect/hazard_area)
		return

	if(!should_have_status_effect && effect) // Shouldn't have the status - and does
		parent_living.remove_status_effect(/datum/status_effect/hazard_area)

/**
 * This signal should be called whenever our parent moves.
 */
/datum/component/hazard_area/proc/handle_parent_move()
	SIGNAL_HANDLER

	var/area/current_area = get_area(parent)
	if(current_area.type == last_parent_area)
		return
	last_parent_area = current_area.type

	INVOKE_ASYNC(src, .proc/update_parent_status_effect)
