#include maps\_utility;
#include maps\_vehicle;
#include maps\_vehicle_spline;
#include maps\_anim;
#include maps\_hud_util;
#include maps\gulag_ending_code;
#include common_scripts\utility;

/*QUAKED script_origin_pillar1 (1 0.7 0.1) (-32 -32 0) (32 32 94)*/
/*QUAKED script_origin_pillar2 (0.9 0.75 0.1) (-32 -32 0) (32 32 96)*/

endlog_common()
{
	level.default_sprint = GetDvar( "player_sprintSpeedScale" );
	add_start( "run", ::start_run, "run", ::gulag_run_for_it );
	add_start( "cafe", ::start_cafeteria, "cafe", ::gulag_cafeteria );
	add_start( "evac", ::start_evac, "evac", ::gulag_evac );

	waittillframeend;// for _load

	/#
	if ( IsDefined( level.stop_load ) )
	{
		if ( GetDvar( "createfx" ) == "" )
			maps\_global_fx::main();
		return;
	}
	#/


	cafe_ceiling_chunks = GetEntArray( "cafe_ceiling_chunk", "targetname" );
	array_thread( cafe_ceiling_chunks, ::self_delete );

	cafe_ceiling_chunk_smalls = GetEntArray( "cafe_ceiling_chunk_small", "targetname" );
	array_thread( cafe_ceiling_chunk_smalls, ::self_delete );

	cafe_ceiling_pristines = GetEntArray( "cafe_ceiling_pristine", "targetname" );
	array_thread( cafe_ceiling_pristines, ::self_delete );

	rubble = GetEnt( "cafeteria_hallway_rubble", "targetname" );
	rubble thread rubble_think();



	maps\gulag_ending_anim::gulag_ending_anim_main();

	level._effect[ "breach_door" ]					 = LoadFX( "explosions/breach_wall_concrete" );
	level._effect[ "flashlight" ]						 = LoadFX( "misc/flashlight" );
	level._pipe_fx_time = 2.5;

	hookup_rope_ent = GetEnt( "hookup_rope_ent", "targetname" );
	if ( IsDefined( hookup_rope_ent ) )
		hookup_rope_ent Delete();


	flag_init( "player_approaches_rescue_breach" );
	flag_init( "intro_helis_go" );
	flag_init( "player_near_tv" );
	flag_init( "stop_tv_loop" );
	flag_init( "f15s_spawn" );
	flag_init( "anti_air_missiles_fire" );
	flag_init( "aa_hit" );
	flag_init( "f15s_attack" );
	flag_init( "player_heli_uses_modified_yaw" );
	flag_init( "intro_helis_spawned" );
	flag_init( "player_lands" );
	flag_init( "cell_door1" );
	flag_init( "cell_door2" );
	flag_init( "cell_door3" );
	flag_init( "cell_door4" );
	flag_init( "cell_door_weapons" );
	flag_init( "access_control_room" );
	flag_init( "going_in_hot" );
	flag_init( "gulag_cell_doors_enabled" );
	flag_init( "player_exited_bathroom" );
	flag_init( "player_rappels_from_bathroom" );
	flag_init( "rope_drops_now" );
	flag_init( "cell_duty" );
	flag_init( "cellblock_player_starts_rappel" );
	flag_init( "bathroom_second_wave_trigger" );
	flag_init( "player_died_to_cave_in" );
	flag_init( "match_up_for_final_room" );
	flag_init( "rescue_begins" );
	flag_init( "time_to_evac" );
	flag_init( "enable_interior_fx" );
	flag_init( "enable_endlog_fx" );
	flag_init( "player_falls_down" );
	flag_init( "player_evac" );
	flag_init( "controlled_player_rumble" );
	flag_init( "evac_begins" );
	//flag_init( "exit_collapses" );

	PreCacheItem( "smoke_grenade_american" );
	PreCacheItem( "armory_grenade" );
	PreCacheItem( "m4m203_reflex_arctic" );
	PreCacheItem( "f15_sam" );
	PreCacheItem( "sam" );
	PreCacheItem( "stinger" );
	PreCacheItem( "cobra_seeker" );
	PreCacheItem( "rpg_straight" );
	PreCacheItem( "cobra_Sidewinder" );
	PreCacheItem( "claymore" );
	PreCacheItem( "mp5_silencer_reflex" );
	PreCacheTurret( "heli_spotlight" );
	PreCacheTurret( "player_view_controller" );
	
	PreCacheRumble( "heavy_1s" );
	PreCacheRumble( "heavy_2s" );
	PreCacheRumble( "heavy_3s" );

	PreCacheRumble( "light_1s" );
	PreCacheRumble( "light_2s" );
	PreCacheRumble( "light_3s" );
                         
	PreCacheItem( "m14_scoped_arctic" );
	PreCacheItem( "fraggrenade" );
	PreCacheItem( "flash_grenade" );
	PreCacheItem( "claymore" );

	PreCacheModel( "com_emergencylightcase_blue" );
	PreCacheModel( "com_emergencylightcase" );
//	PreCacheModel( "rappelrope100_le_obj" );
	PreCacheModel( "com_drop_rope_obj" );
	PreCacheModel( "com_blackhawk_spotlight_on_mg_setup" );
	PreCacheModel( "com_floodlight" );
	PreCacheModel( "ch_street_wall_light_01_on" );
	PreCacheModel( "ch_street_wall_light_01_off" );
	PreCacheItem( "m4m203_acog" );

//	thread handle_gulag_world_fx();
//	level thread init_tv_movies();
//	thread gulag_music();

	thread calculate_cafe_run_distances();

	turnaround_triggers = GetEntArray( "turnaround_trigger", "targetname" );
	array_thread( turnaround_triggers, ::turnaround_trigger_think );

	ceiling_collapses = GetEntArray( "ceiling_collapse", "targetname" );
	array_thread( ceiling_collapses, ::ceiling_collapse_think );


	chase_brush = GetEnt( "chase_brush", "targetname" );
	chase_brush Hide();
	chase_brush ConnectPaths();

	spawner = GetEnt( "price_spawner", "targetname" );
	spawner thread add_spawn_function( ::become_price );

	set_friendly_endpoint = getstruct( "set_friendly_endpoint", "targetname" );
	set_friendly_endpoint thread set_friendly_endpoint_think();

	array_spawn_function_targetname( "endlog_redshirt_spawner", ::become_redshirt );

	ending_window_littlebird = GetEnt( "ending_window_littlebird", "script_noteworthy" );
	ending_window_littlebird add_spawn_function( ::ending_window_littlebird );

	delete_trees = GetEntArray( "delete_tree", "targetname" );
	array_thread( delete_trees, ::delete_tree_think );

	thread file_cabinet_show();
	//thread pillar_anim_show();


	flag_wait( "rescue_begins" );

	evac_rock = GetEnt( "evac_rock", "targetname" );
	evac_rock NotSolid();

	swing_light_orgs = getstructarray( "swing_light_org", "targetname" );
	array_thread( swing_light_orgs, ::swing_light_org_think );

	swing_light_orgs = getstructarray( "swing_light_org_off", "targetname" );
	array_thread( swing_light_orgs, ::swing_light_org_off_think );

	run_thread_on_noteworthy( "hunted_hanging_light", ::hunted_hanging_light );


	flag_clear( "enable_interior_fx" );
	flag_set( "enable_endlog_fx" );
	remove_global_spawn_function( "allies", ::enable_cqbwalk );

	thread player_pushes_slab();

	ambient_flicker_lights = GetEntArray( "ambient_flicker_light", "targetname" );
	array_thread( ambient_flicker_lights, ::ambient_flicker_light_think );

	friendly_car_slide_trigger = GetEnt( "friendly_car_slide_trigger", "targetname" );
	friendly_car_slide_trigger thread friendly_car_slide_trigger();

	trigger_damages = GetEntArray( "trigger_damage", "targetname" );
	array_thread( trigger_damages, ::trigger_damage_think );

	battlechatter_off( "allies" );
	battlechatter_off( "axis" );

	flag_wait( "escape_the_gulag" );
	stumble_triggers = GetEntArray( "stumble_trigger", "targetname" );
	array_thread( stumble_triggers, ::stumble_trigger_think );

}


