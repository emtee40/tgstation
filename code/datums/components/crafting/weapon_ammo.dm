/datum/crafting_recipe/meteorslug
	name = "Meteorslug Shell"
	result = /obj/item/ammo_casing/shotgun/meteorslug
	reqs = list(
		/obj/item/ammo_casing/shotgun/techshell = 1,
		/obj/item/rcd_ammo = 1,
		/datum/reagent/gunpowder = 10,
		/datum/reagent/consumable/ethanol/rum = 10,
		/obj/item/stock_parts/servo = 2,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/rebarsyndie
	name = "jagged iron rod"
	result = /obj/item/ammo_casing/rebar/syndie
	reqs = list(
		/obj/item/stack/rods = 1,
	)
	tool_behaviors = list(TOOL_WIRECUTTER)
	time = 0.5 SECONDS
	always_available = FALSE
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/pulseslug
	name = "Pulse Slug Shell"
	result = /obj/item/ammo_casing/shotgun/pulseslug
	reqs = list(
		/obj/item/ammo_casing/shotgun/techshell = 1,
		/obj/item/stock_parts/capacitor/adv = 2,
		/obj/item/stock_parts/micro_laser/ultra = 1,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/dragonsbreath
	name = "Dragonsbreath Shell"
	result = /obj/item/ammo_casing/shotgun/dragonsbreath
	reqs = list(
		/obj/item/ammo_casing/shotgun/techshell = 1,
		/datum/reagent/phosphorus = 5,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/frag12
	name = "FRAG-12 Slug Shell"
	result = /obj/item/ammo_casing/shotgun/frag12
	reqs = list(
		/obj/item/ammo_casing/shotgun/techshell = 1,
		/datum/reagent/glycerol = 5,
		/datum/reagent/toxin/acid/fluacid = 10,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/ionslug
	name = "Ion Scatter Shell"
	result = /obj/item/ammo_casing/shotgun/ion
	reqs = list(
		/obj/item/ammo_casing/shotgun/techshell = 1,
		/obj/item/stock_parts/micro_laser/ultra = 1,
		/obj/item/stock_parts/subspace/crystal = 1,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/improvisedslug
	name = "Improvised Shotgun Shell"
	result = /obj/item/ammo_casing/shotgun/improvised
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/shard = 1,
		/datum/reagent/fuel = 10,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 1.2 SECONDS
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/trashball
	name = "Trashball"
	always_available = FALSE
	result = /obj/item/stack/cannonball/trashball
	reqs = list(
		/obj/item/stack/sheet = 5,
		/datum/reagent/consumable/space_cola = 10,
	)
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/cannonball
	name = "Cannonball"
	result = /obj/item/ammo_casing/caseless/cannonball
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/iron = 10)
	category = CAT_WEAPON_AMMO
	always_available = FALSE
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER)

/datum/crafting_recipe/cannonball/emp
	name = "EMP Cannonball"
	result = /obj/item/ammo_casing/caseless/cannonball/emp
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/iron = 10,
				/obj/item/stack/cable_coil = 10,
				/datum/reagent/iron = 20,
				/datum/reagent/uranium = 20)
	category = CAT_WEAPON_AMMO
	always_available = FALSE
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER)

/datum/crafting_recipe/cannonball/explosive
	name = "Explosive Cannonball"
	result = /obj/item/ammo_casing/caseless/cannonball/explosive
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/iron = 10,
				/datum/reagent/gunpowder = 50)
	category = CAT_WEAPON_AMMO
	always_available = FALSE
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER)
