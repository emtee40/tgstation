/**
 * Attached to a mob with an AI controller, passes things which have damaged it to a blackboard.
 * The AI controller is responsible for doing anything with that information.
 */
/datum/element/ai_retaliate
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Callback to a mob
	var/datum/callback/post_retaliate_callback

/datum/element/ai_retaliate/Attach(datum/target, post_retaliate_callback_input = null)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	src.post_retaliate_callback = post_retaliate_callback_input
	target.AddElement(/datum/element/relay_attackers)
	RegisterSignal(target, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/datum/element/ai_retaliate/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_WAS_ATTACKED)

/// Add an attacking atom to a blackboard list of things which attacked us
/datum/element/ai_retaliate/proc/on_attacked(mob/victim, atom/attacker)
	SIGNAL_HANDLER

	if (!victim.ai_controller)
		return
	var/list/enemy_refs = victim.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
	if (!enemy_refs)
		enemy_refs = list()
	enemy_refs |= WEAKREF(attacker)
	victim.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST] = enemy_refs
	post_retaliate_callback?.InvokeAsync(attacker)
