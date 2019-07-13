/obj/machinery/plumbing/pipeinput
	name = "pipe input"
	desc = "An input pipe, you put the liquids in here."
	icon_state = "input"
	volume = 100

obj/machinery/plumbing/pipeinput/Initialize()
	. = ..()
	create_reagents(volume, OPENCONTAINER | AMOUNT_VISIBLE)
	AddComponent(/datum/component/plumbing/input)

/obj/item/deployable/input
	name = "deployable input pipe"
	desc = "A self-deploying input pipe, just press the button to activate it."
	icon_state = "input_d"
	result = /obj/machinery/plumbing/pipeinput

/obj/machinery/plumbing/pipeoutput
	name = "pipe output"
	desc = "An output pipe, you can take the fluids from here with a container."
	icon_state = "output"
	volume = 100

/obj/machinery/plumbing/pipeoutput/Initialize()
	. = ..()
	create_reagents(volume, DRAINABLE|AMOUNT_VISIBLE)
	AddComponent(/datum/component/plumbing/output)

/obj/item/deployable/output
	name = "deployable output pipe"
	desc = "A self-deploying output pipe, just press the button to activate it."
	icon_state = "output_d"
	result = /obj/machinery/plumbing/pipeoutput