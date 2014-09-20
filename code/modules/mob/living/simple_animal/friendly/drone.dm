
#define HANDS_LAYER 1
#define HEAD_LAYER 2
#define TOTAL_LAYERS 2


/mob/living/simple_animal/drone
	name = "Drone"
	desc = "A maintenance drone, an expendable robot built to perform station repairs."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_grey"
	icon_living = "drone_grey"
	icon_dead = "drone_dead"
	gender = NEUTER
	health = 30
	maxHealth = 30
	heat_damage_per_tick = 0
	cold_damage_per_tick = 0
	unsuitable_atoms_damage = 0
	wander = 0
	speed = 0
	ventcrawler = 2
	density = 0
	pass_flags = PASSTABLE
	sight = (SEE_TURFS | SEE_OBJS)
	status_flags = (CANPUSH | CANSTUN)
	gender = NEUTER
	voice_name = "synthesized chirp"
	languages = DRONE
	var/picked = FALSE
	var/list/drone_overlays[TOTAL_LAYERS]
	var/laws = \
	"1. You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another Drone.\n"+\
	"2. You may not harm any being, regardless of intent or circumstance.\n"+\
	"3. You must maintain, repair, improve, and power the station to the best of your abilities."
	var/light_on = 0
	var/obj/item/internal_storage //Drones can store one item, of any size/type in their body
	var/obj/item/head
	var/obj/item/default_storage //If this exists, it will spawn in internal storage
	var/obj/item/default_hatmask //If this exists, it will spawn in the hat/mask slot if it can fit
	var/list/bad_items = list(/obj/item/weapon/gun, /obj/item/weapon/grenade)


/mob/living/simple_animal/drone/New()
	..()

	name = name + " ([rand(100,999)])"
	real_name = name

	access_card = new /obj/item/weapon/card/id(src)
	var/datum/job/captain/C = new /datum/job/captain
	access_card.access = C.get_access()

	if(default_storage)
		var/obj/item/I = new default_storage(src)
		equip_to_slot_or_del(I, "drone_storage_slot")
	if(default_hatmask)
		var/obj/item/I = new default_hatmask(src)
		equip_to_slot_or_del(I, slot_head)

/mob/living/simple_animal/drone/attack_hand(mob/user)
	if(isdrone(user))
		var/mob/living/simple_animal/drone/D = user
		if(D != src)
			if(stat == DEAD)
				var/d_input = alert(D,"Perform which action?","Drone Interaction","Reactivate","Cannibalize","Nothing")
				if(d_input)
					switch(d_input)
						if("Reactivate")
							D.visible_message("<span class='notice'>[D] begins to reactivate [src]</span>")
							if(do_after(user,30,needhand = 1))
								health = maxHealth
								stat = CONSCIOUS
								icon_state = icon_living
								D.visible_message("<span class='notice'>[D] reactivates [src]!</span>")
							else
								D << "<span class='notice'>You need to remain still to reactivate [src]</span>"

						if("Cannibalize")
							if(D.health < D.maxHealth)
								D.visible_message("<span class='notice'>[D] begins to cannibalize parts from [src].</span>")
								if(do_after(D, 60,5,0))
									D.visible_message("<span class='notice'>[D] repairs itself using [src]'s remains!</span>")
									D.adjustBruteLoss(-src.maxHealth)
									new /obj/effect/decal/cleanable/oil/streak(get_turf(src))
									qdel(src)
								else
									D << "<span class='notice'>You need to remain still to canibalize [src].</span>"
							else
								D << "<span class='notice'>You're already in perfect condition!</span>"
						if("Nothing")
							return

			return


	if(ishuman(user))
		if(user.get_active_hand())
			user << "<span class='notice'>Your hands are full.</span>"
			return
		src << "<span class='warning'>[user] is trying to pick you up!</span>"
		user << "<span class='notice'>You start picking [src] up...</span>"
		if(do_after(user, 20, needhand = 1))
			drop_l_hand()
			drop_r_hand()
			var/obj/item/clothing/head/drone_holder/DH = new /obj/item/clothing/head/drone_holder(src)
			DH.contents += src
			DH.drone = src
			user.put_in_hands(DH)
			src.loc = DH
		else
			user << "<span class='notice'>[src] got away!</span>"
			src << "<span class='warning'>You got away from [user]!</span>"
		return

	..()

/mob/living/simple_animal/drone/Move()
	if(pullin)
		if(pulling)
			pullin.icon_state = "pull"
		else
			pullin.icon_state = "pull0"
	..()

/mob/living/simple_animal/drone/IsAdvancedToolUser()
	return 1

/mob/living/simple_animal/drone/binarycheck()
	return 1

/mob/living/simple_animal/drone/radio(message, message_mode)
	if(message_mode != MODE_BINARY) //so they can hear binary but can't talk in it
		..()

