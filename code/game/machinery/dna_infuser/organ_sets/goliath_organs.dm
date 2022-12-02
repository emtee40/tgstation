
#define GOLIATH_ORGAN_COLOR "#4caee7"
#define GOLIATH_SCLERA_COLOR "#ffffff"
#define GOLIATH_PUPIL_COLOR "#00b1b1"

#define GOLIATH_COLORS GOLIATH_ORGAN_COLOR + GOLIATH_SCLERA_COLOR + GOLIATH_PUPIL_COLOR

///bonus of the goliath: you can swim through space!
/datum/status_effect/organ_set_bonus/goliath
	organs_needed = 4
	bonus_activate_text = span_notice("goliath DNA is deeply infused with you! You can now endure walking on lava!")
	bonus_deactivate_text = span_notice("Your DNA is once again mostly yours, and so fades your ability to survive on lava...")

/datum/status_effect/organ_set_bonus/goliath/enable_bonus()
	. = ..()
	ADD_TRAIT(src, TRAIT_LAVA_IMMUNE, REF(src))

/datum/status_effect/organ_set_bonus/goliath/disable_bonus()
	. = ..()
	REMOVE_TRAIT(src, TRAIT_LAVA_IMMUNE, REF(src))

///goliath eyes, simple night vision
/obj/item/organ/internal/eyes/night_vision/goliath
	name = "goliath eyes"
	desc = "goliath DNA infused into what was once some normal eyes."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "eyes"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = GOLIATH_COLORS

	eye_color_left = "f00"
	eye_color_right = "f00"

/obj/item/organ/internal/eyes/night_vision/goliath/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "eyes are blood red and stone like.", BODY_ZONE_HEAD)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/goliath)

/obj/item/organ/internal/eyes/night_vision/goliath/Insert(mob/living/carbon/eyes_owner, special, drop_if_replaced)
	. = ..()
	ADD_TRAIT(eyes_owner, TRAIT_UNNATURAL_RED_GLOWY_EYES, ORGAN_TRAIT)

/obj/item/organ/internal/eyes/night_vision/goliath/Remove(mob/living/carbon/eyes_owner, special, drop_if_replaced)
	REMOVE_TRAIT(eyes_owner, TRAIT_UNNATURAL_RED_GLOWY_EYES, ORGAN_TRAIT)
	return ..()

///goliath lungs! You can breathe lavaland air mix but can't breath pure O2 from a tank anymore.
/obj/item/organ/internal/lungs/lavaland/goliath
	name = "mutated goliath-lungs"
	desc = "goliath DNA infused into what was once some normal lungs."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "lungs"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = GOLIATH_COLORS

/obj/item/organ/internal/lungs/lavaland/goliath/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "small tendrils grow on their back.", BODY_ZONE_HEAD)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/goliath)

///goliath brain. you can't use gloves but one of your arms becomes a tendril hammer that can be used to mine!
/obj/item/organ/internal/brain/goliath
	name = "mutated goliath-brain"
	desc = "goliath DNA infused into what was once a normal brain."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "brain"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = GOLIATH_COLORS

	var/obj/item/goliath_infuser_hammer/hammer

/obj/item/organ/internal/brain/goliath/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "arm is just a tendril hammer...")
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/goliath)

/obj/item/organ/internal/brain/goliath/Insert(mob/living/carbon/brain_owner, special, drop_if_replaced, no_id_transfer)
	. = ..()
	if(!ishuman(brain_owner))
		return
	var/mob/living/carbon/human/human_receiver = brain_owner
	var/datum/species/rec_species = human_receiver.dna.species
	rec_species.update_no_equip_flags(brain_owner, rec_species.no_equip_flags | ITEM_SLOT_GLOVES)

	hammer = new/obj/item/goliath_infuser_hammer
	brain_owner.put_in_hands(hammer)

/obj/item/organ/internal/brain/goliath/Remove(mob/living/carbon/brain_owner, special, no_id_transfer)
	. = ..()
	UnregisterSignal(brain_owner)
	if(!ishuman(brain_owner))
		return
	var/mob/living/carbon/human/human_receiver = brain_owner
	var/datum/species/rec_species = human_receiver.dna.species
	rec_species.update_no_equip_flags(brain_owner, initial(rec_species.no_equip_flags))
	if(hammer)
		brain_owner.visible_message(span_warning("\The [hammer] disintegrates!"))
		QDEL_NULL(hammer)
	return ..()

/obj/item/goliath_infuser_hammer
	name = "tendril hammer"
	desc = "A mass of tendrils have replaced your arm."
	icon = 'icons/obj/weapons/goliath_hammer.dmi'
	icon_state = "goliath_hammer"
	inhand_icon_state = "goliath_hammer"
	lefthand_file = 'icons/mob/inhands/weapons/goliath_hammer_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/goliath_hammer_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 20
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	attack_verb_continuous = list("smashes", "bashes", "hammers", "crunches")
	attack_verb_simple = list("smash", "bash", "hammer", "crunch")
	hitsound = 'sound/effects/bamf.ogg'
	tool_behaviour = TOOL_MINING
	toolspeed = 0.1
	/// List of factions we deal bonus damage to
	var/list/nemesis_factions = list("mining", "boss")
	/// Amount of damage we deal to the above factions
	var/faction_bonus_force = 80

/obj/item/goliath_infuser_hammer/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/goliath_infuser_hammer/melee_attack_chain(mob/user, atom/target, params)
	. = ..()
	user.changeNext_move(CLICK_CD_MELEE * 2) //hits slower but HARD

/obj/item/goliath_infuser_hammer/attack(mob/living/target, mob/living/carbon/human/user)
	if(!target.density || get_turf(target) == get_turf(user))
		faction_bonus_force = 0
	var/is_nemesis_faction = FALSE
	for(var/found_faction in target.faction)
		if(found_faction in nemesis_factions)
			is_nemesis_faction = TRUE
			force += faction_bonus_force
			nemesis_effects(user, target)
			break
	. = ..()
	if(is_nemesis_faction)
		force -= faction_bonus_force

/obj/item/goliath_infuser_hammer/proc/nemesis_effects(mob/living/user, mob/living/target)
	if(istype(target, /mob/living/simple_animal/hostile/asteroid/elite))
		return
	///we obtain the relative direction from the bat itself to the target
	var/relative_direction = get_cardinal_dir(src, target)
	var/atom/throw_target = get_edge_target_turf(target, relative_direction)
	. = ..()
	if(!QDELETED(target))
		var/whack_speed = (prob(60) ? 1 : 4)
		target.throw_at(throw_target, rand(1, 2), whack_speed, user)

/// goliath heart gives you the ability to survive ash storms.
/obj/item/organ/internal/heart/goliath
	name = "mutated goliath-heart"
	desc = "goliath DNA infused into what was once a normal heart."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "heart"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = GOLIATH_COLORS

	organ_traits = list(TRAIT_ASHSTORM_IMMUNE)

/obj/item/organ/internal/heart/goliath/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "skin has small hide plates growing...")
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/goliath)

#undef GOLIATH_COLORS
