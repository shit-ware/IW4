/****************************************************************************

Level: 		Cliffhanger (cliffhanger.bsp)
Location:	Eastern Krgyzstan
Campaign: Price's PMC on assignment
Objectives:	
			1. Climb to the summit.
			2. Plant C4 on the fuel storage tanks.
			3. Infiltrate the storage hangar. 
			4. Extract the nuclear power core from the downed satellite.
			5. Get to the exfil point.
			6. Get on the snowmobile.

Notes on progression:
1. climb, jump, climb, spiderman, tarzan, climb to open field
2. Price: "Cake, start the uplink."
3. Cake: "Already on it. Let's hope these codes were worth what we paid."
4. Price: "Soap, on me, let's go. Satellite time's not cheap."
5. Cake: "Ok, I'm gettin' a good feed. 10 minutes on the clock starting now." (starting open field)

*****************************************************************************/

#include maps\_utility;
#include maps\_vehicle;
#include maps\_anim;
#include common_scripts\utility;
#include maps\_stealth_utility;
#include maps\_hud_util;
#include maps\_blizzard;
#include maps\cliffhanger_code;
#include maps\cliffhanger_stealth;
#include maps\cliffhanger_snowmobile;





main()
{
	SetSavedDvar( "com_cinematicEndInWhite", 1 );

	price_spawner = getent( "price", "script_noteworthy" );
	price_spawner.script_friendname = "Captain MacTavish";
	
	
	level.DODGE_DISTANCE = 500;
	level.POS_LOOKAHEAD_DIST = 200;

	setsaveddvar( "r_specularcolorscale", "1.2" );
	maps\cliffhanger_precache::main();
	flags();
	default_start( ::start_cave );
	add_start( "cave", 			::start_cave, 			"With soap", 				::cave_main );
	add_start( "e3", 			::start_e3, 			"E3", 						::cave_main );
	add_start( "climb", 		::start_climb, 			"Icepicks", 				::cave_main );
	add_start( "jump", 	 		::start_jump, 			"Make the jump",			::cave_main );
	add_start( "clifftop", 		::start_clifftop, 		"Learn heartbeat sensor", 	::clifftop_main );
	add_start( "camp", 			::start_camp, 			"sneak through", 			::camp_main );
	add_start( "c4", 			::start_c4, 			"plant it on the tanks", 	::c4_main );
	add_start( "goto_hanger", 	::start_goto_hanger, 	"Go there", 				::goto_hanger_main );
	add_start( "hangerpath", 	::start_hangerpath, 	"Find it", 					::hangerpath_main );//broken and not needed
	add_start( "hanger", 		::start_hanger, 		"Be there", 				::hanger_main );
	add_start( "satellite", 	::start_satellite, 		"Got DSM",		 			::player_used_computer );
	add_start( "tarmac", 		::start_ch_tarmac, 		"escape",		 			::cliffhanger_tarmac_main );
	add_start( "icepick", 		::start_icepick, 		"Watch Soap stab", 			::snowmobile_main );
	add_start( "snowmobile", 	::start_snowmobile, 	"Ride it to the finish", 	::snowmobile_main );
//	add_start( "snowspawn", ::start_snowmobile, "[snowspawn] -> Snowmobile midpoint", ::snowmobile_main );
//	add_start( "lake", ::start_snowmobile, "[lake] -> Snowmobile lake", ::snowmobile_main );
//	add_start( "avalanche", ::start_avalanche, "[avalanche]", 						::avalanche_main );
	SetSavedDvar( "ai_friendlyFireBlockDuration", 0 );

	global_inits();

	//start everything after the first frame so that level.start_point can be
	//initialized - this is a bad way of doing things...if people are initilizing
	//things before they want their start to start, then they should wait on a flag
	waittillframeend;

	thread cliffhanger_objective_main();

}

