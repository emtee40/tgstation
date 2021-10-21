/*
	Station Airlocks Regular
*/

/obj/machinery/door/airlock/command
	icon = 'icons/obj/doors/airlocks/station/command.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_com
	normal_integrity = 450
	greyscale_colors = "#3e7bc1#3e7bc1#2a5b94#2a5b94#369de5#6d6565#2c5280"

/obj/machinery/door/airlock/security
	icon = 'icons/obj/doors/airlocks/station/security.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_sec
	normal_integrity = 450
	greyscale_colors = "#9f2828#9f2828#a51c1c#a51c1c#d27428#6d6565#8e2222"

/obj/machinery/door/airlock/engineering
	icon = 'icons/obj/doors/airlocks/station/engineering.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_eng
	greyscale_colors = "#d8a81b#d8a81b#c2940d#c2940d#7f292f#6d6565#997715"

/obj/machinery/door/airlock/medical
	icon = 'icons/obj/doors/airlocks/station/medical.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_med
	greyscale_colors = "#ffffff#ffffff#ffffff#ffffff#66ccff#6d6565#ffffff"

/obj/machinery/door/airlock/hydroponics	//Hydroponics front doors!
	icon = 'icons/obj/doors/airlocks/station/medical.dmi'	 //Uses same icon as /medical, maybe update it with its own unique icon one day?
	assemblytype = /obj/structure/door_assembly/door_assembly_hydro

/obj/machinery/door/airlock/maintenance
	name = "maintenance access"
	icon = 'icons/obj/doors/airlocks/tall/maintenance.dmi'
	overlays_file = 'icons/obj/doors/airlocks/tall/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_mai
	normal_integrity = 250
	greyscale_config = null
	greyscale_colors = null

/obj/machinery/door/airlock/maintenance/external
	name = "external airlock access"
	icon = 'icons/obj/doors/airlocks/station/maintenanceexternal.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_extmai
	greyscale_config = /datum/greyscale_config/airlocks
	greyscale_colors = "#4d4d4d#4d4d4d#5f5f5f#5f5f5f#998d67#998d67#333333"

/obj/machinery/door/airlock/mining
	name = "mining airlock"
	icon = 'icons/obj/doors/airlocks/station/mining.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_min
	greyscale_colors = "#c39344#c39344#b3863c#b3863c#78430d#6d6565#967032"

/obj/machinery/door/airlock/atmos
	name = "atmospherics airlock"
	icon = 'icons/obj/doors/airlocks/tall/department/atmos.dmi'
	overlays_file = 'icons/obj/doors/airlocks/tall/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_atmo
	greyscale_config = null
	greyscale_colors = null

/obj/machinery/door/airlock/research
	icon = 'icons/obj/doors/airlocks/station/research.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_research
	greyscale_colors = "#ffffff#ffffff#ffffff#ffffff#974cdc#6d6565#ffffff"

/obj/machinery/door/airlock/freezer
	name = "freezer airlock"
	icon = 'icons/obj/doors/airlocks/station/freezer.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_fre
	greyscale_colors = "#ffffff#ffffff#eaeaea#eaeaea#808080#6d6565#ffffff"

/obj/machinery/door/airlock/science
	icon = 'icons/obj/doors/airlocks/station/science.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_science
	greyscale_colors = "#ffffff#ffffff#ffffff#ffffff#9966ff#6d6565#ffffff"

/obj/machinery/door/airlock/virology
	icon = 'icons/obj/doors/airlocks/station/virology.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_viro
	greyscale_colors = "#ffffff#ffffff#ffffff#ffffff#006600#6d6565#ffffff"

//////////////////////////////////
/*
	Station Airlocks Glass
*/

/obj/machinery/door/airlock/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/glass/incinerator
	autoclose = FALSE
	frequency = FREQ_AIRLOCK_CONTROL
	heat_proof = TRUE
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/door/airlock/glass/incinerator/syndicatelava_interior
	name = "Turbine Interior Airlock"
	id_tag = INCINERATOR_SYNDICATELAVA_AIRLOCK_INTERIOR

/obj/machinery/door/airlock/glass/incinerator/syndicatelava_exterior
	name = "Turbine Exterior Airlock"
	id_tag = INCINERATOR_SYNDICATELAVA_AIRLOCK_EXTERIOR

