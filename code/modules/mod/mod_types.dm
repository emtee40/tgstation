/obj/item/mod/control/pre_equipped
	cell = /obj/item/stock_parts/cell/high
	var/applied_skin

/obj/item/mod/control/pre_equipped/Initialize(mapload, new_theme, new_skin)
	new_skin = applied_skin
	return ..()

/obj/item/mod/control/pre_equipped/standard
	initial_modules = list(/obj/item/mod/module/storage, /obj/item/mod/module/welding, /obj/item/mod/module/flashlight)

/obj/item/mod/control/pre_equipped/engineering
	theme = /datum/mod_theme/engineering
	initial_modules = list(/obj/item/mod/module/storage, /obj/item/mod/module/welding, /obj/item/mod/module/rad_protection, /obj/item/mod/module/flashlight, /obj/item/mod/module/magboot)

/obj/item/mod/control/pre_equipped/atmospheric
	theme = /datum/mod_theme/atmospheric
	initial_modules = list(/obj/item/mod/module/storage, /obj/item/mod/module/welding, /obj/item/mod/module/rad_protection, /obj/item/mod/module/flashlight, /obj/item/mod/module/t_ray)

/obj/item/mod/control/pre_equipped/advanced
	theme = /datum/mod_theme/advanced
	cell = /obj/item/stock_parts/cell/super
	initial_modules = list(/obj/item/mod/module/storage/large_capacity, /obj/item/mod/module/welding, /obj/item/mod/module/rad_protection, /obj/item/mod/module/jetpack, /obj/item/mod/module/flashlight)

/obj/item/mod/control/pre_equipped/mining
	theme = /datum/mod_theme/mining
	cell = /obj/item/stock_parts/cell/high/plus
	initial_modules = list(/obj/item/mod/module/storage/large_capacity, /obj/item/mod/module/welding, /obj/item/mod/module/orebag, /obj/item/mod/module/flashlight, /obj/item/mod/module/magboot, /obj/item/mod/module/drill)

/obj/item/mod/control/pre_equipped/medical
	theme = /datum/mod_theme/medical
	initial_modules = list(/obj/item/mod/module/storage, /obj/item/mod/module/flashlight, /obj/item/mod/module/health_analyzer, /obj/item/mod/module/quick_carry)

/obj/item/mod/control/pre_equipped/rescue
	theme = /datum/mod_theme/rescue
	cell = /obj/item/stock_parts/cell/super
	initial_modules = list(/obj/item/mod/module/storage/large_capacity, /obj/item/mod/module/flashlight, /obj/item/mod/module/health_analyzer, /obj/item/mod/module/injector)

/obj/item/mod/control/pre_equipped/research
	theme = /datum/mod_theme/research
	cell = /obj/item/stock_parts/cell/super
	initial_modules = list(/obj/item/mod/module/storage/large_capacity, /obj/item/mod/module/welding, /obj/item/mod/module/flashlight, /obj/item/mod/module/circuit, /obj/item/mod/module/t_ray)

/obj/item/mod/control/pre_equipped/traitor
	theme = /datum/mod_theme/syndicate
	cell = /obj/item/stock_parts/cell/super
	initial_modules = list(/obj/item/mod/module/storage/syndicate, /obj/item/mod/module/welding, /obj/item/mod/module/tether, /obj/item/mod/module/pathfinder, /obj/item/mod/module/flashlight, /obj/item/mod/module/dna_lock)

/obj/item/mod/control/pre_equipped/nuclear
	theme = /datum/mod_theme/syndicate
	cell = /obj/item/stock_parts/cell/hyper
	initial_modules = list(/obj/item/mod/module/storage/syndicate, /obj/item/mod/module/welding, /obj/item/mod/module/jetpack, /obj/item/mod/module/visor/thermal, /obj/item/mod/module/flashlight, /obj/item/mod/module/holster)

/obj/item/mod/control/pre_equipped/elite
	theme = /datum/mod_theme/elite
	cell = /obj/item/stock_parts/cell/bluespace
	initial_modules = list(/obj/item/mod/module/storage/syndicate, /obj/item/mod/module/welding, /obj/item/mod/module/jetpack, /obj/item/mod/module/visor/thermal, /obj/item/mod/module/flashlight, /obj/item/mod/module/holster)

/obj/item/mod/control/pre_equipped/wizard
	theme = /datum/mod_theme/wizard
	cell = /obj/item/stock_parts/cell/crystal_cell/wizard
	initial_modules = list(/obj/item/mod/module/storage/large_capacity, /obj/item/mod/module/energy_shield/wizard)

/obj/item/mod/control/pre_equipped/debug
	theme = /datum/mod_theme/debug
	cell = /obj/item/stock_parts/cell/bluespace
	initial_modules = list(/obj/item/mod/module/storage/bluespace, /obj/item/mod/module/welding, /obj/item/mod/module/flashlight, /obj/item/mod/module/bikehorn, /obj/item/mod/module/rad_protection, /obj/item/mod/module/tether, /obj/item/mod/module/injector) //one of every type of module, for testing if they all work correctly

/obj/item/mod/control/pre_equipped/admin
	theme = /datum/mod_theme/admin
	cell = /obj/item/stock_parts/cell/infinite/abductor
	initial_modules = list(/obj/item/mod/module/storage/bluespace, /obj/item/mod/module/welding, /obj/item/mod/module/stealth/ninja, /obj/item/mod/module/quick_carry/advanced, /obj/item/mod/module/magboot/advanced, /obj/item/mod/module/jetpack)

//these exist for the prefs menu
/obj/item/mod/control/pre_equipped/syndicate_empty
	theme = /datum/mod_theme/syndicate

/obj/item/mod/control/pre_equipped/syndicate_empty/elite
	theme = /datum/mod_theme/elite

INITIALIZE_IMMEDIATE(/obj/item/mod/control/pre_equipped/syndicate_empty)
