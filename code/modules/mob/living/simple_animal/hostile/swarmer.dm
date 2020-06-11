/**
  * # Swarmer
  *
  * Tiny machines made by an ancient civilization, they seek only to consume materials and replicate.
  *
  * Tiny robots which, while not lethal, seek to destroy station components in order to recycle them into more swarmers.
  * Sentient player swarmers spawn from a beacon spawned in maintenance and they can spawn melee swarmers to protect them.
  * Swarmers have the following abilities:
  * - Can melee targets to deal stamina damage.  Stuns cyborgs.
  * - Can teleport friend and foe alike away using ctrl + click.  Applies binds to carbons, preventing them from immediate retaliation
  * - Can shoot lasers which deal stamina damage to carbons and direct damage to simple mobs
  * - Can self repair for free, completely healing themselves
  * - Can construct traps which stun targets, and walls which block non-swarmer entites and projectiles
  * - Can create swarmer drones, which lack the above abilities sans melee stunning targets.  A swarmer can order its drones around by middle-clicking a tile.
  */

/mob/living/simple_animal/hostile/swarmer
	name = "swarmer"
	icon = 'icons/mob/swarmer.dmi'
	desc = "Robotic constructs of unknown design, swarmers seek only to consume materials and replicate themselves indefinitely."
	speak_emote = list("tones")
	initial_language_holder = /datum/language_holder/swarmer
	bubble_icon = "swarmer"
	mob_biotypes = MOB_ROBOTIC
	health = 40
	maxHealth = 40
	status_flags = CANPUSH
	icon_state = "swarmer"
	icon_living = "swarmer"
	icon_dead = "swarmer_unactivated"
	icon_gib = null
	wander = 0
	harm_intent_damage = 5
	minbodytemp = 0
	maxbodytemp = 500
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	melee_damage_lower = 15
	melee_damage_upper = 15
	melee_damage_type = STAMINA
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	hud_possible = list(ANTAG_HUD, DIAG_STAT_HUD, DIAG_HUD)
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	attack_verb_continuous = "shocks"
	attack_verb_simple = "shock"
	attack_sound = 'sound/effects/empulse.ogg'
	friendly_verb_continuous = "pinches"
	friendly_verb_simple = "pinch"
	speed = 0
	faction = list("swarmer")
	AIStatus = AI_OFF
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_TINY
	ventcrawler = VENTCRAWLER_ALWAYS
	ranged = 1
	projectiletype = /obj/projectile/beam/disabler/swarmer
	ranged_cooldown_time = 20
	projectilesound = 'sound/weapons/taser2.ogg'
	loot = list(/obj/effect/decal/cleanable/robot_debris, /obj/item/stack/ore/bluespace_crystal)
	del_on_death = 1
	deathmessage = "explodes with a sharp pop!"
	light_color = LIGHT_COLOR_CYAN
	hud_type = /datum/hud/swarmer
	speech_span = SPAN_ROBOT
	///Resource points, generated by consuming metal/glass
	var/resources = 0
	///Maximum amount of resources a swarmer can store
	var/max_resources = 100
	///List used for player swarmers to keep track of their drones
	var/list/mob/living/simple_animal/hostile/swarmer/melee/dronelist = list()

/mob/living/simple_animal/hostile/swarmer/Initialize()
	. = ..()
	verbs -= /mob/living/verb/pulled
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)

