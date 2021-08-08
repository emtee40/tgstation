/**
 * # NTNet Reciever Component
 *
 * Recieves data through NTNet.
 */

/obj/item/circuit_component/ntnet_receive
	display_name = "NTNet Receiver"
	desc = "Recieves data packages through NTNet. If Encryption Key is set then only signals with the same Encryption Key will be received."

	circuit_flags = CIRCUIT_FLAG_OUTPUT_SIGNAL //trigger_output

	network_id = __NETWORK_CIRCUITS

	var/datum/port/input/push_hid
	var/datum/port/output/hid
	var/datum/port/output/data_package
	var/datum/port/output/secondary_package
	var/datum/port/input/enc_key
	var/datum/port/input/option/data_type_options

/obj/item/circuit_component/ntnet_receive/Initialize()
	. = ..()
	AddComponent(/datum/component/ntnet_interface)
	push_hid = add_input_port("Get Hardware ID", PORT_TYPE_SIGNAL)
	hid = add_output_port("Hardware ID", PORT_TYPE_STRING)
	data_package = add_output_port("Data Package", PORT_TYPE_ANY)
	secondary_package = add_output_port("Secondary Package", PORT_TYPE_ANY)
	enc_key = add_input_port("Encryption Key", PORT_TYPE_STRING)
	RegisterSignal(src, COMSIG_COMPONENT_NTNET_RECEIVE, .proc/ntnet_receive)

/obj/item/circuit_component/ntnet_receive/populate_options()
	var/static/component_options = list(
		PORT_TYPE_ANY,
		PORT_TYPE_STRING,
		PORT_TYPE_NUMBER,
		PORT_TYPE_LIST,
		PORT_TYPE_ATOM,
	)
	data_type_options = add_option_port("Data Type", component_options)

/obj/item/circuit_component/ntnet_receive/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return
		
	if(COMPONENT_TRIGGERED_BY(data_type_options, port))
		data_package.set_datatype(data_type_options.input_value)
		secondary_package.set_datatype(data_type_options.input_value)
		
	if(COMPONENT_TRIGGERED_BY(push_hid, port))
		var/datum/component/ntnet_interface/ntnet_interface = GetComponent(/datum/component/ntnet_interface)
		hid.set_output(ntnet_interface.hardware_id)

/obj/item/circuit_component/ntnet_receive/proc/ntnet_receive(datum/source, datum/netdata/data)
	SIGNAL_HANDLER

	if(data.data["enc_key"] != enc_key.input_value)
		return

	data_package.set_output(data.data["data"])
	secondary_package.set_output(data.data["data_secondary"])
	trigger_output.set_output(COMPONENT_SIGNAL)
