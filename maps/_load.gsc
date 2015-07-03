#include common_scripts\utility;
#include maps\_utility;
#include maps\_debug;
#include maps\_vehicle;
#include maps\_hud_util;

main()
{
	if ( !isdefined( level.func ) )
	{
		level.func = [];
	}
	level.func[ "setsaveddvar" ] 	 = ::setsaveddvar;
	level.func[ "useanimtree" ] 	 = ::useAnimTree;
	level.func[ "setanim" ]			 = ::setAnim;
	level.func[ "setanimknob" ]	 	 = ::setAnimKnob;
	level.func[ "clearanim" ]		 = ::clearAnim;
	level.func[ "kill" ]			 = ::Kill;

	set_early_level();

	//*****************************************			STEALTH SYSTEM CALLBACKS		*****************************************/

	//->since stealth is so integrated into many global scripts, these call backs refer to an empty function...if they are actually
	//called, that means the designer called a stealth function without initilizing the stealth system first.  This is done so stealth
	//scripts dont have to be loaded globally into every level
	level.global_callbacks = [];

	level.global_callbacks[ "_autosave_stealthcheck" ] 		 = ::global_empty_callback;
	level.global_callbacks[ "_patrol_endon_spotted_flag" ] 	 = ::global_empty_callback;
	level.global_callbacks[ "_spawner_stealth_default" ] 	 = ::global_empty_callback;
	//this one's for _idle...its peppered with stealth stuff so it got quarentined too.
	level.global_callbacks[ "_idle_call_idle_func" ] 		 = ::global_empty_callback;

	//*****************************************			STEALTH SYSTEM CALLBACKS		*****************************************/

	/#
	weapon_list_debug();
	#/

	if ( !isdefined( level.visionThermalDefault ) )
		level.visionThermalDefault = "cheat_bw";
	VisionSetThermal( level.visionThermalDefault );

	VisionSetPain( "near_death" );

	level.func[ "damagefeedback" ] = maps\_damagefeedback::updateDamageFeedback;// for player shooting sentry guns
	array_thread( GetEntArray( "script_model_pickup_claymore", "classname" ), ::claymore_pickup_think_global );
	array_thread( GetEntArray( "ammo_cache", "targetname" ), ::ammo_cache_think_global );

	/# star( 4 + RandomInt( 4 ) ); #/

	if ( GetDvar( "debug" ) == "" )
		SetDvar( "debug", "0" );

	if ( GetDvar( "fallback" ) == "" )
		SetDvar( "fallback", "0" );

	if ( GetDvar( "angles" ) == "" )
		SetDvar( "angles", "0" );

	if ( GetDvar( "noai" ) == "" )
		SetDvar( "noai", "off" );

	if ( GetDvar( "scr_RequiredMapAspectratio" ) == "" )
		SetDvar( "scr_RequiredMapAspectratio", "1" );

	//if ( GetDvar( "ac130_player_num" ) == "" )
		SetDvar( "ac130_player_num", -1 );	// reset ac130 player number for proper display of HUD

	clear_custom_eog_summary();
	SetDvar( "ui_remotemissile_playernum", 0 );
	SetDvar( "ui_pmc_won", 0 );

	CreatePrintChannel( "script_debug" );

	if ( !isdefined( anim.notetracks ) )
	{
		// string based array for notetracks
		anim.notetracks = [];
		animscripts\shared::registerNoteTracks();
	}

	// default start for killing script.
	add_start( "no_game", ::start_nogame );

	level._loadStarted = true;
	level.first_frame = true;
	level.level_specific_dof = false;
	thread remove_level_first_frame();

	level.wait_any_func_array 		 = [];
	level.run_func_after_wait_array = [];
	level.run_call_after_wait_array = [];
	level.run_noself_call_after_wait_array = [];
	level.do_wait_endons_array 		 = [];
	level.abort_wait_any_func_array = [];
	if ( !isdefined( level.script ) )
		level.script = ToLower( GetDvar( "mapname" ) );

	maps\_specialops::specialops_remove_unused();

	// set solo_play dvar correctly upon returning from a friend's game in which you were invited while playing solo play mode previously
	if ( is_specialop() && ( IsSplitScreen() || ( GetDvar( "coop" ) == "1" ) ) )
		SetDvar( "solo_play", "" );

	/*
	no_game_levels = [];
	no_game_levels[ "contingency" ] = true;

	if ( IsDefined( no_game_levels[ level.script ] ) )
	{
		SetDvar( "start", "no_game" );
	}
	else
	{
		if ( GetDvar( "start" ) == "no_game" )
			SetDvar( "start", "" );
	}
	*/

	level.dirtEffectMenu[ "center" ] = "dirt_effect_center";
	level.dirtEffectMenu[ "left" ] = "dirt_effect_left";
	level.dirtEffectMenu[ "right" ] = "dirt_effect_right";
	PrecacheMenu( level.dirtEffectMenu[ "center" ] );
	PrecacheMenu( level.dirtEffectMenu[ "left" ] );
	PrecacheMenu( level.dirtEffectMenu[ "right" ] );
	PreCacheShader( "fullscreen_dirt_bottom_b" );
	PreCacheShader( "fullscreen_dirt_bottom" );
	PreCacheShader( "fullscreen_dirt_left" );
	PreCacheShader( "fullscreen_dirt_right" );


	level.is_legacy_map = set_legacy_map();

	level.ai_number = 0;
	// flag_struct is used as a placeholder when a flag is set without an entity

	if ( !isdefined( level.flag ) )
	{
		init_flags();
	}
	else
	{
		// flags initialized before this should be checked for stat tracking
		flags = GetArrayKeys( level.flag );
		array_levelthread( flags, ::check_flag_for_stat_tracking );
	}

	// disabled, prototyping PMC/COOP money
	if ( GetDvar( "xp_enable", "0" ) == "" )
		SetDvar( "xp_enable", "0" );

	if ( string_starts_with( level.script, "co_" ) )
	{
		SetDvar( "money_enable", "1" );
		SetDvar( "in_game_reward", "0" );	// this includes getting reward from kills and objectives
	}
	else if ( string_starts_with( level.script, "pmc_" ) )
	{
		SetDvar( "money_enable", "1" );
		SetDvar( "in_game_reward", "1" );
	}
	else
	{
		SetDvar( "money_enable", "0" );
		SetDvar( "in_game_reward", "0" );
	}

	if ( GetDvar( "money_sharing" ) == "" )
		SetDvar( "money_sharing", "1" );


	init_level_players();

	if ( is_coop() )
		maps\_coop::main();

	if ( IsSplitScreen() )
	{
		SetSavedDvar( "cg_fovScale", "0.75" );// 65 - > 40 fov// 0.54
	}
	else
	{
		SetSavedDvar( "cg_fovScale", "1" );
	}

	level.radiation_totalpercent = 0;

	flag_init( "missionfailed" );
	flag_init( "auto_adjust_initialized" );
	flag_init( "_radiation_poisoning" );
	flag_init( "gameskill_selected" );
	flag_init( "battlechatter_on_thread_waiting" );

	thread maps\_gameskill::aa_init_stats();
	thread player_death_detection();

	level.default_run_speed = 190;
	SetSavedDvar( "g_speed", level.default_run_speed );

	if ( is_specialop() )
	{
		SetSavedDvar( "sv_saveOnStartMap", false );
	}
	else if ( arcadeMode() )
	{
		SetSavedDvar( "sv_saveOnStartMap", false );
		thread arcademode_save();
	}
	else
	{
		SetSavedDvar( "sv_saveOnStartMap", true );
	}

	level.dronestruct = [];


	// remove delete_on_load structs
	foreach ( index, struct in level.struct )
	{
		if ( !isdefined( struct.targetname ) )
			continue;
		if ( struct.targetname == "delete_on_load" )
			level.struct[ index ] = undefined;
	}

	struct_class_init();

	// can be turned on and off to control friendly_respawn_trigger
	flag_init( "respawn_friendlies" );
	flag_init( "player_flashed" );

	//function pointers so I can share _destructible script with SP and MP where code commands don't exist in MP
	level.arcadeMode_kill_func = ::arcadeMode_kill;
	level.connectPathsFunction = ::connectPaths;
	level.disconnectPathsFunction = ::disconnectPaths;
	level.badplace_cylinder_func = ::badplace_cylinder;
	level.badplace_delete_func = ::badplace_delete;
	level.isAIfunc = ::isAI;
	level.createClientFontString_func = maps\_hud_util::createClientFontString;
	level.HUDsetPoint_func = maps\_hud_util::setPoint;
	level.makeEntitySentient_func = ::makeEntitySentient;
	level.freeEntitySentient_func = ::freeEntitySentient;
	level.sentry_money_init_func = maps\_money::AI_money_init;
	level.laserOn_func = ::laserForceOn;
	level.laserOff_func = ::laserForceOff;
	level.stat_track_kill_func = maps\_player_stats::register_kill;
	level.stat_track_damage_func = maps\_player_stats::register_shot_hit;
	level.doPickyAutosaveChecks = true;
	level.autosave_threat_check_enabled = true;
	level.getNodeFunction = ::GetNode;
	level.getNodeArrayFunction = ::GetNodeArray;

	if ( !isdefined( level._notetrackFX ) )
		level._notetrackFX = [];

	foreach ( player in level.players )
	{
		player.maxhealth = level.player.health;
		player.shellshocked = false;
		player.inWater = false;
		player.dirt_on_screen = [];
		player.dirt_on_screen[ "bottom_b" ] = 0;
		player.dirt_on_screen[ "left" ] = 0;
		player.dirt_on_screen[ "right" ] = 0;
		player thread watchWeaponChange();// for thermal
	}

	level.last_mission_sound_time = -5000;
	level.hero_list = [];
	thread precache_script_models();

// 	level.ai_array = [];

	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[ i ];
		player thread maps\_utility::flashMonitor();
		player thread maps\_utility::shock_ondeath();
	}

// 	level.player thread ai_eq();
// 	level.player thread maps\_spawner::setup_ai_eq_triggers();
// 	level.eq_trigger_num = 0;
// 	level.eq_trigger_table = [];
// 	level.touched_eq_function[ true ] = ::player_touched_eq_trigger;
// 	level.touched_eq_function[ false ] = ::ai_touched_eq_trigger;

	//un-developer commented. I was precaching this model in _vehicle anyway.
	PreCacheModel( "fx" );

	PreCacheModel( "tag_origin" );
	PreCacheShellShock( "victoryscreen" );
	PreCacheShellShock( "default" );
	PreCacheShellShock( "flashbang" );
	PreCacheShellShock( "dog_bite" );
	PreCacheRumble( "damage_heavy" );
	PreCacheRumble( "damage_light" );
	PreCacheRumble( "grenade_rumble" );
	PreCacheRumble( "artillery_rumble" );

	// You are Hurt. Get to Cover!
	PreCacheString( &"GAME_GET_TO_COVER" );
	// You were killed by a grenade.\nWatch out for the grenade danger indicator.
	PreCacheString( &"SCRIPT_GRENADE_DEATH" );
	// You died holding a grenade for too long.
	PreCacheString( &"SCRIPT_GRENADE_SUICIDE_LINE1" );
	// Holding ^3[{+frag}]^7 allows you to cook off live grenades.
	PreCacheString( &"SCRIPT_GRENADE_SUICIDE_LINE2" );
	// You were killed by an exploding vehicle.\nVehicles on fire are likely to explode.
	PreCacheString( &"SCRIPT_EXPLODING_VEHICLE_DEATH" );
	// You were killed by an explosion.\nSome burning objects can explode.
	PreCacheString( &"SCRIPT_EXPLODING_DESTRUCTIBLE_DEATH" );
	// You were killed by an exploding barrel.\nRed barrels will explode when shot.
	PreCacheString( &"SCRIPT_EXPLODING_BARREL_DEATH" );
	PreCacheShader( "hud_grenadeicon" );
	PreCacheShader( "hud_grenadepointer" );
	PreCacheShader( "hud_burningcaricon" );
	PreCacheShader( "death_juggernaut" );
	PreCacheShader( "death_friendly_fire" );
	PreCacheShader( "hud_destructibledeathicon" );
	PreCacheShader( "hud_burningbarrelicon" );
	PreCacheShader( "waypoint_ammo" );

	level._effect[ "deathfx_bloodpool_generic" ] = LoadFX( "impacts/deathfx_bloodpool_generic" );
	animscripts\pain::initPainFx();

	animscripts\melee::Melee_Init();

	level.createFX_enabled = ( GetDvar( "createfx" ) != "" );

	slowmo_system_init();

	maps\_mgturret::main();

	setupExploders();
	maps\_art::main();
	maps\_noder::main();
	common_scripts\_painter::main();
	maps\_gameskill::setSkill();

	maps\_anim::init();

	thread common_scripts\_fx::initFX();
	if ( level.createFX_enabled )
	{
		level.stop_load = true;
		maps\_createfx::createfx();
	}

	maps\_detonategrenades::init();

	thread setup_simple_primary_lights();

	// --------------------------------------------------------------------------------
	// ---- PAST THIS POINT THE SCRIPTS DONT RUN WHEN GENERATING REFLECTION PROBES ----
	// --------------------------------------------------------------------------------
	/#
	if ( GetDvar( "r_reflectionProbeGenerate" ) == "1" )
	{
		level.stop_load = true;
		maps\_global_fx::main();
		level waittill( "eternity" );
	}
	#/

	/#
	if ( string_starts_with( level.script, "so_" ) && !is_specialop() )
		AssertMsg( "Attempted to run a Special Op, but not in Special Ops mode. Probably need to add +set specialops 1 to Launcher Custom Command Line Options." );
	#/
	
	maps\_names::setup_names();

	thread handle_starts();
	thread handle_getviewpos();
	thread handle_getviewangle();

	/#
	thread maps\_debug::mainDebug();
	#/

	if ( !isdefined( level.trigger_flags ) )
	{
		// may have been defined by AI spawning
		init_trigger_flags();
	}

	level.killspawn_groups = [];
	init_script_triggers();

	SetSavedDvar( "ufoHitsTriggers", "0" );

	//don't go past here on no_game start
	if ( level.start_point == "no_game" )
	{
		// we want ufo/noclip to hit triggers in no_game
		SetSavedDvar( "ufoHitsTriggers", "1" );

		level.stop_load = true;
		// SRS 11/25/08: LDs can run a custom setup function for their levels to get back some
		//  selected script calls (loadout, vision, etc).  be careful, this function is not threaded!
		if ( IsDefined( level.custom_no_game_setupFunc ) )
		{
			level [[ level.custom_no_game_setupFunc ]]();
		}
		maps\_loadout::init_loadout();
		maps\_ambient::init();
		level waittill( "eternity" );
	}

	thread maps\_vehicle::init_vehicles();

	if ( GetDvar( "g_connectpaths" ) == "2" )
	{
		/# PrintLn( "g_connectpaths == 2; halting script execution" ); #/
		level waittill( "eternity" );
	}

	PrintLn( "level.script: ", level.script );

	maps\_autosave::main();
	if ( !isdefined( level.animSounds ) )
		thread maps\_debug::init_animSounds();
	maps\_anim::init();
	maps\_ambient::init();

	// lagacy... necessary?
	anim.useFacialAnims = false;

	if ( !isdefined( level.MissionFailed ) )
		level.MissionFailed = false;

	maps\_loadout::init_loadout();

	common_scripts\_destructible::init();
	thread common_scripts\_elevator::init();
	thread common_scripts\_pipes::main();

	SetObjectiveTextColors();

	// global effects for objects
	maps\_global_fx::main();
	common_scripts\_dynamic_world::init();

	//thread devhelp();// disabled due to localization errors

	SetSavedDvar( "ui_campaign", level.campaign );// level.campaign is set in maps\_loadout::init_loadout

	thread maps\_introscreen::main();
	thread maps\_quotes::main();
//	thread maps\_minefields::main();
	thread maps\_shutter::main();
// 	thread maps\_breach::main();
//	thread maps\_inventory::main();
// 	thread maps\_photosource::main();
	thread maps\_endmission::main();
	thread maps\_damagefeedback::init();
	thread maps\_escalator::init();
	maps\_friendlyfire::main();

	// For _anim to track what animations have been used. Uncomment this locally if you need it.
// 	thread usedAnimations();

	array_levelthread( GetEntArray( "badplace", "targetname" ), ::badplace_think );
	array_levelthread( GetEntArray( "delete_on_load", "targetname" ), ::deleteEnt );
	array_thread( GetNodeArray( "traverse", "targetname" ), ::traverseThink );
	/# array_thread( GetNodeArray( "deprecated_traverse", "targetname" ), ::deprecatedTraverseThink ); #/
	array_thread( GetEntArray( "piano_key", "targetname" ), ::pianoThink );
	array_thread( GetEntArray( "piano_damage", "targetname" ), ::pianoDamageThink );
	array_thread( GetEntArray( "water", "targetname" ), ::waterThink );
	array_thread( GetEntArray( "kill_all_players", "targetname" ), ::kill_all_players_trigger );

	flag_init( "allow_ammo_pickups" );
	flag_set( "allow_ammo_pickups" );

	array_thread( GetEntArray( "ammo_pickup_grenade_launcher", "targetname" ), ::ammo_pickup, "grenade_launcher" );
	array_thread( GetEntArray( "ammo_pickup_rpg", "targetname" ), ::ammo_pickup, "rpg" );
	array_thread( GetEntArray( "ammo_pickup_c4", "targetname" ), ::ammo_pickup, "c4" );
	array_thread( GetEntArray( "ammo_pickup_claymore", "targetname" ), ::ammo_pickup, "claymore" );
	array_thread( GetEntArray( "ammo_pickup_556", "targetname" ), ::ammo_pickup, "556" );
	array_thread( GetEntArray( "ammo_pickup_762", "targetname" ), ::ammo_pickup, "762" );
	array_thread( GetEntArray( "ammo_pickup_45", "targetname" ), ::ammo_pickup, "45" );
	array_thread( GetEntArray( "ammo_pickup_pistol", "targetname" ), ::ammo_pickup, "pistol" );

	thread maps\_interactive_objects::main();
	thread maps\_intelligence::main();

	thread maps\_gameskill::playerHealthRegenInit();

	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[ i ];
		player thread maps\_gameskill::playerHealthRegen();
		player thread playerDamageRumble();
	}

	thread player_special_death_hint();

	// this has to come before _spawner moves the turrets around
	thread massNodeInitFunctions();

	// Various newvillers globalized scripts
	flag_init( "spawning_friendlies" );
	flag_init( "friendly_wave_spawn_enabled" );
	flag_clear( "spawning_friendlies" );

	level.friendly_spawner[ "rifleguy" ] = GetEntArray( "rifle_spawner", "script_noteworthy" );
	level.friendly_spawner[ "smgguy" ] = GetEntArray( "smg_spawner", "script_noteworthy" );
	level.spawn_funcs = [];
	level.spawn_funcs[ "allies" ] = [];
	level.spawn_funcs[ "axis" ] = [];
	level.spawn_funcs[ "team3" ] = [];
	level.spawn_funcs[ "neutral" ] = [];
	thread maps\_spawner::goalVolumes();
	thread maps\_spawner::friendlyChains();
	thread maps\_spawner::friendlychain_onDeath();

// 	array_thread( GetEntArray( "ally_spawn", "targetname" ), maps\_spawner::squadThink );
	array_thread( GetEntArray( "friendly_spawn", "targetname" ), maps\_spawner::friendlySpawnWave );
	array_thread( GetEntArray( "flood_and_secure", "targetname" ), maps\_spawner::flood_and_secure );

	// Do various things on triggers
	array_thread( GetEntArray( "ambient_volume", "targetname" ), maps\_ambient::ambientVolume );


	array_thread( GetEntArray( "window_poster", "targetname" ), ::window_destroy );


	if ( !isdefined( level.trigger_hint_string ) )
	{
		level.trigger_hint_string = [];
		level.trigger_hint_func = [];
	}

	level.shared_portable_turrets = [];
	level.spawn_groups = [];
	maps\_spawner::main();

	// for cobrapilot extended visible distance and potentially others, stretch that horizon! - nate
	// origin of prefab is copied manually by LD to brushmodel contained in the prefab, no real way to automate this AFAIK
	array_thread( GetEntArray( "background_block", "targetname" ), ::background_block );

	maps\_hud::init();
	// maps\_hud_weapons::init();

	thread load_friendlies();

