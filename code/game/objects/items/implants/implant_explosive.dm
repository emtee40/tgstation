/**
 * Note that we can stack explosive implants and thus increase the payload's devastation radius. (https://github.com/tgstation/tgstation/pull/50674)
 * That's why the three devastation values for the microbomb implant are balanced around in such a way
 * that buying one macrobomb equals to buying 10 microbombs and stacking them.
 */

#define MICROBOMB_DELAY 0.7 SECONDS

#define MICROBOMB_EXPLOSION_LIGHT 2
#define MICROBOMB_EXPLOSION_HEAVY 0.8
#define MICROBOMB_EXPLOSION_DEVASTATE 0.4

/obj/item/implant/explosive
	name = "microbomb implant"
	desc = "And boom goes the weasel."
	icon_state = "explosive"
	actions_types = list(/datum/action/item_action/explosive_implant) //Explosive implant action is always available.
	///Whether the implant's explosion sequence has been activated or not
	var/active = FALSE
	///The final countdown (delay before we explode)
	var/delay = MICROBOMB_DELAY
	///If the delay is equal or lower to MICROBOMB_DELAY (0.7 sec), the explosion will be instantaneous.
	var/instant_explosion = TRUE
	///Radius of weak devastation explosive impact
	var/explosion_light = MICROBOMB_EXPLOSION_LIGHT
	///Radius of medium devastation explosive impact
	var/explosion_heavy = MICROBOMB_EXPLOSION_HEAVY
	///Radius of heavy devastation explosive impact
	var/explosion_devastate = MICROBOMB_EXPLOSION_DEVASTATE
	///Whether the confirmation UI popup is active or not
	var/popup = FALSE
	///Do we rapidly increase the beeping speed as it gets closer to detonating?
	var/panic_beep_sound = FALSE
	///Do we disable paralysis upon activation
	var/no_paralyze = FALSE
	///Do we override other explosive implants?
	var/master_implant = FALSE
	///Will this implant notify ghosts when activated?
	var/notify_ghosts = TRUE

/obj/item/implant/explosive/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER

	// There may be other signals that want to handle mob's death
	// and the process of activating destroys the body, so let the other
	// signal handlers at least finish. Also, the "delayed explosion"
	// uses sleeps, which is bad for signal handlers to do.
	INVOKE_ASYNC(src, PROC_REF(activate), "death")

/obj/item/implant/explosive/get_data()
	return "<b>Implant Specifications:</b><BR> \
		<b>Name:</b> Robust Corp RX-78 Employee Management Implant<BR> \
		<b>Life:</b> Activates upon death.<BR> \
		<b>Important Notes:</b> Explodes<BR> \
		<HR> \
		<b>Implant Details:</b><BR> \
		<b>Function:</b> Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal or upon host death.<BR> \
		<b>Special Features:</b> Explodes<BR>"

/obj/item/implant/explosive/activate(cause)
	. = ..()
	if(!cause || !imp_in || active)
		return FALSE
	if(cause == "action_button")
		if(popup)
			return FALSE
		popup = TRUE
		var/response = tgui_alert(imp_in, "Are you sure you want to activate your [name]? This will cause you to explode!", "[name] Confirmation", list("Yes", "No"))
		popup = FALSE
		if(response != "Yes")
			return FALSE
	if(cause == "death" && HAS_TRAIT(imp_in, TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION))
		return FALSE
	to_chat(imp_in, span_notice("You activate your [name]."))
	active = TRUE
	var/turf/boomturf = get_turf(imp_in)
	message_admins("[ADMIN_LOOKUPFLW(imp_in)] has activated their [name] at [ADMIN_VERBOSEJMP(boomturf)], with cause of [cause].")
	//If the delay is shorter or equal to the default delay, just blow up already jeez
	if(delay <= MICROBOMB_DELAY && instant_explosion)
		explode()
		return
	timed_explosion()

/obj/item/implant/explosive/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	for(var/target_implant in target.implants)
		if(istype(target_implant, /obj/item/implant/explosive)) //we don't use our own type here, because macrobombs inherit this proc and need to be able to upgrade microbombs
			var/obj/item/implant/explosive/other_implant = target_implant
			if(other_implant.master_implant && master_implant) //we cant have two master implants at once
				target.balloon_alert(user, "cannot fit implant!")
				return FALSE
			if(master_implant)
				merge_implants(src, other_implant)
			else
				merge_implants(other_implant, src)
				return TRUE

	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/obj/item/implant/explosive/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(.)
		UnregisterSignal(target, COMSIG_LIVING_DEATH)

/**
 * Merges two explosive implants together, adding the stats of the latter to the former before qdeling the latter implant.
 * kept_implant = the implant that is kept
 * stat_implant = the implant which has it's stats added to kept_implant, before being deleted.
 */
