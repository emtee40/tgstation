/// from /obj/machinery/netpod/default_pry_open() : (mob/living/intruder)
#define COMSIG_BITRUNNER_CROWBAR_ALERT "bitrunner_crowbar"

/// from /obj/effect/bitrunning/loot_signal: (points)
#define COMSIG_BITRUNNER_GOAL_POINT "bitrunner_goal_point"

/// from /obj/machinery/quantum_server/on_goal_turf_entered(): (atom/entered, reward_points)
#define COMSIG_BITRUNNER_DOMAIN_COMPLETE "bitrunner_complete"

/// from /obj/machinery/netpod/on_take_damage()
#define COMSIG_BITRUNNER_NETPOD_INTEGRITY "bitrunner_netpod_damage"

/// from multiple sources, (boolean)
#define COMSIG_BITRUNNER_SEVER_CONNECTION "bitrunner_sever"

/// from /obj/machinery/quantum_server/shutdown() : (mob/living)
#define COMSIG_BITRUNNER_SHUTDOWN_ALERT "bitrunner_shutdown"

/// from /obj/machinery/quantum_server/notify_threat()
#define COMSIG_BITRUNNER_THREAT_CREATED "bitrunner_threat"

// Informs the server to up the threat count
/// from event spawns: (mob/living)
#define COMSIG_BITRUNNER_SPAWN_GLITCH "bitrunner_spawn_glitch"

/// from /obj/machinery/quantum_server/scrub_vdom()
#define COMSIG_BITRUNNER_DOMAIN_SCRUBBED "bitrunner_domain_scrubbed"

/// from /obj/machinery/netpod/open_machine()
#define COMSIG_BITRUNNER_NETPOD_OPENED "bitrunner_netpod_opened"
