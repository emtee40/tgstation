/obj/item/gun/ballistic/automatic
	w_class = WEIGHT_CLASS_NORMAL
	can_suppress = TRUE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)
	semi_auto = TRUE
	fire_sound = 'sound/weapons/gun/smg/shot.ogg'
	fire_sound_volume = 90
	rack_sound = 'sound/weapons/gun/smg/smgrack.ogg'
	suppressed_sound = 'sound/weapons/gun/smg/shot_suppressed.ogg'
	var/select = 1 ///fire selector position. 1 = semi, 2 = burst. anything past that can vary between guns.
	var/selector_switch_icon = FALSE ///if it has an icon for a selector switch indicating current firemode.

/obj/item/gun/ballistic/automatic/update_overlays()
	. = ..()
	if(!selector_switch_icon)
		return

	switch(select)
		if(0)
			. += "[initial(icon_state)]_semi"
		if(1)
			. += "[initial(icon_state)]_burst"

/obj/item/gun/ballistic/automatic/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_firemode))
		burst_select()
	else
		..()

/obj/item/gun/ballistic/automatic/proc/burst_select()
	var/mob/living/carbon/human/user = usr
	select = !select
	if(!select)
		burst_size = 1
		fire_delay = 0
		balloon_alert(user, "switched to semi-automatic")
	else
		burst_size = initial(burst_size)
		fire_delay = initial(fire_delay)
		balloon_alert(user, "switched to [burst_size]-round burst")

	playsound(user, 'sound/weapons/empty.ogg', 100, TRUE)
	update_appearance()
	update_action_buttons()

/obj/item/gun/ballistic/automatic/proto
	name = "\improper Nanotrasen Saber SMG"
	desc = "A prototype full-auto 9mm submachine gun, designated 'SABR'. Has a threaded barrel for suppressors."
	icon_state = "saber"
	burst_size = 1
	actions_types = list()
	mag_display = TRUE
	empty_indicator = TRUE
	mag_type = /obj/item/ammo_box/magazine/smgm9mm
	pin = null
	bolt_type = BOLT_TYPE_LOCKING
	show_bolt_icon = FALSE

/obj/item/gun/ballistic/automatic/proto/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

/obj/item/gun/ballistic/automatic/proto/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/wt550
	name = "security auto rifle"
	desc = "An outdated personal defence weapon. Uses 4.6x30mm rounds and is designated the WT-550 Automatic Rifle."
	icon_state = "wt550"
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/wt550m9
	fire_delay = 2
	can_suppress = FALSE
	burst_size = 1
	actions_types = list()
	can_bayonet = TRUE
	knife_x_offset = 25
	knife_y_offset = 12
	mag_display = TRUE
	mag_display_ammo = TRUE
	empty_indicator = TRUE

/obj/item/gun/ballistic/automatic/wt550/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.3 SECONDS)

/obj/item/gun/ballistic/automatic/plastikov
	name = "\improper PP-95 SMG"
	desc = "An ancient 9mm submachine gun pattern updated and simplified to lower costs, though perhaps simplified too much."
	icon_state = "plastikov"
	inhand_icon_state = "plastikov"
	mag_type = /obj/item/ammo_box/magazine/plastikov9mm
	burst_size = 5
	spread = 25
	can_suppress = FALSE
	actions_types = list()
	projectile_damage_multiplier = 0.35 //It's like 10.5 damage per bullet, it's close enough to 10 shots
	mag_display = TRUE
	empty_indicator = TRUE
	fire_sound = 'sound/weapons/gun/smg/shot_alt.ogg'

/obj/item/gun/ballistic/automatic/mini_uzi
	name = "\improper Type U3 Uzi"
	desc = "A lightweight, burst-fire submachine gun, for when you really want someone dead. Uses 9mm rounds."
	icon_state = "miniuzi"
	mag_type = /obj/item/ammo_box/magazine/uzim9mm
	burst_size = 2
	bolt_type = BOLT_TYPE_OPEN
	show_bolt_icon = FALSE
	mag_display = TRUE
	rack_sound = 'sound/weapons/gun/pistol/slide_lock.ogg'

/obj/item/gun/ballistic/automatic/tommygun
	name = "\improper Thompson SMG"
	desc = "Based on the classic 'Chicago Typewriter'."
	icon_state = "tommygun"
	inhand_icon_state = "shotgun"
	selector_switch_icon = TRUE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/tommygunm45
	can_suppress = FALSE
	burst_size = 1
	actions_types = list()
	fire_delay = 1
	bolt_type = BOLT_TYPE_OPEN
	empty_indicator = TRUE
	show_bolt_icon = FALSE

