//lavaland_surface_syndicate_base1.dmm and it's modules

/obj/machinery/vending/syndichem
	name = "\improper SyndiChem"
	desc = "A vending machine full of grenades and grenade accessories. Sponsored by Donk Co."
	req_access = list(ACCESS_SYNDICATE)
	products = list(/obj/item/stack/cable_coil = 5,
					/obj/item/assembly/igniter = 20,
					/obj/item/assembly/prox_sensor = 5,
					/obj/item/assembly/signaler = 5,
					/obj/item/assembly/timer = 5,
					/obj/item/assembly/voice = 5,
					/obj/item/assembly/health = 5,
					/obj/item/assembly/infra = 5,
					/obj/item/grenade/chem_grenade = 5,
	                /obj/item/grenade/chem_grenade/large = 5,
	                /obj/item/grenade/chem_grenade/pyro = 5,
	                /obj/item/grenade/chem_grenade/cryo = 5,
	                /obj/item/grenade/chem_grenade/adv_release = 5,
					/obj/item/reagent_containers/food/drinks/bottle/holywater = 1)
	product_slogans = "It's not pyromania if you're getting paid!;You smell that? Plasma, son. Nothing else in the world smells like that.;I love the smell of Plasma in the morning."
	resistance_flags = FIRE_PROOF

/obj/modular_map_root/syndicatebase
	config_file = "strings/modular_maps/syndicatebase.toml"

/obj/item/autosurgeon/organ/syndicate/commsagent
	desc = "A device that automatically - painfully - inserts an implant. It seems someone's specially \
	modified this one to only insert... tongues. Horrifying."
	organ_type = /obj/item/organ/tongue

/obj/structure/closet/crate/secure/freezer/commsagent
	name = "Assorted Tongues And Tongue Accessories"
	desc = "Unearthing this was probably a mistake."

/obj/structure/closet/crate/secure/freezer/commsagent/PopulateContents()
	. = ..() //Contains a variety of less exotic tongues (And tongue accessories) for the comms agent to mess with.
	new /obj/item/organ/tongue(src)
	new /obj/item/organ/tongue/lizard(src)
	new /obj/item/organ/tongue/fly(src)
	new /obj/item/organ/tongue/zombie(src)
	new /obj/item/organ/tongue/bone(src)
	new /obj/item/organ/tongue/robot(src) //DANGER! CRYSTAL HYPERSTRUCTURE-
	new /obj/item/organ/tongue/ethereal(src)
	new /obj/item/organ/tongue/tied(src)
	new /obj/item/autosurgeon/organ/syndicate/commsagent(src)
	new	/obj/item/clothing/gloves/radio(src)

/obj/machinery/power/supermatter_crystal/shard/syndicate
	name = "syndicate supermatter shard"
	desc = "Your benefactors conveinently neglected to mention it's already on."
	anchored = TRUE
	radio_key = /obj/item/encryptionkey/syndicate
	engineering_channel = "Syndicate"
	common_channel = "Syndicate"

/obj/machinery/power/supermatter_crystal/shard/syndicate/attackby(obj/item/item, mob/living/user, params)
	if(istype(item, /obj/item/scalpel/supermatter)) //You can already yoink the docs as a free objective win, another would be just gross
		to_chat(user, span_danger("This shard's already in Syndicate custody, taking it again could cause more harm than good."))
		return
	else
	. = ..()
