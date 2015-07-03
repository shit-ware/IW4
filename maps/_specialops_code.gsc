#include maps\_utility;
#include common_scripts\utility;
#include maps\_hud_util;

/*QUAKED info_player_start_so (0.0 0.3 1.0) (-16 -16 0) (16 16 72)
Player 1 spawns at these locations in Special Ops games. If there is a player 2 but player2 specific start points, player 2 will be positioned near player 1.*/

/*QUAKED info_player_start_soPlayer2 (0.2 0.5 1.0) (-16 -16 0) (16 16 72)
Player 2 spawns at these locations in Special Ops games. Will use the closest spawn point to player 1.*/

pick_starting_location_so( return_placement )
{
	if ( isdefined( return_placement ) && return_placement )
	{
		if ( isdefined( level.skip_PlayerSetStreamOrigin ) && level.skip_PlayerSetStreamOrigin )
			return undefined;
	}

	if ( isdefined( level.pmc_match ) && level.pmc_match )
	{
		return pick_starting_location_pmc( return_placement );
	}
	
	p1_starts = getentarray( "info_player_start_so", "classname" );
	if ( p1_starts.size <= 0 )
		p1_starts = getentarray( "info_player_start", "classname" );

	assertex( p1_starts.size > 0, "Special Ops requires at least 1 player starting position. Place either an info_player_start_so or info_player_start in the level." );

	p1_start_point = random( p1_starts );

	// return_placement tells it to not actually place the people, and instead send back where it *would* have placed them. 
	// If the map can potentially spawn them in random locations or far apart, this logic breaks down.
	// Used by PlayerSetStreamOrigin for map restarts. Use level.skip_PlayerSetStreamOrigin to avoid it.
	if ( isdefined( return_placement ) && return_placement )
	{
		assert( p1_starts.size == 1 );
		return p1_start_point.origin;
	}

	place_player_at_start_point( level.player, p1_start_point );

	if ( is_coop() )
	{	
		p2_starts = getentarray( "info_player_start_soPlayer2", "classname" );
		if ( p2_starts.size > 0 )
		{
			p2_start_point = getClosest( p1_start_point.origin, p2_starts );
			place_player_at_start_point( level.player2, p2_start_point );
		}
		else
		{
			place_player2_near_player1();
		}
	}
}

isDefendMatch()
{
	return( level.pmc_gametype == "mode_defend" );
}

// Having to include this is sucky, but I don't know a better way.
pick_starting_location_pmc( return_placement )
{
	if ( isDefendMatch() )
	{
		startingLocations = getentarray( "info_player_start_pmcDefend", "classname" );
		assertEx( startingLocations.size > 0, "You don't have any player starting positions in the level for defend mode. Place info_player_start_pmcDefend entities in the level." );
		assertEx( startingLocations.size >= level.players.size, "You don't have enough info_player_start_pmcDefend entities in the level to support " + level.players.size + " players." );
	}
	else
	{
		// Get all of the spawn locations in the map
		startingLocations = getentarray( "info_player_start_pmc", "classname" );
		assertEx( startingLocations.size > 0, "You don't have any player starting positions in the level. Place info_player_start_pmc entities in the level." );
		assertEx( startingLocations.size >= level.players.size, "You don't have enough info_player_start_pmc entities in the level to support " + level.players.size + " players." );
	}


	// Pick one at random then put the player at it and put other players at the next nearest ones
	excluders = [];
	spawnEnt = undefined;
	foreach ( player in level.players )
	{
		if ( !excluders.size )
			spawnEnt = random( startingLocations );
		else
			spawnEnt = get_closest_exclude( spawnEnt.origin, startingLocations, excluders );

		assert( isdefined( spawnEnt ) );

		// See notes in pick_starting_location_so()
		if ( isdefined( return_placement ) && return_placement )
		{
			assert( startingLocations.size <= 2 );
			return spawnEnt.origin;
		}
					
		player setOrigin( spawnEnt.origin );
		player setPlayerAngles( spawnEnt.angles );

		excluders[ excluders.size ] = spawnEnt;
	}
}

place_player_at_start_point( player, start_point )
{
	assertex( isdefined( player ), "place_player_at_start_point() requires a valid player." );
	assertex( isdefined( start_point ), "place_player_at_start_point() requires a valid start_point." );

	player SetOrigin( start_point.origin );
	if ( isdefined( start_point.angles ) )
		player setPlayerAngles( start_point.angles );
}

place_player2_near_player1()
{
	level.player2 setPlayerAngles( level.player.angles + ( 0, -25, 0 ) );
	level.player2 SetOrigin( level.player.origin );

	// Offset player 2 a bit from player 1 (adjusted by angle players are facing).
	ent = spawnstruct();
	ent.entity = level.player2;
	ent.right = -20.0;
	ent.forward = -50.0;
	ent translate_local();
	level.player2 SetOrigin( level.player2.origin );
}

specialops_remove_entity_check( special_op_state )
{
	if ( specialops_remove_flag_check( special_op_state ) )
		return true;
	
	if ( specialops_remove_name_check( special_op_state ) )
		return true;
		
	return false;
}

specialops_remove_flag_check( special_op_state )
{
	if ( !isdefined( self.script_specialops ) )
		return false;
		
	assertex( ( ( self.script_specialops == 0 ) || ( self.script_specialops == 1 ) ), "Entities with script_specialops set must use a value of either 0 or 1. Classname " + self.classname + " at Origin " + self.origin );
	if ( self.script_specialops == special_op_state )
		return false;
	
	return true;
}

specialops_remove_name_check( special_op_state )
{
	if ( !isdefined( self.script_specialopsname ) )
		return false;

	if ( special_op_state == 0 )
		return true;

	tokens = strtok( self.script_specialopsname, ":;, " );
	delete_ent = true;
	foreach ( token in tokens )
	{
		if ( token == level.script )
		{
			delete_ent = false;
			break;
		}
	}
	
	return delete_ent;
}

so_create_hud_item_delay_draw( hudelem )
{
	hudelem.alpha = 0;
	while( !so_hud_can_show() )
		wait 0.5;

	if ( !isdefined( hudelem ) )
		return;

	if ( so_hud_can_toggle( hudelem ) )
	{
		switch( self.so_infohud_toggle_state )
		{
			case "on":	
			case "none":	hudelem fade_over_time( 1, 0.5 ); break;
			case "off":		hudelem fade_over_time( 0, 0.5 ); break;
			default:		assertmsg( "so_create_hud_item_delay_draw() encountered a setting for player.so_infohud_toggle_state (" + self.so_infohud_toggle_state + ") it didn't recognize." );
		}
	}
	else
	{
		hudelem fade_over_time( 1, 0.5 );
	}
	
	if ( !self ent_flag( "so_hud_can_toggle" ) )
		self ent_flag_set( "so_hud_can_toggle" );
}

so_hud_can_show()
{
	if ( isdefined( level.so_waiting_for_players ) && level.so_waiting_for_players )
		return false;

	if ( isdefined( level.challenge_time_force_on ) && level.challenge_time_force_on )
		return true;
		
	if ( !isdefined( self.so_hud_show_time ) )
		return true;
	
	return ( gettime() > self.so_hud_show_time );
}

