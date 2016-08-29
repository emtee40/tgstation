var/highlander = FALSE
/client/proc/only_one() //Gives everyone kilts, berets, claymores, and pinpointers, with the objective to hijack the emergency shuttle.
	if(!ticker || !ticker.mode)
		alert("The game hasn't started yet!")
		return
	highlander = TRUE

	world << "<span class='userdanger'><i>THERE CAN BE ONLY ONE!!!</i></span>"
	world << sound('sound/misc/highlander.ogg')

	for(var/mob/living/carbon/human/H in player_list)
		if(H.stat == DEAD || !(H.client))
			continue
		H.make_scottish()

	message_admins("<span class='adminnotice'>[key_name_admin(usr)] used THERE CAN BE ONLY ONE!</span>")
	log_admin("[key_name(usr)] used THERE CAN BE ONLY ONE.")
	addtimer(SSshuttle.emergency, "request", 50, FALSE, null, 1)

/mob/living/carbon/human/proc/make_scottish()
	ticker.mode.traitors += mind
	mind.special_role = "highlander"
	dna.species.specflags |= NOGUNS //nice try jackass

	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = mind
	steal_objective.set_target(new /datum/objective_item/steal/nukedisc)
	mind.objectives += steal_objective

	var/datum/objective/hijack/hijack_objective = new
	hijack_objective.explanation_text = "Escape on the shuttle alone. Ensure that nobody else makes it out."
	hijack_objective.owner = mind
	mind.objectives += hijack_objective

	mind.announce_objectives()

	for(var/obj/item/I in src)
		if(istype(I, /obj/item/weapon/implant))
			continue
		qdel(I)
	equip_to_slot_or_del(new /obj/item/clothing/under/kilt/highlander(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(src), slot_ears)
	equip_to_slot_or_del(new /obj/item/clothing/head/beret/highlander(src), slot_head)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(src), slot_shoes)
	equip_to_slot_or_del(new /obj/item/weapon/pinpointer(src), slot_l_store)
	var/obj/item/weapon/card/id/W = new(src)
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_all_centcom_access()
	W.assignment = "Highlander"
	W.registered_name = real_name
	W.flags |= NODROP
	W.update_label(real_name)
	equip_to_slot_or_del(W, slot_wear_id)

	var/obj/item/weapon/claymore/highlander/H1 = new(src)
	if(!highlander)
		H1.admin_spawned = TRUE //To prevent announcing
	put_in_hands(H1)
	H1.pickup(src)

	var/obj/item/weapon/bloodcrawl/ANTIWELDER = new(src)
	ANTIWELDER.name = "compulsion of honor"
	ANTIWELDER.desc = "You are unable to hold anything in this hand until you're the last one left!"
	ANTIWELDER.icon_state = "bloodhand_right"
	put_in_hands(ANTIWELDER)

	src << "<span class='boldannounce'>Your [H1.name] cries out for blood. Join in the slaughter, lest you be claimed yourself...\n\
	Activate it in your hand, and it will lead to the nearest target.</span>"

/proc/only_me()
	if(!ticker || !ticker.mode)
		alert("The game hasn't started yet!")
		return

	for(var/mob/living/carbon/human/H in player_list)
		if(H.stat == 2 || !(H.client)) continue
		if(is_special_character(H)) continue

		ticker.mode.traitors += H.mind
		H.mind.special_role = "[H.real_name] Prime"

		var/datum/objective/hijackclone/hijack_objective = new /datum/objective/hijackclone
		hijack_objective.owner = H.mind
		H.mind.objectives += hijack_objective

		H << "<B>You are the multiverse summoner. Activate your blade to summon copies of yourself from another universe to fight by your side.</B>"
		H.mind.announce_objectives()

		var/obj/item/slot_item_ID = H.get_item_by_slot(slot_wear_id)
		qdel(slot_item_ID)
		var/obj/item/slot_item_hand = H.get_item_by_slot(slot_r_hand)
		H.unEquip(slot_item_hand)

		var /obj/item/weapon/multisword/multi = new(H)
		H.equip_to_slot_or_del(multi, slot_r_hand)

		var/obj/item/weapon/card/id/W = new(H)
		W.icon_state = "centcom"
		W.access = get_all_accesses()
		W.access += get_all_centcom_access()
		W.assignment = "Multiverse Summoner"
		W.registered_name = H.real_name
		W.update_label(H.real_name)
		H.equip_to_slot_or_del(W, slot_wear_id)

	message_admins("<span class='adminnotice'>[key_name_admin(usr)] used THERE CAN BE ONLY ME!</span>")
	log_admin("[key_name(usr)] used there can be only me.")
