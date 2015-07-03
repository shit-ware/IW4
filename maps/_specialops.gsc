#include common_scripts\utility;
#include maps\_utility;
#include maps\_hud_util;
#include maps\_specialops_code;

specialops_init()
{
	if ( !isdefined( level.so_override ) )
		level.so_override = [];

	// Be sure to enable the friendlyfire warnings for all SO maps, unless already specified not to.
	if ( !IsDefined( level.friendlyfire_warnings ) )
	{
		level.friendlyfire_warnings = true;
	}

	// SP Friendly Fire doesn't apply to SOs.
	level.no_friendly_fire_penalty = true;

	// End game summaries
	precachemenu( "sp_eog_summary" );
	precachemenu( "coop_eog_summary" );
	precachemenu( "coop_eog_summary2" );

	// End game shellshock, just mutes the environment sounds
	PrecacheShellshock( "so_finished" );

	precacheShader( "hud_show_timer" );
//	PreCacheShader( "hud_star69icon" );

	so_precache_strings();

	foreach ( player in level.players )
	{
		player.so_hud_show_time = gettime() + ( so_standard_wait() * 1000 );
		player ent_flag_init( "so_hud_can_toggle" );
	}
		
	// Default timer settings
	level.challenge_time_nudge = 30;	// Yellow warning at 30 seconds
	level.challenge_time_hurry = 10;	// Red Hurry Up at 15 seconds
	
	// Function to handle crushing players when inside of a clip.
	level.func_destructible_crush_player = ::so_crush_player;
	
	// Default friendly fire scaler.
	setsaveddvar( "g_friendlyfireDamageScale", 2 );
	
	if ( isdefined( level.so_compass_zoom ) )
	{
		compass_dist = 0;
		switch ( level.so_compass_zoom )
		{
			case "close":	compass_dist = 1500; break;
			case "far":		compass_dist = 6000; break;
			default:		compass_dist = 3000; break;
		}
		if ( !issplitscreen() )
			compass_dist += ( compass_dist * 0.1 );	// Additional 10% in non-splitscreen.
		setsaveddvar( "compassmaxrange", compass_dist );
	}
	
	// Flag Inits
	flag_init( "challenge_timer_passed" );
	flag_init( "challenge_timer_expired" );
	flag_init( "special_op_succeeded" );
	flag_init( "special_op_failed" );
	flag_init( "special_op_terminated" );
	flag_init( "special_op_p1ready" );
	flag_init( "special_op_p2ready" );
	flag_init( "special_op_no_unlink" );

	// Savegames
	thread disable_saving();
	thread specialops_detect_death();

	// Dialog
	specialops_dialog_init();
	if ( is_coop() )
		maps\_specialops_battlechatter::init();

	// a little easier/different in solo play
	if ( !is_coop() )
		set_custom_gameskill_func( maps\_gameskill::solo_player_in_special_ops );
		
	// Clear out the deadquote.
	level.so_deadquotes_chance = 0.5;	// 50/50 chance of using level specific deadquotes.
	setdvar( "ui_deadquote", "" );
	thread so_special_failure_hint();
	
	// For no longer opening level selection in spec ops after returning from a splitscreen game
	setdvar( "ui_skip_level_select", "1" );
	
	pick_starting_location_so();
	level thread setSoUniqueSavedDvars();
}

setSoUniqueSavedDvars()
{
	setsaveddvar( "hud_fade_ammodisplay", 	30 );
	setsaveddvar( "hud_fade_stance", 		30 );
	setsaveddvar( "hud_fade_offhand", 		30 );
	setsaveddvar( "hud_fade_compass", 		30 );
}

so_precache_strings()
{
	PrecacheString( &"SPECIAL_OPS_TIME_NULL" );
	PrecacheString( &"SPECIAL_OPS_TIME" );
	PrecacheString( &"SPECIAL_OPS_WAITING_P1" );
	PrecacheString( &"SPECIAL_OPS_WAITING_P2" );
	PrecacheString( &"SPECIAL_OPS_REVIVE_NAG_HINT" );
	PrecacheString( &"SPECIAL_OPS_CHALLENGE_SUCCESS" );
	PrecacheString( &"SPECIAL_OPS_CHALLENGE_FAILURE" );
	PrecacheString( &"SPECIAL_OPS_FAILURE_HINT_TIME" );
	PrecacheString( &"SPECIAL_OPS_ESCAPE_WARNING" );
	PrecacheString( &"SPECIAL_OPS_ESCAPE_SPLASH" );
	PrecacheString( &"SPECIAL_OPS_WAITING_OTHER_PLAYER" );
	PrecacheString( &"SPECIAL_OPS_STARTING_IN" );
	PrecacheString( &"SPECIAL_OPS_UI_TIME" );
	PrecacheString( &"SPECIAL_OPS_UI_KILLS" );
	PrecacheString( &"SPECIAL_OPS_UI_DIFFICULTY" );
	PrecacheString( &"SPECIAL_OPS_UI_PLAY_AGAIN" );
	PrecacheString( &"SPECIAL_OPS_DASHDASH" );
	PrecacheString( &"SPECIAL_OPS_HOSTILES" );
	PrecacheString( &"SPECIAL_OPS_INTERMISSION_WAVENUM" );
	PrecacheString( &"SPECIAL_OPS_INTERMISSION_WAVEFINAL" );
	PrecacheString( &"SPECIAL_OPS_WAVENUM" );
	PrecacheString( &"SPECIAL_OPS_WAVEFINAL" );
	PrecacheString( &"SPECIAL_OPS_PRESS_TO_CANCEL" );
	PrecacheString( &"SPECIAL_OPS_PLAYER_IS_READY" );
	PrecacheString( &"SPECIAL_OPS_PRESS_TO_START" );
	PrecacheString( &"SPECIAL_OPS_PLAYER_IS_NOT_READY" );
	PrecacheString( &"SPECIAL_OPS_EMPTY" );
}

// Call this to get whatever the standard time before we turn the hud on is.
so_standard_wait()
{
	return 4;
}

specialops_remove_unused()
{
	entarray = getentarray();
	if ( !isdefined( entarray ) )
		return;

	special_op_state = is_specialop();
	foreach ( ent in entarray )
	{
		if ( ent specialops_remove_entity_check( special_op_state ) )
			ent Delete();
	}
	
	// reset hint dvars so they don't cross over into SP
	so_special_failure_hint_reset_dvars();
}