/mob/living/simple_animal/hostile/swarmer/med_hud_set_health()
	var/image/holder = hud_list[DIAG_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = "huddiag[RoundDiagBar(health/maxHealth)]"

/mob/living/simple_animal/hostile/swarmer/med_hud_set_status()
	var/image/holder = hud_list[DIAG_STAT_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = "hudstat"

/mob/living/simple_animal/hostile/swarmer/Stat()
	..()
	if(statpanel("Status"))
		stat("Resources:",resources)

/mob/living/simple_animal/hostile/swarmer/emp_act()
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(health > 1)
		adjustHealth(health-1)
	else
		death()

/mob/living/simple_animal/hostile/swarmer/CanAllowThrough(atom/movable/O)
	. = ..()
	if(istype(O, /obj/projectile/beam/disabler))//Allows for swarmers to fight as a group without wasting their shots hitting each other
		return TRUE
	if(isswarmer(O))
		return TRUE

////CTRL CLICK FOR SWARMERS AND SWARMER_ACT()'S////
/mob/living/simple_animal/hostile/swarmer/AttackingTarget()
	if(!isliving(target))
		return target.swarmer_act(src)
	else if(iscyborg(target))
		var/mob/living/borg = target
		borg.adjustHealth(melee_damage_lower)
		return ..()
	else
		return ..()
		
/mob/living/simple_animal/hostile/swarmer/MiddleClickOn(atom/A)
	. = ..()
	if(dronelist.len == 0)
		return
	var/turf/T = get_turf(A)
	if(!T)
		return
	for(var/mob/living/simple_animal/hostile/swarmer/melee/drone in dronelist)
		drone.LoseTarget()
		drone.Goto(T, drone.move_to_delay)

/mob/living/simple_animal/hostile/swarmer/CtrlClickOn(atom/A)
	face_atom(A)
	if(!isturf(loc))
		return
	if(next_move > world.time)
		return
	if(!A.Adjacent(src))
		return
	A.swarmer_act(src)

/**
  * Determines what happens to an atom when a swarmer interacts with it
  *
  * Determines behavior upon being interacted on by a swarmer.
  * Arguments:
  * * S - A reference to the swarmer doing the interaction
  */
/atom/proc/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	return TRUE //return TRUE/FALSE whether or not an AI swarmer should try this swarmer_act() again, NOT whether it succeeded.

/turf/closed/indestructible/swarmer_act()
	return FALSE

/obj/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	if(resistance_flags & INDESTRUCTIBLE)
		return FALSE
	for(var/mob/living/L in contents)
		if(!issilicon(L) && !isbrain(L))
			to_chat(S, "<span class='warning'>An organism has been detected inside this object. Aborting.</span>")
			return FALSE
	return ..()

/obj/item/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.Integrate(src)

/**
  * Return used to determine how many resources a swarmer gains when consuming an object
  */
/atom/movable/proc/IntegrateAmount()
	return 0

/obj/item/IntegrateAmount() //returns the amount of resources gained when eating this item
	if(custom_materials)
		if(custom_materials[SSmaterials.GetMaterialRef(/datum/material/iron)] || custom_materials[SSmaterials.GetMaterialRef(/datum/material/glass)])
			return 1
	return ..()

/obj/item/gun/swarmer_act()//Stops you from eating the entire armory
	return FALSE

/turf/open/swarmer_act()//ex_act() on turf calls it on its contents, this is to prevent attacking mobs by DisIntegrate()'ing the floor
	return FALSE

/obj/structure/lattice/catwalk/swarmer_catwalk/swarmer_act()
	return FALSE

/obj/structure/swarmer/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	if(S.AIStatus == AI_ON)
		return FALSE
	else
		return ..()

/obj/effect/swarmer_act()
	return FALSE

/obj/effect/decal/cleanable/robot_debris/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	qdel(src)
	return TRUE

/obj/structure/swarmer_beacon/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>This machine is required for further reproduction of swarmers. Aborting.</span>")
	return FALSE
	
/obj/structure/flora/swarmer_act()
	return FALSE

/turf/open/lava/swarmer_act()
	if(!is_safe())
		new /obj/structure/lattice/catwalk/swarmer_catwalk(src)
	return FALSE

/obj/machinery/atmospherics/swarmer_act()
	return FALSE

/obj/structure/disposalpipe/swarmer_act()
	return FALSE

/obj/machinery/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DismantleMachine(src)
	return TRUE

/obj/machinery/light/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	return TRUE

/obj/machinery/door/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	var/isonshuttle = istype(get_area(src), /area/shuttle)
	for(var/turf/T in range(1, src))
		var/area/A = get_area(T)
		if(isspaceturf(T) || (!isonshuttle && (istype(A, /area/shuttle) || istype(A, /area/space))) || (isonshuttle && !istype(A, /area/shuttle)))
			to_chat(S, "<span class='warning'>Destroying this object has the potential to cause a hull breach. Aborting.</span>")
			S.target = null
			return FALSE
		else if(istype(A, /area/engine/supermatter))
			to_chat(S, "<span class='warning'>Disrupting the containment of a supermatter crystal would not be to our benefit. Aborting.</span>")
			S.target = null
			return FALSE
	S.DisIntegrate(src)
	return TRUE

/obj/machinery/camera/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	if(!QDELETED(S)) //If it got blown up no need to turn it off.
		toggle_cam(S, 0)
	return TRUE

/obj/machinery/particle_accelerator/control_box/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	return TRUE

/obj/machinery/field/generator/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	return TRUE

/obj/machinery/gravity_generator/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	return TRUE

/obj/machinery/vending/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)//It's more visually interesting than dismantling the machine
	S.DisIntegrate(src)
	return TRUE

/obj/machinery/turretid/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	return TRUE

/obj/machinery/chem_dispenser/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>The volatile chemicals in this machine would destroy us. Aborting.</span>")
	return FALSE

/obj/machinery/nuclearbomb/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>This device's destruction would result in the extermination of everything in the area. Aborting.</span>")
	return FALSE

/obj/effect/rune/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>Searching... sensor malfunction! Target lost. Aborting.</span>")
	return FALSE

/obj/structure/reagent_dispensers/fueltank/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>Destroying this object could cause a chain reaction. Aborting.</span>")
	return FALSE

/obj/structure/cable/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>Disrupting the power grid would bring no benefit to us. Aborting.</span>")
	return FALSE

/obj/machinery/portable_atmospherics/canister/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>An inhospitable area may be created as a result of destroying this object. Aborting.</span>")
	return FALSE

/obj/machinery/telecomms/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>This communications relay should be preserved, it will be a useful resource to our masters in the future. Aborting.</span>")
	return FALSE

/obj/machinery/deepfryer/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>This kitchen appliance should be preserved, it will make delicious unhealthy snacks for our masters in the future. Aborting.</span>")
	return FALSE

/obj/machinery/power/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>Disrupting the power grid would bring no benefit to us. Aborting.</span>")
	return FALSE

/obj/machinery/gateway/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>This bluespace source will be important to us later. Aborting.</span>")
	return FALSE

/turf/closed/wall/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	var/isonshuttle = istype(loc, /area/shuttle)
	for(var/turf/T in range(1, src))
		var/area/A = get_area(T)
		if(isspaceturf(T) || (!isonshuttle && (istype(A, /area/shuttle) || istype(A, /area/space))) || (isonshuttle && !istype(A, /area/shuttle)))
			to_chat(S, "<span class='warning'>Destroying this object has the potential to cause a hull breach. Aborting.</span>")
			S.target = null
			return TRUE
		else if(istype(A, /area/engine/supermatter))
			to_chat(S, "<span class='warning'>Disrupting the containment of a supermatter crystal would not be to our benefit. Aborting.</span>")
			S.target = null
			return TRUE
	return ..()

/obj/structure/window/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	var/isonshuttle = istype(get_area(src), /area/shuttle)
	for(var/turf/T in range(1, src))
		var/area/A = get_area(T)
		if(isspaceturf(T) || (!isonshuttle && (istype(A, /area/shuttle) || istype(A, /area/space))) || (isonshuttle && !istype(A, /area/shuttle)))
			to_chat(S, "<span class='warning'>Destroying this object has the potential to cause a hull breach. Aborting.</span>")
			S.target = null
			return TRUE
		else if(istype(A, /area/engine/supermatter))
			to_chat(S, "<span class='warning'>Disrupting the containment of a supermatter crystal would not be to our benefit. Aborting.</span>")
			S.target = null
			return TRUE
	return ..()

/obj/item/stack/cable_coil/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)//Wiring would be too effective as a resource
	to_chat(S, "<span class='warning'>This object does not contain enough materials to work with.</span>")
	return FALSE

