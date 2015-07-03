#include maps\_utility;
#include maps\_vehicle;
#include maps\_anim;
#include maps\_blizzard;
#include common_scripts\utility;
#include maps\_hud_util;
#include maps\_stealth_utility;
#include maps\_vehicle_spline;
#include maps\cliffhanger_code;
#include maps\cliffhanger_stealth;
#include maps\cliffhanger;
#include maps\cliffhanger_snowmobile_code;

/************************************************************************************************************/
/*													SNOWMOBILE												*/
/************************************************************************************************************/

start_tarmac()
{
	level.moto_drive = false;
	if ( getdvar( "moto_drive" ) == "" )
		setdvar( "moto_drive", "0" );
	/*
	bike_animations();
	bike_driver_animations();
	bike_rider_animations();
	*/
	start_common_cliffhanger();
	friendly_init_cliffhanger();

	spawners = getentarray( "enemy_snowmobile_chase_spawner", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, ::enemy_snowmobile_chase_spawner_think );
	array_thread( spawners, ::spawn_ai );

	node = getent( "price_snowmobile_start", "targetname" );
	level.price forceTeleport( node.origin, node.angles );
	level.price setgoalpos( node.origin );
	level.price.ignoreall = true;
	level.price.ignoreRandomBulletDamage = true;

	node = getent( "player_snowmobile_start", "targetname" );
	level.player setorigin( node.origin );
	level.player setplayerangles( node.angles );
	flag_set( "hanger_reinforcements" );
}

price_reaches_slide_start()
{
	price_slide_catchup = getnode( "price_slide_catchup", "targetname" );
	if ( flag( "player_slides_down_hill" ) )
	{
		// player already slide down hill so skip ahead
		level.price teleport_ent( price_slide_catchup );
	}	
	
	node = getent( "cliffhanger_slide", "targetname" );
	node thread anim_reach_solo( level.price, "hill_slide" );
	level.price endon( "goal" );
	
	flag_wait( "player_slides_down_hill" );
	
	// north of the node? then teleport
	if ( level.price.origin[ 1 ] > price_slide_catchup.origin[ 1 ] )
	{
		// player already slide down hill so skip ahead
		level.price teleport_ent( price_slide_catchup );
	}
	level.price waittill( "goal" );
}

price_makes_for_his_mobile()
{
	node = getent( "cliffhanger_slide", "targetname" );

	price_reaches_slide_start();
	
	// the anim lacks the notetrack
	level.price delayThread( 1, animscripts\shared::noteTrackPoseCrouch );
	flag_set( "price_reaches_bottom" );
	level.price disable_surprise();
	node anim_single_solo( level.price, "hill_slide" );
}

hill_attackers_spawn()
{

	ai = getaiarray( "axis" );
	foreach ( guy in ai )
	{
		guy kill();
	}

	hill_attack_spawners = getentarray( "hill_attack_spawner", "targetname" );
	array_thread( hill_attack_spawners, ::spawn_ai );
	
	delaythread( 25, ::flag_set, "clifftop_snowmobile_guys_die" );

	for ( ;; )
	{
		if ( level.cliffdeaths >= 3 )
			break;
		level waittill( "cliff_death" );
		waittillframeend; // for a chance for cliffdeaths to get increments
	}

	if ( !flag( "clifftop_snowmobile_guys_die" ) )
	{
		flag_set( "clifftop_snowmobile_guys_die" );
		wait( 0.15 );
	}

	clifftop_mobile_spawners = getentarray( "clifftop_mobile_spawner", "targetname" );
	array_thread( clifftop_mobile_spawners, ::clifftop_mobile_spawner_think );

	wait( 2 );
	flag_set( "cliff_guys_all_dead" );
	level.price_prep_time = gettime();
	/*
	for ( ;; )
	{
		if ( level.cliffdeaths >= 4 )
			break;
		level waittill( "cliff_death" );
		waittillframeend; // for a chance for cliffdeaths to get increments
	}
	*/

	price_icepicks_a_snowmobile();
}

cover_price()
{
	setObjectiveOnEntity( "obj_exfiltrate", level.price );
	setObjective_pointerText( "obj_exfiltrate", &"SCRIPT_WAYPOINT_COVER" );
}

go_to_mig()
{
	mig_obj_struct = getstruct( "mig_obj_struct", "targetname" );
	org = mig_obj_struct.origin;

	objective = "obj_exfiltrate";

	setObjectiveLocation( objective, org );
	setObjective_pointerText( objective, "" );
	level thread player_is_protected_on_trip_to_objective( objective, org );
}

go_to_slide()
{
	final_obj_struct = getstruct( "final_obj_struct", "targetname" );
	org = final_obj_struct.origin;
	
	objective = "obj_exfiltrate";
	
	setObjectiveLocation( objective, org );
	setObjective_pointerText( objective, "" );
	level thread player_is_protected_on_trip_to_objective( objective, org );
}

