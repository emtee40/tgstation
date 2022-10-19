/datum/computer_file/program/filemanager
	filename = "filemanager"
	filedesc = "File Manager"
	extended_desc = "This program allows management of files."
	program_icon_state = "generic"
	size = 8
	requires_ntnet = FALSE
	available_on_ntnet = FALSE
	undeletable = TRUE
	tgui_id = "NtosFileManager"
	program_icon = "folder"

	var/open_file
	var/error

/datum/computer_file/program/filemanager/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/obj/item/computer_hardware/hard_drive/RHDD = computer.all_components[MC_SDD]

	switch(action)
		if("PRG_deletefile")
			var/datum/computer_file/file = computer.find_file_by_name(params["name"])
			if(!file || file.undeletable)
				return
			computer.remove_file(file)
			return TRUE
		if("PRG_usbdeletefile")
			if(!RHDD)
				return
			var/datum/computer_file/file = RHDD.find_file_by_name(params["name"])
			if(!file || file.undeletable)
				return
			RHDD.remove_file(file)
			return TRUE
		if("PRG_renamefile")
			var/datum/computer_file/file = computer.find_file_by_name(params["name"])
			if(!file)
				return
			var/newname = reject_bad_name(params["new_name"])
			if(!newname || newname != params["new_name"])
				playsound(computer, 'sound/machines/terminal_error.ogg', 25, FALSE)
				return
			file.filename = newname
			return TRUE
		if("PRG_usbrenamefile")
			if(!RHDD)
				return
			var/datum/computer_file/file = RHDD.find_file_by_name(params["name"])
			if(!file)
				return
			var/newname = reject_bad_name(params["new_name"])
			if(!newname || newname != params["new_name"])
				playsound(computer, 'sound/machines/terminal_error.ogg', 25, FALSE)
				return
			file.filename = newname
			return TRUE
		if("PRG_copytousb")
			if(!RHDD)
				return
			var/datum/computer_file/F = computer.find_file_by_name(params["name"])
			if(!F)
				return
			var/datum/computer_file/C = F.clone(FALSE)
			computer.store_file(C)
			return TRUE
		if("PRG_copyfromusb")
			if(!RHDD)
				return
			var/datum/computer_file/F = RHDD.find_file_by_name(params["name"])
			if(!F || !istype(F))
				return
			var/datum/computer_file/C = F.clone(FALSE)
			computer.store_file(C)
			return TRUE
		if("PRG_togglesilence")
			var/datum/computer_file/program/binary = computer.find_file_by_name(params["name"])
			if(!binary || !istype(binary))
				return
			binary.alert_silenced = !binary.alert_silenced

/datum/computer_file/program/filemanager/ui_data(mob/user)
	var/list/data = get_header_data()

	var/obj/item/computer_hardware/hard_drive/portable/RHDD = computer.all_components[MC_SDD]
	if(error)
		data["error"] = error
	if(!computer)
		data["error"] = "I/O ERROR: Unable to access hard drive."
	else
		var/list/files = list()
		for(var/datum/computer_file/F as anything in computer.stored_files)
			var/noisy = FALSE
			var/silenced = FALSE
			var/datum/computer_file/program/binary = F
			if(istype(binary))
				noisy = binary.alert_able
				silenced = binary.alert_silenced
			files += list(list(
				"name" = F.filename,
				"type" = F.filetype,
				"size" = F.size,
				"undeletable" = F.undeletable,
				"alert_able" = noisy,
				"alert_silenced" = silenced
			))
		data["files"] = files
		if(RHDD)
			data["usbconnected"] = TRUE
			var/list/usbfiles = list()
			for(var/datum/computer_file/F in RHDD.stored_files)
				usbfiles += list(list(
					"name" = F.filename,
					"type" = F.filetype,
					"size" = F.size,
					"undeletable" = F.undeletable
				))
			data["usbfiles"] = usbfiles

	return data
