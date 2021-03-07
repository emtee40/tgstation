/datum/game_mode/nuclear/clown_ops
	name = "clown ops"
	config_tag = "clownops"

	announce_span = "danger"
	announce_text = "Clown empire forces are approaching the station in an attempt to HONK it!\n\
	<span class='danger'>Operatives</span>: Secure the nuclear authentication disk and use your bananium fission explosive to HONK the station.\n\
	<span class='notice'>Crew</span>: Defend the nuclear authentication disk and ensure that it leaves with you on the emergency shuttle."

	operative_antag_datum_type = /datum/antagonist/nukeop/clownop
	leader_antag_datum_type = /datum/antagonist/nukeop/leader/clownop

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/nuclear/clown_ops/pre_setup()
	. = ..()
	if(.)
		for(var/obj/machinery/nuclearbomb/syndicate/S in GLOB.nuke_list)
			var/turf/T = get_turf(S)
			if(T)
				qdel(S)
				new /obj/machinery/nuclearbomb/syndicate/bananium(T)
		for(var/V in pre_nukeops)
			var/datum/mind/the_op = V
			the_op.assigned_role = "Clown Operative"
			the_op.special_role = "Clown Operative"

/datum/outfit/syndicate/clownop
	name = "Clown Operative - Basic"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/clown_shoes/combat
	mask = /obj/item/clothing/mask/gas/clown_hat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/clown
	ears = /obj/item/radio/headset/syndicate/alt
	l_pocket = /obj/item/pinpointer/nuke/syndicate
	r_pocket = /obj/item/bikehorn
	id = /obj/item/card/id/advanced/chameleon
	backpack_contents = list(/obj/item/storage/box/survival/syndie=1,\
		/obj/item/kitchen/knife/combat/survival,
		/obj/item/dnainjector/clumsymut, //in case you want to be clumsy for the memes
		/obj/item/storage/box/syndie_kit/clownpins, //for any guns that you get your grubby little clown op mitts on
		/obj/item/reagent_containers/spray/waterflower/lube)
	implants = list(/obj/item/implant/sad_trombone)

	uplink_type = /obj/item/uplink/clownop

	id_trim = /datum/id_trim/chameleon/operative/clown

/datum/outfit/syndicate/clownop/no_crystals
	tc = 0

/datum/outfit/syndicate/clownop/leader
	name = "Clown Operative Leader - Basic"
	gloves = /obj/item/clothing/gloves/krav_maga/combatglovesplus
	command_radio = TRUE

	id_trim = /datum/id_trim/chameleon/operative/clown_leader