price_got_new_colornode( node )
{
	self notify( "new_node_orders" );
	self endon( "new_node_orders" );
	remark_func = undefined;
	
	if ( gettime() > self.next_comment_time )
	{
		// haven't spoken in awhile so it's ok to make a comment about what I'm doing
		remark = undefined;

		switch( node.script_noteworthy )
		{
			case "central_jeeps":
				// “I’m heading for those jeeps, cover me!”
				remark = "headingforjeeps";
				remark_func = ::cover_price;
				 
				break;

			case "last_mig":
				// “I’ll make a run for the next MiG! Give me some covering fire!”
				remark = "runtonextmig";
				remark_func = ::cover_price;
				break;

			case "final_spot":
				// “Cover me, I’m making a break for it!”
				remark = "makingabreak";
				remark_func = ::cover_price;
				break;
		}

		if ( isdefined( remark ) )
		{
			self thread dialogue_queue( remark );
			if ( isdefined( remark_func ) )
			{
				delaythread( 1.5, remark_func );
				remark_func = undefined;
			}
			
			set_next_comment_time();
		}
	}

	self waittill( "goal" );

	remarks = [];
	// got to my node before the player so tell him to go
	switch( node.script_noteworthy )
	{
		case "cinderblock_wall":
			wait( 0.5 );
			// “Soap, make a run for that MIG to the east!”
			//remarks[ remarks.size ] = "runformigeast";
			// “To the east, soap! Go!”
			remarks[ remarks.size ] = "eastgo";
			// “Head for that MiG, I’ll cover you!”
			remarks[ remarks.size ] = "headformig";
			
			remark_func = ::go_to_mig;
			break;

		case "central_jeeps":
		case "last_mig":
		case "final_spot":
			// “All right, let’s go!”
			remarks[ remarks.size ] = "allright";
			// “I’ll cover you! Come to me!”
			remarks[ remarks.size ] = "cometome";
			// “To the east, soap! Go!”
			remarks[ remarks.size ] = "eastgo";
			// “I’ve got you covered Soap! Move up! Move up!”
			remarks[ remarks.size ] = "moveup";

			remark_func = ::go_to_slide;
			break;
	}

	if ( !remarks.size )
		return;

	for ( ;; )
	{
		wait( 2 );
		self.speak_index++;
		if ( self.speak_index >= remarks.size )
			self.speak_index = 0;

		remark = remarks[ self.speak_index ];

		set_next_comment_time();
		
		if ( isdefined( remark_func ) )
		{
			delaythread( 1.5, remark_func );
			remark_func = undefined;
		}

		self dialogue_queue( remark );

		wait randomfloatrange( 5, 7 );
	}
}

set_next_comment_time()
{
	base = 4800;
	range = 1800;
	if ( level.gameskill >= 2 )
	{
		base += 2500;
	}
	
	self.next_comment_time = gettime() + randomfloatrange( base, base + range );
}

clifftop_mobile_spawner_think()
{
	self thread add_spawn_function( ::icepick_vehicle_think );
//	self script_delay();
	if ( isdefined( self.script_delay ) )
	{
		self.script_delay = undefined;
		flag_wait( "cliff_guys_all_dead" );
	}

	self thread spawn_vehicle_and_gopath();
}


price_warns_about_snowmobiles()
{
	flag_wait( "tarmac_snowmobiles_spawned" );
	
	start_time = gettime();
	for ( ;; )
	{
		if ( gettime() > start_time + 2500 )
			return;
		if ( !level.price.function_stack.size )
			break;
		
		wait( 0.05 );
	}
	
		
	// “Snowmobiles! Take ‘em out!!”
	level.price thread dialogue_queue( "snowmoibles" );
}

price_progress_trigger_think()
{
	self waittill( "trigger" );
	level.price.position = self.script_noteworthy;
}

price_navigates_tarmac_and_calls_to_player()
{
	assertex( !flag( "player_slides_down_hill" ), "How did this flag get set so early?" );
	level endon( "player_slides_down_hill" );
	tarmac_destination = getent( "tarmac_destination", "targetname" );

	level.player.position = "hanger";
	player_position_triggers = getentarray( "player_position_trigger", "targetname" );
	array_thread( player_position_triggers, ::track_player_position );

	price_progress_triggers = getentarray( "price_progress_trigger", "targetname" );
	array_thread( price_progress_triggers, ::price_progress_trigger_think );

	price = level.price;
	node = getnode( "price_tarmac_path", "targetname" );
	price.position = node.script_noteworthy;

	price disable_ai_color();
	price setgoalnode( node );
	price.goalradius = 64;
	price.fixedNode = true;
	price.fixedNodeSafeRadius = 0;

	if ( is_e3_start() )
	{
		wait( 2 );
	}
	else
	{
		if ( level.player.position == "hanger" )
			wait( 5 );
	}
	
	flag_set( "escape_with_soap" );
	
	
	// “Stay close and hug the wall! We’ll use the MiGs for cover and cross the tarmac to the southeast!”
	price dialogue_queue( "hugthewall" );

	if ( is_e3_start() )
	{
		wait( 1.2 );
	}
	else
	{
		buffer_start = gettime();
	
		// first_corner endon conditions: player leaves hanger, enemies die
		price wait_until_player_leaves_hanger_or_enemies_recede( node );
	
		if ( level.player.position == "hanger" )
		{
			wait_for_buffer_time_to_pass( buffer_start, 5 );
		}
	}

	price.grenadeawareness = 0;
	//Soap! Follow me! Let's go!!!

	price.speak_index = 0;
	price.next_comment_time = 0;

	thread autosave_by_name( "hugthewall" );
	level.player.baseIgnoreRandomBulletDamage = true;	
	level.player.IgnoreRandomBulletDamage = true;
	
	price thread player_is_protected_on_trip_to_objective( "obj_exfiltrate" );
	
	price.colornode_func = ::price_got_new_colornode;
	price thread dialogue_queue( "follow_me" );
	activate_trigger_with_targetname( "price_tarmac_run_trigger" );
	level.price set_force_color( "b" );
	flag_wait( "price_ready_to_slide" );
	
	level notify( "new_player_protection_trip" );	
	
	setObjectiveOnEntity( "obj_exfiltrate", level.price );
	setObjective_pointerText( "obj_exfiltrate", "" );
	
	
	price.colornode_func = undefined;
	price notify( "new_node_orders" ); // stop any more color talking
	price disable_ai_color();
}

price_yells_for_player_to_come_from_positions( positions, op_timer )
{
	// is the player at one of these positions?
	if ( !isdefined( positions[ level.player.position ] ) )
		return;

	self endon( "player_left_bad_positions" );
	self add_wait( ::waittill_player_not_position, positions );
	self add_func( ::send_notify, "player_left_bad_positions" );
	self add_endon( "next_goal" );
	self thread do_wait();

	if ( isdefined( op_timer ) )
		wait( op_timer );

	wait( 4 );
}

