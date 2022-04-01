/obj/item/clothing/shoes/gunboots //admin boots that fire gunshots randomly while walking
	name = "gunboots"
	desc = "This is what all those research points added up to, the ultimate workplace hazard."
	icon_state = "jackboots"
	inhand_icon_state = "jackboots"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes
	/// What projectile do we shoot?
	var/projectile_type = /obj/projectile/bullet/c10mm
	/// Each step, this is the chance we fire a shot
	var/shot_prob = 50

/obj/item/clothing/shoes/gunboots/Initialize(mapload)
	. = ..()
	register_signal(src, COMSIG_SHOES_STEP_ACTION, .proc/check_step)

/obj/item/clothing/shoes/gunboots/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_FEET)
		register_signal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, .proc/check_kick)
	else
		unregister_signal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK)

/obj/item/clothing/shoes/gunboots/dropped(mob/user)
	if(user)
		unregister_signal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK)
	return ..()

/// After each step, check if we randomly fire a shot
/obj/item/clothing/shoes/gunboots/proc/check_step(mob/user)
	SIGNAL_HANDLER
	if(!prob(shot_prob))
		return

	INVOKE_ASYNC(src, .proc/fire_shot)

/// Stomping on someone while wearing gunboots shoots them point blank
/obj/item/clothing/shoes/gunboots/proc/check_kick(mob/living/carbon/human/kicking_person, atom/attacked_atom, proximity)
	SIGNAL_HANDLER
	if(!isliving(attacked_atom))
		return
	var/mob/living/attacked_living = attacked_atom
	if(attacked_living.body_position == LYING_DOWN)
		INVOKE_ASYNC(src, .proc/fire_shot, attacked_living)

/// Actually fire a shot. If no target is provided, just fire off in a random direction
/obj/item/clothing/shoes/gunboots/proc/fire_shot(atom/target)
	if(!isliving(loc))
		return

	var/mob/living/wearer = loc
	var/obj/projectile/shot = new projectile_type(get_turf(wearer))

	if(!target)
		target = get_offset_target_turf(get_turf(wearer), rand(-3, 3), rand(-3,3))

	//Shooting Code:
	shot.original = target
	shot.fired_from = src
	shot.firer = wearer // don't hit ourself that would be really annoying
	shot.impacted = list(wearer = TRUE)
	shot.def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG) // they're fired from boots after all
	shot.preparePixelProjectile(target, wearer)
	if(!shot.suppressed)
		wearer.visible_message(span_danger("[wearer]'s [name] fires \a [shot]!"), "", blind_message = span_hear("You hear a gunshot!"), vision_distance=COMBAT_MESSAGE_RANGE)
	shot.fire()

/obj/item/clothing/shoes/gunboots/disabler
	name = "disaboots"
	projectile_type = /obj/projectile/beam/disabler