/************************************************************************************************************/
/*													CLIMB													*/
/************************************************************************************************************/
cave_main()
{
/#
	if ( level.start_point == "jump" )
	{
		setsaveddvar( "g_friendlyNameDist", 0 );
		flag_wait( "reached_top" );
		return;
	}
#/

	thread maps\_introscreen::cliffhanger_intro_text();

	climb_starts = getentarray( "player_climb", "targetname" );
	climb_starts = array_randomize( climb_starts );
	plane_sound_nodes = getvehiclenodearray( "plane_sound", "script_noteworthy" );
	array_thread( plane_sound_nodes, maps\_mig29::plane_sound_node );
	
	plane_sound_nodes = getvehiclenodearray( "cliff_plane_sound", "script_noteworthy" );
	array_thread( plane_sound_nodes, maps\_climb::cliff_plane_sound_node );
	
	

	foreach ( index, player in level.players )
	{
		player thread maps\_climb::climb_wall( climb_starts[ index ].origin, climb_starts[ index ].angles );
	}
	
	array_thread( climb_starts, ::self_delete );


	maps\_climb::cliff_scene_with_price();
}



/************************************************************************************************************/
/*												CLIFFTOP													*/
/************************************************************************************************************/
clifftop_main()
{
	level.price pushplayer( true );
	if ( is_e3_start() )
	{
		return;
	}
	
	level.friendlyFireDisabled = false;
	SetSavedDvar( "g_friendlyfiredist", 175 );
	node = getstruct( "price_clifftopstart", "targetname" );
//	level.price stopanimscripted();
	//level.price disable_exits();
	//level.price enable_cqbwalk();

	//level.price forceTeleport( node.origin, node.angles );
	level.price.moveplaybackrate = .6;
	level.price.goalradius = 16;
//	level.price setgoalpos( level.price.origin );
//	level.price enable_ai_color();

	activate_trigger_with_targetname( "price_start_clifftop" );//tell price to crouch 

	thread maps\_utility::set_ambient( "snow_cliff" );

	//save at top of cliff
	autosave_by_name( "clifftop" );


	//settings for no blizzard
	sight_ranges_long();

	level.price set_battlechatter( false );

	//give player his guns back after climb takes them
	flag_set( "delay_weapon_switch" );
	player_weapons_init();

	//array_thread( getnodearray( "clifftop_nodes", "script_noteworthy" ), ::clifftop_aim_thread );
	array_thread( getentarray( "patrollers_1_leftguy", "script_noteworthy" ), ::add_spawn_function, ::clifftop_patroller1_logic );
	array_thread( getentarray( "patrollers_1_rightguy", "script_noteworthy" ), ::add_spawn_function, ::clifftop_patroller1_logic );


	thread maps\_blizzard::blizzard_level_transition_light( .05 );


//	level add_wait( ::flag_wait, "airfield_in_sight" );
//	level add_func( ::dialog_airfield_in_sight );
//	thread do_wait();
//	
//
//	level add_wait( ::flag_wait, "clifftop_patrol1_dead" );
//	level add_func( ::dialog_first_guys_dead );
//	thread do_wait();


	level add_wait( ::flag_wait, "clifftop_patrol2_dead" );
	level add_wait( ::flag_wait, "clifftop_patrol1_dead" );
	level add_func( ::flag_set, "clifftop_area_done" );
	thread do_wait();

	level add_wait( ::flag_wait, "clifftop_corner_wind_direction" );
	level add_func( maps\_blizzard::blizzard_level_transition_light, 4 );
	thread do_wait();

	//save after each group
	thread camp_flag_save( "clifftop_patrol1_dead" );
	thread camp_flag_save( "clifftop_patrol2_dead" );

	thread mig_landing1();

	thread dialog_setup_heartbeat();
	thread price_starts_moving();
	
	
	array_thread( getentarray( "clifftop_guys", "targetname" ), ::add_spawn_function, ::price_kills_me_if_too_close );
	flag_init( "player_killed_one_first_two_encounters" );
	array_thread( getentarray( "clifftop_guys", "targetname" ), ::add_spawn_function, ::flag_if_player_kill );
	flag_init( "said_dont_alert_them" );
	flag_init( "said_nicely_done" );
	flag_init( "interupt_first_encounter" );
	flag_init( "first_encounter_dialog_finished" );
	thread dialog_first_encounter();
	thread dialog_first_encounter_success();
	thread dialog_first_encounter_failure();
	
	flag_init( "blizzard_halfway" );
	level add_wait( ::flag_wait, "airfield_in_sight" );
	level add_func( ::blizzard_starts );
	thread do_wait();
	
	flag_init( "said_storm_brewing" );
	thread dialog_storm_moving_in();
	
	flag_init( "interupt_second_encounter" );
	flag_init( "second_encounter_dialog_finished" );
	thread dialog_second_encounter();
	thread dialog_second_encounter_success();
	thread dialog_go_do_the_work();
	
	thread price_climbs_ledge();

	flag_wait( "first_two_guys_in_sight" );
	level.price pushplayer( false );
	flag_set( "clifftop_guys_move" );
	
	//save just before first encounter
	autosave_by_name( "first_encounter" );
	
	flag_wait( "dialog_take_point" );
	
}



