/obj/machinery/vending/wallmed
	name = "\improper NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	density = FALSE
	products = list(/obj/item/reagent_containers/syringe = 3,
		            /obj/item/reagent_containers/pill/patch/acetaminophen = 5,
					/obj/item/reagent_containers/pill/patch/neomycin_sulfate = 5,
					/obj/item/reagent_containers/pill/palletta = 2,
					/obj/item/reagent_containers/medigel/acetaminophen = 2,
					/obj/item/reagent_containers/medigel/neomycin_sulfate = 2,
					/obj/item/reagent_containers/medigel/sterilizine = 1)
	contraband = list(/obj/item/reagent_containers/pill/tox = 2,
	                  /obj/item/reagent_containers/pill/morphine = 2)
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/wallmed
	default_price = 25
	extra_price = 100
	payment_department = ACCOUNT_MED

/obj/item/vending_refill/wallmed
	machine_name = "NanoMed"
	icon_state = "refill_medical"

/obj/machinery/vending/wallmed/pubby
	products = list(/obj/item/reagent_containers/syringe = 3,
					/obj/item/reagent_containers/pill/patch/acetaminophen = 1,
					/obj/item/reagent_containers/pill/patch/neomycin_sulfate = 1,
					/obj/item/reagent_containers/medigel/sterilizine = 1)
