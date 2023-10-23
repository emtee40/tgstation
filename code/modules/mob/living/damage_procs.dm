
/**
 * Applies damage to this mob.
 *
 * Sends [COMSIG_MOB_APPLY_DAMAGE]
 *
 * Arguuments:
 * * damage - Amount of damage
 * * damagetype - What type of damage to do. one of [BRUTE], [BURN], [TOX], [OXY], [CLONE], [STAMINA], [BRAIN].
 * * def_zone - What body zone is being hit. Or a reference to what bodypart is being hit.
 * * blocked - Percent modifier to damage. 100 = 100% less damage dealt, 50% = 50% less damage dealt.
 * * forced - "Force" exactly the damage dealt. This means it skips damage modifier from blocked.
 * * spread_damage - For carbons, spreads the damage across all bodyparts rather than just the targeted zone.
 * * wound_bonus - Bonus modifier for wound chance.
 * * bare_wound_bonus - Bonus modifier for wound chance on bare skin.
 * * sharpness - Sharpness of the weapon.
 * * attack_direction - Direction of the attack from the attacker to [src].
 * * attacking_item - Item that is attacking [src].
 *
 * Returns the amount of damage dealt.
 */
/mob/living/proc/apply_damage(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	blocked = 0,
	forced = FALSE,
	spread_damage = FALSE,
	wound_bonus = 0,
	bare_wound_bonus = 0,
	sharpness = NONE,
	attack_direction = null,
	attacking_item,
)
	SHOULD_CALL_PARENT(TRUE)
	var/damage_amount = damage
	if(!forced)
		damage_amount *= ((100 - blocked) / 100)
		damage_amount *= get_incoming_damage_modifier(damage_amount, damagetype, def_zone, sharpness, attack_direction, attacking_item)
		if(damage_amount <= 0)
			return 0

	SEND_SIGNAL(src, COMSIG_MOB_APPLY_DAMAGE, damage_amount, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item)

	var/damage_dealt = 0
	switch(damagetype)
		if(BRUTE)
			if(isbodypart(def_zone))
				var/obj/item/bodypart/actual_hit = def_zone
				var/delta = actual_hit.get_damage()
				if(actual_hit.receive_damage(
					brute = damage_amount,
					burn = 0,
					wound_bonus = wound_bonus,
					bare_wound_bonus = bare_wound_bonus,
					sharpness = sharpness,
					attack_direction = attack_direction,
					damage_source = attacking_item,
				))
					update_damage_overlays()
				damage_dealt = delta - actual_hit.get_damage() // Unfortunately bodypart receive_damage doesn't return damage dealt so we do it manually
			else
				damage_dealt = adjustBruteLoss(damage_amount, forced = forced)
		if(BURN)
			if(isbodypart(def_zone))
				var/obj/item/bodypart/actual_hit = def_zone
				var/delta = actual_hit.get_damage()
				if(actual_hit.receive_damage(
					brute = 0,
					burn = damage_amount,
					wound_bonus = wound_bonus,
					bare_wound_bonus = bare_wound_bonus,
					sharpness = sharpness,
					attack_direction = attack_direction,
					damage_source = attacking_item,
				))
					update_damage_overlays()
				damage_dealt = delta - actual_hit.get_damage() // See above
			else
				damage_dealt = adjustFireLoss(damage_amount, forced = forced)
		if(TOX)
			damage_dealt = adjustToxLoss(damage_amount, forced = forced)
		if(OXY)
			damage_dealt = adjustOxyLoss(damage_amount, forced = forced)
		if(CLONE)
			damage_dealt = adjustCloneLoss(damage_amount, forced = forced)
		if(STAMINA)
			damage_dealt = adjustStaminaLoss(damage_amount, forced = forced)
		if(BRAIN)
			damage_dealt = adjustOrganLoss(ORGAN_SLOT_BRAIN, damage_amount)

	SEND_SIGNAL(src, COMSIG_MOB_AFTER_APPLY_DAMAGE, damage_dealt, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item)
	return damage_dealt

/**
 * Used in tandem with [proc/apply_damage] to calculate modifier applied into incoming damage
 */
/mob/living/proc/get_incoming_damage_modifier(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	sharpness = NONE,
	attack_direction = null,
	attacking_item,
)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)

	var/list/damage_mods = list()
	SEND_SIGNAL(src, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, attacking_item)

	var/final_mod = 1
	for(var/new_mod in damage_mods)
		final_mod *= new_mod
	return final_mod