so_hud_can_toggle( hudelem )
{
	if ( !isdefined( hudelem.so_can_toggle ) || !hudelem.so_can_toggle )
		return false;
		
	if ( !isdefined( self.so_infohud_toggle_state ) )
		return false;
		
	return true;
}

challenge_timer_player_setup( start_flag, passed_flag, message )
{
	level endon( "challenge_timer_expired" );
	level endon( "new_challenge_timer" );
	level endon( "special_op_terminated" );

	ypos = maps\_specialops::so_hud_ypos();
	self.hud_so_timer_msg = maps\_specialops::so_create_hud_item( 1, ypos, message, self );
	if ( isdefined( level.challenge_time_limit ) )
	{
		self.hud_so_timer_time = maps\_specialops::so_create_hud_item( 1, ypos, undefined /*convert_to_time_string( level.challenge_time_limit, true )*/, self );
		self.hud_so_timer_time SetTenthsTimerStatic( level.challenge_time_limit );
	}
	else
		self.hud_so_timer_time = maps\_specialops::so_create_hud_item( 1, ypos, &"SPECIAL_OPS_TIME_NULL", self );
	self.hud_so_timer_time.alignX = "left";

	thread maps\_specialops::info_hud_wait_for_player();
	thread maps\_specialops::info_hud_handle_fade( self.hud_so_timer_msg );
	thread maps\_specialops::info_hud_handle_fade( self.hud_so_timer_time );

	challenge_timer_wait_start( self.hud_so_timer_msg, self.hud_so_timer_time, start_flag );

/*	if ( !isdefined( level.challenge_progress_manual_update ) || !level.challenge_progress_manual_update )
	{
		thread challenge_timer_detect_3quarter();
		thread challenge_timer_detect_halfway();
		thread challenge_timer_detect_quarter();
	}*/

	if ( isdefined( level.challenge_time_limit ) )
	{
		level.so_challenge_time_left = level.challenge_time_limit;
		thread challenge_timer_show_nudge( self.hud_so_timer_msg, self.hud_so_timer_time );
		thread challenge_timer_show_hurry( self.hud_so_timer_msg, self.hud_so_timer_time );
		thread challenge_timer_show_failed( self.hud_so_timer_msg, self.hud_so_timer_time );
		thread challenge_timer_destroy_prematurely( self.hud_so_timer_msg, self.hud_so_timer_time );
	}

	thread challenge_timer_wait_passed( self.hud_so_timer_msg, self.hud_so_timer_time, passed_flag );
}

// CTW - Better way to do this: Have the timer detect the halfway mark when counting down
// and if you haven't set these flags, tell the player they need to pick it up.
challenge_timer_detect_3quarter()
{
	if ( !flag_exist( "so_challenge_is_3quarter" ) )
		flag_init( "so_challenge_is_3quarter" );
	
	flag_wait( "so_challenge_is_3quarter" );
	
	maps\_specialops::so_dialog_progress_update( 3, 4 );
}

challenge_timer_detect_halfway()
{
	if ( !flag_exist( "so_challenge_is_halfway" ) )
		flag_init( "so_challenge_is_halfway" );
	
	flag_wait( "so_challenge_is_halfway" );
	
	maps\_specialops::so_dialog_progress_update( 2, 4 );
}

challenge_timer_detect_quarter()
{
	if ( !flag_exist( "so_challenge_is_quarter" ) )
		flag_init( "so_challenge_is_quarter" );
		
	flag_wait( "so_challenge_is_quarter" );
	
	maps\_specialops::so_dialog_progress_update( 1, 4 );
}

challenge_timer_wait_start( hud_msg, hud_time, start_flag )
{
	level endon( "special_op_terminated" );

	if ( isdefined( start_flag ) )
		flag_wait( start_flag );

	// Force the hud on if player charges ahead.
	foreach ( player in level.players )
	{
		if ( !player so_hud_can_show() )
			player.so_hud_show_time = gettime();
	}
			
	if ( !isdefined( level.challenge_start_time ) )
	{
		if ( challenge_timer_should_play_alarm() )
			level.player PlaySound( "arcademode_zerodeaths" );
		level.challenge_start_time = gettime();
	}

	hud_time.label = "";
	if ( isdefined( level.challenge_time_limit ) )
		hud_time settenthstimer( level.challenge_time_limit );
	else
		hud_time settenthstimerup( 0.00 );
}

challenge_timer_should_play_alarm()
{
	if ( isdefined( level.challenge_time_limit ) )
		return true;
		
	foreach ( player in level.players )
	{
		if ( player.so_infohud_toggle_state != "off" )
			return true;
	}
	
	return false;
}

challenge_timer_show_nudge( hud_msg, hud_time )
{
	if ( !validate_timer( level.challenge_time_nudge ) )
		return;

	level endon( "challenge_timer_passed" );
	level endon( "new_challenge_timer" );
	level endon( "special_op_terminated" );

//	if ( level.challenge_time_limit > level.challenge_time_nudge )
//		wait level.challenge_time_limit - level.challenge_time_nudge;

	while ( level.so_challenge_time_left > level.challenge_time_nudge )
	{
		wait( 0.1 );
	}

	hud_msg set_hudelem_yellow();
	hud_time set_hudelem_yellow();
	if ( !challenge_timer_be_silent() )
		thread maps\_specialops::so_dialog_time_low_normal();
}

challenge_timer_show_hurry( hud_msg, hud_time )
{
	if ( !validate_timer( level.challenge_time_hurry ) )
		return;

	level endon( "challenge_timer_passed" );
	level endon( "new_challenge_timer" );
	level endon( "special_op_terminated" );

//	if ( level.challenge_time_limit > level.challenge_time_hurry )
//		wait level.challenge_time_limit - level.challenge_time_hurry;
	while ( level.so_challenge_time_left > level.challenge_time_hurry )
	{
		wait( 0.1 );
	}

	hud_msg set_hudelem_red();
	hud_time set_hudelem_red();
	if ( !challenge_timer_be_silent() )
		thread maps\_specialops::so_dialog_time_low_hurry();
}

challenge_timer_be_silent()
{
	if ( self != level.player )
		return true;
	
	if ( !isdefined( level.challenge_time_silent ) )
		return false;
		
	return level.challenge_time_silent;
}

challenge_timer_thread()
{
	level endon( "special_op_terminated" );
	
	level notify( "stop_challenge_timer_thread" );
	level endon( "stop_challenge_timer_thread" );

	while ( level.so_challenge_time_left > 0 )
	{
		wait( 0.05 );
		level.so_challenge_time_left -= 0.05;
		thread challenge_timer_give_alert();
	}

	level notify( "challenge_timer_failed" );
}

challenge_timer_give_alert()
{
	if ( challenge_timer_should_pulse() )
	{
		foreach ( player in level.players )
		{
			player.hud_so_timer_msg thread maps\_specialops::so_hud_pulse_create();
			player.hud_so_timer_time thread maps\_specialops::so_hud_pulse_create();
		}

		if ( level.so_challenge_time_beep < 0 )
			level.player PlaySound( "arcademode_kill_streak_lost" );
		else
			level.player PlaySound( "so_countdown_beep" );
	}
}

