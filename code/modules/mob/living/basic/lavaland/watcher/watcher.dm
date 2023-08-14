/// A floating eyeball which keeps its distance and plays red light/green light with you.
/mob/living/basic/mining/watcher
	name = "watcher"
	desc = "A levitating, monocular creature held aloft by wing-like veins. A sharp spine of crystal protrudes from its body."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters_wide.dmi'
	icon_state = "watcher"
	icon_living = "watcher"
	icon_dead = "watcher_dead"
	health_doll_icon = "watcher"
	pixel_x = -12
	base_pixel_x = -12
	speak_emote = list("chimes")
	speed = 3
	maxHealth = 200
	health = 200
	attack_verb_continuous = "buffets"
	attack_verb_simple = "buffet"
	crusher_loot = /obj/item/crusher_trophy/watcher_wing
	ai_controller = /datum/ai_controller/basic_controller/watcher
	butcher_results = list(
		/obj/item/stack/sheet/bone = 1,
		/obj/item/stack/ore/diamond = 2,
		/obj/item/stack/sheet/sinew = 2,
	)
	/// How often can we shoot?
	var/ranged_cooldown = 3 SECONDS
	/// What kind of beams we got?
	var/projectile_type = /obj/projectile/temp/watcher
	/// Icon state for our eye overlay
	var/eye_glow = "ice_glow"
	/// Sound to play when we shoot
	var/shoot_sound = 'sound/weapons/pierce.ogg'
	// TODO: hunts pens and diamonds for some reason
	var/wanted_objects = list(/obj/item/pen/survival, /obj/item/stack/ore/diamond)

/mob/living/basic/mining/watcher/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddComponent(/datum/component/basic_ranged_ready_overlay, overlay_state = eye_glow)
	AddComponent(/datum/component/ranged_attacks, cooldown_time = ranged_cooldown, projectile_type = projectile_type, projectile_sound = shoot_sound)
	update_appearance(UPDATE_OVERLAYS)

	var/datum/action/cooldown/watcher_overwatch/overwatch = new(src)
	overwatch.Grant(src)
	overwatch.projectile_type = projectile_type
	ai_controller.set_blackboard_key(BB_TARGETTED_ACTION, overwatch)

/mob/living/basic/mining/watcher/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "watcher_emissive", src)

/// For map generation, has a chance to instantiate as a special subtype
/mob/living/basic/mining/watcher/random

/mob/living/basic/mining/watcher/random/Initialize(mapload)
	. = ..()
	if(prob(99))
		return
	if(prob(75))
		new /mob/living/basic/mining/watcher/magmawing(loc)
	else
		new /mob/living/basic/mining/watcher/icewing(loc)
	return INITIALIZE_HINT_QDEL

/// More durable, burning projectiles
/mob/living/basic/mining/watcher/magmawing
	name = "magmawing watcher"
	desc = "Presented with extreme temperatures, adaptive watchers absorb heat through their circulatory wings and repurpose it as a weapon."
	icon_state = "watcher_magmawing"
	icon_living = "watcher_magmawing"
	icon_dead = "watcher_magmawing_dead"
	eye_glow = "fire_glow"
	maxHealth = 215 //Compensate for the lack of slowdown on projectiles with a bit of extra health
	health = 215
	projectile_type = /obj/projectile/temp/watcher/magmawing
	crusher_loot = /obj/item/crusher_trophy/blaster_tubes/magma_wing
	crusher_drop_chance = 100 // There's only going to be one of these per round throw them a bone

/// Less durable, freezing projectiles
/mob/living/basic/mining/watcher/icewing
	name = "icewing watcher"
	desc = "Watchers which fail to absorb enough heat during their development become fragile, but share their internal chill with their enemies."
	icon_state = "watcher_icewing"
	icon_living = "watcher_icewing"
	icon_dead = "watcher_icewing_dead"
	maxHealth = 170
	health = 170
	projectile_type = /obj/projectile/temp/watcher/icewing
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/bone = 1)
	crusher_loot = /obj/item/crusher_trophy/watcher_wing/ice_wing
	crusher_drop_chance = 100