/obj/machinery/door/airlock/command/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 400

/obj/machinery/door/airlock/engineering/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/engineering/glass/critical
	critical_machine = TRUE //stops greytide virus from opening & bolting doors in critical positions, such as the SM chamber.

/obj/machinery/door/airlock/security/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 400

/obj/machinery/door/airlock/medical/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/hydroponics/glass //Uses same icon as medical/glass, maybe update it with its own unique icon one day?
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/research/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/research/glass/incinerator
	autoclose = FALSE
	frequency = FREQ_AIRLOCK_CONTROL
	heat_proof = TRUE
	req_access = list(ACCESS_ORDNANCE)

/obj/machinery/door/airlock/research/glass/incinerator/ordmix_interior
	name = "Mixing Room Interior Airlock"
	id_tag = INCINERATOR_ORDMIX_AIRLOCK_INTERIOR

/obj/machinery/door/airlock/research/glass/incinerator/ordmix_exterior
	name = "Mixing Room Exterior Airlock"
	id_tag = INCINERATOR_ORDMIX_AIRLOCK_EXTERIOR

/obj/machinery/door/airlock/mining/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/atmos/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/atmos/glass/critical
	critical_machine = TRUE //stops greytide virus from opening & bolting doors in critical positions, such as the SM chamber.

/obj/machinery/door/airlock/science/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/virology/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/maintenance/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/maintenance/external/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 200

//////////////////////////////////
/*
	Station Airlocks Mineral
*/

/obj/machinery/door/airlock/gold
	name = "gold airlock"
	icon = 'icons/obj/doors/airlocks/tall/mineral/gold.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_gold
	greyscale_config = null
	greyscale_colors = null

/obj/machinery/door/airlock/gold/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/silver
	name = "silver airlock"
	icon = 'icons/obj/doors/airlocks/tall/mineral/silver.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_silver
	greyscale_config = null
	greyscale_colors = null

/obj/machinery/door/airlock/silver/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/diamond
	name = "diamond airlock"
	icon = 'icons/obj/doors/airlocks/station/diamond.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_diamond
	normal_integrity = 1000
	explosion_block = 2
	greyscale_config = null
	greyscale_colors = null

/obj/machinery/door/airlock/diamond/glass
	normal_integrity = 950
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/uranium
	name = "uranium airlock"
	icon = 'icons/obj/doors/airlocks/station/uranium.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_uranium
	var/last_event = 0
	greyscale_colors = rgb(0,51,0)+rgb(0,51,0)+rgb(0,68,0)+rgb(0,68,0)+rgb(0,51,0)+rgb(109,101,101)+rgb(0,51,0)

/obj/machinery/door/airlock/uranium/process()
	if(world.time > last_event+20)
		if(prob(50))
			radiate()
		last_event = world.time
	..()

/obj/machinery/door/airlock/uranium/proc/radiate()
	radiation_pulse(get_turf(src), 150)
	return

/obj/machinery/door/airlock/uranium/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/plasma
	name = "plasma airlock"
	desc = "No way this can end badly."
	icon = 'icons/obj/doors/airlocks/station/plasma.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_plasma
	greyscale_colors = "#890e89#890e89#660066#660066#660066#6d6565#5d035d"

/obj/machinery/door/airlock/plasma/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive, mapload)

/obj/machinery/door/airlock/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (exposed_temperature > 300)

/obj/machinery/door/airlock/plasma/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	PlasmaBurn()

/obj/machinery/door/airlock/plasma/proc/PlasmaBurn()
	atmos_spawn_air("plasma=500;TEMP=1000")
	var/obj/structure/door_assembly/DA
	DA = new /obj/structure/door_assembly(loc)
	if(glass)
		DA.glass = TRUE
	if(heat_proof)
		DA.heat_proof_finished = TRUE
	DA.update_appearance()
	DA.update_name()
	qdel(src)

/obj/machinery/door/airlock/plasma/block_superconductivity() //we don't stop the heat~
	return 0

/obj/machinery/door/airlock/plasma/attackby(obj/item/C, mob/user, params)
	if(C.get_temperature() > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma airlock ignited by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(src)]")
		log_game("Plasma airlock ignited by [key_name(user)] in [AREACOORD(src)]")
		ignite(C.get_temperature())
	else
		return ..()

