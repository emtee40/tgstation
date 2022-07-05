/*!
 * Custom rendering solution to allow for advanced effects
 * We (ab)use plane masters and render source/target to cheaply render 2+ planes as 1
 * if you want to read more read the _render_readme.md
 */


/**
 * Render relay object assigned to a plane master to be able to relay it's render onto other planes that are not it's own
 */
/atom/movable/render_plane_relay
	screen_loc = "CENTER"
	layer = -1
	plane = 0
	appearance_flags = PASS_MOUSE | NO_CLIENT_COLOR | KEEP_TOGETHER

/**
 * ## Rendering plate
 *
 * Acts like a plane master, but for plane masters
 * Renders other planes onto this plane, through the use of render objects
 * Any effects applied onto this plane will act on the unified plane
 * IE a bulge filter will apply as if the world was one object
 * remember that once planes are unified on a render plate you cant change the layering of them!
 */
/atom/movable/screen/plane_master/rendering_plate
	name = "default rendering plate"


///this plate renders the final screen to show to the player
/atom/movable/screen/plane_master/rendering_plate/master
	name = "master rendering plate"
	documentation = "The endpoint of all plane masters, you can think of this as the final \"view\" we draw.\
		<br>If offset is not 0 this will be drawn to the transparent plane of the floor above, but otherwise this is drawn to nothing, or shown to the player."
	plane = RENDER_PLANE_MASTER
	render_relay_planes = list()
	generate_render_target = FALSE

// Master plates relay their render "up" to the transparent floor a level above them
/atom/movable/screen/plane_master/rendering_plate/master/update_offset()
	name = "[initial(name)] #[offset]"
	SET_PLANE_W_SCALAR(src, real_plane, offset)
	render_relay_planes = list()
	if(offset)
		generate_render_target = TRUE
		// We're gonna layer up to the transparent floor
		// Basically we're passing our rendering "up" the pipeline
		render_relay_planes += GET_NEW_PLANE(TRANSPARENT_FLOOR_PLANE, offset - 1)
	else
		generate_render_target = FALSE
	if(initial(render_target))
		render_target = "[initial(render_target)] #[offset]"

///renders general in charachter game objects
/atom/movable/screen/plane_master/rendering_plate/game_world
	name = "game rendering plate"
	documentation = "Holds all objects that are ahhh, in character? is maybe the best way to describe it.\
		<br>We apply a displacement effect from the gravity pulse plane too, so we can warp the game world."
	plane = RENDER_PLANE_GAME
	render_relay_planes = list(RENDER_PLANE_MASTER)

/atom/movable/screen/plane_master/rendering_plate/game_world/Initialize(mapload)
	. = ..()
	add_filter("displacer", 1, displacement_map_filter(render_source = OFFSET_RENDER_TARGET(GRAVITY_PULSE_RENDER_TARGET, offset), size = 10))

///render plate for OOC stuff like ghosts, hud-screen effects, etc
/atom/movable/screen/plane_master/rendering_plate/non_game
	name = "non-game rendering plate"
	documentation = "Renders anything that's out of character. Mostly useful as a converse to the game rendering plate."
	plane = RENDER_PLANE_NON_GAME
	render_relay_planes = list(RENDER_PLANE_MASTER)

/**
 * Plane master proc called in show_to() that creates relay objects, sets them as needed and then adds them to the clients screen
 * Sets:
 * * layer from plane to avoid z-fighting
 * * planes to relay the render to
 * * render_source so that the plane will render on these objects
 * * mouse opacity to ensure proper mouse hit tracking
 * * name for debugging purposes
 * Other vars such as alpha will automatically be applied with the render source
 * Arguments:
 * * mymob: mob whose plane is being backdropped
 */
/atom/movable/screen/plane_master/proc/relay_render_to_plane(mob/mymob)
	var/client/our_client = mymob.client
	if(!our_client)
		return
	// relay renders can be called more then once
	if(relays_generated)
		our_client.screen += relays
		return

	var/relay_loc = "CENTER"
	// If we're using a submap (say for a popup window) make sure we draw onto it
	if(home.map)
		relay_loc = "[home.map]:[relay_loc]"

	var/list/generated_planes = list()
	for(var/atom/movable/render_plane_relay/relay as anything in relays)
		generated_planes += relay.plane

	for(var/relay_plane in (render_relay_planes - generated_planes))
		generate_relay_to(relay_plane, relay_loc, our_client)

	if(blend_mode != BLEND_MULTIPLY)
		blend_mode = BLEND_DEFAULT
	relays_generated = TRUE

/// Creates a connection between this plane master and the passed in plane
/// Helper for out of system code, shouldn't be used in this file
/// Build system to differenchiate between generated and non generated render relays
/atom/movable/screen/plane_master/proc/add_relay_to(target_plane, blend_mode_override)
	if(get_relay_to(target_plane))
		return
	render_relay_planes += target_plane
	if(!relays_generated && isnull(blend_mode_override))
		return
	var/client/display_lad = home?.our_hud?.mymob?.client
	generate_relay_to(target_plane, show_to = display_lad, blend_override = blend_mode_override)

/atom/movable/screen/plane_master/proc/generate_relay_to(target_plane, relay_loc, client/show_to, blend_override)
	if(!length(relays) && !initial(render_target) && generate_render_target)
		render_target = OFFSET_RENDER_TARGET("*[name]: AUTOGENERATED RENDER TGT", offset)
	if(!relay_loc)
		relay_loc = "CENTER"
		// If we're using a submap (say for a popup window) make sure we draw onto it
		if(home.map)
			relay_loc = "[home.map]:[relay_loc]"
	var/blend_to_use = blend_override
	if(isnull(blend_to_use))
		blend_to_use = blend_mode_override || initial(blend_mode)

	var/atom/movable/render_plane_relay/relay = new()
	relay.render_source = render_target
	relay.plane = target_plane
	relay.screen_loc = relay_loc
	// There are two rules here
	// 1: layer needs to be positive (negative layers are treated as float layers)
	// 2: lower planes (including offset ones) need to be layered below higher ones (because otherwise they'll render fucky)
	// By multiplying LOWEST_EVER_PLANE by 30, we give 30 offsets worth of room to planes before they start going negative
	// Bet
	relay.layer = (plane + abs(LOWEST_EVER_PLANE * 30)) //layer must be positive but can be a decimal
	relay.blend_mode = blend_to_use
	relay.mouse_opacity = mouse_opacity
	relay.name = render_target
	relays += relay
	// Relays are sometimes generated early, before huds have a mob to display stuff to
	// That's what this is for
	if(show_to)
		show_to.screen += relay
	return relay

/// Breaks a connection between this plane master, and the passed in place
/atom/movable/screen/plane_master/proc/remove_relay_from(target_plane)
	render_relay_planes -= target_plane
	var/atom/movable/render_plane_relay/existing_relay = get_relay_to(target_plane)
	if(!existing_relay)
		return
	home.our_hud.mymob.client.screen -= existing_relay
	relays -= existing_relay
	if(!length(relays) && generate_render_target)
		render_target = initial(render_target)

/// Gets the relay atom we're using to connect to the target plane, if one exists
/atom/movable/screen/plane_master/proc/get_relay_to(target_plane)
	for(var/atom/movable/render_plane_relay/relay in relays)
		if(relay.plane == target_plane)
			return relay

	return null

/// Basically, trigger a full hud rebuild so our relays will be added to the screen
/// I hate hud code
/atom/movable/screen/plane_master/proc/rebuild_relays()
	relays = list()
	var/datum/hud/hud = home.our_hud
	hud.show_hud(hud.hud_version)
