/mob/living/silicon/Login()
	if(mind && SSticker && SSticker.mode)
		SSticker.mode.remove_cultist(mind, 0, 0)
		SSticker.mode.remove_revolutionary(mind, 0)
		SSticker.mode.remove_gangster(mind, remove_bosses=1)
	..()
