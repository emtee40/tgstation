// Aquarium related signals
#define COMSIG_AQUARIUM_SURFACE_CHANGED "aquarium_surface_changed"
#define COMSIG_AQUARIUM_FLUID_CHANGED "aquarium_fluid_changed"

// Fish signals
#define COMSIG_FISH_STATUS_CHANGED "fish_status_changed"
#define COMSIG_FISH_STIRRED "fish_stirred"

/// Fishing challenge completed
#define COMSIG_FISHING_CHALLENGE_COMPLETED "comsig_fishing_completed"
/// Called when you try to use fishing rod on anything
#define COMSIG_PRE_FISHING "comsig_pre_fishing"

/// Sent by the target of the fishing rod cast
#define COMSIG_FISHING_ROD_CAST "comsig_fishing_rod_cast"
	#define FISHING_ROD_CAST_HANDLED 1

/// Sent when fishing line is snapped
#define COMSIG_FISHING_LINE_SNAPPED "comsig_fishing_line_interrupted"
