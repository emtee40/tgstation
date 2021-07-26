/**
 * # Multiplexer Component
 *
 * Routes one of multiple inputs into one of multiple outputs.
 */
/obj/item/circuit_component/multiplexer
	display_name = "Multiplexer"
	display_desc = "Don't know how to wire up your circuit? This lets the circuit decide."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// Which ports to connect.
	var/datum/port/input/nin
	var/datum/port/input/nout

	/// How many ports to have.
	var/input_port_amount = 4
	var/output_port_amount = 4

	/// Current type of the ports
	var/current_type

	/// The ports to route.
	var/list/datum/port/input/ins
	var/list/datum/port/input/outs

/obj/item/circuit_component/multiplexer/populate_options()
	var/static/component_options = list(
		PORT_TYPE_ANY,
		PORT_TYPE_STRING,
		PORT_TYPE_NUMBER,
		PORT_TYPE_LIST,
		PORT_TYPE_ATOM,
	)
	options = component_options

/obj/item/circuit_component/multiplexer/Initialize()
	. = ..()
	current_type = current_option
	nin = add_input_port("Input", PORT_TYPE_NUMBER, default = 1)
	nout = add_input_port("Output", PORT_TYPE_NUMBER, default = 1)
	ins = list()
	for(var/port_id in 1 to input_port_amount)
		ins += add_input_port("Port [port_id]", current_type)
	outs = list()
	for(var/port_id in 1 to output_port_amount)
		outs += add_output_port("Port [port_id]", current_type)

/obj/item/circuit_component/multiplexer/Destroy()
	ins.Cut()
	ins = null
	outs.Cut()
	outs = null
	return ..()


#define WRAPACCESS(L, I) L[(((I||1)-1)%length(L)+length(L))%length(L)+1]
/obj/item/circuit_component/multiplexer/input_received(datum/port/input/port)
	. = ..()
	if(current_type != current_option)
		current_type = current_option
		for(var/datum/port/input/input_port as anything in multiplexer_inputs)
			input_port.set_datatype(current_type)
		for(var/datum/port/input/output_port as anything in multiplexer_outputs)
			output_port.set_datatype(current_type)

	if(.)
		return
	WRAPACCESS(outs, nout.input_value).set_output(WRAPACCESS(ins,nin.input_value))