// 	level.player thread stun_test();

	thread maps\_animatedmodels::main();
	thread maps\_cagedchickens::initChickens();
	if ( is_coop() )
		thread maps\_loadout::coop_gamesetup_menu();
	thread weapon_ammo();
	thread filmy();

	if ( is_specialop() )
		maps\_specialops::specialops_init();
	
	// set has-played-SP when player plays the frist level in the game for the first time.
	assert( isdefined( level.missionsettings ) && isdefined( level.missionsettings.levels ) );
	assert( isdefined( level.script ) );
	
	if ( level.script == level.missionsettings.levels[0].name && !( level.player getLocalPlayerProfileData( "hasEverPlayed_SP" ) ) )
	{
		level.player SetLocalPlayerProfileData( "hasEverPlayed_SP", true );
		UpdateGamerProfile();
	}
}

/*QUAKED trigger_multiple_spawn (1.0 0.5 0.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="spawner_trigger"
Spawns whatever is targetted. Currently supports AI.*/

/*QUAKED trigger_multiple_spawn_reinforcement (0.12 0.23 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="spawner_trigger"
Spawns whatever is targetted. When the targeted AI dies a reinforcement spawner will be spawned if the spawner targets another spawner. Currently supports AI.*/

/*QUAKED trigger_use_flag_set (0.12 0.23 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="flag"
Sets the script_flag when triggered. The entity that triggered it is passed with the level notify and to the flag_wait.*/

/*QUAKED trigger_use_flag_clear (0.12 0.23 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="flag"
Sets the script_flag when triggered. The entity that triggered it is passed with the level notify and to the flag_wait.*/

/*QUAKED trigger_damage_doradius_damage (0.12 0.23 1.0) ? PISTOL_NO RIFLE_NO PROJ_NO EXPLOSION_NO SPLASH_NO MELEE_NO
defaulttexture="trigger"
Wait for trigger then do lots of damage at target spot. */

/*QUAKED trigger_multiple_doradius_damage (0.12 0.23 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN
defaulttexture="trigger"
Wait for trigger then do lots of damage at target spot. */

/*QUAKED trigger_damage_player_flag_set (0.12 0.23 1.0) ? PISTOL_NO RIFLE_NO PROJ_NO EXPLOSION_NO SPLASH_NO MELEE_NO
defaulttexture="flag"
Sets the script_flag when player does damage to the trigger. */

/*QUAKED trigger_multiple_nobloodpool (0.12 0.23 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN
defaulttexture="trigger_nobloodpool"
When triggered the touching character will no longer spawn blood pools on death. When the character leaves the trigger the blood pool will be re-enabled after a short delay. */

/*QUAKED trigger_multiple_flag_set (0.12 0.23 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="flag"
Sets the script_flag when triggered. The entity that triggered it is passed with the level notify and to the flag_wait.*/

/*QUAKED trigger_multiple_flag_clear (0.12 0.23 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="flag"
Clears the script_flag when triggered.*/

/*QUAKED trigger_multiple_flag_set_touching (0.12 0.23 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="flag"
Sets the script_flag when touched and then clears the flag when no longer touched.*/

/*QUAKED trigger_multiple_flag_lookat (0.12 0.23 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="flag"
The trigger targets a script origin. When the trigger is touched and a player looks at the origin, the script_flag gets set. If there is no script_flag then any triggers targetted by the trigger_multiple_lookat get triggered. Change SCRIPT_DOT to change required dot product*/

/*QUAKED trigger_multiple_flag_looking (0.12 0.23 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="flag"
The trigger targets a script origin. When the trigger is touched and a player looks at the origin, the script_flag gets set. Change SCRIPT_DOT to change required dot product.

When the player looks away from the script origin, the script_flag is cleared.

If there is no script_flag then any triggers targetted by the trigger_multiple_lookat get triggered.
*/

/*QUAKED trigger_multiple_no_prone (0.12 0.23 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL  ? ? ? TOUCH_ONCE
defaulttexture="trigger_no_prone"
*/

/*QUAKED trigger_multiple_no_crouch_or_prone (0.12 0.23 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL  ? ? ? TOUCH_ONCE
defaulttexture="trigger_no_crouch_or_prone"
*/


/*QUAKED trigger_multiple_autosave (1.0 0.23 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="autosave"
Autosaves when the trigger is hit.
*/

/*QUAKED trigger_multiple_physics ( 0.0 0.63 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="trigger"
Activate a physics jolt at a specified origin.
Use script_parameters to set amount of jolt.
*/

/*QUAKED trigger_multiple_visionset (1.0 0.23 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="trigger_environment"
Changes vision set to script_visionset. Script_delay specifies how long to spend on the transition.
If it can find a fogset with the same name, it will change that as well.
*/

/*QUAKED trigger_multiple_slide (1.0 0.23 1.0) ?
defaulttexture="trigger"
Forces the player to slide.
*/

/*QUAKED script_origin_mini (1.0 0.0 0.0) (-2 -2 -2) (2 2 2)*/

/*QUAKED script_origin_small (1.0 0.0 0.0) (-4 -4 -4) (4 4 4)*/

/*QUAKED script_struct_mini (0.9 0.3 0.0) (-1 -1 -1) (1 1 1)*/

/*QUAKED script_struct_small (0.9 0.3 0.0) (-2 -2 -2) (2 2 2)*/


/*QUAKED trigger_multiple_fog (1.0 0.23 1.0) ?
defaulttexture="trigger"
Fog transition trigger.
script_fogset_start="example_start_fog"
script_fogset_end="example_end_fog"
"example_start_fog" is made from maps\_utility::create_fog("example_start_fog")

Trigger must target a script_origin to define the entry side,
this script_origin can target another optional script_origin to define exit side.
*/

/*QUAKED trigger_multiple_ambient (1.0 0.23 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="ambient"
.ambient determines the ambience for the trigger. Can be two values, like "interior exterior" and it will blend between them.
For blending, needs a targetted origin to determine blend direction.

Current sets are:
ac130
alley
bunker
city
container
exterior
exterior1
exterior2
exterior3
exterior4
exterior5
forrest
hangar
interior
interior_metal
interior_stone
interior_vehicle
interior_wood
mountains
pipe
shanty
snow_base
snow_cliff
tunnel
underpass


*/

/*QUAKED trigger_radius_glass_break (0 0.25 0.5) (-16 -16 -16) (16 16 16) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE
Target to a func_glass. When an entity touching this trigger sends a level notify of "glass_break", the func_glass targeted by this trigger will break.
*/

/*QUAKED trigger_multiple_glass_break (0 0.25 0.5) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE
defaulttexture="trigger"
Target to a func_glass. When an entity touching this trigger sends a level notify of "glass_break", the func_glass targeted by this trigger will break.
*/

/*QUAKED trigger_multiple_friendly_respawn (0 1 0.25) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="aitrig"
Target a script origin. Replacement friendlies will spawn from the origin.
*/

/*QUAKED trigger_multiple_friendly_stop_respawn (0.25 1 0.25) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="aitrig"
Stops friendly respawning.
*/

/*QUAKED trigger_multiple_friendly (0 1.0 0.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="aitrig"
Assign color codes to this trigger to control friendlies.
*/

/*QUAKED trigger_multiple_compass (0.2 0.9 0.7) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="trigger"
Activates the compass map set in its script_parameters.
*/

/*QUAKED trigger_multiple_specialops_flag_set (0.12 0.23 1.0) ? AI_AXIS AI_ALLIES AI_NEUTRAL NOTPLAYER VEHICLE TRIGGER_SPAWN TOUCH_ONCE
defaulttexture="flag"
Sets the script_flag after being triggered by all player in a specialops map. The last entity that triggered it is passed with the level notify and to the flag_wait.*/

get_load_trigger_classes()
{
	trigger_classes = [];
	trigger_classes[ "trigger_multiple_nobloodpool" ] = ::trigger_nobloodpool;
	trigger_classes[ "trigger_multiple_flag_set" ] = ::flag_set_trigger;
	trigger_classes[ "trigger_multiple_flag_clear" ] = ::flag_unset_trigger;
	trigger_classes[ "trigger_use_flag_set" ] = ::flag_set_trigger;
	trigger_classes[ "trigger_use_flag_clear" ] = ::flag_unset_trigger;
	trigger_classes[ "trigger_multiple_flag_set_touching" ] = ::flag_set_touching;
	trigger_classes[ "trigger_multiple_flag_lookat" ] = ::trigger_lookat;
	trigger_classes[ "trigger_multiple_flag_looking" ] = ::trigger_looking;
	trigger_classes[ "trigger_multiple_no_prone" ] = ::no_prone_think;
	trigger_classes[ "trigger_multiple_no_crouch_or_prone" ] = ::no_crouch_or_prone_think;
	trigger_classes[ "trigger_multiple_compass" ] = ::trigger_multiple_compass;
	trigger_classes[ "trigger_multiple_specialops_flag_set" ] = ::flag_set_trigger_specialops;

	if ( level.start_point != "no_game" )
	{
		trigger_classes[ "trigger_multiple_autosave" ] = maps\_autosave::trigger_autosave;
		trigger_classes[ "trigger_multiple_spawn" ] = maps\_spawner::trigger_spawner;
		trigger_classes[ "trigger_multiple_spawn_reinforcement" ] = maps\_spawner::trigger_spawner_reinforcement;
	}

	trigger_classes[ "trigger_multiple_slide" ] = ::trigger_slide;
	trigger_classes[ "trigger_multiple_fog" ] = ::trigger_fog;
	//trigger_classes[ "trigger_multiple_ambient" ] = ::trigger_ambient; // runs from global .ambient check

	trigger_classes[ "trigger_damage_doradius_damage" ] = ::trigger_damage_do_radius_damage;
	trigger_classes[ "trigger_multiple_doradius_damage" ] = ::trigger_multiple_do_radius_damage;

	trigger_classes[ "trigger_damage_player_flag_set" ] = ::trigger_damage_player_flag_set;
	trigger_classes[ "trigger_multiple_visionset" ] = ::trigger_multiple_visionset;
	trigger_classes[ "trigger_multiple_glass_break" ] = ::trigger_glass_break;
	trigger_classes[ "trigger_radius_glass_break" ] = ::trigger_glass_break;
	trigger_classes[ "trigger_multiple_friendly_respawn" ] = ::trigger_multiple_friendly_respawn;
	trigger_classes[ "trigger_multiple_friendly_stop_respawn" ] = ::trigger_multiple_friendly_stop_respawn;
	trigger_classes[ "trigger_multiple_physics" ] = ::trigger_multiple_physics;
	trigger_classes[ "trigger_multiple_fx_watersheeting" ] = maps\_fx::watersheeting;





	return trigger_classes;
}

get_load_trigger_funcs()
{

	trigger_funcs = [];
	trigger_funcs[ "friendly_wave" ] = maps\_spawner::friendly_wave;
	trigger_funcs[ "friendly_wave_off" ] = maps\_spawner::friendly_wave;
	trigger_funcs[ "friendly_mgTurret" ] = maps\_spawner::friendly_mgTurret;

	if ( level.start_point != "no_game" )
	{
		trigger_funcs[ "camper_spawner" ] = maps\_spawner::camper_trigger_think;
		trigger_funcs[ "flood_spawner" ] = maps\_spawner::flood_trigger_think;
		trigger_funcs[ "trigger_spawner" ] = maps\_spawner::trigger_spawner;
		trigger_funcs[ "trigger_autosave" ] = maps\_autosave::trigger_autosave;
		trigger_funcs[ "trigger_spawngroup" ] = ::trigger_spawngroup;
		trigger_funcs[ "two_stage_spawner" ] = maps\_spawner::two_stage_spawner_think;
		trigger_funcs[ "trigger_vehicle_spline_spawn" ] = ::trigger_vehicle_spline_spawn;
		trigger_funcs[ "trigger_vehicle_spawn" ] = ::trigger_vehicle_spawn;
		trigger_funcs[ "trigger_vehicle_getin_spawn" ] = ::trigger_vehicle_getin_spawn;
		trigger_funcs[ "random_spawn" ] = maps\_spawner::random_spawn;
	}

	trigger_funcs[ "autosave_now" ] = maps\_autosave::autosave_now_trigger;
	trigger_funcs[ "trigger_autosave_tactical" ] = maps\_autosave::trigger_autosave_tactical;
	trigger_funcs[ "trigger_autosave_stealth" ] = maps\_autosave::trigger_autosave_stealth;
	trigger_funcs[ "trigger_unlock" ] = ::trigger_unlock;
	trigger_funcs[ "trigger_lookat" ] = ::trigger_lookat;
	trigger_funcs[ "trigger_looking" ] = ::trigger_looking;
	trigger_funcs[ "trigger_cansee" ] = ::trigger_cansee;
	trigger_funcs[ "autosave_immediate" ] = maps\_autosave::trigger_autosave_immediate;
	trigger_funcs[ "flag_set" ] = ::flag_set_trigger;
	if ( is_coop() )
		trigger_funcs[ "flag_set_coop" ] = ::flag_set_coop_trigger;
	trigger_funcs[ "flag_set_player" ] = ::flag_set_player_trigger;
	trigger_funcs[ "flag_unset" ] = ::flag_unset_trigger;
	trigger_funcs[ "flag_clear" ] = ::flag_unset_trigger;
	trigger_funcs[ "objective_event" ] = maps\_spawner::objective_event_init;
// 	trigger_funcs[ "eq_trigger" ] = ::eq_trigger;
	trigger_funcs[ "friendly_respawn_trigger" ] = ::trigger_multiple_friendly_respawn;
	trigger_funcs[ "friendly_respawn_clear" ] = ::friendly_respawn_clear;
	trigger_funcs[ "radio_trigger" ] = ::radio_trigger;
	trigger_funcs[ "trigger_ignore" ] = ::trigger_ignore;
	trigger_funcs[ "trigger_pacifist" ] = ::trigger_pacifist;
	trigger_funcs[ "trigger_delete" ] = ::trigger_turns_off;
	trigger_funcs[ "trigger_delete_on_touch" ] = ::trigger_delete_on_touch;
	trigger_funcs[ "trigger_off" ] = ::trigger_turns_off;
	trigger_funcs[ "trigger_outdoor" ] = maps\_spawner::outdoor_think;
	trigger_funcs[ "trigger_indoor" ] = maps\_spawner::indoor_think;
	trigger_funcs[ "trigger_hint" ] = ::trigger_hint;
	trigger_funcs[ "trigger_grenade_at_player" ] = ::throw_grenade_at_player_trigger;
	trigger_funcs[ "flag_on_cleared" ] = maps\_load::flag_on_cleared;
	trigger_funcs[ "flag_set_touching" ] = ::flag_set_touching;
	trigger_funcs[ "delete_link_chain" ] = ::delete_link_chain;
	trigger_funcs[ "trigger_fog" ] = ::trigger_fog;
	trigger_funcs[ "trigger_slide" ] = ::trigger_slide;
	trigger_funcs[ "trigger_dooropen" ] = ::trigger_dooropen;

	trigger_funcs[ "no_crouch_or_prone" ] = ::no_crouch_or_prone_think;
	trigger_funcs[ "no_prone" ] = ::no_prone_think;
	return trigger_funcs;
}


init_script_triggers()
{
	// run logic on these triggers from radiant
	trigger_classes = get_load_trigger_classes();
	trigger_funcs = get_load_trigger_funcs();


	foreach ( classname, function in trigger_classes )
	{
		triggers = GetEntArray( classname, "classname" );
		array_levelthread( triggers, function );
	}

	// old style targetname triggering

	// trigger_multiple and trigger_radius can have the trigger_spawn flag set
	trigger_multiple = GetEntArray( "trigger_multiple", "classname" );
	trigger_radius = GetEntArray( "trigger_radius", "classname" );
	triggers = array_merge( trigger_multiple, trigger_radius );
	trigger_disk = GetEntArray( "trigger_disk", "classname" );
	triggers = array_merge( triggers, trigger_disk );
	trigger_once = GetEntArray( "trigger_once", "classname" );
	triggers = array_merge( triggers, trigger_once );

	if ( level.start_point != "no_game" )
	{
		for ( i = 0; i < triggers.size; i++ )
		{
			if ( triggers[ i ].spawnflags & 32 )
				thread maps\_spawner::trigger_spawner( triggers[ i ] );
		}
	}

	for ( p = 0; p < 7; p++ )
	{
		switch( p )
		{
			case 0:
				triggertype = "trigger_multiple";
				break;

			case 1:
				triggertype = "trigger_once";
				break;

			case 2:
				triggertype = "trigger_use";
				break;

			case 3:
				triggertype = "trigger_radius";
				break;

			case 4:
				triggertype = "trigger_lookat";
				break;

			case 5:
				triggertype = "trigger_disk";
				break;

			default:
				Assert( p == 6 );
				triggertype = "trigger_damage";
				break;
		}

		triggers = GetEntArray( triggertype, "code_classname" );

		for ( i = 0; i < triggers.size; i++ )
		{
			if ( IsDefined( triggers[ i ].script_flag_true ) )
				level thread script_flag_true_trigger( triggers[ i ] );

			if ( IsDefined( triggers[ i ].script_flag_false ) )
				level thread script_flag_false_trigger( triggers[ i ] );

			if ( IsDefined( triggers[ i ].script_autosavename ) || IsDefined( triggers[ i ].script_autosave ) )
				level thread maps\_autosave::autoSaveNameThink( triggers[ i ] );

			if ( IsDefined( triggers[ i ].script_fallback ) )
				level thread maps\_spawner::fallback_think( triggers[ i ] );

			if ( IsDefined( triggers[ i ].script_mgTurretauto ) )
				level thread maps\_mgturret::mgTurret_auto( triggers[ i ] );

			if ( IsDefined( triggers[ i ].script_killspawner ) )
				level thread maps\_spawner::kill_spawner( triggers[ i ] );

			if ( IsDefined( triggers[ i ].script_kill_vehicle_spawner ) )
				level thread maps\_vehicle::kill_vehicle_spawner( triggers[ i ] );

			if ( IsDefined( triggers[ i ].script_emptyspawner ) )
				level thread maps\_spawner::empty_spawner( triggers[ i ] );

			if ( IsDefined( triggers[ i ].script_prefab_exploder ) )
				triggers[ i ].script_exploder = triggers[ i ].script_prefab_exploder;

			if ( IsDefined( triggers[ i ].script_exploder ) )
				level thread maps\_load::exploder_load( triggers[ i ] );

			if ( IsDefined( triggers[ i ].ambient ) )
				triggers[ i ] thread maps\_ambient::ambient_trigger();

			if ( IsDefined( triggers[ i ].script_triggered_playerseek ) )
				level thread triggered_playerseek( triggers[ i ] );

			if ( IsDefined( triggers[ i ].script_bctrigger ) )
				level thread bctrigger( triggers[ i ] );

			if ( IsDefined( triggers[ i ].script_trigger_group ) )
				triggers[ i ] thread trigger_group();

			if ( IsDefined( triggers[ i ].script_random_killspawner ) )
				level thread maps\_spawner::random_killspawner( triggers[ i ] );

			if ( IsDefined( triggers[ i ].targetname ) )
			{
				// do targetname specific functions
				targetname = triggers[ i ].targetname;
				if ( IsDefined( trigger_funcs[ targetname ] ) )
				{
					level thread [[ trigger_funcs[ targetname ] ]]( triggers[ i ] );
				}
			}
		}
	}
}

trigger_ambient( trigger )
{
	if ( !isdefined( trigger.ambient ) )
		return;
	trigger thread maps\_ambient::ambient_trigger();
}

