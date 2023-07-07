///prototype for mining mobs
/mob/living/basic/mining
	combat_mode = TRUE
	faction = list(FACTION_MINING)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	// Pale purple, should be red enough to see stuff on lavaland
	lighting_cutoff_red = 25
	lighting_cutoff_green = 15
	lighting_cutoff_blue = 35
	/// What crusher trophy this mob drops, if any
	var/crusher_loot
	/// What is the chance the mob drops it if all their health was taken by crusher attacks
	var/crusher_drop_chance = 25

/mob/living/basic/mining/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE), INNATE_TRAIT)
	AddElement(/datum/element/mob_killed_tally, "mobs_killed_mining")
	AddElement(\
		/datum/element/ranged_armour,\
		minimum_projectile_force = 30,\
		below_projectile_multiplier = 0.3,\
		vulnerable_projectile_types = MINING_MOB_PROJECTILE_VULNERABILITY,\
		minimum_thrown_force = 20,\
	)
	if(crusher_loot)
		AddElement(\
			/datum/element/crusher_loot,\
			trophy_type = crusher_loot,\
			drop_mod = crusher_drop_chance,\
			drop_immediately = basic_mob_flags & DEL_ON_DEATH\
		)
