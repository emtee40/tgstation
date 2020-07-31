/obj/item/skillchip
	name = "skillchip"
	desc = "This biochip integrates with user's brain to enable mastery of specific skill. Consult certified Nanotrasen neurosurgeon before use."

	icon = 'icons/obj/card.dmi'
	icon_state = "data_3"
	custom_price = 500
	w_class = WEIGHT_CLASS_SMALL

	/// Trait automatically granted by this chip, optional
	var/auto_trait
	/// Skill name shown on UI
	var/skill_name
	/// Skill description shown on UI
	var/skill_description
	/// Fontawesome icon show on UI, list of possible icons https://fontawesome.com/icons?d=gallery&m=free
	var/skill_icon = "brain"
	/// Message shown when implanting the chip
	var/implanting_message
	/// Message shown when extracting the chip
	var/removal_message
	//If set to TRUE, trying to extract the chip will destroy it instead
	var/removable = TRUE
	/// How many skillslots this one takes
	var/slot_cost = 1
	/// Variable for flags
	var/skillchip_flags = NONE
	/// Cooldown before the skillchip can be extracted after it has been implanted.
	var/cooldown = 5 MINUTES
	/// The world.time when this skillchip should be extractable.
	var/extractable_at = 0

/// Called after implantation and/or brain entering new body
/obj/item/skillchip/proc/on_apply(mob/living/carbon/user,silent=TRUE)
	if(!silent && implanting_message)
		to_chat(user,implanting_message)
	if(auto_trait)
		ADD_TRAIT(user,auto_trait,SKILLCHIP_TRAIT)
	user.used_skillchip_slots += slot_cost

	extractable_at = world.time + cooldown

/// Called after removal and/or brain exiting the body
/obj/item/skillchip/proc/on_removal(mob/living/carbon/user,silent=TRUE)
	if(!silent && removal_message)
		to_chat(user,removal_message)
	if(auto_trait)
		REMOVE_TRAIT(user,auto_trait,SKILLCHIP_TRAIT)
	user.used_skillchip_slots -= slot_cost

	extractable_at = 0

/**
  * Checks for skillchip incompatibility with other installed chips.
  *
  * Returns all incompatible flags to be parsed by the calling proc.
  * Arguments:
  * * skillchip - The skillchip to test for implantability.
  */
/obj/item/skillchip/proc/check_incompatibility(obj/item/skillchip/skillchip)
	var/incompatible_flags = 0

	// If this is a SKILLCHIP_JOB_TYPE it is incompatible with any other SKILLCHIP_JOB_TYPE.
	if((skillchip_flags & SKILLCHIP_JOB_TYPE) && (skillchip.skillchip_flags & SKILLCHIP_JOB_TYPE))
		incompatible_flags |= SKILLCHIP_JOB_TYPE

	// Only allow multiple copies of a type if SKILLCHIP_ALLOWS_MULTIPLE flag is set
	if(!(skillchip_flags & SKILLCHIP_ALLOWS_MULTIPLE) && (istype(skillchip, type)))
		incompatible_flags |= SKILLCHIP_ALLOWS_MULTIPLE

	return incompatible_flags

/**
  * Intended to be overridden. Returns whether the chip is in an implantable state.
  *
  * Returns TRUE if the chip is in an implantable state.
  */
/obj/item/skillchip/proc/can_implant()
	return TRUE

/**
  * Returns whether the chip is able to be removed safely.
  *
  * This does not mean the chip should be impossible to remove. It's up to each individual
  * piece of code to decide what it does with the result of this proc.
  *
  * Returns FALSE if the chip's extraction cooldown hasn't yet passed.
  */
/obj/item/skillchip/proc/can_remove_safely()
	if(extractable_at > world.time)
		return FALSE

	return TRUE

/obj/item/skillchip/basketweaving
	name = "Basketsoft 3000 skillchip"
	desc = "Underwater edition."
	auto_trait = TRAIT_UNDERWATER_BASKETWEAVING_KNOWLEDGE
	skill_name = "Underwater Basketweaving"
	skill_description = "Master intricate art of using twine to create perfect baskets while submerged."
	skill_icon = "shopping-basket"
	implanting_message = "<span class='notice'>You're one with the twine and the sea.</span>"
	removal_message = "<span class='notice'>Higher mysteries of underwater basketweaving leave your mind.</span>"

/obj/item/skillchip/wine_taster
	name = "WINE skillchip"
	desc = "Wine.Is.Not.Equal version 5."
	auto_trait = TRAIT_WINE_TASTER
	skill_name = "Wine Tasting"
	skill_description = "Recognize wine vintage from taste alone. Never again lack an opinion when presented with an unknown drink."
	skill_icon = "wine-bottle"
	implanting_message = "<span class='notice'>You recall wine taste.</span>"
	removal_message = "<span class='notice'>Your memories of wine evaporate.</span>"

/obj/item/skillchip/bonsai
	name = "Hedge 3 skillchip"
	auto_trait = TRAIT_BONSAI
	skill_name = "Hedgetrimming"
	skill_description = "Trim hedges and potted plants into marvelous new shapes with any old knife. Not applicable to plastic plants."
	skill_icon = "spa"
	implanting_message = "<span class='notice'>Your mind is filled with plant arrangments.</span>"
	removal_message = "<span class='notice'>Your can't remember how a hedge looks like anymore.</span>"

/obj/item/skillchip/useless_adapter
	name = "Skillchip adapter"
	skill_name = "Useless adapter"
	skill_description = "Allows you to insert another identical skillchip into this adapter, but the adapter also takes a slot ..."
	skill_icon = "plug"
	implanting_message = "<span class='notice'>You can now implant another chip into this adapter, but the adapter also took up an existing slot ...</span>"
	removal_message = "<span class='notice'>You no longer have the useless skillchip adapter.</span>"
	skillchip_flags = SKILLCHIP_ALLOWS_MULTIPLE
	slot_cost = 0

/obj/item/skillchip/useless_adapter/on_apply(mob/living/carbon/user, silent)
	. = ..()
	user.max_skillchip_slots++
	user.used_skillchip_slots++

/obj/item/skillchip/useless_adapter/on_removal(mob/living/carbon/user, silent)
	user.max_skillchip_slots--
	user.used_skillchip_slots--
	return ..()