start_run()
{
	flag_set( "rescue_begins" );

	spawners = [];
	spawner = GetEnt( "price_spawner", "targetname" );
	spawners[ spawners.size ] = spawner;

	spawner = GetEnt( "endlog_soap_spawner", "targetname" );
	spawners[ spawners.size ] = spawner;

	spawner = GetEntArray( "endlog_redshirt_spawner", "targetname" )[ 0 ];
	spawners[ spawners.size ] = spawner;

	guys = array_spawn( spawners );
	player_org = getstruct( "ending_breach_org", "targetname" );

	level.player SetOrigin( player_org.origin );
	level.player SetPlayerAngles( player_org.angles );
	gulag_player_loadout();

	player_org thread anim_single( guys, "price_rescue" );
	wait( 0.05 );
	foreach ( guy in guys )
	{
		animation = guy getanim( "price_rescue" );
		guy SetAnimTime( animation, 0.75 );
	}

}

gulag_run_for_it()
{
	if ( level.script == "endlog" || level.start_point == "run" )
		wait( 0.05 );

	set_cafeteria_spotlight_dvars();

	// make the AI keep going if you try to stop them with ADS
	SetSavedDvar( "ai_friendlyFireBlockDuration", 0 );

	thread minor_earthquakes();

	hillside_brushmodels = GetEntArray( "hillside_brushmodel", "targetname" );
	foreach ( ent in hillside_brushmodels )
	{
		ent Hide();
	}

	hillside_models = GetEntArray( "hillside_model", "targetname" );
	foreach ( ent in hillside_models )
	{
		ent Hide();
	}

	//	level.player FreezeControls( true );
	// Task Force be advised, they've started the bombardment early – get the hell out of there now!	

	// level.player FreezeControls( false );

	orgs = getstructarray( "friendly_escape_org", "targetname" );
	orgs = array_index_by_parameters( orgs );

	//level.player AllowSprint( false );
	ai = GetAIArray( "allies" );
	colors = [];
	colors[ "soap" ] = ( 0, 1, 1 );
	colors[ "price" ] = ( 1.000000, 0.501961, 0.000000 );
	colors[ "redshirt" ] = ( 1.000000, 0.000000, 0.501961 );

	foreach ( guy in ai )
	{
		guy thread endlog_friendly_runout_settings();
		guy thread maps\_spawner::go_to_node( orgs[ guy.animname ], "struct" );
		//guy thread my_color_trail( colors[ guy.animname ] );
	}

	//thread chase_train(); // the cave in chases you

	thread ending_run_fx();
	thread cafe_fx();

	flag_init( "modify_ai_moveplaybackrate" );
	delayThread( 11.5, ::flag_set, "modify_ai_moveplaybackrate" );
	thread moderate_ai_moveplaybackrate();


	activate_trigger_with_targetname( "friendly_escape_trigger" );

	// Go go go! 	
	level.soap delayThread( 5, ::dialogue_queue, "gulag_cmt_gogogo1" );


	autosave_by_name( "run_autosave" );

	wait( 1 );

	ending_window_littlebird = GetEnt( "ending_window_littlebird", "script_noteworthy" );
	targ = getstruct( ending_window_littlebird.target, "targetname" );
	ending_window_littlebird.origin = targ.origin;


	flag_wait( "there_is_chopper" );

	// There’s the chopper!!! Get ready to jump!!!	
	level.soap thread dialogue_queue( "gulag_cmt_ready2jump" );

	flag_wait( "exit_collapses" );

	// Ahh, bollocks!!! Go back go back!!! We'll find another way out!!!	
	level.soap delayThread( 1.5, ::dialogue_queue, "gulag_cmt_anotherway" );

	noself_delayCall( 1.5, ::setsaveddvar, "player_sprintSpeedScale", level.default_sprint );
	SetSavedDvar( "player_sprintUnlimited", 1 );

	flag_set( "soap_speed_boost" );
	level.max_rocks = 1;
	quake( 0.25, 4, level.price.origin, 5000 );

	thread chase_train();// the cave in chases you
	wait( 0.2 );

	orgs = getstructarray( "friendly_changedirection_org", "targetname" );
	orgs = array_index_by_parameters( orgs );

	ducks = [];
	ducks[ "soap" ] = "reaction_180";
	ducks[ "redshirt" ] = "reaction_180";
	//ducks[ ducks.size ] = "run_180";
	index = 0;

	waits = [];
	waits[ "soap" ] = 0.0;
	waits[ "redshirt" ] = 0.45;
	waits[ "price" ] = 0.4;

	guys = [];
	guys[ "soap" ] = level.soap;
	guys[ "redshirt" ] = level.redshirt;
	guys[ "price" ] = level.price;

	foreach ( animname, guy in guys )
	{
		wait_time = waits[ animname ];
		duck = ducks[ animname ];
		guy delayThread( wait_time, maps\_spawner::go_to_node, orgs[ animname ], "struct" );
		if ( IsDefined( duck ) )
		{
			guy delayThread( wait_time, ::anim_generic_run, guy, duck );
		}
	}

	/*
	for ( i = 0; i < guys.size; i++ )
	{
		guy = guys[ i ];
		guy thread maps\_spawner::go_to_node( orgs[ guy.animname ], "struct" );

		if ( IsDefined( ducks[ index ] ) )
		{
			guy thread anim_generic_run( guy, ducks[ index ] );
		}

		time = waits[ index ];
		if ( IsDefined( time ) )
			wait( time );
		index++;
	}
	*/

	wait( 1 );
	level.max_rocks = 4;

	/*
	foreach ( guy in ai )
	{
		guy.sprint = true;
	}
	*/


	set_cafeteria_spotlight_dvars();
	flag_wait( "enter_final_room" );// ai trigger this

	thread cafe_lights_explode();
}

