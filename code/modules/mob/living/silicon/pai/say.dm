<<<<<<< HEAD
/mob/living/silicon/pai/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(silent)
		to_chat(src, "<span class='warning'>Communication circuits remain unitialized.</span>")
	else
		..(message)

/mob/living/silicon/pai/binarycheck()
	return 0
=======
/mob/living/silicon/pai/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(silent)
		to_chat(src, "<span class='warning'>Communication circuits remain unitialized.</span>")
	else
		..(message)

/mob/living/silicon/pai/binarycheck()
	return 0
>>>>>>> Updated this old code to fork