challenge_timer_should_pulse()
{
	if ( level.so_challenge_time_left > level.so_challenge_time_beep )
		return false;
		
	for ( i = 0; i <= level.challenge_time_beep_start; i++ )
	{
		if ( level.so_challenge_time_left > i )
		{
			// If the timer has been increased, need to reset our beep tracking.
			if ( level.so_challenge_time_beep < i )
				level.so_challenge_time_beep = i + 1;
			continue;
		}
		
		// We already know time_left is less than time_beep, so go go go!
		level.so_challenge_time_beep = i - 1;
		return true;
	}
	
	return false;
}

challenge_timer_show_failed( hud_msg, hud_time )
{
	if ( !validate_timer( level.challenge_time_limit ) )
		return;

	level endon( "challenge_timer_passed" );
	level endon( "new_challenge_timer" );
	level endon( "special_op_terminated" );

//	wait( level.challenge_time_limit );
	thread challenge_timer_thread();
	level waittill( "challenge_timer_failed" );

	flag_set( "challenge_timer_expired" );
	level.challenge_end_time = gettime();

	challenge_timer_destroy( hud_msg, hud_time );
		
//	radio_dialogue_stop();
	if ( self == level.player )
		thread maps\_specialops::so_dialog_mission_failed_time();

	maps\_specialops::so_force_deadquote( "@SPECIAL_OPS_FAILURE_HINT_TIME", "ui_time_failure" );
	
	if ( self == level.player )
		MissionFailedWrapper();
}

challenge_timer_wait_passed( hud_msg, hud_time, passed_flag )
{
	level endon( "challenge_timer_expired" );
	level endon( "new_challenge_timer" );
	
	if ( flag_exist( "individual_timers" ) && flag( "individual_timers" ) )
		self ent_flag_wait( passed_flag );
	else
		flag_wait( passed_flag );

	flag_set( "challenge_timer_passed" );
	level.challenge_end_time = gettime();

	// This might not work in every circumstance?
	// Freeze the timer where it is for the couple of seconds it remains visible.
	time = ( level.challenge_end_time - level.challenge_start_time ) * 0.001;
	if ( isdefined( level.challenge_time_limit ) )
		time = level.challenge_time_limit - time;
	
	// stupid hack to make this work correctly, because this mission modifies level.challenge_time_limit on the fly
	if ( level.script == "so_snowrace2_cliffhanger" )
		time = level.challenge_time_limit;


	// We cannot have time be 0 when we call SetTenthsTimerStatic()
	if ( time <= 0 )
	{
		time = 0.1;
	}
	
	hud_time SetTenthsTimerStatic( time );
	
	if ( !flag_exist( "individual_timers" ) )
		return;
	if ( flag( "individual_timers" ) )
		return;
	
	challenge_timer_destroy( hud_msg, hud_time );
}

challenge_timer_destroy_prematurely( hud_msg, hud_time )
{
	level waittill( "new_challenge_timer" );
	challenge_timer_destroy( hud_msg, hud_time, true );
}

challenge_timer_destroy( hud_msg, hud_time, destroy_immediately )
{
	if ( isdefined( hud_msg ) )
		hud_msg	thread maps\_specialops::so_remove_hud_item( destroy_immediately );
	if ( isdefined( hud_time ) )
		hud_time thread maps\_specialops::so_remove_hud_item( destroy_immediately );
}

validate_timer( timer )
{
	if ( !isdefined( timer ) )
		return false;
		
	if ( timer <= 0 )
		return false;
		
	return true;
}

failure_summary_display()
{
	if ( getdvarint( "so_nofail" ) )
		return;
		
	thread maps\_specialops::so_dialog_mission_failed_generic();
	
	MissionFailed();
	specialops_mission_over_setup( false );

	// mission failed;
	setDvar( "ui_mission_success", 0 );
	level notify( "so_generate_deathquote" );
	maps\_endmission::coop_eog_summary();

	specialops_summary_player_choice();
}

specialops_mission_over_setup( was_success )
{
	assertex( isdefined( was_success ), "specialops_mission_over_setup() requires a true or false value for the was_success parameter." );

	if ( flag( "special_op_terminated" ) )
	{
		assertmsg( "The special op has somehow tried to end itself more than once. Current Success = " + was_success + " and Previous Success = " + level.special_op_success );
	}
	
	if ( !isdefined( level.challenge_end_time ) )
		level.challenge_end_time = gettime();

	flag_set( "special_op_terminated" );
	level notify( "stop_music" );

	// Initiate a pre-fetch of the texture data to help lower load times a bit.
	stream_origin = undefined;
	if ( isdefined( level.pmc_game ) && level.pmc_game )
		stream_origin = pick_starting_location_pmc( true );
	else
		stream_origin = pick_starting_location_so( true );
	if ( isdefined( stream_origin ) )
	{
		foreach ( player in level.players )
			player PlayerSetStreamOrigin( stream_origin );
	}
	
	ambientStop( 2 );
	music_stop( 1 );
	
	if ( was_success )
		thread specialops_mission_over_setup_success();
	else
		thread specialops_mission_over_setup_failure();
		
	foreach ( player in level.players )
	{
		player AllowJump( false );
		player disableweapons();
		player disableusability();
		player EnableInvulnerability();
		player.ignoreme = true;
	}
	
	thread specialops_blur_player_screen();
	
	wait 3;

	thread specialops_mission_over_remove_ai();

	if ( !flag( "special_op_no_unlink" ) )
	{
		foreach ( player in level.players )
		{
			player Unlink();
	//		org = player spawn_tag_origin();
	//		player PlayerLinkToDelta( org );
		}
	}

	foreach ( player in level.players )
	{
		player freezecontrols( true );
	}
	
	// This needs to happen last as it's expected for all values used in stat collection to be set by now.
	specialops_mission_over_stats( was_success );
}

specialops_blur_player_screen()
{
	foreach ( player in level.players )
	{
		wait 0.1;
		player setBlurForPlayer( 6, 1 );
	}
}

specialops_mission_over_remove_ai()
{
	wait 0.25;
	
	ai_to_delete = getaiarray();
	ai_to_delete = array_merge( ai_to_delete , getaiSpeciesArray( "axis", "dog" ) );
	foreach ( ai in ai_to_delete )
	{
		if ( isdefined( ai.magic_bullet_shield ) )
			ai stop_magic_bullet_shield();
		ai Delete();
	}
}

specialops_mission_over_setup_success()
{
	flag_set( "special_op_succeeded" );
	
	foreach ( player in level.players )
	{
		screen_fade = create_client_overlay( "white", 0, player );
		screen_fade.color = ( 0.7, 0.7, 1 );
		screen_fade thread fade_over_time( 0.25, 2 );
	}
	
	if ( isdefined( level.suppress_challenge_success_print ) )
		return;
	
	passed_hud = maps\_specialops::so_create_hud_item( 3, 0, &"SPECIAL_OPS_CHALLENGE_SUCCESS" );
	passed_hud.alignX = "center";
	passed_hud.horzAlign = "center";
	passed_hud set_hudelem_blue();
	passed_hud SetPulseFX( 60, 2500, 500 );	

	wait 1.5;
	music_play( "so_victory_" + level.so_campaign, undefined, 0, true );
}

