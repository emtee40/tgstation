// Sidepaths for knowledge between Knock and Moon.

/datum/heretic_knowledge/spell/mind_gate
	name = "Mind Gate"
	desc = "Grants you Mind Gate, a spell \
		which deals you 20 brain damage but the target suffers a hallucination, is left confused for 10 seconds and takes 30 brain damage."
	gain_text = "My mind swings open like a gate, and its insight will let me percieve the truth."
	next_knowledge = list(
		/datum/heretic_knowledge/key_ring,
		/datum/heretic_knowledge/spell/moon_smile,
	)
	spell_to_add = /datum/action/cooldown/spell/pointed/mind_gate
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/unfathomable_curio
	name = "Unfathomable Curio"
	desc = "Allows you to transmute 3 rods, a brain and a belt into an Unfathomable Curio\
			, a belt that can hold blades and items for rituals. Whilst worn will also \
			veil you, allowing you to take 5 hits without suffering damage, this veil will recharge very slowly \
			outside of combat. When examined the examiner will suffer brain damage and blindness."
	gain_text = "The manus holds many a curio, some are not meant for the mortal eye."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/burglar_finesse,
		/datum/heretic_knowledge/spell/moon_parade,
	)
	required_atoms = list(
		/obj/item/organ/internal/brain = 1,
		/obj/item/stack/rods = 3,
		/obj/item/storage/belt = 1,
	)
	result_atoms = list(/obj/item/storage/belt/unfathomable_curio)
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/painting
	name = "Glimmering Arts"
	desc = "Allows you to transmute a canvas and an additional item to create a piece of art, these paintings \
			have different effects depending on the additional item added. Possible paintings:"
	gain_text = "A wind of inspiration blows through me, past the walls and past the gate inspirations lie, yet to be depicted. \
				They yearn for mortal eyes again, and I shall grant that wish."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/burglar_finesse,
		/datum/heretic_knowledge/spell/moon_parade,
	)
	required_atoms = list(
		/obj/item/canvas = 1,
	)
	result_atoms = list(/obj/item/canvas)
	optional_atoms = list(
		/obj/item/organ/internal/eyes = 1,
		/obj/item/bodypart = 1,
		/obj/item/trash = 1,
		/obj/item/food/grown = 1,
		/obj/item/clothing/gloves = 1,
	)
	optional_result_atoms = list(/obj/item/canvas)
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/painting/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc, list/optional_selected_atoms)
	if(!length(result_atoms))
		return FALSE

	// List comparison
	if(length(optional_selected_atoms))
		for(var/optional_atoms in optional_selected_atoms)
			if(optional_atoms == /obj/item/organ/internal/eyes)
				new /obj/item/wallframe/painting/eldritch(loc)
				continue
			if(optional_atoms == /obj/item/bodypart)
				new /obj/item/wallframe/painting/eldritch/desire(loc)
				continue
			if(optional_atoms == /obj/item/trash)
				new /obj/item/wallframe/painting/eldritch(loc)
				continue
			if(optional_atoms == /obj/item/food/grown)
				new /obj/item/wallframe/painting/eldritch(loc)
				continue
			if(optional_atoms == /obj/item/clothing/gloves)
				new /obj/item/wallframe/painting/eldritch(loc)
				continue
	else
		for(var/result in result_atoms)
			new result(loc)
	return TRUE
