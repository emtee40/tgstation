/**********************Mining Equipment Vendor**************************/

/obj/machinery/mineral/equipment_vendor
	name = "mining equipment vendor"
	desc = "An equipment vendor for miners, points collected at an ore redemption machine can be spent here."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/mining_equipment_vendor
	var/icon_deny = "mining-deny"
	var/obj/item/card/id/inserted_id
	var/list/prize_list = list( //if you add something to this, please, for the love of god, sort it by price/type. use tabs and not spaces.
		new /datum/data/mining_equipment("1 Marker Beacon", /obj/item/stack/marker_beacon, 10),
		new /datum/data/mining_equipment("10 Marker Beacons", /obj/item/stack/marker_beacon/ten, 100),
		new /datum/data/mining_equipment("30 Marker Beacons", /obj/item/stack/marker_beacon/thirty, 300),
		new /datum/data/mining_equipment("Skeleton Key", /obj/item/skeleton_key, 777),
		new /datum/data/mining_equipment("Whiskey", /obj/item/reagent_containers/cup/glass/bottle/whiskey, 100),
		new /datum/data/mining_equipment("Absinthe", /obj/item/reagent_containers/cup/glass/bottle/absinthe/premium, 100),
		new /datum/data/mining_equipment("Bubblegum Gum Packet", /obj/item/storage/box/gum/bubblegum, 100),
		new /datum/data/mining_equipment("Cigar", /obj/item/clothing/mask/cigarette/cigar/havana, 150),
		new /datum/data/mining_equipment("Soap", /obj/item/soap/nanotrasen, 200),
		new /datum/data/mining_equipment("Laser Pointer", /obj/item/laser_pointer, 300),
		new /datum/data/mining_equipment("Alien Toy", /obj/item/clothing/mask/facehugger/toy, 300),
		new /datum/data/mining_equipment("Stabilizing Serum", /obj/item/mining_stabilizer, 400),
		new /datum/data/mining_equipment("Fulton Beacon", /obj/item/fulton_core, 400),
		new /datum/data/mining_equipment("Shelter Capsule", /obj/item/survivalcapsule, 400),
		new /datum/data/mining_equipment("GAR Meson Scanners", /obj/item/clothing/glasses/meson/gar, 500),
		new /datum/data/mining_equipment("Explorer's Webbing", /obj/item/storage/belt/mining, 500),
		new /datum/data/mining_equipment("Point Transfer Card", /obj/item/card/mining_point_card, 500),
		new /datum/data/mining_equipment("Survival Medipen", /obj/item/reagent_containers/hypospray/medipen/survival, 500),
		new /datum/data/mining_equipment("Brute Medkit", /obj/item/storage/medkit/brute, 600),
		new /datum/data/mining_equipment("Tracking Implant Kit", /obj/item/storage/box/minertracker, 600),
		new /datum/data/mining_equipment("Jaunter", /obj/item/wormhole_jaunter, 750),
		new /datum/data/mining_equipment("Kinetic Crusher", /obj/item/kinetic_crusher, 750),
		new /datum/data/mining_equipment("Kinetic Accelerator", /obj/item/gun/energy/recharge/kinetic_accelerator, 750),
		new /datum/data/mining_equipment("Advanced Scanner", /obj/item/t_scanner/adv_mining_scanner, 800),
		new /datum/data/mining_equipment("Resonator", /obj/item/resonator, 800),
		new /datum/data/mining_equipment("Luxury Medipen", /obj/item/reagent_containers/hypospray/medipen/survival/luxury, 1000),
		new /datum/data/mining_equipment("Fulton Pack", /obj/item/extraction_pack, 1000),
		new /datum/data/mining_equipment("Lazarus Injector", /obj/item/lazarus_injector, 1000),
		new /datum/data/mining_equipment("Silver Pickaxe", /obj/item/pickaxe/silver, 1000),
		new /datum/data/mining_equipment("Mining Conscription Kit", /obj/item/storage/backpack/duffelbag/mining_conscript, 1500),
		new /datum/data/mining_equipment("Space Cash", /obj/item/stack/spacecash/c1000, 2000),
		new /datum/data/mining_equipment("Diamond Pickaxe", /obj/item/pickaxe/diamond, 2000),
		new /datum/data/mining_equipment("Kheiral Cuffs", /obj/item/kheiral_cuffs, 2000),
		new /datum/data/mining_equipment("Super Resonator", /obj/item/resonator/upgraded, 2500),
		new /datum/data/mining_equipment("Jump Boots", /obj/item/clothing/shoes/bhop, 2500),
		new /datum/data/mining_equipment("Ice Hiking Boots", /obj/item/clothing/shoes/winterboots/ice_boots, 2500),
		new /datum/data/mining_equipment("Mining MODsuit", /obj/item/mod/control/pre_equipped/mining, 3000),
		new /datum/data/mining_equipment("Luxury Shelter Capsule", /obj/item/survivalcapsule/luxury, 3000),
		new /datum/data/mining_equipment("Luxury Bar Capsule", /obj/item/survivalcapsule/luxuryelite, 10000),
		new /datum/data/mining_equipment("Nanotrasen Minebot", /mob/living/simple_animal/hostile/mining_drone, 800),
		new /datum/data/mining_equipment("Minebot Melee Upgrade", /obj/item/mine_bot_upgrade, 400),
		new /datum/data/mining_equipment("Minebot Armor Upgrade", /obj/item/mine_bot_upgrade/health, 400),
		new /datum/data/mining_equipment("Minebot Cooldown Upgrade", /obj/item/borg/upgrade/modkit/cooldown/minebot, 600),
		new /datum/data/mining_equipment("Minebot AI Upgrade", /obj/item/slimepotion/slime/sentience/mining, 1000),
		new /datum/data/mining_equipment("KA Minebot Passthrough", /obj/item/borg/upgrade/modkit/minebot_passthrough, 100),
		new /datum/data/mining_equipment("KA White Tracer Rounds", /obj/item/borg/upgrade/modkit/tracer, 100),
		new /datum/data/mining_equipment("KA Adjustable Tracer Rounds", /obj/item/borg/upgrade/modkit/tracer/adjustable, 150),
		new /datum/data/mining_equipment("KA Super Chassis", /obj/item/borg/upgrade/modkit/chassis_mod, 250),
		new /datum/data/mining_equipment("KA Hyper Chassis", /obj/item/borg/upgrade/modkit/chassis_mod/orange, 300),
		new /datum/data/mining_equipment("KA Range Increase", /obj/item/borg/upgrade/modkit/range, 1000),
		new /datum/data/mining_equipment("KA Damage Increase", /obj/item/borg/upgrade/modkit/damage, 1000),
		new /datum/data/mining_equipment("KA Cooldown Decrease", /obj/item/borg/upgrade/modkit/cooldown, 1000),
		new /datum/data/mining_equipment("KA AoE Damage", /obj/item/borg/upgrade/modkit/aoe/mobs, 2000)
	)

