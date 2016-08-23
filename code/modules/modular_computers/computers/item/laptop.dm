/obj/item/modular_computer/laptop
	name = "laptop"
	desc = "A portable laptop computer."

	icon = 'icons/obj/modular_laptop.dmi'
	icon_state = "laptop-closed"
	icon_state_powered = "laptop"
	icon_state_unpowered = "laptop-off"
	icon_state_menu = "menu"

	hardware_flag = PROGRAM_LAPTOP
	max_hardware_size = 2
	w_class = 3

	flags = HANDSLOW // No running around with open laptops in hands.

	screen_on = 0 		// Starts closed
	var/start_open = 1	// unless this var is set to 1
	var/icon_state_closed = "laptop-closed"
	var/w_class_open = 4
	var/slowdown_open = 1

/obj/item/modular_computer/laptop/New()
	..()
	if(start_open && !screen_on)
		toggle_open()

/obj/item/modular_computer/laptop/update_icon()
	if(screen_on)
		..()
	else
		cut_overlays()
		icon_state = icon_state_closed

/obj/item/modular_computer/laptop/attack_self(mob/user)
	if(!screen_on)
		try_toggle_open(user)
	else
		return ..()

/obj/item/modular_computer/laptop/verb/open_computer()
	set name = "Toggle Open"
	set category = "Object"
	set src in view(1)

	try_toggle_open(usr)

/obj/item/modular_computer/laptop/MouseDrop(obj/over_object, src_location, over_location)
	if(over_object == usr || over_object == src)
		try_toggle_open(usr)
	else if(istype(over_object, /obj/screen/inventory/hand))
		var/obj/screen/inventory/hand/H = over_object
		var/mob/M = usr

		if(!M.restrained() && !M.stat)
			if(!isturf(loc) || !Adjacent(M))
				return

			switch(H.slot_id)
				if(slot_r_hand)
					M.put_in_r_hand(src)
				if(slot_l_hand)
					M.put_in_l_hand(src)

/obj/item/modular_computer/laptop/attack_hand(mob/user)
	if(screen_on && isturf(loc))
		return attack_self(user)

	return ..()


/obj/item/modular_computer/laptop/proc/try_toggle_open(mob/living/user)
	if(issilicon(user))
		return
	if(!isturf(loc) && !ismob(loc)) // No opening it in backpack.
		return
	if(!user.canUseTopic(src))
		return

	toggle_open(user)


/obj/item/modular_computer/laptop/AltClick(mob/user)
	if(screen_on) // Close it.
		try_toggle_open(user)
	else
		return ..()

/obj/item/modular_computer/laptop/proc/toggle_open(mob/living/user=null)
	if(screen_on)
		user << "<span class='notice'>You close \the [src].</span>"
		slowdown = initial(slowdown)
		w_class = initial(w_class)
	else
		user << "<span class='notice'>You open \the [src].</span>"
		slowdown = slowdown_open
		w_class = w_class_open

	screen_on = !screen_on
	update_icon()



// Laptop frame, starts empty and closed.
/obj/item/modular_computer/laptop/buildable
	start_open = 0