/************************************************************************************************************/
/*														CAMP												*/
/************************************************************************************************************/
camp_main()
{	
	//save
	autosave_stealth();
	
	thread dialog_your_in();
	thread spawn_beehive();

	player_speed_percent( 90, 2 );

	thread camp_flag_save( "give_c4_obj" );
	thread start_truck_patrol();
	
}


/************************************************************************************************************/
/*														C4													*/
/************************************************************************************************************/
c4_main()
{	
	thread dialog_plant_c4_nag();
	thread dialog_near_fueling_station();
	array_thread( getentarray( "base_c4_models", "targetname" ), ::c4_player_obj );
	
	flag_wait( "player_halfway_to_c4" );
	autosave_stealth();
	thread dialog_they_are_respawning();
	thread return_spawning();
	
	flag_wait( "one_c4_planted" );
	
	autosave_stealth();
}

/************************************************************************************************************/
/*													GOTO HANGER											*/
/************************************************************************************************************/
goto_hanger_main()
{
	//save
	//autosave_stealth();
	
	
	level add_wait( ::dialog_goto_hanger );
	level add_func( ::flag_set, "price_moving_to_hanger" );
	thread do_wait();	
	
	thread dialog_goto_hanger_nag();
	
	thread camp_flag_save( "player_halfway_to_hanger" );

	//level.price set_force_color( "c" );
	//level.price enable_ai_color();
	thread player_speed_percent( 90, 2 );

	//level.price camp_smartstance_settings();
	//level.price thread follow_player( 200 );//barney
	//level.price enable_stealth_smart_stance();

	//thread price_teleport_fallback( "starting_hanger_backdoor_path", "hanger_path_price_teleport", 1300 );

	
	flag_wait( "starting_hanger_backdoor_path" );
}


