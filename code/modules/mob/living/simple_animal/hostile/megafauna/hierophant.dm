#define MEDAL_PREFIX "Hierophant"
/*

The Hierophant

The Hierophant spawns somewhere who knows

The Hierophant's attacks are as follows, and INTENSIFY at a random chance based on Hierophant's health or if the target is adjacent to Hierophant;
- Creates a cardinal or diagonal blast(Cross Blast) under its target, exploding after a short time.
	INTENSITY EFFECT: Creates one of the cross blast types under itself instead of under the target.
- If no chasers exist, creates a chaser that will seek its target, leaving a trail of blasts.
	INTENSITY EFFECT: Creates a second, slower chaser.
- Creates an expanding AoE burst.
- INTENSE ATTACKS:
	Blinks to the target after a very brief delay, damaging everything near the start and end points.
	Rapidly creates Cross Blasts and squares of 3x3 blasts under the target.
	Creates four high-speed chasers.
- IF TARGET WAS STRUCK IN MELEE: Creates a 3x3 square of blasts under the target.

Cross Blasts and the AoE burst gain additional range as the Hierophant loses health, while Chasers gain additional speed.

When The Hierophant dies, it leaves behind its staff, which, while much weaker than when wielded by The Hierophant itself, is still quite effective.
- The rune it teleports back to also becomes avalible for use, allowing you, too, to teleport to it at will.

Difficulty: Hard

*/

/mob/living/simple_animal/hostile/megafauna/hierophant
	name = "Hierophant"
	desc = "Stolen from Hyper Light Drifter."
	health = 2500
	maxHealth = 2500
	attacktext = "clubs"
	attack_sound = "swing_hit"
	icon_state = "hierophant"
	icon_living = "hierophant"
	friendly = "stares down"
	icon = 'icons/mob/lavaland/hierophant.dmi'
	faction = list("mining")
	weather_immunities = list("lava","ash")
	speak_emote = list("preaches")
	armour_penetration = 100
	melee_damage_lower = 20
	melee_damage_upper = 20
	speed = 1
	move_to_delay = 10
	ranged = 1
	flying = 1
	mob_size = MOB_SIZE_LARGE
	pixel_x = -16
	ranged_cooldown_time = 40
	aggro_vision_range = 23
	idle_vision_range = 5
	loot = list(/obj/item/weapon/hierophant_staff)
	wander = FALSE
	var/anger_modifier = 0
	var/burst_range = 2
	var/beam_range = 3
	var/chaser_cooldown = 101
	var/major_attack_cooldown = 60
	var/doing_major_attack = FALSE
	var/blinking = FALSE
	var/obj/effect/hierophant/original_loc
	var/timeout_time = 15 //after this many Life() ticks with no target, we return to our original location
	var/obj/item/device/gps/internal
	medal_type = MEDAL_PREFIX
	score_type = BIRD_SCORE
	del_on_death = TRUE
	deathmessage = "disappears in a burst of magic, leaving only its staff."
	death_sound = 'sound/magic/Repulse.ogg'
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)

/mob/living/simple_animal/hostile/megafauna/hierophant/New()
	..()
	internal = new/obj/item/device/gps/internal/hierophant(src)
	original_loc = new(loc)
	original_loc.active_boss = src

/mob/living/simple_animal/hostile/megafauna/hierophant/Life()
	. = ..()
	if(. && original_loc)
		if(target || loc == original_loc.loc)
			timeout_time = initial(timeout_time)
		else
			timeout_time--
		if(timeout_time <= 0)
			if(get_dist(src, original_loc) > 2)
				blink(original_loc)
			else
				Goto(original_loc, move_to_delay, 0)
			wander = FALSE

/mob/living/simple_animal/hostile/megafauna/hierophant/death()
	if(health > 0)
		return
	else
		blinking = TRUE
		animate(src, alpha = 0, color = "660099", time = 3, easing = EASE_OUT)
		melee_blast(src)
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/Destroy()
	qdel(internal)
	if(original_loc)
		original_loc.active_boss = null
	. = ..()

/mob/living/simple_animal/hostile/megafauna/hierophant/attackby(obj/item/weapon/W, mob/user, params)
	if(W)
		W.force *= 2
		..()
		W.force *= 0.5

/mob/living/simple_animal/hostile/megafauna/hierophant/devour(mob/living/L)
	visible_message(
		"<span class='hierophant'>\"Caw.\"</span>\n<span class='hierophant_warning'>[src] annihilates [L]!</span>",
		"<span class='userdanger'>You annihilate [L], restoring your health!</span>")
	adjustHealth(-L.maxHealth)
	L.dust()

