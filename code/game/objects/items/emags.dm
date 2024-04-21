/* Emags
 * Contains:
 * EMAGS AND DOORMAGS
 */


/*
 * EMAG AND SUBTYPES
 */
/obj/item/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	slot_flags = ITEM_SLOT_ID
	worn_icon_state = "emag"
	var/prox_check = TRUE //If the emag requires you to be in range
	var/type_blacklist //List of types that require a specialized emag

/obj/item/card/emag/attack_self(mob/user) //for traitors with balls of plastitanium
	if(Adjacent(user))
		user.visible_message(span_notice("[user] shows you: [icon2html(src, viewers(user))] [name]."), span_notice("You show [src]."))
	add_fingerprint(user)

/obj/item/card/emag/bluespace
	name = "bluespace cryptographic sequencer"
	desc = "It's a blue card with a magnetic strip attached to some circuitry. It appears to have some sort of transmitter attached to it."
	color = rgb(40, 130, 255)
	prox_check = FALSE

/obj/item/card/emag/halloween
	name = "hack-o'-lantern"
	desc = "It's a pumpkin with a cryptographic sequencer sticking out."
	icon_state = "hack_o_lantern"

/obj/item/card/emagfake
	desc = "It's a card with a magnetic strip attached to some circuitry. Closer inspection shows that this card is a poorly made replica, with a \"Donk Co.\" logo stamped on the back."
	name = "cryptographic sequencer"
	icon_state = "emag"
	slot_flags = ITEM_SLOT_ID
	worn_icon_state = "emag"

/obj/item/card/emagfake/attack_self(mob/user) //for assistants with balls of plasteel
	if(Adjacent(user))
		user.visible_message(span_notice("[user] shows you: [icon2html(src, viewers(user))] [name]."), span_notice("You show [src]."))
	add_fingerprint(user)

/obj/item/card/emagfake/interact_with_atom(atom/interacting_with, mob/living/user)
	playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
	return ITEM_INTERACT_SKIP_TO_ATTACK // So it does the attack animation.

/obj/item/card/emag/Initialize(mapload)
	. = ..()
	type_blacklist = list(typesof(/obj/machinery/door/airlock) + typesof(/obj/machinery/door/window/) +  typesof(/obj/machinery/door/firedoor) - typesof(/obj/machinery/door/airlock/tram)) //list of all typepaths that require a specialized emag to hack.

/obj/item/card/emag/interact_with_atom(atom/interacting_with, mob/living/user)
	if(!can_emag(interacting_with, user))
		return ITEM_INTERACT_BLOCKING
	log_combat(user, interacting_with, "attempted to emag")
	interacting_with.emag_act(user, src)
	return ITEM_INTERACT_SUCCESS

/obj/item/card/emag/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	// Proximity based emagging is handled by above
	// This is only for ranged emagging
	if(proximity_flag || prox_check)
		return

	. |= AFTERATTACK_PROCESSED_ITEM
	interact_with_atom(target, user)

/obj/item/card/emag/proc/can_emag(atom/target, mob/user)
	for (var/subtypelist in type_blacklist)
		if (target.type in subtypelist)
			to_chat(user, span_warning("The [target] cannot be affected by the [src]! A more specialized hacking device is required."))
			return FALSE
	return TRUE

/*
 * DOORMAG
 */
/obj/item/card/emag/doorjack
	desc = "Commonly known as a \"doorjack\", this device is a specialized cryptographic sequencer specifically designed to override station airlock access codes. Uses self-refilling charges to hack airlocks."
	name = "airlock authentication override card"
	icon_state = "doorjack"
	worn_icon_state = "doorjack"
	var/type_whitelist //List of types
	var/charges = 3
	var/max_charges = 3
	var/list/charge_timers = list()
	var/charge_time = 1800 //three minutes

/obj/item/card/emag/doorjack/Initialize(mapload)
	. = ..()
	type_whitelist = list(typesof(/obj/machinery/door/airlock), typesof(/obj/machinery/door/window/), typesof(/obj/machinery/door/firedoor)) //list of all acceptable typepaths that this device can affect

/obj/item/card/emag/doorjack/proc/use_charge(mob/user)
	charges --
	to_chat(user, span_notice("You use [src]. It now has [charges] charge[charges == 1 ? "" : "s"] remaining."))
	charge_timers.Add(addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time, TIMER_STOPPABLE))

