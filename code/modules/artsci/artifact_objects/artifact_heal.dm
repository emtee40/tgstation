/obj/structure/artifact/heal
	assoc_comp = /datum/component/artifact/heal

/datum/component/artifact/heal
	associated_object = /obj/structure/artifact/heal
	weight = ARTIFACT_VERYUNCOMMON
	type_name = "Single Healer"
	activation_message = "starts emitting a soothing aura!"
	deactivation_message = "becomes silent."
	valid_triggers = list(/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch)
	///list of damage types we heal, this is randomly removed from at setup
	var/list/damage_types = list(BRUTE,BURN,TOX,OXY,BRAIN)
	///how much do we heal
	var/heal_amount
	COOLDOWN_DECLARE(heal_cooldown)

/datum/component/artifact/heal/setup()
	heal_amount = rand(1,15)
	potency += heal_amount
	var/type_amount = prob(75) ? 4 : rand(2,4) //75% to remove 4 types for 1 heal type or 25% for 2 or 4 types removed
	while(type_amount)
		type_amount--
		damage_types -= pick(damage_types)
	potency += 5 * (length(damage_types) - 1)

/datum/component/artifact/heal/effect_touched(mob/living/user)
	if(!COOLDOWN_FINISHED(src, heal_cooldown))
		return
	var/damage_length = length(damage_types)
	for(var/dam_type in damage_types)
		user.apply_damage_type( -(heal_amount / damage_length), dam_type)
	to_chat(user, span_notice("You feel slightly refreshed!"))
	new /obj/effect/temp_visual/heal(get_turf(user), COLOR_HEALING_CYAN)
	COOLDOWN_START(src, heal_cooldown, 5 SECONDS)
