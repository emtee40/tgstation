/obj/item/modular_computer/deconstruct(disassembled = TRUE)
	break_apart()
	return ..()

/obj/item/modular_computer/proc/break_apart()
	if(!(flags_1 & NODECONSTRUCT_1))
		physical.visible_message(span_notice("\The [src] breaks apart!"))
		var/turf/newloc = get_turf(src)
		new /obj/item/stack/sheet/iron(newloc, round(steel_sheet_cost/2))
	relay_qdel()
