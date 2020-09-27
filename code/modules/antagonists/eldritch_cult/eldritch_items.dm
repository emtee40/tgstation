/obj/item/living_heart
	name = "Living Heart"
	desc = "Link to the worlds beyond."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "living_heart"
	w_class = WEIGHT_CLASS_SMALL
	///Target
	var/mob/living/carbon/human/target

/obj/item/living_heart/attack_self(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return
	if(!target)
		to_chat(user,"<span class='warning'>No target could be found. Put the living heart on the rune and use the rune to recieve a target.</span>")
		return
	var/dist = get_dist(user.loc,target.loc)
	var/dir = get_dir(user.loc,target.loc)
	if(user.z != target.z)
		to_chat(user,"<span class='warning'>[target.real_name] is on another plane of existance!</span>")
	else
		switch(dist)
			if(0 to 15)
				to_chat(user,"<span class='warning'>[target.real_name] is near you. They are to the [dir2text(dir)] of you!</span>")
			if(16 to 31)
				to_chat(user,"<span class='warning'>[target.real_name] is somewhere in your vicinty. They are to the [dir2text(dir)] of you!</span>")
			if(32 to 127)
				to_chat(user,"<span class='warning'>[target.real_name] is far away from you. They are to the [dir2text(dir)] of you!</span>")
			else
				to_chat(user,"<span class='warning'>[target.real_name] is beyond our reach.</span>")

	if(target.stat == DEAD)
		to_chat(user,"<span class='warning'>[target.real_name] is dead. Bring them onto a transmutation rune!</span>")

/datum/action/innate/heretic_shatter
	name = "Shattering Offer"
	desc = "By breaking your blade you are noticed by the hill or rust and are granted an escape from a dire sitatuion. (Teleports you to a random safe z turf on your current z level but destroys your blade.)"
	background_icon_state = "bg_ecult"
	button_icon_state = "shatter"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN
	var/mob/living/carbon/human/holder
	var/obj/item/melee/sickly_blade/sword

/datum/action/innate/heretic_shatter/Grant(mob/user, obj/object)
	sword = object
	holder = user
	//i know what im doing
	return ..()

/datum/action/innate/heretic_shatter/IsAvailable()
	if(IS_HERETIC(holder) || IS_HERETIC_MONSTER(holder))
		return TRUE
	else
		return FALSE

/datum/action/innate/heretic_shatter/Activate()
	var/turf/safe_turf = find_safe_turf(zlevels = sword.z, extended_safety_checks = TRUE)
	do_teleport(holder,safe_turf,forceMove = TRUE)
	to_chat(holder,"<span class='warning'> You feel a gust of energy flow through your body, Rusted Hills heard your call...")
	qdel(sword)


/obj/item/melee/sickly_blade
	name = "Sickly blade"
	desc = "A sickly green crescent blade, decorated with an ornamental eye. You feel like you're being watched..."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eldritch_blade"
	inhand_icon_state = "eldritch_blade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	flags_1 = CONDUCT_1
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_NORMAL
	force = 17
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")
	var/datum/action/innate/heretic_shatter/linked_action

/obj/item/melee/sickly_blade/Initialize()
	. = ..()
	linked_action = new(src)

/obj/item/melee/sickly_blade/attack(mob/living/M, mob/living/user)
	if(!(IS_HERETIC(user) || IS_HERETIC_MONSTER(user)))
		to_chat(user,"<span class='danger'>You feel a pulse of some alien intellect lash out at your mind!</span>")
		var/mob/living/carbon/human/human_user = user
		human_user.AdjustParalyzed(5 SECONDS)
		return FALSE
	return ..()

/obj/item/melee/sickly_blade/pickup(mob/user)
	. = ..()
	linked_action.Grant(user, src)

/obj/item/melee/sickly_blade/dropped(mob/user, silent)
	. = ..()
	linked_action.Remove(user, src)

/obj/item/melee/sickly_blade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/datum/antagonist/heretic/cultie = user.mind.has_antag_datum(/datum/antagonist/heretic)
	if(!cultie || !proximity_flag)
		return
	var/list/knowledge = cultie.get_all_knowledge()
	for(var/X in knowledge)
		var/datum/eldritch_knowledge/eldritch_knowledge_datum = knowledge[X]
		eldritch_knowledge_datum.on_eldritch_blade(target,user,proximity_flag,click_parameters)

/obj/item/melee/sickly_blade/rust
	name = "Rusted Blade"
	desc = "This crescent blade is decrepit, wasting to dust. Yet still it bites, catching flesh with jagged, rotten teeth."
	icon_state = "rust_blade"
	inhand_icon_state = "rust_blade"

/obj/item/melee/sickly_blade/ash
	name = "Ashen Blade"
	desc = "Molten and unwrought, a hunk of metal warped to cinders and slag. Unmade, it aspires to be more than it is, and shears soot-filled wounds with a blunt edge."
	icon_state = "ash_blade"
	inhand_icon_state = "ash_blade"

/obj/item/melee/sickly_blade/flesh
	name = "Flesh Blade"
	desc = "A crescent blade born from a fleshwarped creature. Keenly aware, it seeks to spread to others the excruitations it has endured from dread origins."
	icon_state = "flesh_blade"
	inhand_icon_state = "flesh_blade"

/obj/item/melee/sickly_blade/void
	name = "Void Blade"
	desc = "Devoid of any substance, this blade reflects nothingness. It is a real depiction of purity, and chaos that ensues after its implementation."
	icon_state = "void_blade"
	inhand_icon_state = "flesh_blade"

/obj/item/clothing/neck/eldritch_amulet
	name = "Warm Eldritch Medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the world around you melts away. You see your own beating heart, and the pulse of a thousand others."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eye_medalion"
	w_class = WEIGHT_CLASS_SMALL
	///What trait do we want to add upon equipiing
	var/trait = TRAIT_THERMAL_VISION

/obj/item/clothing/neck/eldritch_amulet/equipped(mob/user, slot)
	. = ..()
	if(ishuman(user) && user.mind && slot == ITEM_SLOT_NECK && (IS_HERETIC(user) || IS_HERETIC_MONSTER(user)) )
		ADD_TRAIT(user, trait, CLOTHING_TRAIT)
		user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, trait, CLOTHING_TRAIT)
	user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/piercing
	name = "Piercing Eldritch Medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the light refracts into new and terrifying spectrums of color. You see yourself, reflected off cascading mirrors, warped into improbable shapes."
	trait = TRAIT_XRAY_VISION

