///List of all active syndicate beacons, should only be populated with atoms
GLOBAL_LIST_EMPTY(active_syndicate_beacons)
///List of all syndicate paintings currently hanging on walls
GLOBAL_LIST_INIT(active_syndicate_paintings, list("Random Teleport"))

#define COMSIG_PAINTING_SET_TARGET "painting_set_target"
#define COMSIG_PAINTING_CUT_CONNECTIONS "painting_cut_connections"

#define COMSIG_TELEPORTER_SET_TARGET "teleporter_set_target"
#define COMSIG_TELEPORTER_CUT_CONNECTIONS "teleporter_cut_connections"