specialops_mission_over_setup_failure()
{
	flag_set( "special_op_failed" );

	passed_hud = maps\_specialops::so_create_hud_item( 3, 0, &"SPECIAL_OPS_CHALLENGE_FAILURE" );
	passed_hud.hidewhendead = false;
	passed_hud.alignX = "center";
	passed_hud.horzAlign = "center";
	passed_hud set_hudelem_red();
	passed_hud SetPulseFX( 60, 2500, 500 );

	foreach ( player in level.players )
	{
		screen_fade = create_client_overlay( "white", 0, player );
		screen_fade.color = ( 1, 0.4, 0.4 );
		screen_fade thread fade_over_time( 0.25, 2 );
	}

	wait 1.5;
	music_play( "so_defeat_" + level.so_campaign, undefined, 0, true );
}

is_current_level_locked()
{
	specOpsString = self GetLocalPlayerProfileData( "missionSOHighestDifficulty" );
	
	if( !isdefined( specOpsString ) )
		return true;
	
	specOpsSum = 0;
	for( i=0; i<specOpsString.size; i++ )
		specOpsSum += max ( 0, int( specOpsString[i] ) - 1 );

	current_group = tablelookup( "sp/specOpsTable.csv", 1, level.script, 13 );
	
	return ( specOpsSum < int( tablelookup( "sp/specOpsTable.csv", 1, current_group, 5 ) ) );	
}

is_so_player_signed_in()
{
	//return self isSignedIn();

	return true; //always true until code gives me a function	
}

can_save_to_profile()
{
	return self is_so_player_signed_in() && !( self is_current_level_locked() );
}

specialops_achievement_by_stars( specOpsString )
{
	specOpsSum = get_total_stars( specOpsString );
	
	// --------------- Gold Star: earn 1 star in special ops
	if ( specOpsSum >= 1 )
		self player_giveachievement_wrapper( "GOLD_STAR" );
		
	// --------------- Hotel Bravo: earn 4 star in special ops
	if ( specOpsSum >= 4 )
		self player_giveachievement_wrapper( "HOTEL_BRAVO" );	
		
	// --------------- Charlie on our six: earn 8 star in special ops
	if ( specOpsSum >= 8 )
		self player_giveachievement_wrapper( "CHARLIE_ON_OUR_SIX" );
		
	// --------------- Blackjack: earn 21 star in special ops
	if ( specOpsSum >= 21 )
		self player_giveachievement_wrapper( "BLACKJACK" );
		
	// --------------- Specialist: earn 30 star in special ops
	if ( specOpsSum >= 30 )
		self player_giveachievement_wrapper( "SPECIALIST" );

	// --------------- Star 69: earn 69 star in special ops
	if ( specOpsSum >= 69 )
		self player_giveachievement_wrapper( "STAR_69" );

	// =============== It Goes to Eleven: 1 star in 11 different SO
	if ( get_num_of_levels_with_star( specOpsString, 1 ) >= 11 )
		self player_giveachievement_wrapper( "IT_GOES_TO_ELEVEN" );

	// =============== Operational Asset: 3 stars in 5 different SO
	if ( get_num_of_levels_with_star( specOpsString, 3 ) >= 5 )
		self player_giveachievement_wrapper( "OPERATIONAL_ASSET" );
		
	// =============== Honor Roll: 1 star in 23 different SO
	if ( get_num_of_levels_with_star( specOpsString, 1 ) >= 23 )
		self player_giveachievement_wrapper( "HONOR_ROLL" );	
		
	// =============== Operative: 3 stars in 10 different SO
	if ( get_num_of_levels_with_star( specOpsString, 3 ) >= 10 )
		self player_giveachievement_wrapper( "OPERATIVE" );	
		
	// =============== Professional: 3 stars in 15 different SO
	if ( get_num_of_levels_with_star( specOpsString, 3 ) >= 15 )
		self player_giveachievement_wrapper( "PROFESSIONAL" );
}

get_total_stars( specOpsString )
{
	string_size = specOpsString.size;
	if ( string_size > level.specOpsSettings.levels.size )
		string_size = level.specOpsSettings.levels.size;
			
	specOpsSum = 0;
	for( i=0; i<string_size; i++ )
	{
		specOpsSum += max ( 0, int( specOpsString[i] ) - 1 );
	}	
	return specOpsSum;
}

get_num_of_levels_with_star( specOpsString, stars )
{
	string_size = specOpsString.size;
	if ( string_size > level.specOpsSettings.levels.size )
		string_size = level.specOpsSettings.levels.size;
		
	levels = 0;
	for( i=0; i<string_size; i++ )
	{
		if( max ( 0, int( specOpsString[i] ) - 1 ) >= stars )
			levels++;
	}		
	return levels;
}

