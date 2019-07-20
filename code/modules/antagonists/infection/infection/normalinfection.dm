/obj/structure/infection
	name = "infection"
	icon = 'icons/mob/infection/infection.dmi'
	light_range = 4
	desc = "A thick wall of writhing tendrils."
	density = FALSE
	spacemove_backup = TRUE
	opacity = 0
	anchored = TRUE
	layer = TABLE_LAYER
	CanAtmosPass = ATMOS_PASS_PROC
	var/point_return = 0 //How many points the commander gets back when it removes an infection of that type. If less than 0, structure cannot be removed.
	max_integrity = 30
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 70)
	var/health_regen = 5 //how much health this blob regens when pulsed
	var/next_pulse = 0
	var/pulse_cooldown = 20
	var/brute_resist = 0.75 //multiplies brute damage by this
	var/fire_resist = 0.5 //multiplies burn damage by this
	var/atmosblock = FALSE //if the infection blocks atmos and heat spread
	var/mob/camera/commander/overmind
	var/list/angles = list() // possible angles for the node to expand on
	var/timecreated
	var/build_time = 0 // time it takes to build this type when created (in deciseconds)
	var/building = FALSE // if the infection is being used to create another currently
	var/list/upgrades = list() // the actual upgrade datums
	var/list/upgrade_types = list() // the types of upgrades
	var/upgrade_subtype = null // adds all subtypes of this to the upgrade list
	var/datum/infection_menu/menu_handler

/obj/structure/infection/Initialize(mapload, owner_overmind)
	. = ..()
	if(owner_overmind)
		overmind = owner_overmind
	else if(GLOB.infection_commander)
		overmind = GLOB.infection_commander
	GLOB.infections += src //Keep track of the structure in the normal list either way
	setDir(pick(GLOB.cardinals))
	update_icon()
	if(atmosblock)
		air_update_turf(1)
	ConsumeTile()
	timecreated = world.time
	AddComponent(/datum/component/no_beacon_crossing)
	generate_upgrades()
	menu_handler = new /datum/infection_menu(src)

/obj/structure/infection/proc/generate_upgrades()
	if(ispath(upgrade_subtype))
		upgrade_types += subtypesof(upgrade_subtype)
	for(var/upgrade_type in upgrade_types)
		upgrades += new upgrade_type()

/obj/structure/infection/proc/evolve_menu(var/mob/camera/commander/C)
	if(C == overmind)
		menu_handler.ui_interact(overmind)

/obj/structure/infection/proc/max_upgrade()
	for(var/datum/infection_upgrade/U in upgrades)
		var/times = U.times
		for(var/i = 1 to times)
			U.do_upgrade(src)

/obj/structure/infection/proc/creation_action() //When it's created by the overmind, do this.
	return

/obj/structure/infection/relaymove(mob/user)
	if(istype(user, /mob/living/simple_animal/hostile/infection/infectionspore/sentient))
		var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/I = user
		I.cycle_node()
	return

/obj/structure/infection/Destroy()
	if(atmosblock)
		atmosblock = FALSE
		air_update_turf(1)
	GLOB.infections -= src //it's no longer in the all infections list either
	for(var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/I in contents)
		I.cycle_node()
	var/turf/T = get_turf(src)
	var/list/stored_contents = T.contents
	. = ..()
	for(var/atom/movable/M in stored_contents)
		Uncrossed(M) // so the overlay and move speed effects don't stay after destruction

/obj/structure/infection/blob_act()
	return

/obj/structure/infection/singularity_act()
	eat_nearby_singularity()
	return

/obj/structure/infection/tesla_act(power)
	. = ..()
	eat_nearby_singularity()
	return

/obj/structure/infection/proc/eat_nearby_singularity()
	var/list/contents_adjacent = urange(1, src)
	var/obj/singularity/to_eat = locate(/obj/singularity) in contents_adjacent
	if(to_eat)
		for(var/mob/M in range(10,src))
			if(M.client)
				flash_color(M.client, "#FB6B00", 1)
				shake_camera(M, 4, 3)
		playsound(src.loc, pick('sound/effects/curseattack.ogg', 'sound/effects/curse1.ogg', 'sound/effects/curse2.ogg', 'sound/effects/curse3.ogg', 'sound/effects/curse4.ogg',), 300, 1, pressure_affected = FALSE)
		visible_message("<span class='danger'[to_eat] is absorbed by the infection!</span>")

/obj/structure/infection/singularity_pull()
	return

/obj/structure/infection/Adjacent(var/atom/neighbour)
	. = ..()
	if(.)
		var/result = 0
		var/direction = get_dir(src, neighbour)
		var/list/dirs = list("[NORTHWEST]" = list(NORTH, WEST), "[NORTHEAST]" = list(NORTH, EAST), "[SOUTHEAST]" = list(SOUTH, EAST), "[SOUTHWEST]" = list(SOUTH, WEST))
		for(var/A in dirs)
			if(direction == text2num(A))
				for(var/B in dirs[A])
					var/C = locate(/obj/structure/infection) in get_step(src, B)
					if(C)
						result++
		. -= result - 1

