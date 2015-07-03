#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\arcadia;
#include maps\arcadia_code;

STRYKER_TARGET_OFFSET_VEHICLE = 30;
STRYKER_TARGET_OFFSET_HELICOPTER = -80;
STRYKER_MANUAL_AI_DURATION = 20;

setup_stryker_modes()
{
	level.stryker_settings[ "ai" ] = spawnStruct();
	level.stryker_settings[ "ai" ].target_engage_duration = 3.0;		// number of seconds the stryker will shoot at a target
	level.stryker_settings[ "ai" ].target_engage_break_time = 3.0;		// number of seconds the stryker will wait before searching for a new target when no target is found
	level.stryker_settings[ "ai" ].target_min_range = 300;				// min distance the stryker will search for targets
	level.stryker_settings[ "ai" ].target_max_range = 3500;				// max distance the stryker will search for targets
	level.stryker_settings[ "ai" ].target_min_range_veh = 0;			// min distance the stryker will search for targets
	level.stryker_settings[ "ai" ].target_max_range_veh = 300;			// max distance the stryker will search for targets
	level.stryker_settings[ "ai" ].burst_count_min = 3;					// min number of bullets per burst
	level.stryker_settings[ "ai" ].burst_count_max = 10;				// max number of bullets per burst
	level.stryker_settings[ "ai" ].burst_delay_min = 8.0;				// min wait time between bursts
	level.stryker_settings[ "ai" ].burst_delay_max = 15.0;				// max wait time between bursts
	level.stryker_settings[ "ai" ].fire_time = 0.1;						// time between bullets
	level.stryker_settings[ "ai" ].getVehicles = false;					// should we seek out vehicle targets?
	
	level.stryker_settings[ "manual" ] = spawnStruct();
	level.stryker_settings[ "manual" ].target_engage_duration = 4.0;	// number of seconds the stryker will shoot at a target
	level.stryker_settings[ "manual" ].target_engage_break_time = 0.2;	// number of seconds the stryker will wait before searching for a new target when no target is found
	level.stryker_settings[ "manual" ].target_min_range = 0;			// min distance the stryker will search for targets
	level.stryker_settings[ "manual" ].target_max_range = 4500;			// max distance the stryker will search for targets
	level.stryker_settings[ "manual" ].target_min_range_veh = 0;		// min distance the stryker will search for targets
	level.stryker_settings[ "manual" ].target_max_range_veh = 200;		// max distance the stryker will search for targets
	level.stryker_settings[ "manual" ].burst_count_min = 15;			// min number of bullets per burst
	level.stryker_settings[ "manual" ].burst_count_max = 25;			// max number of bullets per burst
	level.stryker_settings[ "manual" ].burst_delay_min = 0.1;			// min wait time between bursts
	level.stryker_settings[ "manual" ].burst_delay_max = 0.4;			// max wait time between bursts
	level.stryker_settings[ "manual" ].fire_time = 0.1;					// time between bullets
	level.stryker_settings[ "manual" ].getVehicles = true;				// should we seek out vehicle targets?
}

stryker_setmode_ai()
{
	self.turretMode = "ai";
	self.targetSearchOrigin = undefined;
	
	/#
	if ( getdvar( "arcadia_debug_stryker" ) == "1" )
		iprintln( "^2stryker - " + self.turretMode + " mode" );
	#/
	
	self thread stryker_turret_think();
}

stryker_setmode_manual( origin )
{
	self endon( "death" );
	
	assert( isdefined( origin ) );
	
	self notify( "stryker_setmode_manual" );
	self endon( "stryker_setmode_manual" );
	
	self.turretMode = "manual";
	self.targetSearchOrigin = origin;
	
	self thread stryker_turret_think();
	
	/#
	if ( getdvar( "arcadia_debug_stryker" ) == "1" )
		iprintln( "^2stryker - " + self.turretMode + " mode" );
	#/
	
	wait STRYKER_MANUAL_AI_DURATION;
	
	thread stryker_suppression_complete_dialog();
	thread stryker_laser_reminder_dialog();
	thread stryker_setmode_ai();
}

