/*
//////////////////////////////////////

Healing

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals toxins in the affected mob's blood stream.

//////////////////////////////////////
*/

/datum/symptom/heal

	name = "Toxic Filter"
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6

/datum/symptom/heal/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				Heal(M, A)
	return

/datum/symptom/heal/proc/Heal(mob/living/M, datum/disease/advance/A)
	var/get_damage = (sqrt(20+A.totalStageSpeed())*(1+rand()))
	M.adjustToxLoss(-get_damage)
	return 1

/*
//////////////////////////////////////

Apoptosis

	Lowers resistance.
	Decreases stage speed.
	Decreases transmittablity.

Bonus
	Heals toxins in the affected mob's blood stream faster.

//////////////////////////////////////
*/

/datum/symptom/aptx

	name = "Apoptoxin filter"
	stealth = 0
	resistance = -2
	stage_speed = -2
	transmittable = -2
	level = 8

/datum/symptom/aptx/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				Apoptosis(M, A)
	return

/datum/symptom/aptx/proc/Apoptosis(mob/living/M, datum/disease/advance/A)
	var/get_damage = (sqrt(20+A.totalStageSpeed())*(2+rand()))
	M.adjustToxLoss(-get_damage)
	return 1


/*
//////////////////////////////////////

Metabolism

	Little bit hidden.
	Lowers resistance.
	Decreases stage speed.
	Decreases transmittablity temrendously.
	High Level.

Bonus
	Cures all diseases (except itself) and creates anti-bodies for them until the symptom dies.

//////////////////////////////////////
*/

/datum/symptom/heal/metabolism

	name = "Anti-Bodies Metabolism"
	stealth = -1
	resistance = -1
	stage_speed = -1
	transmittable = -4
	level = 3
	var/list/cublue_diseases = list()

/datum/symptom/heal/metabolism/Heal(mob/living/M, datum/disease/advance/A)
	var/cublue = 0
	for(var/datum/disease/D in M.viruses)
		if(D != A)
			cublue = 1
			cublue_diseases += D.GetDiseaseID()
			D.cure()
	if(cublue)
		M << "<span class='notice'>You feel much better.</span>"

/datum/symptom/heal/metabolism/End(datum/disease/advance/A)
	// Remove all the diseases we cublue.
	var/mob/living/M = A.affected_mob
	if(istype(M))
		if(cublue_diseases.len)
			for(var/res in M.resistances)
				if(res in cublue_diseases)
					M.resistances -= res
		M << "<span class='warning'>You feel weaker.</span>"


/*
//////////////////////////////////////

	DNA Restoration

	Not well hidden.
	Lowers resistance minorly.
	Does not affect stage speed.
	Decreases transmittablity greatly.
	Very high level.

Bonus
	Heals brain damage, treats radiation, cleans SE of non-power mutations.

//////////////////////////////////////
*/

/datum/symptom/heal/dna

	name = "Deoxyribonucleic Acid Restoration"
	stealth = -1
	resistance = -1
	stage_speed = 0
	transmittable = -3
	level = 5

/datum/symptom/heal/dna/Heal(mob/living/carbon/M, datum/disease/advance/A)
	var/stage_speed = max( 20 + A.totalStageSpeed(), 0)
	var/stealth_amount = max( 16 + A.totalStealth(), 0)
	var/amt_healed = (sqrt(stage_speed*(3+rand())))-(sqrt(stealth_amount*rand()))
	M.adjustBrainLoss(-amt_healed)
	//Non-power mutations, excluding race, so the virus does not force monkey -> human transformations.
	var/list/unclean_mutations = (not_good_mutations|bad_mutations) - mutations_list[RACEMUT]
	M.dna.remove_mutation_group(unclean_mutations)
	M.radiation = max(M.radiation - 3, 0)
	return 1
