//Investigate logging defines
#define INVESTIGATE_ACCESSCHANGES "id_card_changes"
#define INVESTIGATE_ATMOS "atmos"
#define INVESTIGATE_BOTANY "botany"
#define INVESTIGATE_CARGO "cargo"
#define INVESTIGATE_CRAFTING "crafting"
#define INVESTIGATE_DEATHS "deaths"
#define INVESTIGATE_ENGINE "engine"
#define INVESTIGATE_EXPERIMENTOR "experimentor"
#define INVESTIGATE_GRAVITY "gravity"
#define INVESTIGATE_HALLUCINATIONS "hallucinations"
#define INVESTIGATE_HYPERTORUS "hypertorus"
#define INVESTIGATE_PORTAL "portals"
#define INVESTIGATE_PRESENTS "presents"
#define INVESTIGATE_RADIATION "radiation"
#define INVESTIGATE_RECORDS "records"
#define INVESTIGATE_RESEARCH "research"
#define INVESTIGATE_WIRES "wires"

// Logging types for log_message()
#define LOG_ATTACK (1 << 0)
#define LOG_SAY (1 << 1)
#define LOG_WHISPER (1 << 2)
#define LOG_EMOTE (1 << 3)
#define LOG_DSAY (1 << 4)
#define LOG_PDA (1 << 5)
#define LOG_CHAT (1 << 6)
#define LOG_COMMENT (1 << 7)
#define LOG_TELECOMMS (1 << 8)
#define LOG_OOC (1 << 9)
#define LOG_ADMIN (1 << 10)
#define LOG_OWNERSHIP (1 << 11)
#define LOG_GAME (1 << 12)
#define LOG_ADMIN_PRIVATE (1 << 13)
#define LOG_ASAY (1 << 14)
#define LOG_MECHA (1 << 15)
#define LOG_VIRUS (1 << 16)
#define LOG_SHUTTLE (1 << 17)
#define LOG_ECON (1 << 18)
#define LOG_VICTIM (1 << 19)
#define LOG_RADIO_EMOTE (1 << 20)
#define LOG_SPEECH_INDICATORS (1 << 21)

//Individual logging panel pages
#define INDIVIDUAL_GAME_LOG (LOG_GAME)
#define INDIVIDUAL_ATTACK_LOG (LOG_ATTACK | LOG_VICTIM)
#define INDIVIDUAL_SAY_LOG (LOG_SAY | LOG_WHISPER | LOG_DSAY | LOG_SPEECH_INDICATORS)
#define INDIVIDUAL_EMOTE_LOG (LOG_EMOTE | LOG_RADIO_EMOTE)
#define INDIVIDUAL_COMMS_LOG (LOG_PDA | LOG_CHAT | LOG_COMMENT | LOG_TELECOMMS)
#define INDIVIDUAL_OOC_LOG (LOG_OOC | LOG_ADMIN)
#define INDIVIDUAL_OWNERSHIP_LOG (LOG_OWNERSHIP)
#define INDIVIDUAL_SHOW_ALL_LOG (LOG_ATTACK | LOG_SAY | LOG_WHISPER | LOG_EMOTE | LOG_RADIO_EMOTE | LOG_DSAY | LOG_PDA | LOG_CHAT | LOG_COMMENT | LOG_TELECOMMS | LOG_OOC | LOG_ADMIN | LOG_OWNERSHIP | LOG_GAME | LOG_ADMIN_PRIVATE | LOG_ASAY | LOG_MECHA | LOG_VIRUS | LOG_SHUTTLE | LOG_ECON | LOG_VICTIM | LOG_SPEECH_INDICATORS)

#define LOGSRC_CKEY "Ckey"
#define LOGSRC_MOB "Mob"

// Log header keys
#define LOG_HEADER_CATEGORY "cat"
#define LOG_HEADER_CATEGORY_LIST "cat-list"
#define LOG_HEADER_INIT_TIMESTAMP "ts"
#define LOG_HEADER_ROUND_ID "round-id"
#define LOG_HEADER_SECRET "secret"

// Log json keys
#define LOG_JSON_CATEGORY "cat"
#define LOG_JSON_ENTRIES "entries"
#define LOG_JSON_LOGGING_START "log-start"

// Category for invalid/missing categories
#define LOG_CATEGORY_NOT_FOUND "invalid-category"

