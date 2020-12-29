#define DEFAULT_TASTE_SENSITIVITY 15

/mob/living
	var/last_taste_time
	var/last_taste_text

/*
* Returns whether a given mob is capable of tasting flavour.
*/
/mob/living/proc/can_taste()
	return !HAS_TRAIT(src, TRAIT_AGEUSIA)

/*
* Overrides the carbon tasting by also checking that the carbon
* has a tongue. The absence of a tongue will prevent the carbon
* mob from tasting.
*/
/mob/living/carbon/can_taste()
	var/obj/item/organ/tongue/tongue = getorganslot(ORGAN_SLOT_TONGUE)
	return ..() && istype(tongue)

/*
* Gets the "taste_sensitivity" of a given mob. This is used in calculating
* what flavours the mob can pick up, with a lower number closer to 0
* being better.
*/
/mob/living/proc/get_taste_sensitivity()
	return DEFAULT_TASTE_SENSITIVITY

/mob/living/carbon/get_taste_sensitivity()
	var/obj/item/organ/tongue/tongue = getorganslot(ORGAN_SLOT_TONGUE)
	if(istype(tongue))
		. = tongue.taste_sensitivity
	else
		// never normally reach this point without a tongue, but sensible fallback
		. = DEFAULT_TASTE_SENSITIVITY

// non destructively tastes a reagent container
/mob/living/proc/taste(datum/reagents/from)
	if(!can_taste())
		return

	var/taste_sensitivity = get_taste_sensitivity()

	if(last_taste_time + 50 < world.time)
		var/text_output = from.generate_taste_message(src, taste_sensitivity)
		// We dont want to spam the same message over and over again at the
		// person. Give it a bit of a buffer.
		if(hallucination > 50 && prob(25))
			text_output = pick("spiders","dreams","nightmares","the future","the past","victory",\
			"defeat","pain","bliss","revenge","poison","time","space","death","life","truth","lies","justice","memory",\
			"regrets","your soul","suffering","music","noise","blood","hunger","the american way")
		if(text_output != last_taste_text || last_taste_time + 100 < world.time)
			to_chat(src, "<span class='notice'>You can taste [text_output].</span>")
			// "something indescribable" -> too many tastes, not enough flavor.

			last_taste_time = world.time
			last_taste_text = text_output

#undef DEFAULT_TASTE_SENSITIVITY