specialops_mission_over_stats( was_success )
{
	if ( !isdefined( was_success ) || !was_success )
		return;
		
	// using map name to get dvar used for saving that map's best time
	best_time_name = tablelookup( "sp/specOpsTable.csv", 1, level.script, 9 );

	// Test maps shouldn't have to SRE out.
	if ( best_time_name == "" )
		return;
	
	// Early out the player that doesnt have the level unlocked, cause we dont give him reward
	foreach( player in level.players )
	{
		if ( !( player can_save_to_profile() ) )
		{
			/#
			PrintLn( ">> UpdateGamerProfileAll():	[ PLAYER 2 SKIPPED ALL PROFILE UPDATES DUE TO LEVEL LOCKED ]" );
			#/
			player.eog_noreward = true;
		}
	}
	
	// PS3 special handler - PS3 splitscreen, guest player always get stars when first player get stars
	if ( issplitscreen() && level.ps3 )
		level.player2.eog_noreward = false;
	
	assert( isdefined( best_time_name ) );
	assert( isdefined( level.challenge_start_time ) );
	assert( isdefined( level.challenge_end_time ) );

	// time is capped at 24 hours
	m_seconds = int( min( ( level.challenge_end_time - level.challenge_start_time ), 86400000 ) );
	
	foreach( player in level.players )
	{	
		if ( isdefined( player.eog_noreward ) && player.eog_noreward )
			continue;
			
		current_best_time = player GetLocalPlayerProfileData( best_time_name );

		if ( !isdefined( current_best_time ) )
			continue;	// non local player
			
		never_played = current_best_time == 0;
		if ( isdefined( player.finish_time ) && isdefined( level.challenge_start_time ) )
			m_seconds = int( min( ( player.finish_time - level.challenge_start_time ), 86400000 ) );
		
		if ( never_played || m_seconds < current_best_time )
			player SetLocalPlayerProfileData( best_time_name, m_seconds );
		
		if ( !never_played && m_seconds < current_best_time )
		{
			player.eog_besttime = true;
			player.eog_besttime_value = m_seconds;
		}
	}
	
	levelIndex = level.specOpsSettings maps\_endmission::getLevelIndex( level.script );

	if ( !isDefined( levelIndex ) )
	{
		// run the same mission again if the nextmission is not defiend.
		MissionSuccess( level.script );
		return;
	}
	
	// update mission difficult dvar
	level.specOpsSettings maps\_endmission::setSoLevelCompleted( levelIndex );

	foreach( player in level.players )
	{
		if ( isdefined( player.eog_noreward ) && player.eog_noreward )
			continue;
			
		missionSpecOps = player GetLocalPlayerProfileData( "missionSpecOps" );	

		if ( !isdefined( missionSpecOps ) )
			continue;			
			
		if ( missionSpecOps < levelindex + 1 )
			player SetLocalPlayerProfileData( "missionSpecOps", levelIndex + 1 );	
	}
	
	foreach( player in level.players )
	{
		if ( isdefined( player.eog_noreward ) && player.eog_noreward )
			continue;
			
		specOpsString = player GetLocalPlayerProfileData( "missionSOHighestDifficulty" );
		
		if( !isdefined( specOpsString ) )
			continue;
			
		assertex( isdefined( level.specOpsSettings ), "Special Op levels are not yet initialized in _endmission.gsc and we are already trying to save level difficulty completed data." );
		
		// specOpsString is a string of something like '0123412324200323404...' ranging from 0 to 4, for special ops we need range of 0 to 3.
		// string size can not count higher then number of levels or we will have 100%+
		string_size = specOpsString.size;
		if ( string_size > level.specOpsSettings.levels.size )
			string_size = level.specOpsSettings.levels.size;
			
		specOpsSum = 0;
		for( i=0; i<string_size; i++ )
			specOpsSum += int( max ( 0, int( specOpsString[i] ) - 1 ) );
		
		assertex( specOpsSum >= 0 && specOpsSum <= ( level.specOpsSettings.levels.size * 3 ), "More stars earned than possible!" );
		
		completion_percentage = 0;
		completion_fraction = 100 * ( ( specOpsSum ) / ( level.specOpsSettings.levels.size * 3 ) );
	
		assert( isdefined( completion_fraction ) );
		
		// round up or down
		if ( int(completion_fraction*100)%100 >= 0.5 )
			completion_percentage = int( completion_fraction ) + 1;
		else
			completion_percentage = int( completion_fraction );

		assertex( ( completion_percentage >= 0 && completion_percentage <= 100 ), "Special Ops' completion percentage [ " + completion_percentage + "% ] is outside of 0 to 100 range!" );
		
		player specialops_achievement_by_stars( specOpsString );
		
		/#
		setlevel = getdvarint( "ui_debug_setlevel" );
		if( setlevel != 0 )	
		{
			player SetLocalPlayerProfileData( "missionspecops", setlevel );
			level.specOpsSettings maps\_endmission::setSoLevelCompleted( max( 0, setlevel-1 ) );
			
			setdvar( "ui_debug_setlevel", "" );
		}
		
		upto = getdvarint( "ui_debug_setlevel_upto" );
		if( upto != 0 )	
		{
			player SetLocalPlayerProfileData( "missionspecops", upto );
			
			difficulty_string = "";
			for( i=0; i<upto; i++ )
			{
				difficulty_string += "4";
				level.specOpsSettings maps\_endmission::setSoLevelCompleted( i );
			}
			player SetLocalPlayerProfileData( "missionsohighestdifficulty", difficulty_string );
			
			setdvar( "ui_debug_setlevel_upto", "" );
		}
		
		// Debug prints
		PrintLn( ">> SO DEBUG: 					[ setlevel:" + setlevel + " setlevel_upto:" + upto + " clearall:" + getdvarint( "ui_debug_clearall" ) + " ]" );
		PrintLn( ">> SO PLAYER ID: 			[" + player GetEntityNumber() + "]" );
		PrintLn( ">> SO PERCENTAGE COMPLETED: 	[" + specOpsString + "]" );
		PrintLn( ">> SO PLAYER PERCENTAGE: 		[" + completion_percentage + "%]" );
		PrintLn( ">> SO PLAYER TOTAL STARS:		[" + specOpsSum + "%]" );
		PrintLn( ">> SO LEVEL INDEX: 			[" + level.specOpsSettings maps\_endmission::getLevelIndex( level.script ) + "]" );
		PrintLn( ">> SO LEVEL NAME: 			[" + level.script + "]" );
		PrintLn( ">> SO STARS EARNED:	 		[" + specOpsSum + "]" );
		PrintLn( ">> SO MAX LEVELS: 			[" + level.specOpsSettings.levels.size + "]" );
		#/
		
		player SetLocalPlayerProfileData( "percentCompleteSO", specOpsSum );
		//player SetLocalPlayerProfileData( "percentCompleteSO", completion_percentage );
	}
		
	UpdateGamerProfileAll();
	/#
	PrintLn( ">> UpdateGamerProfileAll(): [ CALLED ]" );
	#/
}

specialops_summary_player_choice()
{
	for ( ;; )
	{
		response = waittill_either_player();
		
		// if player chooses to return to main menu
		if ( response == "summary_closed" )
		{
			ChangeLevel( "" );
			return;
		}
		
		// if player chooses to play again
		if ( response == "summary_closed_play_again" )
		{
			ChangeLevel( level.script );
			return;
		}
	}
}

wait_all_players_are_touching( trigger_ent )
{
	for ( ;; )
	{
		trigger_ent waittill( "trigger" );

		// If not in co-op, then a simple touch is all we need.
		if ( !is_coop() )
			return;

		level.player thread waiting_message_hide();
		level.player2 thread waiting_message_hide();

		if ( !level.player IsTouching( trigger_ent ) )
		{
			level.player2 thread display_waiting_message();
			continue;
		}
		
		if ( !level.player2 IsTouching( trigger_ent ) )
		{
			level.player thread display_waiting_message();
			continue;
		}
		
		// If we get here then we've succeeded...
		break;
	}
}

wait_all_players_have_touched( trigger_ent, touch_style )
{
	player1_touched = false;
	player2_touched = false;

	for ( ;; )
	{
		trigger_ent waittill( "trigger" );

		// If not in co-op, then a simple touch is all we need.
		if ( !is_coop() )
			return;

		level.player thread waiting_message_hide();
		level.player2 thread waiting_message_hide();

		if ( level.player IsTouching( trigger_ent ) )
		{
			player1_touched = true;
			if ( !player2_touched && !level.player2 IsTouching( trigger_ent ) )
			{
				thread determine_waiting_message( level.player, touch_style );
				continue;
			}
		}

		if ( level.player2 IsTouching( trigger_ent ) )
		{
			player2_touched = true;
			if ( !player1_touched && !level.player IsTouching( trigger_ent ) )
			{
				thread determine_waiting_message( level.player2, touch_style );
				continue;
			}
		}

		// If we get here then we've succeeded...
		break;
	}
}

disable_mission_end_trigger( trigger_ent )
{
	level waittill( "special_op_terminated" );
	
	trigger_ent trigger_off();
}

determine_waiting_message( player, touch_style )
{
	switch ( touch_style )
	{
		case "all"		: player display_waiting_message(); break;
		case "any"		: player display_waiting_message(); break;
		case "freeze"	: player display_frozen_message(); break;
	}
}

display_waiting_message()
{
	self endon( "death" );
	level endon( "challenge_timer_passed" );
	level endon( "challenge_timer_expired" );
	level endon( "special_op_terminated" );

	level notify( "players_touching_hint" );
	level endon( "players_touching_hint" );

	if ( !isdefined( self ) )
		return;
		
	if ( !isdefined( self.waiting_hud ) )
	{
		self.waiting_hud = create_waiting_message( self );
	}
	else
	{
		self.waiting_hud.alpha = 1;
	}
	
	wait 0.05;
	self.waiting_hud fadeovertime( 0.25 );
	self.waiting_hud.alpha = 0;
}