wait_for_player_to_leave_position( position, remarks )
{
	thread remind_player_where_to_go( remarks );
	for ( ;; )
	{
		if ( level.player.position != position )
			break;
		level waittill( "new_player_position" );
	}

	self notify( "player_moved_on" );
}

remind_player_where_to_go( remarks )
{
	self endon( "player_moved_on" );
	index = 0;
	for ( ;; )
	{
		wait( 2 );
		remark = remarks[ index ];
		self dialogue_queue( remark );
		index++;
		if ( index >= remarks.size )
			index = 0;
		wait randomfloatrange( 5, 7 );
	}
}

price_yells_for_player_to_come_to_positions( positions, op_timer )
{
	// is the player at one of these positions?
	if ( isdefined( positions[ level.player.position ] ) )
		return;

	self endon( "player_reached_good_position" );
	self add_wait( ::waittill_player_position, positions );
	self add_func( ::send_notify, "player_reached_good_position" );
	self add_endon( "next_goal" );
	self thread do_wait();

	if ( isdefined( op_timer ) )
		wait( op_timer );

	wait( 4 );
}


wait_until_player_leaves_hanger_or_enemies_recede( node )
{
	level endon( "time_to_leave_hanger" );
	node endon( "enemies_receded" );

	thread detect_enemies_recede( node );
	positions = [];
	positions[ "hanger" ] = true;
	position = waittill_player_not_position( positions );
}

detect_enemies_recede( node )
{
	// if the enemies are all suppressed or dead/dying, then its time to go
	if ( !isdefined( node.target ) )
		return;

	volume = getent( node.target, "targetname" );
	if ( !isdefined( volume ) )
		return;

	for ( ;; )
	{
		if ( enemies_receded( volume ) )
			break;
		wait( 1.5 );
	}

	node notify( "enemies_receded" );
}

enemies_receded( volume )
{
	ai = getaiarray( "axis" );
	foreach ( guy in ai )
	{
		if ( !guy istouching( volume ) )
			continue;

		if ( guy doingLongDeath() )
			continue;

		if ( isdefined( guy.a.coverMode ) && guy.a.coverMode == "hide" )
			continue;

		if ( guy issuppressed() )
			continue;

		return false;
	}
	return true;
}

waittill_player_position( positions )
{
	for ( ;; )
	{
		level waittill( "new_player_position", position );
		if ( isdefined( positions[ position ] ) )
			return;
	}
}

waittill_player_not_position( positions )
{
	if ( !isdefined( positions[ level.player.position ] ) )
		return;

	for ( ;; )
	{
		level waittill( "new_player_position", new_position );
		if ( !isdefined( positions[ level.player.position ] ) )
			return;
	}
}

price_icepicks_a_snowmobile()
{
	level.price.baseAccuracy = 1;

	org = getent( "price_icepick_snowmobile_org", "targetname" );
	spawners = getentarray( "snowmobile_icepick_spawner", "targetname" );
	snowmobile = spawn_anim_model( "snowmobile" );
	snowmobile hide();

	point = GetStartOrigin( org.origin, org.angles, level.price getAnim( "icepick_fight" ) );
	//Print3d( point, "x", (1,0.5,0), 1, 2, 5000 );

	spawners[0].animname = "passenger";
	//spawners[1].animname = "driver";
	spawners[ 1 ] delete();
	spawners[ 1 ] = undefined;

	org anim_teleport( spawners, "icepick_fight" );
	org anim_reach_and_approach_solo( level.price, "icepick_fight", undefined, "Cover Right" );

	// wait until at least 2 seconds have passed
	wait_for_buffer_time_to_pass( level.price_prep_time, 3.5 );

	guys = get_guys_with_targetname_from_spawner( "snowmobile_icepick_spawner" );
//	assert( guys.size == 2 );

	passenger = guys[0];
	//driver = guys[1];
	passenger.animname = "passenger";
	//driver.animname = "driver";

	player_snowmobile_spawner = getent( "player_snowmobile_spawner", "targetname" );
	player_snowmobile_spawner.origin = snowmobile.origin;
	player_snowmobile_spawner.angles = snowmobile.angles;

	snowmobile = player_snowmobile_spawner spawn_vehicle();
	snowmobile.animname = "snowmobile";

	all_guys = [];
	all_guys[ all_guys.size ] = level.price;
	all_guys[ all_guys.size ] = passenger;
	all_guys[ all_guys.size ] = snowmobile;

	//driver linkto( snowmobile, "TAG_BODY", (0,0,0), (0,0,0) );
	//driver thread snowmobile_driver_handles_death();
	//driver.a.special = "snowmobile";
	//snowmobile thread anim_single_solo( driver, "icepick_fight","TAG_BODY" );
	org anim_single( all_guys, "icepick_fight" );
	/*
	if ( isalive( driver ) )
	{
		driver.a.special = "none";
		driver unlink();
		driver waittill( "death" );
	}
	*/

	wait( 0.75 );
	

	level.player_snowmobile = snowmobile;
	snowmobile thread maps\_snowmobile_drive::drive_vehicle();
	level.player_snowmobile thread remind_player_to_get_on_snowmobile();

	thread friendlies_get_on_snowmobile();
	flag_set( "player_snowmobile_available" );

	level.player_snowmobile waittill( "vehicle_mount", otherEnt );
	
	level.price add_damage_function( ::penalize_player_for_running_over_price );
	
	ai = getaiarray( "axis" );
	foreach ( guy in ai )
	{
		delay = randomfloat( 2 );
		guy delaythread( delay, ::kill_near_player );
	}
	
	assert( otherEnt == level.player );

	player_snowmobile_block = getent( "player_snowmobile_block", "targetname" );
	player_snowmobile_block delete();


	waittillframeend; // for the mount vehicle to finish.
	flag_set( "player_rides_snowmobile" );
}