start_endshow()
{
	soap_spawner = GetEnt( "endlog_soap_spawner", "targetname" );
	soap = soap_spawner spawn_ai();

	price_spawner = GetEnt( "price_spawner", "targetname" );
	price = price_spawner spawn_ai();

	redshirt_spawner = GetEntArray( "endlog_redshirt_spawner", "targetname" );
	soldier = redshirt_spawner[ 0 ] spawn_ai();

	player = spawn_anim_model( "player_rig" );

	guys = [];
	guys[ guys.size ] = soap;
	guys[ guys.size ] = price;
	guys[ guys.size ] = soldier;
	guys[ guys.size ] = player;

	soap.animname = "gulag_end_animatic_soap";
	price.animname = "gulag_end_animatic_price";
	soldier.animname = "gulag_end_animatic_soldier";
	player.animname = "player_rig";

	create_dvar( "altview", 0 );

	if ( GetDvarInt( "altview" ) )
	{
		level.player SetOrigin( ( -4594, -765, 240 - 60 ) );
		level.player SetPlayerAngles( ( -21, -88, 0 ) );
	}
	else
	{
		level.player PlayerLinkToBlend( player, "tag_player", 0, 0, 0 );
	}

	level.player TakeAllWeapons();


	ent = GetEnt( "mound_scene_export", "targetname" );
	for ( ;; )
	{
		ent anim_single( guys, "ending" );
	}

/*
gulag_end_animatic_player" 
gulag_end_animatic_soldier"
gulag_end_animatic_price" ]
gulag_end_animatic_soap" ][
*/
}

