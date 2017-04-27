GLOBAL_LIST_EMPTY(GPS_list)
/obj/item/device/gps
	name = "global positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016. Alt+click to toggle power."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;magnets=1;bluespace=2"
	unique_rename = TRUE
	var/gpstag = "COM0"
	var/emped = FALSE
	var/turf/locked_location
	var/tracking = TRUE

/obj/item/device/gps/Initialize()
	..()
	GLOB.GPS_list += src
	name = "global positioning system ([gpstag])"
	add_overlay("working")

/obj/item/device/gps/Destroy()
	GLOB.GPS_list -= src
	return ..()

/obj/item/device/gps/emp_act(severity)
	emped = TRUE
	cut_overlay("working")
	add_overlay("emp")
	addtimer(CALLBACK(src, .proc/reboot), 300, TIMER_OVERRIDE) //if a new EMP happens, remove the old timer so it doesn't reactivate early

/obj/item/device/gps/proc/reboot()
	emped = FALSE
	cut_overlay("emp")
	add_overlay("working")

/obj/item/device/gps/examine(mob/user)
	..()
	if(unique_rename)
		to_chat(user, "<span class='notice'>[src] can be changed by using a pen.</span>")

/obj/item/device/gps/AltClick(mob/user)
	if(!user.canUseTopic(src, be_close=TRUE))
		return //user not valid to use gps
	if(emped)
		to_chat(user, "It's busted!")
		return
	if(tracking)
		cut_overlay("working")
		to_chat(user, "[src] is no longer tracking, or visible to other GPS devices.")
		tracking = FALSE
	else
		add_overlay("working")
		to_chat(user, "[src] is now tracking, and visible to other GPS devices.")
		tracking = TRUE

/obj/item/device/gps/attack_self(mob/user)
	if(!tracking)
		to_chat(user, "[src] is turned off. Use alt+click to toggle it back on.")
		return

	var/obj/item/device/gps/t = ""
	var/gps_window_height = 110 + GLOB.GPS_list.len * 20 // Variable window height, depending on how many GPS units there are to show
	if(emped)
		t += "ERROR"
	else
		t += "<BR>Tag: [gpstag]"
		if(locked_location && locked_location.loc)
			t += "<BR>Bluespace coordinates saved: [locked_location.loc]"
			gps_window_height += 20

		for(var/obj/item/device/gps/G in GLOB.GPS_list)
			var/turf/pos = get_turf(G)
			var/area/gps_area = get_area(G)
			var/tracked_gpstag = G.gpstag
			if(G.emped == 1)
				t += "<BR>[tracked_gpstag]: ERROR"
			else if(G.tracking)
				t += "<BR>[tracked_gpstag]: [format_text(gps_area.name)] ([pos.x], [pos.y], [pos.z])"
			else
				continue
	var/datum/browser/popup = new(user, "GPS", name, 360, min(gps_window_height, 800))
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/item/device/gps/science
	icon_state = "gps-s"
	gpstag = "SCI0"

/obj/item/device/gps/engineering
	icon_state = "gps-e"
	gpstag = "ENG0"

/obj/item/device/gps/mining
	icon_state = "gps-m"
	gpstag = "MINE0"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."

/obj/item/device/gps/cyborg
	icon_state = "gps-b"
	gpstag = "BORG0"
	desc = "A mining cyborg internal positioning system. Used as a recovery beacon for damaged cyborg assets, or a collaboration tool for mining teams."
	flags = NODROP

/obj/item/device/gps/internal
	icon_state = null
	flags = ABSTRACT
	gpstag = "Eerie Signal"
	desc = "Report to a coder immediately."
	invisibility = INVISIBILITY_MAXIMUM

/obj/item/device/gps/mining/internal
	icon_state = "gps-m"
	gpstag = "MINER"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."

/obj/item/device/gps/internal/base
	gpstag = "NT_AUX"
	desc = "A homing signal from Nanotrasen's mining base."

/obj/item/device/gps/visible_debug
	name = "visible GPS"
	gpstag = "ADMIN"
	desc = "This admin-spawn GPS unit leaves the coordinates visible \
		on any turf that it passes over, for debugging. Especially useful \
		for marking the area around the transition edges."
	var/list/turf/tagged

/obj/item/device/gps/visible_debug/Initialize()
	. = ..()
	tagged = list()
	START_PROCESSING(SSfastprocess, src)

/obj/item/device/gps/visible_debug/process()
	var/turf/T = get_turf(src)
	if(T)
		// I assume it's faster to color,tag and OR the turf in, rather
		// then checking if its there
		T.color = RANDOM_COLOUR
		T.maptext = "[T.x],[T.y],[T.z]"
		tagged |= T

/obj/item/device/gps/visible_debug/proc/clear()
	while(tagged.len)
		var/turf/T = pop(tagged)
		T.color = initial(T.color)
		T.maptext = initial(T.maptext)

/obj/item/device/gps/visible_debug/Destroy()
	if(tagged)
		clear()
	tagged = null
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()
