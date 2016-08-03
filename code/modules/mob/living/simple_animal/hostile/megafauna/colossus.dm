
#define MEDAL_PREFIX "Colossus"
/*

COLOSSUS

The colossus spawns randomly wherever a lavaland creature is able to spawn. It is powerful, ancient, and extremely deadly.
The colossus has a degree of sentience, proving this in speech during its attacks.

It acts as a melee creature, chasing down and attacking its target while also using different attacks to augment its power that increase as it takes damage.

The colossus' true danger lies in its ranged capabilities. It fires immensely damaging death bolts that penetrate all armor in a variety of ways:
 1. The colossus fires death bolts in alternating patterns: the cardinal directions and the diagonal directions.
   1.2 If hurt, may fire at both cardinal and diagonal directions at once.
 2. The colossus fires death bolts in a shotgun-like pattern, instantly downing anything unfortunate enough to be hit by all of them.
 3. The colossus fires a spiral of death bolts.
At 33% health, the colossus gains an additional attack:
 4. The colossus fires two spirals of death bolts, spinning in either opposite directions or the same direction.

When a colossus dies, it leaves behind a chunk of glowing crystal known as a black box. Anything placed inside will carry over into future rounds.
For instance, you could place a bag of holding into the black box, and then kill another colossus next round and retrieve the bag of holding from inside.

Difficulty: Very Hard

*/

/mob/living/simple_animal/hostile/megafauna/colossus
	name = "colossus"
	desc = "A monstrous creature protected by heavy shielding."
	health = 2500
	maxHealth = 2500
	attacktext = "judges"
	attack_sound = 'sound/magic/clockwork/ratvar_attack.ogg'
	icon_state = "eva"
	icon_living = "eva"
	icon_dead = "dragon_dead"
	friendly = "stares down"
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	faction = list("mining")
	weather_immunities = list("lava","ash")
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 1
	move_to_delay = 10
	ranged = 1
	flying = 1
	mob_size = MOB_SIZE_LARGE
	pixel_x = -32
	aggro_vision_range = 18
	idle_vision_range = 5
	del_on_death = 1
	medal_type = MEDAL_PREFIX
	score_type = COLOSSUS_SCORE
	loot = list(/obj/machinery/smartfridge/black_box)
	butcher_results = list(/obj/item/weapon/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/animalhide/ashdrake = 10, /obj/item/stack/sheet/bone = 30)

	deathmessage = "disintegrates, leaving a glowing core in its wake."
	death_sound = 'sound/magic/demon_dies.ogg'
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	var/anger_modifier = 0
	var/minor_cooldown = 20 //time, in deciseconds, a minor attack causes it to cool down for
	var/medium_cooldown = 40 //time, in deciseconds, a medium attack causes it to cool down for
	var/major_cooldown = 120 //time, in deciseconds, a minor attack causes it to cool down for
	var/obj/item/device/gps/internal

/mob/living/simple_animal/hostile/megafauna/colossus/devour(mob/living/L)
	visible_message("<span class='colossus'>[src] disintegrates [L]!</span>")
	L.dust()

/mob/living/simple_animal/hostile/megafauna/colossus/OpenFire()
	anger_modifier = Clamp(((maxHealth - health)/50),0,20)

	if(prob(20 + anger_modifier)) //Major attack
		ranged_cooldown = world.time + major_cooldown
		telegraph()

		if(health < maxHealth/3)
			double_spiral()
		else
			visible_message("<span class='colossus'>\"<b>Judgement.</b>\"</span>")
			spiral_shoot(rand(0, 1), rand(1, 16))

	else //Minor attack
		if(prob(20 + anger_modifier))
			ranged_cooldown = world.time + medium_cooldown
			random_shots()
		else
			if(prob(70))
				ranged_cooldown = world.time + minor_cooldown
				blast()
			else
				ranged_cooldown = world.time + medium_cooldown
				if(prob(10 + anger_modifier))
					dir_shots(alldirs)
					sleep(8)
					dir_shots(alldirs)
				else
					dir_shots(diagonals)
					sleep(8)
					dir_shots(cardinal)
					sleep(8)
					dir_shots(diagonals)
					sleep(8)
					dir_shots(cardinal)


/mob/living/simple_animal/hostile/megafauna/colossus/New()
	..()
	internal = new/obj/item/device/gps/internal/colossus(src)

/mob/living/simple_animal/hostile/megafauna/colossus/Destroy()
	qdel(internal)
	. = ..()

/obj/effect/overlay/temp/at_shield
	name = "anti-toolbox field"
	desc = "A shimmering forcefield protecting the colossus."
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield2"
	layer = FLY_LAYER
	luminosity = 2
	duration = 8
	var/target

/obj/effect/overlay/temp/at_shield/New(new_loc, new_target)
	..()
	target = new_target
	addtimer(src, "orbit", 0, FALSE, target, 0, FALSE, 0, 0, FALSE, TRUE)

