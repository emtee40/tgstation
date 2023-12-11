/**
 * ## Spy uplink
 *
 * Applied to items similar to traitor uplinks.
 *
 * Used for spies to complete bounties.
 */
/datum/component/spy_uplink
	/// Weakref to the spy antag datum which owns this uplink
	var/datum/weakref/spy_ref
	/// The handler which manages all bounties across all spies.
	var/static/datum/spy_bounty_handler/handler

/datum/component/spy_uplink/Initialize(datum/antagonist/spy/spy)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	spy_ref = WEAKREF(spy)

	if(isnull(handler))
		handler = new()

/datum/component/spy_uplink/RegisterWithParent()
	RegisterSignal(parent, COMSIG_TABLET_CHECK_DETONATE, PROC_REF(block_pda_bombs))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK_SECONDARY, PROC_REF(on_pre_attack_secondary))

/datum/component/spy_uplink/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_PRE_ATTACK_SECONDARY,
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_TABLET_CHECK_DETONATE,
	))

/datum/component/spy_uplink/proc/is_our_spy(mob/whoever)
	var/datum/antagonist/spy/spy_datum = spy_ref?.resolve()
	return spy_datum?.owner.current == whoever

/datum/component/spy_uplink/proc/block_pda_bombs(obj/item/source)
	SIGNAL_HANDLER

	return COMPONENT_TABLET_NO_DETONATE

/datum/component/spy_uplink/proc/on_attack_self(obj/item/source, mob/user)
	SIGNAL_HANDLER

	if(is_our_spy(user))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/datum, ui_interact), user)
	return NONE

/datum/component/spy_uplink/proc/on_pre_attack_secondary(obj/item/source, atom/target, mob/living/user, params)
	SIGNAL_HANDLER

	if(!ismovable(target))
		return NONE
	if(!is_our_spy(user))
		return NONE
	if(try_steal(target, user))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	return NONE

/// Checks if the passed atom is something that can be stolen according to one of the active bounties.
/// If so, starts the stealing process.
/datum/component/spy_uplink/proc/try_steal(atom/movable/stealing, mob/living/spy)
	for(var/datum/spy_bounty/bounty as anything in handler.get_all_bounties())
		if(bounty.claimed)
			continue
		if(bounty.is_stealable(stealing))
			if(DOING_INTERACTION(spy, REF(src)))
				spy.balloon_alert(spy, "already scanning!") // Only shown if they're trying to scan two valid targets
			else
				INVOKE_ASYNC(src, PROC_REF(start_stealing), stealing, spy, bounty)
			return TRUE

	return FALSE

/// Wraps the stealing process in a scanning effect.
/datum/component/spy_uplink/proc/start_stealing(atom/movable/stealing, mob/living/spy, datum/spy_bounty/bounty)
	if(!isturf(stealing.loc) && stealing.loc != spy)
		to_chat(spy, span_warning("You can't scan [stealing] from there!"))
		return FALSE

	var/obj/effect/scan_effect/active_scan_effect = new(stealing.loc)
	active_scan_effect.appearance = stealing.appearance
	active_scan_effect.dir = stealing.dir
	active_scan_effect.makeHologram()

	var/obj/effect/scan_effect/cone/active_scan_cone
	if(isturf(stealing.loc) && isturf(spy.loc)) // Cone doesn't make sense if its being held or something
		active_scan_cone = new(spy.loc)
		active_scan_cone.transform = active_scan_cone.transform.Turn(get_angle(spy, stealing))
		active_scan_cone.pixel_x -= 48
		active_scan_cone.pixel_y -= 48
		active_scan_cone.alpha = 0
		animate(active_scan_cone, time = 0.5 SECONDS, alpha = initial(active_scan_cone.alpha))

	. = steal_process(stealing, spy, bounty)
	qdel(active_scan_effect)
	qdel(active_scan_cone)
	return .

/// Attempts to steal the passed atom in accordance with the passed bounty.
/// If successful, proceeds to complete the bounty.
/datum/component/spy_uplink/proc/steal_process(atom/movable/stealing, mob/living/spy, datum/spy_bounty/bounty)
	spy.visible_message(
		span_warning("[spy] starts scanning [stealing] with a strange device..."),
		span_notice("You start scanning [stealing], preparing it for extraction."),
	)

	if(!do_after(spy, bounty.theft_time, stealing, interaction_key = REF(src)))
		return FALSE
	if(bounty.claimed)
		to_chat(spy, span_warning("The bounty for [stealing] has been claimed by another spy!"))
		return FALSE

	bounty.clean_up_stolen_item(stealing, spy)
	bounty.claimed = TRUE

	var/obj/item/reward = new bounty.reward_item.item(spy.loc)
	spy.put_in_hands(reward)
	to_chat(spy, span_notice("Bounty complete! You have been rewarded with \a [reward].\
		[reward.loc == spy ? "" : " <i>Find it at your feet.</i>"]"))

	playsound(parent, 'sound/machines/wewewew.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

	var/datum/antagonist/spy/spy_datum = spy_ref?.resolve()
	spy_datum?.bounties_claimed += 1

	return TRUE

/datum/component/spy_uplink/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpyUplink")
		ui.open()

/datum/component/spy_uplink/ui_data(mob/user)
	var/list/data = list()

	data["bounties"] = list()
	for(var/datum/spy_bounty/bounty as anything in handler.get_all_bounties())
		UNTYPED_LIST_ADD(data["bounties"], bounty.to_ui_data())
	data["time_left"] = timeleft(handler.refresh_timer)

	return data

/obj/effect/scan_effect
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	plane = GAME_PLANE_UPPER_FOV_HIDDEN

/obj/effect/scan_effect/cone
	name = "holoray"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "holoray"
	color = "#3ba0ff"
	alpha = 125
