/mob/living/basic/tree
	name = "pine tree"
	desc = "A pissed off tree-like alien. It seems annoyed with the festivities..."
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"
	icon_living = "pine_1"
	icon_dead = "pine_1"
	icon_gib = "pine_1"
	health_doll_icon = "pine_1"
	mob_biotypes = MOB_ORGANIC | MOB_PLANT
	gender = NEUTER
	gold_core_spawnable = HOSTILE_SPAWN
	basic_mob_flags = DEL_ON_DEATH

	response_help_continuous = "brushes"
	response_help_simple = "brush"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"

	mob_size = MOB_SIZE_LARGE
	pixel_x = -16
	base_pixel_x = -16

	speed = 1
	maxHealth = 250
	health = 250
	melee_damage_lower = 8
	melee_damage_upper = 12
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

	faction = list(FACTION_HOSTILE)
	speak_emote = list("pines")

	habitable_atmos = list("min_oxy" = 2, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 2.5
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1200

	death_message = "is hacked into pieces!"

	ai_controller = /datum/ai_controller/basic_controller/tree

	///items that make us angry
	var/list/infuriating_objects = list(/obj/item/chainsaw, /obj/item/hatchet, /obj/item/stack/sheet/mineral/wood)
	///chance of target getting paralyzed
	var/paralyze_prob = 15
	///for how the target is  paralyzed
	var/paralyze_value = 50
	///boost added when our target is holding an item that offends us
	var/anger_boost = 85

/mob/living/basic/tree/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_PINE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	AddElement(/datum/element/death_drops, list(/obj/item/stack/sheet/mineral/wood))
	RegisterSignal(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(handle_paralysis))

/mob/living/basic/tree/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()
	if(!isopenturf(loc))
		return
	var/turf/open/our_turf = src.loc
	if(!our_turf.air || !our_turf.air.gases[/datum/gas/carbon_dioxide])
		return

	var/co2 = our_turf.air.gases[/datum/gas/carbon_dioxide][MOLES]
	if(co2 > 0 && SPT_PROB(13, seconds_per_tick))
		var/amt = min(co2, 9)
		our_turf.air.gases[/datum/gas/carbon_dioxide][MOLES] -= amt
		our_turf.atmos_spawn_air("o2=[amt]")

/mob/living/basic/tree/proc/handle_paralysis(mob/living/simple_animal/hostile/attacker, atom/target, success)
	SIGNAL_HANDLER

	if(!success || !iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	var/boost = 0

	var/list/items = infuriating_objects

	for(var/item_path in items)
		if(locate(item_path) in carbon_target.held_items)
			boost = anger_boost
			break

	if(prob(paralyze_prob + boost))
		carbon_target.Paralyze(paralyze_value + boost)
		carbon_target.visible_message(
			span_danger("[src] knocks down [carbon_target]!"),
			span_userdanger("[src] knocks you down!"),
		)

/datum/ai_controller/basic_controller/tree
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/tree,
		/datum/ai_planning_subtree/random_speech/tree,
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/tree
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/tree

/datum/ai_behavior/basic_melee_attack/tree
	action_cooldown = 2 SECONDS