///like [apply_damage][/mob/living/proc/apply_damage] except it always uses the damage procs
/mob/living/proc/apply_damage_type(damage = 0, damagetype = BRUTE)
	switch(damagetype)
		if(BRUTE)
			return adjustBruteLoss(damage)
		if(BURN)
			return adjustFireLoss(damage)
		if(TOX)
			return adjustToxLoss(damage)
		if(OXY)
			return adjustOxyLoss(damage)
		if(CLONE)
			return adjustCloneLoss(damage)
		if(STAMINA)
			return adjustStaminaLoss(damage)

/// return the damage amount for the type given
/mob/living/proc/get_current_damage_of_type(damagetype = BRUTE)
	switch(damagetype)
		if(BRUTE)
			return getBruteLoss()
		if(BURN)
			return getFireLoss()
		if(TOX)
			return getToxLoss()
		if(OXY)
			return getOxyLoss()
		if(CLONE)
			return getCloneLoss()
		if(STAMINA)
			return getStaminaLoss()

/// applies multiple damages at once via [/mob/living/proc/apply_damage]
/mob/living/proc/apply_damages(brute = 0, burn = 0, tox = 0, oxy = 0, clone = 0, def_zone = null, blocked = FALSE, stamina = 0, brain = 0)
	if(blocked >= 100)
		return 0
	if(brute)
		apply_damage(brute, BRUTE, def_zone, blocked)
	if(burn)
		apply_damage(burn, BURN, def_zone, blocked)
	if(tox)
		apply_damage(tox, TOX, def_zone, blocked)
	if(oxy)
		apply_damage(oxy, OXY, def_zone, blocked)
	if(clone)
		apply_damage(clone, CLONE, def_zone, blocked)
	if(stamina)
		apply_damage(stamina, STAMINA, def_zone, blocked)
	if(brain)
		apply_damage(brain, BRAIN, def_zone, blocked)
	return 1


/// applies various common status effects or common hardcoded mob effects
/mob/living/proc/apply_effect(effect = 0,effecttype = EFFECT_STUN, blocked = 0)
	var/hit_percent = (100-blocked)/100
	if(!effect || (hit_percent <= 0))
		return FALSE
	switch(effecttype)
		if(EFFECT_STUN)
			Stun(effect * hit_percent)
		if(EFFECT_KNOCKDOWN)
			Knockdown(effect * hit_percent)
		if(EFFECT_PARALYZE)
			Paralyze(effect * hit_percent)
		if(EFFECT_IMMOBILIZE)
			Immobilize(effect * hit_percent)
		if(EFFECT_UNCONSCIOUS)
			Unconscious(effect * hit_percent)

	return TRUE

/**
 * Applies multiple effects at once via [/mob/living/proc/apply_effect]
 *
 * Pretty much only used for projectiles applying effects on hit,
 * don't use this for anything else please just cause the effects directly
 */
/mob/living/proc/apply_effects(
		stun = 0,
		knockdown = 0,
		unconscious = 0,
		slur = 0 SECONDS, // Speech impediment, not technically an effect
		stutter = 0 SECONDS, // Ditto
		eyeblur = 0 SECONDS,
		drowsy = 0 SECONDS,
		blocked = 0, // This one's not an effect, don't be confused - it's block chance
		stamina = 0, // This one's a damage type, and not an effect
		jitter = 0 SECONDS,
		paralyze = 0,
		immobilize = 0,
	)

	if(blocked >= 100)
		return FALSE

	if(stun)
		apply_effect(stun, EFFECT_STUN, blocked)
	if(knockdown)
		apply_effect(knockdown, EFFECT_KNOCKDOWN, blocked)
	if(unconscious)
		apply_effect(unconscious, EFFECT_UNCONSCIOUS, blocked)
	if(paralyze)
		apply_effect(paralyze, EFFECT_PARALYZE, blocked)
	if(immobilize)
		apply_effect(immobilize, EFFECT_IMMOBILIZE, blocked)

	if(stamina)
		apply_damage(stamina, STAMINA, null, blocked)

	if(drowsy)
		adjust_drowsiness(drowsy)
	if(eyeblur)
		adjust_eye_blur(eyeblur)
	if(jitter && !check_stun_immunity(CANSTUN))
		adjust_jitter(jitter)
	if(slur)
		adjust_slurring(slur)
	if(stutter)
		adjust_stutter(stutter)

	return TRUE