/************************************************************************************************************/
/*													HANGER PATH											*/
/************************************************************************************************************/
hangerpath_main()
{
	flag_set( "price_moving_to_hanger" );
	level.price stop_magic_bullet_shield();
	level.price delete();
	
	/#
	if ( level.start_point == "hangerpath" )
		wait( 0.05 ); // so spawner will work
	#/
	
	price_hanger_start = getent( "price_hanger_start", "targetname" );
	level.price_spawner.script_stealth = undefined;
	level.price_spawner.origin = price_hanger_start.origin;
	level.price = new_captain_price_spawns();

	level.price disable_ai_color();
	level.price forceUseWeapon( "ak47_arctic", "primary" );
	
	//save
	autosave_stealth();

	//level.price set_force_color( "c" );
	//level.price enable_ai_color();
	player_speed_percent( 90, 2 );

	//thread price_on_hanger_path();

	flag_wait( "starting_hanger_backdoor_path" );
	
	thread turn_off_blizzard();
	
	
	enemies = GetAISpeciesArray( "axis", "all" );
	
	welder_wing = get_living_ai( "welder_wing", "script_noteworthy" );
	if( isalive( welder_wing ) )
		enemies = array_remove( enemies, welder_wing );
		
	welder_engine = get_living_ai( "welder_engine", "script_noteworthy" );
	if( isalive( welder_engine ) )
		enemies = array_remove( enemies, welder_engine );
	
	
	if( isalive( level.truck_patrol ) )
		level.truck_patrol Vehicle_SetSpeed( 0, 15 );

	flag_set( "script_attack_override" );
	
	flag_set( "done_with_stealth_camp" );
	
	price = level.price;
	price disable_ai_color();
	price_behind_barrel = getnode( "price_behind_barrel", "targetname" );
	
	price setgoalnode( price_behind_barrel );
	price.goalradius = 20;
	price.fixednode = true;
	
	surviving_enemies = [];
	foreach( mf in enemies )
	{	
		//DELETE EVERYONE you cant see
		d = distance( mf.origin, level.player.origin );
		if( d > 1000 )
		{
			mf delete();
			continue;
		}
		if( isdefined( mf.ridingvehicle ) )
		{
			mf delete();
			continue;
		}
		
		//keep the rest
		surviving_enemies[ surviving_enemies.size ] = mf;
	}
	//the rest magically know where you are (cause they were alerted recently in order to be that close)
	disable_stealth_system();
	
	if( surviving_enemies.size > 0 )//someone is alive and broken stealth
	{
		foreach( mf in surviving_enemies )
			mf thread setup_stealth_enemy_cleanup();
		
		while( 1 )
		{
			all_dead = true;
			foreach( mf in surviving_enemies )
			{
				
				if( isalive( mf ) )
				{
					if ( mf doingLongDeath() )
						continue;
						
					mf.goalradius = 400;
					mf.favoriteenemy = level.player;
					mf setgoalentity( level.player );
					all_dead = false;
				}
			}
			if( all_dead )
			{
				break;
			}
			else
			{
				if( flag( "player_on_backdoor_path" ) )
					flag_set( "brought_friends" );
				wait 1;
			}
		}
	}
}



/************************************************************************************************************/
/*													HANGER											*/
/************************************************************************************************************/
hanger_main()
{
	flag_wait( "player_on_backdoor_path" );
	
	// add the drill that price will pick up in the hangar
	satelite_sequence_node = GetEnt( "satelite_sequence", "targetname" );
	level.drill = spawn_anim_model( "drill" );
	satelite_sequence_node anim_first_frame_solo( level.drill, "enter" );
	
	if( flag( "brought_friends" ) )
	{
		//Brought some friends with you?	
		level.price thread dialogue_queue( "cliff_pri_broughtfriends" );
	}
	else
	{
		//Took the scenic route eh?	
		level.price thread dialogue_queue( "cliff_pri_scenicroute" );
	}

	price_comes_out = GetNode( "price_comes_out", "targetname" );
	level.price SetGoalNode( price_comes_out );
	level.price.goalradius = 16;

	for ( ;; )
	{
		if ( Distance( level.player.origin, level.price.origin ) < 350 )
			break;
		wait( 0.25 );
	}
	
	
	soap_opens_hanger_door();

	node = getnode( "price_prep_for_locker_brawl_node", "targetname" );
	wait( 0.05 ); // or colorchange will overwrite his destination if coming from a start point
	level.price setgoalnode( node );
	level.price.goalradius = 8;

	
	level.price disable_ai_color();
	level.price forceUseWeapon( "ak47_arctic", "primary" );
	
	flag_clear( "locker_brawl_breaks_out" );//make sure it wasnt set before
	
	
	flag_wait( "locker_brawl_breaks_out" );
	
	cliffhanger_locker_brawl();

	// teleport price to the correct place
	thread price_anims_satellite();


	wait( 2 );
	// Watch my back.	
//	level.price thread dialogue_queue( "cliff_pri_watchmyback" );
	
	hanger_enemies_enter = getnode( "hanger_enemies_enter", "targetname" );
	//hanger_enemies_enter thread maps\_debug::drawOriginForever ();
	use_satelite = getent( "use_satelite", "targetname" );
	satelite_sequence_node = getnode( "satelite_sequence", "targetname" );

	
	keyboard_trigger = getEntWithFlag( "keyboard_used" );
	keyboard_trigger trigger_off();

	// Press and hold ^3&&1^7 to extract the DSM.
	//keyboard_trigger setHintString( &"CLIFFHANGER_USE_SATELITE" );
	
	//level.price_targets = [];


	//save
	//autosave_by_name( "used_keyboard" );

//	level.price set_force_color( "c" );
//	level.price enable_ai_color();
	player_speed_percent( 100, 2 );
	level.price enable_cqbwalk();

	//level.price disable_stealth_smart_stance();


	flag_wait( "player_in_hanger" );

	wait( 2 );
	
	// Go up stairs and look for the DSM.	
	level.price thread dialogue_queue( "cliff_pri_goupstairs" );
	
	thread keyboard_nag();
	dsm = getent( "dsm", "targetname" );
	dsm makeusable();
	dsm setHintString( &"CLIFFHANGER_USE_SATELITE" );
	
	flag_clear( "keyboard_used" );
	dsm waittill( "trigger" );

	if ( maps\_autosave::autoSaveCheck() )
	{
		SaveGame( "keyboard_used", &"CLIFFHANGER_USE_SATELITE", "keyboard_used", false );
	}
	
	thread play_sound_in_space( "dsm_pickup", dsm.origin );
	dsm delete();	
	
	flag_set( "keyboard_used" );
	keyboard_trigger delete();
	wait( 2.2 );
	
	//flag_wait( "hanger_return" );
}