/obj/item/gun/ballistic/automatic/tommygun/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.1 SECONDS)

/obj/item/gun/ballistic/automatic/ar
	name = "\improper NT-ARG 'Boarder'"
	desc = "A robust assault rifle used by Nanotrasen fighting forces."
	icon_state = "arg"
	inhand_icon_state = "arg"
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/m556
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 1

// Old Semi-Auto Rifle //

/obj/item/gun/ballistic/automatic/surplus
	name = "Surplus Rifle"
	desc = "One of countless obsolete ballistic rifles that still sees use as a cheap deterrent. Uses 10mm ammo and its bulky frame prevents one-hand firing."
	icon_state = "surplus"
	inhand_icon_state = "moistnugget"
	worn_icon_state = null
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/m10mm/rifle
	fire_delay = 30
	burst_size = 1
	can_unsuppress = TRUE
	can_suppress = TRUE
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK
	actions_types = list()
	mag_display = TRUE

// Laser rifle (rechargeable magazine) //

/obj/item/gun/ballistic/automatic/laser
	name = "laser rifle"
	desc = "Though sometimes mocked for the relatively weak firepower of their energy weapons, the logistic miracle of rechargeable ammunition has given Nanotrasen a decisive edge over many a foe."
	icon_state = "oldrifle"
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/recharge
	empty_indicator = TRUE
	fire_delay = 2
	can_suppress = FALSE
	burst_size = 0
	actions_types = list()
	fire_sound = 'sound/weapons/laser.ogg'
	casing_ejector = FALSE

/*
	SYNDICATE
*/

// C-20r //

/obj/item/gun/ballistic/automatic/c20r
	name = "\improper EC-20ᴿ SMG"
	desc = "A mid-length carbine top-loading bullpup. Originally the Company’s main service weapon, \
			however developments in body-armour has caused it to be phased out in favour of the M90 with it’s higher calibre. \
			It currently serves as the main service weapon for support troops, due it’s relative light-weight."
	icon_state = "c20r"
	inhand_icon_state = "c20r"
	icon = 'icons/obj/weapons/guns/syndicate/ballistic.dmi'
	mag_type = /obj/item/ammo_box/magazine/smgm45
	fire_delay = 2
	burst_size = 3
	pin = /obj/item/firing_pin/implant/pindicate
	can_bayonet = TRUE
	knife_x_offset = 26
	knife_y_offset = 12
	mag_display = TRUE

/obj/item/gun/ballistic/automatic/c20r/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/c20r/Initialize(mapload)
	. = ..()
	update_appearance()

// M90 //

/obj/item/gun/ballistic/automatic/m90
	name = "\improper M90-SOCOM Carbine"
	desc = "A high-calibre full-length battle rifle, adoptated as the main rifleman weapon in the year FUCK DATES. \
			Contained within the heat-shield is an integrated 40 millimeter grenade launcher, loaded from a special compartment within the magazine. \
			Originally an attempt by Waffle Corp to win the contract for the new Federation service rifle, but the cost-per-unit was too high for the Federation. \
			However, per specific request, a contract to manufacture for the Company was soon signed."
	icon_state = "m90"
	icon = 'icons/obj/weapons/guns/syndicate/ballistic.dmi'
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = "m90"
	mag_type = /obj/item/ammo_box/magazine/m556
	can_suppress = FALSE
	var/obj/item/gun/ballistic/revolver/grenadelauncher/underbarrel
	burst_size = 3
	fire_delay = 2
	spread = 5
	pin = /obj/item/firing_pin/implant/pindicate
	mag_display = TRUE
	fire_sound = 'sound/weapons/gun/rifle/shot.ogg'

/obj/item/gun/ballistic/automatic/m90/Initialize(mapload)
	. = ..()
	underbarrel = new /obj/item/gun/ballistic/revolver/grenadelauncher(src)
	update_appearance()

/obj/item/gun/ballistic/automatic/m90/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/m90/unrestricted/Initialize(mapload)
	. = ..()
	underbarrel = new /obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted(src)
	update_appearance()

/obj/item/gun/ballistic/automatic/m90/afterattack_secondary(atom/target, mob/living/user, flag, params)
	underbarrel.afterattack(target, user, flag, params)
	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/item/gun/ballistic/automatic/m90/attackby(obj/item/A, mob/user, params)
	if(isammocasing(A))
		if(istype(A, underbarrel.magazine.ammo_type))
			underbarrel.attack_self(user)
			underbarrel.attackby(A, user, params)
	else
		..()

// L6 SAW //