/obj/machinery/door/airlock/plasma/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/bananium
	name = "bananium airlock"
	desc = "Honkhonkhonk"
	icon = 'icons/obj/doors/airlocks/station/bananium.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_bananium
	doorOpen = 'sound/items/bikehorn.ogg'
	greyscale_colors = "#ffff00#ffff00#ffff00#ffff00#ffff00#ffff00#ffff00"

/obj/machinery/door/airlock/bananium/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/sandstone
	name = "sandstone airlock"
	icon = 'icons/obj/doors/airlocks/station/sandstone.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_sandstone
	greyscale_colors = "#876f57#876f57#877869#877869#978471#6d6565#876f57"

/obj/machinery/door/airlock/sandstone/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/wood
	name = "wooden airlock"
	icon = 'icons/obj/doors/airlocks/tall/wood.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_wood
	greyscale_config = null
	greyscale_colors = null

/obj/machinery/door/airlock/wood/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/titanium
	name = "shuttle airlock"
	assemblytype = /obj/structure/door_assembly/door_assembly_titanium
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	normal_integrity = 400
	greyscale_config = null
	greyscale_colors = null

/obj/machinery/door/airlock/titanium/glass
	normal_integrity = 350
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/bronze
	name = "bronze airlock"
	icon = 'icons/obj/doors/airlocks/clockwork/pinion_airlock.dmi'
	overlays_file = 'icons/obj/doors/airlocks/clockwork/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_bronze
	greyscale_config = null
	greyscale_colors = null

/obj/machinery/door/airlock/bronze/seethru
	assemblytype = /obj/structure/door_assembly/door_assembly_bronze/seethru
	opacity = FALSE
	glass = TRUE
//////////////////////////////////
/*
	Station2 Airlocks
*/

/obj/machinery/door/airlock/public
	icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
	overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_public
	greyscale_config = null
	greyscale_colors = null

/obj/machinery/door/airlock/public/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/public/glass/incinerator
	autoclose = FALSE
	frequency = FREQ_AIRLOCK_CONTROL
	heat_proof = TRUE
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS)

/obj/machinery/door/airlock/public/glass/incinerator/atmos_interior
	name = "Turbine Interior Airlock"
	id_tag = INCINERATOR_ATMOS_AIRLOCK_INTERIOR

/obj/machinery/door/airlock/public/glass/incinerator/atmos_exterior
	name = "Turbine Exterior Airlock"
	id_tag = INCINERATOR_ATMOS_AIRLOCK_EXTERIOR

//////////////////////////////////
/*
	External Airlocks
*/

/obj/machinery/door/airlock/external
	name = "external airlock"
	icon = 'icons/obj/doors/airlocks/external/external.dmi'
	overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_ext
	greyscale_config = null
	greyscale_colors = null
	req_access = list(ACCESS_EXTERNAL_AIRLOCKS)

	/// Whether or not the airlock can be opened without access from a certain direction while powered, or with bare hands from any direction while unpowered OR pressurized.
	var/space_dir = null

/obj/machinery/door/airlock/external/Initialize(mapload, ...)
	// default setting is for mapping only, let overrides work
	if(!mapload || req_access_txt || req_one_access_txt)
		req_access = null

	return ..()

/obj/machinery/door/airlock/external/LateInitialize()
	. = ..()
	if(space_dir)
		unres_sides |= space_dir

/obj/machinery/door/airlock/external/examine(mob/user)
	. = ..()
	if(space_dir)
		. += span_notice("It has labels indicating that it has an emergency mechanism to open from the [dir2text(space_dir)] side with <b>just your hands</b> even if there's no power.")

/obj/machinery/door/airlock/external/cyclelinkairlock()
	. = ..()
	var/obj/machinery/door/airlock/external/cycle_linked_external_airlock = cyclelinkedairlock
	if(istype(cycle_linked_external_airlock))
		cycle_linked_external_airlock.space_dir |= space_dir
		space_dir |= cycle_linked_external_airlock.space_dir