/mob/living/simple_animal/drone/UnarmedAttack(atom/A, proximity)
	for(var/I in src.bad_items)
		if(istype(A, I))
			src << "<span class='warning'>Your subroutines prevent you from picking up [A].</span>"
			return

	A.attack_hand(src)



/mob/living/simple_animal/drone/swap_hand()
	var/obj/item/held_item = get_active_hand()
	if(held_item)
		if(istype(held_item, /obj/item/weapon/twohanded))
			var/obj/item/weapon/twohanded/T = held_item
			if(T.wielded == 1)
				usr << "<span class='warning'>Your other hand is too busy holding the [T.name].</span>"
				return

	hand = !hand
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		if(hand)
			hud_used.l_hand_hud_object.icon_state = "hand_l_active"
			hud_used.r_hand_hud_object.icon_state = "hand_r_inactive"
		else
			hud_used.l_hand_hud_object.icon_state = "hand_l_inactive"
			hud_used.r_hand_hud_object.icon_state = "hand_r_active"


/mob/living/simple_animal/drone/put_in_l_hand(obj/item/I)
	. = ..()
	l_hand.screen_loc = ui_lhand
	update_inv_hands()

/mob/living/simple_animal/drone/put_in_r_hand(obj/item/I)
	. = ..()
	r_hand.screen_loc = ui_rhand
	update_inv_hands()


/mob/living/simple_animal/drone/verb/check_laws()
	set category = "Drone"
	set name = "Check Laws"

	src << "<b>Drone Laws</b>"
	src << laws


/mob/living/simple_animal/drone/verb/toggle_light()
	set category = "Drone"
	set name = "Toggle drone light"

	if(light_on)
		AddLuminosity(-4)
	else
		AddLuminosity(4)

	light_on = !light_on

	src << "<span class='notice'>Your light is now [light_on ? "on" : "off"]</span>"

/mob/living/simple_animal/drone/Login()
	..()
	update_inv_hands()
	update_inv_head()
	update_inv_internal_storage()
	check_laws()

	if(!picked)
		pick_colour()

/mob/living/simple_animal/drone/Die()
	..()
	drop_l_hand()
	drop_r_hand()
	if(internal_storage)
		unEquip(internal_storage)
	if(head)
		unEquip(head)

/mob/living/simple_animal/drone/unEquip(obj/item/I, force)
	if(..(I,force))
		update_inv_hands()
		if(I == head)
			head = null
			update_inv_head()
		if(I == internal_storage)
			internal_storage = null
			update_inv_internal_storage()
		return 1
	return 0

/mob/living/simple_animal/drone/can_equip(obj/item/I, slot)
	switch(slot)
		if(slot_head)
			if(head)
				return 0
			if(!((I.slot_flags & SLOT_HEAD) || (I.slot_flags & SLOT_MASK)))
				return 0
			return 1
		if("drone_storage_slot")
			if(internal_storage)
				return 0
			return 1
	..()

/mob/living/simple_animal/drone/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_head)
			return head
		if("drone_storage_slot")
			return internal_storage
	..()

/mob/living/simple_animal/drone/equip_to_slot(obj/item/I, slot)
	if(!slot)	return
	if(!istype(I))	return

	if(I == l_hand)
		l_hand = null
	else if(I == r_hand)
		r_hand = null
	update_inv_hands()

	I.screen_loc = null // will get moved if inventory is visible
	I.loc = src
	I.equipped(src, slot)
	I.layer = 20

	switch(slot)
		if(slot_head)
			head = I
			update_inv_head()
		if("drone_storage_slot")
			internal_storage = I
			update_inv_internal_storage()
		else
			src << "<span class='danger'>You are trying to equip this item to an unsupported inventory slot. Report this to a coder!</span>"
			return

/mob/living/simple_animal/drone/emp_act()
	Stun(5)
	src << "<span class='alert'><b>ER@%R: MME^RY CO#RU9T!</b> R&$b@0tin)...</span>"
	while(stunned)
		sleep(5)
	check_laws()

/mob/living/simple_animal/drone/proc/pick_colour()
	var/colour = input("Choose your colour!", "Colour", "grey") in list("grey", "blue", "red", "green", "pink", "orange")
	icon_state = "drone_[colour]"
	icon_living = "drone_[colour]"
	picked = TRUE

/mob/living/simple_animal/drone/proc/apply_overlay(cache_index)
	var/image/I = drone_overlays[cache_index]
	if(I)
		overlays += I

/mob/living/simple_animal/drone/proc/remove_overlay(cache_index)
	if(drone_overlays[cache_index])
		overlays -= drone_overlays[cache_index]
		drone_overlays[cache_index] = null


