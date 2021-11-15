/mob/living/simple_animal/hostile/retaliate
	///A list of weakrefs pointing at things that we consider targets
	var/list/enemies = list()

/mob/living/simple_animal/hostile/retaliate/Found(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(!L.stat)
			return L
		else
			enemies -= WEAKREF(L)
	else if(ismecha(A))
		var/obj/vehicle/sealed/mecha/M = A
		if(LAZYLEN(M.occupants))
			return A

/mob/living/simple_animal/hostile/retaliate/ListTargets()
	if(!enemies.len)
		return list()
	var/list/see = ..()
	var/list/actual_enemies = list()
	for(var/datum/weakref/enemy as anything in enemies)
		var/mob/flesh_and_blood = enemy.resolve()
		if(!flesh_and_blood)
			enemies -= enemy
			continue
		actual_enemies += flesh_and_blood

	see &= actual_enemies // Remove all entries that aren't in enemies
	return see

/mob/living/simple_animal/hostile/retaliate/proc/Retaliate()
	for(var/atom/movable/A as obj|mob in oview(vision_range, src))
		if(isliving(A))
			var/mob/living/M = A
			if(attack_same || !faction_check_mob(M))
				enemies |= WEAKREF(M)
			if(istype(M, /mob/living/simple_animal/hostile/retaliate))
				var/mob/living/simple_animal/hostile/retaliate/H = M
				if(attack_same && H.attack_same)
					H.enemies |= enemies
		else if(ismecha(A))
			var/obj/vehicle/sealed/mecha/M = A
			if(LAZYLEN(M.occupants))
				enemies |= WEAKREF(M)
				add_enemies(M.occupants)

	return FALSE

/mob/living/simple_animal/hostile/retaliate/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(. > 0 && stat == CONSCIOUS)
		Retaliate()

/mob/living/simple_animal/hostile/retaliate/proc/add_enemies(new_enemies)
	for(var/new_enemy in new_enemies)
		enemies |= WEAKREF(new_enemy)