/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/can_adjust_brute_loss(amount, forced, required_bodytype)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_LIVING_ADJUST_BRUTE_DAMAGE, BRUTE, amount, forced) & COMPONENT_IGNORE_CHANGE)
		return FALSE
	return TRUE

/mob/living/proc/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype = ALL)
	if (!can_adjust_brute_loss(amount, forced, required_bodytype))
		return 0
	. = bruteloss
	bruteloss = clamp((bruteloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	. -= bruteloss
	if(!.) // no change, no need to update
		return 0
	if(updating_health)
		updatehealth()


/mob/living/proc/setBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype = ALL)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	. = bruteloss
	bruteloss = amount

	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()
	. -= bruteloss

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/can_adjust_oxy_loss(amount, forced, required_biotype, required_respiration_type)
	if(!forced)
		if(status_flags & GODMODE)
			return FALSE
		if (required_respiration_type)
			var/obj/item/organ/internal/lungs/affected_lungs = get_organ_slot(ORGAN_SLOT_LUNGS)
			if(isnull(affected_lungs))
				if(!(mob_respiration_type & required_respiration_type))  // if the mob has no lungs, use mob_respiration_type
					return FALSE
			else
				if(!(affected_lungs.respiration_type & required_respiration_type)) // otherwise use the lungs' respiration_type
					return FALSE
	if(SEND_SIGNAL(src, COMSIG_LIVING_ADJUST_OXY_DAMAGE, OXY, amount, forced) & COMPONENT_IGNORE_CHANGE)
		return FALSE
	return TRUE

/mob/living/proc/adjustOxyLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype = ALL, required_respiration_type = ALL)
	if(!can_adjust_oxy_loss(amount, forced, required_biotype, required_respiration_type))
		return 0
	. = oxyloss
	oxyloss = clamp((oxyloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	. -= oxyloss
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

/mob/living/proc/setOxyLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype = ALL, required_respiration_type = ALL)
	if(!forced)
		if(status_flags & GODMODE)
			return FALSE

		var/obj/item/organ/internal/lungs/affected_lungs = get_organ_slot(ORGAN_SLOT_LUNGS)
		if(isnull(affected_lungs))
			if(!(mob_respiration_type & required_respiration_type))
				return FALSE
		else
			if(!(affected_lungs.respiration_type & required_respiration_type))
				return FALSE
	. = oxyloss
	oxyloss = amount
	. -= oxyloss
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/can_adjust_tox_loss(amount, forced, required_biotype = ALL)
	if(!forced && ((status_flags & GODMODE) || !(mob_biotypes & required_biotype)))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_LIVING_ADJUST_TOX_DAMAGE, TOX, amount, forced) & COMPONENT_IGNORE_CHANGE)
		return FALSE
	return TRUE

/mob/living/proc/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype = ALL)
	if(!can_adjust_tox_loss(amount, forced, required_biotype))
		return 0
	. = toxloss
	toxloss = clamp((toxloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	. -= toxloss
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

/mob/living/proc/setToxLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype = ALL)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(!forced && !(mob_biotypes & required_biotype))
		return FALSE
	. = toxloss
	toxloss = amount
	. -= toxloss
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/can_adjust_fire_loss(amount, forced, required_bodytype)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_LIVING_ADJUST_BURN_DAMAGE, BURN, amount, forced) & COMPONENT_IGNORE_CHANGE)
		return FALSE
	return TRUE

/mob/living/proc/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype = ALL)
	if(!can_adjust_fire_loss(amount, forced, required_bodytype))
		return 0
	. = fireloss
	fireloss = clamp((fireloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	. -= fireloss
	if(. == 0) // no change, no need to update
		return
	if(updating_health)
		updatehealth()

/mob/living/proc/setFireLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype = ALL)
	if(!forced && (status_flags & GODMODE))
		return 0
	. = fireloss
	fireloss = amount
	. -= fireloss
	if(. == 0) // no change, no need to update
		return 0
	if(updating_health)
		updatehealth()

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/can_adjust_clone_loss(amount, forced, required_biotype = ALL)
	if(!forced && (!(mob_biotypes & required_biotype) || status_flags & GODMODE || HAS_TRAIT(src, TRAIT_NOCLONELOSS)))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_LIVING_ADJUST_CLONE_DAMAGE, CLONE, amount, forced) & COMPONENT_IGNORE_CHANGE)
		return FALSE
	return TRUE

