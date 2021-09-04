/obj/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
	embedding = null
	shrapnel_type = null

/obj/projectile/bullet/gyro/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, devastation_range = -1, light_impact_range = 2)
	return BULLET_ACT_HIT

/// PM9 HEDP rocket
/obj/projectile/bullet/a84mm
	name ="\improper HEDP rocket"
	desc = "USE A WEEL GUN"
	icon_state= "84mm-hedp"
	damage = 80
	armour_penetration = 100
	dismemberment = 100
	embedding = null
	shrapnel_type = null
	/// Whether we do extra damage when hitting a mech or silicon
	var/anti_armour_damage = 200

/obj/projectile/bullet/a84mm/on_hit(atom/target, blocked = FALSE)
	if(isliving(target) && prob(1))
		var/mob/living/gibbed_dude = target
		if(gibbed_dude.stat < HARD_CRIT)
			gibbed_dude.say("Is that a fucking ro-", forced = "hit by rocket")
	..()

	do_boom(target)
	if(anti_armour_damage && ismecha(target))
		var/obj/vehicle/sealed/mecha/M = target
		M.take_damage(anti_armour_damage)
	if(issilicon(target))
		var/mob/living/silicon/S = target
		S.take_overall_damage(anti_armour_damage*0.75, anti_armour_damage*0.25)
	return BULLET_ACT_HIT

/// Since some rockets have different booms depending if they hit a living target or not, this is easier than having explosive radius vars
/obj/projectile/bullet/a84mm/proc/do_boom(atom/target)
	explosion(target, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, flame_range = 4, flash_range = 1, adminlog = FALSE)

/// PM9 standard rocket
/obj/projectile/bullet/a84mm/he
	name ="\improper HE missile"
	desc = "Boom."
	icon_state = "missile"
	damage = 50
	anti_armour_damage = 0

/obj/projectile/bullet/a84mm/he/do_boom(atom/target, blocked=0)
	if(!isliving(target)) //if the target isn't alive, so is a wall or something
		explosion(target, heavy_impact_range = 1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	else
		explosion(target, light_impact_range = 2, flame_range = 3, flash_range = 4)

/// PM9 weak rocket
/obj/projectile/bullet/a84mm/weak
	name ="low-yield HE missile"
	desc = "Boom, but less so."
	damage = 30
	anti_armour_damage = 0

/obj/projectile/bullet/a84mm/weak/do_boom(atom/target, blocked=0)
	if(!isliving(target)) //if the target isn't alive, so is a wall or something
		explosion(target, heavy_impact_range = 1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	else
		explosion(target, light_impact_range = 2, flame_range = 3, flash_range = 4)

/// Tacticool (Useless) ammo for the PML and subtypes
/obj/projectile/bullet/a84mm/sabot
	name = "\improper APCBCFSDSGLAT missile"
	desc = "Pray this isn't coming straigh at you."
	icon_state = "84mm-sabot"
	damage = 150
	anti_armour_damage = 200
	wound_bonus = 50
	projectile_piercing = PASSMOB //Look up modern tank APFSDS shells to see why for this one
	ricochets_max = 5
	ricochet_chance = 120
	ricochet_auto_aim_range = 3
	ricochet_incidence_leeway = 70
	knockdown = 100

/obj/projectile/bullet/a84mm/sabot/do_boom(atom/target)
	explosion(target, flash_range = 2) //Shells so goddamn powerful, they create a flash of light with everything they impact

/obj/projectile/bullet/a84mm/emp
	name = "\improper GLEMPS missile"
	desc = "Point at ai, fire, pray."
	icon_state = "84mm-emp"
	damage = 30
	anti_armour_damage = 0
	dismemberment = 0
	knockdown = 50

/obj/projectile/bullet/a84mm/emp/do_boom(atom/target)
	empulse(target, 2, 5)

/obj/projectile/bullet/a84mm/smoke
	name = "\improper HVSD missile"
	desc = "Tactically fast smoke in 30 minutes or its free!"
	icon_state = "84mm-smoke"
	damage = 40 //Fuckin' ow dude, you just got direct hit by a rocket
	anti_armour_damage = 0
	dismemberment = 0 //You aren't going to be delimbed by a really fast smoke grenade
	knockdown = 100 //You have been direct hit by a missile

/obj/projectile/bullet/a84mm/smoke/do_boom(atom/target)
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/smoke_spread/bad/smoke = new
	smoke.set_up(7, src) //Big smoke, you're using a rocket for a reason
	smoke.start()
	qdel(smoke)

/obj/projectile/bullet/a84mm/smoke/phosphor
	name = "\improper HVWP missile"
	desc = "Nothing beats the smell."
	icon_state = "84mm-coldsmoke"

/obj/projectile/bullet/a84mm/smoke/phosphor/do_boom(atom/target)
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/smoke_spread/freezing/smoke = new
	smoke.set_up(7, src)
	smoke.start()
	qdel(smoke)
	explosion(target, flame_range = 7, flash_range = 2)

/obj/projectile/bullet/a84mm/smoke/sleeping
	name = "\improper RCSD missile"
	desc = "What's this sleep gas stuff made of anyway?"
	icon_state = "84mm-sleepsmoke"

/obj/projectile/bullet/a84mm/smoke/sleeping/do_boom(atom/target)
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/smoke_spread/sleeping/smoke = new
	smoke.set_up(5, src)
	smoke.start()
	qdel(smoke)

/// Mech BRM-6 missile
/obj/projectile/bullet/a84mm_br
	name ="\improper HE missile"
	desc = "Boom."
	icon_state = "missile"
	damage = 30
	ricochets_max = 0 //it's a MISSILE
	embedding = null
	shrapnel_type = null
	var/sturdy = list(
	/turf/closed,
	/obj/vehicle/sealed/mecha,
	/obj/machinery/door,
	/obj/structure/window,
	/obj/structure/grille
	)

/obj/item/broken_missile
	name = "\improper broken missile"
	desc = "A missile that did not detonate. The tail has snapped and it is in no way fit to be used again."
	icon = 'icons/obj/guns/projectiles.dmi'
	icon_state = "missile_broken"
	w_class = WEIGHT_CLASS_TINY


/obj/projectile/bullet/a84mm_br/on_hit(atom/target, blocked=0)
	..()
	for(var/i in sturdy)
		if(istype(target, i))
			explosion(target, heavy_impact_range = 1, light_impact_range = 1, flash_range = 2)
			return BULLET_ACT_HIT
	//if(istype(target, /turf/closed) || ismecha(target))
	new /obj/item/broken_missile(get_turf(src), 1)