penalize_player_for_running_over_price( damage, attacker, direction_vec, point, type, modelName, tagName )
{
	if ( !isdefined( level.player.vehicle ) )
		return;
	if ( attacker != level.player.vehicle )
		return;
		
	setdvar( "ui_deadquote", &"CLIFFHANGER_RUN_OVER" );
	missionfailedwrapper();
}

remind_player_to_get_on_snowmobile()
{
	level.player_snowmobile endon( "vehicle_mount" );
	for ( ;; )
	{
		// Soap, take that snowmobile! Let's get the hell out of here!
		level.price thread dialogue_queue( "cliff_pri_takesnowmobile" );
		wait( randomfloatrange( 9, 14 ) );

		// Soap! Get on that snowmobile let's go!
		level.price thread dialogue_queue( "cliff_pri_snowmobileletsgo" );
		wait( randomfloatrange( 9, 14 ) );
	}
}

kill_near_player()
{
	if ( distance( self.origin, level.player.origin ) < 512 )
		self kill();
}

snowmobile_driver_handles_death()
{
	self endon( "death" );
	self.allowdeath = true;
	self.health = 25;

	self waittillmatch( "single anim", "end" );
	self clear_deathanim();
}

friendlies_get_on_snowmobile()
{
	level.price.ignoreme = false;
	level.price.ignoreall = false;
	level.price.ignoreRandomBulletDamage = false;

	if ( !level.icepick_snowmobiles.size )
		level waittill( "new_icepick_snowmobile" );
	
	assertex( isdefined( level.price_snowmobile ), "Pricemobile aint defined" );
	npc_snowmobile = level.price_snowmobile;
	npc_snowmobile setcandamage( false );
	npc_snowmobile.player_offset = 250;
	level.price.sprint = true;
	level.price.baseAccuracy = 50;

	foreach ( guy in level.price_snowmobile_riders )
	{
		if ( !isalive( guy ) )
			continue;
		guy.threatbias = 50000;
	}
	wait_for_riders_to_die();


	// wait for price's vehicle to stop, note he hasn't gotten on it yet
	while ( level.price_snowmobile.veh_speed > 0 )
		wait( 0.05 );

	// clear the riders so price can get on
	npc_snowmobile.riders = [];
	foreach ( index, _ in npc_snowmobile.usedPositions )
	{
		npc_snowmobile.usedPositions[ index ] = false;
	}

	level.price disable_surprise();
	price_gets_on_snowmobile( npc_snowmobile );
	level.price.baseAccuracy = 1;

	foreach ( rider in level.price_snowmobile_riders )
	{
		if ( isalive( rider ) )
			rider delete();
	}

	if ( !npc_snowmobile.riders.size )
	{
		// Price hasn't got on yet, so force him on
		npc_snowmobile thread anim_generic( level.price, "snowmobile_driver_mount_dir1_short", "tag_driver" ); // but enter script state before
		npc_snowmobile thread maps\_vehicle_aianim::guy_enter( level.price );
	}

	//npc_snowmobile Vehicle_SetSpeed( 70, 35, 35 );
	//level.gaz.baseAccuracy = 0;
	price_snowmobile_path = getvehiclenode( "price_snowmobile_path", "targetname" );
	//npc_snowmobile attachPath( price_snowmobile_path );


	//npc_snowmobile.veh_pathtype = "constrained";
	npc_snowmobile startPath( price_snowmobile_path );
	npc_snowmobile.target = price_snowmobile_path.targetname;
	npc_snowmobile thread getonpath( true );
	npc_snowmobile Vehicle_SetSpeedImmediate( 15, 5, 5 );
	//npc_snowmobile thread gopath( npc_snowmobile );

	npc_snowmobile thread price_leads_player_to_heli();

	level.price remove_damage_function( ::penalize_player_for_running_over_price );

	wait( 1 );
	npc_snowmobile resumespeed( 5 );
	flag_wait( "player_rides_snowmobile" );
	npc_snowmobile.veh_pathtype = "constrained";
	
//	level.price.ignoreme = true;

//	level.price.ignoreall = true;

}

wait_for_riders_to_die()
{
	level endon( "player_starts_snowmobile_trip" );
	if ( flag( "player_starts_snowmobile_trip" ) )
		return;

	foreach ( rider in level.price_snowmobile_riders )
	{
		if ( isalive( rider ) )
			rider waittill( "death" );
	}
}

price_gets_on_snowmobile( npc_snowmobile )
{
	level endon( "player_starts_snowmobile_trip" );
	if ( flag( "player_starts_snowmobile_trip" ) )
		return;

	price_snowmobile_run_path = getnode( "price_snowmobile_run_path", "targetname" );
//	level.price maps\_spawner::go_to_node( price_snowmobile_run_path, "node" ); // run around back so you dont get run over
	level.price mount_snowmobile( npc_snowmobile, 0 );
}

start_icepick()
{
	level.moto_drive = false;
	if ( getdvar( "moto_drive" ) == "" )
		setdvar( "moto_drive", "0" );
	/*
	bike_animations();
	bike_driver_animations();
	bike_rider_animations();
	*/
	start_common_cliffhanger();
	friendly_init_cliffhanger();
	
	if ( isdefined( level.price._stealth ) )
		level.price stealth_basic_states_default();
	disable_stealth_system();
	flag_set( "player_in_hanger" );
	flag_set( "hanger_slowmo_ends" );
	flag_set( "start_big_explosion" );
	flag_set( "player_slides_down_hill" );
	/*
	gaz_spawner = getent( "gaz_snowmobile_spawner", "targetname" );
	level.gaz = gaz_spawner spawn_ai();
	level.gaz thread magic_bullet_shield();
	*/

	init_vehicle_splines();

	level notify( "stop_price_shield" );
	if ( !isdefined( level.price.magic_bullet_shield ) )
	{
		level.price thread magic_bullet_shield();
	}


	level notify( "stop_price_shield" );
	level.price.baseAccuracy = 1;
//	level.gaz.baseAccuracy = 0;

	player_snowmobile_spawner = getent( "player_snowmobile_spawner", "targetname" );
	level.player teleport_ent( player_snowmobile_spawner );

	wait( 1.5 );

	org = getent( "price_icepick_snowmobile_org", "targetname" );
	level.price teleport_ent( org );
	thread hill_attackers_spawn();
	thread maps\cliffhanger_snowmobile_code::recover_vehicle_path_trigger();	
}

