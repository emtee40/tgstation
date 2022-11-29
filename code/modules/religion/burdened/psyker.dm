/obj/item/organ/internal/brain/psyker
	name = "psyker brain"
	desc = "This brain is blue, split into two hemispheres, and has immense psychic powers. What kind of monstrosity would use that?"
	icon_state = "brain-psyker"
	actions_types = list(
		/datum/action/cooldown/spell/pointed/psychic_projection,
		/datum/action/cooldown/spell/charged/psychic_booster,
		/datum/action/cooldown/spell/forcewall/psychic_wall,
	)
	organ_traits = list(TRAIT_ADVANCEDTOOLUSER, TRAIT_LITERATE, TRAIT_CAN_STRIP, TRAIT_ANTIMAGIC_NO_SELFBLOCK)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/organ/internal/brain/psyker/Insert(mob/living/carbon/inserted_into, special, drop_if_replaced, no_id_transfer)
	. = ..()
	inserted_into.AddComponent(/datum/component/echolocation, echo_group = "psyker", echo_icon = "psyker", color_path = /datum/client_colour/psyker)
	inserted_into.AddComponent(/datum/component/anti_magic, antimagic_flags = MAGIC_RESISTANCE_MIND)

/obj/item/organ/internal/brain/psyker/Remove(mob/living/carbon/removed_from, special, no_id_transfer)
	. = ..()
	qdel(removed_from.GetComponent(/datum/component/echolocation))
	qdel(removed_from.GetComponent(/datum/component/anti_magic))

/obj/item/organ/internal/brain/psyker/on_life(delta_time, times_fired)
	. = ..()
	var/obj/item/bodypart/head/psyker/psyker_head = owner.get_bodypart(zone)
	if(istype(psyker_head))
		return
	if(!DT_PROB(2, delta_time))
		return
	to_chat(owner, span_userdanger("Your head hurts... It can't fit your brain!"))
	owner.adjust_disgust(33 * delta_time)
	applyOrganDamage(5 * delta_time, 199)
	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5 * delta_time)

/obj/item/bodypart/head/psyker
	limb_id = BODYPART_ID_PSYKER
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodypart_traits = list(TRAIT_DISFIGURED, TRAIT_BALD, TRAIT_SHAVED, TRAIT_BLIND)

/obj/item/bodypart/head/psyker/try_attach_limb(mob/living/carbon/new_head_owner, special, abort)
	. = ..()
	if(!. || !new_head_owner.dna?.species)
		return
	new_head_owner.dna.species.species_traits |= NOEYESPRITES //MAKE VISUALS TIED TO BODYPARTS ARGHH
	new_head_owner.update_body()

/// Makes us go through a transform sequency, to turn into a psyker.
/mob/living/carbon/human/proc/psykerize()
	if(stat == DEAD || !get_bodypart(BODY_ZONE_HEAD) || istype(get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/psyker))
		return
	to_chat(src, span_userdanger("You feel unwell..."))
	sleep(5 SECONDS)
	if(stat == DEAD || !get_bodypart(BODY_ZONE_HEAD))
		return
	to_chat(src, span_userdanger("You feel your skin ripping off!"))
	emote("scream")
	apply_damage(30, BRUTE, BODY_ZONE_HEAD)
	sleep(5 SECONDS)
	var/obj/item/bodypart/head/old_head = get_bodypart(BODY_ZONE_HEAD)
	var/obj/item/organ/internal/brain/old_brain = getorganslot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/internal/old_eyes = getorganslot(ORGAN_SLOT_EYES)
	if(stat == DEAD || !old_head || !old_brain)
		return
	to_chat(src, span_userdanger("Your head splits open! Your brain mutates!"))
	playsound(src, 'sound/effects/blobattack.ogg', 50, vary = TRUE)
	emote("scream")
	var/obj/item/bodypart/head/psyker/psyker_head = new()
	psyker_head.receive_damage(brute = 50)
	if(!psyker_head.replace_limb(src, special = TRUE))
		return
	qdel(old_head)
	var/obj/item/organ/internal/brain/psyker/psyker_brain = new()
	old_brain.before_organ_replacement(psyker_brain)
	old_brain.Remove(src, special = TRUE, no_id_transfer = TRUE)
	qdel(old_brain)
	psyker_brain.Insert(src, special = TRUE, drop_if_replaced = FALSE)
	if(old_eyes)
		qdel(old_eyes)

/datum/religion_rites/nullrod_transformation
	name = "Transmogrify"
	desc = "Your full power needs a firearm to be realized. You may transform your null rod into one."
	ritual_length = 10 SECONDS
	///The rod that will be transmogrified.
	var/obj/item/nullrod/transformation_target

