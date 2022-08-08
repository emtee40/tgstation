/// The carp rift is currently charging.
#define CHARGE_ONGOING 0
/// The carp rift is currently charging and has output a final warning.
#define CHARGE_FINALWARNING 1
/// The carp rift is now fully charged.
#define CHARGE_COMPLETED 2

/datum/action/innate/summon_rift
	name = "Summon Rift"
	desc = "Summon a rift to bring forth a horde of space carp."
	background_icon_state = "bg_default"
	icon_icon = 'icons/mob/actions/actions_space_dragon.dmi'
	button_icon_state = "carp_rift"

/datum/action/innate/summon_rift/Activate()
	var/datum/antagonist/space_dragon/dragon = owner.mind?.has_antag_datum(/datum/antagonist/space_dragon)
	if(!dragon)
		return
	var/area/rift_location = get_area(owner)
	if(!(rift_location.area_flags & VALID_TERRITORY))
		to_chat(owner, span_warning("You can't summon a rift here! Try summoning somewhere secure within the station!"))
		return
	for(var/obj/structure/carp_rift/rift as anything in dragon.rift_list)
		var/area/used_location = get_area(rift)
		if(used_location == rift_location)
			to_chat(owner, span_warning("You've already summoned a rift in this area! You have to summon again somewhere else!"))
			return
	to_chat(owner, span_warning("You begin to open a rift..."))
	if(!do_after(owner, 10 SECONDS, target = owner))
		return
	if(locate(/obj/structure/carp_rift) in owner.loc)
		return
	var/obj/structure/carp_rift/new_rift = new /obj/structure/carp_rift(get_turf(owner))
	playsound(owner.loc, 'sound/vehicles/rocketlaunch.ogg', 100, TRUE)
	dragon.riftTimer = -1
	new_rift.dragon = dragon
	dragon.rift_list += new_rift
	to_chat(owner, span_boldwarning("The rift has been summoned. Prevent the crew from destroying it at all costs!"))
	notify_ghosts("The Space Dragon has opened a rift!", source = new_rift, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Carp Rift Opened")
	qdel(src)

/**
 * # Carp Rift
 *
 * The portals Space Dragon summons to bring carp onto the station.
 *
 * The portals Space Dragon summons to bring carp onto the station.  His main objective is to summon 3 of them and protect them from being destroyed.
 * The portals can summon sentient space carp in limited amounts.  The portal also changes color based on whether or not a carp spawn is available.
 * Once it is fully charged, it becomes indestructible, and intermitently spawns non-sentient carp.  It is still destroyed if Space Dragon dies.
 */
/obj/structure/carp_rift
	name = "carp rift"
	desc = "A rift akin to the ones space carp use to travel long distances."
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 50, BIO = 100, FIRE = 100, ACID = 100)
	max_integrity = 300
	icon = 'icons/obj/carp_rift.dmi'
	icon_state = "carp_rift_carpspawn"
	light_color = LIGHT_COLOR_PURPLE
	light_range = 10
	anchored = TRUE
	density = FALSE
	plane = MASSIVE_OBJ_PLANE
	/// The amount of time the rift has charged for.
	var/time_charged = 0
	/// The maximum charge the rift can have.
	var/max_charge = 300
	/// How many carp spawns it has available.
	var/carp_stored = 1
	/// A reference to the Space Dragon antag that created it.
	var/datum/antagonist/space_dragon/dragon
	/// Current charge state of the rift.
	var/charge_state = CHARGE_ONGOING
	/// The interval for adding additional space carp spawns to the rift.
	var/carp_interval = 60
	/// The time since an extra carp was added to the ghost role spawning pool.
	var/last_carp_inc = 0
	/// A list of all the ckeys which have used this carp rift to spawn in as carps.
	var/list/ckey_list = list()

/obj/structure/carp_rift/Initialize(mapload)
	. = ..()

	AddComponent( \
		/datum/component/aura_healing, \
		range = 0, \
		simple_heal = 5, \
		limit_to_trait = TRAIT_HEALS_FROM_CARP_RIFTS, \
		healing_color = COLOR_BLUE, \
	)

	START_PROCESSING(SSobj, src)

// Carp rifts always take heavy explosion damage. Discourages the use of maxcaps
// and favours more weaker explosives to destroy the portal
// as they have the same effect on the portal.
/obj/structure/carp_rift/ex_act(severity, target)
	return ..(min(EXPLODE_HEAVY, severity))

/obj/structure/carp_rift/examine(mob/user)
	. = ..()
	if(time_charged < max_charge)
		. += span_notice("It seems to be [(time_charged / max_charge) * 100]% charged.")
	else
		. += span_warning("This one is fully charged. In this state, it is poised to transport a much larger amount of carp than normal.")

	if(isobserver(user))
		. += span_notice("It has [carp_stored] carp available to spawn as.")

/obj/structure/carp_rift/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, 'sound/magic/lightningshock.ogg', 50, TRUE)

/obj/structure/carp_rift/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(charge_state != CHARGE_COMPLETED)
		if(dragon)
			to_chat(dragon.owner.current, span_boldwarning("A rift has been destroyed! You have failed, and find yourself  weakened."))
			dragon.destroy_rifts()
	dragon = null
	return ..()