set_early_level()
{
	level.early_level = [];
	level.early_level[ "trainer" ] = true;
	level.early_level[ "roadkill" ] = true;
	level.early_level[ "cliffhanger" ] = true;
	level.early_level[ "airport" ] = true;
	level.early_level[ "favela" ] = true;
//	level.early_level[ "invasion" ] = true;
//	level.early_level[ "favela_escape" ] = true;
//	level.early_level[ "arcadia" ] = true;
}

trigger_slide( trigger )
{
	while ( 1 )
	{
		trigger waittill( "trigger", player );
		player thread slideTriggerPlayerThink( trigger );
	}
}

slideTriggerPlayerThink( trig )
{
	if ( IsDefined( self.vehicle ) )
		return;

	if ( self IsSliding() )
		return;
		
	if ( isdefined( self.player_view ) )
		return;

	self endon( "death" );
	
	if ( SoundExists( "SCN_cliffhanger_player_hillslide" ) )
		self PlaySound( "SCN_cliffhanger_player_hillslide" );

	self BeginSliding();
	while ( 1 )
	{
		if ( !self IsTouching( trig ) )
			break;
		wait .05;
	}
	if ( IsDefined( level.end_slide_delay ) )
		wait( level.end_slide_delay );
	self EndSliding();
}



setup_simple_primary_lights()
{
	flickering_lights = GetEntArray( "generic_flickering", "targetname" );
	pulsing_lights = GetEntArray( "generic_pulsing", "targetname" );
	double_strobe = GetEntArray( "generic_double_strobe", "targetname" );

	array_thread( flickering_lights, maps\_lights::generic_flickering );
	array_thread( pulsing_lights, maps\_lights::generic_pulsing );
	array_thread( double_strobe, maps\_lights::generic_double_strobe );
}

weapon_ammo()
{
	ents = GetEntArray();
	for ( i = 0; i < ents.size; i++ )
	{
		if ( ( IsDefined( ents[ i ].classname ) ) && ( GetSubStr( ents[ i ].classname, 0, 7 ) == "weapon_" ) )
		{
			weap = ents[ i ];
			
			weaponName = GetSubStr( weap.classname, 7 );

			// if we're maxing everything out, do that and earlyout
			if ( IsDefined( weap.script_ammo_max ) )
			{
				clip = WeaponClipSize( weaponName );
				reserve = WeaponMaxAmmo( weaponName );

				weap ItemWeaponSetAmmo( clip, reserve, clip, 0 ); // primary mode
				
				altWeaponName = WeaponAltWeaponName( weaponName );
				if( altWeaponName != "none" )
				{
					altclip = WeaponClipSize( altWeaponName );
					altreserve = WeaponMaxAmmo( altWeaponName );
					weap ItemWeaponSetAmmo( altclip, altreserve, altclip, 1 ); // altmode
				}

				continue;
			}

			change_ammo = false;
			clip = undefined;
			extra = undefined;

			change_alt_ammo = false;
			alt_clip = undefined;
			alt_extra = undefined;

			if ( IsDefined( weap.script_ammo_clip ) )
			{
				clip = weap.script_ammo_clip;
				change_ammo = true;
			}
			if ( IsDefined( weap.script_ammo_extra ) )
			{
				extra = weap.script_ammo_extra;
				change_ammo = true;
			}

			if ( IsDefined( weap.script_ammo_alt_clip ) )
			{
				alt_clip = weap.script_ammo_alt_clip;
				change_alt_ammo = true;
			}
			if ( IsDefined( weap.script_ammo_alt_extra ) )
			{
				alt_extra = weap.script_ammo_alt_extra;
				change_alt_ammo = true;
			}

			if ( change_ammo )
			{
				if ( !isdefined( clip ) )
					AssertMsg( "weapon: " + weap.classname + " " + weap.origin + " sets script_ammo_extra but not script_ammo_clip" );
				if ( !isdefined( extra ) )
					AssertMsg( "weapon: " + weap.classname + " " + weap.origin + " sets script_ammo_clip but not script_ammo_extra" );

				weap ItemWeaponSetAmmo( clip, extra );
			}

			if ( change_alt_ammo )
			{
				if ( !isdefined( alt_clip ) )
					AssertMsg( "weapon: " + weap.classname + " " + weap.origin + " sets script_ammo_alt_extra but not script_ammo_alt_clip" );
				if ( !isdefined( alt_extra ) )
					AssertMsg( "weapon: " + weap.classname + " " + weap.origin + " sets script_ammo_alt_clip but not script_ammo_alt_extra" );

				weap ItemWeaponSetAmmo( alt_clip, alt_extra, 0, 1 );
			}
		}
	}
}

trigger_group()
{
	self thread trigger_group_remove();

	level endon( "trigger_group_" + self.script_trigger_group );
	self waittill( "trigger" );
	level notify( "trigger_group_" + self.script_trigger_group, self );
}

trigger_group_remove()
{
	level waittill( "trigger_group_" + self.script_trigger_group, trigger );
	if ( self != trigger )
		self Delete();
}

/#
star( total )
{
	PrintLn( "         " );
	PrintLn( "         " );
	PrintLn( "         " );
	for ( i = 0; i < total; i++ )
	{
		for ( z = total - i; z > 1; z-- )
		Print( " " );
		Print( " * " );
		for ( z = 0; z < i; z++ )
			Print( " ** " );
		PrintLn( "" );
	}
	for ( i = total - 2; i > -1; i-- )
	{
		for ( z = total - i; z > 1; z-- )
		Print( " " );
		Print( " * " );
		for ( z = 0; z < i; z++ )
			Print( " ** " );
		PrintLn( "" );
	}

	PrintLn( "         " );
	PrintLn( "         " );
	PrintLn( "         " );
}
#/


exploder_load( trigger )
{
	level endon( "killexplodertridgers" + trigger.script_exploder );
	trigger waittill( "trigger" );
	if ( IsDefined( trigger.script_chance ) && RandomFloat( 1 ) > trigger.script_chance )
	{
		if ( !trigger script_delay() )
			wait 4;

		level thread exploder_load( trigger );
		return;
	}

	if ( !trigger script_delay() && IsDefined( trigger.script_exploder_delay ) )
	{
		wait( trigger.script_exploder_delay );
	}

	exploder( trigger.script_exploder );
	level notify( "killexplodertridgers" + trigger.script_exploder );
}

shock_onpain()
{
	PreCacheShellShock( "pain" );
	PreCacheShellShock( "default" );
	level.player endon( "death" );
	SetDvarIfUninitialized( "blurpain", "on" );

	while ( 1 )
	{
		oldhealth = level.player.health;
		level.player waittill( "damage" );
		if ( GetDvar( "blurpain" ) == "on" )
		{
// 			PrintLn( "health dif was ", oldhealth - level.player.health );
			if ( oldhealth - level.player.health < 129 )
			{
				// level.player ShellShock( "pain", 0.4 );
			}
			else
			{
				level.player ShellShock( "default", 5 );
			}
		}
	}
}




usedAnimations()
{
	SetDvar( "usedanim", "" );
	while ( 1 )
	{
		if ( GetDvar( "usedanim" ) == "" )
		{
			wait( 2 );
			continue;
		}

		animname = GetDvar( "usedanim" );
		SetDvar( "usedanim", "" );

		if ( !isdefined( level.completedAnims[ animname ] ) )
		{
			PrintLn( "^d -- -- No anims for ", animname, "^d -- -- -- -- -- - " );
			continue;
		}

		PrintLn( "^d -- -- Used animations for ", animname, "^d: ", level.completedAnims[ animname ].size, "^d -- -- -- -- -- - " );
		for ( i = 0; i < level.completedAnims[ animname ].size; i++ )
			PrintLn( level.completedAnims[ animname ][ i ] );
	}
}


badplace_think( badplace )
{
	if ( !isdefined( level.badPlaces ) )
		level.badPlaces = 0;

	level.badPlaces++;
	BadPlace_Cylinder( "badplace" + level.badPlaces, -1, badplace.origin, badplace.radius, 1024 );
}

setup_individual_exploder( ent )
{
	exploder_num = ent.script_exploder;
	if ( !isdefined( level.exploders[ exploder_num ] ) )
	{
		level.exploders[ exploder_num ] = [];
	}

	targetname = ent.targetname;
	if ( !isdefined( targetname ) )
		targetname = "";

	level.exploders[ exploder_num ][ level.exploders[ exploder_num ].size ] = ent;
	if ( exploder_model_starts_hidden( ent ) )
	{
		ent Hide();
		return;
	}

	if ( exploder_model_is_damaged_model( ent ) )
	{
		ent Hide();
		ent NotSolid();
		if ( IsDefined( ent.script_disconnectpaths ) )
			ent ConnectPaths();
		return;
	}

	if ( exploder_model_is_chunk( ent ) )
	{
		ent Hide();
		ent NotSolid();
		if ( IsDefined( ent.spawnflags ) && ( ent.spawnflags & 1 ) )
			ent ConnectPaths();
		return;
	}
}

setupExploders()
{
	level.exploders = [];

	// Hide exploder models.
	ents = GetEntArray( "script_brushmodel", "classname" );
	smodels = GetEntArray( "script_model", "classname" );
	for ( i = 0; i < smodels.size; i++ )
		ents[ ents.size ] = smodels[ i ];

	foreach ( ent in ents )
	{
		if ( IsDefined( ent.script_prefab_exploder ) )
			ent.script_exploder = ent.script_prefab_exploder;

		if ( IsDefined( ent.script_exploder ) )
		{
			setup_individual_exploder( ent );
		}
	}

	script_exploders = [];

	potentialExploders = GetEntArray( "script_brushmodel", "classname" );
	for ( i = 0; i < potentialExploders.size; i++ )
	{
		if ( IsDefined( potentialExploders[ i ].script_prefab_exploder ) )
			potentialExploders[ i ].script_exploder = potentialExploders[ i ].script_prefab_exploder;

		if ( IsDefined( potentialExploders[ i ].script_exploder ) )
			script_exploders[ script_exploders.size ] = potentialExploders[ i ];
	}

	potentialExploders = GetEntArray( "script_model", "classname" );
	for ( i = 0; i < potentialExploders.size; i++ )
	{
		if ( IsDefined( potentialExploders[ i ].script_prefab_exploder ) )
			potentialExploders[ i ].script_exploder = potentialExploders[ i ].script_prefab_exploder;

		if ( IsDefined( potentialExploders[ i ].script_exploder ) )
			script_exploders[ script_exploders.size ] = potentialExploders[ i ];
	}

	potentialExploders = GetEntArray( "item_health", "classname" );
	for ( i = 0; i < potentialExploders.size; i++ )
	{
		if ( IsDefined( potentialExploders[ i ].script_prefab_exploder ) )
			potentialExploders[ i ].script_exploder = potentialExploders[ i ].script_prefab_exploder;

		if ( IsDefined( potentialExploders[ i ].script_exploder ) )
			script_exploders[ script_exploders.size ] = potentialExploders[ i ];
	}

	if ( !isdefined( level.createFXent ) )
		level.createFXent = [];

	acceptableTargetnames = [];
	acceptableTargetnames[ "exploderchunk visible" ] = true;
	acceptableTargetnames[ "exploderchunk" ] = true;
	acceptableTargetnames[ "exploder" ] = true;

	thread setup_flag_exploders();

	for ( i = 0; i < script_exploders.size; i++ )
	{
		exploder = script_exploders[ i ];
		ent = createExploder( exploder.script_fxid );
		ent.v = [];
		ent.v[ "origin" ] = exploder.origin;
		ent.v[ "angles" ] = exploder.angles;
		ent.v[ "delay" ] = exploder.script_delay;
		ent.v[ "delay_post" ] = exploder.script_delay_post;
		ent.v[ "firefx" ] = exploder.script_firefx;
		ent.v[ "firefxdelay" ] = exploder.script_firefxdelay;
		ent.v[ "firefxsound" ] = exploder.script_firefxsound;
		ent.v[ "firefxtimeout" ] = exploder.script_firefxtimeout;
		ent.v[ "earthquake" ] = exploder.script_earthquake;
		ent.v[ "rumble" ] = exploder.script_rumble;
		ent.v[ "damage" ] = exploder.script_damage;
		ent.v[ "damage_radius" ] = exploder.script_radius;
		ent.v[ "soundalias" ] = exploder.script_soundalias;
		ent.v[ "repeat" ] = exploder.script_repeat;
		ent.v[ "delay_min" ] = exploder.script_delay_min;
		ent.v[ "delay_max" ] = exploder.script_delay_max;
		ent.v[ "target" ] = exploder.target;
		ent.v[ "ender" ] = exploder.script_ender;
		ent.v[ "physics" ] = exploder.script_physics;
		ent.v[ "type" ] = "exploder";
// 		ent.v[ "worldfx" ] = true;
		if ( !isdefined( exploder.script_fxid ) )
			ent.v[ "fxid" ] = "No FX";
		else
			ent.v[ "fxid" ] = exploder.script_fxid;
		ent.v[ "exploder" ] = exploder.script_exploder;
		AssertEx( IsDefined( exploder.script_exploder ), "Exploder at origin " + exploder.origin + " has no script_exploder" );

		if ( !isdefined( ent.v[ "delay" ] ) )
			ent.v[ "delay" ] = 0;



		if ( IsDefined( exploder.target ) )
		{
			get_ent = GetEntArray( ent.v[ "target" ], "targetname" )[ 0 ];
			if ( IsDefined( get_ent ) )
			{
				org = get_ent.origin;
				ent.v[ "angles" ] = VectorToAngles( org - ent.v[ "origin" ] );
			}
			else
			{
				get_ent = get_target_ent( ent.v[ "target" ] );
				if ( IsDefined( get_ent ) )
				{
					org = get_ent.origin;
					ent.v[ "angles" ] = VectorToAngles( org - ent.v[ "origin" ] );
				}
			}
// 			forward = AnglesToForward( angles );
// 			up = AnglesToUp( angles );
		}

		// this basically determines if its a brush / model exploder or not
		if ( exploder.code_classname == "script_brushmodel" || IsDefined( exploder.model ) )
		{
			ent.model = exploder;
			ent.model.disconnect_paths = exploder.script_disconnectpaths;
		}

		if ( IsDefined( exploder.targetname ) && IsDefined( acceptableTargetnames[ exploder.targetname ] ) )
			ent.v[ "exploder_type" ] = exploder.targetname;
		else
			ent.v[ "exploder_type" ] = "normal";

		ent common_scripts\_createfx::post_entity_creation_function();
	}
}

setup_flag_exploders()
{
	// createfx has to do 2 waittillframeends so we have to do 3 to make sure this comes after
	// createfx is all done setting up. Who will raise the gambit to 4? 
	waittillframeend;
	waittillframeend;
	waittillframeend;
	exploder_flags = [];

	foreach ( ent in level.createFXent )
	{
		if ( ent.v[ "type" ] != "exploder" )
			continue;
		theFlag = ent.v[ "flag" ];

		if ( !isdefined( theFlag ) )
		{
			continue;
		}

		if ( theFlag == "nil" )
		{
			ent.v[ "flag" ] = undefined;
		}

		exploder_flags[ theFlag ] = true;
	}

	foreach ( msg, _ in exploder_flags )
	{
		thread exploder_flag_wait( msg );
	}
}

exploder_flag_wait( msg )
{
	if ( !flag_exist( msg ) )
		flag_init( msg );
	flag_wait( msg );

	foreach ( ent in level.createFXent )
	{
		if ( ent.v[ "type" ] != "exploder" )
			continue;
		theFlag = ent.v[ "flag" ];

		if ( !isdefined( theFlag ) )
		{
			continue;
		}

		if ( theFlag != msg )
			continue;
		ent activate_individual_exploder();
	}
}


nearAIRushesPlayer()
{
	if ( IsAlive( level.enemySeekingPlayer ) )
		return;
	enemy = get_closest_ai( level.player.origin, "bad_guys" );
	if ( !isdefined( enemy ) )
		return;

	if ( Distance( enemy.origin, level.player.origin ) > 400 )
		return;

	level.enemySeekingPlayer = enemy;
	enemy SetGoalEntity( level.player );
	enemy.goalradius = 512;

}


playerDamageRumble()
{
	while ( true )
	{
		self waittill( "damage", amount );

		if ( IsDefined( self.specialDamage ) )
			continue;

		self PlayRumbleOnEntity( "damage_heavy" );
	}
}

playerDamageShellshock()
{
	while ( true )
	{
		level.player waittill( "damage", damage, attacker, direction_vec, point, cause );

		if ( cause == "MOD_EXPLOSIVE" ||
			cause == "MOD_GRENADE" ||
			cause == "MOD_GRENADE_SPLASH" ||
			cause == "MOD_PROJECTILE" ||
			cause == "MOD_PROJECTILE_SPLASH" )
		{
			time = 0;

			multiplier = level.player.maxhealth / 100;
			scaled_damage = damage * multiplier;

			if ( scaled_damage >= 90 )
				time = 4;
			else if ( scaled_damage >= 50 )
				time = 3;
			else if ( scaled_damage >= 25 )
				time = 2;
			else if ( scaled_damage > 10 )
				time = 1;

			if ( time )
				level.player ShellShock( "default", time );
		}
	}
}

map_is_early_in_the_game()
{
	/#
	if ( IsDefined( level.testmap ) )
		return true;
	#/

	if ( IsDefined( level.early_level[ level.script ] ) )
		return level.early_level[ level.script ];
	else
		return false;
}

player_throwgrenade_timer()
{
	self endon( "death" );
	self.lastgrenadetime = 0;
	while ( 1 )
	{
		while ( ! self IsThrowingGrenade() )
			wait .05;
		self.lastgrenadetime = GetTime();
		while ( self IsThrowingGrenade() )
			wait .05;
	}
}

player_special_death_hint()
{
	// Special Ops requires a different style of tracking and custom language in the hints.
	// Safer to branch cleanly and track separately from SP.
	if ( is_specialop() )
		return;

	if ( IsAlive( level.player ) )
		thread maps\_quotes::setDeadQuote();

	level.player thread player_throwgrenade_timer();

	level.player waittill( "death", attacker, cause, weaponName );

	if ( cause != "MOD_GRENADE" && cause != "MOD_GRENADE_SPLASH" && cause != "MOD_SUICIDE" && cause != "MOD_EXPLOSIVE" )
		return;

	if ( level.gameskill >= 2 )
	{
		// less death hinting on hard / fu
		if ( !map_is_early_in_the_game() )
			return;
	}

	if ( cause == "MOD_SUICIDE" )
	{
		if ( ( level.player.lastgrenadetime - GetTime() ) > 3.5 * 1000 )
			return;// magic number copied from fraggrenade asset.
		level notify( "new_quote_string" );
		// You died holding a grenade for too long.
		// Holding ^3[{+frag}]^7 allows you to cook off live grenades.
		thread grenade_death_text_hudelement( &"SCRIPT_GRENADE_SUICIDE_LINE1", &"SCRIPT_GRENADE_SUICIDE_LINE2" );
		return;
	}

	if ( cause == "MOD_EXPLOSIVE" )
	{
		if ( level.player destructible_death( attacker ) )
			return;
		

		if ( level.player exploding_barrel_death_af_chase( attacker ) )
			return;

		if ( level.player vehicle_death( attacker ) )
			return;
		
		if ( level.player exploding_barrel_death( attacker ) )
			return;
	}

	if ( cause == "MOD_GRENADE" || cause == "MOD_GRENADE_SPLASH" )
	{
		if ( IsDefined( weaponName ) && !IsWeaponDetonationTimed( weaponName ) )
		{
			return;
		}

		level notify( "new_quote_string" );
		// Would putting the content of the string here be so hard?
		SetDvar( "ui_deadquote", "@SCRIPT_GRENADE_DEATH" );
		thread grenade_death_indicator_hudelement();
		return;
	}
}