/datum/religion_rites/nullrod_transformation/perform_rite(mob/living/user, atom/religious_tool)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/human_user = user
	var/datum/brain_trauma/special/burdened/burden = human_user.has_trauma_type(/datum/brain_trauma/special/burdened)
	if(!burden || burden.burden_level < 9)
		to_chat(human_user, span_warning("You aren't burdened enough."))
		return FALSE
	for(var/obj/item/nullrod/null_rod in get_turf(religious_tool))
		transformation_target = null_rod
		return ..()
	to_chat(human_user, span_warning("You need to place a null rod on [religious_tool] to do this!"))
	return FALSE

/datum/religion_rites/nullrod_transformation/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/obj/item/nullrod/null_rod = transformation_target
	transformation_target = null
	if(QDELETED(null_rod) || null_rod.loc != get_turf(religious_tool))
		to_chat(user, span_warning("Your target left the altar!"))
		return FALSE
	to_chat(user, span_warning("[null_rod] turns into a gun!"))
	user.emote("smile")
	qdel(null_rod)
	new /obj/item/gun/ballistic/revolver/chaplain(get_turf(religious_tool))
	return TRUE

/obj/item/gun/ballistic/revolver/chaplain
	name = "chaplain's revolver"
	desc = "Holy smokes."
	icon_state = "chaplain"
	force = 10
	fire_sound = 'sound/weapons/gun/revolver/shot.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev77
	obj_flags = UNIQUE_RENAME
	custom_materials = null
	actions_types = list(/datum/action/item_action/pray_refill)
	/// Needs burden level nine to refill.
	var/needs_burden = TRUE
	/// List of all possible names and descriptions.
	var/static/list/possible_names = list(
		"Requiescat" = "May they rest in peace.",
		"Requiem" = "They will never reach truth.",
		"Vade Retro" = "Having a gun might make exorcisms more effective, who knows?",
		"Extra Nos" = "Salvation is given externally.",
		"Ordo Salutis" = "First step? Fire.",
		"Absolution" = "Free of your sins.",
		"Rod of God" = "Splitting the red sea again.",
		"Holy Grail" = "You found it!",
		"Burning Bush" = "Useful for any burning ambush.",
		"Judgement" = "First of all, damn. Alpha much? Dude, so cool, and so are you! Strong, too!",
		"Paradiso" = "A divine end to the comedy of life.",
		"DVNO" = "Don't need to ask my name to figure out how cool I am.",
		"Venus Supermax" = "Did you know nearly everyone working and living on Venus is involved in sulfur extraction? Quite fitting for this weapon of gunpowder.",
		"Nirvana" = "The giver of quietude, freedom, and highest happiness.",
		"Cerebrum Dispersio" = "Latin for \"brain splitting\". How fitting.",
		"Ultimort" = "Your hope dies last.",
		"Lifelight" = "No escape, no greater fate to be made.",
		"Bendbreaker" = "FRAGILE: Please do not bend or break.",
		"Pop Pop" = "The name referring to an onomatopeia (phonetic imitation) of a gun firing.",
		"Justice" = "Justice is Splendor.",
		"Splendor" = "Splendor is Justice.",
		"Revelation" = "Awaken your faith.",
		"New Safety M62" = "This model of firearm is popular hundreds of years later due to masculine associations created by the film industry.",
		"Unmaker" = "What the !@#%* is this!",
		"INKVD" = "Savior of the soul and fighter against dirty thoughts.",
		"Life Leech" = "An artifact said to draw its power from the life energy of others.",
		"Nullray" = "Starless metal on the barrel imbibes light and routes it to the null place. The grip acrylic is patterned after ley lines.",
		"Mortis" = "Put your faith into this weapon working.",
		"Ramiel" = "Literally meaning \"God has thundered\". You could even interpret the gunshot as a thunder.",
		"Daredevil" = "Hey now, you won't be reckless with this, will you?",
		"Lacytanga" = "Rules are written by the strong.",
		"A10" = "The fist of God. Keep away from the terrible.",
	)

/obj/item/gun/ballistic/revolver/chaplain/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, MAGIC_RESISTANCE_HOLY)
	name = pick(possible_names)
	desc = possible_names[name]

/obj/item/gun/ballistic/revolver/chaplain/suicide_act(mob/living/user)
	. = ..()
	name = "Habemus Papam"
	desc = "I announce to you a great joy."