// Misc categories
#define LOG_CATEGORY_ATTACK "attack"
#define LOG_CATEGORY_CONFIG "config"
#define LOG_CATEGORY_DYNAMIC "dynamic"
#define LOG_CATEGORY_ECONOMY "economy"
#define LOG_CATEGORY_FILTER "filter"
#define LOG_CATEGORY_MANIFEST "manifest"
#define LOG_CATEGORY_MECHA "mecha"
#define LOG_CATEGORY_PAPER "paper"
#define LOG_CATEGORY_SHUTTLE "shuttle"
#define LOG_CATEGORY_SILICON "silicon"
#define LOG_CATEGORY_SIGNAL "signal"
#define LOG_CATEGORY_SPEECH_INDICATOR "speech-indiciator"
#define LOG_CATEGORY_SUSPICIOUS_LOGIN "supicious-login"
#define LOG_CATEGORY_TARGET_ZONE_SWITCH "target-zone-switch"
#define LOG_CATEGORY_TELECOMMS "telecomms"
#define LOG_CATEGORY_TOOL "tool"
#define LOG_CATEGORY_VIRUS "virus"

// Admin categories
#define LOG_CATEGORY_ADMIN "admin"
#define LOG_CATEGORY_ADMIN_CIRCUIT "admin-circuit"
#define LOG_CATEGORY_ADMIN_DSAY "admin-dsay"

// Admin private categories
#define LOG_CATEGORY_ADMIN_PRIVATE "adminprivate"
#define LOG_CATEGORY_ADMIN_PRIVATE_ASAY "adminprivate-asay"

// Debug categories
#define LOG_CATEGORY_DEBUG "debug"
#define LOG_CATEGORY_DEBUG_ASSET "debug-asset"
#define LOG_CATEGORY_DEBUG_HREF "debug-href"
#define LOG_CATEGORY_DEBUG_JOB "debug-job"
#define LOG_CATEGORY_DEBUG_LUA "debug-lua"
#define LOG_CATEGORY_DEBUG_MAPPING "debug-mapping"
#define LOG_CATEGORY_DEBUG_MOBTAG "debug-mobtag"
#define LOG_CATEGORY_DEBUG_QDEL "debug-qdel"
#define LOG_CATEGORY_DEBUG_RUNTIME "debug-runtime"
#define LOG_CATEGORY_DEBUG_SQL "debug-sql"
#define LOG_CATEGORY_DEBUG_TGUI "debug-tgui"

// Compatibility categories, for when stuff is changed and you need existing functionality to work
#define LOG_CATEGORY_COMPAT_GAME "game-compat"

// Game categories
#define LOG_CATEGORY_GAME "game"
#define LOG_CATEGORY_GAME_ACCESS "game-access"
#define LOG_CATEGORY_GAME_EMOTE "game-emote"
#define LOG_CATEGORY_GAME_OOC "game-ooc"
#define LOG_CATEGORY_GAME_PRAYER "game-prayer"
#define LOG_CATEGORY_GAME_RADIO_EMOTE "game-radio-emote"
#define LOG_CATEGORY_GAME_SAY "game-say"
#define LOG_CATEGORY_GAME_TOPIC "game-topic"
#define LOG_CATEGORY_GAME_TRAITOR "game-traitor"
#define LOG_CATEGORY_GAME_VOTE "game-vote"
#define LOG_CATEGORY_GAME_WHISPER "game-whisper"

// Uplink categories
#define LOG_CATEGORY_UPLINK "uplink"
#define LOG_CATEGORY_UPLINK_CHANGELING "uplink-changeling"
#define LOG_CATEGORY_UPLINK_HERETIC "uplink-heretic"
#define LOG_CATEGORY_UPLINK_MALF "uplink-malf"
#define LOG_CATEGORY_UPLINK_SPELL "uplink-spell"

// PDA categories
#define LOG_CATEGORY_PDA "pda"
#define LOG_CATEGORY_PDA_CHAT "pda-chat"
#define LOG_CATEGORY_PDA_COMMENT "pda-comment"

#define SCHEMA_VERSION "schema-version"

// Default log schema version
#define LOG_CATEGORY_SCHEMA_VERSION_NOT_SET "0.0.1"

//wrapper macros for easier grepping
#define DIRECT_OUTPUT(A, B) A << B
#define DIRECT_INPUT(A, B) A >> B
#define SEND_IMAGE(target, image) DIRECT_OUTPUT(target, image)
#define SEND_SOUND(target, sound) DIRECT_OUTPUT(target, sound)
#define SEND_TEXT(target, text) DIRECT_OUTPUT(target, text)
#define WRITE_FILE(file, text) DIRECT_OUTPUT(file, text)
#define READ_FILE(file, text) DIRECT_INPUT(file, text)
//This is an external call, "true" and "false" are how rust parses out booleans
#define WRITE_LOG(log, text) rustg_log_write(log, text, "true")
#define WRITE_LOG_NO_FORMAT(log, text) rustg_log_write(log, text, "false")
