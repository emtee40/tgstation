/obj/structure/fireaxecabinet
	name = "fire axe cabinet"
	desc = "There is a small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "fireaxe"
	anchored = TRUE
	density = FALSE
	armor = list(MELEE = 50, BULLET = 20, LASER = 0, ENERGY = 100, BOMB = 10, BIO = 0, FIRE = 90, ACID = 50)
	max_integrity = 150
	integrity_failure = 0.33
	var/locked = TRUE
	var/open = FALSE
	var/obj/item/held_item
	var/item_path = /obj/item/fireaxe
	var/item_overlay = "axe"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/fireaxecabinet, 32)

/obj/structure/fireaxecabinet/Initialize(mapload)
	. = ..()
	held_item = new item_path(src)
	update_appearance()

/obj/structure/fireaxecabinet/Destroy()
	if(held_item)
		QDEL_NULL(held_item)
	return ..()

/obj/structure/fireaxecabinet/attackby(obj/item/attacking_item, mob/living/user, params)
	if(iscyborg(user) || attacking_item.tool_behaviour == TOOL_MULTITOOL)
		toggle_lock(user)
	else if(attacking_item.tool_behaviour == TOOL_WELDER && !user.combat_mode && !broken)
		if(atom_integrity < max_integrity)
			if(!attacking_item.tool_start_check(user, amount = 2))
				return
			to_chat(user, span_notice("You begin repairing [src]."))
			if(attacking_item.use_tool(src, user, 4 SECONDS, volume= 50, amount = 2))
				repair_damage(max_integrity - get_integrity())
				update_appearance()
				to_chat(user, span_notice("You repair [src]."))
		else
			to_chat(user, span_warning("[src] is already in good condition!"))
		return
	else if(istype(attacking_item, /obj/item/stack/sheet/glass) && broken)
		var/obj/item/stack/sheet/glass/glass_stack = attacking_item
		if(glass_stack.get_amount() < 2)
			to_chat(user, span_warning("You need two glass sheets to fix [src]!"))
			return
		to_chat(user, span_notice("You start fixing [src]..."))
		if(do_after(user, 2 SECONDS, target = src) && glass_stack.use(2))
			broken = FALSE
			atom_integrity = max_integrity
			update_appearance()
	else if(open || broken)
		if(istype(attacking_item, item_path) && !held_item)
			if(HAS_TRAIT(attacking_item, TRAIT_WIELDED))
				to_chat(user, span_warning("Unwield [attacking_item] first."))
				return
			if(!user.transferItemToLoc(attacking_item, src))
				return
			held_item = attacking_item
			to_chat(user, span_notice("You place [attacking_item] back in [src]."))
			update_appearance()
			return
		else if(!broken)
			toggle_open()
	else
		return ..()

/obj/structure/fireaxecabinet/Exited(atom/movable/gone, direction)
	if(gone == held_item)
		held_item = null
		update_appearance()
	return ..()

/obj/structure/fireaxecabinet/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(broken)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 90, TRUE)
			else
				playsound(loc, 'sound/effects/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/fireaxecabinet/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = TRUE, attack_dir)
	if(open)
		return
	. = ..()
	if(.)
		update_appearance()

/obj/structure/fireaxecabinet/atom_break(damage_flag)
	. = ..()
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		update_appearance()
		broken = TRUE
		playsound(src, 'sound/effects/glassbr3.ogg', 100, TRUE)
		new /obj/item/shard(loc)
		new /obj/item/shard(loc)

/obj/structure/fireaxecabinet/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(held_item && loc)
			held_item.forceMove(loc)
		new /obj/item/stack/sheet/iron(loc, 2)
	qdel(src)

/obj/structure/fireaxecabinet/blob_act(obj/structure/blob/B)
	if(held_item)
		held_item.forceMove(loc)
	qdel(src)

/obj/structure/fireaxecabinet/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if((open || broken) && held_item)
		to_chat(user, span_notice("You take [held_item] from [src]."))
		user.put_in_hands(held_item)
		add_fingerprint(user)
		update_appearance()
		return
	toggle_open(user)

/obj/structure/fireaxecabinet/attack_paw(mob/living/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/fireaxecabinet/attack_ai(mob/user)
	toggle_lock(user)
	return

/obj/structure/fireaxecabinet/attack_tk(mob/user)
	. = COMPONENT_CANCEL_ATTACK_CHAIN
	if(locked)
		to_chat(user, span_warning("The [name] won't budge!"))
		return
	open = !open
	update_appearance()

/obj/structure/fireaxecabinet/update_overlays()
	. = ..()
	if(held_item)
		. += item_overlay
	if(open)
		. += "glass_raised"
		return
	var/hp_percent = atom_integrity/max_integrity * 100
	if(broken)
		. += "glass4"
	else
		switch(hp_percent)
			if(-INFINITY to 40)
				. += "glass3"
			if(40 to 60)
				. += "glass2"
			if(60 to 80)
				. += "glass1"
			if(80 to INFINITY)
				. += "glass"

	. += locked ? "locked" : "unlocked"

/obj/structure/fireaxecabinet/proc/toggle_lock(mob/user)
	to_chat(user, span_notice("Resetting circuitry..."))
	playsound(src, 'sound/machines/locktoggle.ogg', 50, TRUE)
	if(do_after(user, 2 SECONDS, target = src))
		to_chat(user, span_notice("You [locked ? "disable" : "re-enable"] the locking modules."))
		locked = !locked
		update_appearance()

/obj/structure/fireaxecabinet/proc/toggle_open(mob/user)
	if(locked)
		to_chat(user, span_warning("\The [name] won't budge!"))
		return
	else
		open = !open
		update_appearance()
		return

/obj/structure/fireaxecabinet/mechremoval
	name = "mech removal tool cabinet"
	desc = "There is a small label that reads \"For Emergency use only\" along with details for safe use of the tool. As if."
	icon_state = "mechremoval"
	item_path = /obj/item/crowbar/mechremoval
	item_overlay = "crowbar"