/obj/item/implant/explosive/proc/merge_implants(obj/item/implant/explosive/kept_implant, obj/item/implant/explosive/stat_implant)
	kept_implant.explosion_devastate += stat_implant.explosion_devastate
	kept_implant.explosion_heavy += stat_implant.explosion_heavy
	kept_implant.explosion_light += stat_implant.explosion_light
	kept_implant.delay = min(kept_implant.delay + stat_implant.delay, 30 SECONDS)
	qdel(stat_implant)

/**
 * Explosive activation sequence for implants with a delay longer than 0.7 seconds.
 * Make the implantee beep a few times, keel over and explode. Usually to a devastating effect.
 */
/obj/item/implant/explosive/proc/timed_explosion()
	if (isnull(imp_in))
		visible_message(span_warning("[src] starts beeping ominously!"))
	else
		imp_in.visible_message(span_warning("[imp_in] starts beeping ominously!"))
		if(notify_ghosts)
			notify_ghosts(
				"[imp_in] is about to detonate their explosive implant!",
				source = src,
				header = "Tick Tick Tick...",
				notify_flags = NOTIFY_CATEGORY_NOFLASH,
				ghost_sound = 'sound/machines/warning-buzzer.ogg',
				notify_volume = 75,
			)

	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	if(!panic_beep_sound)
		sleep(delay * 0.25)
	if(imp_in && !imp_in.stat && !no_paralyze)
		imp_in.visible_message(span_warning("[imp_in] doubles over in pain!"))
		imp_in.Paralyze(14 SECONDS)
	//total of 4 bomb beeps, and we've already beeped once
	var/bomb_beeps_until_boom = 3
	if(!panic_beep_sound)
		while(bomb_beeps_until_boom > 0)
			//for extra spice
			var/beep_volume = 35
			playsound(loc, 'sound/items/timer.ogg', beep_volume, vary = FALSE)
			sleep(delay * 0.25)
			bomb_beeps_until_boom--
			beep_volume += 5
		explode()
	else
		addtimer(CALLBACK(src, PROC_REF(explode)), delay)
		while(delay > 1) //so we dont accidentally enter an infinite sleep
			var/beep_volume = 35
			playsound(loc, 'sound/items/timer.ogg', beep_volume, vary = FALSE)
			sleep(delay * 0.2)
			delay -= delay * 0.2
			beep_volume += 5


///When called, just explodes
/obj/item/implant/explosive/proc/explode()
	explosion_devastate = round(explosion_devastate)
	explosion_heavy = round(explosion_heavy)
	explosion_light = round(explosion_light)
	explosion(src, devastation_range = explosion_devastate, heavy_impact_range = explosion_heavy, light_impact_range = explosion_light, flame_range = explosion_light, flash_range = explosion_light, explosion_cause = src)
	if(imp_in)
		imp_in.investigate_log("has been gibbed by an explosive implant.", INVESTIGATE_DEATHS)
		imp_in.gib(DROP_ORGANS|DROP_BODYPARTS)
	qdel(src)

///Macrobomb has the strength and delay of 10 microbombs
/obj/item/implant/explosive/macro
	name = "macrobomb implant"
	desc = "And boom goes the weasel. And everything else nearby."
	icon_state = "explosive"
	delay = 10 * MICROBOMB_DELAY
	explosion_light = 10 * MICROBOMB_EXPLOSION_LIGHT
	explosion_heavy = 10 * MICROBOMB_EXPLOSION_HEAVY
	explosion_devastate = 10 * MICROBOMB_EXPLOSION_DEVASTATE

///Microbomb which prevents you from going into critical condition but also explodes after a timer when you reach critical condition in the first place.
/obj/item/implant/explosive/deniability
	name = "tactical deniability implant"
	desc = "An enhanced version of the microbomb that directly plugs into the brain. No downsides, promise!"
	delay = 10 SECONDS
	panic_beep_sound = TRUE
	no_paralyze = TRUE
	master_implant = TRUE

/obj/item/implant/explosive/deniability/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(check_health))
		target.add_traits(list(TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT), IMPLANT_TRAIT)

/obj/item/implant/explosive/deniability/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(.)
		UnregisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE)
		target.remove_traits(list(TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT), IMPLANT_TRAIT)

/obj/item/implant/explosive/deniability/proc/check_health(mob/living/source)
	SIGNAL_HANDLER

	if(source.health < source.crit_threshold)
		INVOKE_ASYNC(src, PROC_REF(activate), "deniability")

/obj/item/implant/explosive/deathmatch
	name = "deathmatch microbomb implant"
	delay = 0.5 SECONDS
	actions_types = null
	instant_explosion = FALSE
	notify_ghosts = FALSE