vehicle_death( attacker )
{
	if ( !isdefined( attacker ) )
		return false;
	
	if ( attacker.code_classname != "script_vehicle" )
		return false;
	
	level notify( "new_quote_string" );

	// You were killed by an exploding vehicle. Vehicles on fire are likely to explode.
	SetDvar( "ui_deadquote", "@SCRIPT_EXPLODING_VEHICLE_DEATH" );
	thread special_death_indicator_hudelement( "hud_burningcaricon", 96, 96 );
	
	return true;
}

destructible_death( attacker )
{
	if ( !isdefined( attacker ) )
		return false;

	if ( !isdefined( attacker.destructible_type ) )
		return false;

	level notify( "new_quote_string" );

	if ( IsSubStr( attacker.destructible_type, "vehicle" ) )
	{
		// You were killed by an exploding vehicle. Vehicles on fire are likely to explode.
		SetDvar( "ui_deadquote", "@SCRIPT_EXPLODING_VEHICLE_DEATH" );
		thread special_death_indicator_hudelement( "hud_burningcaricon", 96, 96 );
	}
	else
	{
		// You were killed by an explosion.\nSome burning objects can explode.
		SetDvar( "ui_deadquote", "@SCRIPT_EXPLODING_DESTRUCTIBLE_DEATH" );
		thread special_death_indicator_hudelement( "hud_destructibledeathicon", 96, 96 );
	}

	return true;
}

exploding_barrel_death_af_chase( attacker )
{
	// paranoid.. can't imagine how this would break the game but just in case.
	// just reordering things so the that we get the exploding barrel death message before the vehilce one.
	// see bugzilla 110565
	// next game maybe just put this before the vehicle death.
	if( level.script != "af_chase" )
		return false;
	return exploding_barrel_death( attacker );
}

exploding_barrel_death( attacker )
{
	// check if the death was caused by a barrel
	// have to check time and location against the last explosion because the attacker isn't the
	// barrel because the ent that damaged the barrel is passed through as the attacker instead
	if ( IsDefined( level.lastExplodingBarrel ) )
	{
		// killed the same frame a barrel exploded
		if ( GetTime() != level.lastExplodingBarrel[ "time" ] )
			return false;

		// within the blast radius of the barrel that exploded
		d = Distance( self.origin, level.lastExplodingBarrel[ "origin" ] );
		if ( d > level.lastExplodingBarrel[ "radius" ] )
			return false;

		// must have been killed by that barrel
		level notify( "new_quote_string" );
		// You were killed by an exploding barrel. Red barrels will explode when shot.
		SetDvar( "ui_deadquote", "@SCRIPT_EXPLODING_BARREL_DEATH" );
		thread special_death_indicator_hudelement( "hud_burningbarrelicon", 64, 64 );
		return true;
	}
	return false;
}

grenade_death_text_hudelement( textLine1, textLine2 )
{
	level.player.failingMission = true;

	SetDvar( "ui_deadquote", "" );

	wait( 1.5 );

	fontElem = NewHudElem();
	fontElem.elemType = "font";
	fontElem.font = "default";
	fontElem.fontscale = 1.5;
	fontElem.x = 0;
	fontElem.y = -30;
	fontElem.alignX = "center";
	fontElem.alignY = "middle";
	fontElem.horzAlign = "center";
	fontElem.vertAlign = "middle";
	fontElem SetText( textLine1 );
	fontElem.foreground = true;
	fontElem.alpha = 0;
	fontElem FadeOverTime( 1 );
	fontElem.alpha = 1;

	if ( IsDefined( textLine2 ) )
	{
		fontElem = NewHudElem();
		fontElem.elemType = "font";
		fontElem.font = "default";
		fontElem.fontscale = 1.5;
		fontElem.x = 0;
		fontElem.y = -25 + level.fontHeight * fontElem.fontscale;
		fontElem.alignX = "center";
		fontElem.alignY = "middle";
		fontElem.horzAlign = "center";
		fontElem.vertAlign = "middle";
		fontElem SetText( textLine2 );
		fontElem.foreground = true;
		fontElem.alpha = 0;
		fontElem FadeOverTime( 1 );
		fontElem.alpha = 1;
	}
}

grenade_death_indicator_hudelement()
{
	wait( 1.5 );
	overlay = NewHudElem();
	overlay.x = 0;
	overlay.y = 68;
	overlay SetShader( "hud_grenadeicon", 50, 50 );
	overlay.alignX = "center";
	overlay.alignY = "middle";
	overlay.horzAlign = "center";
	overlay.vertAlign = "middle";
	overlay.foreground = true;
	overlay.alpha = 0;
	overlay FadeOverTime( 1 );
	overlay.alpha = 1;

	overlay = NewHudElem();
	overlay.x = 0;
	overlay.y = 25;
	overlay SetShader( "hud_grenadepointer", 50, 25 );
	overlay.alignX = "center";
	overlay.alignY = "middle";
	overlay.horzAlign = "center";
	overlay.vertAlign = "middle";
	overlay.foreground = true;
	overlay.alpha = 0;
	overlay FadeOverTime( 1 );
	overlay.alpha = 1;
}

special_death_indicator_hudelement( shader, iWidth, iHeight, fDelay )
{
	if ( !isdefined( fDelay ) )
		fDelay = 1.5;
	wait fDelay;
	overlay = NewHudElem();
	overlay.x = 0;
	overlay.y = 40;
	overlay SetShader( shader, iWidth, iHeight );
	overlay.alignX = "center";
	overlay.alignY = "middle";
	overlay.horzAlign = "center";
	overlay.vertAlign = "middle";
	overlay.foreground = true;
	overlay.alpha = 0;
	overlay FadeOverTime( 1 );
	overlay.alpha = 1;
}

triggered_playerseek( trig )
{
	groupNum = trig.script_triggered_playerseek;
	trig waittill( "trigger" );

	ai = GetAIArray();
	for ( i = 0; i < ai.size; i++ )
	{
		if ( !isAlive( ai[ i ] ) )
			continue;
		if ( ( IsDefined( ai[ i ].script_triggered_playerseek ) ) && ( ai[ i ].script_triggered_playerseek == groupNum ) )
		{
			ai[ i ].goalradius = 800;
			ai[ i ] SetGoalEntity( level.player );
			level thread maps\_spawner::delayed_player_seek_think( ai[ i ] );
		}
	}
}

traverseThink()
{
	ent = GetEnt( self.target, "targetname" );
	self.traverse_height = ent.origin[ 2 ];
	ent Delete();
}

/#
deprecatedTraverseThink()
{
	wait .05;
	PrintLn( "^1Warning: deprecated traverse used in this map somewhere around " + self.origin );
	if ( GetDvarInt( "scr_traverse_debug" ) )
	{
		while ( 1 )
		{
			Print3d( self.origin, "deprecated traverse!" );
			wait .05;
		}
	}
}
#/

pianoDamageThink()
{
	org = self GetOrigin();
	// 
// 	self SetHintString( &"SCRIPT_PLATFORM_PIANO" );
	note[ 0 ] = "large";
	note[ 1 ] = "small";
	for ( ;; )
	{
		self waittill( "trigger" );
		thread play_sound_in_space( "bullet_" + random( note ) + "_piano", org );
	}
}

pianoThink()
{
	org = self GetOrigin();
	note = "piano_" + self.script_noteworthy;
	// 
	self SetHintString( &"SCRIPT_PLATFORM_PIANO" );
	for ( ;; )
	{
		self waittill( "trigger" );
		thread play_sound_in_space( note, org );
	}
}


bcTrigger( trigger )
{
	realTrigger = undefined;

	// see if this targets an auxiliary trigger for advanced usage
	if ( IsDefined( trigger.target ) )
	{
		targetEnts = GetEntArray( trigger.target, "targetname" );

		if ( IsSubStr( targetEnts[ 0 ].classname, "trigger" ) )
		{
			realTrigger = targetEnts[ 0 ];
		}
	}

	// if we target an auxiliary trigger, that one kicks off the custom battlechatter event
	if ( IsDefined( realTrigger ) )
	{
		realTrigger waittill( "trigger", other );
	}
	else
	{
		trigger waittill( "trigger", other );
	}

	soldier = undefined;

	// for advanced usage: target an auxiliary trigger that kicks off the battlechatter event, but only
	//  if the player is touching the trigger that targets it.
	if ( IsDefined( realTrigger ) )
	{
		// enemy touched trigger, have a friendly tell the player about it
		if ( ( other.team != level.player.team ) && level.player IsTouching( trigger ) )
		{
			soldier = level.player animscripts\battlechatter::getClosestFriendlySpeaker( "custom" );
		}
		// friendly touched auxiliary trigger, have the enemy AI chatter about it
		else if ( other.team == level.player.team )
		{
			enemyTeam = "axis";
			if ( level.player.team == "axis" )
			{
				enemyTeam = "allies";
			}

			soldiers = animscripts\battlechatter::getSpeakers( "custom", enemyTeam );
			// for some reason, get_array_of_farthest returns the closest at index 0
			soldiers = get_array_of_farthest( level.player.origin, soldiers );

			foreach ( guy in soldiers )
			{
				if ( guy IsTouching( trigger ) )
				{
					soldier = guy;

					if ( bcTrigger_validate_distance( guy.origin ) )
					{
						break;
					}
				}
			}
		}
	}
	// otherwise we're just using one trigger
	else if ( IsPlayer( other ) )
	{
		soldier = other animscripts\battlechatter::getClosestFriendlySpeaker( "custom" );
	}
	else
	{
		soldier = other;
	}

	if ( !IsDefined( soldier ) )
	{
		return;
	}

	if ( !bcTrigger_validate_distance( soldier.origin ) )
	{
		return;
	}

	success = soldier custom_battlechatter( trigger.script_bctrigger );

	// if the chatter didn't play successfully, rethread the function on the trigger
	if ( !success )
	{
		level delayThread( 0.25, ::bcTrigger, trigger );
	}
	else
	{
		trigger notify( "custom_battlechatter_done" );
	}
}

bcTrigger_validate_distance( speakerOrigin )
{
	if ( Distance( speakerOrigin, level.player GetOrigin() ) <= 512 )
	{
		return true;
	}

	return false;
}


waterThink()
{
	Assert( IsDefined( self.target ) );
	targeted = GetEnt( self.target, "targetname" );
	Assert( IsDefined( targeted ) );
	waterHeight = targeted.origin[ 2 ];
	targeted = undefined;

	level.depth_allow_prone = 8;
	level.depth_allow_crouch = 33;
	level.depth_allow_stand = 50;
	
	wasInWater = false;
	//prof_begin( "water_stance_controller" );

	for ( ;; )
	{
		wait 0.05;
		// restore all defaults
		if ( !level.player.inWater && wasInWater )
		{
			wasInWater = false;
			level.player AllowProne( true );
			level.player AllowCrouch( true );
			level.player AllowStand( true );
			thread waterThink_rampSpeed( level.default_run_speed );
		}

		// wait until in water
		self waittill( "trigger" );
		level.player.inWater = true;
		wasInWater = true;
		while ( level.player IsTouching( self ) )
		{
			level.player.inWater = true;
			playerOrg = level.player GetOrigin();
			d = ( playerOrg[ 2 ] - waterHeight );
			if ( d > 0 )
				break;

			// slow the players movement based on how deep it is
			newSpeed = Int( level.default_run_speed - abs( d * 5 ) );
			if ( newSpeed < 50 )
				newSpeed = 50;
			Assert( newSpeed <= 190 );
			thread waterThink_rampSpeed( newSpeed );

			// controll the allowed stances in this water height
			if ( abs( d ) > level.depth_allow_crouch )
				level.player AllowCrouch( false );
			else
				level.player AllowCrouch( true );

			if ( abs( d ) > level.depth_allow_prone )
				level.player AllowProne( false );
			else
				level.player AllowProne( true );

			wait 0.5;
		}
		level.player.inWater = false;
		wait 0.05;
	}

	//prof_end( "water_stance_controller" );
}

waterThink_rampSpeed( newSpeed )
{
	level notify( "ramping_water_movement_speed" );
	level endon( "ramping_water_movement_speed" );

	rampTime = 0.5;
	numFrames = Int( rampTime * 20 );

	currentSpeed = GetDvarInt( "g_speed" );

	qSlower = false;
	if ( newSpeed < currentSpeed )
		qSlower = true;

	speedDifference = Int( abs( currentSpeed - newSpeed ) );
	speedStepSize = Int( speedDifference / numFrames );

	for ( i = 0; i < numFrames; i++ )
	{
		currentSpeed = GetDvarInt( "g_speed" );
		if ( qSlower )
			SetSavedDvar( "g_speed", ( currentSpeed - speedStepSize ) );
		else
			SetSavedDvar( "g_speed", ( currentSpeed + speedStepSize ) );
		wait 0.05;
	}
	SetSavedDvar( "g_speed", newSpeed );
}



massNodeInitFunctions()
{
	nodes = GetAllNodes();

	thread maps\_mgturret::auto_mgTurretLink( nodes );
	thread maps\_mgturret::saw_mgTurretLink( nodes );
	thread maps\_colors::init_color_grouping( nodes );
}


 /*
 * * * * * * * * * *

TRIGGER_UNLOCK

 * * * * * * * * * *
 */

trigger_unlock( trigger )
{
	// trigger unlocks unlock another trigger. When that trigger is hit, all unlocked triggers relock
	// trigger_unlocks with the same script_noteworthy relock the same triggers

	noteworthy = "not_set";
	if ( IsDefined( trigger.script_noteworthy ) )
		noteworthy = trigger.script_noteworthy;

	target_triggers = GetEntArray( trigger.target, "targetname" );

	trigger thread trigger_unlock_death( trigger.target );

	for ( ;; )
	{
		array_thread( target_triggers, ::trigger_off );
		trigger waittill( "trigger" );
		array_thread( target_triggers, ::trigger_on );

		wait_for_an_unlocked_trigger( target_triggers, noteworthy );

		array_notify( target_triggers, "relock" );
	}
}

trigger_unlock_death( target )
{
	self waittill( "death" );
	target_triggers = GetEntArray( target, "targetname" );
	array_thread( target_triggers, ::trigger_off );
}

wait_for_an_unlocked_trigger( triggers, noteworthy )
{
	level endon( "unlocked_trigger_hit" + noteworthy );
	ent = SpawnStruct();
	for ( i = 0; i < triggers.size; i++ )
	{
		triggers[ i ] thread report_trigger( ent, noteworthy );
	}
	ent waittill( "trigger" );
	level notify( "unlocked_trigger_hit" + noteworthy );
}

report_trigger( ent, noteworthy )
{
	self endon( "relock" );
	level endon( "unlocked_trigger_hit" + noteworthy );
	self waittill( "trigger" );
	ent notify( "trigger" );
}

 /*
 * * * * * * * * * *

TRIGGER_LOOKAT

 * * * * * * * * * *
 */

get_trigger_targs()
{
	triggers = [];
	target_origin = undefined;// was self.origin
	if ( IsDefined( self.target ) )
	{
		targets = GetEntArray( self.target, "targetname" );
		orgs = [];
		foreach ( target in targets )
		{
			if ( target.classname == "script_origin" )
				orgs[ orgs.size ] = target;
			if ( IsSubStr( target.classname, "trigger" ) )
				triggers[ triggers.size ] = target;
		}

		targets = getstructarray( self.target, "targetname" );

		foreach ( target in targets )
		{
			orgs[ orgs.size ] = target;
		}

		AssertEx( orgs.size < 2, "Trigger at " + self.origin + " targets multiple script origins" );
		if ( orgs.size == 1 )
		{
			org = orgs[ 0 ];
			target_origin = org.origin;
			if ( IsDefined( org.code_classname ) )
				org Delete();
		}
	}

	/#
	if ( IsDefined( self.targetname ) )
		AssertEx( IsDefined( target_origin ), self.targetname + " at " + self.origin + " has no target origin." );
	else
		AssertEx( IsDefined( target_origin ), self.classname + " at " + self.origin + " has no target origin." );
	#/

	array = [];
	array[ "triggers" ] = triggers;
	array[ "target_origin" ] = target_origin;
	return array;
}

trigger_lookat( trigger )
{
	// ends when the flag is hit
	trigger_lookat_think( trigger, true );
}

trigger_looking( trigger )
{
	// flag is only set while the thing is being looked at
	trigger_lookat_think( trigger, false );
}

trigger_visionset_change( trigger )
{
	AssertEx( IsDefined( trigger.script_visionset ), "trigger_multiple_visionset at " + trigger.origin + " has no script_visionset." );
	transition = 3;

	if ( IsDefined( trigger.script_delay ) )
		transition = trigger.script_delay;

	while ( 1 )
	{
		trigger waittill( "trigger" );

		set_vision_set( trigger.script_visionset, transition );
		wait transition;
	}
}

trigger_lookat_think( trigger, endOnFlag )
{
	success_dot = 0.78;
	if ( IsDefined( trigger.script_dot ) )
	{
		success_dot = trigger.script_dot;
		AssertEx( success_dot <= 1, "Script_dot should be between 0 and 1" );
	}

	array = trigger get_trigger_targs();
	triggers = array[ "triggers" ];
	target_origin = array[ "target_origin" ];

	has_flag = IsDefined( trigger.script_flag ) || IsDefined( trigger.script_noteworthy );
	flagName = undefined;

	if ( has_flag )
	{
		flagName = trigger get_trigger_flag();
		if ( !isdefined( level.flag[ flagName ] ) )
			flag_init( flagName );
	}
	else
	{
		if ( !triggers.size )
			AssertEx( IsDefined( trigger.script_flag ) || IsDefined( trigger.script_noteworthy ), "Trigger_lookat at " + trigger.origin + " has no script_flag! The script_flag is used as a flag that gets set when the trigger is activated." );
	}

	if ( endOnFlag && has_flag )
	{
		level endon( flagName );
	}

	trigger endon( "death" );
	do_sighttrace = false;

	if ( IsDefined( trigger.script_parameters ) )
	{
		do_sighttrace = !issubstr( "no_sight", trigger.script_parameters );
	}

//	touching_trigger = [];

	for ( ;; )
	{
		if ( has_flag )
			flag_clear( flagName );

		trigger waittill( "trigger", other );

		AssertEx( IsPlayer( other ), "trigger_lookat currently only supports looking from the player" );
		touching_trigger = [];

		while ( other IsTouching( trigger ) )
		{
			if ( do_sighttrace && !sightTracePassed( other GetEye(), target_origin, false, undefined ) )
			{
				if ( has_flag )
					flag_clear( flagName );
				wait( 0.5 );
				continue;
			}

			normal = VectorNormalize( target_origin - other.origin );
		    player_angles = other GetPlayerAngles();
		    player_forward = AnglesToForward( player_angles );

	// 		angles = VectorToAngles( target_origin - other.origin );
	// 	    forward = AnglesToForward( angles );
	// 		draw_arrow( level.player.origin, level.player.origin + vector_multiply( forward, 150 ), ( 1, 0.5, 0 ) );
	// 		draw_arrow( level.player.origin, level.player.origin + vector_multiply( player_forward, 150 ), ( 0, 0.5, 1 ) );

			dot = VectorDot( player_forward, normal );
			if ( dot >= success_dot )
			{
				// notify targetted triggers as well
				array_thread( triggers, ::send_notify, "trigger" );

				if ( has_flag )
					flag_set( flagName, other );

				if ( endOnFlag )
					return;
				wait( 2 );
			}
			else
			{
				if ( has_flag )
					flag_clear( flagName );
			}

			if ( do_sighttrace )
				wait( 0.5 );
			else
				wait 0.05;
		}
	}
}

/*
* * * * * * * * * *

TRIGGER_CANSEE

* * * * * * * * * *
*/