/datum/data/mining_equipment
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0

/datum/data/mining_equipment/New(name, path, cost)
	src.equipment_name = name
	src.equipment_path = path
	src.cost = cost

/obj/machinery/mineral/equipment_vendor/Initialize(mapload)
	. = ..()
	build_inventory()

/obj/machinery/mineral/equipment_vendor/proc/build_inventory()
	for(var/p in prize_list)
		var/datum/data/mining_equipment/M = p
		GLOB.vending_products[M.equipment_path] = 1

/obj/machinery/mineral/equipment_vendor/update_icon_state()
	icon_state = "[initial(icon_state)][powered() ? null : "-off"]"
	return ..()

/obj/machinery/mineral/equipment_vendor/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/vending),
	)

/obj/machinery/mineral/equipment_vendor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MiningVendor", name)
		ui.open()

/obj/machinery/mineral/equipment_vendor/ui_static_data(mob/user)
	. = list()
	.["product_records"] = list()
	for(var/datum/data/mining_equipment/prize in prize_list)
		var/list/product_data = list(
			path = replacetext(replacetext("[prize.equipment_path]", "/obj/item/", ""), "/", "-"),
			name = prize.equipment_name,
			price = prize.cost,
			ref = REF(prize)
		)
		.["product_records"] += list(product_data)