start_cafeteria()
{

	friendly_escape_orgs = getstructarray( "start_cafe_friendly", "targetname" );
	orgs = array_index_by_parameters( friendly_escape_orgs );

	map_spawners_to_starts( orgs );

	ai = GetAIArray( "allies" );
	foreach ( guy in ai )
	{
		guy thread endlog_friendly_runout_settings();
	}


	player_org = getstruct( "start_cafe_player", "targetname" );
	level.player SetOrigin( player_org.origin );
	level.player SetPlayerAngles( player_org.angles );
	gulag_player_loadout();

	SetSavedDvar( "r_spotlightbrightness", "0.9" );
	SetSavedDvar( "r_spotlightendradius", "1200" );
	SetSavedDvar( "r_spotlightstartradius", "50" );
	//setsaveddvar( "r_spotlightfovinnerfraction", "0.7" );

	level.cafe_tables = GetEntArray( "cafe_table", "targetname" );
	array_thread( level.cafe_tables, ::cafe_table_think );
	cafe_table_orgs = getstructarray( "cafe_table_org", "targetname" );
	array_thread( cafe_table_orgs, ::cafe_table_org_think );

	cafe_table_eq_orgs = getstructarray( "cafe_table_eq_org", "targetname" );
	array_thread( cafe_table_eq_orgs, ::cafe_table_eq_org_think );


	thread cafe_lights_explode();


	hunted_swing_light = GetEnt( "hunted_swing_light", "targetname" );
//	thread hunted_swing_light_think( hunted_swing_light );

	//swing_lights = GetEntArray( "swing_light", "targetname" );
	//array_thread( swing_lights, ::swing_light_think );

	/*
	ending_window_littlebird = GetEnt( "ending_window_littlebird", "script_noteworthy" );
	heli = ending_window_littlebird spawn_vehicle();
	path = heli vehicle_get_path_array();
	
	heli Delete();
	wait( 0.05 );
	heli = ending_window_littlebird spawn_vehicle();
	path = heli vehicle_get_path_array();
	*/

	//thread gulag_glass_shatter();
}

