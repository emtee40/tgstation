#define TIMER_DEFAULT 0
#define TIMER_OLDEST 1
#define TIMER_NEWEST 2
#define TIMER_SHORTEST 3
#define TIMER_LONGEST 4

var/datum/subsystem/timer/SStimer

/datum/subsystem/timer
	name = "Timer"
	wait = 5
	priority = 1
	display = 3

	var/list/datum/timedevent/processing
	var/list/hashes
	var/list/unique

/datum/subsystem/timer/New()
	NEW_SS_GLOBAL(SStimer)
	processing = list()
	hashes = list()

/datum/subsystem/timer/stat_entry(msg)
	..("P:[processing.len]")

/datum/subsystem/timer/fire()
	if(!processing.len)
		can_fire = 0 //nothing to do, lets stop firing.
		return
	for(var/datum/timedevent/event in processing)
		if(!event.thingToCall || qdeleted(event.thingToCall))
			qdel(event)
		if(event.timeToRun <= world.time)
			runevent(event)
			qdel(event)

/datum/subsystem/timer/proc/runevent(datum/timedevent/event)
	set waitfor = 0
	call(event.thingToCall, event.procToCall)(arglist(event.argList))

/datum/timedevent
	var/thingToCall
	var/procToCall
	var/timeToRun
	var/argList
	var/id
	var/hash
	var/static/nextid = 1

/datum/timedevent/New()
	id = nextid
	nextid++

/datum/timedevent/Destroy()
	SStimer.processing -= src
	SStimer.hashes -= hash
	SStimer.unique -= hash
	return QDEL_HINT_IWILLGC

/proc/addtimer(thingToCall, procToCall, wait, unique = TIMER_DEFAULT, ...)
	if (!SStimer) //can't run timers before the mc has been created
		return
	if (!thingToCall || !procToCall || wait <= 0)
		return
	if (!SStimer.can_fire)
		SStimer.can_fire = 1
		SStimer.next_fire = world.time + SStimer.wait

	var/datum/timedevent/event = new()
	event.thingToCall = thingToCall
	event.procToCall = procToCall
	event.timeToRun = world.time + wait
	if(args.len > 4)
		event.argList = args.Copy(5)

	// Check for dupes if unique = 1.
	switch(unique)
		if(TIMER_DEFAULT)
			var/semihash = args.Copy(1,3)
			event.hash = jointext(semihash, null)
		if(TIMER_OLDEST) // Uses the first timer that was created.
			var/semihash = args.Copy(1,3)
			event.hash = jointext(semihash, null)
			if(event.hash in SStimer.unique)
				qdel(src)
				return
			SStimer.unique[event.hash] = event
		if(TIMER_NEWEST) // Uses the most recently created timer.
			var/semihash = args.Copy(1,3)
			event.hash = jointext(semihash, null)
			var/datum/timedevent/old = SStimer.unique[event.hash]
			if(old)
				SStimer.processing -= old // In case qdel doesnt get to it fast enough to remove it from the processing list.
				qdel(old)
			SStimer.unique[event.hash] = event
		if(TIMER_SHORTEST) // Uses the timer that will fire first.
			var/semihash = args.Copy(1,3)
			event.hash = jointext(semihash, null)
			var/datum/timedevent/old = SStimer.unique[event.hash]
			if(old)
				if(old.timeToRun <= event.timeToRun)
					qdel(src)
					return
				SStimer.processing -= old
				qdel(old)
			SStimer.unique[event.hash] = event
		if(TIMER_LONGEST) // Uses the timer that will fire last.
			var/semihash = args.Copy(1,3)
			event.hash = jointext(semihash, null)
			var/datum/timedevent/old = SStimer.unique[event.hash]
			if(old)
				if(old.timeToRun >= event.timeToRun)
					qdel(src)
					return
				SStimer.processing -= old
				qdel(old)
			SStimer.unique[event.hash] = event
		else
			event.hash = jointext(args, null)
			if(event.hash in SStimer.unique)
				qdel(src)
				return
			SStimer.unique[event.hash] = event

	// If we are unique (or we're not checking that), add the timer and return the id.
	SStimer.processing += event
	SStimer.hashes += event.hash
	return event.id

/proc/deltimer(id)
	for(var/datum/timedevent/event in SStimer.processing)
		if(event.id == id)
			qdel(event)
			return 1
	return 0
