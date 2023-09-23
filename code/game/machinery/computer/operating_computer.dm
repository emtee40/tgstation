#define MENU_OPERATION 1
#define MENU_SURGERIES 2

/obj/machinery/computer/operating
	name = "operating computer"
	desc = "Monitors patient vitals and displays surgery steps. Can be loaded with surgery disks to perform experimental procedures. Automatically syncs to operating tables within its line of sight for surgical tech advancement."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/operating

	var/list/advanced_surgeries = list()
	var/datum/techweb/linked_techweb
	light_color = LIGHT_COLOR_BLUE

	var/datum/component/experiment_handler/experiment_handler

	VAR_PRIVATE
		/// Tracks all possible patients, in order of most recent to least recent.
		// We don't need to worry about cleaning up the references when the components destroy, because the components
		// already mark all their patients as leaving on destruction, which will clear their reference.
		list/datum/operating_computer_patient/patients = list()

		/// What datums are linked to this computer?
		list/datum/links = list()

/obj/machinery/computer/operating/Initialize(mapload)
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !linked_techweb)
		linked_techweb = SSresearch.science_tech

	RegisterSignal(src, COMSIG_LINKS_TO_OPERATING_COMPUTERS_INITIALIZED, PROC_REF(on_links_to_operating_computers_initialized))

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/operating/LateInitialize()
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !linked_techweb)
		CONNECT_TO_RND_SERVER_ROUNDSTART(linked_techweb, src)

	SEND_SIGNAL(loc, COMSIG_OPERATING_COMPUTER_INITIALIZED, src)

	experiment_handler = AddComponent( \
		/datum/component/experiment_handler, \
		allowed_experiments = list(/datum/experiment/autopsy), \
		config_flags = EXPERIMENT_CONFIG_ALWAYS_ACTIVE, \
		config_mode = EXPERIMENT_CONFIG_ALTCLICK, \
	)

/obj/machinery/computer/operating/Destroy()
	QDEL_NULL(experiment_handler)
	links.Cut()
	patients.Cut()
	return ..()

/obj/machinery/computer/operating/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		linked_techweb = tool.buffer
	return TRUE

/obj/machinery/computer/operating/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/disk/surgery))
		user.visible_message(span_notice("[user] begins to load \the [O] in \the [src]..."), \
			span_notice("You begin to load a surgery protocol from \the [O]..."), \
			span_hear("You hear the chatter of a floppy drive."))
		var/obj/item/disk/surgery/D = O
		if(do_after(user, 10, target = src))
			advanced_surgeries |= D.surgeries
		return TRUE
	return ..()

/obj/machinery/computer/operating/proc/sync_surgeries()
	if(!linked_techweb)
		return
	for(var/i in linked_techweb.researched_designs)
		var/datum/design/surgery/D = SSresearch.techweb_design_by_id(i)
		if(!istype(D))
			continue
		advanced_surgeries |= D.surgery

/obj/machinery/computer/operating/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/obj/machinery/computer/operating/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OperatingComputer", name)
		ui.open()