/obj/item/gun/ballistic/automatic/l6_saw
	name = "\improper L6 Heavy Assault"
	desc = "A heavily modified 7.12x82mm light machine gun, designated 'L6 SAW'. Has 'Aussec Armoury - 2531' engraved on the receiver below the designation."
	icon_state = "l6"
	inhand_icon_state = "l6mag"
	base_icon_state = "l6"
	icon = 'icons/obj/weapons/guns/syndicate/ballistic.dmi'
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/mm712x82
	weapon_weight = WEAPON_HEAVY
	burst_size = 1
	actions_types = list()
	can_suppress = FALSE
	spread = 7
	pin = /obj/item/firing_pin/implant/pindicate
	bolt_type = BOLT_TYPE_OPEN
	show_bolt_icon = FALSE
	mag_display = TRUE
	mag_display_ammo = TRUE
	tac_reloads = FALSE
	fire_sound = 'sound/weapons/gun/l6/shot.ogg'
	rack_sound = 'sound/weapons/gun/l6/l6_rack.ogg'
	suppressed_sound = 'sound/weapons/gun/general/heavy_shot_suppressed.ogg'
	var/cover_open = FALSE

/obj/item/gun/ballistic/automatic/l6_saw/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/l6_saw/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

/obj/item/gun/ballistic/automatic/l6_saw/examine(mob/user)
	. = ..()
	. += "<b>alt + click</b> to [cover_open ? "rack" : "open"] the charging bolt."
	if(cover_open && magazine)
		. += span_notice("It seems like you could use an <b>empty hand</b> to remove the magazine.")


/obj/item/gun/ballistic/automatic/l6_saw/AltClick(mob/user)
	if(!user.canUseTopic(src))
		return
	cover_open = !cover_open
	to_chat(user, span_notice("You [cover_open ? "open" : "rack"] [src]'s bolt."))
	playsound(src, 'sound/weapons/gun/l6/l6_door.ogg', 60, TRUE)
	update_appearance()

/obj/item/gun/ballistic/automatic/l6_saw/update_icon_state()
	. = ..()
	inhand_icon_state = "[base_icon_state][magazine ? "mag":"nomag"]"

/obj/item/gun/ballistic/automatic/l6_saw/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params)
	if(cover_open)
		balloon_alert(user, "rack the bolt!")
		return
	else
		. = ..()
		update_appearance()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/gun/ballistic/automatic/l6_saw/attack_hand(mob/user, list/modifiers)
	if (loc != user)
		..()
		return
	if (!cover_open)
		balloon_alert(user, "open the bolt!")
		return
	..()

/obj/item/gun/ballistic/automatic/l6_saw/attackby(obj/item/A, mob/user, params)
	if(!cover_open && istype(A, mag_type))
		balloon_alert(user, "close the bolt!")
		return
	..()

// SNIPER //

/obj/item/gun/ballistic/automatic/sniper_rifle
	name = "sniper rifle"
	desc = "A long ranged weapon that does significant damage. No, you can't quickscope."

	icon_state = "sniper"
	inhand_icon_state = "sniper"
	icon = 'icons/obj/weapons/guns/syndicate/xtra_wide.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	worn_icon_state = null
	inhand_x_dimension = 64

	fire_sound = 'sound/weapons/gun/sniper/shot.ogg'
	fire_sound_volume = 90
	load_sound = 'sound/weapons/gun/sniper/mag_insert.ogg'
	rack_sound = 'sound/weapons/gun/sniper/rack.ogg'
	suppressed_sound = 'sound/weapons/gun/general/heavy_shot_suppressed.ogg'

	recoil = 2

	weapon_weight = WEAPON_HEAVY

	mag_type = /obj/item/ammo_box/magazine/sniper_rounds

	fire_delay = 4 SECONDS
	burst_size = 1

	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK

	actions_types = list()

	mag_display = TRUE

	w_class = WEIGHT_CLASS_BULKY

	suppressor_x_offset = 3
	suppressor_y_offset = 3

/obj/item/gun/ballistic/automatic/sniper_rifle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 2)

/obj/item/gun/ballistic/automatic/sniper_rifle/reset_semicd()
	. = ..()
	if(suppressed)
		playsound(src, 'sound/machines/eject.ogg', 25, TRUE, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	else
		playsound(src, 'sound/machines/eject.ogg', 50, TRUE)

/obj/item/gun/ballistic/automatic/sniper_rifle/syndicate
	name = "syndicate sniper rifle"
	desc = "An illegally modified .50 cal sniper rifle with suppression compatibility. Quickscoping still doesn't work."
	can_suppress = TRUE
	can_unsuppress = TRUE
	pin = /obj/item/firing_pin/implant/pindicate