/mob/living/simple_animal/hostile/megafauna/hierophant/AttackingTarget()
	if(!blinking)
		if(target)
			addtimer(src, "melee_blast", 0, FALSE, get_turf(target))
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/DestroySurroundings()
	if(!blinking)
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/Move()
	if(!blinking)
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/Goto(target, delay, minimum_distance)
	wander = TRUE
	if(!blinking)
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/calculate_rage()
	anger_modifier = Clamp(((maxHealth - health)/50),0,50)
	burst_range = initial(burst_range) + round(anger_modifier * 0.1)
	beam_range = initial(beam_range) + round(anger_modifier * 0.16)

/mob/living/simple_animal/hostile/megafauna/hierophant/OpenFire()
	calculate_rage()
	if(blinking)
		return
	ranged_cooldown = world.time + max(5, ranged_cooldown_time - anger_modifier)

	if(prob(anger_modifier*0.75)) //major ranged attack
		ranged_cooldown = world.time + max(5, major_attack_cooldown - round(anger_modifier*0.75))
		var/list/possibilities = list("cardinal_blast_spam", "blast_spam")
		if(get_dist(src, target) > 2)
			possibilities += "blink"
		if(chaser_cooldown < world.time)
			if(prob(anger_modifier*2))
				possibilities = list("chaser_swarm")
			else
				possibilities += "chaser_swarm"
		switch(pick(possibilities))
			if("blink")
				blink(target)
			if("blast_spam")
				blinking = TRUE
				animate(src, color = "#660099", time = 3)
				melee_blast(target)
				var/counter = round(anger_modifier*0.12)
				sleep(3)
				while(target && counter)
					counter--
					melee_blast(target)
					sleep(3)
				sleep(5)
				animate(src, color = initial(color), time = 3)
				blinking = FALSE
			if("cardinal_blast_spam")
				blinking = TRUE
				animate(src, color = "#660099", time = 6)
				if(prob(60))
					cardinal_blasts(target)
				else
					diagonal_blasts(target)
				var/counter = round(anger_modifier*0.08)
				sleep(6)
				while(target && counter)
					counter--
					if(prob(60))
						cardinal_blasts(target)
					else
						diagonal_blasts(target)
					sleep(6)
				sleep(7)
				animate(src, color = initial(color), time = 6)
				blinking = FALSE
			if("chaser_swarm")
				chaser_cooldown = world.time + initial(chaser_cooldown)
				blinking = TRUE
				animate(src, color = "#660099", time = 5)
				var/list/cardinal_copy = cardinal.Copy()
				while(target && cardinal_copy.len)
					var/obj/effect/overlay/temp/hierophant/chaser/C = PoolOrNew(/obj/effect/overlay/temp/hierophant/chaser, list(loc, src, target, max(1.5, 4 - anger_modifier*0.05)))
					C.moving = 4
					C.moving_dir = pick_n_take(cardinal_copy)
					sleep(10)
				sleep(10)
				animate(src, color = initial(color), time = 5)
				blinking = FALSE
		return

	if(prob(70-anger_modifier)) //a cross blast of some type
		if(prob(anger_modifier))
			if(prob(60))
				addtimer(src, "cardinal_blasts", 0, FALSE, src)
			else
				addtimer(src, "diagonal_blasts", 0, FALSE, src)
		else
			if(prob(60))
				addtimer(src, "cardinal_blasts", 0, FALSE, target)
			else
				addtimer(src, "diagonal_blasts", 0, FALSE, target)
	else
		if(chaser_cooldown < world.time)
			var/obj/effect/overlay/temp/hierophant/chaser/C = PoolOrNew(/obj/effect/overlay/temp/hierophant/chaser, list(loc, src, target, max(1.5, 4 - anger_modifier*0.05)))
			chaser_cooldown = world.time + initial(chaser_cooldown)
			if((prob(anger_modifier) || target.Adjacent(src)) && target != src)
				var/obj/effect/overlay/temp/hierophant/chaser/OC = PoolOrNew(/obj/effect/overlay/temp/hierophant/chaser, list(loc, src, target, max(1, 6 - anger_modifier*0.05)))
				OC.moving = 4
				OC.moving_dir = pick(cardinal - C.moving_dir)
		else
			addtimer(src, "burst", 0, FALSE, get_turf(src))

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/diagonal_blasts(mob/victim)
	var/turf/T = get_turf(victim)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/diagonal, list(T, src))
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	sleep(3)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(T, src))
	for(var/d in diagonals)
		addtimer(src, "blast_wall", 0, FALSE, T, d)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/cardinal_blasts(mob/victim)
	var/turf/T = get_turf(victim)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/cardinal, list(T, src))
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	sleep(3)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(T, src))
	for(var/d in cardinal)
		addtimer(src, "blast_wall", 0, FALSE, T, d)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/blast_wall(turf/T, dir)
	var/range = beam_range
	var/turf/previousturf = T
	var/turf/J = get_step(previousturf, dir)
	for(var/i in 1 to range)
		PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(J, src))
		previousturf = J
		J = get_step(previousturf, dir)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/blink(mob/victim)
	if(blinking || !victim || get_dist(victim, src) <= 2)
		return
	var/turf/T = get_turf(victim)
	var/turf/source = get_turf(src)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph, list(T, src))
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph, list(source, src))
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	playsound(source,'sound/magic/blink.ogg', 200, 1)
	blinking = TRUE
	sleep(3)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/teleport, list(T, src))
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/teleport, list(source, src))
	for(var/t in RANGE_TURFS(1, T))
		var/obj/effect/overlay/temp/hierophant/blast/B = PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(t, src))
		B.damage = 30
	for(var/t in RANGE_TURFS(1, source))
		var/obj/effect/overlay/temp/hierophant/blast/B = PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(t, src))
		B.damage = 30
	animate(src, alpha = 0, color = "660099", time = 2, easing = EASE_OUT)
	sleep(1)
	visible_message("<span class='hierophant_warning'>[src] fades out!</span>")
	density = FALSE
	sleep(3)
	forceMove(T)
	animate(src, alpha = 255, color = initial(color), time = 2, easing = EASE_IN)
	sleep(1)
	density = TRUE
	visible_message("<span class='hierophant_warning'>[src] fades in!</span>")
	sleep(1)
	blinking = FALSE

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/melee_blast(mob/victim)
	var/turf/T = get_turf(victim)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph, list(T, src))
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	sleep(3)
	for(var/t in RANGE_TURFS(1, T))
		PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(t, src))

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/burst(turf/original)
	playsound(original,'sound/magic/blink.ogg', 200, 1)
	var/last_dist = 0
	for(var/t in spiral_range_turfs(burst_range, original))
		var/turf/T = t
		if(!T)
			continue
		var/dist = get_dist(original, T)
		if(dist > last_dist)
			last_dist = dist
			sleep(rand(1, last_dist))
		PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(T, src))