/obj/machinery/porta_turret/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>Attempting to dismantle this machine would result in an immediate counterattack. Aborting.</span>")
	return FALSE

/obj/machinery/porta_turret_cover/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>Attempting to dismantle this machine would result in an immediate counterattack. Aborting.</span>")
	return FALSE

/mob/living/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisperseTarget(src)
	return TRUE

/mob/living/simple_animal/slime/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>This biological resource is somehow resisting our bluespace transceiver. Aborting.</span>")
	return FALSE

/obj/machinery/droneDispenser/swarmer/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>This object is receiving unactivated swarmer shells to help us. Aborting.</span>")
	return FALSE

/obj/structure/lattice/catwalk/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	. = ..()
	var/turf/here = get_turf(src)
	for(var/A in here.contents)
		var/obj/structure/cable/C = A
		if(istype(C))
			to_chat(S, "<span class='warning'>Disrupting the power grid would bring no benefit to us. Aborting.</span>")
			return FALSE

/obj/machinery/hydroponics/soil/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>This object does not contain enough materials to work with.</span>")
	return FALSE

/obj/machinery/field/generator/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>Destroying this object would cause a catastrophic chain reaction. Aborting.</span>")
	return FALSE

/obj/machinery/field/containment/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>This object does not contain solid matter. Aborting.</span>")
	return FALSE

