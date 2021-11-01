
///how many vampires exist in each house
#define VAMPIRES_PER_HOUSE 5
///maximum a vampire will drain, they will drain less if they hit their cap
#define VAMP_DRAIN_AMOUNT 50

/datum/species/vampire
	name = "Vampire"
	id = SPECIES_VAMPIRE
	default_color = "FFFFFF"
	species_traits = list(
		EYECOLOR,
		HAIR,
		FACEHAIR,
		LIPS,
		DRINKSBLOOD,
		HAS_FLESH,
		HAS_BONE,
		BLOOD_CLANS,
	)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_NOHUNGER,
		TRAIT_NOBREATH,
	)
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	mutant_bodyparts = list("wings" = "None")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN
	exotic_bloodtype = "U"
	use_skintones = TRUE
	mutantheart = /obj/item/organ/heart/vampire
	mutanttongue = /obj/item/organ/tongue/vampire
	limbs_id = "human"
	skinned_type = /obj/item/stack/sheet/animalhide/human
	///some starter text sent to the vampire initially, because vampires have shit to do to stay alive
	var/info_text = "You are a <span class='danger'>Vampire</span>. You will slowly but constantly lose blood if outside of a coffin. If inside a coffin, you will slowly heal. You may gain more blood by grabbing a live victim and using your drain ability."
	///static list shared among all vampire species datums that give a house name for each department
	var/static/list/vampire_houses = list(
		DEPARTMENT_COMMAND,
		DEPARTMENT_SECURITY,
		DEPARTMENT_ENGINEERING,
		DEPARTMENT_MEDICAL,
		DEPARTMENT_SCIENCE,
		DEPARTMENT_CARGO,
		DEPARTMENT_SERVICE,
	)

/datum/species/vampire/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/vampire/on_species_gain(mob/living/carbon/human/new_vampire, datum/species/old_species)
	. = ..()
	to_chat(new_vampire, "[info_text]")
	new_vampire.skin_tone = "albino"
	new_vampire.update_body(0)
	new_vampire.set_safe_hunger_level()
	var/clan_status = new_vampire.client?.prefs?.read_preference(/datum/preference/choiced/vampire_status)
	if(clan_status == "Inoculated")
		add_vampire_to_house(new_vampire)

/datum/species/vampire/proc/add_vampire_to_house(mob/living/carbon/human/new_vampire)

	//find and setup the house (department) this vampire is joining
	var/datum/job_department/vampire_house
	var/datum/job/vampire_job = SSjob.GetJob(new_vampire.job)
	var/list/valid_departments = (SSjob.joinable_departments.Copy()) - list(/datum/job_department/silicon, /datum/job_department/undefined)
	for(var/datum/job_department/potential_house as anything in valid_departments)
		if(vampire_job in potential_house.department_jobs)
			vampire_house = potential_house
			break
	if(!vampire_house)
		return
	if(!vampire_houses[vampire_house.department_name])
		vampire_houses[vampire_house.department_name] = pick(GLOB.vampire_house_names)
	var/house_name = vampire_houses[vampire_house.department_name]

	//modify name (Platos Syrup > Platos de Lioncourt)
	var/first_space_index = findtextEx(new_vampire.real_name, " ")
	var/new_name = copytext(new_vampire.real_name, 1, first_space_index + 1)
	new_name += house_name
	new_vampire.fully_replace_character_name(new_vampire.real_name, new_name)
	to_chat(new_vampire, span_boldnotice("You've been brought into house \"[house_name]\". Do not disappoint your vampire ménages!"))

