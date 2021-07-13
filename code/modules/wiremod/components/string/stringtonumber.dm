/**
 * # String To Number Component
 *
 * Converts a string into a Number
 */
/obj/item/circuit_component/stringtonumber
	display_name = "String To Number"
	display_desc = "A component that converts its input to a number. If there's text in the input, it'll only consider it if it starts with a number. It will take that number and ignore the rest."

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/stringtonumber/Initialize()
	. = ..()
	input_port = add_input_port("Input", PORT_TYPE_STRING)

	output = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/circuit_component/stringtonumber/Destroy()
	input_port = null
	output = null
	return ..()

/obj/item/circuit_component/stringtonumber/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/input_value = input_port.input_value

	if(isnull(input_value))
		return

	var/output_value = text2num(input_value)

	output.set_output(output_value)