start_satellite()
{
	thread maps\_utility::set_ambient( "snow_base" );
	flag_set( "done_with_stealth_camp" );
	flag_set( "base_c4_price_done" );
	flag_set( "price_moving_to_hanger" );
	start_common_cliffhanger();
	friendly_init_cliffhanger();

	player_hanger_start = getent( "start_satellite_player", "targetname" );
	level.player teleport_ent( player_hanger_start );

	node = getent( "price_hanger_start", "targetname" );
	level.price forceTeleport( node.origin, node.angles );
	level.price forceUseWeapon( "ak47_arctic", "primary" );
	

	//ch_teleport_player();
	maps\_blizzard::blizzard_level_transition_light( 3 );
	thread price_puts_his_hands_up();
	flag_set( "player_in_hanger" );
	flag_set( "reached_top" );
}

player_used_computer()
{
	flag_set( "start_busted_music" );
	
	thread maps\_blizzard::blizzard_level_transition_light( 40 );
	//Well, uh, this is a little awkward, innit mate? No, no, it's quite all right, we're all friends here, just a pub crawl with the lads…uh…	
//	level.price anim_single_queue( level.price, "cliff_pri_pubcrawl" );
	thread open_hanger_doors();
	thread guards_run_in();
	thread more_guards();

	if ( isdefined( level.price._stealth ) )
		level.price stealth_basic_states_default();
	disable_stealth_system();
	level.player.ignoreme = true;
	thread check_player_detonate();
	price_is_captured();
	
	level.player.ignoreme = false;
	flag_wait( "player_detonate" );
	
	saveID = SaveGameNoCommit( "player_detonate", &"CLIFFHANGER_USE_SATELITE", "player_detonate", false );
	thread save_game_if_safe( saveID );
	
	wait( 0.1 );

	level.explosion_enemies = getaiarray( "axis" );
	flag_set( "start_big_explosion" );
	delaythread( 1, ::flag_set, "hanger_reinforcements" );

	level.player SetMoveSpeedScale( 0.3 );
	
	level.player delaycall( 1.5, ::freezecontrols, false );
	//thread player_dies_if_he_moves();
	thread player_slow_mo();
	thread price_starts_shooting();

	battlechatter_on( "axis" );
	thread explosion_chain_reaction();
}

