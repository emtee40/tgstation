/obj/item/organ/internal/brain/psyker
	name = "psyker brain"
	desc = "This brain is blue, split into two hemispheres, and has immense psychic powers. Why does that even exist?"
	icon_state = "brain-psyker"

/obj/item/organ/internal/brain/psyker/Insert(mob/living/carbon/inserted_into, special, drop_if_replaced, no_id_transfer)
	if(!istype(inserted_into.get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/psyker))
		return FALSE
	. = ..()
	inserted_into.AddComponent(/datum/component/echolocation)

/obj/item/bodypart/head/psyker
	limb_id = BODYPART_ID_PSYKER
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodypart_traits = list(TRAIT_DISFIGURED, TRAIT_BALD, TRAIT_SHAVED, TRAIT_BLIND, TRAIT_UNINTELLIGIBLE_SPEECH)

/mob/living/carbon/human/proc/psykerize()
	if(stat == DEAD || !get_bodypart(BODY_ZONE_HEAD))
		return
	to_chat(src, span_userdanger("You feel unwell..."))
	sleep(5 SECONDS)
	if(stat == DEAD || !get_bodypart(BODY_ZONE_HEAD))
		return
	to_chat(src, span_userdanger("It hurts!"))
	emote("scream")
	apply_damage(30, BRUTE, BODY_ZONE_HEAD)
	sleep(5 SECONDS)
	var/obj/item/bodypart/head/old_head = get_bodypart(BODY_ZONE_HEAD)
	var/obj/item/organ/internal/brain/old_brain = getorganslot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/internal/old_eyes = getorganslot(ORGAN_SLOT_EYES)
	if(stat == DEAD || !old_head || !old_brain)
		return
	to_chat(src, span_userdanger("Your head splits open! Your brain mutates!"))
	emote("scream")
	var/obj/item/bodypart/head/psyker/psyker_head = new()
	psyker_head.receive_damage(brute = 50)
	if(!psyker_head.replace_limb(src, special = TRUE))
		return
	qdel(old_head)
	var/obj/item/organ/internal/brain/psyker/psyker_brain = new()
	old_brain.before_organ_replacement(psyker_brain)
	old_brain.Remove(src, special = TRUE, no_id_transfer = TRUE)
	qdel(old_brain)
	psyker_brain.Insert(src, special = TRUE, drop_if_replaced = FALSE)
	if(old_eyes)
		qdel(old_eyes)

/datum/religion_rites/nullrod_transformation
	name = "Transmogrify"
	desc = "Your full power needs a firearm to be realized. You may transform your null rod into one."
	ritual_length = 10 SECONDS
	///The rod that will be transmogrified.
	var/obj/item/nullrod/transformation_target

/datum/religion_rites/nullrod_transformation/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/nullrod/nullrod in get_turf(religious_tool))
		transformation_target = rod
		return ..()
	to_chat(user, span_warning("You need to place a null rod on [religious_tool] to do this!"))
	return FALSE

/datum/religion_rites/nullrod_transformation/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/obj/item/nullrod/nullrod = transformation_target
	transformation_target = null
	qdel(nullrod)
/*	if(QDELETED(moldify) || !(get_turf(religious_tool) == moldify.loc)) //check if the same food is still there
		to_chat(user, span_warning("Your target left the altar!"))
		return FALSE
	to_chat(user, span_warning("[moldify] becomes rancid!"))
	user.emote("laughs")
	new /obj/item/food/badrecipe/moldy(get_turf(religious_tool))
	qdel(moldify)

	return TRUE */

/obj/item/gun/ballistic/revolver/chaplain
