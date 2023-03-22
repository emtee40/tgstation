///SNAIL
/obj/item/bodypart/head/snail
	limb_id = SPECIES_SNAIL
	is_dimorphic = FALSE

/obj/item/bodypart/chest/snail
	limb_id = SPECIES_SNAIL
	is_dimorphic = FALSE

/obj/item/bodypart/arm/left/snail
	limb_id = SPECIES_SNAIL
	unarmed_attack_verb = "slap"
	unarmed_attack_effect = ATTACK_EFFECT_DISARM
	unarmed_damage_high = 0.5 //snails are soft and squishy

/obj/item/bodypart/arm/right/snail
	limb_id = SPECIES_SNAIL
	unarmed_attack_verb = "slap"
	unarmed_attack_effect = ATTACK_EFFECT_DISARM
	unarmed_damage_high = 0.5

/obj/item/bodypart/leg/left/snail
	limb_id = SPECIES_SNAIL
	unarmed_damage_high = 0.5
/obj/item/bodypart/leg/right/snail
	limb_id = SPECIES_SNAIL
	unarmed_damage_high = 0.5

///ABDUCTOR
/obj/item/bodypart/head/abductor
	biological_state = BIO_INORGANIC //i have no fucking clue why these mfs get no wounds but SURE
	limb_id = SPECIES_ABDUCTOR
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/abductor
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_ABDUCTOR
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/abductor
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_ABDUCTOR
	should_draw_greyscale = FALSE
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/arm/right/abductor
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_ABDUCTOR
	should_draw_greyscale = FALSE
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/leg/left/abductor
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_ABDUCTOR
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/abductor
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_ABDUCTOR
	should_draw_greyscale = FALSE

///JELLY
/obj/item/bodypart/head/jelly
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_JELLYPERSON
	is_dimorphic = TRUE
	dmg_overlay_type = null

/obj/item/bodypart/chest/jelly
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_JELLYPERSON
	is_dimorphic = TRUE
	dmg_overlay_type = null

/obj/item/bodypart/arm/left/jelly
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_JELLYPERSON
	dmg_overlay_type = null

/obj/item/bodypart/arm/right/jelly
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_JELLYPERSON
	dmg_overlay_type = null

/obj/item/bodypart/leg/left/jelly
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_JELLYPERSON
	dmg_overlay_type = null

/obj/item/bodypart/leg/right/jelly
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_JELLYPERSON
	dmg_overlay_type = null

///SLIME
/obj/item/bodypart/head/slime
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_SLIMEPERSON
	is_dimorphic = FALSE

/obj/item/bodypart/chest/slime
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_SLIMEPERSON
	is_dimorphic = TRUE

/obj/item/bodypart/arm/left/slime
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_SLIMEPERSON

/obj/item/bodypart/arm/right/slime
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_SLIMEPERSON

/obj/item/bodypart/leg/left/slime
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_SLIMEPERSON

/obj/item/bodypart/leg/right/slime
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_SLIMEPERSON

///LUMINESCENT
/obj/item/bodypart/head/luminescent
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_LUMINESCENT
	is_dimorphic = TRUE

/obj/item/bodypart/chest/luminescent
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_LUMINESCENT
	is_dimorphic = TRUE

/obj/item/bodypart/arm/left/luminescent
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_LUMINESCENT

/obj/item/bodypart/arm/right/luminescent
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_LUMINESCENT

/obj/item/bodypart/leg/left/luminescent
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_LUMINESCENT

/obj/item/bodypart/leg/right/luminescent
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_LUMINESCENT

///ZOMBIE
/obj/item/bodypart/head/zombie
	limb_id = SPECIES_ZOMBIE
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/zombie
	limb_id = SPECIES_ZOMBIE
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/zombie
	limb_id = SPECIES_ZOMBIE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/zombie
	limb_id = SPECIES_ZOMBIE
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/left/zombie
	limb_id = SPECIES_ZOMBIE
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/zombie
	limb_id = SPECIES_ZOMBIE
	should_draw_greyscale = FALSE

///PODPEOPLE
/obj/item/bodypart/head/pod
	limb_id = SPECIES_PODPERSON
	is_dimorphic = TRUE

/obj/item/bodypart/chest/pod
	limb_id = SPECIES_PODPERSON
	is_dimorphic = TRUE

/obj/item/bodypart/arm/left/pod
	limb_id = SPECIES_PODPERSON
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/pod
	limb_id = SPECIES_PODPERSON
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/leg/left/pod
	limb_id = SPECIES_PODPERSON

/obj/item/bodypart/leg/right/pod
	limb_id = SPECIES_PODPERSON

