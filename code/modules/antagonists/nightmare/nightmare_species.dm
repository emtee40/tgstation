/**
 * A highly aggressive subset of shadowlings
 */
/datum/species/shadow/nightmare
	name = "Nightmare"
	id = SPECIES_NIGHTMARE
	examine_limb_id = SPECIES_SHADOW
	burnmod = 1.5
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE
	no_equip = list(ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_SUITSTORE)
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NO_DNA_COPY,NOTRANSSTING,NOEYESPRITES)
	inherent_traits = list(
		TRAIT_ADVANCED_TOOL_USER,
		TRAIT_CAN_STRIP,
		TRAIT_RESIST_COLD,
		TRAIT_NO_BREATH,
		TRAIT_RESIST_HIGH_PRESSURE,
		TRAIT_RESIST_LOW_PRESSURE,
		TRAIT_CHUNKY_FINGERS,
		TRAIT_RAD_IMMUNE,
		TRAIT_VIRUS_IMMUNE,
		TRAIT_PIERCE_IMMUNE,
		TRAIT_NO_DISMEMBER,
		TRAIT_NO_HUNGER,
	)

	mutantheart = /obj/item/organ/internal/heart/nightmare
	mutantbrain = /obj/item/organ/internal/brain/shadow/nightmare

/datum/species/shadow/nightmare/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()

	C.fully_replace_character_name(null, pick(GLOB.nightmare_names))
	C.set_safe_hunger_level()

/datum/species/shadow/nightmare/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			H.visible_message(span_danger("[H] dances in the shadows, evading [P]!"))
			playsound(T, SFX_BULLET_MISS, 75, TRUE)
			return BULLET_ACT_FORCE_PIERCE
	return ..()

/datum/species/shadow/nightmare/check_roundstart_eligible()
	return FALSE