/// Implant used by the traitor Battle Royale objective, is not active immediately
/obj/item/implant/explosive/battle_royale
	name = "rumble royale implant"
	actions_types = null
	instant_explosion = FALSE
	master_implant = TRUE
	delay = 10 SECONDS
	panic_beep_sound = TRUE
	/// Is this implant active yet?
	var/battle_started = FALSE
	/// Are we presently exploding?
	var/has_exploded = FALSE

/obj/item/implant/explosive/battle_royale/get_data()
	return "<b>Implant Specifications:</b><BR> \
		<b>Name:</b> Donk Co. 'Rumble Royale' Contestant Motivation Implant<BR> \
		<b>Life:</b> Activates upon death, or expiry of an internal timer.<BR> \
		<b>Important Notes:</b> Explodes.<BR> \
		<HR> \
		<b>Implant Details:</b><BR> \
		<b>Function:</b> Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal or upon host death. \
		Upon triggering the timer, the implant will begin to broadcast the surrounding area for the purposes of televised entertainment. This signal can be detected by GPS trackers.<BR> \
		<b>Special Features:</b> Exploding.<BR>"

/obj/item/implant/explosive/battle_royale/on_death(datum/source, gibbed)
	if (!battle_started)
		return
	return ..()

/obj/item/implant/explosive/battle_royale/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	if (!.)
		return
	RegisterSignal(target, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	if (!battle_started)
		return
	name = "[name] - [imp_in.real_name]"
	target.AddComponent( \
		/datum/component/simple_bodycam, \
		camera_name = "rumble royale tracker", \
		c_tag = "Competitor [target.real_name]", \
		network = BATTLE_ROYALE_CAMERA_NET, \
		emp_proof = TRUE, \
	)
	announce()

/obj/item/implant/explosive/battle_royale/removed(mob/target, silent, special)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_LIFE)
	if (battle_started)
		qdel(target.GetComponent(/datum/component/simple_bodycam)) // Surely there's no way they could have more than one
	visible_message(span_boldwarning("[src] beeps ominously."))
	playsound(loc, 'sound/items/timer.ogg', 50, vary = FALSE)

	if (has_exploded || QDELETED(src))
		return
	if (prob(50))
		explode()
	else
		timed_explosion()

/obj/item/implant/explosive/battle_royale/explode()
	has_exploded = TRUE
	return ..()

/// Give a slight tell
/obj/item/implant/explosive/battle_royale/proc/on_life(mob/living/source)
	SIGNAL_HANDLER
	if (prob(98))
		return
	if (!source.itch() || prob(80))
		return
	to_chat(source, span_boldwarning("You feel a lump which shouldn't be there."))

/// Start the battle royale
/obj/item/implant/explosive/battle_royale/proc/start_battle()
	if (isnull(imp_in))
		explode()
		return
	battle_started = TRUE
	name = "[name] - [imp_in.real_name]"
	imp_in.AddComponent( \
		/datum/component/simple_bodycam, \
		camera_name = "rumble royale tracker", \
		c_tag = "Competitor [imp_in.real_name]", \
		network = BATTLE_ROYALE_CAMERA_NET, \
		emp_proof = TRUE, \
	)
	AddComponent(/datum/component/gps, "Rumble Royale - [imp_in.real_name]")
	playsound(loc, 'sound/items/timer.ogg', 50, vary = FALSE)

/// Give a little spiel to our new contestant
/obj/item/implant/explosive/battle_royale/proc/announce()
	to_chat(imp_in, span_warning("[span_bold("You hear a tinny voice in your ear: ")] \
		Welcome contestant to Rumble Royale, the galaxy's greatest show! \n\
		You may have already heard our announcement, but we're glad to tell you that you are on live TV! \n\
		Your objective in this contest is simple: Within ten minutes be the last contestant left alive, to win a fabulous prize! \n\
		Your fellow contestants will be hearing this too, so you should grab a GPS quick and get hunting! \n\
		Noncompliance and removal of this implant is not recommended, and remember to smile for the cameras!"))

/obj/item/implanter/explosive
	name = "implanter (microbomb)"
	imp_type = /obj/item/implant/explosive

/obj/item/implantcase/explosive
	name = "implant case - 'Explosive'"
	desc = "A glass case containing an explosive implant."
	imp_type = /obj/item/implant/explosive

/obj/item/implanter/explosive_macro
	name = "implanter (macrobomb)"
	imp_type = /obj/item/implant/explosive/macro

/obj/item/implanter/tactical_deniability
	name = "implanter (tactical deniability)"
	imp_type = /obj/item/implant/explosive/deniability

/datum/action/item_action/explosive_implant
	check_flags = NONE
	name = "Activate Explosive Implant"

#undef MICROBOMB_DELAY
#undef MICROBOMB_EXPLOSION_LIGHT
#undef MICROBOMB_EXPLOSION_HEAVY
#undef MICROBOMB_EXPLOSION_DEVASTATE