gulag_cafeteria()
{
	/*
	level.soap ent_flag_wait( "run_into_room" );
	level.price ent_flag_wait( "run_into_room" );
	level.redshirt ent_flag_wait( "run_into_room" );
	*/

	set_cafeteria_spotlight_dvars();

	level.soap notify( "stop_going_to_node" );
	level.price notify( "stop_going_to_node" );
	level.redshirt notify( "stop_going_to_node" );

	guys = [];
	guys[ "soap" ] = level.soap;
	guys[ "price" ] = level.price;
	guys[ "redshirt" ] = level.redshirt;

	foreach ( ai in guys )
	{
		ai.grenadeawareness = 0;

		if ( !isdefined( ai.magic_bullet_shield ) )
			ai thread magic_bullet_shield();

		ai.IgnoreRandomBulletDamage = true;
		ai.attackeraccuracy = 0;
	}

	priceRed = [];
	priceRed[ priceRed.size ] = level.price;
	priceRed[ priceRed.size ] = level.redshirt;

	ent = GetEnt( "mound_scene_export", "targetname" );
	ent thread anim_reach( guys, "cafe_entrance" );


	anim_post = spawn_anim_model( "post" );
	anim_post Hide();
	ent anim_first_frame_solo( anim_post, "gate" );

	evac_post = GetEnt( "gulag_post_slab", "targetname" );
	evac_post NotSolid();
	evac_post add_target_pivot();
	evac_post CastShadows();
	evac_post.pivot LinkTo( anim_post, "body_animate", ( 0, 0, 0 ), ( 0, 0, 0 ) );

	flag_wait( "match_up_for_final_room" );

	if ( level.start_point != "cafe" )
		ent anim_reach_together( guys, "cafe_entrance" );

	level notify( "cafeteria_sequence_begins" );

	foreach ( ai in guys )
	{
		ai.moveplaybackrate = 1;
	}

	player_gets_hit_by_rock();

	// It's a dead end!!!	
	level.redshirt thread dialogue_queue( "gulag_wrm_deadend" );

	// We can't go back that way!!! Let's try to get these doors open!!!	
//	level.price delayThread( 2.2, ::anim_single_solo, level.price, "gulag_pri_doorsopen" );

	delayThread( 1.5, ::soap_talks_to_heli );

	level.timer = GetTime();
	for ( i = 0; i < 3; i++ )
	{
		delayThread( 4.7, ::exploder, "end_scene_rock" );
	}
	delayThread( 4.75, ::exploder, "end_scene_rock" );
	delayThread( 4.85, ::exploder, "end_scene_rock" );

	ent thread anim_single( guys, "cafe_entrance" );
	wait( 4.2 );


	quake( 0.25, 4, level.player.origin, 5000 );


	wait( 0.05 );

	wait( 2 );

	delayThread( 1, ::flag_set, "player_falls_down" );

	// roach is down!
	level.soap delaythread( 2, ::dialogue_queue, "gulag_cmt_roachisdown" );
	// roach!!
	level.soap delaythread( 3.1, ::dialogue_queue, "gulag_cmt_roach" );

	wait( 2 );

	flag_waitopen( "player_falls_down" );// during cafeteria ending
}