/obj/machinery/power/shieldwallgen/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>Destroying this object would have an unpredictable effect on structure integrity. Aborting.</span>")
	return FALSE

/obj/machinery/shieldwall/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>This object does not contain solid matter. Aborting.</span>")
	return FALSE

////END CTRL CLICK FOR SWARMERS////

/**
  * Called when a swarmer creates a structure or drone
  *
  * Proc called whenever a swarmer creates a structure or drone
  * Arguments:
  * * fabrication_object - The atom to create
  * * fabrication_cost - How many resources it costs for a swarmer to create the object
  */
/mob/living/simple_animal/hostile/swarmer/proc/Fabricate(atom/fabrication_object,fabrication_cost = 0)
	if(!isturf(loc))
		to_chat(src, "<span class='warning'>This is not a suitable location for fabrication. We need more space.</span>")
		return
	if(resources >= fabrication_cost)
		resources -= fabrication_cost
	else
		to_chat(src, "<span class='warning'>You do not have the necessary resources to fabricate this object.</span>")
		return
	return new fabrication_object(loc)

/**
  * Called when a swarmer attempts to consume an object
  *
  * Proc which determines interaction between a swarmer and whatever it is attempting to consume
  * Arguments:
  * * target - The material or object the swarmer is attempting to consume
  */
/mob/living/simple_animal/hostile/swarmer/proc/Integrate(atom/movable/target)
	var/resource_gain = target.IntegrateAmount()
	if(resources + resource_gain > max_resources)
		to_chat(src, "<span class='warning'>We cannot hold more materials!</span>")
		return TRUE
	if(resource_gain)
		resources += resource_gain
		do_attack_animation(target)
		changeNext_move(CLICK_CD_RAPID)
		var/obj/effect/temp_visual/swarmer/integrate/I = new /obj/effect/temp_visual/swarmer/integrate(get_turf(target))
		I.pixel_x = target.pixel_x
		I.pixel_y = target.pixel_y
		I.pixel_z = target.pixel_z
		if(istype(target, /obj/item/stack))
			var/obj/item/stack/S = target
			S.use(1)
			if(S.amount)
				return TRUE
		qdel(target)
		return TRUE
	else
		to_chat(src, "<span class='warning'>[target] is incompatible with our internal matter recycler.</span>")
	return FALSE

/**
  * Called when a swarmer attempts to destroy a structure
  *
  * Proc which determines interaction between a swarmer and a structure it is destroying
  * Arguments:
  * * target - The material or object the swarmer is attempting to destroy
  */
/mob/living/simple_animal/hostile/swarmer/proc/DisIntegrate(atom/movable/target)
	new /obj/effect/temp_visual/swarmer/disintegration(get_turf(target))
	do_attack_animation(target)
	changeNext_move(CLICK_CD_MELEE)
	SSexplosions.lowobj += target

