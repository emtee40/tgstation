/obj/item/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices. Allows for syncing when using a secure signaler on another."
	icon_state = "signaller"
	inhand_icon_state = "signaler"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	custom_materials = list(/datum/material/iron=400, /datum/material/glass=120)
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE
	attachable = TRUE
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound =  'sound/items/handling/component_pickup.ogg'

	var/code = DEFAULT_SIGNALER_CODE
	var/frequency = FREQ_SIGNALER
	///Holds the mind that commited suicide.
	var/datum/mind/suicider
	///Holds a reference string to the mob, decides how much of a gamer you are.
	var/suicide_mob
	var/hearing_range = 1

/obj/item/assembly/signaler/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] eats \the [src]! If it is signaled, [user.p_they()] will die!</span>")
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE)
	moveToNullspace()
	suicider = user.mind
	suicide_mob = REF(user)
	return MANUAL_SUICIDE_NONLETHAL

/obj/item/assembly/signaler/proc/manual_suicide(datum/mind/suicidee)
	var/mob/living/user = suicidee.current
	if(!istype(user))
		return
	if(suicide_mob == REF(user))
		user.visible_message("<span class='suicide'>[user]'s [src] receives a signal, killing [user.p_them()] instantly!</span>")
	else
		user.visible_message("<span class='suicide'>[user]'s [src] receives a signal and [user.p_they()] die[user.p_s()] like a gamer!</span>")
	user.adjustOxyLoss(200)//it sends an electrical pulse to their heart, killing them. or something.
	user.death(0)
	user.set_suicide(TRUE)
	user.suicide_log()
	playsound(user, 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	qdel(src)

// if we care about radio, make sure frequency is NOT 0 when the device is created
// Otherwise the component was never installed
/obj/item/assembly/signaler/ComponentInitialize()
	AddComponent(/datum/component/radio_interface, frequency, radio_filter)
	RegisterSignal(src, COMSIG_RADIO_RECEIVE_DATA, .proc/receive_signal)


/obj/item/assembly/signaler/Destroy()
	SSradio.remove_object(src,frequency)
	suicider = null
	. = ..()

/obj/item/assembly/signaler/activate()
	if(!..())//cooldown processing
		return FALSE
	signal()
	return TRUE

/obj/item/assembly/signaler/update_icon()
	if(holder)
		holder.update_icon()
	return

/obj/item/assembly/signaler/ui_status(mob/user)
	if(is_secured(user))
		return ..()
	return UI_CLOSE

/obj/item/assembly/signaler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Signaler", name)
		ui.open()

/obj/item/assembly/signaler/ui_data(mob/user)
	var/list/data = list()
	data["frequency"] = frequency
	data["code"] = code
	data["minFrequency"] = MIN_FREE_FREQ
	data["maxFrequency"] = MAX_FREE_FREQ
	return data

/obj/item/assembly/signaler/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("signal")
			INVOKE_ASYNC(src, .proc/signal)
			. = TRUE
		if("freq")
			frequency = unformat_frequency(params["freq"])
			frequency = sanitize_frequency(frequency, TRUE)
			SEND_SIGNAL(src, COMSIG_RADIO_NEW_FREQUENCY, frequency)
			. = TRUE
		if("code")
			code = text2num(params["code"])
			code = round(code)
			. = TRUE
		if("reset")
			if(params["reset"] == "freq")
				frequency = initial(frequency)
				SEND_SIGNAL(src, COMSIG_RADIO_NEW_FREQUENCY, frequency)
			else
				code = initial(code)
			. = TRUE

	update_icon()

/obj/item/assembly/signaler/attackby(obj/item/W, mob/user, params)
	if(issignaler(W))
		var/obj/item/assembly/signaler/signaler2 = W
		if(secured && signaler2.secured)
			code = signaler2.code
			SEND_SIGNAL(src,COMSIG_RADIO_NEW_FREQUENCY, signaler2.frequency)
			to_chat(user, "You transfer the frequency and code of \the [signaler2.name] to \the [name]")
	..()

/obj/item/assembly/signaler/proc/signal()
	var/datum/signal/signal = new(list("code" = code))
	var/datum/component/radio_interface/radio_connection = GetComponent(/datum/component/radio_interface)
	radio_connection.broadcast(signal)

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)
	if(usr)
		GLOB.lastsignalers.Add("[time] <B>:</B> [usr.key] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]")

/obj/item/assembly/signaler/proc/receive_signal(datum/signal/signal)
	. = FALSE
	if(!signal)
		return
	if(signal.data["code"] != code)
		return
	if(!(src.wires & WIRE_RADIO_RECEIVE))
		return
	if(suicider)
		manual_suicide(suicider)
		return
	pulse(TRUE)
	audible_message("[icon2html(src, hearers(src))] *beep* *beep* *beep*", null, hearing_range)
	for(var/CHM in get_hearers_in_view(hearing_range, src))
		if(ismob(CHM))
			var/mob/LM = CHM
			LM.playsound_local(get_turf(src), 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	return TRUE


// Embedded signaller used in grenade construction.
// It's necessary because the signaler doens't have an off state.
// Generated during grenade construction.  -Sayu
/obj/item/assembly/signaler/receiver
	var/on = FALSE

/obj/item/assembly/signaler/receiver/proc/toggle_safety()
	on = !on

/obj/item/assembly/signaler/receiver/activate()
	toggle_safety()
	return TRUE

/obj/item/assembly/signaler/receiver/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The radio receiver is [on?"on":"off"].</span>"

/obj/item/assembly/signaler/receiver/receive_signal(datum/signal/signal)
	if(!on)
		return
	return ..(signal)

/obj/item/assembly/signaler/anomaly/attack_self()
	return

/obj/item/assembly/signaler/crystal_anomaly/attack_self()
	return

/obj/item/assembly/signaler/cyborg

/obj/item/assembly/signaler/cyborg/attackby(obj/item/W, mob/user, params)
	return
/obj/item/assembly/signaler/cyborg/screwdriver_act(mob/living/user, obj/item/I)
	return
