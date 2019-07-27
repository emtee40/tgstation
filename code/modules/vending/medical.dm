/obj/machinery/vending/medical
	name = "\improper NanoMed Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	icon_deny = "med-deny"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access = list(ACCESS_MEDICAL)
	products = list(/obj/item/stack/medical/gauze = 8,
					/obj/item/reagent_containers/syringe = 12,
					/obj/item/reagent_containers/dropper = 3,
					/obj/item/healthanalyzer = 4,
					/obj/item/reagent_containers/pill/patch/styptic = 5,
					/obj/item/reagent_containers/pill/patch/silver_sulf = 5,
<<<<<<< HEAD
					/obj/item/reagent_containers/syringe/perfluorodecalin = 2,
					/obj/item/reagent_containers/pill/insulin = 5,
					/obj/item/reagent_containers/glass/bottle/charcoal = 4,
					/obj/item/reagent_containers/glass/bottle/epinephrine = 3,
					/obj/item/reagent_containers/glass/bottle/morphine = 4,
					/obj/item/reagent_containers/glass/bottle/potass_iodide = 1,
					/obj/item/reagent_containers/glass/bottle/salglu_solution = 3,
					/obj/item/reagent_containers/glass/bottle/toxin = 3,
					/obj/item/reagent_containers/syringe/antiviral = 6,
					/obj/item/reagent_containers/medigel/styptic = 2,
					/obj/item/reagent_containers/medigel/silver_sulf = 2,
					/obj/item/reagent_containers/medigel/sterilizine = 1,
=======
					/obj/item/reagent_containers/pill/salbutamol = 2,
					/obj/item/reagent_containers/pill/insulin = 5,
					/obj/item/reagent_containers/glass/bottle/charcoal = 4,
					/obj/item/reagent_containers/glass/bottle/epinephrine = 4,
					/obj/item/reagent_containers/glass/bottle/salglu_solution = 3,
					/obj/item/reagent_containers/glass/bottle/morphine = 4,
					/obj/item/reagent_containers/glass/bottle/toxin = 3,
					/obj/item/reagent_containers/syringe/antiviral = 6,
					/obj/item/reagent_containers/medspray/styptic = 2,
					/obj/item/reagent_containers/medspray/silver_sulf = 2,
					/obj/item/reagent_containers/medspray/sterilizine = 1,
>>>>>>> Updated this old code to fork
					/obj/item/sensor_device = 2,
					/obj/item/pinpointer/crew = 2)
	contraband = list(/obj/item/reagent_containers/pill/tox = 3,
		              /obj/item/reagent_containers/pill/morphine = 4,
		              /obj/item/reagent_containers/pill/charcoal = 6,
		              /obj/item/storage/box/hug/medical = 1)
<<<<<<< HEAD
	premium = list(/obj/item/reagent_containers/medigel/synthflesh = 2,
=======
	premium = list(/obj/item/reagent_containers/medspray/synthflesh = 2,
>>>>>>> Updated this old code to fork
		           /obj/item/storage/pill_bottle/psicodine = 2,
		           /obj/item/reagent_containers/hypospray/medipen = 3,
		           /obj/item/storage/belt/medical = 3,
		           /obj/item/wrench/medical = 1,
		           /obj/item/storage/firstaid/advanced = 2)
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/medical
	default_price = 25
	extra_price = 100
	payment_department = ACCOUNT_MED
<<<<<<< HEAD

=======
>>>>>>> Updated this old code to fork
/obj/item/vending_refill/medical
	machine_name = "NanoMed Plus"
	icon_state = "refill_medical"

/obj/machinery/vending/medical/syndicate_access
	name = "\improper SyndiMed Plus"
	req_access = list(ACCESS_SYNDICATE)