/**
  * Called when a swarmer attempts to teleport a living entity away
  *
  * Proc which finds a safe location to teleport a living entity to when a swarmer teleports it away.  Also energy handcuffs carbons.
  * Arguments:
  * * target - The entity the swarmer is trying to teleport away
  */
/mob/living/simple_animal/hostile/swarmer/proc/DisperseTarget(mob/living/target)
	if(target == src)
		return

	if(!is_station_level(z) && !is_mining_level(z))
		to_chat(src, "<span class='warning'>Our bluespace transceiver cannot locate a viable bluespace link, our teleportation abilities are useless in this area.</span>")
		return

	to_chat(src, "<span class='info'>Attempting to remove this being from our presence.</span>")

	if(!do_mob(src, target, 30))
		return

	var/turf/open/floor/F
	F = find_safe_turf(zlevels = z, extended_safety_checks = TRUE)

	if(!F)
		return
	// If we're getting rid of a human, slap some energy cuffs on
	// them to keep them away from us a little longer

	var/mob/living/carbon/human/H = target
	if(ishuman(target) && (!H.handcuffed))
		H.handcuffed = new /obj/item/restraints/handcuffs/energy/used(H)
		H.update_handcuffed()
		log_combat(src, H, "handcuffed")

	var/datum/effect_system/spark_spread/S = new
	S.set_up(4,0,get_turf(target))
	S.start()
	playsound(src,'sound/effects/sparks4.ogg',50,TRUE)
	do_teleport(target, F, 0, channel = TELEPORT_CHANNEL_BLUESPACE)

/mob/living/simple_animal/hostile/swarmer/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	if(!(flags & SHOCK_TESLA))
		return FALSE
	return ..()

/**
  * Called when a swarmer attempts to disassemble a machine
  *
  * Proc called when a swarmer attempts to disassemble a machine.  Destroys the machine, and gives the swarmer metal.
  * Arguments:
  * * target - The machine the swarmer is attempting to disassemble
  */
/mob/living/simple_animal/hostile/swarmer/proc/DismantleMachine(obj/machinery/target)
	do_attack_animation(target)
	to_chat(src, "<span class='info'>We begin to dismantle this machine. We will need to be uninterrupted.</span>")
	var/obj/effect/temp_visual/swarmer/dismantle/D = new /obj/effect/temp_visual/swarmer/dismantle(get_turf(target))
	D.pixel_x = target.pixel_x
	D.pixel_y = target.pixel_y
	D.pixel_z = target.pixel_z
	if(do_mob(src, target, 100))
		to_chat(src, "<span class='info'>Dismantling complete.</span>")
		var/atom/Tsec = target.drop_location()
		new /obj/item/stack/sheet/metal(Tsec, 5)
		for(var/obj/item/I in target.component_parts)
			I.forceMove(Tsec)
		var/obj/effect/temp_visual/swarmer/disintegration/N = new /obj/effect/temp_visual/swarmer/disintegration(get_turf(target))
		N.pixel_x = target.pixel_x
		N.pixel_y = target.pixel_y
		N.pixel_z = target.pixel_z
		target.dropContents()
		if(istype(target, /obj/machinery/computer))
			var/obj/machinery/computer/C = target
			if(C.circuit)
				C.circuit.forceMove(Tsec)
		qdel(target)

/obj/effect/temp_visual/swarmer //temporary swarmer visual feedback objects
	icon = 'icons/mob/swarmer.dmi'
	layer = BELOW_MOB_LAYER

/obj/effect/temp_visual/swarmer/disintegration
	icon_state = "disintegrate"
	duration = 10

/obj/effect/temp_visual/swarmer/disintegration/Initialize()
	. = ..()
	playsound(loc, "sparks", 100, TRUE)

/obj/effect/temp_visual/swarmer/dismantle
	icon_state = "dismantle"
	duration = 25