/mob/living/proc/adjustCloneLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype = ALL)
	if(!can_adjust_clone_loss(amount, forced, required_biotype))
		return 0
	. = cloneloss
	cloneloss = clamp((cloneloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	. -= cloneloss
	if(. == 0) // no change, no need to update
		return 0
	if(updating_health)
		updatehealth()

/mob/living/proc/setCloneLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype = ALL)
	if(!forced && ( (status_flags & GODMODE) || HAS_TRAIT(src, TRAIT_NOCLONELOSS)) )
		return FALSE
	if(!forced && !(mob_biotypes & required_biotype))
		return FALSE
	. = cloneloss
	cloneloss = amount
	. -= cloneloss
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

/mob/living/proc/adjustOrganLoss(slot, amount, maximum, required_organ_flag)
	return

/mob/living/proc/setOrganLoss(slot, amount, maximum, required_organ_flag)
	return

/mob/living/proc/get_organ_loss(slot)
	return

/mob/living/proc/getStaminaLoss()
	return staminaloss

/mob/living/proc/can_adjust_stamina_loss(amount, forced, required_biotype = ALL)
	if(!forced && (!(mob_biotypes & required_biotype) || status_flags & GODMODE))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE, STAMINA, amount, forced) & COMPONENT_IGNORE_CHANGE)
		return FALSE
	return TRUE

/mob/living/proc/adjustStaminaLoss(amount, updating_stamina = TRUE, forced = FALSE, required_biotype = ALL)
	if(!can_adjust_stamina_loss(amount, forced, required_biotype))
		return 0
	. = staminaloss
	staminaloss = clamp((staminaloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, max_stamina)
	. -= staminaloss
	if(. == 0) // no change, no need to update
		return 0
	if(updating_stamina)
		updatehealth()

/mob/living/proc/setStaminaLoss(amount, updating_stamina = TRUE, forced = FALSE, required_biotype = ALL)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(!forced && !(mob_biotypes & required_biotype))
		return FALSE
	. = staminaloss
	staminaloss = amount
	. -= staminaloss
	if(!.) // no change, no need to update
		return FALSE
	if(updating_stamina)
		updatehealth()

/**
 * heal ONE external organ, organ gets randomly selected from damaged ones.
 *
 * returns the net change in damage
 */
/mob/living/proc/heal_bodypart_damage(brute = 0, burn = 0, updating_health = TRUE, required_bodytype = NONE, target_zone = null)
	. = (adjustBruteLoss(-abs(brute), updating_health = FALSE) + adjustFireLoss(-abs(burn), updating_health = FALSE))
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

/// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_bodypart_damage(brute = 0, burn = 0, updating_health = TRUE, required_bodytype, check_armor = FALSE, wound_bonus = 0, bare_wound_bonus = 0, sharpness = NONE)
	. = (adjustBruteLoss(abs(brute), updating_health = FALSE) + adjustFireLoss(abs(burn), updating_health = FALSE))
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

/// heal MANY bodyparts, in random order. note: stamina arg nonfunctional for carbon mobs
/mob/living/proc/heal_overall_damage(brute = 0, burn = 0, stamina = 0, required_bodytype, updating_health = TRUE, forced = FALSE)
	. = (adjustBruteLoss(-abs(brute), updating_health = FALSE, forced = forced) + \
			adjustFireLoss(-abs(burn), updating_health = FALSE, forced = forced) + \
			adjustStaminaLoss(-abs(stamina), updating_stamina = FALSE, forced = forced))
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

/// damage MANY bodyparts, in random order. note: stamina arg nonfunctional for carbon mobs
/mob/living/proc/take_overall_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, forced = FALSE, required_bodytype)
	. = (adjustBruteLoss(abs(brute), updating_health = FALSE, forced = forced) + \
			adjustFireLoss(abs(burn), updating_health = FALSE, forced = forced) + \
			adjustStaminaLoss(abs(stamina), updating_stamina = FALSE, forced = forced))
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

///heal up to amount damage, in a given order
/mob/living/proc/heal_ordered_damage(amount, list/damage_types)
	. = FALSE //we'll return the amount of damage healed
	for(var/damagetype in damage_types)
		var/amount_to_heal = min(abs(amount), get_current_damage_of_type(damagetype)) //heal only up to the amount of damage we have
		if(amount_to_heal)
			. += apply_damage_type(-amount_to_heal, damagetype)
			amount -= amount_to_heal //remove what we healed from our current amount
		if(!amount)
			break