start_snowmobile( e3 )
{
	
	level.moto_drive = false;
	if ( getdvar( "moto_drive" ) == "" )
		setdvar( "moto_drive", "0" );
	/*
	bike_animations();
	bike_driver_animations();
	bike_rider_animations();
	*/
	
	ai = getaiarray( "axis" );
	foreach ( guy in ai )
	{
		guy delete();
	}
	
	if ( !isdefined( e3 ) )
	{
		start_common_cliffhanger();
		friendly_init_cliffhanger();
	}
	if ( isdefined( level.price._stealth ) )
		level.price stealth_basic_states_default();
	disable_stealth_system();
	flag_set( "player_in_hanger" );
	flag_set( "hanger_slowmo_ends" );
	flag_set( "start_big_explosion" );
	/*
	gaz_spawner = getent( "gaz_snowmobile_spawner", "targetname" );
	level.gaz = gaz_spawner spawn_ai();
	level.gaz thread magic_bullet_shield();
	*/

	init_vehicle_splines();

	level notify( "stop_price_shield" );
	if ( !isdefined( level.price.magic_bullet_shield ) )
	{
		level.price thread magic_bullet_shield();
	}


	magic_bullet_spawner = getentarray( "magic_bullet_spawner", "script_noteworthy" );
	array_thread( magic_bullet_spawner, ::_delete );

//	For trying the scripted snowmobile path
	npc_snowmobile_spawner = getent( "god_vehicle_spawner", "script_noteworthy" );
	npc_snowmobile_spawner.script_vehicleride = undefined;
	npc_snowmobile_spawner.target = "price_snowmobile_path";
	price_snowspawn = undefined;
	/#
	if ( level.start_point == "snowspawn" )
	{
		flag_set( "price_ready_for_auto_speed" );
		price_snowspawn = getvehiclenode( "price_snowspawn", "script_noteworthy" );
		npc_snowmobile_spawner.origin = price_snowspawn.origin;
		npc_snowmobile_spawner.angles = price_snowspawn.angles;
	}
	#/
	npc_snowmobile = npc_snowmobile_spawner spawn_vehicle();

	/#
	if ( level.start_point == "snowspawn" )
	{
		npc_snowmobile attachpath( price_snowspawn );
		npc_snowmobile thread vehicle_paths( price_snowspawn );
	}
	#/
//	npc_snowmobile = getent( "npc_snowmobile", "targetname" );
	npc_snowmobile.player_offset = 250;
//	npc_snowmobile thread maps\_vehicle_aianim::guy_enter( level.gaz, npc_snowmobile );
	npc_snowmobile thread maps\_vehicle_aianim::guy_enter( level.price );
	npc_snowmobile become_price_snowmobile();
	npc_snowmobile.veh_pathtype = "constrained";

	npc_snowmobile thread gopath();
	npc_snowmobile thread price_leads_player_to_heli();
	level notify( "stop_price_shield" );
	level.price.baseAccuracy = 0;
//	level.gaz.baseAccuracy = 0;

	player_snowmobile_spawner = getent( "player_snowmobile_spawner", "targetname" );
	level.player_snowmobile = player_snowmobile_spawner spawn_vehicle();
	level.price_snowmobile = npc_snowmobile;

	/#
	if ( level.start_point == "snowspawn" )
	{
		playermobile_spawner = getent( "playermobile_spawner", "targetname" );
		player_snowspawn_start = getent( "player_snowspawn_start", "targetname" );
		playermobile_spawner.origin = player_snowspawn_start.origin;
		playermobile_spawner.angles = player_snowspawn_start.angles;

		level.player_snowmobile = playermobile_spawner spawn_vehicle();

	}
	if ( level.start_point == "lake" )
	{
		playermobile_spawner = getent( "playermobile_spawner", "targetname" );
		player_snowspawn_start = getent( "player_lake_start", "targetname" );
		playermobile_spawner.origin = player_snowspawn_start.origin;
		playermobile_spawner.angles = player_snowspawn_start.angles;

		level.player_snowmobile = playermobile_spawner spawn_vehicle();
	}
	#/

	level.player_snowmobile thread maps\_snowmobile_drive::drive_vehicle();
	level.player player_mount_vehicle( level.player_snowmobile );

	waittillframeend; // for the mount vehicle to finish.
	flag_set( "player_rides_snowmobile" );
	flag_set( "player_slides_down_hill" );
	player_snowmobile_block = getent( "player_snowmobile_block", "targetname" );
	player_snowmobile_block delete();

	thread blizzard_level_transition_snowmobile ( 1 );
}

