///LAVA

/turf/open/lava
	name = "lava"
	icon_state = "lava"
	gender = PLURAL //"That's some lava."
	baseturfs = /turf/open/lava //lava all the way down
	slowdown = 2

	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA
	bullet_bounce_sound = 'sound/items/welder2.ogg'

	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA
	/// How much fire damage we deal to living mobs stepping on us
	var/lava_damage = 20
	/// How many firestacks we add to living mobs stepping on us
	var/lava_firestacks = 20
	/// How much temperature we expose objects with
	var/temperature_damage = 10000

/turf/open/lava/ex_act(severity, target)
	contents_explosion(severity, target)

/turf/open/lava/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/lava/Melt()
	to_be_destroyed = FALSE
	return src

/turf/open/lava/acid_act(acidpwr, acid_volume)
	return FALSE

/turf/open/lava/MakeDry(wet_setting = TURF_WET_WATER)
	return

/turf/open/lava/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/lava/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(burn_stuff(arrived))
		START_PROCESSING(SSobj, src)

/turf/open/lava/Exited(atom/movable/gone, direction)
	. = ..()
	if(isliving(gone))
		var/mob/living/L = gone
		if(!islava(get_step(src, direction)))
			REMOVE_TRAIT(L, TRAIT_PERMANENTLY_ONFIRE, TURF_TRAIT)
		if(!L.on_fire)
			L.update_fire()

/turf/open/lava/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(burn_stuff(AM))
		START_PROCESSING(SSobj, src)

/turf/open/lava/process(delta_time)
	if(!burn_stuff(null, delta_time))
		STOP_PROCESSING(SSobj, src)

/turf/open/lava/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 3)
	return FALSE

/turf/open/lava/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, span_notice("You build a floor."))
			PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			return TRUE
	return FALSE

/turf/open/lava/singularity_act()
	return

/turf/open/lava/singularity_pull(S, current_size)
	return

/turf/open/lava/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/open/lava/GetHeatCapacity()
	. = 700000

/turf/open/lava/GetTemperature()
	. = 5000

/turf/open/lava/TakeTemperature(temp)

/turf/open/lava/attackby(obj/item/C, mob/user, params)
	..()
	if(istype(C, /obj/item/stack/rods/lava))
		var/obj/item/stack/rods/lava/R = C
		var/obj/structure/lattice/lava/H = locate(/obj/structure/lattice/lava, src)
		if(H)
			to_chat(user, span_warning("There is already a lattice here!"))
			return
		if(R.use(1))
			to_chat(user, span_notice("You construct a lattice."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			new /obj/structure/lattice/lava(locate(x, y, z))
		else
			to_chat(user, span_warning("You need one rod to build a heatproof lattice."))
		return

/turf/open/lava/proc/is_safe()
	//if anything matching this typecache is found in the lava, we don't burn things
	var/static/list/lava_safeties_typecache = typecacheof(list(/obj/structure/lattice/catwalk, /obj/structure/stone_tile, /obj/structure/lattice/lava))
	var/list/found_safeties = typecache_filter_list(contents, lava_safeties_typecache)
	for(var/obj/structure/stone_tile/S in found_safeties)
		if(S.fallen)
			LAZYREMOVE(found_safeties, S)
	return LAZYLEN(found_safeties)


/turf/open/lava/proc/burn_stuff(AM, delta_time = 1)
	if(is_safe())
		return FALSE

	var/thing_to_check = src
	if (AM)
		thing_to_check = list(AM)
	for(var/atom/movable/burn_target as anything in thing_to_check)
		if(burn_target.movement_type & (FLYING|FLOATING) || burn_target.throwing) //YOU'RE FLYING OVER IT
			continue
		if(isobj(burn_target))
			var/obj/burn_obj = burn_target
			. = TRUE
			if((burn_obj.resistance_flags & (LAVA_PROOF|ON_FIRE)))
				continue
			if(!(burn_obj.resistance_flags & FLAMMABLE))
				burn_obj.resistance_flags |= FLAMMABLE //Even fireproof things burn up in lava
			if(burn_obj.resistance_flags & FIRE_PROOF)
				burn_obj.resistance_flags &= ~FIRE_PROOF
			if(burn_obj.armor.fire > 50) //obj with 100% fire armor still get slowly burned away.
				burn_obj.armor = burn_obj.armor.setRating(fire = 50)
			burn_obj.fire_act(temperature_damage, 1000 * delta_time)
			if(istype(burn_obj, /obj/structure/closet))
				var/obj/structure/closet/burn_closet = burn_obj
				for(var/burn_content in burn_closet.contents)
					burn_stuff(burn_content)
		else if (isliving(burn_target))
			. = TRUE
			var/mob/living/burn_living = burn_target
			var/atom/movable/burn_buckled = burn_living.buckled
			if(burn_buckled)
				if(burn_buckled.movement_type & (FLYING|FLOATING) || burn_buckled.throwing)
					continue
				if(isobj(burn_buckled))
					var/obj/burn_buckled_obj = burn_buckled
					if(burn_buckled_obj.resistance_flags & LAVA_PROOF)
						continue
				else if(isliving(burn_buckled))
					var/mob/living/burn_buckled_live = burn_buckled
					if(WEATHER_LAVA in burn_buckled_live.weather_immunities)
						continue

			if(iscarbon(burn_living))
				var/mob/living/carbon/burn_carbon = burn_living
				var/obj/item/clothing/burn_suit = burn_carbon.get_item_by_slot(ITEM_SLOT_OCLOTHING)
				var/obj/item/clothing/burn_helmet = burn_carbon.get_item_by_slot(ITEM_SLOT_HEAD)

				if(burn_suit?.clothing_flags & LAVAPROTECT && burn_helmet?.clothing_flags & LAVAPROTECT)
					return

			if(WEATHER_LAVA in burn_living.weather_immunities)
				continue

			ADD_TRAIT(burn_living, TRAIT_PERMANENTLY_ONFIRE, TURF_TRAIT)
			burn_living.update_fire()

			burn_living.adjustFireLoss(lava_damage * delta_time)
			if(burn_living) //mobs turning into object corpses could get deleted here.
				burn_living.adjust_fire_stacks(lava_firestacks * delta_time)
				burn_living.IgniteMob()

/turf/open/lava/smooth
	name = "lava"
	baseturfs = /turf/open/lava/smooth
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "lava-255"
	base_icon_state = "lava"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_LAVA)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_LAVA)

/turf/open/lava/smooth/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/lava_land_surface

/turf/open/lava/smooth/airless
	initial_gas_mix = AIRLESS_ATMOS
