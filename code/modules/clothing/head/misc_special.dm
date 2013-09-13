/*
 * Contents:
 *		Welding mask
 *		Cakehat
 *		Ushanka
 *		Pumpkin head
 *		Kitty ears
 *
 */

/*
 * Welding mask
 */
/obj/item/clothing/head/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	flags = (FPRINT | TABLEPASS | HEADCOVERSEYES | HEADCOVERSMOUTH)
	item_state = "welding"
	m_amt = 3000
	g_amt = 1000
//	var/up = 0
	flash_protect = 2
	tint = 2
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags_inv = (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
	action_button_name = "Toggle Welding Helmet"
	visor_flags = HEADCOVERSEYES | HEADCOVERSMOUTH
	visor_flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE

/obj/item/clothing/head/welding/attack_self()
	toggle()


/obj/item/clothing/head/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding helmet"
	set src in usr

	weldingvisortoggle()


/*
 * Cakehat
 */
/obj/item/clothing/head/cakehat
	name = "cake-hat"
	desc = "It's tasty looking!"
	icon_state = "cake0"
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES
	var/onfire = 0.0
	var/status = 0
	var/fire_resist = T0C+1300	//this is the max temp it can stand before you start to cook. although it might not burn away, you take damage
	var/processing = 0 //I dont think this is used anywhere.

/obj/item/clothing/head/cakehat/process()
	if(!onfire)
		processing_objects.Remove(src)
		return

	var/turf/location = src.loc
	if(istype(location, /mob/))
		var/mob/living/carbon/human/M = location
		if(M.l_hand == src || M.r_hand == src || M.head == src)
			location = M.loc

	if (istype(location, /turf))
		location.hotspot_expose(700, 1)

/obj/item/clothing/head/cakehat/attack_self(mob/user as mob)
	if(status > 1)	return
	src.onfire = !( src.onfire )
	if (src.onfire)
		src.force = 3
		src.damtype = "fire"
		src.icon_state = "cake1"
		processing_objects.Add(src)
	else
		src.force = null
		src.damtype = "brute"
		src.icon_state = "cake0"
	return


/*
 * Ushanka
 */
/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon_state = "ushankadown"
	item_state = "ushankadown"
	flags_inv = HIDEEARS

/obj/item/clothing/head/ushanka/attack_self(mob/user as mob)
	if(src.icon_state == "ushankadown")
		src.icon_state = "ushankaup"
		src.item_state = "ushankaup"
		user << "You raise the ear flaps on the ushanka."
	else
		src.icon_state = "ushankadown"
		src.item_state = "ushankadown"
		user << "You lower the ear flaps on the ushanka."

/*
 * Pumpkin head
 */
/obj/item/clothing/head/pumpkinhead
	name = "carved pumpkin"
	desc = "A jack o' lantern! Believed to ward off evil spirits."
	icon_state = "hardhat0_pumpkin"//Could stand to be renamed
	item_state = "hardhat0_pumpkin"
	col = "pumpkin"
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES | HEADCOVERSMOUTH | BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	var/brightness_on = 2 //luminosity when on
	var/on = 0

	attack_self(mob/user)
		if(!isturf(user.loc))
			user << "You cannot turn the light on while in this [user.loc]" //To prevent some lighting anomalities.
			return
		on = !on
		icon_state = "hardhat[on]_[col]"
		item_state = "hardhat[on]_[col]"

		if(on)	user.SetLuminosity(user.luminosity + brightness_on)
		else	user.SetLuminosity(user.luminosity - brightness_on)

	pickup(mob/user)
		if(on)
			user.SetLuminosity(user.luminosity + brightness_on)
//			user.UpdateLuminosity()
			SetLuminosity(0)

	dropped(mob/user)
		if(on)
			user.SetLuminosity(user.luminosity - brightness_on)
//			user.UpdateLuminosity()
			SetLuminosity(brightness_on)

/*
 * Kitty ears
 */
/obj/item/clothing/head/kitty
	name = "kitty ears"
	desc = "A pair of kitty ears. Meow!"
	icon_state = "kitty"
	flags = FPRINT | TABLEPASS
	var/icon/mob
	var/icon/mob2

/obj/item/clothing/head/kitty/equipped(mob/user, slot)
	if(user && slot == slot_head)
		update_icon(user)

//ffffuck you kitty ears. this proc is a) retarded and b) seems to fail around fifty percent of the time. idgaf tbh
/obj/item/clothing/head/kitty/update_icon(mob/living/carbon/human/user)
	if(!istype(user)) return
	mob = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kitty")
	mob2 = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kitty2")
	mob.Blend("#[user.hair_color]", ICON_ADD)
	mob2.Blend("#[user.hair_color]", ICON_ADD)

	var/icon/earbit = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kittyinner")
	var/icon/earbit2 = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kittyinner2")
	mob.Blend(earbit, ICON_OVERLAY)
	mob2.Blend(earbit2, ICON_OVERLAY)
