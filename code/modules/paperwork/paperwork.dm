/**
 * # Paperwork
 *
 * Paperwork documents that can be stamped by their associated stamp to provide a bonus to cargo.
 *
 * Paperwork documents are a cargo item meant to provide the opportunity to make money.
 * Each piece of paperwork has its own associated stamp it needs to be stamped with. Selling a
 * properly stamped piece of paperwork will provide a cash bonus to the cargo budget. If a document is
 * not properly stamped it will instead drain a small stipend from the cargo budget.
 *
 */

/obj/item/paperwork
	name = "paperwork documents"
	desc = "A disorganized mess of documents, research results, and investigation findings."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "docs_part"
	inhand_icon_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	layer = MOB_LAYER
	///The stamp overlay, used to show that the paperwork is complete without making a bunch of sprites
	var/mutable_appearance/stamp_overlay
	///The specific stamp icon to be overlaid on the paperwork
	var/stamp_icon = "paper_stamp-void"
	///The stamp needed to "complete" this form.
	var/stamp_requested = /obj/item/stamp/void
	///Has the paperwork been properly stamped
	var/stamped = FALSE
	///The path to the job of the associated paperwork form
	var/stamp_job
	///Used to store the bonus text that displays when the paperwork's associated role reads it
	var/detailed_desc

/obj/item/paperwork/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()

	if(!stamped)
		if(istype(attacking_item, /obj/item/stamp))
			if(istype(attacking_item, stamp_requested) || istype(attacking_item, stamp_requested)) //chameleon stamp does not work, this is a CRITICAL issue
				add_stamp()
				to_chat(user, span_notice("You skim through the papers until you find a field reading 'STAMP HERE', and complete the paperwork."))
			else
				to_chat(user, span_warning("You hunt through the papers for somewhere to use the [attacking_item], but can't find anything."))

/obj/item/paperwork/update_overlays()
	. = ..()

	if(stamped && stamp_overlay)
		. += stamp_overlay