/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "ominous hood"
	icon_state = "eldritch"
	desc = "A torn, dust-caked hood. Strange eyes line the inside."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	flash_protect = FLASH_PROTECTION_WELDER

/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon_state = "eldritch_armor"
	inhand_icon_state = "eldritch_armor"
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/forbidden_book, /obj/item/living_heart)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	// slightly better than normal cult robes
	armor = list(MELEE = 50, BULLET = 50, LASER = 50,ENERGY = 50, BOMB = 35, BIO = 20, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/reagent_containers/glass/beaker/eldritch
	name = "flask of eldritch essence"
	desc = "Toxic to the close minded. Healing to those with knowledge of the beyond."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eldrich_flask"
	list_reagents = list(/datum/reagent/eldritch = 50)

/obj/item/clothing/head/hooded/cult_hoodie/void
	name = "void hood"
	icon_state = "void_cloak"
	flags_inv = NONE
	flags_cover = NONE
	desc = "Black like tar, doesn't reflect any light. Runic symbols line the outside, with each flash you loose comprehension of what you are seeing."
	item_flags = EXAMINE_SKIP
	armor = list(MELEE = 30, BULLET = 30, LASER = 30,ENERGY = 30, BOMB = 15, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/hooded/cultrobes/void
	name = "void cloak"
	desc = "Black like tar, doesn't reflect any light. Runic symbols line the outside, with each flash you loose comprehension of what you are seeing."
	icon_state = "void_cloak"
	inhand_icon_state = "void_cloak"
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/forbidden_book, /obj/item/living_heart)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/void
	// slightly worse than normal cult robes
	armor = list(MELEE = 30, BULLET = 30, LASER = 30,ENERGY = 30, BOMB = 15, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/void_cloak

/obj/item/clothing/suit/hooded/cultrobes/void/ToggleHood()
	if(!iscarbon(src.loc))
		return
	var/mob/living/carbon/carbon_user = src.loc
	if(IS_HERETIC(carbon_user) || IS_HERETIC_MONSTER(carbon_user))
		. = ..()
		//We need to account for the hood shenanigans, and that way we can make sure items always fit, even if one of the slots is used by the fucking hood.
		var/datum/component/storage/concrete/pockets/void_cloak/cloak = GetComponent(/datum/component/storage/concrete/pockets/void_cloak)
		if(suittoggled)
			cloak.max_items = 3
			to_chat(carbon_user,"<span class='notice'>The light shifts around you making the cloak invisible!</span>")
		else
			cloak.max_items = 4
	else
		to_chat(carbon_user,"<span class='danger'>You can't force the hood onto your head!</span>")

	item_flags = suittoggled ? EXAMINE_SKIP : ~EXAMINE_SKIP

/obj/item/clothing/mask/void_mask
	name = "Abyssal Mask"
	desc = "Mask created from the suffering of existance, you can look down it's eyes, and notice something gazing back at you."
	icon_state = "mad_mask"
	inhand_icon_state = "mad_mask"
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	var/mob/living/carbon/human/local_user

/obj/item/clothing/mask/void_mask/equipped(mob/user, slot)
	. = ..()

	if(ishuman(user) && user.mind && slot == ITEM_SLOT_MASK)
		local_user = user
		START_PROCESSING(SSobj,src)
		if(IS_HERETIC(user) || IS_HERETIC_MONSTER(user))
			return
		ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)

/obj/item/clothing/mask/void_mask/dropped(mob/M)
	. = ..()
	local_user = null
	STOP_PROCESSING(SSobj,src)
	REMOVE_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)

/obj/item/clothing/mask/void_mask/process(delta_time)
	if(!local_user)
		return PROCESS_KILL

	for(var/mob/living/carbon/human/human_in_range in spiral_range(9,local_user))
		if(IS_HERETIC(human_in_range) || IS_HERETIC_MONSTER(human_in_range))
			continue

		SEND_SIGNAL(human_in_range,COMSIG_DRAIN_SANITY,rand(-1,-10))

		if(DT_PROB(10,delta_time))
			human_in_range.emote(pick("giggle","laugh"))
			human_in_range.adjustStaminaLoss(10)

		if(DT_PROB(25,delta_time))
			human_in_range.Dizzy(5)

		if(DT_PROB(40,delta_time))
			human_in_range.Jitter(5)

		if(DT_PROB(60,delta_time))
			human_in_range.hallucination += 5