trigger_cansee( trigger )
{
	triggers = [];
	target_origin = undefined;// was trigger.origin

	array = trigger get_trigger_targs();
	triggers = array[ "triggers" ];
	target_origin = array[ "target_origin" ];

	has_flag = IsDefined( trigger.script_flag ) || IsDefined( trigger.script_noteworthy );
	flagName = undefined;

	if ( has_flag )
	{
		flagName = trigger get_trigger_flag();
		if ( !isdefined( level.flag[ flagName ] ) )
			flag_init( flagName );
	}
	else
	{
		if ( !triggers.size )
			AssertEx( IsDefined( trigger.script_flag ) || IsDefined( trigger.script_noteworthy ), "Trigger_cansee at " + trigger.origin + " has no script_flag! The script_flag is used as a flag that gets set when the trigger is activated." );
	}

	trigger endon( "death" );

	range = 12;
	offsets = [];
	offsets[ offsets.size ] = ( 0, 0, 0 );
	offsets[ offsets.size ] = ( range, 0, 0 );
	offsets[ offsets.size ] = ( range * -1, 0, 0 );
	offsets[ offsets.size ] = ( 0, range, 0 );
	offsets[ offsets.size ] = ( 0, range * -1, 0 );
	offsets[ offsets.size ] = ( 0, 0, range );

	for ( ;; )
	{
		if ( has_flag )
			flag_clear( flagName );

		trigger waittill( "trigger", other );
		AssertEx( IsPlayer( other ), "trigger_cansee currently only supports looking from the player" );

		while ( level.player IsTouching( trigger ) )
		{
			if ( !( other cantraceto( target_origin, offsets ) ) )
			{
				if ( has_flag )
					flag_clear( flagName );
				wait( 0.1 );
				continue;
			}

			if ( has_flag )
				flag_set( flagName );

			// notify targetted triggers as well
			array_thread( triggers, ::send_notify, "trigger" );
			wait( 0.5 );
		}
	}
}

cantraceto( target_origin, offsets )
{
	for ( i = 0; i < offsets.size; i++ )
	{
		if ( SightTracePassed( self GetEye(), target_origin + offsets[ i ], true, self ) )
			return true;
	}
	return false;
}


indicate_start( start )
{
	hudelem = NewHudElem();
	hudelem.alignX = "left";
	hudelem.alignY = "middle";
	hudelem.x = 10;
	hudelem.y = 400;
//	hudelem.label = "Loading from start: " + start;
	hudelem SetText( start );
	hudelem.alpha = 0;
	hudelem.fontScale = 3;
	wait( 1 );
	hudelem FadeOverTime( 1 );
	hudelem.alpha = 1;
	wait( 5 );
	hudelem FadeOverTime( 1 );
	hudelem.alpha = 0;
	wait( 1 );
	hudelem Destroy();
}

handle_starts()
{
	create_dvar( "start", "" );

	if ( GetDvar( "scr_generateClipModels" ) != "" && GetDvar( "scr_generateClipModels" ) != "0" )
		return;// shortcut for generating clipmodels gah.

 	if ( !isdefined( level.start_functions ) )
		level.start_functions = [];

	PrecacheMenu( "start" );

	AssertEx( GetDvar( "jumpto" ) == "", "Use the START dvar instead of JUMPTO" );

	start = ToLower( GetDvar( "start" ) );

	// find the start that matches the one the dvar is set to, and execute it
	dvars = get_start_dvars();

	if ( IsDefined( level.start_point ) )
		start = level.start_point;

	// first try to find the start based on the dvar
	start_index = 0;
	for ( i = 0; i < dvars.size; i++ )
	{
		if ( start == dvars[ i ] )
		{
			start_index = i;
			level.start_point = dvars[ i ];
			break;
		}
	}

	// then try based on the override
	if ( IsDefined( level.default_start_override ) && !isdefined( level.start_point ) )
	{
		foreach ( index, dvar in dvars )
		{
			if ( level.default_start_override == dvar )
			{
				start_index = index;
				level.start_point = dvar;
				break;
			}
		}
	}

	if ( !isdefined( level.start_point ) )
	{
		// was a start set with default_start()?
		if ( IsDefined( level.default_start ) )
			level.start_point = "default";
		else
		if ( level_has_start_points() )
			level.start_point = level.start_functions[ 0 ][ "name" ];
		else
			level.start_point = "default";
	}

	waittillframeend;// starts happen at the end of the first frame, so threads in the mission have a chance to run and init stuff
	thread start_menu();

	if ( level.start_point == "default" )
	{
		if ( IsDefined( level.default_start ) )
		{
			level thread [[ level.default_start ]]();
		}

	}
	else
	{
		/#
		if ( IsDefined( level.start_loc_string[ level.start_point ] ) )
			thread indicate_start( level.start_loc_string[ level.start_point ] );
		else
			thread indicate_start( level.start_point );
		#/
		start_array = level.start_arrays[ level.start_point ];
		thread [[ start_array[ "start_func" ] ]]();
	}

	if ( is_default_start() )
	{
		string = get_string_for_starts( dvars );
		SetDvar( "start", string );
	}

	waittillframeend;// let the frame finish for all ai init type stuff that goes on in start points

	previously_run_logic_functions = [];
	// run each logic function in order
	for ( i = start_index; i < level.start_functions.size; i++ )
	{
		start_array = level.start_functions[ i ];
		if ( !isdefined( start_array[ "logic_func" ] ) )
			continue;

		if ( already_ran_function( start_array[ "logic_func" ], previously_run_logic_functions ) )
			continue;

		[[ start_array[ "logic_func" ] ]]();
		previously_run_logic_functions[ previously_run_logic_functions.size ] = start_array[ "logic_func" ];
	}
}

already_ran_function( func, previously_run_logic_functions )
{
	foreach ( logic_function in previously_run_logic_functions )
	{
		if ( logic_function == func )
			return true;
	}
	return false;
}

get_string_for_starts( dvars )
{
	string = " ** No starts have been set up for this map with maps\_utility::add_start().";
	if ( dvars.size )
	{
		string = " ** ";
		for ( i = dvars.size - 1; i >= 0; i-- )
		{
			string = string + dvars[ i ] + " ";
		}
	}

	SetDvar( "start", string );
	return string;
}


create_start( start, index )
{
	hudelem = NewHudElem();
	hudelem.alignX = "left";
	hudelem.alignY = "middle";
	hudelem.x = 80;
	hudelem.y = 80 + index * 18;
	hudelem SetText( start );
	hudelem.alpha = 0;
	hudelem.foreground = true;

	hudelem.fontScale = 1.75;
	hudelem FadeOverTime( 0.5 );
	hudelem.alpha = 1;
	return hudelem;
}

start_menu()
{
/#
	if ( !isdefined( level.start_loc_string ) )
	{
		 level.start_loc_string = [];
	}

	for ( ;; )
	{
		if ( GetDvarInt( "debug_start" ) )
		{
			SetDevDvar( "debug_start", 0 );
			SetSavedDvar( "hud_drawhud", 1 );
			display_starts();
		}
		else
		{
			level.display_starts_Pressed = false;
		}
		wait( 0.05 );
	}
#/
}

start_nogame()
{
	//empty.. this start for when you want to play without playing. for viewing geo maybe?
	array_call( GetAIArray(), ::Delete );
	array_call( GetSpawnerArray(), ::Delete );
	//array_call( GetEntArray( "trigger_multiple", "code_classname" ), ::Delete );
	//array_call( GetEntArray( "trigger_radius", "code_classname" ), ::Delete );
}

get_start_dvars()
{
	dvars = [];
	for ( i = 0; i < level.start_functions.size; i++ )
	{
		dvars[ dvars.size ] = level.start_functions[ i ][ "name" ];
	}
	return dvars;
}

display_starts()
{

	level.display_starts_Pressed = true;
	if ( level.start_functions.size <= 0 )
		return;

	dvars = get_start_dvars();
	dvars[ dvars.size ] = "default";
	dvars[ dvars.size ] = "cancel";

	dvars = array_reverse( dvars );
	// Available Starts:
	title = create_start( "Available Starts:", -1 );
	title.color = ( 1, 1, 1 );
	elems = [];

	for ( i = 0; i < dvars.size; i++ )
	{
		dvar = dvars[ i ];
		start_string = "[" + dvars[ i ] + "]";
		if ( IsDefined( level.start_loc_string[ dvar ] ) )
		{
			start_string += " -> ";
			start_string += level.start_loc_string[ dvar ];
		}

		elems[ elems.size ] = create_start( start_string, dvars.size - i );
	}

	selected = dvars.size - 1;
	up_pressed = false;
	down_pressed = false;

	for ( ;; )
	{
		if ( !( level.player ButtonPressed( "F10" ) ) )
		{
			level.display_starts_Pressed = false;
		}


		for ( i = 0; i < dvars.size; i++ )
		{
			elems[ i ].color = ( 0.7, 0.7, 0.7 );
		}

		elems[ selected ].color = ( 1, 1, 0 );

		if ( !up_pressed )
		{
			if ( level.player ButtonPressed( "UPARROW" ) || level.player ButtonPressed( "DPAD_UP" ) || level.player ButtonPressed( "APAD_UP" ) )
			{
				up_pressed = true;
				selected++;
			}
		}
		else
		{
			if ( !level.player ButtonPressed( "UPARROW" ) && !level.player ButtonPressed( "DPAD_UP" ) && !level.player ButtonPressed( "APAD_UP" ) )
				up_pressed = false;
		}


		if ( !down_pressed )
		{
			if ( level.player ButtonPressed( "DOWNARROW" ) || level.player ButtonPressed( "DPAD_DOWN" ) || level.player ButtonPressed( "APAD_DOWN" ) )
			{
				down_pressed = true;
				selected--;
			}
		}
		else
		{
			if ( !level.player ButtonPressed( "DOWNARROW" ) && !level.player ButtonPressed( "DPAD_DOWN" ) && !level.player ButtonPressed( "APAD_DOWN" ) )
				down_pressed = false;
		}

		if ( selected < 0 )
			selected = dvars.size - 1;

		if ( selected >= dvars.size )
			selected = 0;


		if ( level.player ButtonPressed( "kp_enter" ) || level.player ButtonPressed( "BUTTON_A" ) || level.player ButtonPressed( "enter" ) )
		{
			if ( dvars[ selected ] == "cancel" )
			{
				title Destroy();
				for ( i = 0; i < elems.size; i++ )
				{
					elems[ i ] Destroy();
				}
				break;
			}


			SetDvar( "start", dvars[ selected ] );
			level.player OpenPopupMenu( "start" );
//			ChangeLevel( level.script, false );
		}
		wait( 0.05 );
	}

}

start_button_combo()
{
	if ( !( level.player ButtonPressed( "BUTTON_RSTICK" ) ) )
		return false;

	if ( !( level.player ButtonPressed( "BUTTON_RSHLDR" ) ) )
		return false;

	return true;
}


devhelp_hudElements( hudarray, alpha )
{
	for ( i = 0; i < hudarray.size; i++ )
		for ( p = 0; p < 5; p++ )
			hudarray[ i ][ p ].alpha = alpha;

}

devhelp()
{
	/#
	helptext = [];
	helptext[ helptext.size ] = "P: pause                                                       ";
	helptext[ helptext.size ] = "T: super speed                                                 ";
	helptext[ helptext.size ] = ".: fullbright                                                  ";
	helptext[ helptext.size ] = "U: toggle normal maps                                          ";
	helptext[ helptext.size ] = "Y: print a line of text, useful for putting it in a screenshot ";
	helptext[ helptext.size ] = "H: toggle detailed ent info                                    ";
	helptext[ helptext.size ] = "g: toggle simplified ent info                                  ";
	helptext[ helptext.size ] = ", : show the triangle outlines                                  ";
	helptext[ helptext.size ] = " - : Back 10 seconds                                             ";
	helptext[ helptext.size ] = "6: Replay mark                                                 ";
	helptext[ helptext.size ] = "7: Replay goto                                                 ";
	helptext[ helptext.size ] = "8: Replay live                                                 ";
	helptext[ helptext.size ] = "0: Replay back 3 seconds                                       ";
	helptext[ helptext.size ] = "[ : Replay restart                                              ";
	helptext[ helptext.size ] = "\: map_restart                                                 ";
	helptext[ helptext.size ] = "U: draw material name                                          ";
	helptext[ helptext.size ] = "J: display tri counts                                          ";
	helptext[ helptext.size ] = "B: cg_ufo                                                      ";
	helptext[ helptext.size ] = "N: ufo                                                         ";
	helptext[ helptext.size ] = "C: god                                                         ";
	helptext[ helptext.size ] = "K: Show ai nodes                                               ";
	helptext[ helptext.size ] = "L: Show ai node connections                                    ";
	helptext[ helptext.size ] = "Semicolon: Show ai pathing                                     ";


	strOffsetX = [];
	strOffsetY = [];
	strOffsetX[ 0 ] = 0;
	strOffsetY[ 0 ] = 0;
	strOffsetX[ 1 ] = 1;
	strOffsetY[ 1 ] = 1;
	strOffsetX[ 2 ] = -2;
	strOffsetY[ 2 ] = 1;
	strOffsetX[ 3 ] = 1;
	strOffsetY[ 3 ] = -1;
	strOffsetX[ 4 ] = -2;
	strOffsetY[ 4 ] = -1;
	hudarray = [];
	for ( i = 0; i < helptext.size; i++ )
	{
		newStrArray = [];
		for ( p = 0; p < 5; p++ )
		{
			// setup instructional text
			newStr = NewHudElem();
			newStr.alignX = "left";
			newStr.location = 0;
			newStr.foreground = 1;
			newStr.fontScale = 1.30;
			newStr.sort = 20 - p;
			newStr.alpha = 1;
			newStr.x = 54 + strOffsetX[ p ];
			newStr.y = 80 + strOffsetY[ p ] + i * 15;
			newstr SetText( helptext[ i ] );
			if ( p > 0 )
				newStr.color = ( 0, 0, 0 );

			newStrArray[ newStrArray.size ] = newStr;
		}
		hudarray[ hudarray.size ] = newStrArray;
	}

	devhelp_hudElements( hudarray, 0 );

	while ( 1 )
	{
		update = false;
		if ( level.player ButtonPressed( "F1" ) )
		{
				devhelp_hudElements( hudarray, 1 );
				while ( level.player ButtonPressed( "F1" ) )
					wait .05;
		}
		devhelp_hudElements( hudarray, 0 );
		wait .05;
	}
	#/
}

flag_set_player_trigger( trigger )
{
	if ( is_coop() )
	{
		thread flag_set_coop_trigger( trigger );
		return;
	}

	flag = trigger get_trigger_flag();

	if ( !isdefined( level.flag[ flag ] ) )
	{
		flag_init( flag );
	}

	for ( ;; )
	{
		trigger waittill( "trigger", other );
		if ( !isplayer( other ) )
			continue;
		trigger script_delay();
		flag_set( flag );
	}
}

trigger_nobloodpool( trigger )
{
	// Issue: If a guy dies and animates into the trigger, he will still spawn a blood pool.
	for ( ;; )
	{
		trigger waittill( "trigger", other );
		if ( !isalive( other ) )
			continue;

		other.skipBloodPool = true;
		other thread set_wait_then_clear_skipBloodPool();
	}
}

set_wait_then_clear_skipBloodPool()
{

	// Issue: If a guy dies during this timer even though he has left the trigger area, he will not spawn a pool. Deemed acceptable.
	self notify( "notify_wait_then_clear_skipBloodPool" );
	self endon( "notify_wait_then_clear_skipBloodPool" );
	self endon( "death" );

	wait 2;
	self.skipBloodPool = undefined;
}

flag_set_trigger( trigger )
{
	flag = trigger get_trigger_flag();

	if ( !isdefined( level.flag[ flag ] ) )
	{
		flag_init( flag );
	}

	for ( ;; )
	{
		trigger waittill( "trigger", other );
		trigger script_delay();
		flag_set( flag, other );
	}
}

flag_set_trigger_specialops( trigger )
{
	flag = trigger get_trigger_flag();

	if ( !isdefined( level.flag[ flag ] ) )
	{
		flag_init( flag );
	}

	trigger.player_touched_arr = level.players;
	trigger thread flag_set_trigger_specialops_clear( flag );

	for ( ;; )
	{
		trigger waittill( "trigger", other );

		trigger.player_touched_arr = array_remove( trigger.player_touched_arr, other );
		if ( trigger.player_touched_arr.size )
			continue;

		trigger script_delay();
		flag_set( flag, other );
	}
}

flag_set_trigger_specialops_clear( flag )
{
	// sets self.player_touched_arr when the flag is set or cleared from script.
	while ( true )
	{
		level waittill( flag );
		if ( flag( flag ) )
		{
			self.player_touched_arr = [];
		}
		else
		{
			self.player_touched_arr = level.players;
		}
	}
}

trigger_damage_player_flag_set( trigger )
{
	flag = trigger get_trigger_flag();

	if ( !isdefined( level.flag[ flag ] ) )
	{
		flag_init( flag );
	}

	for ( ;; )
	{
		trigger waittill( "trigger", other );
		if ( !isalive( other ) )
			continue;
		if ( !isplayer( other ) )
			continue;
		trigger script_delay();
		flag_set( flag, other );
	}
}

flag_set_coop_trigger( trigger )
{
	AssertEx( is_coop(), "flag_set_coop_trigger() was called but co-op is not enabled." );
	flag = trigger get_trigger_flag();

	if ( !isdefined( level.flag[ flag ] ) )
	{
		flag_init( flag );
	}

	agents = [];

	for ( ;; )
	{
		trigger waittill( "trigger", user );

		if ( !isplayer( user ) )
			continue;

		add = [];
		add[ add.size ] = user;

		agents = array_merge( agents, add );

		if ( agents.size == level.players.size )
			break;
	}

	trigger script_delay();
	flag_set( flag );
}

flag_unset_trigger( trigger )
{
	flag = trigger get_trigger_flag();

	if ( !isdefined( level.flag[ flag ] ) )
		flag_init( flag );
	for ( ;; )
	{
		trigger waittill( "trigger" );
		trigger script_delay();
		flag_clear( flag );
	}
}

eq_trigger( trigger )
{
	level.set_eq_func[ true ] = ::set_eq_on;
	level.set_eq_func[ false ] = ::set_eq_off;
	targ = GetEnt( trigger.target, "targetname" );
	for ( ;; )
	{
		trigger waittill( "trigger" );
		ai = GetAIArray( "allies" );
		for ( i = 0; i < ai.size; i++ )
		{
			ai[ i ] [[ level.set_eq_func[ ai[ i ] IsTouching( targ ) ] ]]();
		}
		while ( level.player IsTouching( trigger ) )
			wait( 0.05 );

		ai = GetAIArray( "allies" );
		for ( i = 0; i < ai.size; i++ )
		{
			ai[ i ] [[ level.set_eq_func[ false ] ]]();
		}
	}
	 /*
	num = level.eq_trigger_num;
	trigger.eq_num = num;
	level.eq_trigger_num ++ ;
	waittillframeend;// let the ai get their eq_num table created
	waittillframeend;// let the ai get their eq_num table created
	level.eq_trigger_table[ num ] = [];
	if ( IsDefined( trigger.script_linkTo ) )
	{
		tokens = StrTok( trigger.script_linkto, " " );
		for ( i = 0; i < tokens.size; i ++ )
		{
			target_trigger = GetEnt( tokens[ i ], "script_linkname" );
			// add the trigger num to the list of triggers this trigger hears
			level.eq_trigger_table[ num ][ level.eq_trigger_table[ num ].size ] = target_trigger.eq_num;
		}
	}

	for ( ;; )
	{
		trigger waittill( "trigger", other );

		// are we already registered with this trigger?
		if ( other.eq_table[ num ] )
			continue;

		other thread [[ level.touched_eq_function[ other.is_the_player ] ]]( num, trigger );
	}
	 */
}


player_ignores_triggers()
{
	self endon( "death" );
	self.ignoretriggers = true;
	wait( 1 );
	self.ignoretriggers = false;
}

get_trigger_eq_nums( num )
{
	// tally up the triggers this trigger hears into, including itself
	nums = [];
	nums[ 0 ] = num;
	for ( i = 0; i < level.eq_trigger_table[ num ].size; i++ )
	{
		nums[ nums.size ] = level.eq_trigger_table[ num ][ i ];
	}
	return nums;
}