/obj/machinery/mineral/equipment_vendor/ui_data(mob/user)
	. = list()
	var/obj/item/card/id/C
	if(isliving(user))
		var/mob/living/L = user
		C = L.get_idcard(TRUE)
	if(C)
		.["user"] = list()
		.["user"]["points"] = C.mining_points
		if(C.registered_account)
			.["user"]["name"] = C.registered_account.account_holder
			if(C.registered_account.account_job)
				.["user"]["job"] = C.registered_account.account_job.title
			else
				.["user"]["job"] = "No Job"

/obj/machinery/mineral/equipment_vendor/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("purchase")
			var/obj/item/card/id/I
			if(isliving(usr))
				var/mob/living/L = usr
				I = L.get_idcard(TRUE)
			if(!istype(I))
				to_chat(usr, span_alert("Error: An ID is required!"))
				flick(icon_deny, src)
				return
			var/datum/data/mining_equipment/prize = locate(params["ref"]) in prize_list
			if(!prize || !(prize in prize_list))
				to_chat(usr, span_alert("Error: Invalid choice!"))
				flick(icon_deny, src)
				return
			if(prize.cost > I.mining_points)
				to_chat(usr, span_alert("Error: Insufficient points for [prize.equipment_name] on [I]!"))
				flick(icon_deny, src)
				return
			I.mining_points -= prize.cost
			to_chat(usr, span_notice("[src] clanks to life briefly before vending [prize.equipment_name]!"))
			new prize.equipment_path(loc)
			SSblackbox.record_feedback("nested tally", "mining_equipment_bought", 1, list("[type]", "[prize.equipment_path]"))
			. = TRUE