/obj/structure/carp_rift/process(delta_time)
	// If we're fully charged, just start mass spawning carp and move around.
	if(charge_state == CHARGE_COMPLETED)
		if(DT_PROB(1.25, delta_time) && dragon)
			var/mob/living/newcarp = new dragon.ai_to_spawn(loc)
			newcarp.faction = dragon.owner.current.faction
		if(DT_PROB(1.5, delta_time))
			var/rand_dir = pick(GLOB.cardinals)
			Move(get_step(src, rand_dir), rand_dir)
		return

	// Increase time trackers and check for any updated states.
	time_charged = min(time_charged + delta_time, max_charge)
	last_carp_inc += delta_time
	update_check()

/obj/structure/carp_rift/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	summon_carp(user)

/**
 * Does a series of checks based on the portal's status.
 *
 * Performs a number of checks based on the current charge of the portal, and triggers various effects accordingly.
 * If the current charge is a multiple of carp_interval, add an extra carp spawn.
 * If we're halfway charged, announce to the crew our location in a CENTCOM announcement.
 * If we're fully charged, tell the crew we are, change our color to yellow, become invulnerable, and give Space Dragon the ability to make another rift, if he hasn't summoned 3 total.
 */
/obj/structure/carp_rift/proc/update_check()
	// If the rift is fully charged, there's nothing to do here anymore.
	if(charge_state == CHARGE_COMPLETED)
		return

	// Can we increase the carp spawn pool size?
	if(last_carp_inc >= carp_interval)
		carp_stored++
		icon_state = "carp_rift_carpspawn"
		if(light_color != LIGHT_COLOR_PURPLE)
			set_light_color(LIGHT_COLOR_PURPLE)
			update_light()
		notify_ghosts("The carp rift can summon an additional carp!", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Carp Spawn Available")
		last_carp_inc -= carp_interval

	// Is the rift now fully charged?
	if(time_charged >= max_charge)
		charge_state = CHARGE_COMPLETED
		var/area/A = get_area(src)
		priority_announce("Spatial object has reached peak energy charge in [initial(A.name)], please stand-by.", "Central Command Wildlife Observations")
		atom_integrity = INFINITY
		icon_state = "carp_rift_charged"
		set_light_color(LIGHT_COLOR_YELLOW)
		update_light()
		armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100)
		resistance_flags = INDESTRUCTIBLE
		dragon.rifts_charged += 1
		if(dragon.rifts_charged != 3 && !dragon.objective_complete)
			var/datum/action/innate/summon_rift/rift = new()
			rift.Grant(dragon.owner.current)
			dragon.riftTimer = 0
			dragon.rift_empower()
		// Early return, nothing to do after this point.
		return

	// Do we need to give a final warning to the station at the halfway mark?
	if(charge_state < CHARGE_FINALWARNING && time_charged >= (max_charge * 0.5))
		charge_state = CHARGE_FINALWARNING
		var/area/A = get_area(src)
		priority_announce("A rift is causing an unnaturally large energy flux in [initial(A.name)]. Stop it at all costs!", "Central Command Wildlife Observations", ANNOUNCER_SPANOMALIES)

/**
 * Used to create carp controlled by ghosts when the option is available.
 *
 * Creates a carp for the ghost to control if we have a carp spawn available.
 * Gives them prompt to control a carp, and if our circumstances still allow if when they hit yes, spawn them in as a carp.
 * Also add them to the list of carps in Space Dragon's antgonist datum, so they'll be displayed as having assisted him on round end.
 * Arguments:
 * * mob/user - The ghost which will take control of the carp.
 */
/obj/structure/carp_rift/proc/summon_carp(mob/user)
	if(carp_stored <= 0)//Not enough carp points
		return FALSE
	var/is_listed = FALSE
	if (user.ckey in ckey_list)
		if(carp_stored == 1)
			to_chat(user, span_warning("You've already become a carp using this rift!  Either wait for a backlog of carp spawns or until the next rift!"))
			return FALSE
		is_listed = TRUE
	var/carp_ask = tgui_alert(user, "Become a carp?", "Carp Rift", list("Yes", "No"))
	if(carp_ask != "Yes" || QDELETED(src) || QDELETED(user))
		return FALSE
	if(carp_stored <= 0)
		to_chat(user, span_warning("The rift already summoned enough carp!"))
		return FALSE

	if(!dragon)
		return
	var/mob/living/newcarp = new dragon.minion_to_spawn(loc)
	newcarp.faction = dragon.owner.current.faction
	newcarp.AddElement(/datum/element/nerfed_pulling, GLOB.typecache_general_bad_things_to_easily_move)
	newcarp.AddElement(/datum/element/prevent_attacking_of_types, GLOB.typecache_general_bad_hostile_attack_targets, "this tastes awful!")

	if(!is_listed)
		ckey_list += user.ckey
	newcarp.key = user.key
	newcarp.set_name()
	dragon.carp += newcarp.mind
	to_chat(newcarp, span_boldwarning("You have arrived in order to assist the space dragon with securing the rifts. Do not jeopardize the mission, and protect the rifts at all costs!"))
	carp_stored--
	if(carp_stored <= 0 && charge_state < CHARGE_COMPLETED)
		icon_state = "carp_rift"
		set_light_color(LIGHT_COLOR_BLUE)
		update_light()
	return TRUE

#undef CHARGE_ONGOING
#undef CHARGE_FINALWARNING
#undef CHARGE_COMPLETED