player_touched_eq_trigger( num, trigger )
{
	self endon( "death" );

	nums = get_trigger_eq_nums( num );
	for ( r = 0; r < nums.size; r++ )
	{
		self.eq_table[ nums[ r ] ] = true;
		self.eq_touching[ nums[ r ] ] = true;
	}

	thread player_ignores_triggers();

	ai = GetAIArray();
	for ( i = 0; i < ai.size; i++ )
	{
		guy = ai[ i ];
		// is the ai in this trigger with us?
		for ( r = 0; r < nums.size; r++ )
		{
			if ( guy.eq_table[ nums[ r ] ] )
			{
				guy EQOff();
				break;
			}
		}
	}

	while ( self IsTouching( trigger ) )
		wait( 0.05 );

	for ( r = 0; r < nums.size; r++ )
	{
		self.eq_table[ nums[ r ] ] = false;
		self.eq_touching[ nums[ r ] ] = undefined;
	}

	ai = GetAIArray();
	for ( i = 0; i < ai.size; i++ )
	{
		guy = ai[ i ];

		was_in_our_trigger = false;
		// is the ai in the trigger we just left?
		for ( r = 0; r < nums.size; r++ )
		{
			// was the guy in a trigger we could hear into?
			if ( guy.eq_table[ nums[ r ] ] )
			{
				was_in_our_trigger = true;
			}
		}

		if ( !was_in_our_trigger )
			continue;

		// check to see if the guy is in any of the triggers we're still in

		touching = GetArrayKeys( self.eq_touching );
		shares_trigger = false;
		for ( p = 0; p < touching.size; p++ )
		{
			if ( !guy.eq_table[ touching[ p ] ] )
				continue;

			shares_trigger = true;
			break;
		}

		// if he's not in a trigger with us, turn his eq back on
		if ( !shares_trigger )
			guy EQOn();
	}
}

ai_touched_eq_trigger( num, trigger )
{
	self endon( "death" );

	nums = get_trigger_eq_nums( num );
	for ( r = 0; r < nums.size; r++ )
	{
		self.eq_table[ nums[ r ] ] = true;
		self.eq_touching[ nums[ r ] ] = true;
	}

	// are we in the same trigger as the player?
	for ( r = 0; r < nums.size; r++ )
	{
		if ( level.player.eq_table[ nums[ r ] ] )
		{
			self EQOff();
			break;
		}
	}

	// so other AI can touch the trigger
	self.ignoretriggers = true;
	wait( 1 );
	self.ignoretriggers = false;
	while ( self IsTouching( trigger ) )
		wait( 0.5 );

	nums = get_trigger_eq_nums( num );
	for ( r = 0; r < nums.size; r++ )
	{
		self.eq_table[ nums[ r ] ] = false;
		self.eq_touching[ nums[ r ] ] = undefined;
	}

	touching = GetArrayKeys( self.eq_touching );
	for ( i = 0; i < touching.size; i++ )
	{
		// is the player in a trigger that we're still in?
		if ( level.player.eq_table[ touching[ i ] ] )
		{
			// then don't turn eq back on
			return;
		}
	}

	self EQOn();
}

ai_eq()
{
	level.set_eq_func[ false ] = ::set_eq_on;
	level.set_eq_func[ true ] = ::set_eq_off;
	index = 0;
	for ( ;; )
	{
		while ( !level.ai_array.size )
		{
			wait( 0.05 );
		}
		waittillframeend;
		waittillframeend;
		keys = GetArrayKeys( level.ai_array );
		index++;
		if ( index >= keys.size )
			index = 0;
		guy = level.ai_array[ keys[ index ] ];
		guy [[ level.set_eq_func[ SightTracePassed( level.player GetEye(), guy GetEye(), false, undefined ) ] ]]();
		wait( 0.05 );
	}
}

set_eq_on()
{
	self EQOn();
}

set_eq_off()
{
	self EQOff();
}

add_tokens_to_trigger_flags( tokens )
{
	for ( i = 0; i < tokens.size; i++ )
	{
		flag = tokens[ i ];
		if ( !isdefined( level.trigger_flags[ flag ] ) )
		{
			level.trigger_flags[ flag ] = [];
		}

		level.trigger_flags[ flag ][ level.trigger_flags[ flag ].size ] = self;
	}
}

script_flag_false_trigger( trigger )
{
	// all of these flags must be false for the trigger to be enabled
	tokens = create_flags_and_return_tokens( trigger.script_flag_false );
	trigger add_tokens_to_trigger_flags( tokens );
	trigger update_trigger_based_on_flags();
}

script_flag_true_trigger( trigger )
{
	// all of these flags must be false for the trigger to be enabled
	tokens = create_flags_and_return_tokens( trigger.script_flag_true );
	trigger add_tokens_to_trigger_flags( tokens );
	trigger update_trigger_based_on_flags();
}

/*
	for( ;; )
	{
		trigger trigger_on();
		wait_for_flag( tokens );

		trigger trigger_off();
		wait_for_flag( tokens );
		for ( i = 0; i < tokens.size; i ++ )
		{
			flag_wait( tokens[ i ] );
		}
	}
	 */


 /*
script_flag_true_trigger( trigger )
{
	// any of these flags have to be true for the trigger to be enabled
	tokens = create_flags_and_return_tokens( trigger.script_flag_true );

	for ( ;; )
	{
		trigger trigger_off();
		wait_for_flag( tokens );
		trigger trigger_on();
		for ( i = 0; i < tokens.size; i ++ )
		{
			flag_waitopen( tokens[ i ] );
		}
	}
}
 */

wait_for_flag( tokens )
{
	for ( i = 0; i < tokens.size; i++ )
	{
		level endon( tokens[ i ] );
	}
	level waittill( "foreverrr" );
}

trigger_multiple_physics( trigger )
{
	AssertEx( IsDefined( trigger.target ), "Trigger_multiple_physics at " + trigger.origin + " has no target for physics." );

	ents = [];

	structs = getstructarray( trigger.target, "targetname" );
	orgs = GetEntArray( trigger.target, "targetname" );

	foreach ( org in orgs )
	{
		// save ents by moving script origins to structs
		struct = SpawnStruct();
		struct.origin = org.origin;
		struct.script_parameters = org.script_parameters;
		struct.script_damage = org.script_damage;
		struct.radius = org.radius;
		structs[ structs.size ] = struct;
		org Delete();
	}

	AssertEx( structs.size, "Trigger_multiple_physics at " + trigger.origin + " has no target for physics." );

	trigger.org = structs[ 0 ].origin;
	trigger waittill( "trigger" );
	trigger script_delay();

	foreach ( struct in structs )
	{
		radius = struct.radius;
		vel = struct.script_parameters;
		damage = struct.script_damage;

		if ( !isdefined( radius ) )
			radius = 350;
		if ( !isdefined( vel ) )
			vel = 0.25;

		// convert string to float
		SetDvar( "tempdvar", vel );
		vel = GetDvarFloat( "tempdvar" );

		if ( IsDefined( damage ) )
		{
			RadiusDamage( struct.origin, radius, damage, damage * 0.5 );
		}
		PhysicsExplosionSphere( struct.origin, radius, radius * 0.5, vel );
	}
}

trigger_multiple_friendly_stop_respawn( trigger )
{
	for ( ;; )
	{
		trigger waittill( "trigger" );
		flag_clear( "respawn_friendlies" );
	}
}

trigger_multiple_friendly_respawn( trigger )
{
	org = GetEnt( trigger.target, "targetname" );
	origin = undefined;
	if ( IsDefined( org ) )
	{
		origin = org.origin;
		org Delete();

	}
	else
	{
		org = getstruct( trigger.target, "targetname" );
		AssertEx( IsDefined( org ), "trigger_multiple_friendly_respawn doesn't target an origin." );
		origin = org.origin;
	}

	for ( ;; )
	{
		trigger waittill( "trigger" );
		level.respawn_spawner_org = origin;
		flag_set( "respawn_friendlies" );
		wait( 0.5 );
	}
}

friendly_respawn_clear( trigger )
{
	for ( ;; )
	{
		trigger waittill( "trigger" );
		flag_clear( "respawn_friendlies" );
		wait( 0.5 );
	}
}

trigger_multiple_do_radius_damage( trigger )
{
	trigger waittill( "trigger" );
	trigger do_radius_damage_from_target();
}

do_radius_damage_from_target()
{
	radius = 80;
	if ( IsDefined( self.radius ) )
		radius = self.radius;

	targs = self get_all_target_ents();
	foreach ( targ in targs )
	{
		RadiusDamage( targ.origin, radius, 5000, 5000 );
	}
	self Delete();
}

trigger_damage_do_radius_damage( trigger )
{
	for ( ;; )
	{
		trigger waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName );
		if ( !isalive( attacker ) )
			continue;
//		if ( attacker != level.player )
//			continue;
		if ( Distance( attacker.origin, trigger.origin ) > 940 )
			continue;
		break;
	}

	trigger do_radius_damage_from_target();
}

radio_trigger( trigger )
{
	trigger waittill( "trigger" );
	radio_dialogue( trigger.script_noteworthy );
}

background_block()
{
		Assert( IsDefined( self.script_bg_offset ) );
		self.origin -= self.script_bg_offset;
}

trigger_ignore( trigger )
{
	thread trigger_runs_function_on_touch( trigger, ::set_ignoreme, ::get_ignoreme );
}

trigger_pacifist( trigger )
{
	thread trigger_runs_function_on_touch( trigger, ::set_pacifist, ::get_pacifist );
}

trigger_runs_function_on_touch( trigger, set_func, get_func )
{
	for ( ;; )
	{
		trigger waittill( "trigger", other );
		if ( !isalive( other ) )
			continue;
		if ( other [[ get_func ]]() )
			continue;
		other thread touched_trigger_runs_func( trigger, set_func );
	}
}

touched_trigger_runs_func( trigger, set_func )
{
	self endon( "death" );
	self.ignoreme = true;
	[[ set_func ]]( true );
	// so others can touch the trigger
	self.ignoretriggers = true;
	wait( 1 );
	self.ignoretriggers = false;

	while ( self IsTouching( trigger ) )
	{
		wait( 1 );
	}

	[[ set_func ]]( false );
}

trigger_turns_off( trigger )
{
	trigger waittill( "trigger" );
	trigger trigger_off();

	if ( !isdefined( trigger.script_linkTo ) )
		return;

	// also turn off all triggers this trigger links to
	tokens = StrTok( trigger.script_linkto, " " );
	for ( i = 0; i < tokens.size; i++ )
		array_thread( GetEntArray( tokens[ i ], "script_linkname" ), ::trigger_off );
}


set_player_viewhand_model( viewhandModel )
{
	Assert( !isdefined( level.player_viewhand_model ) );	// only set this once per level
	AssertEx( IsSubStr( viewhandModel, "player" ), "Must set with viewhands_player_*" );
	level.player_viewhand_model = viewhandModel;
	PreCacheModel( level.player_viewhand_model );
}

trigger_hint( trigger )
{
	AssertEx( IsDefined( trigger.script_hint ), "Trigger_hint at " + trigger.origin + " has no .script_hint" );

	if ( !isdefined( level.displayed_hints ) )
	{
		level.displayed_hints = [];
	}
	// give level script a chance to set the hint string and optional boolean functions on this hint
	waittillframeend;

	hint = trigger.script_hint;
	AssertEx( IsDefined( level.trigger_hint_string[ hint ] ), "Trigger_hint with hint " + hint + " had no hint string assigned to it. Define hint strings with add_hint_string()" );
	trigger waittill( "trigger", other );

	AssertEx( IsPlayer( other ), "Tried to do a trigger_hint on a non player entity" );

	if ( IsDefined( level.displayed_hints[ hint ] ) )
		return;
	level.displayed_hints[ hint ] = true;

	other display_hint( hint );
}

stun_test()
{

	if ( GetDvar( "stuntime" ) == "" )
		SetDvar( "stuntime", "1" );
	level.player.AllowAds = true;


	for ( ;; )
	{
		self waittill( "damage" );
		if ( GetDvarInt( "stuntime" ) == 0 )
			continue;

		thread stun_player( self PlayerAds() );
	}
}

stun_player( ADS_fraction )
{
	self notify( "stun_player" );
	self endon( "stun_player" );

	if ( ADS_fraction > .3 )
	{
		if ( level.player.AllowAds == true )
			level.player PlaySound( "player_hit_while_ads" );

		level.player.AllowAds = false;
		level.player AllowAds( false );
	}
	level.player SetSpreadOverride( 20 );

	wait( GetDvarInt( "stuntime" ) );

	level.player AllowAds( true );
	level.player.AllowAds = true;
	level.player ResetSpreadOverride();
}

throw_grenade_at_player_trigger( trigger )
{
	trigger endon( "death" );

	trigger waittill( "trigger" );

	ThrowGrenadeAtPlayerASAP();
}

flag_on_cleared( trigger )
{
	flag = trigger get_trigger_flag();

	if ( !isdefined( level.flag[ flag ] ) )
	{
		flag_init( flag );
	}

	for ( ;; )
	{
		trigger waittill( "trigger" );
		wait( 1 );
		if ( trigger found_toucher() )
		{
			continue;
		}

		break;
	}

	flag_set( flag );
}

found_toucher()
{
	ai = GetAIArray( "bad_guys" );
	for ( i = 0; i < ai.size; i++ )
	{
		guy = ai[ i ];
		if ( !isalive( guy ) )
		{
			continue;
		}

		if ( guy IsTouching( self ) )
		{
			return true;
		}

		// spread the touches out over time
		wait( 0.1 );
	}

	// couldnt find any touchers so do a single frame complete check just to make sure

	ai = GetAIArray( "bad_guys" );
	for ( i = 0; i < ai.size; i++ )
	{
		guy = ai[ i ];
		if ( guy IsTouching( self ) )
		{
			return true;
		}
	}

	return false;
}

trigger_delete_on_touch( trigger )
{
	for ( ;; )
	{
		trigger waittill( "trigger", other );
		if ( IsDefined( other ) )
		{
			// might've been removed before we got it
			other Delete();
		}
	}
}


flag_set_touching( trigger )
{
	flag = trigger get_trigger_flag();

	if ( !isdefined( level.flag[ flag ] ) )
	{
		flag_init( flag );
	}

	for ( ;; )
	{
		trigger waittill( "trigger", other );
		trigger script_delay();
		if ( IsAlive( other ) && other IsTouching( trigger ) && IsDefined( trigger ) )
			flag_set( flag );
		while ( IsAlive( other ) && other IsTouching( trigger ) && IsDefined( trigger ) )
		{
			wait( 0.25 );
		}
		flag_clear( flag );
	}
}

 /*
rpg_aim_assist()
{
	level.player endon( "death" );
	for ( ;; )
	{
		level.player waittill( "weapon_fired" );
		currentweapon = level.player GetCurrentWeapon();
		if ( ( currentweapon == "rpg" ) || ( currentweapon == "rpg_player" ) )
			thread rpg_aim_assist_attractor();
	}
}

rpg_aim_assist_attractor()
{
	prof_begin( "rpg_aim_assist" );

	// Trace to where the player is looking
	start = level.player GetEye();
	direction = level.player GetPlayerAngles();
	coord = BulletTrace( start, start + vector_multiply( AnglesToForward( direction ), 15000 ), true, level.player )[ "position" ];

	thread draw_line_for_time( level.player.origin, coord, 1, 0, 0, 10000 );

	prof_end( "rpg_aim_assist" );

	attractor = Missile_CreateAttractorOrigin( coord, 10000, 3000 );
	wait 3.0;
	Missile_DeleteAttractor( attractor );
}
*/

SetObjectiveTextColors()
{
	// The darker the base color, the more-readable the text is against a stark-white backdrop.
	// However; this sacrifices the "white-hot"ness of the text against darker backdrops.

	MY_TEXTBRIGHTNESS_DEFAULT = "1.0 1.0 1.0";
	MY_TEXTBRIGHTNESS_90 = "0.9 0.9 0.9";
	MY_TEXTBRIGHTNESS_85 = "0.85 0.85 0.85";

	if ( level.script == "armada" )
	{
		SetSavedDvar( "con_typewriterColorBase", MY_TEXTBRIGHTNESS_90 );
		return;
	}

	SetSavedDvar( "con_typewriterColorBase", MY_TEXTBRIGHTNESS_DEFAULT );
}

