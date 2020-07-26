//GUNCASES//
/obj/structure/guncase
	name = "gun locker"
	desc = "A locker that holds guns."
	icon = 'icons/obj/closet.dmi'
	icon_state = "shotguncase"
	anchored = FALSE
	density = TRUE
	opacity = 0
	var/case_type = ""
	var/gun_category = /obj/item/gun
	var/open = TRUE
	var/capacity = 4

/obj/structure/guncase/Initialize(mapload)
	. = ..()
	if(mapload)
		for(var/obj/item/I in loc.contents)
			if(istype(I, gun_category))
				I.forceMove(src)
			if(contents.len >= capacity)
				break
	update_icon()

/obj/structure/guncase/update_overlays()
	. = ..()
	if(case_type && LAZYLEN(contents))
		var/mutable_appearance/gun_overlay = mutable_appearance(icon, case_type)
		for(var/i in 1 to contents.len)
			gun_overlay.pixel_x = 3 * (i - 1)
			. += new /mutable_appearance(gun_overlay)
	if(open)
		. += "[icon_state]_open"
	else
		. += "[icon_state]_door"

/obj/structure/guncase/attackby(obj/item/I, mob/user, params)
	if(iscyborg(user) || isalien(user))
		return
	if(istype(I, gun_category) && open)
		if(LAZYLEN(contents) < capacity)
			if(!user.transferItemToLoc(I, src))
				return
			to_chat(user, "<span class='notice'>You place [I] in [src].</span>")
			update_icon()
		else
			to_chat(user, "<span class='warning'>[src] is full.</span>")
		return

	else if(user.a_intent != INTENT_HARM)
		open = !open
		update_icon()
	else
		return ..()

/obj/structure/guncase/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(iscyborg(user) || isalien(user))
		return
	if(contents.len && open)
		show_menu(user)
	else
		open = !open
		update_icon()

/**
  * show_menu: Shows a radial menu to a user consisting of an available weaponry for taking
  *
  * Arguments:
  * * user The mob to which we are showing the radial menu
  */
/obj/structure/guncase/proc/show_menu(mob/user)
	if(!LAZYLEN(contents))
		return

	var/list/display_names = list()
	var/list/items = list()
	for(var/i in 1 to contents.len)
		var/obj/item/I = contents[i]
		display_names[I.name + " ([i])"] = REF(I)
		var/image/item_image = image(icon = I.icon, icon_state = I.icon_state)
		if(length(I.overlays))
			item_image.copy_overlays(I)
		items += list(I.name + " ([i])" = item_image)

	var/pick = show_radial_menu(user, src, items, custom_check = CALLBACK(src, .proc/check_menu, user), radius = 36, require_near = TRUE)
	if(!pick)
		return

	var/weapon_reference = display_names[pick]
	var/obj/item/O = locate(weapon_reference) in contents
	if(!O || !istype(O))
		return
	if(!user.put_in_hands(O))
		O.forceMove(get_turf(src))
	update_icon()

/**
  * check_menu: Checks if we are allowed to interact with a radial menu
  *
  * Arguments:
  * * user The mob interacting with a menu
  */
/obj/structure/guncase/proc/check_menu(mob/living/carbon/human/user)
	if(!open)
		return FALSE
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/obj/structure/guncase/handle_atom_del(atom/A)
	update_icon()

/obj/structure/guncase/contents_explosion(severity, target)
	for(var/atom/A in contents)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.highobj += A
			if(EXPLODE_HEAVY)
				SSexplosions.medobj += A
			if(EXPLODE_LIGHT)
				SSexplosions.lowobj += A

/obj/structure/guncase/shotgun
	name = "shotgun locker"
	desc = "A locker that holds shotguns."
	case_type = "shotgun"
	gun_category = /obj/item/gun/ballistic/shotgun

/obj/structure/guncase/ecase
	name = "energy gun locker"
	desc = "A locker that holds energy guns."
	icon_state = "ecase"
	case_type = "egun"
	gun_category = /obj/item/gun/energy/e_gun