display_frozen_message()
{
	if ( !isdefined( self ) )
		return;
		
	// Don't need to fade in again if already active.
	if ( isdefined( self.frozen_and_waiting ) && self.frozen_and_waiting )
		return;
		
	self.frozen_and_waiting = true;
	self EnableInvulnerability();
	self FreezeControls( true );
	self.ignoreme = true;
	
	self setBlurForPlayer( 6, 1 );

	self.waiting_hud = create_waiting_message( self );
}	

create_waiting_message( player )
{
	self notify( "rebuilding_waiting_hud" );
	self endon( "rebuilding_waiting_hud" );

	waiting_hud = maps\_specialops::so_create_hud_item( 3, 0, &"SPECIAL_OPS_WAITING_OTHER_PLAYER", player );
	waiting_hud.alignX = "center";
	waiting_hud.horzAlign = "center";
	waiting_hud set_hudelem_blue();

	thread waiting_message_delete_on_so_end( waiting_hud );

	return waiting_hud;
}

waiting_message_hide()
{
	if ( !isdefined( self ) )
		return;
		
	if ( !isdefined( self.waiting_hud ) )
		return;

	if ( isdefined( self.frozen_and_waiting ) && self.frozen_and_waiting )
		return;
		
	self.waiting_hud fadeovertime( 0.25 );
	self.waiting_hud.alpha = 0;
}

waiting_message_delete_on_so_end( waiting_hud )
{
	self endon( "rebuilding_waiting_hud" );
	
	level waittill( "special_op_terminated" );

	if ( isdefined( waiting_hud ) )
		waiting_hud Destroy();
}
	
disable_saving()
{
	flag_set( "disable_autosaves" );

	for ( ;; )
	{
		flag_wait( "can_save" );
		flag_clear( "can_save" );
	}
}

disable_escape_warning()
{
	if ( flag( "player_has_escaped" ) )
	{
		return true;
	}
		
	if ( self is_touching_escape_trigger() )
	{
		return false;
	}

//	self.escape_hint_active = undefined;
			
//	self.escape_hint_active = undefined;
//	if ( isdefined( self.ping_escape_splash ) )
//		self.ping_escape_splash Destroy();
	return true;
}

is_touching_escape_trigger()
{
	if ( !IsDefined( level.escape_warning_triggers ) )
	{
		return false;
	}

	foreach ( trigger in level.escape_warning_triggers )
	{
		if ( self IsTouching( trigger ) )
		{
			return true;
		}
	}	

	return false;
}

ping_escape_warning()
{
	if ( isdefined( self.ping_escape_splash ) )
		return;

	self endon( "death" );
	
	self.ping_escape_splash = maps\_specialops::so_create_hud_item( 3.5, 0, &"SPECIAL_OPS_ESCAPE_WARNING", self );
	self.ping_escape_splash.alignx = "center";
	self.ping_escape_splash.horzAlign = "center";
//	self.ping_escape_splash set_hudelem_red();

	while ( ping_escape_warning_valid() )
	{
//		self PlayLocalSound( "coop_player_exit_warning" );
		self.ping_escape_splash.alpha = 1;
		self.ping_escape_splash FadeOverTime( 1 ) ;
		self.ping_escape_splash.alpha = 0.5;
		
		self.ping_escape_splash.fontscale = 1.5;
		self.ping_escape_splash ChangeFontScaleOverTime( 1 );
		self.ping_escape_splash.fontscale = 1;
		
		wait 1;
	}

	self.ping_escape_splash.alpha = 0.5;
	self.ping_escape_splash FadeOverTime( 0.25 );
	self.ping_escape_splash.alpha = 0;
	wait 0.25;

	self.escape_hint_active = undefined;
	
	if ( isdefined( self.ping_escape_splash ) )
		self.ping_escape_splash Destroy();
}

ping_escape_warning_valid()
{
	if ( flag( "special_op_terminated" ) )
		return false;

//	if ( !isdefined( self.escape_hint_active ) )
//	{
//		return false;
//	}

	if ( !self is_touching_escape_trigger() )
	{
		return false;
	}
		
	return true;
}

so_dialog_play( dialog, wait_time, force_stop )
{
	assertex( isdefined( dialog ), "so_dialog_play() requires valid dialog to be passed in." );
	if ( isdefined( wait_time ) )
		wait wait_time;

	// This isn't a good long term solution to SO spam. The Battle Chatter stuff (reviving) needs to be switched
	// to the actual battle chatter system.
	if ( isdefined( force_stop ) && force_stop )
		radio_dialogue_stop();
	radio_dialogue( dialog );
}

specialops_dialog_init()
{
	// Let's do this.
	// Ready up.
	level.scr_radio[ "so_tf_1_plyr_prep" ]			= "so_tf_1_plyr_prep";

	// That's the way it's done. 
	// Good job team.
	// Mission accomplished.
	level.scr_radio[ "so_tf_1_success_generic" ]	= "so_tf_1_success_generic";

	// Not bad, but I've seen better.
	// Well done, but you can do better.
	// Not the best, but you made it.
	level.scr_radio[ "so_tf_1_success_jerk" ]		= "so_tf_1_success_jerk";

	//Nicely done, you beat your previous best.
	//A new personal record, great work.
	//You beat your previous best, keep it up.
	//Excellent job, a new personal best.
	level.scr_radio[ "so_tf_1_success_best" ]		= "so_tf_1_success_best";

	// Mission failed. We’ll get 'em next time.
	// We need to rethink our strategy. Let's run it again.
	level.scr_radio[ "so_tf_1_fail_generic" ]		= "so_tf_1_fail_generic";

	// Well that was a disaster! Let's try it again.
	// Bloody 'ell, we just got our arses kicked.
	level.scr_radio[ "so_tf_1_fail_generic_jerk" ]	= "so_tf_1_fail_generic_jerk";

	// We ran outta time. Keep an eye the clock.
	// Too slow mate. Next time watch the clock, eh?
	level.scr_radio[ "so_tf_1_fail_time" ]			= "so_tf_1_fail_time";

	// We win as a team, we lose as a team. Got it?
	// Look - we work as a team. No one gets left behind!
	level.scr_radio[ "so_tf_1_fail_bleedout" ]		= "so_tf_1_fail_bleedout";

	// We're running out of time!
	// The clock's ticking...
	// Not much time left!
	level.scr_radio[ "so_tf_1_time_generic" ]		= "so_tf_1_time_generic";

	// Time's running out! Go! Go! Go!
	// We're almost outta time! Move! Move!
	// Time's almost up! This is gonna be close!!
	level.scr_radio[ "so_tf_1_time_hurry" ] 		= "so_tf_1_time_hurry";

	// Watch your fire, avoid civilians!
	// Civilian casualties are unacceptable!
	// Careful, you're killing innocent civilians!
	level.scr_radio[ "so_tf_1_civ_kill_warning" ] 	= "so_tf_1_civ_kill_warning";
	
	// 5 more.
	// 5 left.
	// 5 remaining
	level.scr_radio[ "so_tf_1_progress_5more" ]		= "so_tf_1_progress_5more";

	// 4 more.
	// 4 left.
	// 4 remaining
	level.scr_radio[ "so_tf_1_progress_4more" ]		= "so_tf_1_progress_4more";

	// 3 more.
	// 3 left.
	// 3 remaining
	level.scr_radio[ "so_tf_1_progress_3more" ]		= "so_tf_1_progress_3more";

	// 2 more.
	// 2 left.
	// 2 remaining
	level.scr_radio[ "so_tf_1_progress_2more" ]		= "so_tf_1_progress_2more";

	// 1 more.
	// 1 left.
	// 1 remaining
	level.scr_radio[ "so_tf_1_progress_1more" ]		= "so_tf_1_progress_1more";
	
	// Cutting it close, need to pick up the pace.
	// You're running behind, hurry up or you won't make it.
	// Pay attention to the time, you're moving too slow.
	level.scr_radio[ "so_tf_1_time_status_late" ]	= "so_tf_1_time_status_late";

	// Looking good, keep up this pace.
	// Your time is solid, keep it up.
	// Keep going, you're making good time.
	level.scr_radio[ "so_tf_1_time_status_good" ]	= "so_tf_1_time_status_good";

	// 25% done… keep going.
	// You've made it a quarter of the way, don't stop.
	// 25% down, 75% to go.
	level.scr_radio[ "so_tf_1_progress_3quarter" ]	= "so_tf_1_progress_3quarter";

	// Hallfway there.
	// You're halfway done.
	// Halfway through the mission.
	level.scr_radio[ "so_tf_1_progress_half" ]		= "so_tf_1_progress_half";

	// Getting close, keep it up.
	// You're doing well, almost done.
	// Just a little bit left, keep going.
	level.scr_radio[ "so_tf_1_progress_quarter" ]	= "so_tf_1_progress_quarter";
}

