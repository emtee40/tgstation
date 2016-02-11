/mob/living/carbon/brain/death(gibbed)
	if(stat == DEAD)
		return
	stat = DEAD

	if(!gibbed && container && istype(container, /obj/item/device/mmi))//If not gibbed but in a container.
		var/obj/item/device/mmi = container
		mmi.visible_message("<span class='warning'>[src]'s MMI flatlines!</span>", \
					"<span class='italics'>You hear something flatline.</span>")
		mmi.update_icon()

	return ..()

/mob/living/carbon/brain/gib(animation = 0)
	if(container && istype(container, /obj/item/device/mmi))
		qdel(container)//Gets rid of the MMI if there is one
	if(loc)
		if(istype(loc,/obj/item/organ/internal/brain))
			qdel(loc)//Gets rid of the brain item
	..()