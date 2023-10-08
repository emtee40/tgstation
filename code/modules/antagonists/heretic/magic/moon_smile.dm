/datum/action/cooldown/spell/pointed/moon_smile
	name = "Smile of the moon"
	desc = "Lets you turn the gaze of the moon on someone \
			temporarily blinding, muting, deafening and confusing a single target."
	button_icon_state = "blind"
	ranged_mousepointer = 'icons/effects/mouse_pointers/moon_target.dmi'

	sound = 'sound/magic/blind.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS

	invocation = "Mo'N S'M'LE"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	cast_range = 6



	active_msg = "You prepare to let them see the true face..."

/datum/action/cooldown/spell/pointed/moon_smile/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)

/datum/action/cooldown/spell/pointed/moon_smile/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/moon_smile/cast(mob/living/carbon/human/cast_on)
	. = ..()
	var/moon_smile_duration = (120-cast_on.mob_mood.sanity)/10
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("The moon turns, its smile no longer set on you."))
		to_chat(owner, span_warning("The moon does not smile upon them."))
		return FALSE

	playsound(cast_on, 'sound/hallucinations/i_see_you1.ogg', 50, 1)
	to_chat(cast_on, span_warning("Your eyes cry out in pain, your ears bleed and your lips seal! THE MOON SMILES UPON YOU!"))
	cast_on.adjust_temp_blindness(moon_smile_duration SECONDS)
	cast_on.set_eye_blur_if_lower(moon_smile_duration + 2 SECONDS)
	var/obj/item/organ/internal/ears/ears = cast_on.get_organ_slot(ORGAN_SLOT_EARS)
	ears?.adjustEarDamage(0, moon_smile_duration)
	cast_on.adjust_silence(moon_smile_duration SECONDS)
	cast_on.add_mood_event("moon_smile", /datum/mood_event/moon_smile)
	//Lowers sanity
	cast_on.mob_mood.set_sanity(cast_on.mob_mood.sanity - 20)
	return TRUE