/mob/living/simple_animal/hostile/megafauna/hierophant/AltClickOn(atom/A)
	if(!istype(A))
		return
	blink(A)

//Hierophant overlays
/obj/effect/overlay/temp/hierophant
	layer = BELOW_MOB_LAYER
	var/mob/living/caster

/obj/effect/overlay/temp/hierophant/New(loc, new_caster)
	..()
	caster = new_caster

/obj/effect/overlay/temp/hierophant/chaser
	duration = 98
	var/mob/living/target
	var/moving_dir
	var/previous_moving_dir
	var/more_previouser_moving_dir
	var/moving = 0
	var/speed = 3
	var/currently_seeking = FALSE

/obj/effect/overlay/temp/hierophant/chaser/New(loc, new_caster, new_target, new_speed)
	..()
	target = new_target
	if(new_speed)
		speed = new_speed
	addtimer(src, "seek_target", 0)

/obj/effect/overlay/temp/hierophant/chaser/proc/get_target_dir()
	. = get_dir(get_cardinal_step_away(src, target), src)
	if(. != previous_moving_dir && . == more_previouser_moving_dir)
		var/list/cardinal_copy = cardinal.Copy()
		cardinal_copy -= more_previouser_moving_dir
		. = pick(cardinal_copy)

/obj/effect/overlay/temp/hierophant/chaser/proc/seek_target()
	if(!currently_seeking)
		currently_seeking = TRUE
		while(target && src && !qdeleted(src) && currently_seeking && x && y && target.x && target.y)
			if(!moving)
				more_previouser_moving_dir = previous_moving_dir
				previous_moving_dir = moving_dir
				moving_dir = get_target_dir()
				var/standard_target_dir = get_dir(get_cardinal_step_away(src, target), src)
				if(. != previous_moving_dir && standard_target_dir == more_previouser_moving_dir)
					moving = 1
				else
					moving = 4
			if(moving)
				var/turf/T = get_step(src, moving_dir)
				forceMove(T)
				PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(loc, caster))
				moving--
				sleep(speed)

/obj/effect/overlay/temp/hierophant/telegraph
	icon = 'icons/effects/96x96.dmi'
	icon_state = "hierophant_telegraph"
	pixel_x = -32
	pixel_y = -32
	duration = 2

/obj/effect/overlay/temp/hierophant/telegraph/diagonal
	icon_state = "hierophant_telegraph_diagonal"

/obj/effect/overlay/temp/hierophant/telegraph/cardinal
	icon_state = "hierophant_telegraph_cardinal"

/obj/effect/overlay/temp/hierophant/telegraph/teleport
	icon_state = "hierophant_telegraph_teleport"
	duration = 9

/obj/effect/overlay/temp/hierophant/blast
	icon_state = "hierophant_blast"
	name = "vortex blast"
	luminosity = 1
	desc = "Get out of the way!"
	duration = 9
	var/damage = 10
	var/list/hurt_mobs = list()

