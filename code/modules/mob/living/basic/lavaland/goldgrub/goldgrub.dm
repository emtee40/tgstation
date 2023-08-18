//An ore-devouring but easily scared creature
/mob/living/basic/mining/goldgrub
	name = "goldgrub"
	desc = "A worm that grows fat from eating everything in its sight. Seems to enjoy precious metals and other shiny things, hence the name."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters_wide.dmi'
	icon_state = "goldgrub"
	icon_living = "goldgrub"
	icon_dead = "goldgrub_dead"
	icon_gib = "syndicate_gib"
	speed = 5
	pixel_x = -12
	base_pixel_x = -12
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	friendly_verb_continuous = "harmlessly rolls into"
	friendly_verb_simple = "harmlessly roll into"
	maxHealth = 45
	health = 45
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_verb_continuous = "barrels into"
	attack_verb_simple = "barrel into"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = FALSE
	speak_emote = list("screeches")
	death_message = "stops moving as green liquid oozes from the carcass!"
	status_flags = CANPUSH
	gold_core_spawnable = HOSTILE_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/goldgrub
	///can this mob lay eggs
	var/can_lay_eggs = TRUE
	///can we tame this mob
	var/can_tame = TRUE
	//pet commands when we tame the grub
	var/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/grub_spit,
		/datum/pet_command/follow,
		/datum/pet_command/point_targetting/fetch
	)

/mob/living/basic/mining/goldgrub/Initialize(mapload)
	. = ..()
	if(can_tame)
		make_tameable()
	if(can_lay_eggs)
		make_egg_layer()
	generate_loot()
	var/datum/action/cooldown/mob_cooldown/spit_ore/spit = new(src)
	var/datum/action/cooldown/mob_cooldown/burrow/burrow = new(src)
	AddComponent(/datum/component/appearance_on_aggro, overlay_icon = icon, overlay_state = "[icon_state]_alert")
	AddElement(/datum/element/wall_smasher)
	AddComponent(/datum/component/ai_listen_to_weather)
	spit.Grant(src)
	burrow.Grant(src)
	ai_controller.set_blackboard_key(BB_SPIT_ABILITY, spit)
	ai_controller.set_blackboard_key(BB_BURROW_ABILITY, burrow)

/mob/living/basic/mining/goldgrub/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()
	if(!.)
		return

	if(!proximity_flag)
		return

	if(istype(attack_target, /obj/item/stack/ore))
		consume_ore(attack_target)

/mob/living/basic/mining/goldgrub/bullet_act(obj/projectile/bullet)
	if(stat == DEAD)
		return BULLET_ACT_FORCE_PIERCE
	else
		visible_message(span_danger("The [bullet.name] is repelled by [src]'s girth!"))
		return BULLET_ACT_BLOCK

/mob/living/basic/mining/goldgrub/proc/barf_contents()
	visible_message(span_danger("[src] spits out its consumed ores!"))
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
	for(var/obj/item/ore as anything in src)
		ore.forceMove(loc)

/mob/living/basic/mining/goldgrub/proc/generate_loot()
	var/loot_amount = rand(1,3)
	var/list/weight_lootdrops = list(
		/obj/item/stack/ore/silver = 4,
		/obj/item/stack/ore/gold = 3,
		/obj/item/stack/ore/uranium = 3,
		/obj/item/stack/ore/diamond = 1,
	)
	var/list/death_loot = list()
	for(var/i in 1 to loot_amount)
		death_loot += pick_weight(weight_lootdrops)
	AddElement(/datum/element/death_drops, death_loot)

/mob/living/basic/mining/goldgrub/death(gibbed)
	barf_contents()
	return ..()

/mob/living/basic/mining/goldgrub/proc/make_tameable()
	AddComponent(\
		/datum/component/tameable,\
		food_types = list(/obj/item/stack/ore),\
		tame_chance = 25,\
		bonus_tame_chance = 5,\
		after_tame = CALLBACK(src, PROC_REF(tame_grub)),\
	)

/mob/living/basic/mining/goldgrub/proc/tame_grub()
	new /obj/effect/temp_visual/heart(src.loc)
	AddElement(/datum/element/ridable, /datum/component/riding/creature/goldgrub)
	AddComponent(/datum/component/obeys_commands, pet_commands)

/mob/living/basic/mining/goldgrub/proc/make_egg_layer()
	AddComponent(\
		/datum/component/egg_layer,\
		/obj/item/food/egg/green/grub_egg,\
		list(/obj/item/stack/ore/bluespace_crystal),\
		lay_messages = EGG_LAYING_MESSAGES,\
		eggs_left = 0,\
		eggs_added_from_eating = 1,\
		max_eggs_held = 1,\
		egg_laid_callback = CALLBACK(src, PROC_REF(lay_grub_egg)),\
	)

/mob/living/basic/mining/goldgrub/proc/lay_grub_egg(obj/item/grub_egg)
	if(prob(1))
		return
	grub_egg.AddComponent(\
		/datum/component/fertile_egg,\
		embryo_type = /mob/living/basic/mining/goldgrub/baby,\
		minimum_growth_rate = 1,\
		maximum_growth_rate = 2,\
		total_growth_required = 100,\
		current_growth = 0,\
		location_allowlist = typecacheof(list(/turf)),\
	)

/mob/living/basic/mining/goldgrub/proc/consume_ore(obj/item/target_ore)
	playsound(src.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	target_ore.forceMove(src)

/mob/living/basic/mining/goldgrub/baby
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "grub_baby"
	icon_living = "grub_baby"
	icon_dead = "grub_baby_dead"
	speed = 3
	maxHealth = 25
	health = 25
	gold_core_spawnable = NO_SPAWN
	can_tame = FALSE
	ai_controller = /datum/ai_controller/basic_controller/babygrub

/mob/living/basic/mining/goldgrub/baby/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/growth_and_differentiation,\
		growth_time = null,\
		growth_path = /mob/living/basic/mining/goldgrub,\
		growth_probability = 100,\
		lower_growth_value = 0.5,\
		upper_growth_value = 1,\
		signals_to_kill_on = list(COMSIG_MOB_CLIENT_LOGIN),\
		optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
	)

/mob/living/basic/mining/goldgrub/baby/proc/ready_to_grow()
	return (stat == CONSCIOUS)

/obj/item/food/egg/green/grub_egg
	name = "grub egg"
	desc = "Covered in disgusting fluid."