/obj/structure/infection/BlockSuperconductivity()
	return atmosblock

/obj/structure/infection/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSBLOB))
		return TRUE
	return FALSE

/obj/structure/infection/CanAtmosPass(turf/T)
	// override for shield blobs etc
	return !atmosblock

/obj/structure/infection/CanAStarPass(ID, dir, caller)
	. = FALSE
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || (mover.pass_flags & PASSBLOB)

/obj/structure/infection/update_icon() //Updates color based on overmind color if we have an overmind.
	if(overmind)
		add_atom_colour(overmind.infection_color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)

/obj/structure/infection/process()
	Life()

/obj/structure/infection/proc/Life()
	return

/obj/structure/infection/proc/reset_angles()
	angles = list(0,15,30,45,60,75,90,105,120,135,150,165,180,195,210,225,240,255,270,285,300,315,330,345) // this is aids but you cant use initial() on lists so :shrug: i'd rather not loop

/obj/structure/infection/proc/Pulse_Area(mob/camera/commander/pulsing_overmind, claim_range = 6, count = 6, space_expand = FALSE)
	if(QDELETED(pulsing_overmind))
		pulsing_overmind = overmind
	Be_Pulsed()
	ConsumeTile()
	next_pulse = world.time + pulse_cooldown
	for(var/i = 1 to count)
		if(!angles.len)
			reset_angles()
		var/angle = pick(angles)
		angles -= angle
		angle += rand(-7, 7)
		var/turf/check = src
		for(var/j = 1 to claim_range)
			check = locate(src.x + cos(angle) * j, src.y + sin(angle) * j, src.z)
			if(!check || check.is_transition_turf())
				check = locate(src.x + cos(angle) * (j - 1), src.y + sin(angle) * (j - 1), src.z)
				break
		if(!check)
			continue
		var/list/toaffect = getline(src, check)
		var/obj/structure/infection/previous = src
		if(!toaffect)
			continue
		for(var/j = 2 to toaffect.len)
			var/obj/structure/infection/INF = locate(/obj/structure/infection) in toaffect[j]
			if(!INF)
				var/dir_to_next = get_dir(toaffect[j-1], toaffect[j])
				// okay i know we said we were totally going to expand to toaffect[j] but cardinals look cleaner (connectivity) so we'll check if those are empty
				var/turf/finalturf = get_final_expand_turf(toaffect[j-1], toaffect[j], dir_to_next)
				previous.expand(finalturf, overmind, space_expand)
				break
			INF.ConsumeTile()
			INF.air_update_turf(1)
			INF.Be_Pulsed()
			previous = INF

/obj/structure/infection/proc/get_final_expand_turf(var/turf/lastturf, var/turf/finalturf, var/dir_to_next)
	var/list/checkturfs = list()
	if(dir_to_next in GLOB.diagonals)
		var/list/random_cardinals = GLOB.cardinals.Copy()
		while(random_cardinals.len)
			var/checkdir = pick_n_take(random_cardinals)
			if(dir_to_next & checkdir)
				checkturfs += get_step(lastturf, checkdir)
	for(var/turf/checkturf in checkturfs)
		if(locate(/obj/structure/infection) in checkturf.contents)
			continue
		return checkturf
	return finalturf

/obj/structure/infection/proc/Be_Pulsed()
	ConsumeTile()
	obj_integrity = min(max_integrity, obj_integrity+health_regen)
	update_icon()
	var/turf/T = get_turf(src)
	if(istype(T, /turf/open/chasm))
		T.ChangeTurf(/turf/open/space)

/obj/structure/infection/proc/ConsumeTile()
	for(var/atom/A in loc)
		if(isliving(A) || ismecha(A))
			continue
		A.blob_act(src)
	if(iswallturf(loc))
		loc.blob_act(src) //don't ask how a wall got on top of the core, just eat it

/obj/structure/infection/proc/infection_attack_animation(atom/A = null) //visually attacks an atom
	var/obj/effect/temp_visual/infection/O = new /obj/effect/temp_visual/infection(src.loc)
	O.setDir(dir)
	if(overmind)
		O.color = overmind.infection_color
	if(A)
		O.do_attack_animation(A) //visually attack the whatever
	return O //just in case you want to do something to the animation.