start_ch_tarmac( e3 )
{
	level notify( "kill_variable_blizzard" );

	instant_open_hangar_doors();
	thread maps\_utility::set_ambient( "snow_base" );
	flag_set( "done_with_stealth_camp" );
	flag_set( "base_c4_price_done" );
	flag_set( "price_moving_to_hanger" );
	flag_set( "start_big_explosion" );
	
	if ( !isdefined( e3 ) )
	{
		start_common_cliffhanger();
		friendly_init_cliffhanger();
	}
	else
	{
		level.price_spawner.script_stealth = undefined;
		level.price = new_captain_price_spawns();
	
		level.price disable_ai_color();
		level.price forceUseWeapon( "ak47_arctic", "primary" );
	}
	
	if ( isdefined( level.price._stealth ) )
		level.price stealth_basic_states_default();
	disable_stealth_system();

	player_hanger_start = getent( "price_capture_node", "targetname" );
	level.player teleport_ent( player_hanger_start );
	level.player PlayerLinkTo( player_hanger_start, undefined, 1, 0, 0, 0, 0 );
	
	

	node = getnode( "price_tarmac_path", "targetname" );
	level.price forceTeleport( node.origin, node.angles );
	level.price forceUseWeapon( "ak47_arctic", "primary" );

	//ch_teleport_player();
	maps\_blizzard::blizzard_level_transition_light( 0.05 );
//	thread price_puts_his_hands_up();
	flag_set( "player_in_hanger" );
	flag_set( "reached_top" );
	flag_set( "hanger_reinforcements" );
	flag_set( "hanger_slowmo_ends" );
	flag_set( "start_busted_music" );
	
	black_overlay = create_client_overlay( "black", 0, level.player );
	black_overlay.alpha = 1;

	if ( isdefined( level.e3_text_overlay ) )
	{
		level.e3_text_overlay.alpha = 1;
	}

	delaythread( 1.75, ::explosion_chain_reaction );

	wait( 3.75 );
	black_overlay fadeOverTime( 2 );
	black_overlay.alpha = 0;

	if ( isdefined( level.e3_text_overlay ) )
	{
		level.e3_text_overlay fadeOverTime( 2 );
		level.e3_text_overlay.alpha = 0;
	}

	player_hanger_start delete();
	wait( 0.8 );
	wait( 1.2 );
	
	black_overlay destroy();
	if ( isdefined( level.e3_text_overlay ) )
	{
		level.e3_text_overlay destroy();
	}
}

cliffhanger_tarmac_main()
{

	if ( !isalive( level.price ) )
		return;
	level.price endon( "death" );

	setdvar( "player_has_witnessed_capture", "" ); // cleanup on aisle 5
	
	flag_set( "tarmac_escape" );
	flag_init( "price_reaches_bottom" );
	flag_wait( "hanger_reinforcements" );

	add_global_spawn_function( "axis", ::lower_ai_accuracy );

	add_wait( ::flag_wait, "destroy_tarmac_jeeps" );
	add_func( ::set_off_destructible_with_noteworthy, "destructible_tarmac_jeep_center" );
	add_func( ::set_off_destructible_with_noteworthy, "destructible_oilrig_2" );
	thread do_wait();

	thread price_warns_about_snowmobiles();

	level.price.maxFaceEnemyDist = 200;	// make price run-n-gun more instead of strafing
	level.price set_force_color( "g" );
	exploder( 54 ); // tarmac smoking jets
	exploder( 56 ); // tarmac smoking extra jet before it blows
	spawn_vehicle_from_targetname_and_drive( "tarmac_bmp_spawner" );

	//thread delete_random_vehicles(); // for now, need to do this manually until we add script_random_killspawn to vehicles	hanger_reinforce_spawners = getentarray( "hanger_reinforce_spawner", "targetname" );
	hanger_reinforce_spawners = getentarray( "hanger_reinforce_spawner", "targetname" );
	array_thread( hanger_reinforce_spawners, ::spawn_ai );

	thread more_reinforcements_spawn();
	level.player ent_flag_clear( "_stealth_enabled" );
	level.player.maxVisibleDist = 8000;
	blue_house_bottom_door = getent( "blue_house_bottom_door", "targetname" );
	blue_house_bottom_door delete();

	blue_house_top_door = getent( "blue_house_top_door", "targetname" );
	blue_house_top_door delete();

	/*
	gaz_spawner = getent( "gaz_snowmobile_spawner", "targetname" );
	level.gaz = gaz_spawner spawn_ai();
	level.gaz thread magic_bullet_shield();
	*/

	maps\_vehicle_spline::init_vehicle_splines();
	//thread price_ditches_player_detection();

	level notify( "stop_price_shield" );
	if ( !isdefined( level.price.magic_bullet_shield ) )	
	{
		level.price thread magic_bullet_shield();
	}
	//music_loop( "cliffhanger_escape_music", DEFINE_ESCAPE_MUSIC_TIME );

//	snowmobile_triggers = getentarray( "snowmobile_trigger", "targetname" );
//	array_call( snowmobile_triggers, ::setHintString, "Press &&1 to mount" );

	run_thread_on_noteworthy( "tarmac_hanger_gate", ::connect_and_delete );

	flag_wait( "hanger_slowmo_ends" );

	level.price.ignoreRandomBulletDamage = true;
	level.price.attackerAccuracy = 0;
	level.price.baseAccuracy = 1.8;
	level.price.ignoreSuppression = true;

	level.price.pathEnemyFightDist = 350;
	level.price.pathEnemyLookAhead = 350;
//	level.price enable_ai_color();

	level.price set_battlechatter( false );

	clear_all_ai_grenades();

	price_navigates_tarmac_and_calls_to_player();
	thread price_makes_for_his_mobile();

	flag_wait( "player_slides_down_hill" );
	flag_wait( "price_reaches_bottom" );
	autosave_by_name( "slide_down_hill" );

	thread maps\cliffhanger_snowmobile_code::recover_vehicle_path_trigger();
	hill_attackers_spawn();
}



