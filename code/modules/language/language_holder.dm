/* 	Language Holders
*	Language holders live in two places, either in atom movables (mobs, vending machines, etc) or in a mind.
*	Accessing and using language holders should be done through the atom procs where possible.
*	If a mind holder is available, the atom holder will never be used for anything but update the mind holder on transfers and initial creation.
*	If an atom does not have a mind or loses it for some reason, the local holder will be used.
*/

/datum/language_holder
	/// Understood languages.
	var/list/understood_languages = list(/datum/language/common = list(LANGUAGE_MIND))
	/// A list of languages that can be spoken. Tongue organ may also set limits beyond this list.
	var/list/spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM))
	/// A list of blocked languages. Used to prevent understanding and speaking certain languages, ie for certain mobs, mutations etc.
	var/list/blocked_languages = list()
	/// If true, overrides spoken_languages and tongue limitations.
	var/omnitongue
	/// Handles displaying the language menu UI.
	var/datum/language_menu/language_menu
	/// Currently spoken language
	var/selected_language
	/// Tracks the entity that owns the holder.
	var/owner

/// Initializes, and copies in the languages from the current atom if available.
/datum/language_holder/New(_owner)
	owner = _owner
	if(istype(owner, /datum/mind))
		var/datum/mind/M = owner
		if(M.current)
			update_atom_languages(M.current)
	get_selected_language()

/datum/language_holder/Destroy()
	qdel(language_menu)
	return ..()

/// Grants the supplied language.
/datum/language_holder/proc/grant_language(language, understood = TRUE, spoken = TRUE, source = LANGUAGE_MIND)
	if(understood)
		if(!understood_languages[language])
			understood_languages += language
			understood_languages[language] = list()
		understood_languages[language] |= source
		. = TRUE
	if(spoken)
		if(!spoken_languages[language])
			spoken_languages += language
			spoken_languages[language] = list()
		spoken_languages[language] |= source
		. = TRUE

/// Grants every language to understood and spoken, and gives omnitongue.
/datum/language_holder/proc/grant_all_languages(understood = TRUE, spoken = TRUE, omni = TRUE, source = LANGUAGE_MIND)
	for(var/language in GLOB.all_languages)
		grant_language(language, understood, spoken, source)
	if(omni)	// Overrides tongue limitations.
		omnitongue = TRUE
	return TRUE

/// Removes a single language or source, removing all sources returns the pre-removal state of the language.
/datum/language_holder/proc/remove_language(language, understood = TRUE, spoken = TRUE, source = LANGUAGE_ALL)
	if(understood && understood_languages[language])
		if(source == LANGUAGE_ALL)
			understood_languages -= language
		else
			understood_languages[language] -= source
			if(!understood_languages[language].len)
				understood_languages -= language
		. = TRUE

	if(spoken && spoken_languages[language])
		if(source == LANGUAGE_ALL)
			spoken_languages -= language
		else
			spoken_languages[language] -= source
			if(!spoken_languages[language].len)
				spoken_languages -= language
		. = TRUE

/// Removes every language and optionally sets omnitongue false. If a non default source is supplied, only removes that source.
/datum/language_holder/proc/remove_all_languages(source = LANGUAGE_ALL, omni = FALSE)
	for(var/language in GLOB.all_languages)
		remove_language(language, TRUE, TRUE, source)
	if(omni)
		omnitongue = FALSE
	return TRUE

/// Adds a single language, list of languages or a list returned from get_known_languages to the blocked language list.
/datum/language_holder/proc/add_blocked_language(languages, source = LANGUAGE_MIND)
	var/list/all = list()
	if(!islist(languages))
		all |= languages
	if(languages["understood"] || languages["spoken"])
		if(languages["understood"])
			all |= languages["understood"]
		if(languages["spoken"])
			all |= languages["spoken"]
	else
		all |= languages
	for(var/language in all)
		if(!blocked_languages[language])
			blocked_languages += language
			blocked_languages[language] = list()
		blocked_languages[language] |= source
	return TRUE

/// Removes a single language, list of languages or a list returned from get_known_languages from the blocked language list.
/datum/language_holder/proc/remove_blocked_language(languages, source = LANGUAGE_MIND)
	var/list/all = list()
	if(!islist(languages))
		all |= languages
	if(languages["understood"] || languages["spoken"])
		if(languages["understood"])
			all |= languages["understood"]
		if(languages["spoken"])
			all |= languages["spoken"]
	else
		all |= languages
	for(var/language in all)
		if(blocked_languages[language])
			if(source == LANGUAGE_ALL)
				blocked_languages -= language
			else
				blocked_languages[language] -= source
				if(!blocked_languages[language].len)
					blocked_languages -= language
	return TRUE

/// Checks if you have the language. If spoken is true, only checks if you can speak the language.
/datum/language_holder/proc/has_language(language, spoken = FALSE)
	if(language in blocked_languages)
		return FALSE
	if(spoken)
		return language in spoken_languages
	return language in understood_languages

/// Checks if you can speak the language. Tongue limitations should be supplied as an argument.
/datum/language_holder/proc/can_speak_language(language, tongue = TRUE)
	if((omnitongue || tongue) && has_language(language, TRUE))
		return TRUE
	return FALSE