/obj/machinery/door/airlock/external/try_safety_unlock(mob/user)
	if(space_dir && density)
		if(!hasPower())
			to_chat(user, span_notice("You begin unlocking the airlock safety mechanism..."))
			if(do_after(user, 15 SECONDS, target = src))
				try_to_crowbar(null, user, TRUE)
				return TRUE
		else
			// always open from the space side
			// get_dir(src, user) & space_dir, checked in unresricted_sides
			var/should_safety_open = shuttledocked || cyclelinkedairlock?.shuttledocked || is_safe_turf(get_step(src, space_dir), TRUE, FALSE)
			return try_to_activate_door(user, should_safety_open)

	return ..()

/// Access free external airlock
/obj/machinery/door/airlock/external/ruin
	req_access = null

/obj/machinery/door/airlock/external/glass
	opacity = FALSE
	glass = TRUE

/// Access free external glass airlock
/obj/machinery/door/airlock/external/glass/ruin
	req_access = null

//////////////////////////////////
/*
	CentCom Airlocks
*/

/obj/machinery/door/airlock/centcom //Use grunge as a station side version, as these have special effects related to them via phobias and such.
	icon = 'icons/obj/doors/airlocks/tall/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/tall/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_centcom
	normal_integrity = 1000
	security_level = 6
	explosion_block = 2
	greyscale_config = null
	greyscale_colors = null

/obj/machinery/door/airlock/grunge
	icon = 'icons/obj/doors/airlocks/tall/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/tall/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_grunge

//////////////////////////////////
/*
	Vault Airlocks
*/

/obj/machinery/door/airlock/vault
	name = "vault door"
	icon = 'icons/obj/doors/airlocks/vault/vault.dmi'
	overlays_file = 'icons/obj/doors/airlocks/vault/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_vault
	explosion_block = 2
	normal_integrity = 400 // reverse engieneerd: 400 * 1.5 (sec lvl 6) = 600 = original
	security_level = 6
	greyscale_config = null
	greyscale_colors = null

//////////////////////////////////
/*
	Hatch Airlocks
*/

/obj/machinery/door/airlock/hatch
	name = "airtight hatch"
	icon = 'icons/obj/doors/airlocks/hatch/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_hatch
	greyscale_config = null
	greyscale_colors = null

/obj/machinery/door/airlock/maintenance_hatch //Please dear fucking LORD make this a subtype of the above, they're the SAME GOD DAMN THING
	name = "maintenance hatch"
	icon = 'icons/obj/doors/airlocks/hatch/maintenance.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_mhatch
	greyscale_config = null
	greyscale_colors = null

//////////////////////////////////
/*
	High Security Airlocks
*/

/obj/machinery/door/airlock/highsecurity
	name = "high tech security airlock"
	icon = 'icons/obj/doors/airlocks/tall/secure/highsec.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_highsecurity
	explosion_block = 2
	normal_integrity = 500
	security_level = 1
	damage_deflection = 30
	greyscale_config = null
	greyscale_colors = null

//////////////////////////////////
/*
	Shuttle Airlocks
*/

/obj/machinery/door/airlock/shuttle
	name = "shuttle airlock"
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_shuttle
	greyscale_config = null
	greyscale_colors = null

/obj/machinery/door/airlock/shuttle/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/abductor
	name = "alien airlock"
	desc = "With humanity's current technological level, it could take years to hack this advanced airlock... or maybe we should give a screwdriver a try?"
	icon = 'icons/obj/doors/airlocks/abductor/abductor_airlock.dmi'
	overlays_file = 'icons/obj/doors/airlocks/abductor/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_abductor
	note_overlay_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	damage_deflection = 30
	explosion_block = 3
	hackProof = TRUE
	aiControlDisabled = AI_WIRE_DISABLED
	normal_integrity = 700
	security_level = 1
	greyscale_config = null
	greyscale_colors = null

//////////////////////////////////
/*
	Cult Airlocks
*/

/obj/machinery/door/airlock/cult
	name = "cult airlock"
	icon = 'icons/obj/doors/airlocks/tall/cult/cult_runed.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_cult
	hackProof = TRUE
	aiControlDisabled = AI_WIRE_DISABLED
	req_access = list(ACCESS_BLOODCULT)
	damage_deflection = 10
	greyscale_config = null
	greyscale_colors = null
	var/openingoverlaytype = /obj/effect/temp_visual/cult/door
	var/friendly = FALSE
	var/stealthy = FALSE

