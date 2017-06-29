SUBSYSTEM_DEF(title)
	name = "Title Screen"
	flags = SS_NO_FIRE|SS_NO_INIT

	var/file_path
	var/mutable_appearance/map_badge
	var/icon/current_icon
	var/icon/previous_icon
	var/turf/closed/indestructible/splashscreen/splash_turf

/datum/controller/subsystem/title/PreInit()
	if(file_path && current_icon)
		return

	if(fexists("data/previous_title.dat"))
		var/previous_path = file2text("data/previous_title.dat")
		if(istext(previous_path))
			previous_icon = new(previous_icon)
	fdel("data/previous_title.dat")

	var/list/provisional_title_screens = flist("config/title_screens/images/")
	var/list/title_screens = list()
	var/use_rare_screens = prob(1)

	for(var/S in provisional_title_screens)
		var/list/L = splittext(S,"+")
		if((L.len == 1 && L[1] != "blank.png")|| (L.len > 1 && ((use_rare_screens && lowertext(L[1]) == "rare") || (lowertext(L[1]) == lowertext(SSmapping.config.map_name)))))
			title_screens += S

	if(!isemptylist(title_screens))
		if(length(title_screens) > 1)
			for(var/S in title_screens)
				var/list/L = splittext(S,".")
				if(L.len != 2 || L[1] != "default")
					continue
				title_screens -= S
				break

		file_path = "config/title_screens/images/[pick(title_screens)]"
		
		current_icon = new(fcopy_rsc(file_path))

	var/icon/mbi = new(SSmapping.config.badge_file)
	map_badge = new(mbi)
	map_badge.alpha = 150
	map_badge.pixel_x = (current_icon ? current_icon.Width() : 480) - mbi.Width()
	
	SyncAppearance()
	
/datum/controller/subsystem/title/proc/SyncAppearance()
	if(splash_turf)	
		splash_turf.icon = current_icon
		splash_turf.cut_overlays()
		splash_turf.add_overlay(map_badge)
		splash_turf.compile_overlays()	//high prio

/datum/controller/subsystem/title/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if("current_icon")
				SyncAppearance()

/datum/controller/subsystem/title/Shutdown()
	if(file_path)
		var/F = file("data/previous_title.dat")
		F << file_path

	for(var/thing in GLOB.clients)
		if(!thing)
			continue
		var/obj/screen/splash/S = new(thing, FALSE)
		S.Fade(FALSE,FALSE)

/datum/controller/subsystem/title/Recover()
	map_badge = SStitle.map_badge
	current_icon = SStitle.current_icon
	splash_turf = SStitle.splash_turf
	file_path = SStitle.file_path
	previous_icon = SStitle.previous_icon