set_hudelem_white()
{
	self maps\_specialops::set_hud_white();
}

set_hudelem_blue()
{
	self maps\_specialops::set_hud_blue();
}

set_hudelem_green()
{
	self maps\_specialops::set_hud_green();
}

set_hudelem_yellow()
{
	self maps\_specialops::set_hud_yellow();
}

set_hudelem_red()
{
	self maps\_specialops::set_hud_red();
}

so_hud_pulse_single( scale_start, scale_end, time )
{
	self endon( "update_hud_pulse" );
	self endon( "destroying" );
	self endon( "death" );

	self.fontscale = scale_start;
	self changefontscaleovertime( time );
	self.fontscale = scale_end;
	
	wait time;
}

so_hud_pulse_loop()
{
	self endon( "update_hud_pulse" );
	self endon( "destroying" );
	self endon( "death" );

	if ( self.pulse_start_big )
		so_hud_pulse_single( self.pulse_scale_big, self.pulse_scale_loop_normal, self.pulse_time );
		
	while( isdefined( self.pulse_loop ) && self.pulse_loop )
	{
		so_hud_pulse_single( self.pulse_scale_loop_normal, self.pulse_scale_loop_big, self.pulse_time_loop );
		so_hud_pulse_single( self.pulse_scale_loop_big, self.pulse_scale_loop_normal, self.pulse_time_loop );
	}
}

so_hud_pulse_init()
{
	if ( !isdefined( self ) )
		return false;
	
	// Bang defaults
	if ( !isdefined( self.pulse_time ) )
		self.pulse_time = 0.5;

	if ( !isdefined( self.pulse_scale_normal ) )
		self.pulse_scale_normal = 1.0;

	if ( !isdefined( self.pulse_scale_big ) )
		self.pulse_scale_big = 1.6;

	// Looping defaults
	if ( !isdefined( self.pulse_loop ) )
		self.pulse_loop = false;

	if ( !isdefined( self.pulse_time_loop ) )
		self.pulse_time_loop = 1.0;
		
	if ( !isdefined( self.pulse_scale_loop_normal ) )
		self.pulse_scale_loop_normal = 1.0;
		
	if ( !isdefined( self.pulse_scale_loop_big ) )
		self.pulse_scale_loop_big = 1.15;

	if ( !isdefined( self.pulse_start_big ) )
		self.pulse_start_big = true;

	// Successful initialization!		
	return true;
}

specialops_detect_death()
{
	level endon( "special_op_terminated" );
	
	array_thread( level.players, ::specialops_detect_player_death );
		
	level waittill( "so_player_has_died" );
	
	level.challenge_end_time = gettime();
	MissionFailedWrapper();
}

specialops_detect_player_death()
{
	level endon( "special_op_terminated" );

	self waittill( "death" );

	level notify( "so_player_has_died" );
}

waittill_either_player()
{
	if ( !flag_exist( "summary_response" ) )
		flag_init( "summary_response" );
	
	if( level.players.size > 1 )
	{
		// We must clear this each time we get in here, incase a menuresponse previously was not desired
		// example, options menuresponse or "back" (online player in pause menu when everyone died)
		// This will allow us to return to the EOG fine.
		flag_clear( "summary_response" );

		thread waittill_player_respond( 0 );
		thread waittill_player_respond( 1 );
		
		flag_wait( "summary_response" );
		return level.summary_response;
	}
	else
	{
		level.players[0] waittill( "menuresponse", menu, response );
		return response;
	}
}

waittill_player_respond( player_num )
{
	level endon( "summary_response" );
	level.players[ player_num ] waittill( "menuresponse", menu, response );
	level.summary_response = response;
	flag_set( "summary_response" );
}

so_special_failure_hint_reset_dvars( icon_dvar )
{
	setdvar( "ui_dog_death", 0 );
	setdvar( "ui_vehicle_death", 0 );
	setdvar( "ui_destructible_death", 0 );
	setdvar( "ui_barrel_death", 0 );
	setdvar( "ui_grenade_death", 0 );
	setdvar( "ui_time_failure", 0 );
	setdvar( "ui_ff_death", 0 );
	setdvar( "ui_juggernaut_death", 0 );
	setdvar( "ui_bled_out", 0 );
	setdvar( "ui_icon_partner", 0 );
	setdvar( "ui_icon_obj", 0 );
	setdvar( "ui_icon_obj_offscreen", 0 );
	setdvar( "ui_icon_stars", 0 );
	setdvar( "ui_icon_claymore", 0 );
	setdvar( "ui_icon_stealth_stance", 0 );
	
	if ( isdefined( icon_dvar ) )
		setdvar( icon_dvar, 1 );
}

so_special_failure_hint()
{
	so_special_failure_hint_reset_dvars();
	
	foreach( player in level.players )
	{
		player thread maps\_load::player_throwgrenade_timer();
		player thread so_special_death_hint_tracker();
	}
	
	level waittill( "so_generate_deathquote" );
	maps\_quotes::setDeadQuote_so();
}

