
/mob/CanContractDisease(datum/disease/D)
	if(stat == DEAD)
		return 0

	if(D.GetDiseaseID() in resistances)
		return 0

	if(HasDisease(D))
		return 0

	if(!(type in D.viable_mobtypes))
		return 0

	if(count_by_type(viruses, /datum/disease/advance) >= 3)
		return 0

	return 1

/mob/AddDisease(datum/disease/D)
	var/datum/disease/DD = new D.type(1, D, 0)
	viruses += DD
	DD.affected_mob = src
	SSdisease.active_diseases += DD

	//Copy properties over. This is so edited diseases persist.
	var/list/skipped = list("affected_mob","holder","carrier","stage","type","parent_type","vars","transformed")
	for(var/V in DD.vars)
		if(V in skipped)
			continue
		if(istype(DD.vars[V],/list))
			var/list/L = D.vars[V]
			DD.vars[V] = L.Copy()
		else
			DD.vars[V] = D.vars[V]

	DD.affected_mob.med_hud_set_status()