/mob/living/simple_animal/hostile/megafauna/colossus/bullet_act(obj/item/projectile/P)
	if(!stat)
		var/obj/effect/overlay/temp/at_shield/AT = PoolOrNew(/obj/effect/overlay/temp/at_shield, src.loc, src)
		var/random_x = rand(-32, 32)
		AT.pixel_x += random_x

		var/random_y = rand(0, 72)
		AT.pixel_y += random_y
	..()


/mob/living/simple_animal/hostile/megafauna/colossus/proc/double_spiral()
	visible_message("<span class='colossus'>\"<b>Die.</b>\"</span>")

	sleep(10)
	if(prob(50)) //overlapping spirals
		switch(rand(1, 8))
			if(1) //start east and west, east goes counterclockwise, west goes clockwise
				addtimer(src, "spiral_shoot", 0, FALSE, 1, 13) //east
				addtimer(src, "spiral_shoot", 0, FALSE, 0, 5) //west
			if(2) //start east and west, east goes clockwise, west goes counterclockwise
				addtimer(src, "spiral_shoot", 0, FALSE, 0, 13) //east
				addtimer(src, "spiral_shoot", 0, FALSE, 1, 5) //west
			if(3) //start north and south, north goes counterclockwise, south goes clockwise
				addtimer(src, "spiral_shoot", 0, FALSE, 1, 9) //north
				addtimer(src, "spiral_shoot", 0, FALSE, 0, 1) //south
			if(4) //start north and south, north goes clockwise, south goes counterclockwise
				addtimer(src, "spiral_shoot", 0, FALSE, 0, 9) //north
				addtimer(src, "spiral_shoot", 0, FALSE, 1, 1) //south
			if(5) //start northeast and southwest, northeast goes counterclockwise, southwest goes clockwise
				addtimer(src, "spiral_shoot", 0, FALSE, 1, 11) //northeast
				addtimer(src, "spiral_shoot", 0, FALSE, 0, 3) //southwest
			if(6) //start northeast and southwest, northeast goes clockwise, southwest goes counterclockwise
				addtimer(src, "spiral_shoot", 0, FALSE, 0, 11) //northeast
				addtimer(src, "spiral_shoot", 0, FALSE, 1, 3) //southwest
			if(7) //start northwest and southeast, northwest goes counterclockwise, southeast goes clockwise
				addtimer(src, "spiral_shoot", 0, FALSE, 1, 7) //northwest
				addtimer(src, "spiral_shoot", 0, FALSE, 0, 15) //southeast
			if(8) //start northwest and southeast, northwest goes clockwise, southeast goes counterclockwise
				addtimer(src, "spiral_shoot", 0, FALSE, 0, 7) //northwest
				addtimer(src, "spiral_shoot", 0, FALSE, 1, 15) //southeast
	else //non-overlapping spirals
		switch(rand(1, 8))
			if(1) //start east and west, both clockwise
				addtimer(src, "spiral_shoot", 0, FALSE, 0, 13) //east
				addtimer(src, "spiral_shoot", 0, FALSE, 0, 5) //west
			if(2) //start east and west, both counterclockwise
				addtimer(src, "spiral_shoot", 0, FALSE, 1, 13) //east
				addtimer(src, "spiral_shoot", 0, FALSE, 1, 5) //west
			if(3) //start north and south, both clockwise
				addtimer(src, "spiral_shoot", 0, FALSE, 0, 9) //north
				addtimer(src, "spiral_shoot", 0, FALSE, 0, 1) //south
			if(4) //start north and south, both counterclockwise
				addtimer(src, "spiral_shoot", 0, FALSE, 1, 9) //north
				addtimer(src, "spiral_shoot", 0, FALSE, 1, 1) //south
			if(5) //start northeast and southwest, both clockwise
				addtimer(src, "spiral_shoot", 0, FALSE, 0, 11) //northeast
				addtimer(src, "spiral_shoot", 0, FALSE, 0, 3) //southwest
			if(6) //start northeast and southwest, both counterclockwise
				addtimer(src, "spiral_shoot", 0, FALSE, 1, 11) //northeast
				addtimer(src, "spiral_shoot", 0, FALSE, 1, 3) //southwest
			if(7) //start northwest and southeast, both clockwise
				addtimer(src, "spiral_shoot", 0, FALSE, 0, 7) //northwest
				addtimer(src, "spiral_shoot", 0, FALSE, 0, 15) //southeast
			if(8) //start northwest and southeast, both counterclockwise
				addtimer(src, "spiral_shoot", 0, FALSE, 1, 7) //northwest
				addtimer(src, "spiral_shoot", 0, FALSE, 1, 15) //southeast

