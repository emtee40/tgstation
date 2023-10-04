/datum/antagonist/survivalist
	name = "\improper Survivalist"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	suicide_cry = "FOR MYSELF!!"
	var/greet_message = ""

/datum/antagonist/survivalist/forge_objectives()
	var/datum/objective/survive/survive = new
	survive.owner = owner
	objectives += survive

/datum/antagonist/survivalist/on_gain()
	owner.special_role = "survivalist"
	forge_objectives()
	. = ..()

/datum/antagonist/survivalist/greet()
	. = ..()
	to_chat(owner, "<B>[greet_message]</B>")
	owner.announce_objectives()

/datum/antagonist/survivalist/guns
	greet_message = "Your own safety matters above all else, and the only way to ensure your safety is to stockpile weapons! Grab as many guns as possible, by any means necessary. Kill anyone who gets in your way."
	hardcore_random_bonus = TRUE

/datum/antagonist/survivalist/guns/forge_objectives()
	var/datum/objective/steal_n_of_type/summon_guns/guns = new
	guns.owner = owner
	objectives += guns
	..()

/datum/antagonist/survivalist/magic
	name = "Amateur Magician"
	greet_message = "Grow your newfound talent! Grab as many magical artefacts as possible, by any means necessary. Kill anyone who gets in your way."
	hardcore_random_bonus = TRUE

/datum/antagonist/survivalist/magic/greet()
	. = ..()
	to_chat(owner, span_notice("As a wonderful magician, you should remember that spellbooks don't mean anything if they are used up."))

/datum/antagonist/survivalist/magic/forge_objectives()
	var/datum/objective/steal_n_of_type/summon_magic/magic = new
	magic.owner = owner
	objectives += magic
	..()

/datum/antagonist/survivalist/magic/on_gain()
	. = ..()
	ADD_TRAIT(owner, TRAIT_MAGICALLY_GIFTED, REF(src))

/datum/antagonist/survivalist/magic/on_removal()
	REMOVE_TRAIT(owner, TRAIT_MAGICALLY_GIFTED, REF(src))
	return..()
