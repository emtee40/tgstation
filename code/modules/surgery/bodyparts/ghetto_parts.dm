/obj/item/bodypart/arm/left/ghetto
	name = "left peg arm"
	desc = "A roughly hewn wooden peg replaces where a forearm should be. It's simple and sturdy, clearly made in a hurry with whatever materials were at hand. Despite its crude appearance, it gets the job done."
	icon = 'icons/mob/human/species/ghetto.dmi'
	icon_static = 'icons/mob/human/species/ghetto.dmi'
	limb_id = BODYPART_ID_PEG
	icon_state = "peg_l_arm"
	bodytype = BODYTYPE_PEG
	should_draw_greyscale = FALSE
	attack_verb_simple = list("bashed", "slashed")
	unarmed_damage_low = 3
	unarmed_damage_high = 9
	unarmed_effectiveness = 5
	brute_modifier = 1.2
	burn_modifier = 1.5

/obj/item/bodypart/arm/left/ghetto/Initialize(mapload, ...)
	. = ..()
	ADD_TRAIT(src, TRAIT_EASY_ATTACH, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_CHUNKYFINGERS, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NEVER_WOUNDED, INNATE_TRAIT)

/obj/item/bodypart/arm/right/ghetto
	name = "right peg arm"
	desc = "A roughly hewn wooden peg replaces where a forearm should be. It's simple and sturdy, clearly made in a hurry with whatever materials were at hand. Despite its crude appearance, it gets the job done."
	icon = 'icons/mob/human/species/ghetto.dmi'
	icon_static = 'icons/mob/human/species/ghetto.dmi'
	limb_id = BODYPART_ID_PEG
	icon_state = "peg_r_arm"
	body_zone = BODY_ZONE_R_ARM
	bodyshape = BODYSHAPE_HUMANOID
	bodytype = BODYTYPE_PEG
	should_draw_greyscale = FALSE
	plaintext_zone = "right arm"
	aux_zone = BODY_ZONE_PRECISE_R_HAND
	held_index = 2
	px_x = 6
	px_y = 0
	bodypart_trait_source = RIGHT_ARM_TRAIT
	attack_verb_simple = list("bashed", "slashed")
	can_be_disabled = TRUE
	unarmed_damage_low = 3
	unarmed_damage_high = 9
	unarmed_effectiveness = 5
	brute_modifier = 1.2
	burn_modifier = 1.5

/obj/item/bodypart/arm/right/ghetto/Initialize(mapload, ...)
	. = ..()
	ADD_TRAIT(src, TRAIT_EASY_ATTACH, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_CHUNKYFINGERS, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NEVER_WOUNDED, INNATE_TRAIT)

/obj/item/bodypart/leg/left/ghetto
	name = "left peg leg"
	desc = "Fashioned from what looks suspiciously like a table leg, this peg leg brings a whole new meaning to 'dining on the go.' It's a bit wobbly and creaks ominously with every step, but at least you can claim to have the most well-balanced diet on the seven seas."
	icon = 'icons/mob/human/species/ghetto.dmi'
	icon_static = 'icons/mob/human/species/ghetto.dmi'
	limb_id = BODYPART_ID_PEG
	icon_state = "peg_l_leg"
	body_zone = BODY_ZONE_L_LEG
	bodyshape = BODYSHAPE_HUMANOID
	bodytype = BODYTYPE_PEG
	should_draw_greyscale = FALSE
	plaintext_zone = "left leg"
	px_x = -2
	px_y = 12
	can_be_disabled = TRUE
	bodypart_trait_source = LEFT_LEG_TRAIT
	unarmed_damage_low = 2
	unarmed_damage_high = 5
	unarmed_effectiveness = 10
	brute_modifier = 1.2
	burn_modifier = 1.5

/obj/item/bodypart/leg/left/ghetto/Initialize(mapload, ...)
	. = ..()
	ADD_TRAIT(src, TRAIT_EASY_ATTACH, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NEVER_WOUNDED, INNATE_TRAIT)

/obj/item/bodypart/leg/right/ghetto
	name = "right peg leg"
	desc = "Fashioned from what looks suspiciously like a table leg, this peg leg brings a whole new meaning to 'dining on the go.' It's a bit wobbly and creaks ominously with every step, but at least you can claim to have the most well-balanced diet on the seven seas."
	icon = 'icons/mob/human/species/ghetto.dmi'
	icon_static = 'icons/mob/human/species/ghetto.dmi'
	limb_id = BODYPART_ID_PEG
	icon_state = "peg_r_leg"
	body_zone = BODY_ZONE_R_LEG
	bodyshape = BODYSHAPE_HUMANOID
	bodytype = BODYTYPE_PEG
	should_draw_greyscale = FALSE
	plaintext_zone = "right leg"
	px_x = 2
	px_y = 12
	bodypart_trait_source = RIGHT_LEG_TRAIT
	unarmed_damage_low = 2
	unarmed_damage_high = 5
	unarmed_effectiveness = 10
	brute_modifier = 1.2
	burn_modifier = 1.5

/obj/item/bodypart/leg/right/ghetto/Initialize(mapload, ...)
	. = ..()
	ADD_TRAIT(src, TRAIT_EASY_ATTACH, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NEVER_WOUNDED, INNATE_TRAIT)
