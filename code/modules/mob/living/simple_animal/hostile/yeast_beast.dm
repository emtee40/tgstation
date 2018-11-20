/mob/living/simple_animal/hostile/yeast_beast
	name = "yeast beast"
	desc = "Full of flour power, a teleporter accident turned this once normal loaf into a real baked bastard."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "bread"
	icon_living = "bread"
	icon_dead = "bread"
	gender = NEUTER
	mob_biotypes = list(MOB_ORGANIC)
	emote_hear = list("crunches.")
	emote_see = list("loafs around.", "rolls.", "kneads the ground.")
	butcher_results = list(/obj/item/reagent_containers/food/snacks/breadslice/yeast_beast = 4)
	response_help = "kneads"
	response_disarm = "rolls"
	response_harm = "batters"
	emote_taunt = list("rises", "rolls")
	taunt_chance = 30
	maxHealth = 10
	health = 10
	harm_intent_damage = 5
	obj_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "bites"
	faction = list("hostile")
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("oozes")
	gold_core_spawnable = NO_SPAWN
	death_sound = 'sound/misc/splort.ogg'
	deathmessage = "crumples to the ground, green dough oozing from its maw."
