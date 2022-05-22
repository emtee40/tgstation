/**
 * # Ninja Mask
 *
 * Space ninja's mask.  Other than looking cool, doesn't do anything.
 *
 * A mask which only spawns as a part of space ninja's starting kit.  Functions as a gas mask.
 *
 */
/obj/item/clothing/mask/gas/ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "ninja"
	strip_delay = 12 SECONDS
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	has_fov = FALSE

/obj/item/clothing/under/syndicate/ninja
	name = "ninja suit"
	desc = "A nano-enhanced jumpsuit designed for maximum comfort and tacticality."
	icon_state = "ninja_suit"
	can_adjust = FALSE