/obj/structure/infection/proc/expand(turf/T = null, controller = null, space_expand = FALSE)
	infection_attack_animation(T)
	// do not expand to areas that are space, unless we're very lucky or the core
	if(isspaceturf(T) && !(locate(/obj/structure/lattice) in T) && !space_expand && prob(80))
		return null
	if(locate(/obj/structure/beacon_wall) in T.contents || locate(/obj/structure/infection) in T.contents)
		return
	var/obj/structure/infection/I = new /obj/structure/infection/normal(src.loc, (controller || overmind))
	I.density = TRUE
	if(T.Enter(I,src))
		I.density = initial(I.density)
		I.forceMove(T)
		I.update_icon()
		I.ConsumeTile()
		if(T.dynamic_lighting == FALSE)
			T.dynamic_lighting = TRUE
			T.lighting_build_overlay()
		return I
	else
		T.blob_act(src)
		for(var/atom/A in T)
			A.blob_act(src) //also hit everything in the turf
		qdel(I)
		return null

/obj/structure/infection/emp_act(severity)
	. = ..()
	return

/obj/structure/infection/ex_act(severity)
	take_damage(30/severity * 4, BRUTE, "bomb", 0)

/obj/structure/infection/extinguish()
	..()
	return

/obj/structure/infection/hulk_damage()
	return 15

/obj/structure/infection/attack_animal(mob/living/simple_animal/M)
	if(ROLE_INFECTION in M.faction) //sorry, but you can't kill the infection as an infectious creature
		return
	..()

/obj/structure/infection/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, pick('sound/effects/picaxe1.ogg', 'sound/effects/picaxe2.ogg', 'sound/effects/picaxe3.ogg'), 50, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/structure/infection/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	switch(damage_type)
		if(BRUTE)
			damage_amount *= brute_resist
		if(BURN)
			damage_amount *= fire_resist
		if(CLONE)
		else
			return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor.getRating(damage_flag)
	damage_amount = round(damage_amount * (100 - armor_protection)*0.01, 0.1)
	return damage_amount

/obj/structure/infection/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		update_icon()

/obj/structure/infection/obj_destruction(damage_flag)
	..()

/obj/structure/infection/proc/change_to(type, controller, structure_build_time)
	if(!ispath(type))
		throw EXCEPTION("change_to(): invalid type for infection")
		return
	if(building)
		return // no
	var/obj/structure/infection/I = new type(src.loc, controller)
	if(structure_build_time == null)
		structure_build_time = I.build_time
	var/obj/effect/overlay/vis/newicon = new
	newicon.icon = I.icon
	newicon.icon_state = I.icon_state
	newicon.dir = I.dir
	newicon.pixel_x = I.pixel_x
	newicon.pixel_y = I.pixel_y
	newicon.layer = TABLE_LAYER
	if(overmind)
		newicon.color = overmind.infection_color
	newicon.transform = matrix(0.5, 0, 0, 0, 0.5, 0)
	animate(newicon, transform = matrix(), time = structure_build_time)
	vis_contents += newicon
	name = "building [I.name]"
	building = type
	qdel(I)
	sleep(structure_build_time)
	I = new type(src.loc, controller)
	I.creation_action()
	I.update_icon()
	I.setDir(dir)
	qdel(src)
	return I

/obj/structure/infection/normal
	name = "normal infection"
	icon_state = "normal"
	layer = TURF_LAYER
	light_range = 2
	obj_integrity = 25
	max_integrity = 25
	health_regen = 3
	brute_resist = 0.25
	var/overlay_fade_time = 40 // time in deciseconds for overlay on entering and exiting to fade in and fade out

/obj/structure/infection/normal/evolve_menu(var/mob/camera/commander/C)
	return

/obj/structure/infection/normal/CanPass(atom/movable/mover, turf/target)
	return TRUE

/obj/structure/infection/normal/Crossed(atom/movable/mover)
	if(istype(mover) && (mover.pass_flags & PASSBLOB))
		return TRUE
	if(ismob(mover))
		var/mob/M = mover
		M.add_movespeed_modifier(MOVESPEED_ID_INFECTION_STRUCTURE, update=TRUE, priority=100, multiplicative_slowdown=3)
		M.overlay_fullscreen("infectionvision", /obj/screen/fullscreen/curse, 1)

/obj/structure/infection/normal/Uncrossed(atom/movable/mover)
	if(!locate(/obj/structure/infection/normal) in get_turf(mover))
		if(ismob(mover))
			var/mob/M = mover
			M.remove_movespeed_modifier(MOVESPEED_ID_INFECTION_STRUCTURE, update = TRUE)
			M.clear_fullscreen("infectionvision", overlay_fade_time)

/obj/structure/infection/normal/update_icon()
	..()
	if(building)
		return
	if(obj_integrity <= 15)
		icon_state = "normal"
		name = "fragile infection"
		desc = "A thin lattice of slightly twitching tendrils."
	else if (overmind)
		icon_state = "normal"
		name = "infection"
		desc = "A thick wall of writhing tendrils."
	else
		icon_state = "normal"
		name = "dead infection"
		desc = "A thick wall of lifeless tendrils."
		light_range = 0