snowmobile_main()
{
	flag_set( "escape_with_soap" );
	level notify( "kill_variable_blizzard" );

	thread hide_snowmobile_for_antfarm();
	level.enemy_snowmobiles_max = 3;
	thread snowmobile_ending_autosave();
	thread enemy_snowmobiles_wipe_out();
	thread more_enemy_snowmobiles();
	thread player_dies_if_snowmobile_slows_down();
	
	player_top_speed_limit_triggers = getentarray( "player_top_speed_limit_trigger", "targetname" );
	array_thread( player_top_speed_limit_triggers, ::player_top_speed_limit_trigger_think );
	
	kill_enemy_snowmobiles = getentarray( "kill_enemy_snowmobile", "targetname" );
	array_thread( kill_enemy_snowmobiles, ::kill_enemy_snowmobile_think );
	
//	banister_spawners = getentarray( "banister_spawner", "script_noteworthy" );
//	array_thread( banister_spawners, ::banister_spawner_think );

	player_path_triggers = getentarray( "player_path_trigger", "targetname" );
	array_thread( player_path_triggers, ::player_path_trigger_think );
	
	thread snowmobile_dialogue();

	thread player_makes_snowmobile_jump();

	add_wait( ::flag_wait, "snowmobile_fog_clears" );
	add_func( ::flag_clear, "ai_snowmobiles_ram_player" );
	thread do_wait();

	if ( !isalive( level.price ) )
		return;

	flag_set( "reached_top" );

	flag_wait( "player_rides_snowmobile" );
	setsaveddvar( "ui_hideMap", "1" );
	
	level.player takeallweapons();
	
	fence_planks = getentarray( "fence_plank", "targetname" );
	array_thread( fence_planks, ::fence_plank_think );


	//thread price_snowmobile_icon();

	// faster regen for this part to make it more exciting
	level.longRegenTime = 2000;

	// a little extra invul time for the harder difs
	if ( level.player.deathInvulnerableTime > 2000 )
		level.player.deathInvulnerableTime = 2000;

	thread ride_dialogue();

	//SetSavedDvar( "r_showMissingLightgrid", "0" );

	snowmobile = level.player_snowmobile;
	assert( isdefined( snowmobile ) );

	level.player thread maps\_vehicle_spline::track_player_progress( snowmobile.origin );
	flag_set( "player_gets_on_snowmobile" );
	set_custom_gameskill_func( ::snowmobile_gameskill_settings );

	thread blizzard_level_transition_snowmobile ( 5 );

	thread missile_repulser();

	remove_global_spawn_function( "axis", ::lower_ai_accuracy );

	thread hk_heli();

	level.player.baseIgnoreRandomBulletDamage = true;
	level.ignoreRandomBulletDamage = true;

	level.doPickyAutosaveChecks = false;
	level.autosave_threat_check_enabled = false;
	setsaveddvar( "sm_sunSampleSizeNear", 1 );
	autosave_by_name( "ride_the_bike" );

	level.bike_score = 0;
	wait( 2.4 );

	add_wait( ::flag_wait, "snowmobile_fog_clears" );
//	add_func( ::blizzard_no_fog, 2 );
	thread do_wait();

	//thread player_falls_into_revine();
	//thread player_jump_slowmo();
	thread enemy_snowmobiles_spawn_and_attack();

//	level endon( "avalanche_begins" );
//	flag_wait( "avalanche_begins" );


	add_wait( ::flag_wait, "price_get_speed_up" );
	// Pin the throttle!! Keep going!!
	add_func( ::radio_dialogue, "cliff_pri_pinthrottle" );
	thread do_wait();



	flag_wait( "player_reaches_hilltop" );
	level.SPLINE_MIN_PROGRESS = -6000;
	// Papa Six, we’re getting close to bingo fuel. What’s your status over?
	radio_dialogue( "cliff_hp1_status" );

	// Kilo Six-One, we’re taking heavy fire but we’re almost there! Standby!
	radio_dialogue( "cliff_pri_almostthere" );


	flag_wait( "there_is_chopper" );

	// There’s the chopper! Let’s go!
	radio_dialogue( "cliff_pri_thechopper" );

	// Papa Six we have you on visual. Get your ass on board! We’re running on fumes here!
	radio_dialogue( "cliff_hp1_fumes" );
	
	//Ok they got the ACS, we're outta here!
	thread radio_dialogue( "cliff_crc_gotacs" );

	flag_wait( "ending_heli_flies_in" );

	flag_wait( "end_begins" );
	wait( 2.5 );
	black_overlay = create_client_overlay( "black", 0, level.player );
	black_overlay fadeOverTime( 1 );
	black_overlay.alpha = 1;

	level.player SetEqLerp( 1, level.eq_main_track );
	thread maps\_ambient::use_eq_settings( "fadeall_but_music", level.eq_mix_track );
	thread maps\_ambient::blend_to_eq_track( level.eq_mix_track, 1 );	
	
	wait( 2 );
	nextmission();
	//missionSuccess( "cliffhanger" );

//	nextmission();
}

snowmobile_gameskill_settings()
{
	// spend less time in red flashing
	// If you go to red flashing, the amount of time before your health regens
	level.difficultySettings[ "longRegenTime" ][ "easy" ] = 2000;
	level.difficultySettings[ "longRegenTime" ][ "normal" ] = 2000;
	level.difficultySettings[ "longRegenTime" ][ "hardened" ] = 2000;
	level.difficultySettings[ "longRegenTime" ][ "veteran" ] = 2000;
}

ride_dialogue()
{
	/#
	if ( level.start_point == "snowspawn" )
		return;
	#/

	wait( 2.5 );
	// Kilo Six-One, the primary exfil point is compromised! We’re en route to Bravo using enemy transport! Meet us there! Over!
	thread radio_dialogue( "cliff_pri_enroute" );

	// Papa Six, this Kilo Six-One, roger that, we’ll see you at Bravo. Out.
	thread radio_dialogue( "cliff_hp1_seeyouatbravo" );
}


track_landing_time()
{
	self waittill( "veh_landed" );
	self.landed_time = gettime();
}

player_makes_snowmobile_jump()
{
	flag_wait( "snowmobile_jump" );
	ending_fuel_explosion = getstruct( "ending_fuel_explosion", "targetname" );
	wait( 1.5 );
	for ( ;; )
	{
		RadiusDamage( ending_fuel_explosion.origin, ending_fuel_explosion.radius, 50000, 50000, level.price );
		if ( !isdefined( ending_fuel_explosion.target ) )
			return;
		ending_fuel_explosion = getstruct( ending_fuel_explosion.target, "targetname" );
		wait( 0.15 );
	}
}