/*
=============
///ScriptDocBegin
"Name: enable_triggered_start( <challenge_id_start> )"
"Summary: Waits until the specified trigger is triggered, and then sets the flag which is used to kick off challenges."
"Module: Utility"
"MandatoryArg: <challenge_id_start>: Name of the flag *and* trigger that is used to start off the challenge."
"Example: enable_triggered_start( "challenge_start" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
enable_triggered_start( challenge_id_start )
{
	level endon( "challenge_timer_expired" );

	trigger_ent = getent( challenge_id_start, "script_noteworthy" );
	AssertEx( isdefined( trigger_ent ), "challenge_id (" + challenge_id_start + ") was unable to match with a valid trigger." );
	
	trigger_ent waittill( "trigger" );
	flag_set( challenge_id_start );
}

/*
=============
///ScriptDocBegin
"Name: enable_triggered_complete( <challenge_id> , <challenge_id_complete> , <touch_style> )"
"Summary: Waits for all players in the game to be touching the trigger, then sets the challenge complete flag."
"MandatoryArg: <challenge_id>: Name of the trigger all players need to be touching. A matching flag will be set to true to enable any additional needed entities."
"MandatoryArg: <challenge_id_complete>: Flag to set once all players are touching the trigger."
"OptionalArg: <touch_style>: Method of touching to test. "all" = all players must be touching at the same time. "any" = all players must have touched it at some point, but don't need to currently. "freeze" = when a player touches the trigger freeze them and wait for the others."
"Module: Utility"
"Example: enable_triggered_complete( "challenge_trigger", "challenge_complete", "freeze" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
enable_triggered_complete( challenge_id, challenge_id_complete, touch_style )
{
	level endon( "challenge_timer_expired" );

	flag_set( challenge_id );
	
	if ( !isdefined( touch_style ) )
		touch_style = "freeze";

	trigger_ent = getent( challenge_id, "script_noteworthy" );
	AssertEx( isdefined( trigger_ent ), "challenge_id (" + challenge_id + ") was unable to match with a valid trigger." );
	thread disable_mission_end_trigger( trigger_ent );
	
	switch ( touch_style )
	{
		case "all"		: wait_all_players_are_touching( trigger_ent ); break;
		case "any"		: wait_all_players_have_touched( trigger_ent, touch_style ); break;
		case "freeze"	: wait_all_players_have_touched( trigger_ent, touch_style ); break;
	}

	level.challenge_end_time = gettime();
	flag_set( challenge_id_complete );
}

/*
=============
///ScriptDocBegin
"Name: fade_challenge_in( <wait_time>, <doDialogue> )"
"Summary: Simple fade in for use at the start of challenges without anything special for their intro."
"Module: Utility"
"OptionalArg: <wait_time>: If defined will wait on black for specified time."
"OptionalArg: <doDialogue>: Sets whether the 'ready up' dialogue will play after fading the screen up."
"Example: fade_challenge_in();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
fade_challenge_in( wait_time, doDialogue )
{
	if ( !isdefined( wait_time ) )
		wait_time = 0.5;
	
	alpha = 1;
	if ( isdefined( level.so_waiting_for_players_alpha ) )
		alpha = level.so_waiting_for_players_alpha;
	screen_fade = create_client_overlay( "black", alpha );

	wait wait_time;

	screen_fade thread fade_over_time( 0, 1 );
	wait 0.75;
	
	if( !IsDefined( doDialogue ) || ( IsDefined( doDialogue ) && doDialogue ) )
	{
		thread so_dialog_ready_up();
	}
}

/*
=============
///ScriptDocBegin
"Name: fade_challenge_out( <challenge_id> )"
"Summary: Freezes players, fades out music, fades out the scene, and if requested posts an end of game summary."
"Module: Utility"
"OptionalArg: <challenge_id>: Flag to wait to be set before completing the challenge."
"Example: fade_challenge_out( true, "challenge_complete" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
fade_challenge_out( challenge_id, skipDialog )
{
	if ( !isdefined( skipDialog ) )
		skipDialog = false;
	
	if ( isdefined( challenge_id ) )
		flag_wait( challenge_id );
	
	if ( !skipDialog )
		thread so_dialog_mission_success();	

	specialops_mission_over_setup( true );
	
	setdvar( "ui_mission_success", 1 );
	maps\_endmission::coop_eog_summary();

	specialops_summary_player_choice();
}

/*
=============
///ScriptDocBegin
"Name: enable_countdown_timer( <time_wait>, <set_start_time>, <message>, <timer_draw_delay> )"
"Summary: Creates a timer on the screen that countsdown and marks the start of the challenge time when the timer has expired."
"Module: Utility"
"MandatoryArg: <time_wait>: The amount of time to count down from and wait."
"OptionalArg: <set_start_time>: If true, then will set level.challenge_start_time once the timer completes."
"OptionalArg: <message>: Optional message to display."
"OptionalArg: <timer_draw_delay>: When set, will pause for this long before drawing the timer after the message."
"Example: enable_start_countdown( 10 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
enable_countdown_timer( time_wait, set_start_time, message, timer_draw_delay )
{
	level endon( "special_op_terminated" );
	
	if ( !isdefined( message ) )
		message = &"SPECIAL_OPS_STARTING_IN";
	
	hudelem = so_create_hud_item( 0, so_hud_ypos(), message );
	hudelem SetPulseFX( 50, time_wait * 1000, 500 );

	hudelem_timer = so_create_hud_item( 0, so_hud_ypos() );
	hudelem_timer thread show_countdown_timer_time( time_wait, timer_draw_delay );
	
	wait time_wait;
	level.player PlaySound( "arcademode_zerodeaths" );
	
	if ( isdefined( set_start_time ) && set_start_time )
		level.challenge_start_time = gettime();

	thread destroy_countdown_timer( hudelem, hudelem_timer );
}

destroy_countdown_timer( hudelem, hudelem_timer )
{
	wait 1;		
	hudelem Destroy();
	hudelem_timer Destroy();
}

show_countdown_timer_time( time_wait, delay )
{
	self.alignX = "left";
	self settenthstimer( time_wait );
	self.alpha = 0;

	if ( !isdefined( delay ) )
		delay = 0.625;
	wait delay;
	time_wait = int( ( time_wait - delay ) * 1000 );

	self SetPulseFX( 50, time_wait, 500 );
	self.alpha = 1;
}

/*
=============
///ScriptDocBegin
"Name: enable_challenge_timer( <start_flag> , <passed_flag> , <message> )"
"Summary: Will put up an on screen timer that counts down if level.challenge_time_limit is set, otherwise counts up from 0:00.0."
"Module: Utility"
"MandatoryArg: <start_flag>: Flag that the script will wait for before starting the timer."
"MandatoryArg: <passed_flag>: Flag that the script will wait for to determine challenge success and stop the timer."
"OptionalArg: <message>: Custom message you want displayed in front of the timer."
"Example: enable_challenge_timer( "player_reached_start", "player_reached_end", "Time remaining: " );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
enable_challenge_timer( start_flag, passed_flag, message )
{
	assertex( isdefined( passed_flag ), "display_challenge_timer_down() needs a valid passed_flag." );

	if ( isdefined( start_flag ) )
	{	
		if ( !flag_exist( start_flag ) )
			flag_init( start_flag );
		level.start_flag = start_flag;
	}
	
	if ( isdefined( passed_flag ) )
	{	
		if ( !flag_exist( passed_flag ) )
			flag_init( passed_flag );
		level.passed_flag = passed_flag;
	}
	
	if ( !isdefined( message ) )
		message = &"SPECIAL_OPS_TIME";

	if ( !isdefined( level.challenge_time_beep_start ) )
		level.challenge_time_beep_start = level.challenge_time_hurry;
	level.so_challenge_time_beep = level.challenge_time_beep_start + 1;

	foreach ( player in level.players )
		player thread challenge_timer_player_setup( start_flag, passed_flag, message );
}

/*
=============
///ScriptDocBegin
"Name: so_wait_for_players_ready( <so_wait_for_players_ready> )"
"Summary: Waits until both players have indicated they are ready to begin the mission. Only for online co-op matches since they can't pause."
"Module: Utility"
"Example: so_wait_for_players_ready();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_wait_for_players_ready()
{
	// Disabled entirely for now.
	if ( !isdefined( level.so_enable_wait_for_players ) )
		return;
		
	if ( !is_coop() || issplitscreen() )
		return;

	level.so_waiting_for_players = true;
	level.so_waiting_for_players_alpha = 0.85;

	level.player thread so_wait_for_player_ready( "special_op_p1ready", 2 );
	level.player2 thread so_wait_for_player_ready( "special_op_p2ready", 3.25 );

	screen_hold = create_client_overlay( "black", 1 );
	screen_hold fade_over_time( level.so_waiting_for_players_alpha, 1 );

	while ( !flag( "special_op_p1ready" ) || !flag( "special_op_p2ready" ) )
		wait 0.05;

	hold_time = 1;
	
	level.player thread so_wait_for_player_ready_cleanup( hold_time );
	level.player2 thread so_wait_for_player_ready_cleanup( hold_time );

	wait hold_time;
	
	screen_hold Destroy();
	level.so_waiting_for_players = undefined;
}

so_wait_for_player_ready( my_flag, y_line )
{
	self endon( "stop_waiting_start" );

	self freezecontrols( true );
	self disableweapons();
	
	self.waiting_to_start_hud = so_create_hud_item( 0, 0, &"SPECIAL_OPS_PRESS_TO_START", self, true );
	self.waiting_to_start_hud.alignx = "center";
	self.waiting_to_start_hud.horzAlign = "center";

	self.ready_indication_hud = so_create_hud_item( y_line, 0, &"SPECIAL_OPS_PLAYER_IS_NOT_READY", undefined, true );
	self.ready_indication_hud.alignx = "center";
	self.ready_indication_hud.horzAlign = "center";
	self.ready_indication_hud settext( self.playername );
	self.ready_indication_hud set_hud_yellow();

	// Need a tiny wait in order for the blur to stick.
	wait 0.05;
	self setBlurForPlayer( 6, 0 );

	NotifyOnCommand( self.unique_id + "_is_ready", "+gostand" );
	NotifyOnCommand( self.unique_id + "_is_not_ready", "+stance" );
	
	while ( 1 )
	{
		self waittill( self.unique_id + "_is_ready" );
		flag_set( my_flag );
		self PlaySound( "so_player_is_ready" );
		self.waiting_to_start_hud.label = &"SPECIAL_OPS_PRESS_TO_CANCEL";
		self.ready_indication_hud so_hud_pulse_success( &"SPECIAL_OPS_PLAYER_IS_READY" );
		
		self waittill( self.unique_id + "_is_not_ready" );
		flag_clear( my_flag );
		self PlaySound( "so_player_not_ready" );
		self.waiting_to_start_hud.label = &"SPECIAL_OPS_PRESS_TO_START";
		self.ready_indication_hud so_hud_pulse_warning( &"SPECIAL_OPS_PLAYER_IS_NOT_READY" );
	}
}

so_wait_for_player_ready_cleanup( hold_time )
{
	self notify( "stop_waiting_start" );
	self.waiting_to_start_hud thread so_remove_hud_item( true );
	
	wait hold_time;
	
	self.ready_indication_hud thread so_remove_hud_item( false, true );
	self freezecontrols( false );
	self enableweapons();
	self setBlurForPlayer( 0, 0.5 );
}

/*
=============
///ScriptDocBegin
"Name: attacker_is_p1( <attacker> )"
"Summary: Returns true if the attacker was player 1."
"Module: Utility"
"MandatoryArg: <attacker>: Entity to test against player 1."
"Example: credit_player_1 = attacker_is_p1( attacker );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
attacker_is_p1( attacker )
{
	if ( !isdefined( attacker ) )
		return false;
	
	return attacker == level.player;
}

/*
=============
///ScriptDocBegin
"Name: attacker_is_p2( <attacker> )"
"Summary: Returns true if the attacker was player 2 in a co-op game."
"Module: Utility"
"MandatoryArg: <attacker>: Entity to test against player 2."
"Example: credit_player_2 = attacker_is_p2( attacker );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
attacker_is_p2( attacker )
{
	if ( !is_coop() )
		return false;

	if ( !isdefined( attacker ) )
		return false;
		
	return attacker == level.player2;
}

/*
=============
///ScriptDocBegin
"Name: enable_escape_warning( <enable_escape_warning> )"
"Summary: Waits for the flag 'player_trying_to_escape' to be set, then displays a hint to any players touching a trigger with script_noteworthy matching 'player_trying_to_escape'. Removes the hint when no longer touching the trigger. Does not currently support more than one potential exit point"
"Module: Utility"
"Example: enable_escape_warning()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
enable_escape_warning()
{
	level endon( "special_op_terminated" );

	level.escape_warning_triggers = getentarray( "player_trying_to_escape", "script_noteworthy" );
	assertex( level.escape_warning_triggers.size > 0, "enable_escape_warning() requires at least one trigger with script_noteworthy = player_trying_to_escape" );

	add_hint_string( "player_escape_warning", &"SPECIAL_OPS_EMPTY", ::disable_escape_warning );
	while( true )
	{
		wait 0.05;
		foreach ( trigger in level.escape_warning_triggers )
		{
			foreach ( player in level.players )
			{
				if ( !isdefined( player.escape_hint_active ) )
				{
					if ( player istouching( trigger ) )
					{
						player.escape_hint_active = true;
						player thread ping_escape_warning();
						player display_hint_timeout( "player_escape_warning" );
					}
				}
				else
				{
					if ( !isdefined( player.ping_escape_splash ) )
						player thread ping_escape_warning();
				}
			}
		}
	}
}

/*
=============
///ScriptDocBegin
"Name: enable_escape_failure( <enable_escape_failure> )"
"Summary: Waits for the flag 'player_has_escaped' to be set, and when hit displays the deadquote indicating mission failure and ends the mission."
"Example: enable_escape_failure()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
enable_escape_failure()
{
	level endon( "special_op_terminated" );

	flag_wait( "player_has_escaped" );

	level.challenge_end_time = gettime();

	so_force_deadquote( "@DEADQUOTE_SO_LEFT_PLAY_AREA" );
	maps\_utility::missionFailedWrapper();
}


/*
=============
///ScriptDocBegin
"Name: so_delete_all_by_type( <function pointer 1>, <function pointer 2>, ... , <function pointer 5> )"
"Summary: Run this in first frame. Deletes level entities that do not have the key 'script_specialops 1', that are defined by function pointer passed in. This function can delete 5 types of entities at once."
"Module: Utility"
"MandatoryArg: <function pointer 1> These functions passed in must return a boolean. Example type_vehicle() will return isSubStr( self.code_classname, "script_vehicle" );"
"Example: so_delete_all_by_type( ::type_spawn_trigger, ::type_vehicle, ::type_spawners );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
// type definition function is called on the entity, it must return boolean without sleep
so_delete_all_by_type( type1_def_func, type2_def_func, type3_def_func, type4_def_func, type5_def_func )
{
	all_ents = getentarray();
	foreach( ent in all_ents )
	{
		if ( !isdefined( ent.code_classname ) )
			continue;

		isSpecialOpEnt = ( isdefined( ent.script_specialops ) && ent.script_specialops == 1 );
		if( isSpecialOpEnt )
			continue;
		//intel items are handled by the _intelligence script...they need to do more than just delete the trigger.
		isIntelItem = ( isdefined( ent.targetname ) && ent.targetname == "intelligence_item" );
		if( isIntelItem )
			continue;
			
		if (  ent [[ type1_def_func ]]() )
			ent delete();
			
		if ( isdefined( type2_def_func ) &&  ent [[ type2_def_func ]]() )
			ent delete();
			
		if ( isdefined( type3_def_func ) &&  ent [[ type3_def_func ]]() )
			ent delete();
			
		if ( isdefined( type4_def_func ) &&  ent [[ type4_def_func ]]() )
			ent delete();
		
		if ( isdefined( type5_def_func ) &&  ent [[ type5_def_func ]]() )
			ent delete();
	}	
}

//============= some entity type function definitions ================
// ENTITY TYPE DEFINITION FUNCTIONS RETURN BOOLEAN TEST ON SELF
type_spawners()
{
	if ( !isdefined( self.code_classname ) )
		return false;
		
	return isSubStr( self.code_classname, "actor_" );	
}

type_vehicle()
{
	if ( !isdefined( self.code_classname ) )
		return false;
		
	return isSubStr( self.code_classname, "script_vehicle" );
}

type_spawn_trigger()
{
	if ( !isdefined( self.classname ) )
		return false;

	if ( self.classname == "trigger_multiple_spawn" ) 
		return true;

	if ( self.classname == "trigger_multiple_spawn_reinforcement" )
		return true;

	if ( self.classname == "trigger_multiple_friendly_respawn" )
		return true;

	if ( isdefined( self.targetname ) && self.targetname == "flood_spawner" )
		return true;

	if ( isdefined( self.targetname ) && self.targetname == "friendly_respawn_trigger" )
		return true;

	if ( isdefined( self.spawnflags ) && self.spawnflags & 32 )
		return true;

	return false;
}

type_trigger()
{
	if ( !isdefined( self.code_classname ) )
		return false;
		
	array = [];
	array[ "trigger_multiple" ]	= 1;
	array[ "trigger_once" ]		= 1;
	array[ "trigger_use" ]		= 1;
	array[ "trigger_radius" ]	= 1;
	array[ "trigger_lookat" ]	= 1;
	array[ "trigger_disk" ]		= 1;
	array[ "trigger_damage" ]	= 1;
	
	return isdefined( array[ self.code_classname ] );
}

type_flag_trigger()
{
	if ( !IsDefined( self.classname ) )
	{
		return false;
	}
		
	array = [];
	array[ "trigger_multiple_flag_set" ]			= 1;
	array[ "trigger_multiple_flag_set_touching" ]	= 1;
	array[ "trigger_multiple_flag_clear" ]			= 1;
	array[ "trigger_multiple_flag_looking" ]		= 1;
	array[ "trigger_multiple_flag_lookat" ]			= 1;
	
	return IsDefined( array[ self.classname ] );
}

type_killspawner_trigger()
{
	if( !self type_trigger() )
	{
		return false;
	}
	
	if( IsDefined( self.script_killspawner ) )
	{
		return true;
	}
	
	return false;
}

type_goalvolume()
{
	if( !IsDefined( self.classname ) )
	{
		return false;
	}
	
	if( self.classname == "info_volume" && IsDefined( self.script_goalvolume ) )
	{
		return true;
	}
	
	return false;
}

/*
=============
///ScriptDocBegin
"Name: so_delete_all_spawntriggers()"
"Summary: Deletes all spawn triggers without the key 'script_specialops 1'."
"Example: so_delete_all_spawntriggers();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_delete_all_spawntriggers()
{
	so_delete_all_by_type( ::type_spawn_trigger );
}

/*
=============
///ScriptDocBegin
"Name: so_delete_all_triggers()"
"Summary: Deletes all triggers without the key 'script_specialops 1'."
"Example: so_delete_all_triggers();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_delete_all_triggers()
{
	so_delete_all_by_type( ::type_trigger );
}

/*
=============
///ScriptDocBegin
"Name: so_delete_all_vehicles()"
"Summary: Deletes all script vehicles without the key 'script_specialops 1'."
"Example: so_delete_all_vehicles();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_delete_all_vehicles()
{
	so_delete_all_by_type( ::type_vehicle );
}

/*
=============
///ScriptDocBegin
"Name: so_delete_all_spawners()"
"Summary: Deletes all spawners without the key 'script_specialops 1'."
"Example: so_delete_all_spawners();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_delete_all_spawners()
{
	so_delete_all_by_type( ::type_spawners );
}

so_delete_breach_ents()
{
	breach_solids = getentarray( "breach_solid", "targetname" );
	foreach( ent in breach_solids )
	{
		ent connectPaths();
		ent delete();
	}
}

/*
=============
///ScriptDocBegin
"Name: so_force_deadquote( <quote> )"
"Summary: Utility function to easily force the game to use a specific Special Ops deadquote."
"Module: Utility"
"MandatoryArg: <quote>: Message you want displayed on the Mission Failed summary."
"Example: so_force_deadquote( &"SPECIAL_OPS_YOU_SUCK" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_force_deadquote( quote, icon_dvar )
{
	assertex( isdefined( quote ), "so_force_deadquote() requires a valid quote to be passed in." );

	level.so_deadquotes = [];
	level.so_deadquotes[ 0 ] = quote;
	level.so_deadquotes_chance = 1.0;
	
	so_special_failure_hint_reset_dvars( icon_dvar );
}

/*
=============
///ScriptDocBegin
"Name: so_force_deadquote_array( <quotes> )"
"Summary: Utility function to easily force the game to use a specific list of Special Ops deadquotes."
"Module: Utility"
"MandatoryArg: <quotes>: Messages you want displayed on the Mission Failed summary."
"Example: so_include_deadquote_array( special_quotes );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_force_deadquote_array( quotes, icon_dvar )
{
	assertex( isdefined( quotes ), "so_force_deadquote_array() requires a valid quote array to be passed in." );

	level.so_deadquotes = quotes;
	level.so_deadquotes_chance = 1.0;

	so_special_failure_hint_reset_dvars( icon_dvar );
}

/*
=============
///ScriptDocBegin
"Name: so_include_deadquote_array( <quotes> )"
"Summary: Utility function to easily add new custom deadquotes to Special Ops deadquotes Merges with any existing ones."
"Module: Utility"
"MandatoryArg: <quotes>: Messages you want added to the list being displayed on the Mission Failed summary."
"Example: so_include_deadquote_array( special_quotes );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_include_deadquote_array( quotes )
{
	assertex( isdefined( quotes ), "so_include_deadquote_array() requires a valid quote array to be passed in." );

	if ( !isdefined( level.so_deadquotes ) )
		level.so_deadquotes = [];
	level.so_deadquotes = array_merge( level.so_deadquotes , quotes );
}

/*
=============
///ScriptDocBegin
"Name: so_create_hud_item( <yLine>, <xOffset> , <message>, <player> )"
"Summary: Useful for creating the hud items that line up on the right side of the screen for typical Special Ops information."
"Module: Hud"
"OptionalArg: <yLine>: Line # to draw the element on. Start with 0 meaning top of the screen in split screen within the safe area."
"OptionalArg: <xOffset>: Offset for the X position."
"OptionalArg: <message>: Optional message to apply to the hudelem.label."
"OptionalArg: <player>: If a player is passed in, it will create a ClientHudElem for that player specifically."
"OptionalArg: <always_draw>: If true, then will not add itself to the list of hud elements to be toggled on and off with the dpad."
"Example: so_create_hud_item( 1, 0, &"SPECIAL_OPS_TIME_NULL", level.player2 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_create_hud_item( yLine, xOffset, message, player, always_draw )
{
	if ( isdefined( player ) )
		assertex( isplayer( player ), "so_create_hud_item() received a value for player that did not pass the isplayer() check." );
		
	if ( !isdefined( yLine ) )
		yLine = 0;
	if ( !isdefined( xOffset ) )
		xOffset = 0;

	// This is to globally shift all the SOs down by two lines to help with overlap with the objective and help text.
	yLine += 2;

	hudelem = undefined;		
	if ( isdefined( player ) )
		hudelem = newClientHudElem( player );
	else
		hudelem = newHudElem();
	hudelem.alignX = "right";
	hudelem.alignY = "middle";
	hudelem.horzAlign = "right";
	hudelem.vertAlign = "middle";
	hudelem.x = xOffset;
	hudelem.y = -100 + ( 15 * yLine );
	hudelem.font = "hudsmall";
	hudelem.foreground = 1;
	hudelem.hidewheninmenu = true;
	hudelem.hidewhendead = true;
	hudelem.sort = 2;
	hudelem set_hud_white();

	if ( isdefined( message ) )
		hudelem.label = message;

	if ( !isdefined( always_draw ) || !always_draw )
	{
		if ( isdefined( player ) )
		{
			if ( !player so_hud_can_show() )
				player thread so_create_hud_item_delay_draw( hudelem );
		}
	}
					
	return hudelem;
}

/*
=============
///ScriptDocBegin
"Name: so_hud_pulse_create( <new_value> )"
"Summary: Pulses the hud item and updates the label to the new value. Should always try to use the so_hud_pulse_<type> functions instead."
"Module: Hud"
"CallOn: A hud element"
"OptionalArg: <new_value>: When set to a value, will be set on the .label parameter of the hud element."
"Example: hudelem thread so_hud_pulse_create( 0 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_hud_pulse_create( new_value )
{
	if ( !so_hud_pulse_init() )
		return;
	
	self notify( "update_hud_pulse" );
	self endon( "update_hud_pulse" );
	self endon( "destroying" );

	// Need to update this script to support SetValue AND SetText AND updating the label.
	if ( isdefined( new_value ) )
		self.label = new_value;

	if ( isdefined( self.pulse_sound ) )
		level.player PlaySound( self.pulse_sound );
		
	if ( isdefined( self.pulse_loop ) && self.pulse_loop )
		so_hud_pulse_loop();
	else
		so_hud_pulse_single( self.pulse_scale_big, self.pulse_scale_normal, self.pulse_time );
}

/*
=============
///ScriptDocBegin
"Name: so_hud_pulse_stop( <new_value> )"
"Summary: Call to take whatever current status a hud element pulse is in, and return it to normal."
"Module: Hud"
"CallOn: A hud element"
"OptionalArg: <new_value>: When start_immediately, will pass this through to be applied to the hud element's label."
"Example: hudelem thread so_hud_pulse_stop();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_hud_pulse_stop( new_value )
{
	if ( !so_hud_pulse_init() )
		return;
	
	self notify( "update_hud_pulse" );
	self endon( "update_hud_pulse" );
	self endon( "destroying" );
	
	if ( isdefined( new_value ) )
		self.label = new_value;
		
	self.pulse_loop = false;
	so_hud_pulse_single( self.fontscale, self.pulse_scale_normal, self.pulse_time );
}

/*
=============
///ScriptDocBegin
"Name: so_hud_pulse_default( <new_value> )"
"Summary: Pulses the hud element, and sets the default color for that type of pulse."
"Module: Hud"
"CallOn: A hud element"
"OptionalArg: <new_value>: When defined, will be set as the label of the new hud element."
"Example: hudelem so_hud_pulse_default( enemy_count );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_hud_pulse_default( new_value )
{
	set_hud_white();

	self.pulse_loop = false;
	so_hud_pulse_create( new_value );
}

/*
=============
///ScriptDocBegin
"Name: so_hud_pulse_close( <new_value> )"
"Summary: Pulse loops the hud element, and sets the default color for that type of pulse."
"Module: Hud"
"CallOn: A hud element"
"OptionalArg: <new_value>: When defined, will be set as the label of the new hud element."
"Example: hudelem so_hud_pulse_close( enemy_count );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_hud_pulse_close( new_value )
{
	set_hud_green();

	self.pulse_loop = true;
	so_hud_pulse_create( new_value );
}

/*
=============
///ScriptDocBegin
"Name: so_hud_pulse_success( <new_value> )"
"Summary: Pulses the hud element, and sets the default color for that type of pulse."
"Module: Hud"
"CallOn: A hud element"
"OptionalArg: <new_value>: When defined, will be set as the label of the new hud element."
"Example: hudelem so_hud_pulse_success( enemy_count );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_hud_pulse_success( new_value )
{
	set_hud_green();

	self.pulse_loop = false;
	so_hud_pulse_create( new_value );
}

/*
=============
///ScriptDocBegin
"Name: so_hud_pulse_warning( <new_value> )"
"Summary: Pulses the hud element, and sets the default color for that type of pulse."
"Module: Hud"
"CallOn: A hud element"
"OptionalArg: <new_value>: When defined, will be set as the label of the new hud element."
"Example: hudelem so_hud_pulse_warning( enemy_count );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_hud_pulse_warning( new_value )
{
	set_hud_yellow();
	
	self.pulse_loop = false;
	so_hud_pulse_create( new_value );
}

/*
=============
///ScriptDocBegin
"Name: so_hud_pulse_alarm( <new_value> )"
"Summary: Pulse loops the hud element, and sets the default color for that type of pulse."
"Module: Hud"
"CallOn: A hud element"
"OptionalArg: <new_value>: When defined, will be set as the label of the new hud element."
"Example: hudelem so_hud_pulse_alarm( enemy_count );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_hud_pulse_alarm( new_value )
{
	set_hud_red();
	
	self.pulse_loop = true;
	so_hud_pulse_create( new_value );
}

/*
=============
///ScriptDocBegin
"Name: so_hud_pulse_failure( <new_value> )"
"Summary: Pulses the hud element, and sets the default color for that type of pulse."
"Module: Hud"
"CallOn: A hud element"
"OptionalArg: <new_value>: When defined, will be set as the label of the new hud element."
"Example: hudelem so_hud_pulse_failure( enemy_count );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_hud_pulse_failure( new_value )
{
	set_hud_red();

	self.pulse_loop = false;
	so_hud_pulse_create( new_value );
}

/*
=============
///ScriptDocBegin
"Name: so_hud_ypos( <so_hud_ypos> )"
"Summary: Returns the default value for SO HUD element Y positions. This is generally the split between the Text and the Value. When used allows simple adjustment of the hud to move it around in all SOs rather than hand updating each hud element."
"Module: Hud"
"CallOn: A hud element"
"Example: so_create_hud_item( 1, so_hud_ypos(), &"SPECIAL_OPS_TIME_NULL", level.player2 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_hud_ypos()
{
	return -72;
}

/*
=============
///ScriptDocBegin
"Name: so_remove_hud_item( <destroy_immediately> )"
"Summary: Default behavior for removing an SO HUD item. Pulses out by default, but can be told to be removed immediately."
"Module: Hud"
"CallOn: A hud element"
"OptionalArg: <destroy_immediately>: When set to true, will just remove the item immediately."
"OptionalArg: <decay_immediately>: When set to true, will do the decay visuals immediately rather than holding for a moment."
"Example: hudelem so_remove_hud_item();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_remove_hud_item( destroy_immediately, decay_immediately )
{
	if ( isdefined( destroy_immediately ) && destroy_immediately )
	{
		self notify( "destroying" );
		self Destroy();
		return;
	}

	self thread so_hud_pulse_stop();

	if ( isdefined( decay_immediately ) && decay_immediately )
	{
		self SetPulseFX( 0, 0, 500 );
		wait( 0.5 );
	}
	else
	{
		self SetPulseFX( 0, 1500, 500 );
		wait( 2 );
	}
		
	self notify( "destroying" );
	self Destroy();
}

/*
=============
///ScriptDocBegin
"Name: set_hud_white( <new_alpha> )"
"Summary: Sets properties on a hud element to be a standard white color."
"Module: Hud"
"OptionalArg: <new_alpha>: Alpha to optionally set the hud element to."
"CallOn: A hud element"
"Example: hudelem set_hud_white();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
set_hud_white( new_alpha )
{
	if ( isdefined( new_alpha ) )
	{
		self.alpha = new_alpha;
		self.glowAlpha = new_alpha;
	}

	self.color = ( 1, 1, 1 );
	self.glowcolor = ( 0.6, 0.6, 0.6 );
}

/*
=============
///ScriptDocBegin
"Name: set_hud_blue( <new_alpha> )"
"Summary: Sets properties on a hud element to be a standard blue color."
"Module: Hud"
"OptionalArg: <new_alpha>: Alpha to optionally set the hud element to."
"CallOn: A hud element"
"Example: hudelem set_hud_blue();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
set_hud_blue( new_alpha )
{
	if ( isdefined( new_alpha ) )
	{
		self.alpha = new_alpha;
		self.glowAlpha = new_alpha;
	}

	self.color = ( 0.8, 0.8, 1 );
	self.glowcolor = ( 0.301961, 0.301961, 0.6 );
}

/*
=============
///ScriptDocBegin
"Name: set_hud_green( <new_alpha> )"
"Summary: Sets properties on a hud element to be a standard green color."
"Module: Hud"
"OptionalArg: <new_alpha>: Alpha to optionally set the hud element to."
"CallOn: A hud element"
"Example: hudelem set_hud_green();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
set_hud_green( new_alpha )
{
	if ( isdefined( new_alpha ) )
	{
		self.alpha = new_alpha;
		self.glowAlpha = new_alpha;
	}

	self.color = ( 0.8, 1, 0.8 );
	self.glowcolor = ( 0.301961, 0.6, 0.301961 );
}

/*
=============
///ScriptDocBegin
"Name: set_hud_yellow( <new_alpha> )"
"Summary: Sets properties on a hud element to be a standard yellow color."
"Module: Hud"
"OptionalArg: <new_alpha>: Alpha to optionally set the hud element to."
"CallOn: A hud element"
"Example: hudelem set_hud_yellow();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
set_hud_yellow( new_alpha )
{
	if ( isdefined( new_alpha ) )
	{
		self.alpha = new_alpha;
		self.glowAlpha = new_alpha;
	}

	self.color = ( 1, 1, 0.5 );
	self.glowcolor = ( 0.7, 0.7, 0.2 );
}

/*
=============
///ScriptDocBegin
"Name: set_hud_red( <new_alpha> )"
"Summary: Sets properties on a hud element to be a standard red color."
"Module: Hud"
"OptionalArg: <new_alpha>: Alpha to optionally set the hud element to."
"CallOn: A hud element"
"Example: hudelem set_hud_red();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
set_hud_red( new_alpha )
{
	if ( isdefined( new_alpha ) )
	{
		self.alpha = new_alpha;
		self.glowAlpha = new_alpha;
	}
	
	self.color = ( 1, 0.4, 0.4 );
	self.glowcolor = ( 0.7, 0.2, 0.2 );
}

/*
=============
///ScriptDocBegin
"Name: info_hud_wait_for_player( <info_hud_wait_for_player> )"
"Summary: When run on a player, waits for them to press the appropriate key and sends a notify that will allow certain hud elements to become visible for a while before fading them back out."
"Module: Hud"
"CallOn: A player"
"OptionalArg: <endon_notify>: If a value is passed in, will create a level endon( endon_notify ) to terminate the function."
"Example: level.player info_hud_wait_for_player( "special_op_complete" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
info_hud_wait_for_player( endon_notify )
{
	assertex( isplayer( self ), "info_hud_wait_for_player() must be called on a player." );

	// Prevent thread from being initiated multiple times.
	if ( isdefined( self.so_infohud_toggle_state ) )
		return;
			
	level endon( "challenge_timer_expired" );
	level endon( "challenge_timer_passed" );
	level endon( "special_op_terminated" );
	self endon( "death" );
	if ( isdefined( endon_notify ) )
		level endon( endon_notify );

	self setWeaponHudIconOverride( "actionslot1", "hud_show_timer" );
	notifyoncommand( "toggle_challenge_timer", "+actionslot 1" );
	self.so_infohud_toggle_state = info_hud_start_state();

	if ( !so_hud_can_show() )
	{
		thread info_hud_wait_force_on();
		self ent_flag_wait( "so_hud_can_toggle" );
	}

	self notify( "so_hud_toggle_available" );
	while ( 1 )
	{
		self waittill( "toggle_challenge_timer" );
		switch( self.so_infohud_toggle_state )
		{
			case "on":
				self.so_infohud_toggle_state = "off";
				setdvar( "so_ophud_" + self.unique_id, "0" );
				break;
			case "off":
				self.so_infohud_toggle_state = "on";
				setdvar( "so_ophud_" + self.unique_id, "1" );
				break;
		}
		self notify( "update_challenge_timer" );
	}
}

info_hud_wait_force_on()
{
	self endon( "so_hud_toggle_available" );
	
	notifyoncommand( "force_challenge_timer", "+actionslot 1" );
	self waittill( "force_challenge_timer" );
	self.so_hud_show_time = gettime();
	self.so_infohud_toggle_state = "on";
	setdvar( "so_ophud_" + self.unique_id, "1" );
}

info_hud_start_state()
{
	if ( getdvarint( "so_ophud_" + self.unique_id ) == 1 )
	{
		self.so_hud_show_time = gettime() + 1000;
		return "on";
	}

	if ( isdefined( level.challenge_time_limit ) )
		return "on";

	if ( isdefined( level.challenge_time_force_on ) && level.challenge_time_force_on )
		return "on";
		
	return "off";
}

/*
=============
///ScriptDocBegin
"Name: info_hud_handle_fade( <hudelem>, <endon_notify> )"
"Summary: When called on a player and a hudelement is passed in, it will wait for the notifies from info_hud_wait_for_player() and fade the item in or out as needed."
"Module: Hud"
"CallOn: A player"
"MandatoryArg: <hudelem>: Hud element to fade in and out."
"OptionalArg: <endon_notify>: If a value is passed in, will create a level endon( endon_notify ) to terminate the function."
"Example: level.player info_hud_handle_fad( timer_hud, "special_op_complete" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
info_hud_handle_fade( hudelem, endon_notify )
{
	assertex( isplayer( self ), "info_hud_handle_fade() must be called on a player." );
	assertex( isdefined( hudelem ), "info_hud_handle_fade() requires a valid hudelem to be passed in." );
	
	level endon( "new_challenge_timer" );
	level endon( "challenge_timer_expired" );
	level endon( "challenge_timer_passed" );
	level endon( "special_op_terminated" );
	self endon( "death" );
	if ( isdefined( endon_notify ) )
		level endon( endon_notify );
	
	hudelem.so_can_toggle = true;

	self ent_flag_wait( "so_hud_can_toggle" );
	info_hud_update_alpha( hudelem );

	while( 1 )
	{
		self waittill( "update_challenge_timer" );
		hudelem FadeOverTime( 0.25 );
		info_hud_update_alpha( hudelem );
	}
}

info_hud_update_alpha( hudelem )
{
	switch( self.so_infohud_toggle_state )
	{
		case "on":	hudelem.alpha = 1;	break;
		case "off":	hudelem.alpha = 0;	break;
	}
}

/*
=============
///ScriptDocBegin
"Name: info_hud_decrement_timer( <time> )"
"Summary: Modifies the global challenge timer to subract the specified time from the current time."
"Module: Hud"
"MandatoryArg: <time>: The amount to subtract from the global time."
"Example: info_hud_decrement_timer( level.so_missed_target_deduction )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
info_hud_decrement_timer( time )
{
	if ( !IsDefined( level.challenge_time_limit  ) )
	{
		return;
	}

	if ( flag( "challenge_timer_expired" ) || flag( "challenge_timer_passed" ) )
	{
		return;
	}

	level.so_challenge_time_left -= time;

	if ( level.so_challenge_time_left < 0 )
	{
		level.so_challenge_time_left = 0.01;
	}

	red = ( 0.6, 0.2, 0.2 );
	red_glow = ( 0.4, 0.1, 0.1 );
	foreach ( player in level.players )
	{
		player.hud_so_timer_time SetTenthsTimer( level.so_challenge_time_left );

// We need to support the hurry/nudge if we really want to change the color
// Probably store an extra variable on the hud time and msg to keep track.
//		old_color 		= player.hud_so_timer_time.color;
//		old_glow  		= player.hud_so_timer_time.glowcolor;
//		old_title_color = player.hud_so_timer_msg.color;
//		old_title_glow 	= player.hud_so_timer_msg.glowcolor;
//
//		player.hud_so_timer_time.color 		= red;
//		player.hud_so_timer_time.glowcolor 	= red_glow;
//		player.hud_so_timer_msg.color 		= red;
//		player.hud_so_timer_msg.glowcolor 	= red_glow;
//		
//		player.hud_so_timer_time FadeOverTime( 0.5 );
//		player.hud_so_timer_msg FadeOverTime( 0.5 );
//		
//		player.hud_so_timer_time.color 	= old_color;
//		player.hud_so_timer_time.glowcolor 	= old_glow;
//		player.hud_so_timer_msg.color 		= old_title_color;
//		player.hud_so_timer_msg.glowcolor 	= old_title_glow;
	}

	// Restart the challenge_timer_thread
	thread challenge_timer_thread();
}

/*
=============
///ScriptDocBegin
"Name: is_dvar_character_switcher( <dvar> )"
"Summary: Tests the specified dvar to see whether the player positions have switched (for vehicle SOs)."
"Module: Utility"
"MandatoryArg: <dvar>: The dvar to test."
"Example: is_dvar_character_switcher( "specops_character_switched" )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
is_dvar_character_switcher( dvar )
{
	val = getdvar( dvar );
	return val == "so_char_client" || val == "so_char_host";
}

// ---------------------------------------------------------------------------------
//	Special Ops common dialog.
// ---------------------------------------------------------------------------------
has_been_played()
{
	best_time_name = tablelookup( "sp/specOpsTable.csv", 1, level.script, 9 );
	if ( best_time_name == "" )
		return false;

	foreach( player in level.players )
	{
		current_best_time = player GetLocalPlayerProfileData( best_time_name );

		if ( !isdefined( current_best_time ) )
			continue;	// non local player

		if ( current_best_time != 0 )
			return true;			
	}
	
	return false;
}

is_best_time( time_start, time_current, time_frac )
{
	if ( !isdefined( time_start ) )
	{
		if ( isdefined( level.challenge_start_time ) )
			time_start = level.challenge_start_time;
		else
			time_start = 300;	// Frame time that script actually starts on.
	}
		
	if ( !isdefined( time_current ) )
		time_current = gettime();
		
	if ( !isdefined( time_frac ) )
		time_frac = 0.0;

	// Check for best time.
	m_seconds = ( time_current - time_start );
	m_seconds = int( min( m_seconds, 86400000 ) );
	best_time_name = tablelookup( "sp/specOpsTable.csv", 1, level.script, 9 );
	if ( best_time_name == "" )
		return false;
		
	foreach( player in level.players )
	{
		current_best_time = player GetLocalPlayerProfileData( best_time_name );

		if ( !isdefined( current_best_time ) )
			continue;	// non local player
			
		never_played = ( current_best_time == 0 );
		if ( never_played )
			continue;
			
		current_best_time -= ( current_best_time * time_frac );
		if ( m_seconds < current_best_time )
			return true;
	}
	
	return false;
}

is_poor_time( time_start, time_current, time_frac )
{
	if ( !isdefined( time_start ) )
	{
		if ( isdefined( level.challenge_start_time ) )
			time_start = level.challenge_start_time;
		else
			time_start = 300;	// Frame time that script actually starts on.
	}
		
	if ( !isdefined( time_current ) )
		time_current = gettime();
		
	if ( !isdefined( time_frac ) )
		time_frac = 0.0;

	m_seconds = ( time_current - time_start );
	m_time_limit = ( level.challenge_time_limit * 1000 );
	m_time_limit -= ( m_time_limit * time_frac );

	return ( m_seconds > m_time_limit );
}

so_dialog_ready_up()
{
	so_dialog_play( "so_tf_1_plyr_prep", 0, true );
}

so_dialog_mission_success()
{
	// Check for best time.
	if ( is_best_time( level.challenge_start_time, level.challenge_end_time ) )
	{
		thread so_dialog_play( "so_tf_1_success_best", 0.5, true );
		return;
	}
	
	// Normal time.
	// Hardened and lower only get supportive success messages. Veteran has 50/50 chance to get a sarcastic.
	do_sarcasm = false;
	if ( level.gameSkill >= 3 )
	{
		if ( has_been_played() )
			do_sarcasm = cointoss();
	}
	
	if ( do_sarcasm )
		so_dialog_play( "so_tf_1_success_jerk", 0.5, true );
	else
		so_dialog_play( "so_tf_1_success_generic", 0.5, true );
}

/*
=============
///ScriptDocBegin
"Name: so_dialog_mission_failed( <sound_alias> )"
"Summary: Used to safely play a piece of dialog on mission failure without worry of getting duplicates. Whichever one is called first wins."
"Module: Utility"
"MandatoryArg: <sound_alias>: The sound alias in level.scr_radio"
"Example: so_dialog_mission_failed( "what_are_you_stupid" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
so_dialog_mission_failed( sound_alias )
{
	// This is designed to prevent multiple failed messages from playing. Only the first one gets played.
	assertex( isdefined( sound_alias ), "so_dialog_mission_failed() requires a valid sound_alias." );
	if ( isdefined( level.failed_dialog_played ) && level.failed_dialog_played )
		return;

	level.failed_dialog_played = true;
	so_dialog_play( sound_alias, 0.5, true );
}

so_dialog_mission_failed_generic()
{
	if ( ( level.gameskill <= 2 ) || cointoss() )
		so_dialog_mission_failed( "so_tf_1_fail_generic" );
	else
		so_dialog_mission_failed( "so_tf_1_fail_generic_jerk" );
}

so_dialog_mission_failed_time()
{
	so_dialog_mission_failed( "so_tf_1_fail_time" );
}

so_dialog_mission_failed_bleedout()
{
	so_dialog_mission_failed( "so_tf_1_fail_bleedout" );
}

so_dialog_time_low_normal()
{
	so_dialog_play( "so_tf_1_time_generic" );
}

so_dialog_time_low_hurry()
{
	so_dialog_play( "so_tf_1_time_hurry" );
}

so_dialog_killing_civilians()
{
	if ( !isdefined( level.civilian_warning_time ) )
	{
		level.civilian_warning_time = gettime();
		if ( !isdefined( level.civilian_warning_throttle ) )
			level.civilian_warning_throttle = 5000;
	}
	else
	{
		if ( ( gettime() - level.civilian_warning_time ) < level.civilian_warning_throttle )
			return;
	}
	
	wait_time = 0.5;
	level.civilian_warning_time = gettime() + ( wait_time * 1000 );
	so_dialog_play( "so_tf_1_civ_kill_warning", 0.5 );
}

// Note this doesn't account for any mission which might go "backwards" in regards to current_value.
so_dialog_progress_update( current_value, current_goal )
{
	if ( !isdefined( current_value ) )
		return;

	if ( !isdefined( current_goal ) )
		return;
		
	if ( !isdefined( level.so_progress_goal_status ) )
		level.so_progress_goal_status = "none";
	
	time_frac = undefined;
	switch ( level.so_progress_goal_status )
	{
		case "none":		time_frac = 0.75;	break;
		case "3quarter":	time_frac = 0.5;	break;
		case "half":		time_frac = 0.25;	break;
		default:			return;				// No behavior for other states.
	}
	
	test_goal = current_goal * time_frac;
	if ( current_value > test_goal )
		return;

	time_dialog = undefined;
	switch ( level.so_progress_goal_status )
	{
		case "none":
			level.so_progress_goal_status = "3quarter";		
			time_dialog = "so_tf_1_progress_3quarter";
			break;
		case "3quarter":
			level.so_progress_goal_status = "half";		
			time_dialog = "so_tf_1_progress_half";
			break;
		case "half":
			level.so_progress_goal_status = "quarter";	
			time_dialog = "so_tf_1_progress_quarter";
			break;
	}

	so_dialog_play( time_dialog, 0.5 );
//	so_dialog_progress_update_time_quality( time_frac );
}

so_dialog_progress_update_time_quality( time_frac )
{
	// Even if this is their best time so far, always warn about running late first.
	if ( isdefined( level.challenge_time_limit ) )
	{
		if ( is_poor_time( level.challenge_start_time, gettime(), time_frac ) )
		{
			so_dialog_play( "so_tf_1_time_status_late", 0.2 );
			return;
		}
	}

	if ( is_best_time( level.challenge_start_time, gettime(), time_frac ) )
		so_dialog_play( "so_tf_1_time_status_good", 0.2 );
}

so_dialog_counter_update( current_count, current_goal, countdown_divide )
{
	// Prevent overlaps happening quickly.
	if ( !isdefined( level.so_counter_dialog_time ) )
		level.so_counter_dialog_time = 0;
	if ( gettime() < level.so_counter_dialog_time )
		return;

	if ( !isdefined( current_count ) )
		return;

	if ( !isdefined( countdown_divide ) )
		countdown_divide = 1;
	adjusted_count = int( current_count / countdown_divide );

	// No callouts for anything over 5.
	if ( adjusted_count > 5 )
	{
		if ( !isdefined( level.challenge_progress_manual_update ) || !level.challenge_progress_manual_update )
		{
			thread so_dialog_progress_update( current_count, current_goal );
			level.so_counter_dialog_time = gettime() + 800;
		}
		return;
	}
		
	// Call 'em out!
	switch( adjusted_count )
	{
		case 5: thread so_dialog_play( "so_tf_1_progress_5more", 0.5 );	break;
		case 4: thread so_dialog_play( "so_tf_1_progress_4more", 0.5 );	break;
		case 3: thread so_dialog_play( "so_tf_1_progress_3more", 0.5 );	break;
		case 2: thread so_dialog_play( "so_tf_1_progress_2more", 0.5 );	break;
		case 1: thread so_dialog_play( "so_tf_1_progress_1more", 0.5 );	break;
	}
	level.so_counter_dialog_time = gettime() + 800;
}

// ---------------------------------------------------------------------------------

so_crush_player( player, mod )
{
	assert( isdefined( self ) );
	assert( isdefined( player ) );
	
	if ( !IsDefined( player.coop_death_reason ) )
	{
		player.coop_death_reason = [];
	}

	if ( !IsDefined( mod ) )
	{
		mod = "MOD_EXPLOSIVE";
	}

	player.coop_death_reason[ "attacker" ] = self;
	player.coop_death_reason[ "cause" ] = mod;
	player.coop_death_reason[ "weapon_name" ] = "none";
	
	player kill_wrapper();
}
