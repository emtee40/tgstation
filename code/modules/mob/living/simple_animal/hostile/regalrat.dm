#define MINOR_HEAL 10
#define MEDIUM_HEAL 35
#define MAJOR_HEAL 70

/mob/living/simple_animal/hostile/regalrat
	name = "feral regal rat"
	desc = "An evolved rat, created through some strange science. It leads nearby rats with deadly efficiency to protect its kingdom. Not technically a king."
	icon_state = "regalrat"
	icon_living = "regalrat"
	icon_dead = "regalrat_dead"
	gender = NEUTER
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 70
	health = 70
	see_in_dark = 5
	obj_damage = 10
	butcher_results = list(/obj/item/clothing/head/crown = 1,)
	response_help_continuous = "glares at"
	response_help_simple = "glare at"
	response_disarm_continuous = "skoffs at"
	response_disarm_simple = "skoff at"
	response_harm_continuous = "slashes"
	response_harm_simple = "slash"
	melee_damage_lower = 13
	melee_damage_upper = 15
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/punch1.ogg'
	ventcrawler = VENTCRAWLER_ALWAYS
	unique_name = TRUE
	faction = list("rat")
	var/rummaging = FALSE
	///The spell that the rat uses to scrounge up junk.
	var/datum/action/cooldown/domain
	///The Spell that the rat uses to recruit/convert more rats.
	var/datum/action/cooldown/riot

/mob/living/simple_animal/hostile/regalrat/Initialize()
	. = ..()
	domain = new /datum/action/cooldown/domain
	riot = new /datum/action/cooldown/riot
	domain.Grant(src)
	riot.Grant(src)
	AddElement(/datum/element/waddling)