/// Returns selected language if it can be spoken, or decides, sets and returns a new selected language if possible.
/datum/language_holder/proc/get_selected_language()
	if(selected_language && can_speak_language(selected_language))
		return selected_language
	selected_language = null
	var/highest_priority
	var/list/spoken = spoken_languages.Copy()
	for(var/lang in spoken)
		var/datum/language/language = lang
		var/priority = initial(language.default_priority)
		if((!highest_priority || (priority > highest_priority)) && !(lang in blocked_languages))
			selected_language = language
			highest_priority = priority
	return selected_language

/// Gets a list of all the known langauges. Use this for populating blocking lists for mutations etc.
/datum/language_holder/proc/get_known_languages(understood = TRUE, spoken = TRUE)
	var/list/allknown = list()
	if(understood)
		allknown += "understood"
		allknown["understood"] = list()
		for(var/lang in understood_languages)
			allknown["understood"] += lang
	if(spoken)
		allknown += "spoken"
		allknown["spoken"] = list()
		for(var/lang in spoken_languages)
			allknown["spoken"] += lang
	return allknown

/// Gets a random understood language, useful for hallucinations and such.
/datum/language_holder/proc/get_random_understood_language()
	return pick(understood_languages)

/// Gets a random spoken language, useful for forced speech and such.
/datum/language_holder/proc/get_random_spoken_language()
	return pick(spoken_languages)

/// Opens a language menu reading from the language holder.
/datum/language_holder/proc/open_language_menu(mob/user)
	if(!language_menu)
		language_menu = new (src)
	language_menu.ui_interact(user)

/// Gets the atom, since we some times need to check if the tongue has limitations.
/datum/language_holder/proc/get_atom()
	if(owner)
		if(istype(owner, /datum/mind))
			var/datum/mind/M = owner
			return M.current
		return owner
	return FALSE

/// Empties out the atom specific languages and updates them according to the supplied atoms language holder.
/datum/language_holder/proc/update_atom_languages(atom/movable/thing)
	for(var/language in understood_languages)
		remove_language(language, TRUE, FALSE, LANGUAGE_ATOM)
	for(var/language in spoken_languages)
		remove_language(language, FALSE, TRUE, LANGUAGE_ATOM)
	blocked_languages.Cut()

	var/datum/language_holder/from_atom = thing.get_language_holder(FALSE)	// Gets the atoms language holder
	from_atom.copy_languages(src)
	get_selected_language()
	return TRUE

/// Copies and replaces holder into the supplied language holder.
/datum/language_holder/proc/copy_holder(var/datum/language_holder/to_holder)
	to_holder.understood_languages.Cut()
	to_holder.spoken_languages.Cut()
	to_holder.blocked_languages.Cut()

	copy_languages(to_holder)
	to_holder.omnitongue = omnitongue
	to_holder.selected_language = selected_language
	return TRUE

/// Copies all languages into the supplied language holder
/datum/language_holder/proc/copy_languages(var/datum/language_holder/to_holder)
	for(var/language in understood_languages)
		to_holder.grant_language(language, TRUE, FALSE, understood_languages[language])
	for(var/language in spoken_languages)
		to_holder.grant_language(language, FALSE, TRUE, spoken_languages[language])
	for(var/language in blocked_languages)
		to_holder.add_blocked_language(language)
	return TRUE


/************************************************
*        Specific language holders              *
*      Use atom language sources only.           *
************************************************/

/datum/language_holder/alien
	understood_languages = list(/datum/language/xenocommon = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/xenocommon = list(LANGUAGE_ATOM))
	blocked_languages = list(/datum/language/common = list(LANGUAGE_ATOM))

/datum/language_holder/construct
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/narsie = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/narsie = list(LANGUAGE_ATOM))

/datum/language_holder/drone
	understood_languages = list(/datum/language/drone = list(LANGUAGE_ATOM),
								/datum/language/machine = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/drone = list(LANGUAGE_ATOM))
	blocked_languages = list(/datum/language/common = list(LANGUAGE_ATOM))

/datum/language_holder/drone/syndicate
	blocked_languages = list()

/datum/language_holder/jelly
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/slime = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/slime = list(LANGUAGE_ATOM))

/datum/language_holder/lightbringer
	understood_languages = list(/datum/language/slime = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/slime = list(LANGUAGE_ATOM))
	blocked_languages = list(/datum/language/common = list(LANGUAGE_ATOM))

/datum/language_holder/lizard
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/draconic = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/draconic = list(LANGUAGE_ATOM))

/datum/language_holder/monkey
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/monkey = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/monkey = list(LANGUAGE_ATOM))

/datum/language_holder/mushroom
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/mushroom = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/mushroom = list(LANGUAGE_ATOM))

/datum/language_holder/slime
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/slime = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/slime = list(LANGUAGE_ATOM))

/datum/language_holder/swarmer
	understood_languages = list(/datum/language/swarmer = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/swarmer = list(LANGUAGE_ATOM))
	blocked_languages = list(/datum/language/common = list(LANGUAGE_ATOM))

/datum/language_holder/synthetic
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/machine = list(LANGUAGE_ATOM),
								/datum/language/draconic = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/machine = list(LANGUAGE_ATOM),
							/datum/language/draconic = list(LANGUAGE_ATOM))

/datum/language_holder/empty
	understood_languages = list()
	spoken_languages = list()

/datum/language_holder/universal/New()
	..()
	grant_all_languages()
