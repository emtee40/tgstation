/mob/living/simple_animal/hostile/eldritch
	name = "Demon"
	real_name = "Demon"
	desc = ""
	gender = NEUTER
	mob_biotypes = NONE
	speak_emote = list("screams")
	response_help_continuous = "thinks better of touching"
	response_help_simple = "think better of touching"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "reaps"
	response_harm_simple = "tears"
	speak_chance = 1
	icon = 'icons/mob/eldritch_mobs.dmi'
	speed = 0
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	AIStatus = AI_ON
	attack_sound = 'sound/weapons/punch1.ogg'
	see_in_dark = 7
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	healable = 0
	movement_type = GROUND
	pressure_resistance = 100
	del_on_death = TRUE
	deathmessage = "implodes into itself"
	///Innate spells that are supposed to be added when a beast is created
	var/list/spells_to_add

/mob/living/simple_animal/hostile/eldritch/Initialize()
	. = ..()
	add_spells()

/**
  * Add_spells
  *
  * Goes through spells_to_add and adds each spell to the mind.
  */
/mob/living/simple_animal/hostile/eldritch/proc/add_spells()
	for(var/spell in spells_to_add)
		AddSpell(new spell())

/mob/living/simple_animal/hostile/eldritch/raw_prophet
	name = "Raw Prophet"
	real_name = "Raw Prophet"
	desc = "Abomination made from severed limbs."
	icon_state = "raw_prophet"
	status_flags = CANPUSH
	icon_living = "raw_prophet"
	melee_damage_lower = 5
	melee_damage_upper = 10
	maxHealth = 50
	health = 50
	sight = SEE_MOBS|SEE_OBJS|SEE_TURFS
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/long,/obj/effect/proc_holder/spell/targeted/telepathy/eldritch)

/mob/living/simple_animal/hostile/eldritch/raw_prophet/Login()
	. = ..()
	client?.view_size.setTo(11)

/mob/living/simple_animal/hostile/eldritch/armsy
	name = "Terror of the night"
	real_name = "Armsy"
	desc = "Abomination made from severed limbs."
	icon_state = "armsy_start"
	icon_living = "armsy_start"
	maxHealth = 200
	health = 200
	melee_damage_lower = 10
	melee_damage_upper = 15
	move_resist = MOVE_FORCE_OVERPOWERING+1
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/worm_contract)
	///Previous segment in the chain
	var/mob/living/simple_animal/hostile/eldritch/armsy/back
	///Next segment in the chain
	var/mob/living/simple_animal/hostile/eldritch/armsy/front
	///Your old location
	var/oldloc
	///Allow / disallow pulling
	var/allow_pulling = FALSE
	///How many arms do we have to eat to expand?
	var/stacks_to_grow = 5
	///Currently eaten arms
	var/current_stacks = 0

//I tried Initalize but it didnt work, like at all. This proc just wouldnt fire if it was Initalize instead of New
/mob/living/simple_animal/hostile/eldritch/armsy/New(spawn_more = TRUE,len = 6)
	. = ..()
	if(len < 3)
		stack_trace("Eldritch Armsy created with invalid len ([len]). Reverting to 3.")
		len = 3 //code breaks below 3, let's just not allow it.
	oldloc = loc
	RegisterSignal(src,COMSIG_MOVABLE_MOVED,.proc/update_chain_links)
	if(!spawn_more)
		return
	allow_pulling = TRUE
	///next link
	var/mob/living/simple_animal/hostile/eldritch/armsy/next
	///previous link
	var/mob/living/simple_animal/hostile/eldritch/armsy/prev
	///current link
	var/mob/living/simple_animal/hostile/eldritch/armsy/current
	for(var/i in 0 to len)
		prev = current
		//i tried using switch, but byond is really fucky and it didnt work as intended. Im sorry
		if(i == 0)
			current = new type(drop_location(),spawn_more = FALSE)
			current.icon_state = "armsy_mid"
			current.icon_living = "armsy_mid"
			current.front = src
			current.AIStatus = AI_OFF
			back = current
		else if(i < len)
			current = new type(drop_location(),spawn_more = FALSE)
			prev.back = current
			prev.icon_state = "armsy_mid"
			prev.icon_living = "armsy_mid"
			prev.front = next
			prev.AIStatus = AI_OFF
		else
			prev.icon_state = "armsy_end"
			prev.icon_living = "armsy_end"
			prev.front = next
			prev.AIStatus = AI_OFF
		next = prev

/mob/living/simple_animal/hostile/eldritch/armsy/can_be_pulled()
	return FALSE

///Updates chain links to force move onto a single tile
/mob/living/simple_animal/hostile/eldritch/armsy/proc/contract_next_chain_into_single_tile()
	if(back)
		back.forceMove(loc)
		back.contract_next_chain_into_single_tile()
	return

///Updates the next mob in the chain to move to our last location, fixed the worm if somehow broken.
/mob/living/simple_animal/hostile/eldritch/armsy/proc/update_chain_links()
	gib_trail()
	if(back && back.loc != oldloc)
		back.Move(oldloc)
	// self fixing properties if somehow broken
	if(front && loc != front.oldloc)
		forceMove(front.oldloc)
	oldloc = loc

