/datum/surgery/advanced/bioware/nerve_grounding
	name = "Nerve Grounding"
	desc = "A surgical procedure which makes the patient's nerves act as grounding rods, protecting them from electrical shocks."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/ground_nerves,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_NERVES

/datum/surgery_step/ground_nerves
	name = "ground nerves"
	accept_hand = TRUE
	time = 155

/datum/surgery_step/ground_nerves/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
<<<<<<< HEAD
	display_results(user, target, "<span class='notice'>You start rerouting [target]'s nerves.</span>",
		"[user] starts rerouting [target]'s nerves.",
		"[user] starts manipulating [target]'s nervous system.")

/datum/surgery_step/ground_nerves/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You successfully reroute [target]'s nervous system!</span>",
		"[user] successfully reroutes [target]'s nervous system!",
		"[user] finishes manipulating [target]'s nervous system.")
=======
	user.visible_message("[user] starts splicing together [target]'s nerves.", "<span class='notice'>You start splicing together [target]'s nerves.</span>")

/datum/surgery_step/ground_nerves/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] successfully splices [target]'s nervous system!", "<span class='notice'>You successfully splice [target]'s nervous system!</span>")
>>>>>>> Updated this old code to fork
	new /datum/bioware/grounded_nerves(target)
	return TRUE

/datum/bioware/grounded_nerves
	name = "Grounded Nerves"
	desc = "Nerves form a safe path for electricity to traverse, protecting the body from electric shocks."
	mod_type = BIOWARE_NERVES
<<<<<<< HEAD

/datum/bioware/grounded_nerves/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, "grounded_nerves")

/datum/bioware/grounded_nerves/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, "grounded_nerves")
=======
	var/prev_coeff

/datum/bioware/grounded_nerves/on_gain()
	..()
	prev_coeff = owner.physiology.siemens_coeff
	owner.physiology.siemens_coeff = 0

/datum/bioware/grounded_nerves/on_lose()
	..()
	owner.physiology.siemens_coeff = prev_coeff
>>>>>>> Updated this old code to fork