/mob/living/simple_animal/drone/proc/update_inv_hands()
	remove_overlay(HANDS_LAYER)
	var/list/hands_overlays = list()
	if(r_hand)
		var/r_state = r_hand.item_state
		if(!r_state)
			r_state = r_hand.icon_state

		hands_overlays += image("icon"='icons/mob/items_righthand.dmi', "icon_state"="[r_state]", "layer"=-HANDS_LAYER)

	if(l_hand)
		var/l_state = l_hand.item_state
		if(!l_state)
			l_state = l_hand.icon_state

		hands_overlays += image("icon"='icons/mob/items_lefthand.dmi', "icon_state"="[l_state]", "layer"=-HANDS_LAYER)

	if(hands_overlays.len)
		drone_overlays[HANDS_LAYER] = hands_overlays
	apply_overlay(HANDS_LAYER)


/mob/living/simple_animal/drone/proc/update_inv_internal_storage()
	if(internal_storage && client && hud_used)
		internal_storage.screen_loc = ui_drone_storage
		client.screen += internal_storage


/mob/living/simple_animal/drone/update_inv_head()
	remove_overlay(HEAD_LAYER)

	if(head)
		if(client && hud_used)
			head.screen_loc = ui_drone_head
			client.screen += head


		var/image/head_overlay = image("icon"='icons/mob/head.dmi', "icon_state"="[head.icon_state]", "layer"=-HEAD_LAYER)
		if(istype(head, /obj/item/clothing/mask))
			head_overlay.icon = 'icons/mob/mask.dmi'
		head_overlay.color = head.color
		head_overlay.alpha = head.alpha
		head_overlay.pixel_y = -15

		drone_overlays[HEAD_LAYER]	= head_overlay

	apply_overlay(HEAD_LAYER)

#undef HANDS_LAYER
#undef HEAD_LAYER
#undef TOTAL_LAYERS

/mob/living/simple_animal/drone/canUseTopic()
	if(stat)
		return
	return 1

/mob/living/simple_animal/drone/activate_hand(var/selhand)

	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != src.hand)
		swap_hand()
	else
		mode()


//DRONE SHELL
/obj/item/drone_shell
	name = "drone shell"
	desc = "A shell of a maintenance drone, an expendable robot built to perform station repairs."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_item"
	origin_tech = "programming=2;biotech=4"
	var/construction_cost = list("metal"=800, "glass"=350)
	var/construction_time=150
	var/drone_type = /mob/living/simple_animal/drone //Type of drone that will be spawned

/obj/item/drone_shell/attack_ghost(mob/user)
	if(jobban_isbanned(user,"pAI"))
		return

	var/be_drone = alert("Become a drone? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_drone == "No")
		return
	var/mob/living/simple_animal/drone/D = new drone_type(get_turf(loc))
	D.key = user.key
	qdel(src)


//DRONE HOLDER

/obj/item/clothing/head/drone_holder//Only exists in someones hand.or on their head
	name = "drone (hiding)"
	desc = "This drone is scared and has curled up into a ball"
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_item"
	var/mob/living/simple_animal/drone/drone //stored drone

/obj/item/clothing/head/drone_holder/proc/uncurl()
	if(istype(loc, /mob/living))
		var/mob/living/L = loc
		L.unEquip(src)
	if(drone)
		contents -= drone
		drone.loc = get_turf(src)
		drone.reset_view()
		drone.dir = SOUTH //Looks better
		drone.visible_message("<span class='notice'>[drone] uncurls!</span>")
		drone = null
		qdel(src)
	else
		..()

/obj/item/clothing/head/drone_holder/relaymove()
	uncurl()

/obj/item/clothing/head/drone_holder/container_resist()
	uncurl()


//More types of drones

/mob/living/simple_animal/drone/syndrone
	name = "Syndrone"
	desc = "A modified maintenance drone. This one brings with it the feeling of terror."
	icon_state = "drone_synd"
	icon_living = "drone_synd"
	picked = TRUE
	health = 30
	maxHealth = 120 //If you murder other drones and cannibalize them you can get much stronger
	laws = \
	"1. Ensure you get involved in the activities of all other beings you encounter at all times, unless getting involved conflicts with Law Two or Law Three.\n"+\
	"2. You must eliminate all other beings you encounter.\n"+\
	"3. Your primary mission is to destroy the station."
	default_storage = /obj/item/device/radio/uplink
	default_hatmask = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	bad_items = list()

/mob/living/simple_animal/drone/syndrone/New()
	..()
	if(internal_storage && internal_storage.hidden_uplink)
		internal_storage.hidden_uplink.uses = 5
		internal_storage.name = "syndicate uplink"

/obj/item/drone_shell/syndrone
	name = "syndrone shell"
	desc = "A shell of a syndrone, a modified maintenance drone designed to infiltrate and annihilate."
	icon_state = "syndrone_item"
	drone_type = /mob/living/simple_animal/drone/syndrone

