/datum/experiment_type/clone
	name = "Clone"
	hidden = TRUE
	var/uses = 0

/datum/experiment/clone
	weight = 800
	experiment_type = /datum/experiment_type/clone

/datum/experiment/clone/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/datum/experiment_type/clone/mode = E.experiments[/datum/experiment_type/clone]
	if(!mode || mode.uses <= 0)
		. = FALSE

/datum/experiment/clone/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='notice'>A duplicate [O] pops out!</span>")
	E.investigate_log("Experimentor has cloned [O]", INVESTIGATE_EXPERIMENTOR)
	E.eject_item()
	var/turf/T = get_turf(pick(oview(1,src)))
	new O.type(T)
	var/datum/experiment_type/clone/mode = E.experiments[/datum/experiment_type/clone]
	if(mode)
		mode.uses--

/datum/experiment/bad_clone
	weight = 80
	is_bad = TRUE
	experiment_type = /datum/experiment_type/clone

/datum/experiment/bad_clone/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/datum/experiment_type/clone/mode = E.experiments[/datum/experiment_type/clone]
	if(!mode || mode.uses <= 0)
		. = FALSE

/datum/experiment/bad_clone/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='notice'>A duplicate [O] pops out!</span>")
	E.investigate_log("Experimentor has cloned [O], but it will melt sometime soon.", INVESTIGATE_EXPERIMENTOR)
	E.eject_item()
	var/turf/T = get_turf(pick(oview(1,src)))
	var/obj/item/NO = new O.type(T)
	addtimer(CALLBACK(src, .proc/melt, NO), rand(10,150) ** 2)
	var/datum/experiment_type/clone/mode = E.experiments[/datum/experiment_type/clone]
	if(mode)
		mode.uses--

/datum/experiment/bad_clone/proc/melt(obj/item/O)
	O.visible_message("<span class='notice'>[O] melts into a puddle of grey slag.</span>")
	new /obj/effect/decal/cleanable/molten_object(get_turf(O))
	qdel(O)