/************************************************************************************************************/
/*												INITIALIZATIONS												*/
/************************************************************************************************************/

start_flyin()
{
	start_common_cliffhanger();
}

start_cave()
{
	start_common_cliffhanger();
}

start_e3()
{
	start_common_cliffhanger();
	thread e3_objectives();
}
	
e3_objectives()
{
	wait( 0.05 );
	level.curObjective = 1;
	level.objectives = [];
	objective_follow_price();
	objective_c4_fuel_station();
	objective_exfiltrate();
	objective_snowmobile();
}

start_climb()
{
	start_common_cliffhanger();
}

start_clifftop()
{
	flag_set( "reached_top" );
	start_common_cliffhanger();
	friendly_init_cliffhanger();

	ch_teleport_player( "clifftop" );

	node = getstruct( "price_clifftopstart", "targetname" );
	level.price forceTeleport( node.origin, node.angles );
}

start_jump()
{
	start_common_cliffhanger();

	start_pos = getent( "player_big_jump_start", "targetname" );
	level.player setorigin( start_pos.origin );
	level.player setplayerangles( start_pos.angles );

	thread maps\_climb::death_trigger();
	thread maps\_climb::player_big_jump();
}

start_camp( e3 )
{
	flag_set( "price_go_to_climb_ridge" );//for stealth spotted dialog
	flag_set( "reached_top" );
	flag_set( "first_two_guys_in_sight" );//for stealth music
	flag_set( "said_lets_split_up" );
	thread maps\_utility::set_ambient( "snow_base_white" );
	
	if ( !isdefined( e3 ) )
	{
		start_common_cliffhanger();
		friendly_init_cliffhanger();
	}

	//node = getstruct( "price_campstart", "targetname" );
	//level.price forceTeleport( node.origin, node.angles );

	ch_teleport_player( "camp" );

	thread variable_blizzard( 0.05 );
	sight_ranges_blizzard();
}


start_c4()
{
	flag_set( "price_go_to_climb_ridge" );//for stealth spotted dialog
	flag_set( "dialog_take_point" );//for loudspeakers
	flag_set( "reached_top" );
	flag_set( "first_two_guys_in_sight" );//for stealth music
	flag_set( "said_lets_split_up" );
	thread maps\_utility::set_ambient( "snow_base_white" );
	start_common_cliffhanger();
	friendly_init_cliffhanger();
	
	//node = getstruct( "price_c4start", "targetname" );
	//level.price forceTeleport( node.origin, node.angles );
	activate_trigger_with_targetname( "tarmac_guys_trigger" );
	flag_set( "start_truck_patrol" );
	thread start_truck_patrol();
		
	thread spawn_beehive();
	thread variable_blizzard();
	sight_ranges_blizzard();
	//thread dialog_stealth_failure();
}