/obj/item/card/emag/doorjack/proc/recharge(mob/user)
	charges = min(charges+1, max_charges)
	playsound(src,'sound/machines/twobeep.ogg',10,TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	charge_timers.Remove(charge_timers[1])

/obj/item/card/emag/doorjack/examine(mob/user)
	. = ..()
	. += span_notice("It has [charges] charges remaining.")
	if (length(charge_timers))
		. += "[span_notice("<b>A small display on the back reads:")]</b>"
	for (var/i in 1 to length(charge_timers))
		var/timeleft = timeleft(charge_timers[i])
		var/loadingbar = num2loadingbar(timeleft/charge_time)
		. += span_notice("<b>CHARGE #[i]: [loadingbar] ([DisplayTimeText(timeleft)])</b>")

/obj/item/card/emag/doorjack/can_emag(atom/target, mob/user)
	if (charges <= 0)
		to_chat(user, span_warning("[src] is recharging!"))
		return FALSE
	for (var/list/subtypelist in type_whitelist)
		if (target.type in subtypelist)
			return TRUE
	to_chat(user, span_warning("[src] is unable to interface with this. It only seems to fit into airlock electronics."))
	return FALSE

/*
 * Battlecruiser Access
 */
/obj/item/card/emag/battlecruiser
	name = "battlecruiser coordinates upload card"
	desc = "An ominous card that contains the location of the station, and when applied to a communications console, \
	the ability to long-distance contact the Syndicate fleet."
	icon_state = "battlecruisercaller"
	worn_icon_state = "emag"
	///whether we have called the battlecruiser
	var/used = FALSE
	/// The battlecruiser team that the battlecruiser will get added to
	var/datum/team/battlecruiser/team

/obj/item/card/emag/battlecruiser/proc/use_charge(mob/user)
	used = TRUE
	to_chat(user, span_boldwarning("You use [src], and it interfaces with the communication console. No going back..."))

/obj/item/card/emag/battlecruiser/examine(mob/user)
	. = ..()
	. += span_notice("It can only be used on the communications console.")

/obj/item/card/emag/battlecruiser/can_emag(atom/target, mob/user)
	if(used)
		to_chat(user, span_warning("[src] is used up."))
		return FALSE
	if(!istype(target, /obj/machinery/computer/communications))
		to_chat(user, span_warning("[src] is unable to interface with this. It only seems to interface with the communication console."))
		return FALSE
	return TRUE

/*
 * The Bot-Only Subverter
 */
/obj/item/card/emag/botemagger
	desc = "It's a card with a magnetic strip attached to some circuitry. It looks... off, somehow."
	name = "bot behavior sequencer"
	icon_state = "botmag"
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	/// Does usage require you to be in range?
	prox_check = TRUE
	var/type_whitelist //List of types

/obj/item/card/emag/botemagger/Initialize(mapload)
	. = ..()
	type_whitelist = list(typesof(/mob/living/basic/bot), typesof(/mob/living/simple_animal/bot)) //list of all acceptable typepaths that this device can affect

/obj/item/card/emag/botemagger/can_emag(atom/target, mob/user)
	for (var/list/subtypelist in type_whitelist)
		if (target.type in subtypelist)
			return TRUE
	to_chat(user, span_warning("[src] is unable to interface with this. It only seems to activate when in close proximity to simple bots."))
	return FALSE

/*
 * The Jestographic Sequencer
 */

/obj/item/card/emag/doorjack/jester
	name = "jestographic sequencer"
	desc = "It's a colorful card with electronics attached to it. The phrase 'Tastes like electromagnetic bananium.' is written on the back."
	icon_state = "jester"
	charge_time = 600 // 1 minute

/obj/item/card/emag/doorjack/jester/Initialize(mapload)
	. = ..()
	type_whitelist = list(typesof(/obj/machinery/door/airlock), typesof(/obj/machinery/door/window/)) //list of all acceptable typepaths that this device can affect

/obj/item/card/emag/doorjack/jester/interact_with_atom(atom/interacting_with, mob/living/user)
	if(!can_emag(interacting_with, user))
		return ITEM_INTERACT_BLOCKING
	log_combat(user, interacting_with, "attempted to jestergraph")
	if(istype(interacting_with, /obj/machinery/door/airlock)) // You'll have to forgive the 3 different of checks. I'm stupid and have brain rot. :(
		var/obj/machinery/door/airlock/jester_door = interacting_with
		jester_door.jester_act(user, src)
		playsound(jester_door, 'sound/items/bikehorn.ogg', 50, TRUE)
		return ITEM_INTERACT_SUCCESS
	if(istype(interacting_with, /obj/machinery/door/window))
		var/obj/machinery/door/window/jester_door = interacting_with
		jester_door.jester_act(user, src)
		playsound(jester_door, 'sound/items/bikehorn.ogg', 50, TRUE)
		return ITEM_INTERACT_SUCCESS
