/datum/surgery/advanced/bioware
<<<<<<< HEAD
	name = "Enhancement surgery"
=======
	name = "enhancement surgery"
>>>>>>> Updated this old code to fork
	var/bioware_target = BIOWARE_GENERIC

/datum/surgery/advanced/bioware/can_start(mob/user, mob/living/carbon/human/target)
	if(!..())
		return FALSE
	if(!istype(target))
		return FALSE
	for(var/X in target.bioware)
		var/datum/bioware/B = X
		if(B.mod_type == bioware_target)
			return FALSE
<<<<<<< HEAD
	return TRUE
=======
	return TRUE
>>>>>>> Updated this old code to fork
