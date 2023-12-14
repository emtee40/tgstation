// This file contains the louadouts for the assistant gimmicks station trait! When active, gives assistants random stupid gear

/// Parent type of gimmick loadouts for assistants for the functional assistant station traits
/datum/outfit/job/assistant/gimmick
	name = "Gimmick Assistant"
	/// The weight of the outfit to be picked
	var/outfit_weight = 0

/datum/outfit/job/assistant/gimmick/post_equip(mob/living/carbon/human/equipped, visualsOnly)
	. = ..()

	// Throw up any hoods
	var/obj/item/clothing/suit/hooded/hood_suit = locate(/obj/item/clothing/suit/hooded) in equipped
	if(hood_suit)
		SEND_SIGNAL(hood_suit, COMSIG_ITEM_UI_ACTION_CLICK) //we commit some tomfoolery

/datum/outfit/job/assistant/gimmick/bee
	name = "Gimmick Assistant - Bee"
	suit = /obj/item/clothing/suit/hooded/bee_costume
	l_pocket = /obj/item/coupon/bee

	outfit_weight = 5

/obj/item/coupon/bee
	name = "coupon - 70% off Beekeeping Starter Crate"
	desc = "BEEEES???? AT AN AFFORDAbLE PORICE?!!!" //wordcoders seething

	discounted_pack = /datum/supply_pack/organic/hydroponics/beekeeping_fullkit
	discount_pct_off = 0.7

/datum/outfit/job/assistant/gimmick/chicken
	name = "Gimmick Assistant - Chicken"
	suit = /obj/item/clothing/suit/costume/chickensuit
	head = /obj/item/clothing/head/costume/chicken

	l_hand = /obj/item/storage/fancy/egg_box/fertile

	outfit_weight = 3

/datum/outfit/job/assistant/gimmick/cyborg
	name = "Gimmick Assistant - Cardborg"
	suit = /obj/item/clothing/suit/costume/cardborg
	head = /obj/item/clothing/head/costume/cardborg

	r_hand = /obj/item/weldingtool/largetank
	l_hand = /obj/item/stack/cable_coil/five

	uniform = /obj/item/clothing/under/color/black

	outfit_weight = 3

/datum/outfit/job/assistant/gimmick/cyborg/post_equip(mob/living/carbon/human/equipped, visualsOnly)
	. = ..()
	var/obj/item/organ/internal/tongue/robot/robotongue = new ()
	robotongue.Insert(equipped, movement_flags = DELETE_IF_REPLACED)

/datum/outfit/job/assistant/gimmick/skater
	name = "Gimmick Assistant - Skater"
	head = /obj/item/clothing/head/helmet/redtaghelm
	suit = /obj/item/clothing/suit/redtag

	l_hand = /obj/item/melee/skateboard

	uniform = /obj/item/clothing/under/color/orange

	outfit_weight = 10

/datum/outfit/job/assistant/gimmick/rollerskater
	name = "Gimmick Assistant - Rollerskater"
	head = /obj/item/clothing/head/helmet/bluetaghelm
	suit = /obj/item/clothing/suit/bluetag

	shoes = /obj/item/clothing/shoes/wheelys/rollerskates

	uniform = /obj/item/clothing/under/color/darkblue

	outfit_weight = 10

/datum/outfit/job/assistant/gimmick/fisher
	name = "Gimmick Assistant - Fisher"
	suit = /obj/item/clothing/suit/jacket/puffer/vest
	r_hand = /obj/item/storage/toolbox/fishing

	outfit_weight = 5

/datum/outfit/job/assistant/gimmick/patient
	name = "Gimmick Assistant - Patient"
	suit = /obj/item/clothing/suit/apron/surgical

	l_pocket = /obj/item/storage/pill_bottle/multiver
	r_pocket = /obj/item/storage/pill_bottle/mutadone

	uniform = /obj/item/clothing/under/color/white

	outfit_weight = 3

/datum/outfit/job/assistant/gimmick/mopper
	name = "Gimmick Assistant - Mopper"
	suit = /obj/item/clothing/suit/caution

	l_hand = /obj/item/mop

	outfit_weight = 5

/datum/outfit/job/assistant/gimmick/mopper/post_equip(mob/living/carbon/human/equipped, visualsOnly)
	. = ..()

	for(var/turf/turf in range(1, equipped))
		if(turf.is_blocked_turf())
			continue
		var/obj/structure/mop_bucket/bucket = new /obj/structure/mop_bucket(turf)
		equipped.start_pulling(bucket)

/datum/outfit/job/assistant/gimmick/broomer
	name = "Gimmick Assistant - Broomer"
	suit = /obj/item/clothing/suit/caution

	l_hand = /obj/item/pushbroom
	r_hand = /obj/item/storage/bag/trash

	outfit_weight = 5

/datum/outfit/job/assistant/gimmick/hall_monitor
	name = "Gimmick Assistant = Hall Monitor"
	head = /obj/item/clothing/head/collectable/police
	mask = /obj/item/clothing/mask/whistle

	neck = /obj/item/camera

	outfit_weight = 3

/datum/outfit/job/assistant/gimmick/monkey
	name = "Gimmick Assistant - Monkey"
	suit = /obj/item/clothing/suit/costume/monkeysuit
	mask = /obj/item/clothing/mask/gas/monkeymask
	l_pocket = /obj/item/food/monkeycube
	r_pocket = /obj/item/food/monkeycube

	outfit_weight = 5

/datum/outfit/job/assistant/gimmick/flesh
	name = "Gimmick Assistant - FLeshy"
	suit = /obj/item/clothing/suit/hooded/bloated_human
	r_hand = /obj/item/toy/foamblade

	outfit_weight = 1

/datum/outfit/job/assistant/gimmick/lightbringer
	name = "Gimmick Assistant - Lightbringer"
	l_pocket = /obj/item/flashlight/lantern
	r_pocket = /obj/item/lightreplacer

	uniform = /obj/item/clothing/under/color/yellow

	outfit_weight = 3

/datum/outfit/job/assistant/gimmick/handyman
	name = "Gimmick Assistant - Handyman"
	suit = /obj/item/clothing/suit/hazardvest
	belt = /obj/item/storage/belt/utility/full
	head = /obj/item/clothing/head/utility/hardhat

	outfit_weight = 8

/datum/outfit/job/assistant/gimmick/magician
	name = "Gimmick Assistant - Magician"

	head = /obj/item/clothing/head/hats/tophat
	l_hand = /obj/item/gun/magic/wand/nothing

	outfit_weight = 2