/datum/species/vampire/spec_life(mob/living/carbon/human/vampire, delta_time, times_fired)
	. = ..()
	if(istype(vampire.loc, /obj/structure/closet/crate/coffin))
		vampire.heal_overall_damage(2 * delta_time, 2 * delta_time, 0, BODYPART_ORGANIC)
		vampire.adjustToxLoss(-2 * delta_time)
		vampire.adjustOxyLoss(-2 * delta_time)
		vampire.adjustCloneLoss(-2 * delta_time)
		return
	vampire.blood_volume -= 0.125 * delta_time
	if(vampire.blood_volume <= BLOOD_VOLUME_SURVIVE)
		to_chat(vampire, span_danger("You ran out of blood!"))
		var/obj/shapeshift_holder/holder = locate() in vampire
		if(holder)
			holder.shape.dust() //vampires do not have batform anymore, but this would still lead to very weird stuff with other shapeshift holders
		vampire.dust()
	var/area/A = get_area(vampire)
	if(istype(A, /area/service/chapel))
		to_chat(vampire, span_warning("You don't belong here!"))
		vampire.adjustFireLoss(10 * delta_time)
		vampire.adjust_fire_stacks(3 * delta_time)
		vampire.IgniteMob()

/datum/species/vampire/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/nullrod/whip))
		return 2 //Whips deal 2x damage to vampires. Vampire killer.
	return 1

/obj/item/organ/tongue/vampire
	name = "vampire tongue"
	actions_types = list(/datum/action/item_action/organ_action/vampire)
	color = "#1C1C1C"
	var/drain_cooldown = 0

/datum/action/item_action/organ_action/vampire
	name = "Drain Victim"
	desc = "Leech blood from any carbon victim you are passively grabbing."

/datum/action/item_action/organ_action/vampire/Trigger()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/H = owner
		var/obj/item/organ/tongue/vampire/V = target
		if(V.drain_cooldown >= world.time)
			to_chat(H, span_warning("You just drained blood, wait a few seconds!"))
			return
		if(H.pulling && iscarbon(H.pulling))
			var/mob/living/carbon/victim = H.pulling
			if(H.blood_volume >= BLOOD_VOLUME_MAXIMUM)
				to_chat(H, span_warning("You're already full!"))
				return
			if(victim.stat == DEAD)
				to_chat(H, span_warning("You need a living victim!"))
				return
			if(!victim.blood_volume || (victim.dna && ((NOBLOOD in victim.dna.species.species_traits) || victim.dna.species.exotic_blood)))
				to_chat(H, span_warning("[victim] doesn't have blood!"))
				return
			V.drain_cooldown = world.time + 30
			if(victim.anti_magic_check(FALSE, TRUE, FALSE, 0))
				to_chat(victim, span_warning("[H] tries to bite you, but stops before touching you!"))
				to_chat(H, span_warning("[victim] is blessed! You stop just in time to avoid catching fire."))
				return
			if(victim.has_reagent(/datum/reagent/consumable/garlic))
				to_chat(victim, span_warning("[H] tries to bite you, but recoils in disgust!"))
				to_chat(H, span_warning("[victim] reeks of garlic! you can't bring yourself to drain such tainted blood."))
				return
			if(!do_after(H, 30, target = victim))
				return
			var/blood_volume_difference = BLOOD_VOLUME_MAXIMUM - H.blood_volume //How much capacity we have left to absorb blood
			var/drained_blood = min(victim.blood_volume, VAMP_DRAIN_AMOUNT, blood_volume_difference)
			to_chat(victim, span_danger("[H] is draining your blood!"))
			to_chat(H, span_notice("You drain some blood!"))
			playsound(H, 'sound/items/drink.ogg', 30, TRUE, -2)
			victim.blood_volume = clamp(victim.blood_volume - drained_blood, 0, BLOOD_VOLUME_MAXIMUM)
			H.blood_volume = clamp(H.blood_volume + drained_blood, 0, BLOOD_VOLUME_MAXIMUM)
			if(!victim.blood_volume)
				to_chat(H, span_notice("You finish off [victim]'s blood supply."))



/mob/living/carbon/get_status_tab_items()
	. = ..()
	var/obj/item/organ/heart/vampire/darkheart = getorgan(/obj/item/organ/heart/vampire)
	if(darkheart)
		. += "Current blood level: [blood_volume]/[BLOOD_VOLUME_MAXIMUM]."

/obj/item/organ/heart/vampire
	name = "vampire heart"
	color = "#1C1C1C"

#undef VAMPIRES_PER_HOUSE
#undef VAMP_DRAIN_AMOUNT