start_evac()
{
	spawner = GetEnt( "price_spawner", "targetname" );
	spawner spawn_ai();

	spawner = GetEnt( "endlog_soap_spawner", "targetname" );
	spawner spawn_ai();

	spawner = GetEntArray( "endlog_redshirt_spawner", "targetname" )[ 0 ];
	spawner spawn_ai();

}

drawAnimTimes( guys, anime )
{
	for ( ;; )
	{
		PrintLn( " " );
		foreach ( guy in guys )
		{
			animation = guy getanim( anime );
			time = guy GetAnimTime( animation );
			PrintLn( guy.animname + " " + time );
		}
		wait( 0.05 );
	}
}

gulag_evac()
{
//	delayThread( 2.0, ::play_sound_in_space, "scn_gulag_wall_explosion_short_a", level.soap.origin );

	level.player SetMoveSpeedScale( 1 );
	// clear the gate sequence from cafe
	ai = GetAIArray( "allies" );
	foreach ( guy in ai )
	{
		guy anim_stopanimscripted();
	}

	flag_set( "time_to_evac" );
	level.player SetBlurForPlayer( 0, 1 );

	level.player PlayerSetGroundReferenceEnt( undefined );

	level notify( "stop_cavein" );
	SetSavedDvar( "r_spotlightbrightness", 0.6 );
	SetSavedDvar( "g_friendlyNameDist", 0 );
	if ( level.start_point == "evac" )
		wait( 0.05 );// for bug in doing animscripted on first frame of ai

	level.fx_fall_time = 0.1;
	black_overlay = create_client_overlay( "black", 0, level.player );
	black_overlay.alpha = 1;

	if ( isdefined( level.black_overlay ) )
		level.black_overlay.alpha = 0;

	level.player AllowCrouch( false );
	level.player AllowProne( false );
	wait( 5.2 );// should be 2 seconds but the fx take forever to clear

	thread evac_slowmo();
	thread evac_dof();


	black_overlay FadeOverTime( 2 );
	black_overlay.alpha = 0;

	SetSavedDvar( "compass", "0" );
	SetSavedDvar( "ammoCounterHide", 1 );
	SetSavedDvar( "hud_showStance", 0 );
	SetSavedDvar( "hud_drawhud", 0 );

	player_rig = spawn_anim_model( "player_rig" );
	//player_rig thread maps\_debug::drawTagForever( "tag_player" );
	//player_rig Hide();
	extra_player_rig = spawn_anim_model( "player_rig" );
	extra_player_rig Hide();


	level.player_rig = player_rig;
	player_carabiner = spawn_anim_model( "player_carabiner" );
	ent = GetEnt( "mound_scene_export", "targetname" );


	level.soap forceUseWeapon( "m4m203_acog", "primary" );

	guys = [];
//	guys[ guys.size ] = level.soap;
	guys[ "price" ] = level.price;
	guys[ "redshirt" ] = level.redshirt;
	guys[ "player_rig" ] = player_rig;

	anim_rock = spawn_anim_model( "rock" );
	anim_rock Hide();
	guys[ "anim_rock" ] = anim_rock;


	thread maps\_ambient::use_eq_settings( "gulag_exit", level.eq_main_track );
	delayThread( 0, maps\_ambient::blend_to_eq_track, level.eq_main_track, 2 );


	pavelow = spawn_anim_model( "pavelow" );
	guys[ "pavelow" ] = pavelow;

	ending_rope = spawn_anim_model( "ending_rope" );
	level.rope = ending_rope;

	guys[ "ending_rope" ] = ending_rope;

	guys[ "ending_rope" ] MakeUsable();

	// script brushmodel rock
	evac_rock = GetEnt( "evac_rock", "targetname" );
	evac_rock add_target_pivot();
	evac_rock CastShadows();
	//evac_rock Hide();
	evac_rock.pivot LinkTo( anim_rock, "body_animate", ( 0, 0, 0 ), ( 0, 0, 0 ) );

	arcRight = 15;
	arcLeft = 15;
	arcTop = 15;
	arcBottom = 15;

	thread maps\_autosave::_autosave_game_now_nochecks();

	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 0, 0, 0, 0, true );

	level.player TakeAllWeapons();

	exploder( "bomb_exploder" );
	delayThread( 20, ::exploder, "evac_exploder" );

	SoundSetTimeScaleFactor( "mission", 0 );
	SoundSetTimeScaleFactor( "announcer", 0 );


	ent anim_first_frame_solo( extra_player_rig, "fly_away" );
	ent delayThread( 20.16, ::anim_single_solo, extra_player_rig, "fly_away" );

	evac_time = GetTime();
	ent thread anim_single( guys, "evac" );

	//wait( 0.6 );

	ent thread anim_single_solo( level.soap, "evac" );
	flag_set( "evac_begins" );

	// Two-One, I see your flare. SPIE rig coming down.	
	delayThread( 5.7, ::radio_dialogue, "gulag_plp_seeflare" );


	//thread drawAnimTimes( guys, "evac" );

	level.soap thread soap_sets_played_pulled_flag();

	//setsaveddvar( "cg_fov", 50 );

	player_rig waittillmatch( "single anim", "end" );
	level.player Unlink();
	level.player AllowCrouch( true );
	level.player AllowProne( true );
	SetSavedDvar( "g_friendlyNameDist", 175 );
	thread blend_in_player_movespeed();


	//thread lerp_fov_overtime( 3, 65 );

	player_rigs = [];
	player_rigs[ "carabiner" ] = player_carabiner;
	player_rigs[ "rig" ] = player_rig;


	ent anim_first_frame( player_rigs, "hookup" );
	//player_Rig thread maps\_debug::drawTagForever( "tag_player" );
	player_rig Hide();
	player_carabiner Hide();

	tag_origin = spawn_tag_origin();
	tag_origin LinkTo( extra_player_rig, "tag_player", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	//tag_origin thread maps\_debug::drawTagForever( "tag_origin" );

	trigger = getEntWithFlag( "player_uses_rig" );

	// Press and hold^3 &&1 ^7to clip on.
	trigger SetHintString( &"GULAG_HOLD_1_TO_SPIE" );

	SetSavedDvar( "hud_drawhud", 1 );

	flag_wait( "player_uses_rig" );

	trigger trigger_off();
	SetSavedDvar( "r_spotlightbrightness", 0 );
	/*
	// player gets close enough
	for ( ;; )
	{
		if ( Distance( level.player.origin, level.soap.origin ) < 64 )
			break;
		wait( 0.05 );
	}
	*/

	level.player AllowCrouch( false );
	level.player AllowProne( false );


	if ( IsDefined( level.soap.got_player_notetrack ) )
	{
		// too late to hookup
		return;
	}

	


	time_passed = GetTime() - evac_time;
	time_passed *= 0.001;
	player_linked = false;
	if ( time_passed < 18 )
	{
		player_linked = true;
		time = 0.5;
		level.player PlayerLinkToBlend( player_rig, "tag_player", time, time * 0.4, time * 0.4 );
		delayThread( time, ::player_gets_groundref_and_opens_fov, tag_origin, player_rig );

//	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 45, 45, 90, 45 );
	//level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 0,0,0,0 );
	//time = 1;
	//level.player PlayerLinkToBlend( player_rig, "tag_player", time, time * 0.4, time * 0.4 );


		thread player_hooks_up( ent, player_rigs );
	}


	flag_wait( "player_gets_pulled" );

	player_rig Hide();

	SetSavedDvar( "g_friendlyNameDist", 0 );

	ent notify( "stop_loop" );
	level.player notify( "stop_opening_fov" );

	if ( !player_linked )
	{
		time = 0.5;
		level.player PlayerLinkToBlend( extra_player_rig, "tag_player", time, time * 0.4, time * 0.4 );
		//thread player_view_goes_to_zero_then_opens( extra_player_rig, "tag_player", time );
		delayThread( time, ::player_gets_groundref, tag_origin, extra_player_rig );
	}
	else
	{
		thread wait_then_player_view_goes_to_zero_then_opens( extra_player_rig, 1.5 );
	}
	
	/*
	// in case we didn't finish lerping
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 45, 45, 90, 45, true );
	level.player LerpViewAngleClamp( 2, 0.5, 0.5, 0, 0, 0, 0 );
	*/

	level.price delaycall( 5.05, ::playsound, "gulag_pri_yes" );

	ent thread anim_single_solo( player_rig, "fly_away" );
	thread fly_away_rumble();

	thread swap_world_fx();
	delayThread( 3.0, maps\_utility::vision_set_fog_changes, "gulag_circle", 2.2 );

	animation = player_rig getanim( "fly_away" );
	level.player SetEqLerp( 1, level.eq_main_track );
	thread maps\_ambient::use_eq_settings( "gulag_ending_fadeout", level.eq_mix_track );
	wait( 7.85 );

//	wait( 1.5 );	
	
	// set up the mix track we're going to blend to
//	level.player SetEqLerp( 1, level.eq_main_track );
	level.player thread maps\_ambient::blend_to_eq_track( 1, 0.5 );
	//level.player SetEqLerp( 1, level.eq_mix_track );

	

	black_overlay = create_client_overlay( "black", 0, level.player );
	black_overlay.alpha = 1;


	nextmission();
}