ammo_pickup( sWeaponType )
{
	// possible weapons that the player could have that get this type of ammo
	validWeapons = [];
	if ( sWeaponType == "grenade_launcher" )
	{
		validWeapons[ validWeapons.size ] = "m203_m4";
		validWeapons[ validWeapons.size ] = "m203_m4_acog";
		validWeapons[ validWeapons.size ] = "m203_m4_eotech";
		validWeapons[ validWeapons.size ] = "m203_m4_motion_tracker";
		validWeapons[ validWeapons.size ] = "m203_m4_reflex";
		validWeapons[ validWeapons.size ] = "m203_m4_silencer";
		validWeapons[ validWeapons.size ] = "m203_m4_silencer_reflex";
		validWeapons[ validWeapons.size ] = "m203";
		validWeapons[ validWeapons.size ] = "gp25";
		validWeapons[ validWeapons.size ] = "m4m203_silencer_reflex";
		validWeapons[ validWeapons.size ] = "m203_m4_silencer_reflex";
	}
	else if ( sWeaponType == "rpg" )
	{
		validWeapons[ validWeapons.size ] = "rpg";
		validWeapons[ validWeapons.size ] = "rpg_player";
		validWeapons[ validWeapons.size ] = "rpg_straight";
	}
	else if ( sWeaponType == "c4" )
	{
		validWeapons[ validWeapons.size ] = "c4";
	}
	else if ( sWeaponType == "claymore" )
	{
		validWeapons[ validWeapons.size ] = "claymore";
	}
	else if ( sWeaponType == "556" )
	{
		validWeapons[ validWeapons.size ] = "m4_grenadier";
		validWeapons[ validWeapons.size ] = "m4_grunt";
		validWeapons[ validWeapons.size ] = "m4_sd_cloth";
		validWeapons[ validWeapons.size ] = "m4_shotgun";
		validWeapons[ validWeapons.size ] = "m4_silencer";
		validWeapons[ validWeapons.size ] = "m4_silencer_acog";
		validWeapons[ validWeapons.size ] = "m4m203_acog";
		validWeapons[ validWeapons.size ] = "m4m203_eotech";
		validWeapons[ validWeapons.size ] = "m4m203_motion_tracker";
		validWeapons[ validWeapons.size ] = "m4m203_reflex";
		validWeapons[ validWeapons.size ] = "m4m203_reflex_arctic";
		validWeapons[ validWeapons.size ] = "m4m203_silencer";
		validWeapons[ validWeapons.size ] = "m4m203_silencer_reflex";
		validWeapons[ validWeapons.size ] = "m4m203_silencer";
	}
	else if ( sWeaponType == "762" )
	{
		validWeapons[ validWeapons.size ] = "ak47";
		validWeapons[ validWeapons.size ] = "ak47_acog";
		validWeapons[ validWeapons.size ] = "ak47_eotech";
		validWeapons[ validWeapons.size ] = "ak47_grenadier";
		validWeapons[ validWeapons.size ] = "ak47_reflex";
		validWeapons[ validWeapons.size ] = "ak47_shotgun";
		validWeapons[ validWeapons.size ] = "ak47_silencer";
		validWeapons[ validWeapons.size ] = "ak47_thermal";

		validWeapons[ validWeapons.size ] = "ak47_desert";
		validWeapons[ validWeapons.size ] = "ak47_desert_acog";
		validWeapons[ validWeapons.size ] = "ak47_desert_eotech";
		validWeapons[ validWeapons.size ] = "ak47_desert_grenadier";
		validWeapons[ validWeapons.size ] = "ak47_desert_reflex";

		validWeapons[ validWeapons.size ] = "ak47_digital";
		validWeapons[ validWeapons.size ] = "ak47_digital_acog";
		validWeapons[ validWeapons.size ] = "ak47_digital_eotech";
		validWeapons[ validWeapons.size ] = "ak47_digital_grenadier";
		validWeapons[ validWeapons.size ] = "ak47_digital_reflex";

		validWeapons[ validWeapons.size ] = "ak47_fall";
		validWeapons[ validWeapons.size ] = "ak47_fall_acog";
		validWeapons[ validWeapons.size ] = "ak47_fall_eotech";
		validWeapons[ validWeapons.size ] = "ak47_fall_grenadier";
		validWeapons[ validWeapons.size ] = "ak47_fall_reflex";

		validWeapons[ validWeapons.size ] = "ak47_woodland";
		validWeapons[ validWeapons.size ] = "ak47_woodland_acog";
		validWeapons[ validWeapons.size ] = "ak47_woodland_eotech";
		validWeapons[ validWeapons.size ] = "ak47_woodland_grenadier";
		validWeapons[ validWeapons.size ] = "ak47_woodland_reflex";
	}
	else if ( sWeaponType == "45" )
	{
		validWeapons[ validWeapons.size ] = "ump45";
		validWeapons[ validWeapons.size ] = "ump45_acog";
		validWeapons[ validWeapons.size ] = "ump45_eotech";
		validWeapons[ validWeapons.size ] = "ump45_reflex";
		validWeapons[ validWeapons.size ] = "ump45_silencer";

		validWeapons[ validWeapons.size ] = "ump45_arctic";
		validWeapons[ validWeapons.size ] = "ump45_arctic_acog";
		validWeapons[ validWeapons.size ] = "ump45_arctic_eotech";
		validWeapons[ validWeapons.size ] = "ump45_arctic_reflex";

		validWeapons[ validWeapons.size ] = "ump45_digital";
		validWeapons[ validWeapons.size ] = "ump45_digital_acog";
		validWeapons[ validWeapons.size ] = "ump45_digital_eotech";
		validWeapons[ validWeapons.size ] = "ump45_digital_reflex";
	}
	else if ( sWeaponType == "pistol" )
	{
		validWeapons[ validWeapons.size ] = "beretta";
		validWeapons[ validWeapons.size ] = "beretta393";
		validWeapons[ validWeapons.size ] = "usp";
		validWeapons[ validWeapons.size ] = "usp_scripted";
		validWeapons[ validWeapons.size ] = "usp_silencer";
		validWeapons[ validWeapons.size ] = "glock";
	}

	Assert( validWeapons.size > 0 );

	trig = Spawn( "trigger_radius", self.origin, 0, 25, 32 );

	for ( ;; )
	{
		flag_wait( "allow_ammo_pickups" );

		trig waittill( "trigger", triggerer );

		if ( !flag( "allow_ammo_pickups" ) )
			continue;

		if ( !isdefined( triggerer ) )
			continue;

		if ( !isplayer( triggerer ) )
			continue;

		// check if the player is carrying one of the valid grenade launcher weapons
		weaponToGetAmmo = undefined;
		emptyActionSlotAmmo = undefined;
		weapons = triggerer GetWeaponsListAll();
		for ( i = 0; i < weapons.size; i++ )
		{
			for ( j = 0; j < validWeapons.size; j++ )
			{
				if ( weapons[ i ] == validWeapons[ j ]	 )
					weaponToGetAmmo = weapons[ i ];
			}
		}

		//check if weapon if C4 or claymore and the player has zero of them
		if ( ( !isdefined( weaponToGetAmmo ) ) && ( sWeaponType == "claymore" ) )
		{
			emptyActionSlotAmmo = true;
			weaponToGetAmmo = "claymore";
			break;
		}


		//check if weapon if C4 or claymore and the player has zero of them
		if ( ( !isdefined( weaponToGetAmmo ) ) && ( sWeaponType == "c4" ) )
		{
			emptyActionSlotAmmo = true;
			weaponToGetAmmo = "c4";
			break;
		}

		// no grenade launcher found
		if ( !isdefined( weaponToGetAmmo ) )
			continue;

		// grenade launcher found - check if the player has max ammo already
		if ( triggerer GetFractionMaxAmmo( weaponToGetAmmo ) >= 1 )
			continue;

		// player picks up the ammo
		break;
	}

	// give player one more ammo, play pickup sound, and delete the ammo and trigger
	if ( IsDefined( emptyActionSlotAmmo ) )
		triggerer GiveWeapon( weaponToGetAmmo );	// this will only be for C4 and claymores if the player is totally out of them
	else
	{
		rounds = 1;
		if ( sWeaponType == "556" || sWeaponType == "762" )
		{
			rounds = 30;
		}
		else if ( sWeaponType == "45" )
		{
			rounds = 25;
		}
		else if ( sWeaponType == "pistol" )
		{
			rounds = 15;
		}
		triggerer SetWeaponAmmoStock( weaponToGetAmmo, triggerer GetWeaponAmmoStock( weaponToGetAmmo ) + rounds );
	}

	triggerer PlayLocalSound( "grenade_pickup" );
	trig Delete();

	// usable items might not exist anymore at this point since they are deleted in code on player touch
	if ( IsDefined( self ) )
	{
		self Delete();
	}
}

get_script_linkto_targets()
{
	targets = [];
	if ( !isdefined( self.script_linkTo ) )
		return targets;

	tokens = StrTok( self.script_linkto, " " );
	for ( i = 0; i < tokens.size; i++ )
	{
		token = tokens[ i ];
		target = GetEnt( token, "script_linkname" );
		if ( IsDefined( target ) )
			targets[ targets.size ] = target;
	}
	return targets;
}

delete_link_chain( trigger )
{
	// deletes all entities that it script_linkto's, and all entities that entity script linktos, etc.
	trigger waittill( "trigger" );

	targets = trigger get_script_linkto_targets();
	array_thread( targets, ::delete_links_then_self );
}

delete_links_then_self()
{
	targets = get_script_linkto_targets();
	array_thread( targets, ::delete_links_then_self );
	self Delete();
}

/*
	A depth trigger that sets fog
*/
trigger_fog( trigger )
{
	waittillframeend;

	start_fog 	 = trigger.script_fogset_start;
	end_fog 	 = trigger.script_fogset_end;

	AssertEx( IsDefined( start_fog ), "Fog trigger is missing .script_fogset_start" );
	AssertEx( IsDefined( end_fog ), "Fog trigger is missing .script_fogset_end" );

	trigger.sunfog_enabled = false;

	if ( IsDefined( start_fog ) && IsDefined( end_fog ) )
	{
		start_fog_ent = get_fog( start_fog );
		end_fog_ent = get_fog( end_fog );

		AssertEx( IsDefined( start_fog_ent ), "Fog set " + start_fog + " does not exist, please use create_fog() in level_fog.gsc." );
		AssertEx( IsDefined( end_fog_ent ), "Fog set " + end_fog + " does not exist, please use create_fog() in level_fog.gsc." );

		trigger.start_neardist 			 = start_fog_ent.startDist;
		trigger.start_fardist 			 = start_fog_ent.halfwayDist;
		trigger.start_color 			 = ( start_fog_ent.red, start_fog_ent.green, start_fog_ent.blue );
		trigger.start_opacity 			 = start_fog_ent.maxOpacity;
		trigger.sunfog_enabled 			 = ( IsDefined( start_fog_ent.sunred ) ||  IsDefined( end_fog_ent.sunred ) );

		if ( IsDefined( start_fog_ent.sunred ) )
		{
			Assert( IsDefined( start_fog_ent.sungreen ) );
			Assert( IsDefined( start_fog_ent.sunblue ) );
			Assert( IsDefined( start_fog_ent.sundir ) );
			Assert( IsDefined( start_fog_ent.sunBeginFadeAngle ) );
			Assert( IsDefined( start_fog_ent.sunEndFadeAngle ) );
			Assert( IsDefined( start_fog_ent.normalFogScale ) );

			trigger.start_suncolor			 = ( start_fog_ent.sunred, start_fog_ent.sungreen, start_fog_ent.sunblue );
			trigger.start_sundir			 = start_fog_ent.sundir;
			trigger.start_sunBeginFadeAngle = start_fog_ent.sunBeginFadeAngle;
			trigger.start_sunEndFadeAngle 	 = start_fog_ent.sunEndFadeAngle;
			trigger.start_sunFogScale 		 = start_fog_ent.normalFogScale;
		}
		else
		{
			if ( trigger.sunfog_enabled )
			{
				trigger.start_suncolor			 = trigger.start_color;
				trigger.start_sundir			 = ( 0, 0, 0 );
				trigger.start_sunBeginFadeAngle = 0;
				trigger.start_sunEndFadeAngle 	 = 90;
				trigger.start_sunFogScale 		 = 1;
			}
		}

		trigger.end_neardist 			 = end_fog_ent.startDist;
		trigger.end_fardist 			 = end_fog_ent.halfwayDist;
		trigger.end_color 				 = ( start_fog_ent.red, start_fog_ent.green, start_fog_ent.blue );
		trigger.end_opacity 			 = end_fog_ent.maxOpacity;

		if ( IsDefined( end_fog_ent.sunred ) )
		{
			Assert( IsDefined( end_fog_ent.sungreen ) );
			Assert( IsDefined( end_fog_ent.sunblue ) );
			Assert( IsDefined( end_fog_ent.sundir ) );
			Assert( IsDefined( end_fog_ent.sunBeginFadeAngle ) );
			Assert( IsDefined( end_fog_ent.sunEndFadeAngle ) );
			Assert( IsDefined( end_fog_ent.normalFogScale ) );

			trigger.end_suncolor			 = ( end_fog_ent.sunred, end_fog_ent.sungreen, end_fog_ent.sunblue );
			trigger.end_sundir				 = end_fog_ent.sundir;
			trigger.end_sunBeginFadeAngle 	 = end_fog_ent.sunBeginFadeAngle;
			trigger.end_sunEndFadeAngle 	 = end_fog_ent.sunEndFadeAngle;
			trigger.end_sunFogScale 		 = end_fog_ent.normalFogScale;
		}
		else
		{
			if ( trigger.sunfog_enabled )
			{
				trigger.end_suncolor			 = trigger.end_color;
				trigger.end_sundir				 = ( 0, 0, 0 );
				trigger.end_sunBeginFadeAngle 	 = 0;
				trigger.end_sunEndFadeAngle 	 = 90;
				trigger.end_sunFogScale 		 = 1;
			}
		}
	}

	AssertEx( IsDefined( trigger.start_neardist ), "trigger_fog lacks start_neardist" );
	AssertEx( IsDefined( trigger.start_fardist ), "trigger_fog lacks start_fardist" );
	AssertEx( IsDefined( trigger.start_color ), "trigger_fog lacks start_color" );

	AssertEx( IsDefined( trigger.end_color ), "trigger_fog lacks end_color" );
	AssertEx( IsDefined( trigger.end_neardist ), "trigger_fog lacks end_neardist" );
	AssertEx( IsDefined( trigger.end_fardist ), "trigger_fog lacks end_fardist" );

	AssertEx( IsDefined( trigger.target ), "trigger_fog doesnt target an origin to set the start plane" );
	ent = GetEnt( trigger.target, "targetname" );
	AssertEx( IsDefined( ent ), "trigger_fog doesnt target an origin to set the start plane" );

	start = ent.origin;
	end = undefined;

	if ( IsDefined( ent.target ) )
	{
		// if the origin targets a second origin, use it as the end point
		target_ent = GetEnt( ent.target, "targetname" );
		end = target_ent.origin;
	}
	else
	{
		// otherwise double the difference between the target origin and start to get the endpoint
		end = start + vector_multiply( trigger.origin - start, 2 );
	}

//	thread linedraw( start, end, (1,0.5,1) );
//	thread print3ddraw( start, "start", (1,0.5,1) );
//	thread print3ddraw( end, "end", (1,0.5,1) );
	dist = Distance( start, end );

	for ( ;; )
	{
		trigger waittill( "trigger", other );
		AssertEx( IsPlayer( other ), "Non - player entity touched a trigger_fog." );

		progress = 0;
		while ( other IsTouching( trigger ) )
		{
			progress = maps\_ambient::get_progress( start, end, dist, other.origin );
//			PrintLn( "progress " + progress );

			if ( progress < 0 )
				progress = 0;

			if ( progress > 1 )
				progress = 1;

			trigger set_fog_progress( progress );
			wait( 0.05 );
		}

		// when you leave the trigger set it to whichever point it was closest too
		if ( progress > 0.5 )
			progress = 1;
		else
			progress = 0;

		trigger set_fog_progress( progress );
	}
}

set_fog_progress( progress )
{
	anti_progress 	 = 1 - progress;
	startdist 		 = self.start_neardist * anti_progress + self.end_neardist * progress;
	halfwayDist 	 = self.start_fardist * anti_progress + self.end_fardist * progress;
	color 			 = self.start_color * anti_progress + self.end_color * progress;
	start_opacity 	 = self.start_opacity;
	end_opacity 	 = self.end_opacity;

	if ( !isdefined( start_opacity ) )
		start_opacity = 1;

	if ( !isdefined( end_opacity ) )
		end_opacity = 1;

	opacity = start_opacity * anti_progress + end_opacity * progress;

	if ( self.sunfog_enabled )
	{
		sun_color		 = self.start_suncolor * anti_progress + self.end_suncolor * progress;
		sun_dir			 = self.start_sundir * anti_progress + self.end_sundir * progress;
		begin_angle		 = self.start_sunBeginFadeAngle * anti_progress + self.end_sunBeginFadeAngle * progress;
		end_angle		 = self.start_sunEndFadeAngle * anti_progress + self.end_sunEndFadeAngle * progress;
		sun_fog_scale	 = self.start_sunFogScale * anti_progress + self.end_sunFogScale * progress;

		SetExpFog(
			startdist,
			halfwaydist,
			color[ 0 ],
			color[ 1 ],
			color[ 2 ],
			opacity,
			0.4,
			sun_color[ 0 ],
			sun_color[ 1 ],
			sun_color[ 2 ],
			sun_dir,
			begin_angle,
			end_angle,
			sun_fog_scale
		 );
	}
	else
	{
		SetExpFog(
			startdist,
			halfwaydist,
			color[ 0 ],
			color[ 1 ],
			color[ 2 ],
			opacity,
			0.4
		 );
	}
}

remove_level_first_frame()
{
	wait( 0.05 );
	level.first_frame = -1;
}

no_crouch_or_prone_think( trigger )
{
	array_thread( level.players, ::no_crouch_or_prone_think_for_player, trigger );
}

no_crouch_or_prone_think_for_player( trigger )
{
	assert( isplayer( self ) );
	for ( ;; )
	{
		trigger waittill( "trigger", player );
		
		if ( !isdefined( player ) )
			continue;
		
		if ( player != self )
			continue;
		
		while ( player IsTouching( trigger ) )
		{
			player AllowProne( false );
			player AllowCrouch( false );
			wait( 0.05 );
		}
		player AllowProne( true );
		player AllowCrouch( true );
	}
}

no_prone_think( trigger )
{
	array_thread( level.players, ::no_prone_think_for_player, trigger );
}

no_prone_think_for_player( trigger )
{
	assert( isplayer( self ) );
	for ( ;; )
	{
		trigger waittill( "trigger", player );
		
		if ( !isdefined( player ) )
			continue;
		
		if ( player != self )
			continue;
		
		while ( player IsTouching( trigger ) )
		{
			player AllowProne( false );
			wait( 0.05 );
		}
		player AllowProne( true );
	}
}

load_friendlies()
{
	if ( IsDefined( game[ "total characters" ] ) )
	{
		game_characters = game[ "total characters" ];
		PrintLn( "Loading Characters: ", game_characters );
	}
	else
	{
		PrintLn( "Loading Characters: None!" );
		return;
	}

	ai = GetAIArray( "allies" );
	total_ai = ai.size;
	index_ai = 0;

	spawners = GetSpawnerTeamArray( "allies" );
	total_spawners = spawners.size;
	index_spawners = 0;

	while ( 1 )
	{
		if ( ( ( total_ai <= 0 ) && ( total_spawners <= 0 ) ) || ( game_characters <= 0 ) )
			return;

		if ( total_ai > 0 )
		{
			if ( IsDefined( ai[ index_ai ].script_friendname ) )
			{
				total_ai--;
				index_ai++;
				continue;
			}

			PrintLn( "Loading character.. ", game_characters );
			ai[ index_ai ] codescripts\character::new();
			ai[ index_ai ] thread codescripts\character::load( game[ "character" + ( game_characters - 1 ) ] );
			total_ai--;
			index_ai++;
			game_characters--;
			continue;
		}

		if ( total_spawners > 0 )
		{
			if ( IsDefined( spawners[ index_spawners ].script_friendname ) )
			{
				total_spawners--;
				index_spawners++;
				continue;
			}

			PrintLn( "Loading character.. ", game_characters );
			info = game[ "character" + ( game_characters - 1 ) ];
			precache( info [ "model" ] );
			precache( info [ "model" ] );
			spawners[ index_spawners ] thread spawn_setcharacter( game[ "character" + ( game_characters - 1 ) ] );
			total_spawners--;
			index_spawners++;
			game_characters--;
			continue;
		}
	}
}

check_flag_for_stat_tracking( msg )
{
	if ( !issuffix( msg, "aa_" ) )
		return;

	[[ level.sp_stat_tracking_func ]]( msg );
}



precache_script_models()
{
	waittillframeend;
	if ( !isdefined( level.scr_model ) )
		return;
	models = GetArrayKeys( level.scr_model );
	for ( i = 0; i < models.size; i++ )
	{
		if ( IsArray( level.scr_model[ models[ i ] ] ) )
		{
			for ( modelIndex = 0; modelIndex < level.scr_model[ models[ i ] ].size; modelIndex++ )
				PreCacheModel( level.scr_model[ models[ i ] ][ modelIndex ] );
		}
		else
			PreCacheModel( level.scr_model[ models[ i ] ] );
	}
}


filmy()
{
	if ( GetDvar( "grain_test" ) == "" )
		return;
	effect = LoadFX( "misc/grain_test" );
	looper = Spawn( "script_model", level.player GetEye() );
	looper SetModel( "tag_origin" );
	looper Hide();
	PlayFXOnTag( effect, looper, "tag_origin" );
	SetTimeScale( 1.7 );
	while ( 1 )
	{
		wait .05;
		VisionSetNaked( "sepia" );
		looper.origin = level.player GetEye() + ( vector_multiply( AnglesToForward( level.player GetPlayerAngles() ), 50 ) );
	}
}

arcademode_save()
{
	has_save = [];
	has_save[ "cargoship" ] = 			true;
	has_save[ "blackout" ] = 			true;
	has_save[ "armada" ] = 				true;
	has_save[ "bog_a" ] = 				true;
	has_save[ "hunted" ] = 				true;
	has_save[ "ac130" ] = 				true;
	has_save[ "bog_b" ] = 				true;
	has_save[ "airlift" ] = 			true;
	has_save[ "village_assault" ] = 	true;
	has_save[ "scoutsniper" ] = 		true;
	has_save[ "ambush" ] = 				true;
	has_save[ "sniperescape" ] = 		false;
	has_save[ "village_defend" ] = 		false;
	has_save[ "icbm" ] = 				true;
	has_save[ "launchfacility_a" ] = 	true;
	has_save[ "launchfacility_b" ] = 	false;
	has_save[ "jeepride" ] = 			false;
	has_save[ "airplane" ] = 			true;

	if ( has_save[ level.script ] )
		return;

	wait 2.5;
	imagename = "levelshots / autosave / autosave_" + level.script + "start";
	// string not found for AUTOSAVE_LEVELSTART
	SaveGame( "levelstart", &"AUTOSAVE_LEVELSTART", imagename, true );
}