/obj/machinery/door/airlock/cult/Initialize(mapload)
	. = ..()
	new openingoverlaytype(loc)

/obj/machinery/door/airlock/cult/canAIControl(mob/user)
	return (IS_CULTIST(user) && !isAllPowerCut())

/obj/machinery/door/airlock/cult/on_break()
	if(!panel_open)
		panel_open = TRUE

/obj/machinery/door/airlock/cult/isElectrified()
	return FALSE

/obj/machinery/door/airlock/cult/hasPower()
	return TRUE

/obj/machinery/door/airlock/cult/allowed(mob/living/L)
	if(!density)
		return TRUE
	if(friendly || IS_CULTIST(L) || istype(L, /mob/living/simple_animal/shade) || isconstruct(L))
		if(!stealthy)
			new openingoverlaytype(loc)
		return TRUE
	else
		if(!stealthy)
			new /obj/effect/temp_visual/cult/sac(loc)
			var/atom/throwtarget
			throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(L, src)))
			SEND_SOUND(L, sound(pick('sound/hallucinations/turn_around1.ogg','sound/hallucinations/turn_around2.ogg'),0,1,50))
			flash_color(L, flash_color="#960000", flash_time=20)
			L.Paralyze(40)
			L.throw_at(throwtarget, 5, 1,src)
		return FALSE

/obj/machinery/door/airlock/cult/proc/conceal()
	icon = 'icons/obj/doors/airlocks/tall/maintenance.dmi'
	overlays_file = 'icons/obj/doors/airlocks/tall/overlays.dmi'
	name = "airlock"
	desc = "It opens and closes."
	stealthy = TRUE
	update_appearance()

/obj/machinery/door/airlock/cult/proc/reveal()
	icon = initial(icon)
	overlays_file = initial(overlays_file)
	name = initial(name)
	desc = initial(desc)
	stealthy = initial(stealthy)
	update_appearance()

/obj/machinery/door/airlock/cult/narsie_act()
	return

/obj/machinery/door/airlock/cult/emp_act(severity)
	return

/obj/machinery/door/airlock/cult/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/glass
	glass = TRUE
	opacity = FALSE

/obj/machinery/door/airlock/cult/glass/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/unruned
	icon = 'icons/obj/doors/airlocks/tall/cult/cult.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_cult/unruned
	openingoverlaytype = /obj/effect/temp_visual/cult/door/unruned

/obj/machinery/door/airlock/cult/unruned/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/unruned/glass
	glass = TRUE
	opacity = FALSE

/obj/machinery/door/airlock/cult/unruned/glass/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/weak
	name = "brittle cult airlock"
	desc = "An airlock hastily corrupted by blood magic, it is unusually brittle in this state."
	normal_integrity = 150
	damage_deflection = 5
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)

//////////////////////////////////
/*
	Misc Airlocks
*/

/obj/machinery/door/airlock/glass_large
	name = "large glass airlock"
	icon = 'icons/obj/doors/airlocks/glass_large/glass_large.dmi'
	overlays_file = 'icons/obj/doors/airlocks/glass_large/overlays.dmi'
	opacity = FALSE
	assemblytype = null
	glass = TRUE
	bound_width = 64 // 2x1
	greyscale_config = null
	greyscale_colors = null

/obj/machinery/door/airlock/glass_large/narsie_act()
	return

//////////////////////////////////
/*
	Greyscale Config Airlocks
*/

/obj/machinery/door/airlock/greyscale
	name = "fancy ungodlike airlock"
	desc = "I can only imagine the amount of hate this will get if this isn't like... actually perfect."
	icon = 'icons/obj/doors/airlocks/greyscale_template.dmi'
	greyscale_config = /datum/greyscale_config/airlocks
	greyscale_colors = "#ffffff#ffffff#ffffff#ffffff#ffffff#ffffff#ffffff"

/obj/machinery/door/airlock/greyscale/red
	greyscale_colors = "#d40808#d40808#d40808#d40808#ffffff#ffffff#808080"

/obj/machinery/door/airlock/greyscale/green
	greyscale_colors = "#00c41a#00c41a#00c41a#00c41a#ffffff#ffffff#808080"
