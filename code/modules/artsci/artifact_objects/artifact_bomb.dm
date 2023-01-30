/datum/artifact/bomb
	weight = 0
	examine_hint = "It is covered in very conspicuous markings."
	valid_triggers = list(/datum/artifact_trigger/force, /datum/artifact_trigger/heat,/datum/artifact_trigger/shock,/datum/artifact_trigger/radiation,/datum/artifact_trigger/data) //no cold trigger incase it somehow spawns in space and maxcaps some poor carpies
	deactivation_message = "sputters a bit, and falls silent once more."
	var/dud = FALSE
	var/dud_message = "sputters, failing to activate! Its a dud!"
	var/inital_warning = "begins overloading, rattling violenty!"
	var/explode_delay = 1 MINUTES // also delayed by finale_delay for fluff
	var/explode_cooldown_time = 1 MINUTES
	var/finale_delay = 6 SECONDS //delay before we actually deliver the payload for fluff
	var/final_message = "reaches a catastrophic overload, cracks forming at its surface!"
	var/sound/active_alarm = 'sound/effects/alert.ogg' // plays every alarm_cooldown_time when active
	var/alarm_cooldown_time = 3 SECONDS
	var/sound/final_sound = 'sound/misc/bloblarm.ogg'
	COOLDOWN_DECLARE(activation_cooldown)
	COOLDOWN_DECLARE(alarm_cooldown)
	var/timer_id
	var/do_alert = FALSE //do we send an announcement on activation

/datum/artifact/bomb/setup()
	..()
	if(prob(20) && artifact_origin.type_name != ORIGIN_NARSIE) //cult likes killing people ok
		dud = TRUE

/datum/artifact/bomb/effect_activate()
	if(!COOLDOWN_FINISHED(src,explode_cooldown_time))
		holder.visible_message(span_warning("[holder] [deactivation_message]")) //rekt
		sleep(2)
		Deactivate()
		return
	holder.visible_message(span_bolddanger("[holder] [inital_warning]"))
	COOLDOWN_START(src,activation_cooldown,explode_cooldown_time)
	timer_id = addtimer(CALLBACK(src, PROC_REF(finale)), explode_delay, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
	if(do_alert && is_station_level(holder.z))
		priority_announce("A highly unstable object of type [type_name] has been activated at [get_area(holder)], GPS Coordinates [holder.x] [holder.y]. The crew is advised to get rid of it IMMEDIATELY.", null, SSstation.announcer.get_rand_report_sound(), has_important_message = TRUE)
	//animate(holder, pixel_y = rand(-3,3), pixel_x = rand(-3,3),time = 1, loop = 60)
/datum/artifact/bomb/effect_deactivate()
	deltimer(timer_id)

/datum/artifact/bomb/effect_process()
	. = ..()
	if(active && COOLDOWN_FINISHED(src,alarm_cooldown) && (COOLDOWN_TIMELEFT(src,alarm_cooldown) <= finale_delay))
		playsound(holder, active_alarm, 30, 1)
		var/pixel_x_diff = rand(-3, 3)
		var/pixel_y_diff = rand(-2,2)
		animate(holder, pixel_x = pixel_x_diff, pixel_y = pixel_y_diff , time = 0.2 SECONDS, loop = 6, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
		animate(pixel_x = -pixel_x_diff , pixel_y = -pixel_y_diff , time = 0.2 SECONDS, flags = ANIMATION_RELATIVE)
		COOLDOWN_START(src,alarm_cooldown, alarm_cooldown_time)

/datum/artifact/bomb/proc/finale()
	if(final_sound)
		playsound(holder.loc, final_sound, 100, 1, -1)
	if(finale_delay)
		holder.visible_message(span_bolddanger("[holder] [final_message]"))
		addtimer(CALLBACK(src, PROC_REF(payload)), finale_delay)
	else
		payload()

/datum/artifact/bomb/Destroyed(silent=FALSE)
	. = ..()
	if(active)
		payload()
		deltimer(timer_id)
/datum/artifact/bomb/proc/payload()
	. = TRUE
	if(dud)
		holder.visible_message(span_notice("[holder] [dud_message]"))
		Deactivate(silent=TRUE)
		return FALSE

/obj/structure/artifact/bomb
	assoc_datum = /datum/artifact/bomb/explosive

/datum/artifact/bomb/explosive
	associated_object = /obj/structure/artifact/bomb
	type_name = "Bomb (explosive)"
	weight = 700
	var/devast
	var/heavy
	var/light

/datum/artifact/bomb/explosive/New()
	..()
	devast = rand(1,3)
	heavy = rand(2,4)
	light = rand(3,10)

/datum/artifact/bomb/explosive/payload(silent=TRUE)
	if(!..())
		return FALSE
	explosion(holder, devast,heavy,light,light*1.5)
	Destroyed(silent = TRUE)

/obj/structure/artifact/bomb/devastating
	assoc_datum = /datum/artifact/bomb/explosive/devastating

/datum/artifact/bomb/explosive/devastating
	associated_object = /obj/structure/artifact/bomb/devastating
	type_name = "Bomb (explosive, devastating)"
	do_alert = TRUE
	weight = 550
	explode_delay = 2 MINUTES

/datum/artifact/bomb/explosive/devastating/New()
	..()
	devast = rand(3,7)
	heavy = rand(7,12)
	light = rand(10,25)

/obj/structure/artifact/bomb/chemical
	assoc_datum = /datum/artifact/bomb/chemical

/datum/artifact/bomb/chemical
	associated_object = /obj/structure/artifact/bomb/chemical
	type_name = "Bomb (chemical)"
	weight = 500
	explode_delay = 1 // so it dont complain
	explode_cooldown_time = 5 MINUTES
	finale_delay = 0
	var/smoke = FALSE // if false deliver via foam instead

/datum/artifact/bomb/chemical/setup()
	 . = ..()
	 smoke = prob(50)
	 inital_warning = "'s pores start releasing [smoke ? "a thick smoke!" : "foam!"]"