/obj/machinery/computer/operating/ui_data(mob/user)
	var/list/data = list()
	var/list/all_surgeries = list()
	for(var/datum/surgery/surgeries as anything in advanced_surgeries)
		var/list/surgery = list()
		surgery["name"] = initial(surgeries.name)
		surgery["desc"] = initial(surgeries.desc)
		all_surgeries += list(surgery)
	data["surgeries"] = all_surgeries

	var/has_table = links.len > 0
	data["hasTable"] = has_table
	if (!has_table)
		return data

	var/mob/living/carbon/patient = get_patient()
	if (isnull(patient))
		return data

	data["advancedSurgeriesForbidden"] = !provide_upgraded_surgeries_to(patient)

	data["patient"] = list()
	switch(patient.stat)
		if(CONSCIOUS)
			data["patient"]["stat"] = "Conscious"
			data["patient"]["statstate"] = "good"
		if(SOFT_CRIT)
			data["patient"]["stat"] = "Conscious"
			data["patient"]["statstate"] = "average"
		if(UNCONSCIOUS, HARD_CRIT)
			data["patient"]["stat"] = "Unconscious"
			data["patient"]["statstate"] = "average"
		if(DEAD)
			data["patient"]["stat"] = "Dead"
			data["patient"]["statstate"] = "bad"
	data["patient"]["health"] = patient.health

	// check here to see if the patient has standard blood reagent, or special blood (like how ethereals bleed liquid electricity) to show the proper name in the computer
	var/blood_id = patient.get_blood_id()
	if(blood_id == /datum/reagent/blood)
		data["patient"]["blood_type"] = patient.dna?.blood_type
	else
		var/datum/reagent/special_blood = GLOB.chemical_reagents_list[blood_id]
		data["patient"]["blood_type"] = special_blood ? special_blood.name : blood_id

	data["patient"]["maxHealth"] = patient.maxHealth
	data["patient"]["minHealth"] = HEALTH_THRESHOLD_DEAD
	data["patient"]["bruteLoss"] = patient.getBruteLoss()
	data["patient"]["fireLoss"] = patient.getFireLoss()
	data["patient"]["toxLoss"] = patient.getToxLoss()
	data["patient"]["oxyLoss"] = patient.getOxyLoss()
	data["procedures"] = list()
	if(patient.surgeries.len)
		for(var/datum/surgery/procedure in patient.surgeries)
			var/datum/surgery_step/surgery_step = procedure.get_surgery_step()
			var/chems_needed = surgery_step.get_chem_list()
			var/alternative_step
			var/alt_chems_needed = ""
			if(surgery_step.repeatable)
				var/datum/surgery_step/next_step = procedure.get_surgery_next_step()
				if(next_step)
					alternative_step = capitalize(next_step.name)
					alt_chems_needed = next_step.get_chem_list()
				else
					alternative_step = "Finish operation"
			data["procedures"] += list(list(
				"name" = capitalize("[parse_zone(procedure.location)] [procedure.name]"),
				"next_step" = capitalize(surgery_step.name),
				"chems_needed" = chems_needed,
				"alternative_step" = alternative_step,
				"alt_chems_needed" = alt_chems_needed
			))
	return data

/obj/machinery/computer/operating/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("sync")
			sync_surgeries()
		if("open_experiments")
			experiment_handler.ui_interact(usr)
	return TRUE

/obj/machinery/computer/operating/proc/on_links_to_operating_computers_initialized(datum/source, datum/link, list/patients)
	SIGNAL_HANDLER

	if (link in links)
		return

	links += link

	RegisterSignal(link, COMSIG_QDELETING, PROC_REF(on_link_qdeleting))
	RegisterSignal(link, COMSIG_LINKS_TO_OPERATING_COMPUTERS_PATIENT_ADDED, PROC_REF(on_links_to_operating_computers_patient_added))
	RegisterSignal(link, COMSIG_LINKS_TO_OPERATING_COMPUTERS_PATIENT_REMOVED, PROC_REF(on_links_to_operating_computers_patient_removed))

	for (var/patient in patients)
		add_patient(patient, link)

/obj/machinery/computer/operating/proc/on_links_to_operating_computers_patient_added(datum/source, mob/living/carbon/patient)
	SIGNAL_HANDLER

	add_patient(patient, source)

/obj/machinery/computer/operating/proc/add_patient(mob/living/carbon/patient, datum/link)
	var/datum/operating_computer_patient/patient_data = new
	patient_data.patient = patient
	patient_data.link = link

	patients += patient_data

/obj/machinery/computer/operating/proc/on_links_to_operating_computers_patient_removed(datum/source, mob/living/carbon/patient)
	SIGNAL_HANDLER

	for (var/datum/operating_computer_patient/patient_data as anything in patients)
		if (patient_data.patient == patient && patient_data.link == source)
			patients -= patient_data
			return

/obj/machinery/computer/operating/proc/on_link_qdeleting(datum/source)
	SIGNAL_HANDLER
	links -= source

/// Gets the patient we should be operating on.
/// Prioritizes the oldest patient that has upgraded surgeries,
/// followed by the oldest patient otherwise.
/obj/machinery/computer/operating/proc/get_patient()
	RETURN_TYPE(/mob/living/carbon)

	if (patients.len == 0)
		return null

	for (var/datum/operating_computer_patient/patient_data as anything in patients)
		if (patient_data.link.provide_upgraded_surgeries)
			return patient_data.patient

	return patients[1].patient

/// Should this operating computer provide upgraded surgeries to the patient?
/// Will return TRUE if and only if this is a patient on a nearby table that allows it.
/obj/machinery/computer/operating/proc/provide_upgraded_surgeries_to(mob/living/patient)
	for (var/datum/operating_computer_patient/patient_data as anything in patients)
		if (patient_data.link.provide_upgraded_surgeries && patient_data.patient == patient)
			return TRUE

	return FALSE

/datum/operating_computer_patient
	var/mob/living/carbon/patient
	var/datum/component/links_to_operating_computers/link

#undef MENU_OPERATION
#undef MENU_SURGERIES