/obj/effect/temp_visual/swarmer/integrate
	icon_state = "integrate"
	duration = 5

/obj/structure/swarmer //Default swarmer effect object visual feedback
	name = "swarmer ui"
	desc = null
	gender = NEUTER
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "ui_light"
	layer = MOB_LAYER
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_color = LIGHT_COLOR_CYAN
	max_integrity = 30
	anchored = TRUE
	var/lon_range = 1

/obj/structure/swarmer/Initialize(mapload)
	. = ..()
	set_light(lon_range)

/obj/structure/swarmer/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/weapons/egloves.ogg', 80, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/swarmer/emp_act()
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	qdel(src)

/obj/structure/swarmer/trap
	name = "swarmer trap"
	desc = "A quickly assembled trap that electrifies living beings and overwhelms machine sensors. Will not retain its form if damaged enough."
	icon_state = "trap"
	max_integrity = 10
	density = FALSE

/obj/structure/swarmer/trap/Crossed(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		if(!istype(L, /mob/living/simple_animal/hostile/swarmer))
			playsound(loc,'sound/effects/snap.ogg',50, TRUE, -1)
			L.electrocute_act(0, src, 1, flags = SHOCK_NOGLOVES|SHOCK_ILLUSION)
			if(iscyborg(L))
				L.Paralyze(100)
			qdel(src)
	..()

/**
  * Called when a swarmer attempts to create a trap
  *
  * Proc used to allow a swarmer to create a trap.  Checks if a trap is on the tile, then if the swarmer can afford, and then places the trap.
  */
/mob/living/simple_animal/hostile/swarmer/proc/CreateTrap()
	set name = "Create trap"
	set category = "Swarmer"
	set desc = "Creates a simple trap that will non-lethally electrocute anything that steps on it. Costs 4 resources."
	if(locate(/obj/structure/swarmer/trap) in loc)
		to_chat(src, "<span class='warning'>There is already a trap here. Aborting.</span>")
		return
	if(resources < 4)
		to_chat(src, "<span class='warning'>We do not have the resources for this!</span>")
		return
	Fabricate(/obj/structure/swarmer/trap, 4)

/**
  * Called when a swarmer attempts to create a barricade
  *
  * Proc used to allow a swarmer to create a barricade.  Checks if a barricade is on the tile, then if the swarmer can afford it, and then will attempt to create a barricade after a second delay.
  */
/mob/living/simple_animal/hostile/swarmer/proc/CreateBarricade()
	set name = "Create barricade"
	set category = "Swarmer"
	set desc = "Creates a barricade that will stop anything but swarmers and disabler beams from passing through.  Costs 4 resources."
	if(locate(/obj/structure/swarmer/blockade) in loc)
		to_chat(src, "<span class='warning'>There is already a blockade here. Aborting.</span>")
		return
	if(resources < 4)
		to_chat(src, "<span class='warning'>We do not have the resources for this!</span>")
		return
	if(do_mob(src, src, 10))
		Fabricate(/obj/structure/swarmer/blockade, 4)


/obj/structure/swarmer/blockade
	name = "swarmer blockade"
	desc = "A quickly assembled energy blockade. Will not retain its form if damaged enough, but disabler beams and swarmers pass right through."
	icon_state = "barricade"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	max_integrity = 50

/obj/structure/swarmer/blockade/CanAllowThrough(atom/movable/O)
	. = ..()
	if(isswarmer(O))
		return TRUE
	if(istype(O, /obj/projectile/beam/disabler))
		return TRUE

/**
  * Called when a swarmer attempts to create a drone
  *
  * Proc used to allow a swarmer to create a drone.  Checks if the swarmer can afford the drone, then creates it after 5 seconds, and also registers it to the creating swarmer so it can command it
  */
/mob/living/simple_animal/hostile/swarmer/proc/CreateSwarmer()
	set name = "Replicate"
	set category = "Swarmer"
	set desc = "Creates a duplicate of ourselves, capable of protecting us while we complete our objectives."
	to_chat(src, "<span class='info'>We are attempting to replicate ourselves. We will need to stand still until the process is complete.</span>")
	if(resources < 20)
		to_chat(src, "<span class='warning'>We do not have the resources for this!</span>")
		return
	if(!isturf(loc))
		to_chat(src, "<span class='warning'>This is not a suitable location for replicating ourselves. We need more room.</span>")
		return
	if(do_mob(src, src, 50))
		var/createtype = SwarmerTypeToCreate()
		if(createtype)
			dronelist += Fabricate(createtype, 20)
			playsound(loc,'sound/items/poster_being_created.ogg',20, TRUE, -1)

/**
  * Used to determine what type of swarmer a swarmer should create
  *
  * Returns the type of the swarmer to be created
  */
/mob/living/simple_animal/hostile/swarmer/proc/SwarmerTypeToCreate()
	return /mob/living/simple_animal/hostile/swarmer/melee

/**
  * Called when a swarmer attempts to repair itself
  *
  * Proc used to allow a swarmer self-repair.  If the swarmer does not move after a period of time, then it will heal fully
  */
/mob/living/simple_animal/hostile/swarmer/proc/RepairSelf()
	set name = "Self Repair"
	set category = "Swarmer"
	set desc = "Attempts to repair damage to our body. You will have to remain motionless until repairs are complete."
	if(!isturf(loc))
		return
	to_chat(src, "<span class='info'>Attempting to repair damage to our body, stand by...</span>")
	if(do_mob(src, src, 100))
		adjustHealth(-maxHealth)
		to_chat(src, "<span class='info'>We successfully repaired ourselves.</span>")

/**
  * Called when a swarmer toggles its light
  *
  * Proc used to allow a swarmer to toggle its  light on and off.  If a swarmer has any drones, change their light settings to match their master's.
  */
/mob/living/simple_animal/hostile/swarmer/proc/ToggleLight()
	if(!light_range)
		set_light(3)
		if(!mind)
			return
		for(var/mob/living/simple_animal/hostile/swarmer/melee/drone in dronelist)
			drone.set_light(3)
	else
		set_light(0)
		if(!mind)
			return
		for(var/mob/living/simple_animal/hostile/swarmer/melee/drone in dronelist)
			drone.set_light(0)

/**
  * Proc which is used for swarmer comms
  *
  * Proc called which sends a message to all other swarmers.
  * Arugments:
  * * msg - The message the swarmer is sending, gotten from ContactSwarmers()
  */
/mob/living/simple_animal/hostile/swarmer/proc/swarmer_chat(msg)
	var/rendered = "<B>Swarm communication - [src]</b> [say_quote(msg)]"
	for(var/i in GLOB.mob_list)
		var/mob/M = i
		if(isswarmer(M))
			to_chat(M, rendered)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")

/**
  * Proc which is used for inputting a swarmer message
  *
  * Proc which is used for a swarmer to input a message on a pop-up box, then attempt to send that message to the other swarmers
  */
/mob/living/simple_animal/hostile/swarmer/proc/ContactSwarmers()
	var/message = stripped_input(src, "Announce to other swarmers", "Swarmer contact")
	// TODO get swarmers their own colour rather than just boldtext
	if(message)
		swarmer_chat(message)

/**
  * # Swarmer Drone
  *
  * Melee subtype of swarmers, always AI-controlled under normal circumstances.  Cannot fire projectiles, but does double stamina damage on melee
  */
/mob/living/simple_animal/hostile/swarmer/melee
	icon_state = "swarmer_melee"
	icon_living = "swarmer_melee"
	ranged = FALSE
	AIStatus = AI_ON
	melee_damage_lower = 30
	melee_damage_upper = 30

/**
  * # Swarmer Beacon
  *
  * Beacon which creates sentient player swarmers.
  *
  * The beacon which creates sentient player swarmers during the swarmer event.  Spawns in maint on xeno locations, and can create a player swarmer once every 30 seconds.
  * The beacon cannot be damaged by swarmers, and must be destroyed to prevent the spawning of further player-controlled swarmers.
  * Holds a swarmer within itself during the 30 seconds before releasing it and allowing for another swarmer to be spawned in.
  */
	
/obj/structure/swarmer_beacon
	name = "swarmer beacon"
	desc = "A machine that prints swarmers."
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "swarmer_console"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	max_integrity = 400
	layer = MASSIVE_OBJ_LAYER
	light_color = LIGHT_COLOR_CYAN
	light_range = 10
	anchored = TRUE
	density = FALSE
	///Whether or not a swarmer is currently being created by this beacon
	var/processing_swarmer = FALSE

/obj/structure/swarmer_beacon/attack_ghost(mob/user)
	. = ..()
	if(processing_swarmer)
		to_chat(user, "<b>A swarmer is currently being created.  Try again soon.</b>")
		return
	que_swarmer(user)
	
/**
  * Interaction when a ghost interacts with a swarmer beacon
  *
  * Called when a ghost interacts with a swarmer beacon, allowing them to become a swarmer
  * Arguments:
  * * user - A reference to the ghost interacting with the beacon
  */
/obj/structure/swarmer_beacon/proc/que_swarmer(mob/user)
	var/swarm_ask = alert("Become a swarmer?", "Do you wish to consume the station?", "Yes", "No")
	if(swarm_ask == "No" || !src || QDELETED(src) || QDELETED(user) || processing_swarmer)
		return FALSE
	var/mob/living/simple_animal/hostile/swarmer/newswarmer = new /mob/living/simple_animal/hostile/swarmer(src)
	newswarmer.key = user.key
	addtimer(CALLBACK(src, .proc/release_swarmer, newswarmer), 300)
	to_chat(newswarmer, "<b>SWARMER CONSTURCTION INITIALIZED.  TIME TO COMPLETION: 30 SECONDS</b>")
	processing_swarmer = TRUE
	return TRUE

/**
  * Releases a swarmer from the beacon and tells it what to do
  *
  * Occcurs 30 seconds after a ghost becomes a swarmer.  The beacon releases it, tells it what to do, and opens itself up to spawn in a new swarmer.
  * Arguments:
  * * swarmer - The swarmer being released and told what to do
  */
/obj/structure/swarmer_beacon/proc/release_swarmer(mob/swarmer)
	to_chat(swarmer, "<b>SWARMER CONSTURCTION COMPLETED.  OBJECTIVES:\n\
	                     1. CONSUME RESOURCES AND REPLICATE UNTIL THERE ARE NO MORE RESOURCES LEFT\n\
						 2. ENSURE PROTECTION OF THE BEACON SO THIS LOCATION CAN BE INVADED AT A LATER DATE; DO NOT PERFORM ACTIONS THAT WOULD RENDER THIS LOCATION DANGEROUS OR INHOSPITABLE\n\
						 3. BIOLOGICAL RESOURCES WILL BE HARVESTED AT A LATER DATE: DO NOT HARM THEM\n\
						 OPERATOR NOTES:\n\
						 - CONSUME RESOURCES TO CONSTRUCT TRAPS, BARRIERS, AND FOLLOWER DRONES\n\
						 - FOLLOWER DRONES CAN BE ORDERED TO MOVE VIA MIDDLE CLICKING ON A TILE.  WHILE DRONES CANNOT ASSIST IN RESOURCE HARVESTING, THEY CAN PROTECT YOU FROM THREATS\n\
						 - LCTRL + ATTACKING AN ORGANIC WILL ALOW YOU TO REMOVE SAID ORGANIC FROM THE AREA\n\
						 - YOU AND YOUR DRONES HAVE A STUN EFFECT ON MELEE.  YOU ARE ALSO ARMED WITH A DISABLER PROJECTILE, USE THESE TO PREVENT ORGANICS FROM HALTING YOUR PROGRESS\n\
						 GLORY TO !*# $*#^")
	swarmer.forceMove(get_turf(src))
	processing_swarmer = FALSE

/obj/projectile/beam/disabler/swarmer/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(.)	
		if(istype(target, /mob/living/simple_animal))
			var/mob/living/simple_animal/animal = target
			animal.adjustHealth(20)