player_jump_slowmo()
{
	flag_wait( "snowmobile_jump" );
	wait( 0.40 );
	/*
	slowmo_start();
	slowmo_setspeed_slow( 0.5 );
	slowmo_setlerptime_in( 0.2 );
	slowmo_lerp_in();
	*/
//	level.player delaythread( 2.5, ::play_sound_on_entity, "slomo_whoosh" );
	//wait( animation_length * 0.005 );

	wait( 2.6 );
	/*
	if ( flag( "snowmobile_in_house" ) )
	{
		thread player_jolts_house();
		wait( 1.1 );
	}
	*/

	/*
	slowmo_setlerptime_out( 0.5 );
	slowmo_lerp_out();
	slowmo_end();
	*/
	if ( level.player.vehicle vehicle_getSpeed() > 50 )
	{
		level.player.vehicle Vehicle_SetSpeed( 50, 20, 20 );
	}
}

player_falls_into_revine()
{
	flag_wait( "player_falls_to_avalanche_section" );
	ent = getentwithflag( "player_falls_to_avalanche_section" );
	brushmodel = getent( ent.target, "targetname" );
	org = getent( brushmodel.target, "targetname" );
	brushmodel linkto( org );
	org.origin = level.player.origin;
	angles = level.player.vehicle.angles;
	angles = ( 0, angles[ 1 ], 0 );
	org.angles = angles;
	flag_set( "avalanche_begins" );
}

start_avalanche()
{
	/*
	bike_animations();
	bike_driver_animations();
	bike_rider_animations();
	*/
	init_vehicle_splines();
	level.moto_drive = false;
	if ( getdvar( "moto_drive" ) == "" )
		setdvar( "moto_drive", "0" );

	start_common_cliffhanger();
	friendly_init_cliffhanger();

	spawners = getentarray( "enemy_snowmobile_chase_spawner", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, ::enemy_snowmobile_chase_spawner_think );
	array_thread( spawners, ::spawn_ai );
	thread blizzard_level_transition_snowmobile ( 1 );
}

avalanche_main()
{
	flag_set( "reached_top" );
	level.price.ignoreall = true;

	foreach ( fx in level.createFXent )
	{
		fx thread pauseEffect();
	}

	level.player.attackeraccuracy = 0;
	level.chase_vehicles = [];
	avalache_chase_vehicle_spawners = getentarray( "avalanche_chase_vehicle_spawner", "script_noteworthy" );
	array_thread( avalache_chase_vehicle_spawners, ::avalache_chase_vehicle_spawner_think );
	thread chase_vehicles_get_personal_progress_offset();
	thread avalanche_heli_attacks();

	flag_set( "avalanche_ride_starts" );

//	snowmobile_escape_spawner = getent( "snowmobile_escape", "targetname" );
//	snowmobile_escape = snowmobile_escape_spawner Vehicle_DoSpawn();
	//snowmobile_escape = getent( "snowmobile_escape", "targetname" );

	//level.player unlink();
//	level.player PlayerLinkToDelta( player_ride, "tag_origin", 1 );
//	level.player playerlinktodelta( player_ride, "tag_origin", 1, 60, 60, 120, 40 );
	player_ride = spawn_vehicle_from_targetname( "player_end_ride" );
	level.player_ride = player_ride;
	avalanche_progress_org = getent( "avalanche_progress_org", "targetname" );
	targ = getent( avalanche_progress_org.target, "targetname" );

	level.player.baseIgnoreRandomBulletDamage = true;
	level.ignoreRandomBulletDamage = true;

	player_ride thread track_player_ride_progress();
	thread price_progress_dialogue();
	//player_ride hide();
	level.player DisableWeapons();

	if ( isdefined( level.player.vehicle ) )
	{
		level.player.vehicle useby( level.player );
		level.player.drivingVehicle = level.player.vehicle;
		
		level.player.vehicle delete();
		level.player.vehicle = undefined;
	}

	view_arms = spawn_anim_model( "player_rig" );
	view_arms hide();
	tag_origin = spawn_tag_origin();
	tag_origin linkto( view_arms, "tag_player", (0,0,0), (0,0,0) );
	level.player PlayerSetGroundReferenceEnt( tag_origin );
	level.player PlayerLinkToDelta( view_arms, "tag_player", 1, 0, 0, 0, 0 );
	delaythread( 2.5, ::open_up_player_fov, view_arms, "tag_player" );

	scene = [];
	scene[ 0 ] = level.price;
	scene[ 1 ] = view_arms;

	level.price gun_remove();
	if ( isdefined( level.price.magic_bullet_shield ) )
	{
		level.price stop_magic_bullet_shield();
	}

	crash_recovery = getent( "crash_recovery", "targetname" );
	scene_org = spawn( "script_origin", crash_recovery.origin );
	scene_org.angles = crash_recovery.angles;

	/*
	// translate the posts into the proper positions for the animations
	ent = spawnstruct();
	ent.entity = scene_org;
	ent.forward = -10;
	ent.up = 25;
	ent.right = 0;
	ent.yaw = 0;
	ent translate_local();
	*/
	//scene_org LinkTo( player_ride );

	// I'm driving
	level.price delaythread( 3.5, ::dialogue_queue, "i_drive" );
	// “Avalaaaanche!!!!!”
	delaythread( 12.5, ::radio_dialogue_queue, "avalanche" );
	// “More tangos on our six! Take ‘em out!”
	delaythread( 16.5, ::radio_dialogue_queue, "moretangos" );



	scene_org anim_single( scene, "crash_rescue" );

	tag_origin = spawn_tag_origin();
	tag_origin.origin = player_ride.origin;// getTagOrigin( "tag_passenger" );
	tag_origin.angles = player_ride.angles;// getTagAngles( "tag_passenger" );

	ent = spawnstruct();
	ent.entity = tag_origin;
	ent.forward = -20;
	ent.up = 10;
	ent.right = 0;
	ent.yaw = 180;
	ent translate_local();
	//tag_origin linkto( player_ride, "tag_player", (0,0,0), (0,180,0) );
	tag_origin linkto( player_ride );
	//LinkTo( linkto entity, tag, originOffset, anglesOffset );
	//tag_origin thread maps\_debug::drawTagForever( "tag_origin" );

	level.player PlayerSetGroundReferenceEnt( undefined );

	timer = 0.5;
	view_arms delete();
	level.player PlayerLinkToBlend( tag_origin, "tag_origin", timer, timer * 0.2, timer * 0.2 );
	delaythread( timer + 0.1, ::open_up_player_fov, tag_origin, "tag_origin" );

	//view_arms linkto( player_ride );
	level.price delete();


	/*
	viewmodel = spawn_tag_origin();
	viewmodel linkto( player_ride, "tag_origin", ( 0, 0, 0 ), ( 0, 180, 0 ) );
	timer = 0.5;
	level.player PlayerLinkToBlend( viewModel, "tag_origin", timer, timer * 0.2, timer * 0.2 );
	*/

	level.player EnableWeapons();
	thread gopath( player_ride );
	player_ride VehPhys_DisableCrashing();
	wait( 0.5 );
//	level.player playerlinktodelta( viewmodel, "tag_origin", 1, 60, 60, 120, 40 );
	wait( 2.0 );
	level.avalanche_vehicles = [];
	avalanche_ents = spawn_vehicles_from_targetname( "avalance_vehicle" );
	array_thread( avalanche_ents, ::avalanche_section );

    exploder( 2 ); //Avalanche start exploder

	flag_wait( "avalanche_reconstitutes" );

	wait( 2.5 );
//	avalanche_ents = spawn_vehicles_from_targetname( "avalanche_recon" );
//	array_thread( avalanche_ents, ::avalanche_section );

	flag_wait( "the_end" );
	wait( 6 );
	black_overlay = create_client_overlay( "black", 0, level.player );
	black_overlay fadeOverTime( 1 );
	black_overlay.alpha = 1;
	wait( 2 );
	nextmission();
}


