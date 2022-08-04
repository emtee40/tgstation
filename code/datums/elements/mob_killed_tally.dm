/**
 * Mob Killed Tally; which ticks up a blackbox when the mob dies
 *
 * Used for all the mining mobs!
 */
/datum/element/mob_killed_tally
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	/// Path of the trophy dropped
	var/tally_string

/datum/element/mob_killed_tally/Attach(datum/target, tally_string)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_LIVING_DEATH, .proc/on_death)

	src.tally_string = tally_string

/datum/element/mob_killed_tally/Detach(datum/target)
	UnregisterSignal(target, COMSIG_LIVING_DEATH)
	return ..()

/datum/element/mob_killed_tally/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER

	SSblackbox.record_feedback("tally", tally_string, 1, target.type)