/mob/living/simple_animal/hostile/regalrat/proc/get_player()
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the Royal Rat, cheesey be his crown?", ROLE_SENTIENCE, null, FALSE, 100, POLL_IGNORE_SENTIENCE_POTION)
	if(LAZYLEN(candidates) && !mind)
		var/mob/dead/observer/C = pick(candidates)
		key = C.key
		notify_ghosts("All rise for the rat king, ascendant to the throne in \the [get_area(src)].", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Sentient Rat Created")
	to_chat(src, "<span class='notice'>You are an independent, invasive force on the station! Horde coins, trash, cheese, and the like from the safety of darkness!</span>")

/mob/living/simple_animal/hostile/regalrat/handle_automated_action()
	if(prob(20))
		riot.Trigger()
	else if(prob(50))
		domain.Trigger()
	return ..()

/mob/living/simple_animal/hostile/regalrat/CanAttack(atom/the_target)
	if(istype(the_target,/mob/living/simple_animal))
		var/mob/living/A = the_target
		if(istype(the_target, /mob/living/simple_animal/hostile/regalrat) && A.stat == CONSCIOUS)
			return TRUE
		if(istype(the_target, /mob/living/simple_animal/hostile/rat) && A.stat == CONSCIOUS)
			var/mob/living/simple_animal/hostile/rat/R = the_target
			if(R.faction_check_mob(src, TRUE))
				return FALSE
			else
				return TRUE
		return ..()

/mob/living/simple_animal/hostile/regalrat/examine(mob/user)
	. = ..()
	if(istype(user,/mob/living/simple_animal/hostile/rat))
		var/mob/living/simple_animal/hostile/rat/ratself = user
		if(ratself.faction_check_mob(src, TRUE))
			. += "<span class='notice'>This is your king. Long live his majesty!</span>"
		else
			. += "<span class='warning'>This is a false king! Strike him down!</span>"
	else if(user != src && istype(user,/mob/living/simple_animal/hostile/regalrat))
		. += "<span class='warning'>Who is this foolish false king? This will not stand!</span>"

/mob/living/simple_animal/hostile/regalrat/handle_environment(datum/gas_mixture/environment)
	. = ..()
	if(stat == DEAD || !environment)
		return
	var/miasma_percentage = environment.gases[/datum/gas/miasma][MOLES] / environment.total_moles()
	if(miasma_percentage>=0.25)
		heal_bodypart_damage(1)

/mob/living/simple_animal/hostile/regalrat/AttackingTarget()
	if (rummaging)
		return
	. = ..()
	if(istype(target, /obj/machinery/disposal))
		src.visible_message("<span class='warning'>[src] starts rummaging through the [target].</span>","<span class='notice'>You rummage through the [target]...</span>")
		rummaging = TRUE
		if (do_after(src,3 SECONDS, target))
			var/loot = rand(1,100)
			switch(loot)
				if(1 to 5)
					to_chat(src, "<span class='notice'>You find some leftover coins. More for the royal treasury!</span>")
					var/pickedcoin = pick(GLOB.ratking_coins)
					for(var/i = 1 to rand(1,3))
						new pickedcoin(get_turf(src))
				if(6 to 33)
					src.say(pick("Treasure!","Our precious!","Cheese!"))
					to_chat(src, "<span class='notice'>Score! You find some cheese!</span>")
					new /obj/item/food/cheesewedge(get_turf(src))
				else
					var/pickedtrash = pick(GLOB.ratking_trash)
					to_chat(src, "<span class='notice'>You just find more garbage and dirt. Lovely, but beneath you now.</span>")
					new pickedtrash(get_turf(src))
		rummaging = FALSE
		return
	if(istype(target, /obj/structure/cable))
		var/obj/structure/cable/C = target
		if(C.avail())
			apply_damage(15)
			playsound(src, 'sound/effects/sparks2.ogg', 100, TRUE)
		C.deconstruct()

	if(istype(target, /obj/item/food/cheesewedge))
		cheese_heal(target, MINOR_HEAL, "<span class='green'>You eat [target], restoring some health.</span>")

	else if(istype(target, /obj/item/food/cheesewheel))
		cheese_heal(target, MEDIUM_HEAL, "<span class='green'>You eat [target], restoring some health.</span>")

	else if(istype(target, /obj/item/food/royalcheese))
		cheese_heal(target, MAJOR_HEAL, "<span class='green'>You eat [target], revitalizing your royal resolve completely.</span>")
	else if (target.reagents && istype(target,/obj) && target.is_injectable(src,TRUE))
		src.visible_message("<span class='warning'>[src] starts licking the [target] passionately!</span>","<span class='notice'>You start licking the [target]...</span>")
		rummaging = TRUE
		if (do_after(src,2 SECONDS, target) && target)
			target.reagents.add_reagent(/datum/reagent/rat_spit,1,no_react = TRUE)
			to_chat(src, "<span class='notice'>You finish licking the [target].</span>")
		rummaging = FALSE
		return

/**
 * Conditionally "eat" cheese object and heal, if injured.
 *
 * A private proc for sending a message to the mob's chat about them
 * eating some sort of cheese, then healing them, then deleting the cheese.
 * The "eating" is only conditional on the mob being injured in the first
 * place.
 */
/mob/living/simple_animal/hostile/regalrat/proc/cheese_heal(obj/item/target, amount, message)
	if(health < maxHealth)
		to_chat(src, message)
		heal_bodypart_damage(amount)
		qdel(target)
	else
		to_chat(src, "<span class='warning'>You feel fine, no need to eat anything!</span>")

/mob/living/simple_animal/hostile/regalrat/controlled/Initialize()
	. = ..()
	INVOKE_ASYNC(src, .proc/get_player)
	var/kingdom = pick("Plague","Miasma","Maintenance","Trash","Garbage","Rat","Vermin","Cheese")
	var/title = pick("King","Lord","Prince","Emperor","Supreme","Overlord","Master","Shogun","Bojar","Tsar")
	name = kingdom + " " + title


/**
 *Increase the rat king's domain
 */

/datum/action/cooldown/domain
	name = "Rat King's Domain"
	desc = "Corrupts this area to be more suitable for your rat army."
	cooldown_time = 6 SECONDS
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_clock"
	button_icon_state = "coffer"

/datum/action/cooldown/domain/Trigger()
	. = ..()
	var/turf/T = get_turf(owner)
	T.atmos_spawn_air("miasma=4;TEMP=[T20C]")
	switch (rand(1,10))
		if (8)
			new /obj/effect/decal/cleanable/vomit(T)
		if (9)
			new /obj/effect/decal/cleanable/vomit/old(T)
		if (10)
			new /obj/effect/decal/cleanable/oil/slippery(T)
		else
			new /obj/effect/decal/cleanable/dirt(T)
	StartCooldown()

/**
 *This action checks all nearby mice, and converts them into hostile rats. If no mice are nearby, creates a new one.
 */

/datum/action/cooldown/riot
	name = "Raise Army"
	desc = "Raise an army out of the hordes of mice and pests crawling around the maintenance shafts."
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "riot"
	background_icon_state = "bg_clock"
	cooldown_time = 4 SECONDS
	///Checks to see if there are any nearby mice. Does not count Rats.

/datum/action/cooldown/riot/Trigger()
	. = ..()
	if(!.)
		return
	var/cap = CONFIG_GET(number/ratcap)
	var/something_from_nothing = FALSE
	for(var/mob/living/simple_animal/mouse/M in oview(owner, 5))
		var/mob/living/simple_animal/hostile/rat/new_rat = new(get_turf(M))
		something_from_nothing = TRUE
		if(M.mind && M.stat == CONSCIOUS)
			M.mind.transfer_to(new_rat)
		if(istype(owner,/mob/living/simple_animal/hostile/regalrat))
			var/mob/living/simple_animal/hostile/regalrat/giantrat = owner
			new_rat.faction = giantrat.faction
		qdel(M)
	if(!something_from_nothing)
		if(LAZYLEN(SSmobs.cheeserats) >= cap)
			to_chat(owner,"<span class='warning'>There's too many mice on this station to beckon a new one! Find them first!</span>")
			return
		new /mob/living/simple_animal/mouse(owner.loc)
		owner.visible_message("<span class='warning'>[owner] commands a mouse to its side!</span>")
	else
		owner.visible_message("<span class='warning'>[owner] commands its army to action, mutating them into rats!</span>")
	StartCooldown()

/mob/living/simple_animal/hostile/rat
	name = "rat"
	desc = "It's a nasty, ugly, evil, disease-ridden rodent with anger issues."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak = list("Skree!","SKREEE!","Squeak?")
	speak_emote = list("squeaks")
	emote_hear = list("Hisses.")
	emote_see = list("runs in a circle.", "stands on its hind legs.")
	melee_damage_lower = 3
	melee_damage_upper = 5
	obj_damage = 5
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 15
	health = 15
	butcher_results = list(/obj/item/food/meat/slab/mouse = 1)
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	faction = list("rat")

/mob/living/simple_animal/hostile/rat/Initialize()
	. = ..()
	SSmobs.cheeserats += src

/mob/living/simple_animal/hostile/rat/Destroy()
	SSmobs.cheeserats -= src
	return ..()

/mob/living/simple_animal/hostile/rat/death(gibbed)
	if(!ckey)
		..(TRUE)
		if(!gibbed)
			var/obj/item/food/deadmouse/mouse = new(loc)
			mouse.icon_state = icon_dead
			mouse.name = name
	SSmobs.cheeserats -= src // remove rats on death
	return ..()

/mob/living/simple_animal/hostile/rat/revive(full_heal = FALSE, admin_revive = FALSE)
	var/cap = CONFIG_GET(number/ratcap)
	if(!admin_revive && !ckey && LAZYLEN(SSmobs.cheeserats) >= cap)
		visible_message("<span class='warning'>[src] twitched but does not continue moving due to the overwhelming rodent population on the station!</span>")
		return FALSE
	. = ..()
	if(.)
		SSmobs.cheeserats += src

/mob/living/simple_animal/hostile/rat/examine(mob/user)
	. = ..()
	if(istype(user,/mob/living/simple_animal/hostile/rat))
		var/mob/living/simple_animal/hostile/rat/ratself = user
		if(ratself.faction_check_mob(src, TRUE))
			. += "<span class='notice'>You both serve the same king.</span>"
		else
			. += "<span class='warning'>This fool serves a different king!</span>"
	else if(istype(user,/mob/living/simple_animal/hostile/regalrat))
		var/mob/living/simple_animal/hostile/regalrat/ratking = user
		if(ratking.faction_check_mob(src, TRUE))
			. += "<span class='notice'>This rat serves under you.</span>"
		else
			. += "<span class='warning'>This peasant serves a different king! Strike him down!</span>"

/mob/living/simple_animal/hostile/rat/CanAttack(atom/the_target)
	if(istype(the_target,/mob/living/simple_animal))
		var/mob/living/A = the_target
		if(istype(the_target, /mob/living/simple_animal/hostile/regalrat) && A.stat == CONSCIOUS)
			var/mob/living/simple_animal/hostile/regalrat/ratking = the_target
			if(ratking.faction_check_mob(src, TRUE))
				return FALSE
			else
				return TRUE
		if(istype(the_target, /mob/living/simple_animal/hostile/rat) && A.stat == CONSCIOUS)
			var/mob/living/simple_animal/hostile/rat/R = the_target
			if(R.faction_check_mob(src, TRUE))
				return FALSE
			else
				return TRUE
	return ..()

/mob/living/simple_animal/hostile/rat/handle_automated_action()
	. = ..()
	if(prob(40))
		var/turf/open/floor/F = get_turf(src)
		if(istype(F) && !F.intact)
			var/obj/structure/cable/C = locate() in F
			if(C && prob(15))
				if(C.avail())
					visible_message("<span class='warning'>[src] chews through the [C]. It's toast!</span>")
					playsound(src, 'sound/effects/sparks2.ogg', 100, TRUE)
					C.deconstruct()
					death()
			else if(C?.avail())
				visible_message("<span class='warning'>[src] chews through the [C]. It looks unharmed!</span>")
				playsound(src, 'sound/effects/sparks2.ogg', 100, TRUE)
				C.deconstruct()

/mob/living/simple_animal/hostile/rat/AttackingTarget()
	. = ..()
	if(istype(target, /obj/item/food/cheesewedge))
		if (health >= maxHealth)
			to_chat(src, "<span class='warning'>You feel fine, no need to eat anything!</span>")
			return
		to_chat(src, "<span class='green'>You eat \the [src], restoring some health.</span>")
		heal_bodypart_damage(MINOR_HEAL)
		qdel(target)

#undef MINOR_HEAL
#undef MEDIUM_HEAL
#undef MAJOR_HEAL



/**
 *Spittle; harmless reagent that is added by rat king, and makes you disgusted.
 */

/datum/reagent/rat_spit
	name = "Rat Spit"
	description = "Something coming from a rat. Dear god! Who knows where it's been!"
	reagent_state = LIQUID
	color = "#C8C8C8"
	metabolization_rate = 0.03 * REAGENTS_METABOLISM
	taste_description = "something funny"

/datum/reagent/rat_spit/on_mob_metabolize(mob/living/L)
	..()
	to_chat(L, "<span class='notice'>This food has a funny taste!</span>")

/datum/reagent/rat_spit/on_mob_life(mob/living/carbon/M)
	if(prob(15))
		to_chat(M, "<span class='notice'>That food was awful!</span>")
		M.adjust_disgust(3)
	else if(prob(10))
		to_chat(M, "<span class='warning'>That food did not sit up well!</span>")
		M.adjust_disgust(5)
	else if(prob(5))
		M.vomit()
	..()
