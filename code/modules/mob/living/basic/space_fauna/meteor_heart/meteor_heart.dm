#define HEARTBEAT_NORMAL (1.2 SECONDS)
#define HEARTBEAT_FAST (0.6 SECONDS)
#define HEARTBEAT_FRANTIC (0.4 SECONDS)

/mob/living/basic/meteor_heart
	name = "meteor heart"
	desc = "A pulsing lump of flesh and bone growing directly out of the ground."
	icon = 'icons/mob/simple/meteor_heart.dmi'
	icon_state = "heart"
	icon_living = "heart"
	mob_biotypes = MOB_ORGANIC
	basic_mob_flags = DEL_ON_DEATH
	mob_size = MOB_SIZE_HUGE
	health = 600 // 15 PKA shots
	maxHealth = 600
	pressure_resistance = 200
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes"
	response_disarm_simple = "gently push"
	faction = list()
	ai_controller = /datum/ai_controller/basic_controller/meteor_heart
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	combat_mode = TRUE
	move_resist = INFINITY // This mob IS the floor
	/// Action which sends a line of spikes chasing a player
	var/datum/action/cooldown/chasing_spikes/spikes
	/// Action which summons areas the player can't stand in
	var/datum/action/cooldown/spine_traps/traps
	/// Looping heartbeat sound
	var/datum/looping_sound/heartbeat/soundloop

/mob/living/basic/meteor_heart/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, INNATE_TRAIT)
	AddElement(/datum/element/death_drops, list(/obj/effect/temp_visual/meteor_heart_death))
	AddElement(/datum/element/relay_attackers)

	spikes = new(src)
	spikes.Grant(src)
	ai_controller.blackboard[BB_METEOR_HEART_GROUND_SPIKES] = WEAKREF(spikes)

	traps = new(src)
	traps.Grant(src)
	ai_controller.blackboard[BB_METEOR_HEART_SPINE_TRAPS] = WEAKREF(traps)

	ai_controller.set_ai_status(AI_STATUS_OFF)

	RegisterSignal(src, COMSIG_MOB_ABILITY_FINISHED, PROC_REF(used_ability))
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(aggro))

	for (var/obj/structure/meateor_fluff/body_part in view(5, src))
		RegisterSignal(body_part, COMSIG_ATOM_DESTRUCTION, PROC_REF(aggro))

	soundloop = new(src, start_immediately = FALSE)
	soundloop.mid_length = HEARTBEAT_NORMAL
	soundloop.pressure_affected = FALSE
	soundloop.start()

/// Called when we get mad at something, either for attacking us or attacking the nearby area
/mob/living/basic/meteor_heart/proc/aggro()
	if (ai_controller.ai_status == AI_STATUS_ON)
		return
	ai_controller.set_ai_status(ai_controller.get_setup_mob_ai_status(src))
	if (!ai_controller.ai_status == AI_STATUS_ON)
		return
	icon_state = "heart_aggro"
	soundloop.set_mid_length(HEARTBEAT_FAST)

/// Called when we stop being mad
/mob/living/basic/meteor_heart/proc/deaggro()
	ai_controller.set_ai_status(AI_STATUS_OFF)
	icon_state = "heart"
	soundloop.set_mid_length(HEARTBEAT_NORMAL)

/// Animate when using certain abilities
/mob/living/basic/meteor_heart/proc/used_ability(mob/living/owner, datum/action/cooldown/ability)
	SIGNAL_HANDLER
	if (ability != spikes)
		return
	Shake(1, 0, 1.5 SECONDS)

/mob/living/basic/meteor_heart/Destroy()
	QDEL_NULL(spikes)
	QDEL_NULL(traps)
	QDEL_NULL(soundloop)
	return ..()

/// Dramatic death animation for the meteor heart mob
/obj/effect/temp_visual/meteor_heart_death
	name = "meteor heart"
	icon = 'icons/mob/simple/meteor_heart.dmi'
	icon_state = "heart_dying"
	desc = "You've killed this innocent asteroid, I hope you feel happy."
	duration = 3 SECONDS
	/// Looping heartbeat sound
	var/datum/looping_sound/heartbeat/soundloop

/obj/effect/temp_visual/meteor_heart_death/Initialize(mapload)
	. = ..()
	playsound(src, 'sound/magic/demon_dies.ogg', vol = 100, vary = TRUE, pressure_affected = FALSE)
	Shake(2, 0, 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(gib)), duration - 1, TIMER_DELETE_ME)
	soundloop = new(src, start_immediately = FALSE)
	soundloop.mid_length = HEARTBEAT_FRANTIC
	soundloop.pressure_affected = FALSE
	soundloop.start()

/obj/effect/temp_visual/meteor_heart_death/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/// Make this place a mess
/obj/effect/temp_visual/meteor_heart_death/proc/gib()
	playsound(loc, 'sound/effects/attackblob.ogg', vol = 100, vary = TRUE, pressure_affected = FALSE)
	var/turf/my_turf = get_turf(src)
	new /obj/effect/gibspawner/human(my_turf)
	for (var/obj/structure/eyeball as anything in GLOB.meteor_eyeballs)
		if (eyeball.z != src.z)
			continue
		addtimer(CALLBACK(eyeball, TYPE_PROC_REF(/atom/, take_damage), eyeball.max_integrity), rand(0.5 SECONDS, 2 SECONDS)) // pop!
	for (var/mob/murderer in range(10, src))
		if (!murderer.client || isspaceturf(get_turf(murderer)))
			continue
		shake_camera(murderer, duration = 2 SECONDS, strength = 2)

#undef HEARTBEAT_NORMAL
#undef HEARTBEAT_FAST
#undef HEARTBEAT_FRANTIC