so_special_death_hint_tracker()
{
	level endon( "so_special_failure_hint_set" );
	
	// NOTE: weapon may be undefined, so be sure to check for it if you use it.
	self waittill( "death", attacker, cause, weapon );

	if ( isdefined( self.coop_death_reason ) )
	{
		attacker = self.coop_death_reason[ "attacker" ];
		cause = self.coop_death_reason[ "cause" ];
		weapon = self.coop_death_reason[ "weapon_name" ];
	}

	if ( so_claymore_death( cause, weapon ) )
		return;

	if ( so_friendly_fire_death( attacker ) )
		return;

	if ( so_radiation_death( attacker ) )
		return;
		
	if ( so_dog_death( attacker ) )
		return;
		
	if ( so_juggernaut_death( attacker ) )
		return;
	
	if ( so_grenade_suicide_death( cause ) )
		return;
		
	if ( so_destructible_death( attacker, cause ) )
		return;

	if ( so_exploding_barrel_death( cause ) )
		return;

	if ( so_grenade_regular_death( cause ) )
		return;
		
	if ( so_vehicle_death( attacker, cause ) )
		return;
}

so_claymore_death( cause, weapon )
{
	if ( !IsDefined( cause ) )
	{
		return false;
	}

	if ( !IsDefined( weapon ) || ( IsDefined( weapon ) && weapon != "claymore" ) )
	{
		return false;
	}

	// No message if killed by a claymore

	return true;
}

so_friendly_fire_death( attacker )
{
	if ( !is_coop() )
		return false;
		
	if ( !isdefined( attacker ) )
		return false;
		
	other_player = get_other_player( self );
	if ( other_player != attacker )
		return false;
		
	so_special_failure_hint_set( "@DEADQUOTE_SO_FRIENDLY_FIRE_KILL", "ui_ff_death" );
	return true;
}

so_radiation_death( attacker )
{
	if ( !isdefined( attacker ) || ( attacker.classname != "worldspawn" ) )
		return false;
	
	if ( !isdefined( self.radiationDeath ) || !self.radiationDeath )
		return false;

	so_special_failure_hint_set( "@SCRIPT_RADIATION_DEATH" );
	return true;
}

so_dog_death( attacker )
{
	if ( !isdefined( attacker ) )
		return false;
		
	if ( !isdefined( attacker.weapon ) )
		return false;

	if ( attacker.weapon != "dog_bite" )
		return false;
	
	switch( level.dog_death_type )
	{
		case "soon":	so_special_failure_hint_set( "@NEW_DOG_DEATH_TOO_SOON_ALT", "ui_dog_death" ); break;
		case "late":	so_special_failure_hint_set( "@NEW_DOG_DEATH_TOO_LATE_ALT", "ui_dog_death" ); break;
		default:		so_special_failure_hint_set( "@NEW_DOG_DEATH_DO_NOTHING_ALT", "ui_dog_death" ); break;
	}
	
	return true;
}

so_juggernaut_death( attacker )
{
	if ( !isdefined( attacker ) )
		return false;
	
	if ( !isdefined( attacker.juggernaut ) )
		return false;

	deadquotes = [];

	deadquotes[ 0 ] = "@DEADQUOTE_JUGGERNAUT_FLASHBANGS";
	deadquotes[ 1 ] = "@DEADQUOTE_JUGGERNAUT_HIGHCALIBER_WEAPONS";
	deadquotes[ 2 ] = "@DEADQUOTE_JUGGERNAUT_HEADSHOTS";
	deadquotes[ 3 ] = "@DEADQUOTE_JUGGERNAUT_EXPLOSIVES";
	deadquotes[ 4 ] = "@DEADQUOTE_JUGGERNAUT_CORNERED";

	so_special_failure_hint_set_array( deadquotes, "ui_juggernaut_death" );

	return true;
}

so_destructible_death( attacker, cause )
{
	if ( !isdefined( cause ) )
		return false;
		
	if ( !isdefined( attacker ) )
		return false;	
				
	if ( cause != "MOD_EXPLOSIVE" )
		return false;
		
	if ( !isdefined( attacker.destructible_type ) )
		return false;
	
	if ( issubstr( attacker.destructible_type, "vehicle" )  )
	{
		// You were killed by an exploding vehicle. Vehicles on fire are likely to explode.
		so_special_failure_hint_set( "@SCRIPT_EXPLODING_VEHICLE_DEATH", "ui_vehicle_death" );
	}
	else
	{
		// You were killed by an explosion.\nSome burning objects can explode.
		so_special_failure_hint_set( "@SCRIPT_EXPLODING_DESTRUCTIBLE_DEATH", "ui_destructible_death" );
	}

	return true;
}

so_exploding_barrel_death( cause )
{
	if ( !isdefined( cause ) )
		return false;
			
	if ( cause != "MOD_EXPLOSIVE" )
		return false;
		
	// check if the death was caused by a barrel
	// have to check time and location against the last explosion because the attacker isn't the
	// barrel because the ent that damaged the barrel is passed through as the attacker instead
	if ( !isdefined( level.lastExplodingBarrel ) )
		return false;

	// killed the same frame a barrel exploded
	if ( getTime() != level.lastExplodingBarrel[ "time" ] )
		return false;

	// within the blast radius of the barrel that exploded
	d = distance( self.origin, level.lastExplodingBarrel[ "origin" ] );
	if ( d > level.lastExplodingBarrel[ "radius" ] )
		return false;

	// You were killed by an exploding barrel. Red barrels will explode when shot.
	so_special_failure_hint_set( "@SCRIPT_EXPLODING_BARREL_DEATH", "ui_barrel_death" );

	return true;
}

so_grenade_suicide_death( cause )
{
	if ( !isdefined( cause ) )
		return false;
			
	if ( cause != "MOD_SUICIDE" )
		return false;
		
	// magic number copied from fraggrenade asset.
	if ( ( self.lastgrenadetime - gettime() ) > 3.5 * 1000 )
		return false;

	// You died holding a grenade for too long.
	// Holding ^3[{+frag}]^7 allows you to cook off live grenades.
	so_special_failure_hint_set( "@SCRIPT_GRENADE_SUICIDE_COMBINED" );
	
	return true;
}

so_grenade_regular_death( cause )
{
	if ( !isdefined( cause ) )
	{
		return false;
	}
			
	if ( cause != "MOD_GRENADE" && cause != "MOD_GRENADE_SPLASH" )
	{
		return false;
	}

	so_special_failure_hint_set( "@SCRIPT_GRENADE_DEATH", "ui_grenade_death" );

	return true;
}

so_vehicle_death( attacker, cause )
{
	if ( !isdefined( cause ) )
		return false;
		
	if ( !isdefined( attacker ) )
		return false;	
				
	if ( cause != "MOD_CRUSH" )
		return false;
		
	if ( attacker.code_classname != "script_vehicle" )
		return false;
		
	// You were run over. Keep on eye out for enemy vehicles on the move.
	so_special_failure_hint_set( "@DEADQUOTE_SO_RUN_OVER_BY_VEHICLE" );
	return true;
}

so_special_failure_hint_set( quote, icon_dvar )
{
	maps\_specialops::so_force_deadquote( quote, icon_dvar );
	level notify( "so_special_failure_hint_set" );
}

so_special_failure_hint_set_array( quotes, icon_dvar )
{
	maps\_specialops::so_force_deadquote_array( quotes, icon_dvar );
	level notify( "so_special_failure_hint_set" );
}