stryker_turret_think()
{
	/#
	assert( isdefined( self.turretMode ) );
	assert( isdefined( level.stryker_settings[ self.turretMode ] ) );
	#/
	
	self notify( "stryker_turret_think" );
	self endon( "stryker_turret_think" );
	self endon( "death" );
	
	self thread stryker_scan_stop();
	
	for(;;)
	{
		target = self stryker_get_target();
		
		if ( !isdefined( target ) )
		{
			self thread stryker_scan_start();
			wait level.stryker_settings[ self.turretMode ].target_engage_break_time;
			self stryker_scan_stop();
			continue;
		}
		
		self stryker_shoot_target( target );
		wait level.stryker_settings[ self.turretMode ].target_engage_break_time;
	}
}

stryker_scan_start()
{
	self endon( "death" );
	self endon( "stop_scanning" );
	
	assert( !isdefined( self.scanning ) );
	self.scanning = true;
	
	/#
	if ( getdvar( "arcadia_debug_stryker" ) == "1" )
		iprintln( "^2stryker - scan start" );
	#/
	
	alternate = 0;
	
	for(;;)
	{
		// get random point in front of stryker
		forward = anglesToForward( self.angles ) * 1000;
		
		if ( alternate == 0 )
		{
			alternate = 1;
			sideOffset = randomintrange( -1500, -200 );
		}
		else
		{
			alternate = 0;
			sideOffset = randomintrange( 200, 1500 );
		}
		
		right = anglesToRight( self.angles ) * sideOffset;
		
		aimPoint = self.origin + forward + right;
		aimPoint = ( aimPoint[ 0 ], aimPoint[ 1 ], self.origin[ 2 ] );
		
		self SetTurretTargetVec( aimPoint );
		wait randomfloatrange( 2.0, 5.0 );
	}
}

stryker_scan_stop()
{
	/#
	if ( getdvar( "arcadia_debug_stryker" ) == "1" )
		iprintln( "^2stryker - scan stop" );
	#/
	
	self clearTurretTarget();
	self.scanning = undefined;
	self notify( "stop_scanning" );
}

