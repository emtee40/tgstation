/obj/item/food/honeycomb
	name = "honeycomb"
	desc = "A hexagonal mesh of honeycomb."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "honeycomb"
	max_volume = 10
	food_reagents = list(/datum/reagent/consumable/honey = 5)
	tastes = list("honey" = 1)
	preserved_food = TRUE

	var/honey_color = ""

/obj/item/food/honeycomb/update_overlays()
	. = ..()
	var/mutable_appearance/honey_overlay = mutable_appearance(icon, "honey")
	if(honey_color)
		honey_overlay.icon_state = "greyscale_honey"
		honey_overlay.color = honey_color
		. += honey_overlay

/obj/item/food/honeycomb/proc/set_reagent(reagent)
	var/datum/reagent/R = GLOB.chemical_reagents_list[reagent]
	if(istype(R))
		name = "honeycomb ([R.name])"
		honey_color = R.color
		reagents.add_reagent(R.type,5)
	else
		honey_color = ""
	update_appearance()