///FLY
/obj/item/bodypart/head/fly
	limb_id = SPECIES_FLYPERSON
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/fly
	limb_id = SPECIES_FLYPERSON
	is_dimorphic = TRUE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/fly
	limb_id = SPECIES_FLYPERSON
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/fly
	limb_id = SPECIES_FLYPERSON
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/left/fly
	limb_id = SPECIES_FLYPERSON
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/fly
	limb_id = SPECIES_FLYPERSON
	should_draw_greyscale = FALSE

///SHADOW
/obj/item/bodypart/head/shadow
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_SHADOW
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/shadow
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_SHADOW
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/shadow
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_SHADOW
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/shadow
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_SHADOW
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/left/shadow
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_SHADOW
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/shadow
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_SHADOW
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/shadow/nightmare
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/arm/right/shadow/nightmare
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

///SKELETON
/obj/item/bodypart/head/skeleton
	biological_state = BIO_BONE
	limb_id = SPECIES_SKELETON
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	dmg_overlay_type = null

/obj/item/bodypart/chest/skeleton
	biological_state = BIO_BONE
	limb_id = SPECIES_SKELETON
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	dmg_overlay_type = null

/obj/item/bodypart/arm/left/skeleton
	biological_state = BIO_BONE
	limb_id = SPECIES_SKELETON
	should_draw_greyscale = FALSE
	dmg_overlay_type = null

/obj/item/bodypart/arm/right/skeleton
	biological_state = BIO_BONE
	limb_id = SPECIES_SKELETON
	should_draw_greyscale = FALSE
	dmg_overlay_type = null

/obj/item/bodypart/leg/left/skeleton
	biological_state = BIO_BONE
	limb_id = SPECIES_SKELETON
	should_draw_greyscale = FALSE
	dmg_overlay_type = null

/obj/item/bodypart/leg/right/skeleton
	biological_state = BIO_BONE
	limb_id = SPECIES_SKELETON
	should_draw_greyscale = FALSE
	dmg_overlay_type = null

///MUSHROOM
/obj/item/bodypart/head/mushroom
	limb_id = SPECIES_MUSHROOM
	is_dimorphic = TRUE

/obj/item/bodypart/chest/mushroom
	limb_id = SPECIES_MUSHROOM
	is_dimorphic = TRUE
	bodypart_traits = list(TRAIT_NO_JUMPSUIT)

/obj/item/bodypart/arm/left/mushroom
	limb_id = SPECIES_MUSHROOM
	unarmed_damage_low = 6
	unarmed_damage_high = 14
	unarmed_stun_threshold = 14

/obj/item/bodypart/arm/right/mushroom
	limb_id = SPECIES_MUSHROOM
	unarmed_damage_low = 6
	unarmed_damage_high = 14
	unarmed_stun_threshold = 14

/obj/item/bodypart/leg/left/mushroom
	limb_id = SPECIES_MUSHROOM
	unarmed_damage_low = 9
	unarmed_damage_high = 21
	unarmed_stun_threshold = 14

/obj/item/bodypart/leg/right/mushroom
	limb_id = SPECIES_MUSHROOM
	unarmed_damage_low = 9
	unarmed_damage_high = 21
	unarmed_stun_threshold = 14

///GOLEMS (i hate xenobio SO FUCKING MUCH) (from 2022: Yeah I fucking feel your pain brother)
/obj/item/bodypart/head/golem
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_GOLEM
	is_dimorphic = FALSE
	dmg_overlay_type = null

/obj/item/bodypart/chest/golem
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_GOLEM
	is_dimorphic = TRUE
	dmg_overlay_type = null
	bodypart_traits = list(TRAIT_NO_JUMPSUIT)

/obj/item/bodypart/arm/left/golem
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_GOLEM
	dmg_overlay_type = null
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)
	unarmed_damage_low = 5 // I'd like to take the moment that maintaining all of these random ass golem speciese is hell and oranges was right
	unarmed_damage_high = 14
	unarmed_stun_threshold = 11

/obj/item/bodypart/arm/right/golem
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_GOLEM
	dmg_overlay_type = null
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)
	unarmed_damage_low = 5
	unarmed_damage_high = 14
	unarmed_stun_threshold = 11

/obj/item/bodypart/leg/left/golem
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_GOLEM
	dmg_overlay_type = null
	unarmed_damage_low = 7
	unarmed_damage_high = 21
	unarmed_stun_threshold = 11

/obj/item/bodypart/leg/right/golem
	biological_state = BIO_INORGANIC
	limb_id = SPECIES_GOLEM
	dmg_overlay_type = null
	unarmed_damage_low = 7
	unarmed_damage_high = 21
	unarmed_stun_threshold = 11