/obj/effect/overlay/temp/hierophant/blast/New(loc, new_caster)
	..()
	hurt_mobs += new_caster
	if(istype(loc, /turf/closed/mineral))
		var/turf/closed/mineral/M = loc
		M.gets_drilled(caster)
	addtimer(src, "blast", 0)

/obj/effect/overlay/temp/hierophant/blast/proc/blast()
	var/turf/T = get_turf(src)
	if(!T)
		return
	playsound(T,'sound/magic/Blind.ogg', 200, 1, -4)
	sleep(6)
	var/timing = 15
	while(src && !qdeleted(src) && timing && T)
		timing--
		for(var/mob/living/L in T.contents - hurt_mobs)
			hurt_mobs += L
			if(L.stat != DEAD)
				if(L.client)
					flash_color(L.client, "#660099", 1)
				L << "<span class='userdanger'>You're struck by a [name]!</span>"
				L.apply_damage(damage, BRUTE)
		sleep(0.1)

/obj/effect/hierophant
	name = "hierophant rune"
	desc = "A powerful magic mark allowing whomever attunes themself to it to return to it at will."
	icon = 'icons/obj/rune.dmi'
	icon_state = "hierophant"
	anchored = TRUE
	color = "#CC00FF"
	var/mob/living/active_boss

/obj/effect/hierophant/attack_hand(mob/user)
	for(var/datum/action/innate/vortex_recall/V in user.actions)
		user << "<span class='hierophant_warning'>You touch the rune, but nothing happens.</span>"
		return
	if(active_boss)
		user << "<span class='hierophant_warning'>You touch the rune, but nothing happens.</span>"
	else
		user << "<span class='hierophant'>You touch the rune, and a burst of energy pervades your body!</span>\n\
		<span class='notice'>Return to the rune at any time by using the Vortex Recall action button.</span>"
		var/datum/action/innate/vortex_recall/V = new()
		V.rune = src
		V.Grant(user)

/obj/effect/hierophant/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE
	. = ..()

/datum/action/innate/vortex_recall
	name = "Vortex Recall"
	desc = "Allows you to return to the hierophant's arena."
	button_icon_state = "vortex_recall"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
	var/obj/effect/hierophant/rune
	var/teleporting = FALSE

/datum/action/innate/vortex_recall/IsAvailable()
	if(teleporting)
		return 0
	return ..()

/datum/action/innate/vortex_recall/Activate()
	if(!rune)
		qdel(src)
		return
	teleporting = TRUE
	owner.update_action_buttons_icon()
	owner.visible_message("<span class='hierophant_warning'>[owner] starts to glow faintly...</span>")
	if(do_after(owner, 80, target = owner) && rune)
		var/turf/T = get_turf(rune)
		var/turf/source = get_turf(owner)
		PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph, list(T, owner))
		PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph, list(source, owner))
		playsound(T,'sound/magic/blink.ogg', 200, 1)
		playsound(source,'sound/magic/blink.ogg', 200, 1)
		sleep(3)
		if(!owner)
			return
		PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/teleport, list(T, owner))
		PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/teleport, list(source, owner))
		for(var/t in RANGE_TURFS(1, T))
			PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(t, owner))
		for(var/t in RANGE_TURFS(1, source))
			PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(t, owner))
		animate(owner, alpha = 0, color = "660099", time = 2, easing = EASE_OUT)
		sleep(1)
		if(!owner)
			return
		owner.visible_message("<span class='hierophant_warning'>[owner] fades out!</span>")
		owner.density = FALSE
		sleep(3)
		if(!owner)
			return
		owner.forceMove(T)
		animate(owner, alpha = 255, color = initial(owner.color), time = 2, easing = EASE_IN)
		sleep(1)
		if(!owner)
			return
		owner.density = TRUE
		owner.visible_message("<span class='hierophant_warning'>[owner] fades in!</span>")
		sleep(1)
		if(!owner)
			return
	teleporting = FALSE
	owner.update_action_buttons_icon()

/obj/item/device/gps/internal/hierophant
	icon_state = null
	gpstag = "Zealous Signal"
	desc = "Heed its words."
	invisibility = 100

/turf/open/indestructible/hierophant
	icon_state = "hierophant1"
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	desc = "A floor with a square pattern. It's faintly cool to the touch."

/turf/open/indestructible/hierophant/New()
	..()
	if(prob(50))
		icon_state = "hierophant2"

/turf/closed/indestructible/riveted/hierophant
	name = "wall"
	desc = "A wall made out of smooth, cold stone."
	icon = 'icons/turf/walls/hierophant_wall.dmi'
	icon_state = "hierophant"
	smooth = SMOOTH_TRUE

#undef MEDAL_PREFIX