stryker_get_target()
{
	SEARCH_ORIGIN = self.origin;
	if ( isdefined( self.targetSearchOrigin ) )
		SEARCH_ORIGIN = self.targetSearchOrigin;
	
	SEARCH_RADIUS_MIN = level.stryker_settings[ self.turretMode ].target_min_range;
	SEARCH_RADIUS_MAX = level.stryker_settings[ self.turretMode ].target_max_range;
	SEARCH_RADIUS_MIN_VEH = level.stryker_settings[ self.turretMode ].target_min_range_veh;
	SEARCH_RADIUS_MAX_VEH = level.stryker_settings[ self.turretMode ].target_max_range_veh;
	GET_VEHICLES = level.stryker_settings[ self.turretMode ].getVehicles;
	
	eTargets = [];
	
	enemyTeam = common_scripts\utility::get_enemy_team( self.script_team );
	possibleTargets = [];
	vehicleTargets = [];
	destructibleTargets = [];
	sentientTargets = [];
	
	prof_begin( "stryker_ai" );
	
	// ADD VEHICLE AND DESTRUCTIBLE VEHICLE TARGETS
	if ( GET_VEHICLES )
	{
		assert( isdefined( level.vehicles[ enemyTeam ] ) );
		vehicleTargets = level.vehicles[ enemyTeam ];
		vehicleTargets = get_array_of_closest( SEARCH_ORIGIN, vehicleTargets, undefined, undefined, SEARCH_RADIUS_MAX_VEH, SEARCH_RADIUS_MIN_VEH );
		
		ents = getentarray( "destructible_vehicle", "targetname" );
		foreach( ent in ents )
		{
			if ( isdefined( ent.exploded ) )
				continue;
			destructibleTargets[ destructibleTargets.size ] = ent;
		}
		ents = undefined;
		destructibleTargets = get_array_of_closest( SEARCH_ORIGIN, destructibleTargets, undefined, undefined, SEARCH_RADIUS_MAX_VEH, SEARCH_RADIUS_MIN_VEH );
	}
	
	// ADD AI TARGETS
	sentientTargets = getaiarray( enemyTeam );
	sentientTargets = get_array_of_closest( SEARCH_ORIGIN, sentientTargets, undefined, undefined, SEARCH_RADIUS_MAX, SEARCH_RADIUS_MIN );
	
	// BUILD FULL ARRAY OF ALL POSSIBLE TARGETS
	possibleTargets = array_combine( possibleTargets, vehicleTargets );
	possibleTargets = array_combine( possibleTargets, destructibleTargets );
	possibleTargets = array_combine( possibleTargets, sentientTargets );
	
	// clear unused arrays
	vehicleTargets = undefined;
	destructibleTargets = undefined;
	sentientTargets = undefined;
	
	foreach( target in possibleTargets )
	{	
		// threatbias - if this is an ignored group then dont consider this target
		if ( isdefined( self.threatBiasGroup ) && IsSentient( target ) )
		{
			bias = getThreatBias( target getThreatBiasGroup(), self.threatBiasGroup );
			if ( bias <= -1000000 )
				continue;
		}
		
		// don't shoot at targets that are supposed to be ignored
		if ( isdefined( target.ignoreme ) && target.ignoreme == true )
			continue;
		
		if ( isAI( target ) )
		{
			if ( !sightTracePassed( self getTagOrigin( "tag_flash" ), target getEye(), false, self ) )
				continue;
		}
		
		prof_end( "stryker_ai" );
		return target;
	}
	
	prof_end( "stryker_ai" );
	return undefined;
}

stryker_get_target_offset( target )
{
	if ( isAi( target ) )
	{
		eye = target getEye();
		zOffset = eye[ 2 ] - target.origin[ 2 ];
		return ( 0, 0, zOffset );
	}
	
	if ( isdefined( target.vehicletype ) )
	{
		if ( target isHelicopter() )
			return ( 0, 0, STRYKER_TARGET_OFFSET_HELICOPTER );
		return ( 0, 0, STRYKER_TARGET_OFFSET_VEHICLE );
	}
	
	if( isdefined( target.destuctableinfo ) )
		return ( 0, 0, STRYKER_TARGET_OFFSET_VEHICLE );
	
	return ( 0, 0, 0 );
}

stryker_shoot_target( target )
{
	self notify( "stryker_shoot_target" );
	self endon( "stryker_shoot_target" );
	
	if ( !isdefined( target ) )
		return;
	
	// aim the gun at the target and wait for it to be lined up or timeout
	targetOffset = stryker_get_target_offset( target );
	
	/#
	if ( getdvar( "arcadia_debug_stryker" ) == "1" )
	{
		iprintln( "^2stryker - shooting a target" );
		if ( self.turretMode == "ai" )
			thread draw_line_for_time( self.origin + ( 0, 0, 100 ), target.origin + targetOffset, 1, 1, 0, 2.0 );
		else
			thread draw_line_for_time( self.origin + ( 0, 0, 100 ), target.origin + targetOffset, 1, 0, 0, 2.0 );
	}
	#/
	
	self setTurretTargetEnt( target, targetOffset );
	if ( self.lastTarget != target )
		self waittill_notify_or_timeout( "turret_rotate_stopped", 1.0 );
	self.lastTarget = target;
	
	startTime = getTime();
	while( isdefined( target ) )
	{
		// thread ends after level.stryker_settings[ self.turretMode ].target_engage_duration time elapses
		timeElapsed = getTime() - startTime;
		if ( timeElapsed >= level.stryker_settings[ self.turretMode ].target_engage_duration * 1000 )
			return;
		
		self stryker_fire_shots( target, targetOffset );
		wait randomfloatrange( level.stryker_settings[ self.turretMode ].burst_delay_min, level.stryker_settings[ self.turretMode ].burst_delay_max );
	}
}