/mob/living/simple_animal/hostile/eldritch/armsy/proc/gib_trail()
	if(front) // head makes gibs
		return
	var/chosen_decal = pick(typesof(/obj/effect/decal/cleanable/blood/gibs))
	var/obj/effect/decal/cleanable/blood/gibs/decal = new chosen_decal(drop_location())
	decal.setDir(dir)

/mob/living/simple_animal/hostile/eldritch/armsy/Destroy()
	if(front)
		front.icon_state = "armsy_end"
		front.icon_living = "armsy_end"
		front.back = null
	if(back)
		QDEL_NULL(back) // chain destruction baby
	return ..()


/mob/living/simple_animal/hostile/eldritch/armsy/proc/heal()
	if(health == maxHealth)
		if(back)
			back.heal()
			return
		else
			current_stacks++
			if(current_stacks >= stacks_to_grow)
				var/mob/living/simple_animal/hostile/eldritch/armsy/prev = new type(drop_location(),spawn_more = FALSE)
				icon_state = "armsy_mid"
				icon_living =  "armsy_mid"
				back = prev
				prev.icon_state = "armsy_end"
				prev.icon_living = "armsy_end"
				prev.front = src
				prev.AIStatus = AI_OFF
				current_stacks = 0

	adjustBruteLoss(-maxHealth * 0.5, FALSE)
	adjustFireLoss(-maxHealth * 0.5 ,FALSE)
	adjustToxLoss(-maxHealth * 0.5, FALSE)
	adjustOxyLoss(-maxHealth * 0.5)

/mob/living/simple_animal/hostile/eldritch/armsy/AttackingTarget()
	if(istype(target,/obj/item/bodypart/r_arm) || istype(target,/obj/item/bodypart/l_arm))
		qdel(target)
		heal()
		return
	if(back)
		back.target = target
		back.AttackingTarget()
	if(!Adjacent(target))
		return
	do_attack_animation(target)
	//have fun
	if(istype(target,/turf/closed/wall))
		var/turf/closed/wall = target
		wall.ScrapeAway()

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(HAS_TRAIT(C, TRAIT_NODISMEMBER))
			return
		var/list/parts = list()
		for(var/X in C.bodyparts)
			var/obj/item/bodypart/bodypart = X
			if(bodypart.body_part != HEAD && bodypart.body_part != CHEST && bodypart.body_part != LEG_LEFT && bodypart.body_part != LEG_RIGHT)
				if(bodypart.dismemberable)
					parts += bodypart
		if(length(parts) && prob(10))
			var/obj/item/bodypart/bodypart = pick(parts)
			bodypart.dismember()

	return ..()

/mob/living/simple_animal/hostile/eldritch/armsy/prime
	name = "Lord of the Night"
	real_name = "Master of Decay"
	maxHealth = 400
	health = 400
	melee_damage_lower = 20
	melee_damage_upper = 25

/mob/living/simple_animal/hostile/eldritch/armsy/prime/New(spawn_more, len)
	. = ..()
	var/matrix/matrix_transformation = matrix()
	matrix_transformation.Scale(1.4,1.4)
	transform = matrix_transformation

/mob/living/simple_animal/hostile/eldritch/rust_spirit
	name = "Rust Walker"
	real_name = "Rusty"
	desc = "Incomprehensible abomination actively seeping life out of it's surrounding."
	icon_state = "rust_walker"
	status_flags = CANPUSH
	icon_living = "rust_walker"
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS
	spells_to_add = list(/obj/effect/proc_holder/spell/aoe_turf/rust_conversion/small,/obj/effect/proc_holder/spell/targeted/projectile/dumbfire/rust_wave/short)

/mob/living/simple_animal/hostile/eldritch/rust_spirit/Life()
	. = ..()
	if(stat == DEAD)
		return
	var/turf/T = get_turf(src)
	if(istype(T,/turf/open/floor/plating/rust))
		adjustBruteLoss(-3, FALSE)
		adjustFireLoss(-3, FALSE)
		adjustToxLoss(-3, FALSE)
		adjustOxyLoss(-1)

/mob/living/simple_animal/hostile/eldritch/ash_spirit
	name = "Ash Man"
	real_name = "Ashy"
	desc = "Incomprehensible abomination actively seeping life out of it's surrounding."
	icon_state = "ash_walker"
	status_flags = CANPUSH
	icon_living = "ash_walker"
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash,/obj/effect/proc_holder/spell/pointed/ash_cleave/long,/obj/effect/proc_holder/spell/aoe_turf/fire_cascade)

/mob/living/simple_animal/hostile/eldritch/stalker
	name = "Flesh Stalker"
	real_name = "Flesh Stalker"
	desc = "Abomination made from severed limbs."
	icon_state = "stalker"
	status_flags = CANPUSH
	icon_living = "stalker"
	maxHealth = 150
	health = 150
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_MOBS
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash,/obj/effect/proc_holder/spell/targeted/shapeshift/eldritch,/obj/effect/proc_holder/spell/targeted/emplosion/eldritch)
