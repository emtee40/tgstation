// A thing you can fish in
/datum/component/fishing_spot
	/// Defines the probabilities and fish availibilty
	var/datum/fish_source/fish_source

/datum/component/fishing_spot/Initialize(configuration)
	if(ispath(configuration,/datum/fish_source))
		//Create new one of the given type
		fish_source = new configuration
	else if(istype(configuration,/datum/fish_source))
		//Use passed in instance
		fish_source = configuration
	else
		/// Check if it's a preset key
		var/datum/fish_source/preset_configuration = GLOB.preset_fish_sources[configuration]
		if(!preset_configuration)
			stack_trace("Invalid fishing spot configuration \"[configuration]\" passed down to fishing spot component.")
			return COMPONENT_INCOMPATIBLE
		fish_source = preset_configuration
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/handle_attackby)
	RegisterSignal(parent, COMSIG_FISHING_ROD_CAST, .proc/handle_cast)


/datum/component/fishing_spot/proc/handle_cast(datum/source, obj/item/fishing_rod/rod, mob/user)
	SIGNAL_HANDLER
	. = NONE
	if(try_start_fishing(rod,user))
		return FISHING_ROD_CAST_HANDLED

/datum/component/fishing_spot/proc/handle_attackby(datum/source, obj/item/item, mob/user, params)
	SIGNAL_HANDLER
	. = NONE
	if(try_start_fishing(item,user))
		return COMPONENT_NO_AFTERATTACK

/datum/component/fishing_spot/proc/try_start_fishing(obj/item/possibly_rod, mob/user)
	SIGNAL_HANDLER
	var/obj/item/fishing_rod/rod = possibly_rod
	if(istype(rod))
		if(HAS_TRAIT(user,TRAIT_GONE_FISHING) || rod.currently_hooked_item)
			to_chat(user, span_notice("You're not good enough to fish in two places at once."))
			return COMPONENT_NO_AFTERATTACK
		var/denial_reason =  fish_source.can_fish(rod, user)
		if(denial_reason)
			to_chat(user, span_warning(denial_reason))
			return COMPONENT_NO_AFTERATTACK
		start_fishing_challenge(rod, user)
		return COMPONENT_NO_AFTERATTACK

/datum/component/fishing_spot/proc/start_fishing_challenge(obj/item/fishing_rod/rod, mob/user)
	/// Roll what we caught based on modified table
	var/result = fish_source.roll_reward(rod, user)
	var/datum/fishing_challenge/challenge = new(parent, result, rod, user)
	challenge.background = fish_source.background
	challenge.difficulty = fish_source.calculate_difficulty(result, rod, user)
	RegisterSignal(challenge, COMSIG_FISHING_CHALLENGE_COMPLETED, .proc/fishing_completed)
	challenge.start(user)

/datum/component/fishing_spot/proc/fishing_completed(datum/fishing_challenge/source, mob/user, success, perfect)
	if(success)
		fish_source.dispense_reward(source.reward_path, user)