/mob/living/simple_animal/hostile/megafauna/colossus/proc/spiral_shoot(negative = 0, counter_start = 1)
	var/counter = counter_start
	var/turf/marker
	for(var/i in 1 to 80)
		switch(counter)
			if(1)
				marker = locate(x, y - 2, z)
			if(2)
				marker = locate(x - 1, y - 2, z)
			if(3)
				marker = locate(x - 2, y - 2, z)
			if(4)
				marker = locate(x - 2, y - 1, z)
			if(5)
				marker = locate(x - 2, y, z)
			if(6)
				marker = locate(x - 2, y + 1, z)
			if(7)
				marker = locate(x - 2, y + 2, z)
			if(8)
				marker = locate(x - 1, y + 2, z)
			if(9)
				marker = locate(x, y + 2, z)
			if(10)
				marker = locate(x + 1, y + 2, z)
			if(11)
				marker = locate(x + 2, y + 2, z)
			if(12)
				marker = locate(x + 2, y + 1, z)
			if(13)
				marker = locate(x + 2, y, z)
			if(14)
				marker = locate(x + 2, y - 1, z)
			if(15)
				marker = locate(x + 2, y - 2, z)
			if(16)
				marker = locate(x + 1, y - 2, z)

		if(negative)
			counter--
		else
			counter++
		if(counter > 16)
			counter = 0
		if(counter < 0)
			counter = 16
		shoot_projectile(marker)
		playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 20, 1)
		sleep(1)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/shoot_projectile(turf/marker)
	if(!marker)
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/colossus(startloc)
	P.current = startloc
	P.starting = startloc
	P.firer = src
	P.yo = marker.y - startloc.y
	P.xo = marker.x - startloc.x
	P.original = marker
	P.fire()

/mob/living/simple_animal/hostile/megafauna/colossus/proc/random_shots()
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 200, 1, 5)
	for(var/turf/turf in range(12,get_turf(src)))
		if(prob(5))
			shoot_projectile(turf)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/blast()
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 150, 1, 2)
	for(var/turf/turf in range(1, target))
		shoot_projectile(turf)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/dir_shots(list/dirs)
	if(!islist(dirs))
		dirs = alldirs.Copy()
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 150, 1, 2)
	for(var/d in dirs)
		var/turf/E = get_step(src, d)
		shoot_projectile(E)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/telegraph()
	for(var/mob/M in range(10,src))
		if(M.client)
			flash_color(M.client, rgb(200, 0, 0), 1)
			shake_camera(M, 4, 3)
	playsound(get_turf(src),'sound/magic/clockwork/narsie_attack.ogg', 200, 1)



/obj/item/projectile/colossus
	name ="death bolt"
	icon_state= "chronobolt"
	damage = 25
	armour_penetration = 100
	speed = 2
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE

/obj/item/projectile/colossus/on_hit(atom/target, blocked = 0)
	. = ..()
	if(isturf(target) || isobj(target))
		target.ex_act(2)


/obj/item/device/gps/internal/colossus
	icon_state = null
	gpstag = "Angelic Signal"
	desc = "Get in the fucking robot."
	invisibility = 100



//Black Box

/obj/machinery/smartfridge/black_box
	name = "black box"
	desc = "A completely indestructible chunk of crystal, rumoured to predate the start of this universe. It looks like you could store things inside it."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_on = "blackbox"
	icon_off = "blackbox"
	luminosity = 8
	max_n_of_items = 200
	pixel_y = -4
	use_power = 0
	var/duplicate = FALSE
	var/memory_saved = FALSE
	var/list/stored_items = list()
	var/list/blacklist = (/obj/item/weapon/spellbook)

/obj/machinery/smartfridge/black_box/accept_check(obj/item/O)
	if(O.type in blacklist)
		return
	if(istype(O, /obj/item))
		return 1
	return 0

/obj/machinery/smartfridge/black_box/New()
	..()
	for(var/obj/machinery/smartfridge/black_box/B in machines)
		if(B != src)
			duplicate = 1
			qdel(src)
	ReadMemory()

/obj/machinery/smartfridge/black_box/process()
	..()
	if(ticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		WriteMemory()

/obj/machinery/smartfridge/black_box/proc/WriteMemory()
	var/savefile/S = new /savefile("data/npc_saves/Blackbox.sav")
	stored_items = list()
	for(var/obj/I in component_parts)
		qdel(I)
	for(var/obj/O in contents)
		stored_items += O.type
	S["stored_items"]				<< stored_items
	memory_saved = TRUE

/obj/machinery/smartfridge/black_box/proc/ReadMemory()
	var/savefile/S = new /savefile("data/npc_saves/Blackbox.sav")
	S["stored_items"] 		>> stored_items

	if(isnull(stored_items))
		stored_items = list()

	for(var/item in stored_items)
		new item(src)


/obj/machinery/smartfridge/black_box/Destroy()
	if(duplicate)
		return ..()
	else
		return QDEL_HINT_LETMELIVE


//No taking it apart

/obj/machinery/smartfridge/black_box/default_deconstruction_screwdriver()
	return

/obj/machinery/smartfridge/black_box/exchange_parts()
	return


/obj/machinery/smartfridge/black_box/default_pry_open()
	return


/obj/machinery/smartfridge/black_box/default_unfasten_wrench()
	return

/obj/machinery/smartfridge/black_box/default_deconstruction_crowbar()
	return

#undef MEDAL_PREFIX