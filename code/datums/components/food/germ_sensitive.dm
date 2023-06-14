// Don't eat off the floor or hold parent object with dirty hands, you'll get sick

/// Time needed for bacteria to infect the parent object
#define GERM_EXPOSURE_DELAY (5 SECONDS) // Five-second rule
/// Max number of symptoms on the random disease
#define MAX_DISEASE_SYMPTOMS 2
/// Max strength of the random disease
#define MAX_DISEASE_STRENGTH 3

/// Makes edible items infective if left on floor, also sending corresponding signals to parent
/datum/component/germ_sensitive
	/// Timer for counting delay before becoming infective
	var/timer_id
	/// Whether it is already infective
	var/infective = FALSE

/datum/component/germ_sensitive/Initialize(mapload)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	ADD_TRAIT(parent, TRAIT_GERM_SENSITIVE, src)

	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(handle_movement))
	RegisterSignal(parent, COMSIG_ATOM_WASHED, PROC_REF(wash)) //Wash germs off dirty things

	RegisterSignals(parent, list(
		COMSIG_ITEM_DROPPED, //Dropped into the world
		COMSIG_ATOM_EXITED, //Object exits a storage object (tables, boxes, etc)
	),
	PROC_REF(dropped))

	RegisterSignals(parent, list(
		COMSIG_ITEM_PICKUP, //Picked up by mob
		COMSIG_ATOM_ENTERED, //Object enters a storage object (tables, boxes, etc.)
	),
	PROC_REF(picked_up))

	// Map spawned items are protected until moved
	if(!mapload)
		handle_movement()

/datum/component/germ_sensitive/UnregisterFromParent()
	REMOVE_TRAIT(parent, TRAIT_GERM_SENSITIVE, src)
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_MOVABLE_MOVED,
		COMSIG_ATOM_WASHED,
		COMSIG_ITEM_DROPPED,
		COMSIG_ATOM_EXITED,
		COMSIG_ITEM_PICKUP,
		COMSIG_ATOM_ENTERED,
	))

/datum/component/germ_sensitive/Destroy()
	remove_timer()
	return ..()

/datum/component/germ_sensitive/proc/remove_timer()
	if(!timer_id)
		return
	deltimer(timer_id)
	timer_id = null

/datum/component/germ_sensitive/proc/handle_movement()
	SIGNAL_HANDLER

	var/obj/parent_object = parent
	var/turf/open/open_turf = parent_object.loc

	// Is parent on valid open turf?
	if(!istype(open_turf) || islava(open_turf) || isasteroidturf(open_turf) || !parent_object.has_gravity())
		remove_timer()
		SEND_SIGNAL(parent, COMSIG_ATOM_GERM_UNEXPOSED, src)
		return

	// Is parent on an elevated structure?
	for(var/atom/movable/content as anything in open_turf.contents)
		if(GLOB.typecache_elevated_structures[content.type])
			remove_timer()
			SEND_SIGNAL(parent, COMSIG_ATOM_GERM_UNEXPOSED, src)
			return

	// Exposed to bacteria, start countdown until becoming infected
	timer_id = addtimer(CALLBACK(src, PROC_REF(expose_to_germs)), GERM_EXPOSURE_DELAY, TIMER_STOPPABLE | TIMER_UNIQUE)

/datum/component/germ_sensitive/proc/picked_up()
	SIGNAL_HANDLER
	SEND_SIGNAL(parent, COMSIG_ATOM_GERM_UNEXPOSED, src)
	remove_timer()

/datum/component/germ_sensitive/proc/dropped()
	SIGNAL_HANDLER
	handle_movement()

/datum/component/germ_sensitive/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(infective)
		examine_list += span_warning("[parent] looks dirty and not safe to consume.")

/datum/component/germ_sensitive/proc/expose_to_germs()
	// Admin spawned items are never exposed
	var/atom/parent_atom = parent
	if(parent_atom.flags_1 & ADMIN_SPAWNED_1)
		return

	SEND_SIGNAL(parent, COMSIG_ATOM_GERM_EXPOSED, src)

	if(infective)
		return
	infective = TRUE

	var/datum/disease/advance/random/random_disease = new(max_symptoms = rand(MAX_DISEASE_SYMPTOMS), max_level = rand(MAX_DISEASE_STRENGTH))
	random_disease.name = "Unknown"
	parent.AddComponent(/datum/component/infective, list(random_disease), weak = TRUE)

/datum/component/germ_sensitive/proc/wash()
	if(infective)
		infective = FALSE
		qdel(parent.GetComponent(/datum/component/infective))

#undef GERM_EXPOSURE_DELAY
#undef MAX_DISEASE_SYMPTOMS
#undef MAX_DISEASE_STRENGTH