start_goto_hanger()
{
	flag_set( "price_go_to_climb_ridge" );//for stealth spotted dialog
	flag_set( "dialog_take_point" );//for loudspeakers
	flag_set( "reached_top" );
	flag_set( "first_two_guys_in_sight" );//for stealth music
	flag_set( "said_lets_split_up" );
	thread maps\_utility::set_ambient( "snow_base_white" );
	flag_set( "base_c4_planted" );
	start_common_cliffhanger();
	friendly_init_cliffhanger();

	flag_set( "fence_walker_dead" );
	flag_set( "center_building_patroler_dead" );
	flag_set( "center_building_patroler_buddy_dead" );
	flag_set( "ridge_patroler_dead" );

	//node = getstruct( "price_start_goto_hanger", "targetname" );
	//level.price forceTeleport( node.origin, node.angles );
	activate_trigger_with_targetname( "tarmac_guys_trigger" );
	flag_set( "start_truck_patrol" );
	thread start_truck_patrol();

	ch_teleport_player();
	thread spawn_beehive();
	thread variable_blizzard();
	sight_ranges_blizzard();
	//thread dialog_stealth_failure();
}


start_hangerpath()
{
	flag_set( "price_go_to_climb_ridge" );//for stealth spotted dialog
	flag_set( "dialog_take_point" );//for loudspeakers
	flag_set( "reached_top" );
	flag_set( "first_two_guys_in_sight" );//for stealth music
	flag_set( "said_lets_split_up" );
	thread maps\_utility::set_ambient( "snow_base" );
	flag_set( "base_c4_planted" );
	flag_set( "price_moving_to_hanger" );
	start_common_cliffhanger();
	friendly_init_cliffhanger();

	//node = getstruct( "price_hangerpath_start", "targetname" );
	//level.price forceTeleport( node.origin, node.angles );

	thread variable_blizzard();
	sight_ranges_blizzard();
	ch_teleport_player();
	
	price_hanger_start = getent( "price_hanger_start", "targetname" );
	level.price teleport_ent( price_hanger_start );
}

start_hanger()
{
	flag_set( "reached_top" );
	flag_set( "dialog_take_point" );//for loudspeakers
	flag_set( "first_two_guys_in_sight" );//for stealth music
	thread maps\_utility::set_ambient( "snow_base" );
	flag_set( "done_with_stealth_camp" );
	flag_set( "base_c4_planted" );
	flag_set( "price_moving_to_hanger" );
	start_common_cliffhanger();
	friendly_init_cliffhanger();

	player_hanger_start = getent( "player_hanger_start", "targetname" );
	level.player teleport_ent( player_hanger_start );

	node = getent( "price_hanger_start", "targetname" );
	level.price forceTeleport( node.origin, node.angles );

	//ch_teleport_player();
	maps\_blizzard::blizzard_level_transition_light( 3 );
}


//god_vehicle_spawner
//magic_bullet_spawner

start_common_cliffhanger()
{		
	level.price_spawner = getent( "price", "script_noteworthy" );
	player_init();
	misc_precache();
	model_initializations();
	thread enemy_init();
}




cliffhanger_objective_main()
{
	level.curObjective = 1;
	level.objectives = [];

	//goto_hanger_obj = -1;
	//objnum = 0;
	//level.curr_obj = 0;
	//level.curr_obj_string = undefined;

	//thread objective_stealth();

	switch( level.start_point )
	{
		case "default":
		case "cave":
			level waittill( "follow_price_obj" );
		case "climb":
		case "jump":
		case "clifftop":
			objective_follow_price();
		case "camp":
			objective_enter_camp();
		case "c4":
			//objective_c4_both();//multiple on compass 
			//objective_c4_fuel_tanks();
			//objective_c4_mig();
			objective_c4_fuel_station();

		case "goto_hanger":
		case "hangerpath":
			objective_goto_hanger();

		case "hanger":
			objective_satellite();

		case "satellite":
		case "tarmac":
		case "icepick":
			objective_exfiltrate();
		case "snowmobile":
			objective_snowmobile();

		break;
		default:
			assertmsg( "Start not handled: " + level.start_point );
	}
}