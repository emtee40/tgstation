/datum/job/shaft_miner
	title = "Shaft Miner"
	department_head = list("Head of Personnel")
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dcba97"

	outfit = /datum/outfit/job/miner
	plasmaman_outfit = /datum/outfit/plasmaman/mining

	bounty_types = CIV_JOB_MINE
	departments = DEPARTMENT_CARGO
	display_order = JOB_DISPLAY_ORDER_SHAFT_MINER
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

	family_heirlooms = list(
		/obj/item/pickaxe/mini,
		/obj/item/shovel,
	)

/datum/outfit/job/miner
	name = "Shaft Miner"
	jobtype = /datum/job/shaft_miner

	id_trim = /datum/id_trim/job/shaft_miner
	uniform = /obj/item/clothing/under/rank/cargo/miner/lavaland
	backpack_contents = list(
		/obj/item/flashlight/seclite = 1,
		/obj/item/kitchen/knife/combat/survival = 1,
		/obj/item/mining_voucher = 1,
		/obj/item/stack/marker_beacon/ten = 1,
		)
	belt = /obj/item/pda/shaftminer
	ears = /obj/item/radio/headset/headset_cargo/mining
	shoes = /obj/item/clothing/shoes/workboots/mining
	gloves = /obj/item/clothing/gloves/color/black
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival
	r_pocket = /obj/item/storage/bag/ore //causes issues if spawned in backpack

	backpack = /obj/item/storage/backpack/explorer
	satchel = /obj/item/storage/backpack/satchel/explorer
	duffelbag = /obj/item/storage/backpack/duffelbag/explorer

	box = /obj/item/storage/box/survival/mining
	chameleon_extras = /obj/item/gun/energy/kinetic_accelerator


/datum/outfit/job/miner/equipped
	name = "Shaft Miner (Equipment)"

	suit = /obj/item/clothing/suit/hooded/explorer
	suit_store = /obj/item/tank/internals/oxygen
	backpack_contents = list(
		/obj/item/flashlight/seclite = 1,
		/obj/item/gun/energy/kinetic_accelerator = 1,
		/obj/item/kitchen/knife/combat/survival = 1,
		/obj/item/mining_voucher = 1,
		/obj/item/stack/marker_beacon/ten = 1,
		/obj/item/t_scanner/adv_mining_scanner/lesser = 1,
		)
	glasses = /obj/item/clothing/glasses/meson
	mask = /obj/item/clothing/mask/gas/explorer
	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/job/miner/equipped/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	if(istype(H.wear_suit, /obj/item/clothing/suit/hooded))
		var/obj/item/clothing/suit/hooded/S = H.wear_suit
		S.ToggleHood()

/datum/outfit/job/miner/equipped/hardsuit
	name = "Shaft Miner (Equipment + Hardsuit)"

	suit = /obj/item/clothing/suit/space/hardsuit/mining
	mask = /obj/item/clothing/mask/breath
