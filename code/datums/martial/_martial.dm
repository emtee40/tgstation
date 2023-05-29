/datum/martial_art
	var/name = "Martial Art"
	var/id = "" //ID, used by mind/has_martialart
	var/streak = ""
	var/max_streak_length = 6
	var/current_target
	var/datum/martial_art/base // The permanent style. This will be null unless the martial art is temporary
	///Chance to block and counter melee attacks using items while on throw mode.
	var/block_chance = 0
	var/help_verb
	var/allow_temp_override = TRUE //if this martial art can be overridden by temporary martial arts
	var/smashes_tables = FALSE //If the martial art smashes tables when performing table slams and head smashes
	var/datum/weakref/holder //owner of the martial art
	var/display_combos = FALSE //shows combo meter if true
	var/combo_timer = 6 SECONDS // period of time after which the combo streak is reset.
	var/timerid
	/// If set to true this style allows you to punch people despite being a pacifist (for instance Boxing, which does no damage)
	var/pacifist_style = FALSE

/datum/martial_art/serialize_list(list/options, list/semvers)
	. = ..()

	.["name"] = name
	.["id"] = id
	.["pacifist_style"] = pacifist_style

	SET_SERIALIZATION_SEMVER(semvers, "1.0.0")
	return .

/datum/martial_art/proc/help_act(mob/living/attacker, mob/living/defender)
	return MARTIAL_ATTACK_INVALID

/datum/martial_art/proc/disarm_act(mob/living/attacker, mob/living/defender)
	return MARTIAL_ATTACK_INVALID

/datum/martial_art/proc/harm_act(mob/living/attacker, mob/living/defender)
	return MARTIAL_ATTACK_INVALID

/datum/martial_art/proc/grab_act(mob/living/attacker, mob/living/defender)
	return MARTIAL_ATTACK_INVALID

/datum/martial_art/proc/can_use(mob/living/L)
	return TRUE

/datum/martial_art/proc/add_to_streak(element, mob/living/defender)
	if(defender != current_target)
		reset_streak(defender)
	streak = streak+element
	if(length(streak) > max_streak_length)
		streak = copytext(streak, 1 + length(streak[1]))
	if (display_combos)
		var/mob/living/holder_living = holder.resolve()
		timerid = addtimer(CALLBACK(src, PROC_REF(reset_streak), null, FALSE), combo_timer, TIMER_UNIQUE | TIMER_STOPPABLE)
		holder_living?.hud_used?.combo_display.update_icon_state(streak, combo_timer - 2 SECONDS)

/datum/martial_art/proc/reset_streak(mob/living/new_target, update_icon = TRUE)
	if(timerid)
		deltimer(timerid)
	current_target = new_target
	streak = ""
	if(update_icon)
		var/mob/living/holder_living = holder?.resolve()
		holder_living?.hud_used?.combo_display.update_icon_state(streak)

/datum/martial_art/proc/teach(mob/living/holder_living, make_temporary=FALSE)
	if(!istype(holder_living) || !holder_living.mind)
		return FALSE
	if(holder_living.mind.martial_art)
		if(make_temporary)
			if(!holder_living.mind.martial_art.allow_temp_override)
				return FALSE
			store(holder_living.mind.martial_art, holder_living)
		else
			holder_living.mind.martial_art.on_remove(holder_living)
	else if(make_temporary)
		base = holder_living.mind.default_martial_art
	if(help_verb)
		add_verb(holder_living, help_verb)
	holder_living.mind.martial_art = src
	holder = WEAKREF(holder_living)
	RegisterSignal(holder, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(block_check))
	return TRUE

/datum/martial_art/proc/store(datum/martial_art/old, mob/living/holder_living)
	old.on_remove(holder_living)
	if (old.base) //Checks if old is temporary, if so it will not be stored.
		base = old.base
	else //Otherwise, old is stored.
		base = old

/datum/martial_art/proc/remove(mob/living/holder_living)
	if(!istype(holder_living) || !holder_living.mind || holder_living.mind.martial_art != src)
		return
	on_remove(holder_living)
	if(base)
		base.teach(holder_living)
	else
		var/datum/martial_art/default = holder_living.mind.default_martial_art
		default.teach(holder_living)
	holder = null

/datum/martial_art/proc/on_remove(mob/living/holder_living)
	if(help_verb)
		remove_verb(holder_living, help_verb)
	UnregisterSignal(holder_living, COMSIG_LIVING_CHECK_BLOCK)

/datum/martial_art/proc/block_check(mob/living/source, atom/hitby, damage, attack_text = "the attack", attack_type = MELEE_ATTACK, armour_penetration = 0)
	SIGNAL_HANDLER

	if(attack_type != MELEE_ATTACK && attack_type != UNARMED_ATTACK)
		return NONE
	if(!source.throw_mode || !can_use(source) || source.incapacitated(IGNORE_GRAB))
		return NONE

	if(prob(block_chance))
		INVOKE_ASYNC(src, PROC_REF(counter_attack), source, hitby, attack_text)
		return SUCCESSFUL_BLOCK

/datum/martial_art/proc/counter_attack(mob/living/martial_artist, atom/hitby, attack_text = "the attack")
	var/mob/living/assailant = GET_ASSAILANT(hitby)
	if(!istype(assailant) || !martial_artist.Adjacent(assailant))
		return

	martial_artist.visible_message(
		span_danger("[martial_artist] blocks [attack_text] and twists [assailant]'s arm behind [assailant.p_their()] back!"),
		span_userdanger("You block [attack_text] and twist [assailant]'s arm behind [assailant.p_their()] back!"),
	)
	assailant.Stun(4 SECONDS)

///Gets called when a projectile hits the owner. Returning anything other than BULLET_ACT_HIT will stop the projectile from hitting the mob.
/datum/martial_art/proc/on_projectile_hit(mob/living/attacker, obj/projectile/P, def_zone)
	return BULLET_ACT_HIT