fly_away_rumble()
{
	wait( 1 );
	PlayRumbleOnPosition( "heavy_3s", level.player.origin );
	level.player PlayRumbleOnEntity( "damage_heavy" );
	level.player PlayRumbleLoopOnEntity( "light_1s" );
}

wait_then_player_view_goes_to_zero_then_opens( extra_player_rig, time )
{
	flag_wait( "player_evac" );
	player_view_goes_to_zero_then_opens( extra_player_rig, time );
}

player_view_goes_to_zero_then_opens( extra_player_rig, time )
{
	level.player PlayerLinkToBlend( extra_player_rig, "tag_player", time, time * 0.4, time * 0.4 );
	wait( time );
	arc = 18;
	level.player PlayerLinkToDelta( extra_player_rig, "tag_player", arc, arc, arc, arc, true );
}

player_gets_groundref_and_opens_fov( tag_origin, player_rig )
{
	level.player PlayerSetGroundReferenceEnt( tag_origin );
	wait( 1 );
	open_up_fov( 0.5, player_rig, "tag_player", 45, 45, 90, 15 );
}

player_gets_groundref( tag_origin, player_rig )
{
	level.player PlayerSetGroundReferenceEnt( tag_origin );
}


player_hooks_up( ent, player_rigs )
{
	if ( flag( "player_gets_pulled" ) )
		return;

	level endon( "player_gets_pulled" );
	wait( 0.3 );
//	wait( 1 );
//	thread orient_player_to_rig( player_rig );

	player_rigs[ "carabiner" ] Show();
	player_rigs[ "rig" ] Show();
	ent anim_single( player_rigs, "hookup" );
	ent anim_loop_solo( player_rigs[ "rig" ], "idle" );
}

