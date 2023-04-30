/datum/job/coroner
	title = JOB_CORONER
	description = "Perform Autopsies whenever needed, \
		Update medical records accordingly, apply formaldehyde."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_CMO
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CORONER"

	outfit = /datum/outfit/job/coroner
	plasmaman_outfit = /datum/outfit/plasmaman/medical

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_MED

	display_order = JOB_DISPLAY_ORDER_CORONER
	departments_list = list(
		/datum/job_department/medical,
		)

	mail_goodies = list(
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 30,
		/obj/item/healthanalyzer = 10,
	)

	family_heirlooms = list(/obj/item/pen/fountain, /obj/item/storage/dice)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

	rpg_title = "Plague Doctor"

/datum/outfit/job/coroner
	name = "Coroner"
	jobtype = /datum/job/coroner

	id_trim = /datum/id_trim/job/coroner
	uniform = /obj/item/clothing/under/rank/medical/scrubs/coroner
	suit = /obj/item/clothing/suit/toggle/labcoat
	suit_store = /obj/item/flashlight/pen
	belt = /obj/item/modular_computer/pda/medical
	mask = /obj/item/clothing/mask/surgical
	gloves = /obj/item/clothing/gloves/latex
	ears = /obj/item/radio/headset/headset_med
	shoes = /obj/item/clothing/shoes/sneakers/white
	l_pocket = /obj/item/toy/crayon/white

	box = /obj/item/storage/box/survival/medical
	backpack_contents = list(
		/obj/item/autopsy_scanner = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/storage/box/bodybags = 1,
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 1,
		/obj/item/reagent_containers/dropper = 1,
	)
	skillchips = list(/obj/item/skillchip/entrails_reader)