/obj/item/gun/ballistic/revolver/chaplain/attack_self(mob/living/user)
	pray_refill(user)

/obj/item/gun/ballistic/revolver/chaplain/proc/pray_refill(mob/living/carbon/human/user)
	if(DOING_INTERACTION_WITH_TARGET(user, src) || !istype(user))
		return
	var/datum/brain_trauma/special/burdened/burden = user.has_trauma_type(/datum/brain_trauma/special/burdened)
	if(needs_burden && (!burden || burden.burden_level < 9))
		to_chat(user, span_warning("You aren't burdened enough."))
		return
	user.manual_emote("presses [user.p_their()] palms together...")
	if(!do_after(user, 5 SECONDS, src))
		balloon_alert(user, "interrupted!")
		return
	user.say("#Oh great [GLOB.deity], give me the ammunition I need!", forced = "ammo prayer")
	magazine.top_off()
	user.playsound_local(get_turf(src), 'sound/magic/magic_block_holy.ogg', 50, TRUE)
	chamber_round()

/datum/action/item_action/pray_refill
	name = "Refill"
	desc = "Perform a prayer, to refill your weapon."

/obj/item/ammo_box/magazine/internal/cylinder/rev77
	name = "chaplain revolver cylinder"
	ammo_type = /obj/item/ammo_casing/c77
	caliber = CALIBER_77
	max_ammo = 5

/obj/item/ammo_casing/c77
	name = ".77 bullet casing"
	desc = "A .77 bullet casing."
	caliber = CALIBER_77
	projectile_type = /obj/projectile/bullet/c77
	custom_materials = null

/obj/projectile/bullet/c77
	name = ".77 bullet"
	damage = 18
	ricochets_max = 2
	ricochet_chance = 50
	ricochet_auto_aim_angle = 10
	ricochet_auto_aim_range = 3
	wound_bonus = -10
	embedding = null

/datum/action/cooldown/spell/pointed/psychic_projection
	name = "Psychic Projection"
	desc = "Project your psychics into a target to warp their view, and instill absolute terror that will cause them to fire their gun rapidly."
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	button_icon_state = "blind"
	school = SCHOOL_HOLY
	cooldown_time = 1 MINUTES
	antimagic_flags = MAGIC_RESISTANCE_MIND
	spell_max_level = 1
	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	cast_range = 5
	active_msg = "You prepare to psychically project to a target..."
	/// Duration of the effects.
	var/projection_duration = 10 SECONDS

/datum/action/cooldown/spell/pointed/psychic_projection/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(cast_on))
		return FALSE
	var/mob/living/living_target = cast_on
	return !living_target.has_status_effect(/datum/status_effect/psychic_projection)

/datum/action/cooldown/spell/pointed/psychic_projection/cast(mob/living/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("Your mind feels weird, but it passes momentarily."))
		to_chat(owner, span_warning("The spell had no effect!"))
		return FALSE
	to_chat(cast_on, span_userdanger("Your mind gets twisted!"))
	cast_on.emote("scream")
	cast_on.apply_status_effect(/datum/status_effect/psychic_projection, projection_duration)
	return TRUE

/// Status effect that adds a weird view to its owner and causes them to rapidly shoot a firearm in their general direction.
/datum/status_effect/psychic_projection
	id = "psychic_projection"
	alert_type = null
	remove_on_fullheal = TRUE
	tick_interval = 0.1 SECONDS
	/// Times the target has dry fired a weapon.
	var/times_dry_fired = 0
	/// Needs to reach times_dry_fired for the next dry fire to happen.
	var/firing_delay = 0

/datum/status_effect/psychic_projection/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/psychic_projection/on_apply()
	var/atom/movable/plane_master_controller/game_plane_master_controller = owner.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]
	if(!game_plane_master_controller)
		return FALSE
	game_plane_master_controller.add_filter("psychic_wave", 10, wave_filter(240, 240, 3, 0, WAVE_SIDEWAYS))
	game_plane_master_controller.add_filter("psychic_blur", 10, angular_blur_filter(0, 0, 3))
	return TRUE

/datum/status_effect/psychic_projection/on_remove()
	var/atom/movable/plane_master_controller/game_plane_master_controller = owner.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]
	if(!game_plane_master_controller)
		return
	game_plane_master_controller.remove_filter("psychic_blur")
	game_plane_master_controller.remove_filter("psychic_wave")

