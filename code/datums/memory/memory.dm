///little tidbits of past events generated by the player doing things. can be used in engravings, dreams, and changeling succs.
///all of those things are supposed to be taken vaguely (engravings crossround and should not include names, dreams and succs are memory goop)
///and as such the generated text of the memory is vague. also, no references held so hard delling isn't an issue, thank god
/datum/memory
	///name of the memory the user sees
	var/name
	///job of the person performing the event
	var/memorizer
	///the action done to the target, see memory.dm in _DEFINES
	var/action
	///extra information used in the memories to more accurately describe what happened. Assoc list of key -> string identifying what kind of info it is, value is an atom or string identifying the detail.
	var/list/extra_info
	///mood of the person performing the event when they did it. changes the description.
	var/mood

/datum/memory/New(memorizer, action, extra_info, mood)
	. = ..()
	src.memorizer = memorizer
	src.action = action
	src.extra_info = extra_info
	src.mood = mood

	generate_memory_name()

/datum/memory/proc/generate_story(story_type, story_flags)
	var/list/story_pieces = list()

	//entirely independent vars (not related to the action or story type)

	var/list/something_pool = list(
		/mob/living/simple_animal/hostile/carp,
		/mob/living/simple_animal/hostile/bear,
		/mob/living/simple_animal/hostile/mushroom,
		/mob/living/simple_animal/hostile/statue,
		/mob/living/simple_animal/hostile/retaliate/bat,
		/mob/living/simple_animal/hostile/retaliate/goat,
		/mob/living/simple_animal/hostile/killertomato,
		/mob/living/simple_animal/hostile/giant_spider,
		/mob/living/simple_animal/hostile/giant_spider/hunter,
		/mob/living/simple_animal/hostile/blob/blobbernaut/independent,
		/mob/living/simple_animal/hostile/carp/ranged,
		/mob/living/simple_animal/hostile/carp/ranged/chaos,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher,
		/mob/living/simple_animal/hostile/asteroid/goliath/beast,
		/mob/living/simple_animal/hostile/headcrab,
		/mob/living/simple_animal/hostile/morph,
		/mob/living/simple_animal/hostile/stickman,
		/mob/living/simple_animal/hostile/stickman/dog,
		/mob/living/simple_animal/hostile/megafauna/dragon/lesser,
		/mob/living/simple_animal/hostile/gorilla,
		/mob/living/simple_animal/parrot,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/crab,
		/mob/living/simple_animal/pet/dog/pug,
		/mob/living/simple_animal/pet/cat,
		/mob/living/simple_animal/mouse,
		/mob/living/simple_animal/chicken,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/hostile/lizard,
		/mob/living/simple_animal/pet/fox,
		/mob/living/simple_animal/butterfly,
		/mob/living/simple_animal/pet/cat/cak,
		/mob/living/simple_animal/chick
	)

	var/tone_down_the_randomness = FALSE

	//story type dependent vars (engraving art)
	var/list/forewords = strings(MEMORY_FILE, story_type + "_forewords")
	var/list/somethings = strings(MEMORY_FILE, story_type + "_somethings")
	var/list/styles = strings(MEMORY_FILE, story_type + "_styles")
	var/list/randoms = somethings + styles

	//story action vars (surgery)
	var/list/story_starts = strings(MEMORY_FILE, action + "_starts")

	var/list/story_moods
	if(mood != MOODLESS_MEMORY)
		switch(mood)
			if(MOOD_LEVEL_HAPPY4 to MOOD_LEVEL_HAPPY2)
				story_moods = strings(MEMORY_FILE, "happy")
				if("[action]sad" in GLOB.string_cache[MEMORY_FILE])
					story_moods += strings(MEMORY_FILE, "[action]happy")
			if(MOOD_LEVEL_HAPPY2-1 to MOOD_LEVEL_SAD2+1)
				story_moods = strings(MEMORY_FILE, "neutral")
				if("[action]sad" in GLOB.string_cache[MEMORY_FILE])
					story_moods += strings(MEMORY_FILE, "[action]neutral")
			if(MOOD_LEVEL_SAD2 to MOOD_LEVEL_SAD4)
				story_moods = strings(MEMORY_FILE, "sad")
				if("[action]sad" in GLOB.string_cache[MEMORY_FILE])
					story_moods += strings(MEMORY_FILE, "[action]sad")

	//storybuilding

	story_pieces.Add(pick(forewords), pick(story_starts))
	if(prob(25))
		var/random = pick(randoms)
		story_pieces.Add(random)
		if(random in styles)
			randoms -= styles
		tone_down_the_randomness = TRUE
	if(LAZYLEN(story_moods))
		story_pieces.Add(pick(story_moods))
	if(prob(tone_down_the_randomness ? 30 : 70))
		story_pieces.Add(pick(randoms))

	//replacements

	for(var/line in story_pieces)
		for(var/key in extra_info)
			var/detail = extra_info[key]
			line = replacetext(line, "%[key]", "[detail]")
		line = replacetext(line, "%MEMORIZER", "\improper[memorizer]")
		line = replacetext(line, "%MOOD", pick(story_moods))
		var/mob/living/something = pick(something_pool)
		line = replacetext(line, "%SOMETHING", initial(something.name))

	//after replacement section for performance
	if(story_flags & STORY_FLAG_DATED)
		story_pieces.Add("This took place in [GLOB.year_integer+540].")

	return story_pieces.Join(" ")

/datum/memory/proc/generate_memory_name()
	var/names = strings(MEMORY_FILE, action + "_names")
	var/line = pick(names)
	for(var/key in extra_info)
		var/detail = extra_info[key]
		line = replacetext(line, "%[key]", "[detail]")


