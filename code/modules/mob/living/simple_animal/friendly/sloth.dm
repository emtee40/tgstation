/mob/living/simple_animal/sloth
	name = "sloth"
	desc = "An adorable, sleepy creature."
	icon = 'icons/mob/pets.dmi'
	icon_state = "sloth"
	icon_living = "sloth"
	icon_dead = "sloth_dead"
	speak_emote = list("yawns")
	emote_hear = list("snores.","yawns.")
	emote_see = list("dozes off.", "looks around sleepily.")
	speak_chance = 1
	turns_per_move = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	melee_damage_lower = 18
	melee_damage_upper = 18
	health = 50
	maxHealth = 50
	speed = 10
	glide_size = 2
	held_state = "sloth"

	footstep_type = FOOTSTEP_MOB_CLAW


//Cargo Sloth
/mob/living/simple_animal/sloth/paperwork
	name = "Paperwork"
	desc = "Cargo's pet sloth. About as useful as the rest of the techs."
	gold_core_spawnable = NO_SPAWN

//Cargo Sloth 2

/mob/living/simple_animal/sloth/citrus
	name = "Citrus"
	desc = "Cargo's pet sloth. She's dressed in a horrible sweater."
	icon_state = "cool_sloth"
	icon_living = "cool_sloth"
	icon_dead = "cool_sloth_dead"
	gender = FEMALE
	butcher_results = list(/obj/item/toy/spinningtoy = 1)
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/sloth/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if("help")
			wuv(1,M)
		if("harm")
			wuv(-1,M)


/mob/living/simple_animal/sloth/proc/wuv(change, mob/M)
	if(change)
		if(change > 0)
			if(M && stat != DEAD)
				new /obj/effect/temp_visual/heart(loc)
				emote("me", 1, "slowly smiles!")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, src, /datum/mood_event/pet_animal, src)
		else
			if(M && stat != DEAD) // Same check here, even though emote checks it as well (poor form to check it only in the help case)
				emote("me", 1, "slowly frowns!")
