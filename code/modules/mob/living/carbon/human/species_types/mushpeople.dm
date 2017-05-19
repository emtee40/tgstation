/datum/species/mush //mush mush codecuck
	name = "Mushroomperson"
	id = "mush"
	mutant_bodyparts = list("caps", "tail_human", "ears", "wings")
	default_features = list("caps" = "Round", "tail_human" = "None", "ears" = "None", "wings" = "None")

	eye_style = "mush"
	fixed_mut_color = "DBBF92"
	hair_color = "FF4B19" //cap color, spot color uses eye color

	say_mod = "poofs" //what does a mushroom sound like
	species_traits = list(EYECOLOR, MUTCOLORS)

	punchdamagelow = 6
	punchdamagehigh = 14
	punchstunthreshold = 14 //about 44% chance to stun

	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_w_uniform)

	burnmod = 1.25
	heatmod = 1.5

	meat = /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice

	mutanteyes = /obj/item/organ/eyes/night_vision
	use_skintones = FALSE



/datum/species/mush/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.faction |= "mushroom"
	var/datum/language/mushroom/M = new
	C.initial_languages |= M

/datum/species/mush/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.faction -= "mushroom"
	for(var/I in C.initial_languages)
		if(istype(I, /datum/language/mushroom))
			C.initial_languages -= I

/datum/species/mush/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "weedkiller")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/mush/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	forced_colour = FALSE
	..()

