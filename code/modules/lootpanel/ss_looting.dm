
/// Queues image generation for search objects without icons
SUBSYSTEM_DEF(looting)
	name = "Loot Icon Generation"
	init_order = INIT_ORDER_LOOT
	priority = FIRE_PRIORITY_PROCESS
	wait = 0.5 SECONDS
	/// Backlog of items. Gets put into processing
	var/list/datum/lootpanel/backlog = list()
	/// Actively processing items
	var/list/datum/lootpanel/processing = list()


/datum/controller/subsystem/looting/stat_entry(msg)
	msg = "P:[length(backlog)]"
	return ..()


/datum/controller/subsystem/looting/fire(resumed)
	if(!length(backlog))
		return

	if(resumed)
		processing = backlog.Copy()

	processing = backlog
	backlog = list()

	while(length(processing))
		var/datum/lootpanel/panel = processing[length(processing)]
		if(QDELETED(panel) || !length(panel.to_image))
			processing.len--
			continue

		panel.process_images()	
		processing.len--

		if(MC_TICK_CHECK)
			return 
