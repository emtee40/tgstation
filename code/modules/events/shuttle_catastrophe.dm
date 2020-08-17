/datum/round_event_control/shuttle_catastrophe
	name = "Shuttle Catastrophe"
	typepath = /datum/round_event/shuttle_catastrophe
	weight = 10
	max_occurrences = 1

/datum/round_event/shuttle_catastrophe
	var/datum/map_template/shuttle/new_shuttle

/datum/round_event/shuttle_catastrophe/announce(fake)
	var/cause = pick("was attacked by [syndicate_name()] Operatives", "mysteriously teleported away", "had it's refuelling crew mutiny",
		"was found with it's engines stolen", "\[REDACTED\]", "flew into the sunset, and melted", "learned something from a very wise cow, and left on it's own",
		"\[REDACTED\]", "had cloning devices on it")

	priority_announce("Your emergency shuttle [cause]. Your replacement shuttle will be [new_shuttle.name] until further notice.", "CentCom Spacecraft Engineering")

/datum/round_event/shuttle_catastrophe/setup()
	var/list/valid_shuttle_templates = list()
	for(var/shuttle_id in SSmapping.shuttle_templates)
		var/datum/map_template/shuttle/template = SSmapping.shuttle_templates[shuttle_id]
		if(template.can_be_bought && template.credit_cost < INFINITY) //if we could get it from the communications console, it's cool for us to get it here
			valid_shuttle_templates += template
	new_shuttle = pick(valid_shuttle_templates)

/datum/round_event/shuttle_catastrophe/start()
	SSshuttle.shuttle_purchased = SHUTTLEPURCHASE_FORCED
	SSshuttle.unload_preview()
	SSshuttle.load_template(new_shuttle)
	SSshuttle.existing_shuttle = SSshuttle.emergency
	SSshuttle.action_load(new_shuttle)
	log_shuttle("Shuttle Catastrophe set a new shuttle, [new_shuttle.name].")
