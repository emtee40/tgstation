/// Helper to open the panel
/datum/lootpanel/proc/open(turf/tile)
	source_turf = tile

#if !defined(OPENDREAM) && !defined(UNIT_TESTS)
	var/build = owner.byond_build
	var/version = owner.byond_version
	if(!notified)
		if(build < 515 || (build == 515 && version < 1635))
			to_chat(owner.mob, examine_block(span_info("\
				<span class='bolddanger'>Your version of Byond doesn't support fast image loading.</span>\n\
				Detected: [version].[build]\n\
				Required version for this feature: <b>515.1635</b> or later.\n\
				Visit <a href=\"https://secure.byond.com/download\">BYOND's website</a> to get the latest version of BYOND.\n\
			")))

			notified = TRUE
#endif

	populate_contents()
	ui_interact(owner.mob)


/// Used by SSlooting to process images from the to_image list.
/datum/lootpanel/proc/process_images()
	for(var/datum/search_object/index as anything in to_image)
		if(QDELETED(index) || index.icon)
			to_image -= index
			continue

		index.generate_icon(owner)
		to_image -= index

	var/datum/tgui/window = SStgui.get_open_ui(owner.mob, src)
	if(isnull(window))
		reset_contents()
		return

	window.send_update()
