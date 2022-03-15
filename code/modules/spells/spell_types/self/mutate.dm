/// A spell type that adds mutations to the caster temporarily.
/datum/action/cooldown/spell/apply_mutations
	name = "Mutate"
	action_icon_state = "mutate"
	sound = 'sound/magic/mutate.ogg'

	school = SCHOOL_TRANSMUTATION
	spell_requirements = (SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_WIZARD_GARB)

	/// A list of all mutations we add on cast
	var/list/mutations_to_add = list()
	/// The duration the mutations will last afetr cast (keep this above the minimum cooldown)
	var/mutation_duration = 10 SECONDS

/datum/action/cooldown/spell/apply_mutations/Remove()
	remove_mutations(owner)
	return ..()

/datum/action/cooldown/spell/apply_mutations/is_valid_target(atom/cast_on)
	return !!cast_on.dna

/datum/action/cooldown/spell/apply_mutations/cast(mob/living/carbon/human/cast_on)
	for(var/mutation in mutations_to_add)
		cast_on.dna.add_mutation(mutation)
	addtimer(CALLBACK(src, .proc/remove_mutations, cast_on), mutation_duration, TIMER_DELETE_ME)

/datum/action/cooldown/spell/apply_mutations/proc/remove_mutations(mob/living/carbon/human/cast_on)
	if(QDELETED(cast_on) || !is_valid_target(cast_on))
		return

	for(var/mutation in mutations_to_add)
		cast_on.dna.remove_mutations(mutation)

/datum/action/cooldown/spell/apply_mutations/mutate
	desc = "This spell causes you to turn into a hulk and gain laser vision for a short while."
	cooldown_time = 40 SECONDS
	cooldown_reduction_per_rank = 2.5 SECONDS

	invocation = "BIRUZ BENNAR"
	invocation_type = INVOCATION_SHOUT

	mutations_to_add = list(/datum/mutation/human/laser_eyes, /datum/mutation/human/hulk)
	mutation_duration = 30 SECONDS