/datum/status_effect/psychic_projection/tick(delta_time, times_fired)
	var/obj/item/gun/held_gun = owner?.is_holding_item_of_type(/obj/item/gun)
	if(!held_gun)
		return
	if(!held_gun.can_shoot())
		if(firing_delay < times_dry_fired)
			firing_delay++
			return
		firing_delay = 0
		times_dry_fired++
	else
		times_dry_fired = 0
	var/turf/target_turf = get_offset_target_turf(get_ranged_target_turf(owner, owner.dir, 7), dx = rand(-1, 1), dy = rand(-1, 1))
	held_gun.process_fire(target_turf, owner, TRUE, null, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
	held_gun.semicd = FALSE

/datum/action/cooldown/spell/charged/psychic_booster
	name = "Psychic Booster"
	desc = "Charge up your mind to shoot firearms faster and home in on your targets. Think smarter, not harder."
	button_icon_state = "projectile"
	sound = 'sound/weapons/gun/shotgun/rack.ogg'
	school = SCHOOL_HOLY
	cooldown_time = 1 MINUTES
	antimagic_flags = MAGIC_RESISTANCE_MIND
	spell_max_level = 1
	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	channel_message = span_notice("You focus on your trigger fingers...")
	charge_overlay_icon = 'icons/effects/effects.dmi'
	charge_overlay_state = "purplesparkles"
	channel_time = 5 SECONDS
	/// Are we currently active?
	var/boosted = FALSE
	/// How long the effect lasts for?
	var/effect_time = 10 SECONDS

/datum/action/cooldown/spell/charged/psychic_booster/Destroy()
	if(boosted)
		stop_effects()
	return ..()

/datum/action/cooldown/spell/charged/psychic_booster/Remove(mob/living/remove_from)
	if(boosted)
		stop_effects()
	return ..()

/datum/action/cooldown/spell/charged/psychic_booster/cast(atom/cast_on)
	. = ..()
	if(boosted)
		return
	boosted = TRUE
	ADD_TRAIT(cast_on, TRAIT_DOUBLE_TAP, type)
	RegisterSignal(cast_on, COMSIG_PROJECTILE_FIRER_BEFORE_FIRE, PROC_REF(modify_projectile))
	addtimer(CALLBACK(src, PROC_REF(stop_effects)), effect_time)

/datum/action/cooldown/spell/charged/psychic_booster/proc/stop_effects()
	boosted = FALSE
	to_chat(owner, span_warning("Your trigger fingers feel weaker."))
	REMOVE_TRAIT(owner, TRAIT_DOUBLE_TAP, type)
	UnregisterSignal(owner, COMSIG_PROJECTILE_FIRER_BEFORE_FIRE)

/datum/action/cooldown/spell/charged/psychic_booster/proc/modify_projectile(datum/source, obj/projectile/bullet, atom/firer, atom/original_target)
	var/atom/target = original_target
	if(isturf(target) || (isobj(target) && !target.density)) //if weird target, we try to compensate in our homing
		for(var/mob/living/shooting_target in range(1, get_turf(target)))
			if(shooting_target == firer)
				continue
			target = shooting_target
			break
	if(!bullet.can_hit_target(target, direct_target = TRUE, ignore_loc = TRUE))
		return
	bullet.original = target
	bullet.homing_turn_speed = 30
	bullet.set_homing_target(target)

/datum/action/cooldown/spell/forcewall/psychic_wall
	name = "Psychic Wall"
	desc = "Form a psychic wall, able to deflect projectiles and prevent things from going through."
	school = SCHOOL_HOLY
	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 0 SECONDS
	antimagic_flags = MAGIC_RESISTANCE_MIND
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	spell_max_level = 1
	invocation_type = INVOCATION_NONE
	wall_type = /obj/effect/forcefield/psychic

/datum/action/cooldown/spell/forcewall/psychic_wall/spawn_wall(turf/cast_turf)
	. = ..()
	play_fov_effect(cast_turf, 5, "forcefield", time = 10 SECONDS)

/obj/item/reagent_containers/pill/psyker //for testmerge
	name = "pill that definitely does not give you psychic powers"
	desc = "DO NOT EAT!"
	icon_state = "pill4"
	list_reagents = list(/datum/reagent/drug/happiness = 5)

/obj/item/reagent_containers/pill/psyker/on_consumption(mob/living/carbon/human/consoomer, mob/user)
	. = ..()
	if(!istype(consoomer))
		return
	consoomer.dna?.add_mutation(/datum/mutation/human/telekinesis)
	consoomer.dna?.add_mutation(/datum/mutation/human/mindreader)
	consoomer.dna?.add_mutation(/datum/mutation/human/telepathy)
	consoomer.dna?.add_mutation(/datum/mutation/human/unintelligible)
	consoomer.psykerize()