/obj/machinery/mineral/equipment_vendor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mining_voucher))
		redeem_voucher(I, user)
		return
	if(default_deconstruction_screwdriver(user, "mining-open", "mining", I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/**
 * Allows user to redeem a mining voucher for one set of a mining equipment
 *
 * * Arguments:
 * * voucher The mining voucher that is being used to redeem the mining equipment
 * * redeemer The mob that is redeeming the mining equipment
 */
/obj/machinery/mineral/equipment_vendor/proc/redeem_voucher(obj/item/mining_voucher/voucher, mob/redeemer)
	var/static/list/set_types
	if(!set_types)
		set_types = list()
		for(var/datum/voucher_set/static_set as anything in subtypesof(/datum/voucher_set))
			set_types[initial(static_set.name)] = new static_set

	var/list/items = list()
	for(var/set_name in set_types)
		var/datum/voucher_set/current_set = set_types[set_name]
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = current_set.icon, icon_state = current_set.icon_state)
		option.info = span_boldnotice(current_set.description)
		items[set_name] = option

	var/selection = show_radial_menu(redeemer, src, items, custom_check = CALLBACK(src, .proc/check_menu, voucher, redeemer), radius = 38, require_near = TRUE, tooltips = TRUE)
	if(!selection)
		return

	var/datum/voucher_set/chosen_set = set_types[selection]
	for(var/item in chosen_set.set_items)
		new item(drop_location())

	SSblackbox.record_feedback("tally", "mining_voucher_redeemed", 1, selection)
	qdel(voucher)

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * * Arguments:
 * * voucher The mining voucher that is being used to redeem a mining equipment
 * * redeemer The living mob interacting with the menu
 */
/obj/machinery/mineral/equipment_vendor/proc/check_menu(obj/item/mining_voucher/voucher, mob/living/redeemer)
	if(!istype(redeemer))
		return FALSE
	if(redeemer.incapacitated())
		return FALSE
	if(QDELETED(voucher))
		return FALSE
	if(!redeemer.is_holding(voucher))
		return FALSE
	return TRUE

/obj/machinery/mineral/equipment_vendor/ex_act(severity, target)
	do_sparks(5, TRUE, src)
	if(severity > EXPLODE_LIGHT && prob(17 * severity))
		qdel(src)

/****************Golem Point Vendor**************************/

/obj/machinery/mineral/equipment_vendor/golem
	name = "golem ship equipment vendor"
	circuit = /obj/item/circuitboard/machine/mining_equipment_vendor/golem

/obj/machinery/mineral/equipment_vendor/golem/Initialize(mapload)
	desc += "\nIt seems a few selections have been added."
	prize_list += list(
		new /datum/data/mining_equipment("Extra Id", /obj/item/card/id/advanced/mining, 250),
		new /datum/data/mining_equipment("Science Goggles", /obj/item/clothing/glasses/science, 250),
		new /datum/data/mining_equipment("Monkey Cube", /obj/item/food/monkeycube, 300),
		new /datum/data/mining_equipment("Toolbelt", /obj/item/storage/belt/utility, 350),
		new /datum/data/mining_equipment("Royal Cape of the Liberator", /obj/item/bedsheet/rd/royal_cape, 500),
		new /datum/data/mining_equipment("Grey Slime Extract", /obj/item/slime_extract/grey, 1000),
		new /datum/data/mining_equipment("Modification Kit", /obj/item/borg/upgrade/modkit/trigger_guard, 1700),
		new /datum/data/mining_equipment("The Liberator's Legacy", /obj/item/storage/box/rndboards, 2000)
		)
	return ..()

/**********************Mining Equipment Vendor Items**************************/

/**********************Mining Equipment Voucher**********************/

/obj/item/mining_voucher
	name = "mining voucher"
	desc = "A token to redeem a piece of equipment. Use it on a mining equipment vendor."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_voucher"
	w_class = WEIGHT_CLASS_TINY

/**********************Mining Point Card**********************/
#define TO_USER_ID "To ID"
#define TO_POINT_CARD "To Card"
/obj/item/card/mining_point_card
	name = "mining point transfer card"
	desc = "A small, reusable card for transferring mining points. Swipe your ID card over it to start the process."
	icon_state = "data_1"
	var/points = 500

/obj/item/card/mining_point_card/attackby(obj/item/I, mob/user, params)
	if(isidcard(I))
		var/obj/item/card/id/swiped = I
		balloon_alert(user, "starting transfer")
		var/point_movement = tgui_alert(user, "To ID (from card) or to card (from ID)?", "Mining Points Transfer", list(TO_USER_ID, TO_POINT_CARD))
		if(!point_movement)
			return
		var/amount = tgui_input_number(user, "How much do you want to transfer? ID Balance: [swiped.mining_points], Card Balance: [points]", "Transfer Points", min_value = 0, round_value = 1)
		if(!amount)
			return
		switch(point_movement)
			if(TO_USER_ID)
				if(amount > points)
					amount = points
				swiped.mining_points += amount
				points -= amount
				to_chat(user, span_notice("You transfer [amount] mining points from [src] to [swiped]."))
			if(TO_POINT_CARD)
				if(amount > swiped.mining_points)
					amount = swiped.mining_points
				swiped.mining_points -= amount
				points += amount
				to_chat(user, span_notice("You transfer [amount] mining points from [swiped] to [src]."))
	..()

/obj/item/card/mining_point_card/examine(mob/user)
	. = ..()
	. += span_notice("There's [points] point\s on the card.")

#undef TO_POINT_CARD
#undef TO_USER_ID
/obj/item/storage/backpack/duffelbag/mining_conscript
	name = "mining conscription kit"
	desc = "A kit containing everything a crewmember needs to support a shaft miner in the field."
	icon_state = "duffel-explorer"
	inhand_icon_state = "duffel-explorer"

/obj/item/storage/backpack/duffelbag/mining_conscript/PopulateContents()
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/clothing/suit/hooded/explorer(src)
	new /obj/item/encryptionkey/headset_mining(src)
	new /obj/item/clothing/mask/gas/explorer(src)
	new /obj/item/card/id/advanced/mining(src)
	new /obj/item/gun/energy/recharge/kinetic_accelerator(src)
	new /obj/item/knife/combat/survival(src)
	new /obj/item/flashlight/seclite(src)