player_death_detection()
{
	// a dvar starts high then degrades over time whenever the player dies,
	// checked from maps\_utility::player_died_recently()
	SetDvar( "player_died_recently", "0" );
	thread player_died_recently_degrades();

	level add_wait( ::flag_wait, "missionfailed" );
	level.player add_wait( ::waittill_msg, "death" );
	do_wait_any();

	recently_skill = [];
	recently_skill[ 0 ] = 70;
	recently_skill[ 1 ] = 30;
	recently_skill[ 2 ] = 0;
	recently_skill[ 3 ] = 0;

	SetDvar( "player_died_recently", recently_skill[ level.gameskill ] );
}

player_died_recently_degrades()
{
	for ( ;; )
	{
		recent_death_time = GetDvarInt( "player_died_recently", 0 );
		if ( recent_death_time > 0 )
		{
			recent_death_time -= 5;
			SetDvar( "player_died_recently", recent_death_time );
		}
		wait( 5 );
	}
}

set_legacy_map()
{
	switch( level.script )
	{
		case "killhouse":
		case "cargoship":
		case "coup":
		case "blackout":
		case "armada":
		case "bog_a":
		case "hunted":
		case "ac130":
		case "bog_b":
		case "airlift":
		case "aftermath":
		case "village_assault":
		case "scoutsniper":
		case "sniperescape":
		case "village_defend":
		case "ambush":
		case "icbm":
		case "launchfacility_a":
		case "launchfacility_b":
		case "jeepride":
		case "airplane":
		return true;
		default:
		break;
	}

	return false;
}

trigger_spawngroup( trigger )
{
	waittillframeend;// so level.spawn_groups is defined

	AssertEx( IsDefined( trigger.script_spawngroup ), "spawngroup Trigger at " + trigger.origin + " has no script_spawngroup" );
	spawngroup = trigger.script_spawngroup;
	if ( !isdefined( level.spawn_groups[ spawngroup ] ) )
		return;

	trigger waittill( "trigger" );

	spawners = random( level.spawn_groups[ spawngroup ] );

	foreach ( _, spawner in spawners )
	{
		spawner spawn_ai();
	}
}

init_level_players()
{
	level.players = GetEntArray( "player", "classname" );
	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[ i ].unique_id = "player" + i;
	}

	level.player = level.players[ 0 ];
	if ( level.players.size > 1 )
		level.player2 = level.players[ 1 ];

	level notify( "level.players initialized" );
}

kill_all_players_trigger()
{
	self waittill( "trigger", player );

	// disable co-op revive
	if ( flag_exist( "coop_revive" ) )
		flag_clear( "coop_revive" );

	if ( flag_exist( "coop_alldowned" ) )
		flag_set( "coop_alldowned" );

	if ( IsDefined( player ) && IsAlive( player ) )
	{
		player EnableHealthShield( false );
		player Kill( player.origin );
	}
}

trigger_vehicle_spline_spawn( trigger )
{
	trigger waittill( "trigger" );
	//wait( 3 );
	spawners = GetEntArray( trigger.target, "targetname" );
	foreach ( spawner in spawners )
	{
		spawner thread maps\_vehicle::spawn_vehicle_and_attach_to_spline_path( 70 );
		wait( 0.05 );// slow start it up so spread it out
	}
}

trigger_vehicle_spawn( trigger )
{
	trigger waittill( "trigger" );

	spawners = GetEntArray( trigger.target, "targetname" );
	foreach ( spawner in spawners )
	{
		spawner thread maps\_vehicle::spawn_vehicle_and_gopath();
		wait( 0.05 );// slow start it up so spread it out
	}
}

trigger_dooropen( trigger )
{
	trigger waittill( "trigger" );
	targets = GetEntArray( trigger.target, "targetname" );
	rotations = [];
	rotations[ "left_door" ] = -170;
	rotations[ "right_door" ] = 170;
	foreach ( door in targets )
	{
		AssertEx( IsDefined( door.script_noteworthy ), "Door had no script_noteworthy to indicate which door it is. Must be left_door or right_door." );
		rotation = rotations[ door.script_noteworthy ];
		door ConnectPaths();
		door RotateYaw( rotation, 1, 0, 0.5 );
	}
}

trigger_glass_break( trigger )
{
	glassID = GetGlassArray( trigger.target );

	if ( !IsDefined( glassID ) || glassID.size == 0 )
	{
		AssertMsg( "Glass shatter trigger at origin " + trigger.origin + " needs to target a func_glass." );
		return;
	}

	while ( 1 )
	{
		level waittill( "glass_break", other );

		// the ent that sent the notify needs to be touching the trigger_glass_break
		if ( other IsTouching( trigger ) )
		{
			// try to figure out the direction of movement
			ref1 = other.origin;
			wait( 0.05 );
			ref2 = other.origin;

			direction = undefined;
			if ( ref1 != ref2 )
			{
				direction = ref2 - ref1;
			}

			if ( IsDefined( direction ) )
			{
				foreach ( glass in glassID )
					DestroyGlass( glass, direction );
				break;
			}
			else
			{
				foreach ( glass in glassID )
					DestroyGlass( glass );
				break;
			}
		}
	}

	trigger Delete();
}

trigger_vehicle_getin_spawn( trigger )
{
	vehicle_spawners = GetEntArray( trigger.target, "targetname" );
	foreach ( spawner in vehicle_spawners )
	{
		targets = GetEntArray( spawner.target, "targetname" );
		foreach ( target in targets )
		{
			if ( !IsSubStr( target.code_classname, "actor" ) )
				continue;
			if ( !( target.spawnflags & 1 ) )
				continue;
			target.dont_auto_ride = true;
		}
	}
	trigger waittill( "trigger" );

	vehicle_spawners = GetEntArray( trigger.target, "targetname" );
	array_thread( vehicle_spawners, ::add_spawn_function, ::vehicle_spawns_targets_and_rides );
	array_thread( vehicle_spawners, ::spawn_vehicle );
}

vehicle_spawns_targets_and_rides()
{
	targets = GetEntArray( self.target, "targetname" );
	spawners = [];
	foreach ( target in targets )
	{
		if ( target.code_classname == "info_vehicle_node" )
			continue;
		spawners[ spawners.size ] = target;
	}

	// make the closest spawner the driver
	spawners = get_array_of_closest( self.origin, spawners );

	foreach ( index, spawner in spawners )
	{
		spawner thread add_spawn_function( ::guy_spawns_and_gets_in_vehicle, self, index );
	}

	array_thread( spawners, ::spawn_ai );
	self waittill( "guy_entered" );
	wait( 3 );

	self thread vehicle_becomes_crashable();
	if ( !self.riders.size )
		return;


	self gopath();
	self leave_path_for_spline_path();
}

guy_spawns_and_gets_in_vehicle( vehicle, position )
{
	self mount_snowmobile( vehicle, position );
}


watchWeaponChange()
{
	if ( !isdefined( level.friendly_thermal_Reflector_Effect ) )
		level.friendly_thermal_Reflector_Effect = LoadFX( "misc/thermal_tapereflect_inverted" );
	self endon( "death" );

	//if ( IsSubStr( self GetCurrentWeapon(), "_thermal" ) )
	weap = self GetCurrentWeapon();
	if ( weap_has_thermal( weap ) )
		self thread thermal_tracker();

	while ( 1 )
	{
		self waittill( "weapon_change", newWeapon );

		if ( weap_has_thermal( newWeapon ) )
			self thread thermal_tracker();
		else
			self notify( "acogThermalTracker" );
	}
}

weap_has_thermal( weap )
{
	if ( !isdefined( weap ) )
		return false;
	if ( weap == "none" )
		return false;
	if ( WeaponHasThermalScope( weap ) )
		return true;

	return false;
}

thermal_tracker()
{
	self endon( "death" );

	self notify( "acogThermalTracker" );
	self endon( "acogThermalTracker" );

	curADS = 0;

	for ( ;; )
	{
		lastADS = curADS;
		curADS = self PlayerAds();

		if ( turn_thermal_on( curADS, lastADS ) )
		{
			thermal_EffectsOn();
		}
		else
		if ( turn_thermal_off( curADS, lastADS ) )
		{
			thermal_EffectsOff();
		}

		wait( 0.05 );
	}
}

turn_thermal_on( curADS, lastADS )
{
	if ( curADS <= lastADS )
		return false;

	if ( curADS <= 0.65 )
		return false;

	return !isdefined( self.is_in_thermal_Vision );
}

turn_thermal_off( curADS, lastADS )
{
	if ( curADS >= lastADS )
		return false;

	if ( curADS >= 0.80 )
		return false;

	return IsDefined( self.is_in_thermal_Vision );
}


thermal_EffectsOn()
{
	self.is_in_thermal_Vision = true;

	friendlies = GetAIArray( "allies" );
	foreach ( guy in friendlies )
	{
		if ( IsDefined( guy.has_thermal_fx ) )
			continue;

		guy.has_thermal_fx = true;
		guy thread loop_friendly_thermal_Reflector_Effect( self.unique_id );
	}

	if ( is_coop() )
	{
		other_player = get_other_player( self );
		if ( !isdefined( other_player.has_thermal_fx ) )
		{
			other_player.has_thermal_fx = true;
			other_player thread loop_friendly_thermal_Reflector_Effect( self.unique_id, self );
		}
	}
}

thermal_EffectsOff()
{
	self.is_in_thermal_Vision = undefined;
	level notify( "thermal_fx_off" + self.unique_id );

	friendlies = GetAIArray( "allies" );
	for ( index = 0; index < friendlies.size; index++ )
	{
		friendlies[ index ].has_thermal_fx = undefined;
	}

	if ( is_coop() )
	{
		other_player = get_other_player( self );
		other_player.has_thermal_fx = undefined;
	}
}

loop_friendly_thermal_Reflector_Effect( player_id, onlyForThisPlayer )
{
	if ( IsDefined( self.has_no_ir ) )
	{
		AssertEx( self.has_no_ir, ".has_ir must be true or undefined" );
		return;
	}

	level endon( "thermal_fx_off" + player_id );
	self endon( "death" );

	for ( ;; )
	{
		if ( IsDefined( onlyForThisPlayer ) )
			PlayFXOnTagForClients( level.friendly_thermal_Reflector_Effect, self, "J_Spine4", onlyForThisPlayer );
		else
			PlayFXOnTag( level.friendly_thermal_Reflector_Effect, self, "J_Spine4" );

		//"tag_reflector_arm_ri"

		wait( 0.2 );
	}
}


claymore_pickup_think_global()
{
	PreCacheItem( "claymore" );
	self endon( "deleted" );
	self SetCursorHint( "HINT_NOICON" );
	// Press and hold &&1 to pickup claymore
	self SetHintString( &"WEAPON_CLAYMORE_PICKUP" );
	self MakeUsable();

	// if nothing no ammo count is set assume max ammo.
	ammo_count = WeaponMaxAmmo( "claymore" ) + WeaponClipSize( "claymore" );

	if ( isdefined( self.script_ammo_clip ) )
	{
		ammo_count = self.script_ammo_clip;
	}

	while( ammo_count > 0 )
	{
		self waittill( "trigger", player );

		player PlaySound( "weap_pickup" );

		current_ammo_count = 0;
		if ( !player HasWeapon( "claymore" ) )
		{
			player GiveWeapon( "claymore" );
		}
		else
		{
			current_ammo_count = player GetAmmoCount( "claymore" );
		}

		if ( IsDefined( ammo_count ) && ammo_count > 0 )
		{
			ammo_count = current_ammo_count + ammo_count;

			max_ammo = WeaponMaxAmmo( "claymore" );
			clip_size = WeaponClipSize( "claymore" );

			if ( ammo_count >= clip_size )
			{
				ammo_count -= clip_size;
				player setweaponammoclip( "claymore", clip_size );
			}

			if ( ammo_count >= max_ammo )
			{
				ammo_count -= max_ammo;
				player SetWeaponAmmoStock( "claymore", max_ammo );
			}
			else if ( ammo_count > 0 )
			{
				player SetWeaponAmmoStock( "claymore", ammo_count );
				ammo_count = 0;
			}
		}
		else
		{
			player GiveMaxAmmo( "claymore" );
		}

		slotnum = 4;
		if ( IsDefined( player.remotemissile_actionslot ) && player.remotemissile_actionslot == 4 )
		{
			slotnum = 2;
		}
		player SetActionSlot( slotnum, "weapon", "claymore" );

		player SwitchToWeapon( "claymore" );
	}

	if ( IsDefined( self.target ) )
	{
		targets = GetEntArray( self.target, "targetname" );
		//give_ammo_count = targets.size + 1;
		foreach ( t in targets )
			t Delete();
	}

	self MakeUnusable();
	self Delete();

}


ammo_cache_think_global()
{
	self.use_trigger = spawn( "script_model", self.origin + ( 0, 0, 28 ) ); // offset can't be higher than prone height of 30
	self.use_trigger setModel( "tag_origin" );
	self.use_trigger makeUsable();
	self.use_trigger SetCursorHint( "HINT_NOICON" );
	// Press and hold &&1 to refill your ammo
	self.use_trigger setHintString( &"WEAPON_CACHE_USE_HINT" );

	self thread ammo_icon_think();

	while ( 1 )
	{
		self.use_trigger waittill( "trigger", player );

		self.use_trigger MakeUnusable();
		player PlaySound( "player_refill_all_ammo" );
		player DisableWeapons();
		heldweapons = player GetWeaponsListAll();
		foreach ( weapon in heldweapons )
		{
			if ( weapon == "claymore" )
				continue;
			if ( weapon == "c4" )
				continue;
			player GiveMaxAmmo( weapon );
			
			clipSize = WeaponClipSize( weapon );
			if( isdefined( clipSize ) )
			{
				if ( player GetWeaponAmmoClip( weapon ) < clipSize )
					player SetWeaponAmmoClip( weapon, clipSize );
			}
		}
		wait 1.5;
		player EnableWeapons();
		self.use_trigger MakeUsable();
	}
}

ammo_icon_think()
{
	trigger = Spawn( "trigger_radius", self.origin, 0, 320, 72 );

	icon = NewHudElem();
	icon SetShader( "waypoint_ammo", 1, 1 );
	icon.alpha = 0;
	icon.color = ( 1, 1, 1 );
	icon.x = self.origin[ 0 ];
	icon.y = self.origin[ 1 ];
	icon.z = self.origin[ 2 ] + 16;
	icon SetWayPoint( true, true );

	wait( 0.05 );

	while ( true )
	{
		trigger waittill( "trigger", other );

		if ( !isplayer( other ) )
			continue;

		while ( other IsTouching( trigger ) )
		{
			show = true;
			weapon = other GetCurrentPrimaryWeapon();
			if ( weapon == "none" )
				show = false;
			else
			if ( ( other GetFractionMaxAmmo( weapon ) ) > .9 )
				show = false;

			if ( player_looking_at( self.origin, 0.8, true ) && show )
				ammo_icon_fade_in( icon );
			else
				ammo_icon_fade_out( icon );
			wait 0.25;
		}
		ammo_icon_fade_out( icon );
	}
}

ammo_icon_fade_in( icon )
{
	if ( icon.alpha != 0 )
		return;

	icon FadeOverTime( 0.2 );
	icon.alpha = .3;
	wait( 0.2 );
}

ammo_icon_fade_out( icon )
{
	if ( icon.alpha == 0 )
		return;

	icon FadeOverTime( 0.2 );
	icon.alpha = 0;
	wait( 0.2 );
}

handle_getviewpos()
{
	/#
	SetDevDvarIfUninitialized( "launcher_viewpos", 0 );
	playerviewpos = ( 0, 0, 0 );
	while ( 1 )
	{
		while ( ! GetDebugDvarInt( "launcher_viewpos" ) )
			wait .05;
		SetDevDvar( "launcher_viewpos", "0" );
		playerviewpos = level.player.origin + ( 0, 0, level.player GetPlayerViewHeight() ) ;
		playerviewangle = level.player GetPlayerAngles();
		launcher_write_clipboard( playerviewpos[ 0 ] + ", " + playerviewpos[ 1 ] + ", " + playerviewpos[ 2 ] );

		//this part doesn't do anything for radiant. gonna have to make it work sometime.
		// + " " + playerviewangle[0] + " " + playerviewangle[1]
	}
	#/
}

trigger_multiple_visionset( trigger )
{
	AssertEx( IsDefined( trigger.script_delay ), "Vision set trigger at " + trigger.origin + " has no script_delay to control the fade time." );
	AssertEx( IsDefined( trigger.script_visionset ), "Vision set trigger at " + trigger.origin + " has no script_visionset to control the vision set." );

	for ( ;; )
	{
		trigger waittill( "trigger" );
		vision_set_fog_changes( trigger.script_visionset, trigger.script_delay );
	}
}


handle_getviewangle()
{
	/#
	SetDevDvarIfUninitialized( "launcher_viewangle", 0 );
	playerviewpos = ( 0, 0, 0 );
	while ( 1 )
	{
		while ( ! GetDvarInt( "launcher_viewangle", 0 ) )
			wait .05;
		SetDevDvar( "launcher_viewangle", "0" );
		playerviewangle = level.player GetPlayerAngles();
		launcher_write_clipboard( playerviewangle[ 0 ] + ", " + playerviewangle[ 1 ] + ", " + playerviewangle[ 2 ] );

		//this part doesn't do anything for radiant. gonna have to make it work sometime.
		// + " " + playerviewangle[0] + " " + playerviewangle[1]
	}
	#/
}

window_destroy()
{
	Assert( IsDefined( self.target ) );

	glassID = GetGlass( self.target );

	// this can happen with myMapEnts
	//assertex( IsDefined( glassID ), "couldn't find glass for ent with targetname \"window_poster\" at "+ self GetOrigin() );
	if ( !isDefined( glassID ) )
	{
		PrintLn( "Warning: Couldn't find glass with targetname \"" + self.target + "\" for ent with targetname \"window_poster\" at " + self.origin );
		return;
	}

	level waittillmatch( "glass_destroyed", glassID );
	self Delete();
}

global_empty_callback( empty1, empty2, empty3, empty4, empty5 )
{
	AssertMsg( "a _stealth or _idle related function was called in a global script without being initilized by the stealth system.  If you've already initilized those scripts, then this is a bug for Mo." );
}

trigger_multiple_compass( trigger )
{
	minimap_image = trigger.script_parameters;
	AssertEx( IsDefined( minimap_image ), "trigger_multiple_compass has no script_parameters for its minimap_image." );

	if ( !isdefined( level.minimap_image ) )
		level.minimap_image = "";
	for ( ;; )
	{
		trigger waittill( "trigger" );
		if ( level.minimap_image != minimap_image )
		{
			maps\_compass::setupMiniMap( minimap_image );
		}
	}
}

weapon_list_debug()
{
	create_dvar( "weaponlist", "0" );
	if ( !getdvarint( "weaponlist" ) )
		return;

	ents = GetEntArray();
	list = [];
	foreach ( ent in ents )
	{
		if ( !isdefined( ent.code_classname ) )
			continue;
		if ( IsSubStr( ent.code_classname, "weapon" ) )
		{
			list[ ent.classname ] = true;
		}
	}

	PrintLn( "Placed weapons list: " );
	foreach ( weapon, _ in list )
	{
		PrintLn( weapon );
	}

	spawners = GetSpawnerArray();
	classes = [];
	foreach ( spawner in spawners )
	{
		classes[ spawner.code_classname ] = true;
	}

	PrintLn( "" );
	PrintLn( "Spawner classnames: " );

	foreach ( class, _ in classes )
	{
		PrintLn( class );
	}
}

slowmo_system_init()
{
	level.slowmo = spawnstruct();

	slowmo_system_defaults();

	notifyOnCommand( "_cheat_player_press_slowmo", "+melee" );
	notifyOnCommand( "_cheat_player_press_slowmo", "+melee_breath" );
}

slowmo_system_defaults()
{
	level.slowmo.lerp_time_in = 0.0;
	level.slowmo.lerp_time_out = .25;
	level.slowmo.speed_slow = 0.4;
	level.slowmo.speed_norm = 1.0;
}