soap_sets_played_pulled_flag()
{
	flag_init( "player_gets_pulled" );
	self waittillmatch( "single anim", "player" );
	flag_set( "player_gets_pulled" );
}


gulag_ending_startpoint_catchup_thread()
{
	waittillframeend;// let the actual start functions run before this one
	start = level.start_point;

	if ( is_default_start() )
		return;

	remove_global_spawn_function( "allies", ::enable_cqbwalk );

	if ( start == "rescue" )
		return;

	flag_clear( "enable_interior_fx" );
	flag_set( "rescue_begins" );
	flag_set( "escape_the_gulag" );

	wait( 0.05 );
	DisableForcedSunShadows();// lets get some sunlight in here

	delayThread( 0.1, ::vision_set_fog_changes, "gulag_ending", 0 );

	if ( level.script != "endlog" )
	{
		volume = GetEnt( "gulag_endlog_destructibles", "script_noteworthy" );
		volume activate_destructibles_in_volume();
		volume activate_interactives_in_volume();
	}

	if ( start == "run" )
		return;

	thread minor_earthquakes();
	thread cafe_fx();

	set_new_ending_fx_dists();
	flag_set( "enter_final_room" );
	flag_set( "exit_collapses" );
	flag_set( "match_up_for_final_room" );
	flag_set( "big_earthquake_hits" );

	wait( 0.05 );
	level.price forceUseWeapon( "ak47", "primary" );

	level notify( "skip_stumble_trigger_think" );
	
	if ( start == "cafe" )
		return;

	level notify( "stop_minor_earthquakes" );

	level.player TakeAllWeapons();
	flag_set( "player_falls_down" );
	if ( start == "evac" )
		return;


	AssertMsg( "Didn't handle start point " + start );
}