/obj/item/paperwork/examine_more(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/viewer = user
		if(istype(viewer.mind?.assigned_role, stamp_job)) //Examining the paperwork as the proper job gets you some bonus details
			. += detailed_desc
		else
			if(stamped)
				. += span_info("It looks like these documents have already been stamped. Now they can be returned to Central Command.")
			else
				var/datum/job/stamp_title = stamp_job
				var/title = initial(stamp_title.title)
				. += span_info("Trying to read through it makes your head spin. Judging by the few words you can make out, this looks like a job for the [title].")

/**
 * Adds the stamp overlay and sets "stamped" to true
 *
 * Adds the stamp overlay to a piece of paperwork, and sets "stamped" to true.
 * Handled as a proc so that an object may be maked as "stamped" even when a stamp isn't present (like the photocopier)
 */
/obj/item/paperwork/proc/add_stamp()
	stamp_overlay = mutable_appearance('icons/obj/bureaucracy.dmi', stamp_icon)
	add_overlay(stamp_overlay)
	stamped = TRUE

/**
 * Copies the requested stamp, associated job, and associated icon of a given paperwork type
 *
 * Copies the stamp/job related info of a given paperwork type to the object
 * Used to mutate photocopied/ancient paperwork into behaving like their subtype counterparts without the extra details
 */
/obj/item/paperwork/proc/copy_stamp_info(/obj/item/paperwork/paperwork_type)
	stamp_requested = initial(paperwork_type.stamp_requested)
	stamp_job =  initial(paperwork_type.stamp_job)
	stamp_icon =  initial(paperwork_type.stamp_icon)

//HEAD OF STAFF DOCUMENTS

/obj/item/paperwork/cargo
	stamp_requested = /obj/item/stamp/qm
	stamp_job = /datum/job/quartermaster
	stamp_icon = "paper_stamp-qm"

/obj/item/paperwork/cargo/Initialize()
	. = ..()
	detailed_desc = span_notice("<i>As you sift through the papers, you slowly start to piece together what you're reading.</i>")
	detailed_desc += "[span_info(" The papers are a mess of shipping order paperwork. There's no rhyme or reason to how these documents are sorted at all.")]"
	detailed_desc += "[span_info(" By the looks of it, there's nothing out of the ordinary here besides a high-priority request for a second engine.")]"
	detailed_desc += "[span_info(" The 'priority request reason' field is scribbled out, but a note in the margins reads 'we just want to try two engines, don't worry about it'.")]"
	detailed_desc += "[span_info(" Despite how disorganized the documents are, they're all appropriately filled in. You should probably stamp this.")]"

/obj/item/paperwork/security
	stamp_requested = /obj/item/stamp/hos
	stamp_job = /datum/job/head_of_security
	stamp_icon = "paper_stamp-hos"

/obj/item/paperwork/security/Initialize()
	. = ..()

	detailed_desc = span_notice("<i>As you sift through the papers, you slowly start to piece together what you're reading.</i>")
	detailed_desc += "[span_info(" The stack of documents are related to a civil case being processed by a neighboring installation.")]"
	detailed_desc += "[span_info(" The document requests that you review a conduct report submitted by the lawyer of the station.")]"
	detailed_desc += "[span_info(" The case file details accusations against the station's security department, including misconduct, harassment, an-")]"
	detailed_desc += "[span_info(" What a bunch of crap, the security team were clearly just doing what they had to. You should probably stamp this.")]"

/obj/item/paperwork/service
	stamp_requested = /obj/item/stamp/hop
	stamp_job = /datum/job/head_of_personnel
	stamp_icon = "paper_stamp-hop"

/obj/item/paperwork/service/Initialize()
	. = ..()

	detailed_desc = span_notice("<i>As you sift through the papers, you slowly start to piece together what you're reading.</i>")
	detailed_desc += "[span_info(" Your begin scanning over the document. This is a standard Nanotrasen NT-435Z3 form used for requests to Central Command.")]"
	detailed_desc += "[span_info(" Looks like a nearby station has sent in a MAXIMUM priority request for coal, in seemingly ridiculous quantities.")]"
	detailed_desc += "[span_info(" The reason listed for the request seems to be hastily filled in -- 'Seeking alternative methods to power the station.'")]"
	detailed_desc += "[span_info(" A MAXIMUM priority request like this is nothing to balk at. You should probably stamp this.")]"

/obj/item/paperwork/medical
	stamp_requested = /obj/item/stamp/cmo
	stamp_job = /datum/job/chief_medical_officer
	stamp_icon = "paper_stamp-cmo"

/obj/item/paperwork/medical/Initialize()
	. = ..()

	detailed_desc = span_notice("<i>As you sift through the papers, you slowly start to piece together what you're reading.</i>")
	detailed_desc += "[span_info(" The stack of documents appear to be a medical report from a nearby station, detailing the autopsy of an unknown xenofauna.")]"
	detailed_desc += "[span_info(" Skipping to the end of the report reveals that the specimen was the station bartender's pet monkey.")]"
	detailed_desc += "[span_info(" The specimen had been exposed to radiation during an 'unrelated incident with the engine', leading to it's mutated form.")]"
	detailed_desc += "[span_info(" Regardless, the autopsy results look like they could be useful. You should probably stamp this.")]"


/obj/item/paperwork/engineering
	stamp_requested = /obj/item/stamp/ce
	stamp_job = /datum/job/chief_engineer
	stamp_icon = "paper_stamp-ce"

/obj/item/paperwork/engineering/Initialize()
	. = ..()

	detailed_desc = span_notice("<i>As you sift through the papers, you slowly start to piece together what you're reading.</i>")
	detailed_desc += "[span_info(" These papers are a power output report from a neighboring station. It details the power output and other engineering data regarding the station during a typical shift.")]"
	detailed_desc += "[span_info(" Checking the logs, you notice the energy output and engine temperature spike dramatically, and shortly after, the surrounding department appears to be depressurized by an unknown force.")]"
	detailed_desc += "[span_info(" Clearly the station's engineering department was testing an experimental engine setup, and had to use the air in the nearby rooms to help cool the engine. Totally.")]"
	detailed_desc += "[span_info(" Damn, that's impressive stuff. You should probably stamp this.")]"

/obj/item/paperwork/research
	stamp_requested = /obj/item/stamp/rd
	stamp_job = /datum/job/research_director
	stamp_icon = "paper_stamp-rd"

/obj/item/paperwork/research/Initialize()
	. = ..()

	detailed_desc = span_notice("<i>As you sift through the papers, you slowly start to piece together what you're reading.</i>")
	detailed_desc += "[span_info(" The documents detail the results of a standard ordnance test that occured on a nearby station.")]"
	detailed_desc += "[span_info(" As you read further, you realize something strange with the results -- The epicenter doesn't seem to be correct.")]"
	detailed_desc += "[span_info(" If your math is correct, this explosion didn't happen at the station's ordnance site, it occured in the station's engine room.")]"
	detailed_desc += "[span_info(" Regardless, they're still perfectly usable test results. You should probably stamp this.")]"

/obj/item/paperwork/captain
	stamp_requested = /obj/item/stamp/captain
	stamp_job = /datum/job/captain
	stamp_icon = "paper_stamp-cap"

/obj/item/paperwork/captain/Initialize()
	. = ..()

	detailed_desc = span_notice("<i>As you sift through the papers, you slowly start to piece together what you're reading.</i>")
	detailed_desc += "[span_info(" The documents are an unsigned correspondence from the captain's desk of a nearby station.")]"
	detailed_desc += "[span_info(" It seems to be a standard check-in message, reporting that the station is functioning at optimal efficiency.")]"
	detailed_desc += "[span_info(" The message repeatedly asserts that the engine is functioning 'perfectly fine' and is generating 'buttloads' of power.")]"
	detailed_desc += "[span_info(" Everything checks out. You should probably stamp this.")]"

//Photocopied paperwork. These are created when paperwork, whether stamped or otherwise, is printed. If it is stamped, it can be sold to cargo at the risk of the paperwork not being accepted (which takes a small fee from cargo).
//If it is unstamped it will lose you money like normal, unless it has been marked with a VOID stamp
/obj/item/paperwork/photocopy
	name = "photocopied paperwork documents"
	desc = "An even more disorganized mess of photocopied documents and paperwork. Did these even copy in the right order?"
	stamp_icon = "paper_stamp-pc"
	/// Has the photocopy been marked with a "void" stamp. Used to prevent documents from draining money if they somehow make their way to cargo.
	var/voided = FALSE

/obj/item/paperwork/photocopy/examine_more(mob/user)
	. = ..()

	if(stamped)
		if(voided)
			. += span_notice("It looks like it's been marked as 'VOID' on the front. It's unlikely that anyone will accept these now.")
		else
			. += span_notice("The stamp on the front appears to be smudged and faded. Central Command will probably still accept these, right?")
	else
		. += span_notice("These appear to just be a photocopy of the original documents.")

/obj/item/paperwork/photocopy/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/stamp/void) && !stamped && !voided)
		to_chat(user, span_notice("You plant the [attacking_item] firmly onto the front of the documents."))
		stamp_overlay = mutable_appearance('icons/obj/bureaucracy.dmi', "paper_stamp-void")
		add_overlay(stamp_overlay)
		voided = TRUE
		stamped = TRUE //It won't get you any money, but it also can't LOSE you money now.

//Ancient paperwork is a subtype of paperwork, meant to be used for any paperwork not spawned by the event.
//It doesn't have any of the flavor text that the event ones spawn with.

/obj/item/paperwork/ancient
	name = "ancient paperwork"
	desc = "A dusty, ugly mess of paper scraps. You can't recognize a single name, date, or topic mentioned within. How old are these?"

/obj/item/paperwork/ancient/Initialize(mapload)
	. = ..()

	detailed_desc += span_notice("It's impossible to really tell how old these are or what they're for, but Central Command might appreciate them anyways.")

	var/list/paperwork_list = subtypesof(/obj/item/paperwork) //Make the ancient paperwork function like one of the main types
	paperwork_list.Remove(list(/obj/item/paperwork/ancient, /obj/item/paperwork/photocopy)) //Get rid of the uncopiable paperwork types
	var/obj/item/paperwork/paperwork_type = pick(paperwork_list)
	copy_stamp_info(paperwork_type)
