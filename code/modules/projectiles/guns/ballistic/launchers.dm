//KEEP IN MIND: These are different from gun/grenadelauncher. These are designed to shoot premade rocket and grenade projectiles, not flashbangs or chemistry casings etc.
//Put handheld rocket launchers here if someone ever decides to make something so hilarious ~Paprika

/obj/item/gun/ballistic/revolver/grenadelauncher//this is only used for underbarrel grenade launchers at the moment, but admins can still spawn it if they feel like being assholes
	desc = "A break-operated grenade launcher."
	name = "grenade launcher"
<<<<<<< HEAD
	icon_state = "dshotgun_sawn"
=======
	icon_state = "dshotgun-sawn"
>>>>>>> Updated this old code to fork
	item_state = "gun"
	mag_type = /obj/item/ammo_box/magazine/internal/grenadelauncher
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	pin = /obj/item/firing_pin/implant/pindicate
<<<<<<< HEAD
	bolt_type = BOLT_TYPE_NO_BOLT
=======
>>>>>>> Updated this old code to fork

/obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/revolver/grenadelauncher/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/ammo_box) || istype(A, /obj/item/ammo_casing))
		chamber_round()

/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg
	desc = "A 6-shot grenade launcher."
	name = "multi grenade launcher"
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_grenadelnchr"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/grenademulti
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg/attack_self()
	return

/obj/item/gun/ballistic/automatic/gyropistol
	name = "gyrojet pistol"
	desc = "A prototype pistol designed to fire self propelled rockets."
	icon_state = "gyropistol"
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	mag_type = /obj/item/ammo_box/magazine/m75
	burst_size = 1
	fire_delay = 0
	actions_types = list()
	casing_ejector = FALSE

<<<<<<< HEAD
/obj/item/gun/ballistic/rocketlauncher
	name = "\improper PML-9"
	desc = "A reusable rocket propelled grenade launcher. The words \"NT this way\" and an arrow have been written near the barrel."
	icon_state = "rocketlauncher"
	item_state = "rocketlauncher"
	mag_type = /obj/item/ammo_box/magazine/internal/rocketlauncher
=======
/obj/item/gun/ballistic/automatic/gyropistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "loaded" : ""]"

/obj/item/gun/ballistic/rocketlauncher
	name = "rocket propelled grenade launcher"
	desc = "A reusable rocket propelled grenade launcher."
	icon_state = "rocketlauncher"
	item_state = "rocketlauncher"
	mag_type = /obj/item/ammo_box/magazine/rocket
>>>>>>> Updated this old code to fork
	fire_sound = 'sound/weapons/rocketlaunch.ogg'
	w_class = WEIGHT_CLASS_BULKY
	can_suppress = FALSE
	pin = /obj/item/firing_pin/implant/pindicate
	burst_size = 1
	fire_delay = 0
	casing_ejector = FALSE
	weapon_weight = WEAPON_HEAVY
<<<<<<< HEAD
	bolt_type = BOLT_TYPE_NO_BOLT
	internal_magazine = TRUE
	cartridge_wording = "rocket"
	empty_indicator = TRUE
	tac_reloads = FALSE
=======
	magazine_wording = "rocket"

/obj/item/gun/ballistic/rocketlauncher/handle_atom_del(atom/A)
	if(A == chambered)
		chambered = null
		if(!QDELETED(magazine))
			QDEL_NULL(magazine)
	if(A == magazine)
		magazine = null
		if(!QDELETED(chambered))
			QDEL_NULL(chambered)
	update_icon()
	return ..()

/obj/item/gun/ballistic/rocketlauncher/can_shoot()
	return chambered?.BB
>>>>>>> Updated this old code to fork

/obj/item/gun/ballistic/rocketlauncher/unrestricted
	pin = /obj/item/firing_pin

<<<<<<< HEAD
/obj/item/gun/ballistic/rocketlauncher/afterattack()
	. = ..()
	magazine.get_round(FALSE) //Hack to clear the mag after it's fired
=======
/obj/item/gun/ballistic/rocketlauncher/process_chamber()
	if(chambered)
		chambered = null
	if(magazine)
		QDEL_NULL(magazine)
	update_icon()
>>>>>>> Updated this old code to fork

/obj/item/gun/ballistic/rocketlauncher/attack_self_tk(mob/user)
	return //too difficult to remove the rocket with TK

<<<<<<< HEAD
/obj/item/gun/ballistic/rocketlauncher/suicide_act(mob/living/user)
	user.visible_message("<span class='warning'>[user] aims [src] at the ground! It looks like [user.p_theyre()] performing a sick rocket jump!</span>", \
=======
/obj/item/gun/ballistic/rocketlauncher/attack_self(mob/living/user)
	if(magazine)
		if(chambered)
			chambered.forceMove(magazine)
			magazine.stored_ammo.Insert(1, chambered)
			chambered = null
		else
			stack_trace("Removed [magazine] from [src] without a chambered round")
		magazine.forceMove(drop_location())
		if(user.is_holding(src))
			user.put_in_hands(magazine)
		playsound(src, 'sound/weapons/gun_magazine_remove_full.ogg', 70, TRUE)
		to_chat(user, "<span class='notice'>You work the [magazine] out from [src].</span>")
		magazine = null
	else
		to_chat(user, "<span class='notice'>There's no rocket in [src].</span>")
	update_icon()

/obj/item/gun/ballistic/rocketlauncher/update_icon()
	icon_state = "[initial(icon_state)]-[chambered ? "1" : "0"]"

/obj/item/gun/ballistic/rocketlauncher/suicide_act(mob/living/user)
	user.visible_message("<span class='warning'>[user] aims [src] at the ground! It looks like [user.p_theyre()] performing a sick rocket jump!<span>", \
>>>>>>> Updated this old code to fork
		"<span class='userdanger'>You aim [src] at the ground to perform a bisnasty rocket jump...</span>")
	if(can_shoot())
		user.notransform = TRUE
		playsound(src, 'sound/vehicles/rocketlaunch.ogg', 80, 1, 5)
		animate(user, pixel_z = 300, time = 30, easing = LINEAR_EASING)
		sleep(70)
		animate(user, pixel_z = 0, time = 5, easing = LINEAR_EASING)
		sleep(5)
		user.notransform = FALSE
		process_fire(user, user, TRUE)
		if(!QDELETED(user)) //if they weren't gibbed by the explosion, take care of them for good.
			user.gib()
		return MANUAL_SUICIDE
	else
		sleep(5)
		shoot_with_empty_chamber(user)
		sleep(20)
		user.visible_message("<span class='warning'>[user] looks about the room realizing [user.p_theyre()] still there. [user.p_they(TRUE)] proceed to shove [src] down their throat and choke [user.p_them()]self with it!</span>", \
			"<span class='userdanger'>You look around after realizing you're still here, then proceed to choke yourself to death with [src]!</span>")
		sleep(20)
		return OXYLOSS





<<<<<<< HEAD
=======
	
>>>>>>> Updated this old code to fork