avalanche_heli_attacks()
{
	flag_wait( "avalanche_heli_attacks" );

	avalanche_heli_spawner = getent( "avalanche_heli", "targetname" );
	avalanche_heli = avalanche_heli_spawner spawn_vehicle();

	avalanche_heli goPath();
	speed = level.player_ride vehicle_getSpeed();
	//avalanche_heli Vehicle_SetSpeed( speed, speed * 0.5, speed * 0.5 );
	avalanche_heli.personal_offset = 900;

	// move the avalanche back a little to give the heli space
	set_avalanche_offset( 2300 );

	avalanche_heli delaythread( 5, ::avalanche_maintains_distance_behind_player );

	avalanche_heli SetGoalYaw( 90 );

	avalanche_heli waittill( "reached_dynamic_path_end" );
	avalanche_heli_crash = getent( "avalanche_heli_crash", "targetname" );

	avalanche_heli = avalanche_heli vehicle_to_dummy();
	avalanche_heli assign_animtree( "heli" );

	delaythread( 1.5, ::set_avalanche_offset, 500 );

	avalanche_heli_crash anim_single_solo( avalanche_heli, "avalanche_heli_wipeout" );
}

snowmobile_ending_autosave()
{
	flag_wait( "downhill_autosave" );
	if ( level.player.health < 75 )
		return;
	id = SaveGameNoCommit( "blah", &"AUTOSAVE_AUTOSAVE" );
	level.player endon( "death" );
	angles = level.player.vehicle.angles;
//	if ( flag( "price_disables_hill_autosave" ) )
//		return;
	wait( 2 );
	
	new_angles = level.player.vehicle.angles;
	forward = anglestoforward( angles );
	new_forward = anglestoforward( new_angles );
	
	if ( vectordot( forward, new_forward ) < 0.7 )
		return;
	
	if ( !CommitWouldBeValid( id ) )
		return;

	println( "SAVING DOWNHILL" );
	commitsave( id );
}

enemy_snowmobiles_wipe_out()
{
	flag_wait( "enemy_snowmobiles_wipe_out" );
	foreach ( enemy in level.enemy_snowmobiles )
	{
		enemy thread wipeout_soon();
	}
}

wipeout_soon()
{
	self endon( "death" );
	wait( randomfloatrange( 5, 12 ) );
	if ( !isdefined( self ) )
		return;
	self.wipeout = true;	
}

more_enemy_snowmobiles()
{
	flag_wait( "destroyed_fallen_tree_cliffhanger01" );
	level.enemy_snowmobiles_max = 4;
}

player_dies_if_snowmobile_slows_down()
{
	level endon( "snowmobile_jump" );
	flag_wait( "player_rides_snowmobile" );
	level.player.vehicle endon( "veh_collision" );
	level endon( "player_crashes" ); // from triggers in the map
	flag_wait( "bad_heli_goes_to_death_position" );
	
	for ( ;; )
	{
		if ( !isdefined( level.player.vehicle ) )
			return;
		if ( level.player.vehicle.veh_speed >= 120 )
			break;
		wait( 0.05 );
	}
	
	old_speed = level.player.vehicle.veh_speed;
	for ( ;; )
	{
		if ( !isdefined( level.player.vehicle ) )
			return;
		if ( level.player.vehicle.veh_speed < old_speed - 35 )
			break;
		old_speed = level.player.vehicle.veh_speed;
		wait( 0.05 );
	}
	
	level.player.vehicle notify( "veh_collision" );
}

fence_plank_think()
{
	for ( ;; )
	{
		dist_price = distance_test( level.price.vehicle );
		dist_player = distance_test( level.player.vehicle );
		
		if ( dist_price < 100 )
			break;
		if ( dist_player < 100 )
			break;
		if ( dist_player > 1500 )
			break;
		wait( 0.05 );
	}
	
	self delete();
}

distance_test( ent )
{
	if ( !isdefined( ent ) )
		return 500;
	return distance( ent.origin, self.origin );
}

hide_snowmobile_for_antfarm()
{
	flag_wait( "player_rides_snowmobile" );	
	
	if( getdvar( "scr_hide_snowmobile" ) == "1" )
		level.player_snowmobile hide();
}