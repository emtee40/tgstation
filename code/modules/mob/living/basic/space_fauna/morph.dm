/mob/living/basic/morph
	name = "morph"
	real_name = "morph"
	desc = "A revolting, pulsating pile of flesh."
	speak_emote = list("gurgles")
	emote_hear = list("gurgles")
	icon = 'icons/mob/simple/animal.dmi'
	icon_state = "morph"
	icon_living = "morph"
	icon_dead = "morph_dead"
	combat_mode = TRUE

	mob_biotypes = MOB_BEAST
	pass_flags = PASSTABLE

	maxHealth = 150
	health = 150
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = TCMB

	obj_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 20

	// Oh you KNOW it's gonna be real green
	lighting_cutoff_red = 10
	lighting_cutoff_green = 35
	lighting_cutoff_blue = 15

	attack_verb_continuous = "glomps"
	attack_verb_simple = "glomp"
	attack_sound = 'sound/effects/blobattack.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE //nom nom nom
	butcher_results = list(/obj/item/food/meat/slab = 2)

	/// How much damage are we doing while disguised?
	var/melee_damage_disguised = 0
	/// Can we eat while disguised?
	var/eat_while_disguised = FALSE
	/// What are we disguised as?
	var/atom/movable/form = null
	/// Stuff that we can not disguise as.
	var/static/list/blacklist_typecache = typecacheof(list(
		/atom/movable/screen,
		/mob/living/basic/morph,
		/obj/effect,
		/obj/energy_ball,
		/obj/narsie,
		/obj/singularity,
	))

/mob/living/basic/morph/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/content_barfer)

/mob/living/basic/morph/examine(mob/user)
	if(isnull(form))
		return ..()

	. = form.examine(user)
	if(get_dist(user,src) <= 3)
		. += span_warning("It doesn't look quite right...")

/mob/living/basic/morph/med_hud_set_health()
	if(isliving(form))
		return ..()

	//we hide medical hud while morphed
	var/image/holder = hud_list[HEALTH_HUD]
	holder.icon_state = null

/mob/living/basic/morph/med_hud_set_status()
	if(isliving(form))
		return ..()

	//we hide medical hud while morphed
	var/image/holder = hud_list[STATUS_HUD]
	holder.icon_state = null

/// Simple check to see if we are allowed to disguise as something.
/mob/living/basic/morph/proc/allowed_to_disguise_as(atom/movable/checkable)
	return !is_type_in_typecache(checkable, blacklist_typecache) && (isobj(checkable) || ismob(checkable))

/mob/living/basic/morph/ShiftClickOn(atom/movable/A)
	if(!stat)
		if(A == src)
			restore()
			return
		if(istype(A) && allowed_to_disguise_as(A))
			assume(A)
	else
		to_chat(src, span_warning("You need to be conscious to transform!"))
		..()

/// Eat stuff. Delicious. Return TRUE if we ate something, FALSE otherwise.
/mob/living/basic/morph/proc/eat(atom/movable/eatable)
	if(QDELETED(eatable) || eatable.loc == src)
		return FALSE

	if(!isnull(form) && !eat_while_disguised)
		to_chat(src, span_warning("You cannot eat anything while you are disguised!"))
		return FALSE

	visible_message(span_warning("[src] swallows [eatable] whole!"))
	eatable.forceMove(src)
	return TRUE

/mob/living/basic/morph/proc/assume(atom/movable/target)
	form = target

	visible_message(
		span_warning("[src] suddenly twists and changes shape, becoming a copy of [target]!"),
		span_notice("You twist your body and assume the form of [target]."),
	)

	appearance = target.appearance
	copy_overlays(target)
	alpha = max(alpha, 150) //fucking chameleons
	transform = initial(transform)
	pixel_y = base_pixel_y
	pixel_x = base_pixel_x

	//Morphed is weaker
	melee_damage_lower = melee_damage_disguised
	melee_damage_upper = melee_damage_disguised
	add_movespeed_modifier(/datum/movespeed_modifier/morph_disguised)

	med_hud_set_health()
	med_hud_set_status() //we're an object honest

/mob/living/basic/morph/proc/restore()
	if(!isnull(form))
		to_chat(src, span_warning("You're already in your normal form!"))
		return

	form = null
	alpha = initial(alpha)
	color = initial(color)
	desc = initial(desc)
	animate_movement = SLIDE_STEPS
	maptext = null

	visible_message(
		span_warning("[src] suddenly collapses in on itself, dissolving into a pile of green flesh!"),
		span_notice("You reform to your normal body."),
	)

	name = initial(name)
	icon = initial(icon)
	icon_state = initial(icon_state)
	cut_overlays()

	//Baseline stats
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)
	remove_movespeed_modifier(/datum/movespeed_modifier/morph_disguised)

	med_hud_set_health()
	med_hud_set_status() //we are not an object

/mob/living/basic/morph/death(gibbed)
	if(isnull(form))
		return ..()

	visible_message(
		span_warning("[src] twists and dissolves into a pile of green flesh!"),
		span_userdanger("Your skin ruptures! Your flesh breaks apart! No disguise can ward off de--"),
	)

	restore()

	return ..()

///mob/living/basic/morph/Aggro() // automated only
//	..()
//	if(morphed)
//		restore()
//
///mob/living/basic/morph/LoseAggro()
//	vision_range = initial(vision_range)

///mob/living/basic/morph/AIShouldSleep(list/possible_targets)
//	. = ..()
//	if(.)
//		var/list/things = list()
//		for(var/atom/movable/A in view(src))
//			if(allowed_to_disguise_as(A))
//				things += A
//		var/atom/movable/T = pick(things)
//		assume(T)

/mob/living/basic/morph/can_track(mob/living/user)
	if(!isnull(form))
		return FALSE
	return ..()

/mob/living/basic/morph/AttackingTarget()
	if(morphed && !melee_damage_disguised)
		to_chat(src, span_warning("You can not attack while disguised!"))
		return
	if(isliving(target)) //Eat Corpses to regen health
		var/mob/living/L = target
		if(L.stat == DEAD)
			if(do_after(src, 30, target = L))
				if(eat(L))
					adjustHealth(-50)
			return
	else if(isitem(target)) //Eat items just to be annoying
		var/obj/item/I = target
		if(!I.anchored)
			if(do_after(src, 20, target = I))
				eat(I)
			return
	return ..()