stryker_fire_shots( target, targetOffset )
{
	self notify( "stryker_fire_shots" );
	self endon( "stryker_fire_shots" );
	
	shots = randomintrange( level.stryker_settings[ self.turretMode ].burst_count_min, level.stryker_settings[ self.turretMode ].burst_count_max );
	for( i = 0 ; i < shots ; i++ )
	{
		if ( isdefined( target ) && isdefined( targetOffset ) )
			self fireWeapon( "tag_flash", target, targetOffset, 0.0 );
		else
			self fireWeapon( "tag_flash", undefined, ( 0, 0, 0 ), 0.0 );
		wait level.stryker_settings[ self.turretMode ].fire_time;
	}
}











/*
ai_becomes_suppressed()
{
	self endon( "death" );
	
	self notify( "ai_becomes_suppressed" );
	self endon( "ai_becomes_suppressed" );
	
	/#
	if ( getdvar( "arcadia_debug_stryker" ) == "1" )
		thread draw_line_to_ent_for_time( ( 0, 0, 10000 ), self, 1, 0, 0, STRYKER_AI_SUPPRESSION_TIME );
	#/
	
	self.forceSuppression = true;
	wait STRYKER_AI_SUPPRESSION_TIME;
	self.forceSuppression = undefined;
}
*/

stryker_suppression_complete_dialog()
{
	dialog = [];
	dialog[ dialog.size ] = "arcadia_str_targdestroyed";		// Badger One to Hunter Two, target destroyed.
	dialog[ dialog.size ] = "arcadia_str_areasuppressed";		// Badger One to Hunter Two, area suppressed.
	dialog[ dialog.size ] = "arcadia_str_tasuppressed";			// Badger One to Hunter Two, target area suppressed.
	
	if ( flag( "disable_stryker_dialog" ) )
		return;
	
	thread radio_dialogue( dialog[ randomint( dialog.size ) ] );
}

stryker_laser_reminder_dialog()
{
	level endon( "golf_course_mansion" );
	level endon( "laser_coordinates_received" );
	
	level.stryker notify( "stryker_laser_reminder_dialog" );
	level.stryker endon( "stryker_laser_reminder_dialog" );
	level.stryker endon( "death" );
	
	for(;;)
	{
		wait randomintrange( 30, 60 );
		
		if ( !isalive( level.stryker ) )
			return;
		
		if ( flag( "disable_stryker_dialog" ) )
			continue;

		if ( flag_exist( "no_living_enemies" ) && flag( "no_living_enemies" ) )
		{
			continue;
		}
		
		thread laser_hint_print();
		
		rand = randomint( 5 );
		switch( rand )
		{
			case 0:
				// Use your designator! Lase targets for the Stryker!
				level.foley thread anim_single_queue( level.foley, "arcadia_fly_usedesignator" );
				break;
			case 1:
				// Squad, use your laser designators! Paint targets for the Stryker!
				level.foley thread anim_single_queue( level.foley, "arcadia_fly_painttargets" );
				break;
			case 2:
				// All Hunter units, this is Badger One. Lase the target, over.
				thread radio_dialogue( "arcadia_str_lasetarget" );
				break;
			case 3:
				// All Hunter units, this is Badger One. Standing by to engage your targets, over.
				thread radio_dialogue( "arcadia_str_standingby" );
				break;
			case 4:
				// All Hunter teams, this is Badger One. Paint the target, over.
				thread radio_dialogue( "arcadia_str_painttarget" );
				break;
		}
	}
}

stryker_death_wait()
{
	level endon( "golf_course_mansion" );
	
	self waittill( "death" );
	
	wait 1.5;
	
	// All Hunter units, be advised, we just lost Badger One. Stryker support is unavailable, I repeat, Stryker support is unavailable. Make do with what you got. Out.
	level.foley thread anim_single_queue( level.foley, "arcadia_fly_lostbadgerone" );
}