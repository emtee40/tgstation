#define LOG_ERROR(list, error) if(list) { list.Add(error) }

// Determines if a port can have a predefined input value if it is of this type.
GLOBAL_LIST_INIT(circuit_dupe_whitelisted_types, list(
	PORT_TYPE_NUMBER,
	PORT_TYPE_STRING,
	PORT_TYPE_ANY,
))

/// Loads a circuit based on json data at a location. Can also load usb connections, such as arrest consoles.
/obj/item/integrated_circuit/proc/load_circuit_data(json_data, list/errors)
	var/list/general_data = json_decode(json_data)

	if(!general_data)
		LOG_ERROR(errors, "Invalid json format!")
		return

	if(general_data["display_name"])
		set_display_name(general_data["display_name"])

	var/list/circuit_data = general_data["components"]
	var/list/identifiers_to_circuit = list()
	for(var/identifier in circuit_data)
		var/list/component_data = circuit_data[identifier]
		var/type = text2path(component_data["type"])
		if(!ispath(type, /obj/item/circuit_component))
			LOG_ERROR(errors, "Invalid path for circuit component, expected [/obj/item/circuit_component], got [type]")
			continue
		var/obj/item/circuit_component/component = load_component(type)
		identifiers_to_circuit[identifier] = component
		component.load_data_from_list(component_data)

	var/list/external_objects = general_data["external_objects"]
	for(var/identifier in external_objects)
		var/list/object_data = external_objects[identifier]
		var/type = text2path(object_data["type"])
		if(!ispath(type))
			LOG_ERROR(errors, "Invalid path for external object, expected a path, got [type]")
			continue
		var/atom/movable/object = new type(drop_location())
		var/list/connected_components = list()
		for(var/component_id in object_data["connected_components"])
			var/obj/item/circuit_component/component = identifiers_to_circuit[component_id]
			if(!component)
				continue
			connected_components += component
		SEND_SIGNAL(object, COMSIG_MOVABLE_CIRCUIT_LOADED, src, connected_components)

	for(var/identifier in identifiers_to_circuit)
		var/obj/item/circuit_component/component = identifiers_to_circuit[identifier]
		var/list/component_data = circuit_data[identifier]

		var/list/connections = component_data["connections"]
		for(var/port_name in connections)
			var/datum/port/input/port
			var/list/connection_data = connections[port_name]
			for(var/datum/port/input/port_to_check as anything in component.input_ports)
				if(port_to_check.name == port_name)
					port = port_to_check
					break

			if(!port)
				LOG_ERROR(errors, "Port [port_name] not found for [component.type].")
				continue

			if(connection_data["stored_data"])
				if(!(port.datatype in GLOB.circuit_dupe_whitelisted_types))
					continue
				port.set_input(connection_data["stored_data"])
				continue

			var/obj/item/circuit_component/connected_component = identifiers_to_circuit[connection_data["component_id"]]
			if(!connected_component)
				LOG_ERROR(errors, "No connected component found for [component.type] for port [connection_data["port_name"]]. (connected component identifier: [connection_data["component_id"]])")
				continue

			var/datum/port/output/output_port
			var/output_port_name = connection_data["port_name"]
			for(var/datum/port/output/port_to_check as anything in connected_component.output_ports)
				if(port_to_check.name == output_port_name)
					output_port = port_to_check
					break

			if(!output_port)
				LOG_ERROR(errors, "No output port found for [component.type] for port [output_port_name] on component [connected_component.type]")
				continue

			port.register_output_port(output_port)

#undef LOG_ERROR

/// Converts a circuit into json.
/obj/item/integrated_circuit/proc/convert_to_json()
	var/list/circuit_to_identifiers = list()
	var/list/identifiers = list()
	var/list/external_objects = list() // Objects that are connected to a component. These objects will be linked to the components.
	for(var/obj/item/circuit_component/component as anything in attached_components)
		var/index = 1
		var/identifier = "[component.type][index]"
		while(identifier in identifiers)
			index++
			identifier = "[component.type][index]"
		identifiers += identifier
		circuit_to_identifiers[component] = identifier
		var/list/objects = list()
		SEND_SIGNAL(component, COMSIG_CIRCUIT_COMPONENT_SAVE, objects)

		for(var/atom/movable/object as anything in objects)
			if(object in external_objects)
				external_objects[object] += identifier
				continue
			external_objects[object] = list(identifier)

	var/list/circuit_data = list()
	for(var/obj/item/circuit_component/component as anything in circuit_to_identifiers)
		var/identifier = circuit_to_identifiers[component]
		var/list/component_data = list()

		component_data["type"] = component.type

		var/list/connections = list()
		for(var/datum/port/input/port as anything in component.input_ports)
			var/list/connection_data = list()
			var/datum/port/output/output_port = port.connected_port
			if(!output_port)
				if(isnull(port.input_value) || !(port.datatype in GLOB.circuit_dupe_whitelisted_types))
					continue
				connection_data["stored_data"] = port.input_value
				connections[port.name] = connection_data
				continue
			connection_data["component_id"] = circuit_to_identifiers[output_port.connected_component]
			connection_data["port_name"] = output_port.name
			connections[port.name] = connection_data
		component_data["connections"] = connections

		component.save_data_to_list(component_data)
		circuit_data[identifier] = component_data

	var/external_objects_key = list()
	for(var/atom/movable/object as anything in external_objects)
		var/list/new_data = list()
		new_data["type"] = object.type
		new_data["connected_components"] = external_objects[object]
		var/index = 1
		var/identifier = "[object.type][index]"
		while(identifier in external_objects_key)
			index++
			identifier = "[object.type][index]"
		external_objects_key[identifier] = new_data

	var/list/general_data = list()
	general_data["components"] = circuit_data
	general_data["external_objects"] = external_objects_key
	general_data["display_name"] = display_name

	return json_encode(general_data)

/obj/item/integrated_circuit/proc/load_component(type)
	var/obj/item/circuit_component/component = new type(src)
	add_component(component)
	return component

/// Saves data to a list. Shouldn't be used unless you are quite literally saving the data of a component to a list. Input value is the list to save the data to
/obj/item/circuit_component/proc/save_data_to_list(list/component_data)
	component_data["rel_x"] = rel_x
	component_data["rel_y"] = rel_y

	component_data["option"] = current_option

/// Loads data from a list
/obj/item/circuit_component/proc/load_data_from_list(list/component_data)
	rel_x = component_data["rel_x"]
	rel_y = component_data["rel_y"]

	set_option(component_data["option"])

/client/proc/load_circuit()
	set name = "Load Circuit"
	set category = "Admin.Fun"

	if(!check_rights(R_ADMIN) || !check_rights(R_FUN))
		return

	var/list/errors = list()

	var/option = alert(usr, "Load by file or direct input?", "Load by file or string", "File", "Direct Input")
	var/txt
	switch(option)
		if("File")
			txt = file2text(input(usr, "Input File") as file|null)
		if("Direct Input")
			txt = input(usr, "Input JSON", "Input JSON") as text|null

	if(!txt)
		return

	var/obj/item/integrated_circuit/loaded/circuit = new(mob.drop_location())
	circuit.load_circuit_data(txt, errors)

	if(length(errors))
		to_chat(src, span_warning("The following errors were found whilst compiling the circuit data:"))
		for(var/error in errors)
			to_chat(src, span_warning(error))
