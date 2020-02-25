/obj/item/clothing/mask/balaclava
	name = "balaclava"
	desc = "LOADSAMONEY"
	icon_state = "balaclava"
	item_state = "balaclava"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/adjust)

/obj/item/clothing/mask/balaclava/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/balaclava/syndicate
	name = "perfectly generic balaclava"
	desc = "It makes you feel safe in your anonymity. It seems to have a built in heads-up display."
	clothing_flags = MASKINTERNALS
	armor = list("melee" = 10, "bullet" = 5, "laser" = 0,"energy" = 5, "bomb" = 0, "bio" = 0, "rad" = 10, "fire" = 100, "acid" = 40)
	resistance_flags = FIRE_PROOF
	
/obj/item/clothing/mask/balaclava/syndicate/equipped(mob/living/carbon/human/user, slot)
	..()
	to_chat(user, "You roll the balaclava over your face, and a data display appears before your eyes.")
	ADD_TRAIT(user, TRAIT_DIAGNOSTIC_HUD, MASK_TRAIT)
	ADD_TRAIT(user, TRAIT_DISFIGURED, MASK_TRAIT) //this is so they always speak as unknown
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
	H.add_hud_to(user)

/obj/item/clothing/mask/balaclava/syndicate/dropped(mob/living/carbon/human/user)
	..()
	to_chat(user, "You pull off the balaclava, and the mask's internal hud system switches off quietly.")
	REMOVE_TRAIT(user, TRAIT_DIAGNOSTIC_HUD, MASK_TRAIT)
	REMOVE_TRAIT(user, TRAIT_DISFIGURED, MASK_TRAIT)
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
	H.remove_hud_from(user)

/obj/item/clothing/mask/luchador
	name = "Luchador Mask"
	desc = "Worn by robust fighters, flying high to defeat their foes!"
	icon_state = "luchag"
	item_state = "luchag"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_SMALL
	modifies_speech = TRUE

/obj/item/clothing/mask/luchador/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = replacetext(message, "captain", "CAPITÁN")
		message = replacetext(message, "station", "ESTACIÓN")
		message = replacetext(message, "sir", "SEÑOR")
		message = replacetext(message, "the ", "el ")
		message = replacetext(message, "my ", "mi ")
		message = replacetext(message, "is ", "es ")
		message = replacetext(message, "it's", "es")
		message = replacetext(message, "friend", "amigo")
		message = replacetext(message, "buddy", "amigo")
		message = replacetext(message, "hello", "hola")
		message = replacetext(message, " hot", " caliente")
		message = replacetext(message, " very ", " muy ")
		message = replacetext(message, "sword", "espada")
		message = replacetext(message, "library", "biblioteca")
		message = replacetext(message, "traitor", "traidor")
		message = replacetext(message, "wizard", "mago")
		message = uppertext(message)	//Things end up looking better this way (no mixed cases), and it fits the macho wrestler image.
		if(prob(25))
			message += " OLE!"
	speech_args[SPEECH_MESSAGE] = message

/obj/item/clothing/mask/luchador/tecnicos
	name = "Tecnicos Mask"
	desc = "Worn by robust fighters who uphold justice and fight honorably."
	icon_state = "luchador"
	item_state = "luchador"

/obj/item/clothing/mask/luchador/rudos
	name = "Rudos Mask"
	desc = "Worn by robust fighters who are willing to do anything to win."
	icon_state = "luchar"
	item_state = "luchar"

/obj/item/clothing/mask/russian_balaclava
	name = "russian balaclava"
	desc = "Protects your face from snow."
	icon_state = "rus_balaclava"
	item_state = "rus_balaclava"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_SMALL
