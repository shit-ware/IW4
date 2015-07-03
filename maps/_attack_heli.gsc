#include maps\_utility;
#include maps\_vehicle;
#include common_scripts\utility;

preLoad()
{
	//generic turrets and missiles for all attack helis
	PreCacheItem( "turret_attackheli" );
	PreCacheItem( "missile_attackheli" );

	//spotlight effect for _attack_hei vehicles with script_spotlight set to "1"
	attack_heli_fx();
	thread init();
	//maps\_mi28::main( "vehicle_mi-28_flying" );		//why is this here?
}

attack_heli_fx()
{
	if ( GetDvarInt( "sm_enable" ) && GetDvar( "r_zfeather" ) != "0" )
		level._effect[ "_attack_heli_spotlight" ]	 = LoadFX( "misc/hunted_spotlight_model" );
	else
		level._effect[ "_attack_heli_spotlight" ]	 = LoadFX( "misc/spotlight_large" );

}

init()
{
	// already ran elsewhere
	if ( IsDefined( level.attackHeliAIburstSize ) )
		return;

	while ( !isdefined( level.gameskill ) )
		wait( 0.05 );
	/*-----------------------
	ATTACK HELI PARAMETERS
	-------------------------*/		
	if ( !isdefined( level.cosine ) )
		level.cosine = [];

	if ( !isdefined( level.cosine[ "25" ] ) )
		level.cosine[ "25" ] = Cos( 25 );

	if ( !isdefined( level.cosine[ "35" ] ) )
		level.cosine[ "35" ] = Cos( 35 );

	if ( !isdefined( level.attackheliRange ) )		// Heli shoots at target within this distance
		level.attackheliRange = 3500;

	if ( !isdefined( level.attackHeliKillsAI ) )	// Heli shoots at AI, but misses
		level.attackHeliKillsAI = false;

	if ( !isdefined( level.attackHeliFOV ) )		// FOV where the heli can detect targets
		level.attackHeliFOV = Cos( 30 );

	level.attackHeliAIburstSize = 1; 		// how long to fire miniguns at AI
	level.attackHeliMemory = 3;					// how long heli remember who it was that shot at him
	level.attackHeliTargetReaquire = 6;// how long before a heli checks for new targets
	level.attackHeliMoveTime = 3; 			// how long the heli waits before looking for a new node
	switch( level.gameSkill )
	{
		case 0:// easy
			level.attackHeliPlayerBreak = 9;		// if heli has been beating on the player, pick on someone else for this amt of time or until player attacks
			level.attackHeliTimeout = 1; 				// how long the target is out of sight before heli stops shooting it
			break;
		case 1:// regular
			level.attackHeliPlayerBreak = 7;	// if heli has been beating on the player, pick on someone else for this amt of time or until player attacks
			level.attackHeliTimeout = 2; 			// how long the target is out of sight before heli stops shooting it
			break;
		case 2:// hardened
			level.attackHeliPlayerBreak = 5;	// if heli has been beating on the player, pick on someone else for this amt of time or until player attacks
			level.attackHeliTimeout = 3; 			// how long the target is out of sight before heli stops shooting it
			break;
		case 3:// veteran
			level.attackHeliPlayerBreak = 3;	// if heli has been beating on the player, pick on someone else for this amt of time or until player attacks
			level.attackHeliTimeout = 5; 			// how long the target is out of sight before heli stops shooting it
			break;
	}
}

/*
=============
///ScriptDocBegin
"Name: start_attack_heli( <sTargetname> )"
"Summary: Spawns an attack helicopter in PMC or singleplayer that will go to the closest path of helicopter nodes and harass the player. See wiki or PMC maps for details on setting up the heli and a network of nodes."
"Module: Vehicle"
"OptionalArg: <sTargetname>: Targetname value of the helicopter that will spawn. PMC does not require a targetname (uses 'kill_heli')"
"Example: attack_heli = thread maps\_attack_heli::start_attack_heli();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
start_attack_heli( sTargetname )
{
	if ( !isdefined( sTargetname ) )
		sTargetname = "kill_heli";
	eHeli = maps\_vehicle::spawn_vehicle_from_targetname_and_drive( sTargetname );
	eHeli = begin_attack_heli_behavior( eHeli );
	return eHeli;
}
/*
=============
///ScriptDocBegin
"Name: begin_attack_heli_behavior( <eHeli> )"
"Summary: Makesa regularly spawned helicopter start using the AI logic in _attack_heli.gsc script (stalking the player and firing at him)"
"Module: Vehicle"
"MandatoryArg: <eHeli>: The helicopter entity"
"OptionalArg: <heli_points>: Points for the Heli to use when checking for player proximity."
"Example: eHeli = maps\_attack_heli::begin_attack_heli_behavior( eHeli );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
begin_attack_heli_behavior( eHeli, heli_points )
{
	/*-----------------------
	HELI SETUP
	-------------------------*/	
	eHeli endon( "death" );
	eHeli endon( "heli_players_dead" );

	if ( ( level.gameskill == 0 )  || ( level.gameskill == 1 ) )
	{
		//create an attractor if this is easy or normal
		org = Spawn( "script_origin", eHeli.origin + ( 0, 0, -20 ) );
		org LinkTo( eHeli );
		eHeli thread delete_on_death( org );
		strength = undefined;
		if ( level.gameskill == 0 )
			strength = 2800;
		else
			strength = 2200;
		
		if( !isdefined( eHeli.no_attractor ) )
		{
			eHeli.attractor = Missile_CreateAttractorEnt( org, strength, 10000, level.player );
			
			if ( is_coop() )
			{
				eHeli.attractor2 = Missile_CreateAttractorEnt( org, strength, 10000, level.player2 );
			}
		}
		//thread debug_message( "attractor", undefined, 9999, org );
	}
	eHeli EnableAimAssist();
	eHeli.startingOrigin = Spawn( "script_origin", eHeli.origin );
	eHeli thread delete_on_death( eHeli.startingOrigin );
	if ( !isdefined( eHeli.circling ) )
		eHeli.circling = false;
	eHeli.allowShoot = true;
	eHeli.firingMissiles = false;
	eHeli.moving = true;
	eHeli.isTakingDamage = false;
	eHeli.heli_lastattacker = undefined;
	eHeli thread notify_disable();
	eHeli thread notify_enable();
	thread kill_heli_logic( eHeli, heli_points );

	eHeli.turrettype = undefined;
	eHeli heli_default_target_setup();

	eheli thread detect_player_death();
	
	/*-----------------------
	SETUP ATTACK HELI BASED ON VEHICLETYPE
	-------------------------*/		
	switch( eHeli.vehicletype )
	{
		case "hind":
			eHeli.turrettype = "default";
			break;
		case "mi28":
			eHeli.turrettype = "default";
			break;
		case "littlebird":
			eHeli SetYawSpeed( 90, 30, 20 );	// 90 degree / s, 30 degree / s^2, 20 degree / s^2
			eHeli SetMaxPitchRoll( 40, 40 );
			eHeli SetHoverParams( 100, 20, 5 );
			eHeli setup_miniguns();
			break;
		default:
			AssertMsg( "Need to set up this heli type in the _attack_heli.gsc script: " + self.vehicletype );
			break;
	}

	/*-----------------------
	SPOTLIGHT, AIMING, ETC.
	-------------------------*/		
	eHeli.eTarget = eHeli.targetdefault;
	if ( ( IsDefined( eHeli.script_spotlight ) ) && ( eHeli.script_spotlight == 1 ) && ( !isdefined( eHeli.spotlight ) ) )
		eHeli thread heli_spotlight_on( undefined, true );

	eHeli thread attack_heli_cleanup();
	return eHeli;
}

detect_player_death()
{
	foreach( player in level.players )
		player add_wait( ::waittill_msg, "death" );
	do_wait_any();
	
	self notify( "heli_players_dead" );
}

heli_default_target_setup()
{
	up_offset = undefined;
	forward_offset = undefined;
	switch( self.vehicletype )
	{
		case "hind":
			forward_offset = 600;
			up_offset = -100;
			break;
		case "mi28":
			forward_offset = 600;
			up_offset = -100;
			break;
		case "littlebird":
			forward_offset = 600;
			up_offset = -204;
			break;
		default:
			AssertMsg( "Need to set up this heli type in the _attack_heli.gsc script: " + self.vehicletype );
			break;
	}
	self.targetdefault = Spawn( "script_origin", self.origin );
	self.targetdefault.angles = self.angles;
	self.targetdefault.origin = self.origin;

	ent = SpawnStruct();
	ent.entity = self.targetdefault;
	ent.forward = forward_offset;
	ent.up = up_offset;
	ent translate_local();
	self.targetdefault LinkTo( self );
	self.targetdefault thread heli_default_target_cleanup( self );
}

get_turrets()
{
	if ( IsDefined( self.turrets ) )
		return self.turrets;

	setup_miniguns();
	return self.turrets;
}

setup_miniguns()
{
	AssertEx( !isdefined( self.turrets ), ".turrets are already defined" );

	self.turrettype = "miniguns";
	self.minigunsspinning = false;
	self.firingguns = false;
	if ( !isdefined( self.mgturret ) )	//in case the heli is taken out before has a chance to setup turrets
		return;
	
	self.turrets = self.mgturret;
	array_thread( self.turrets, ::littlebird_turrets_think, self );
}

heli_default_target_cleanup( eHeli )
{
	eHeli waittill_either( "death", "crash_done" );
	if ( IsDefined( self ) )
		self Delete();
}

start_circling_heli( heli_targetname, heli_points )
{
	if ( !isdefined( heli_targetname ) )
		heli_targetname = "kill_heli";
	heli = maps\_vehicle::spawn_vehicle_from_targetname_and_drive( heli_targetname );
	heli.startingOrigin = Spawn( "script_origin", heli.origin );
	heli thread delete_on_death( heli.startingOrigin );
	heli.circling = true;
	heli.allowShoot = true;
	heli.firingMissiles = false;
	heli thread notify_disable();
	heli thread notify_enable();
	thread kill_heli_logic( heli, heli_points );
	return heli;
}

kill_heli_logic( heli, heli_points )
{
	if ( !isdefined( heli ) )
	{
		heli = maps\_vehicle::spawn_vehicle_from_targetname_and_drive( "kill_heli" );
		Assert( IsDefined( heli ) );
		heli.allowShoot = true;
		heli.firingMissiles = false;
		heli thread notify_disable();
		heli thread notify_enable();
	}

	baseSpeed = undefined;
	if ( !isdefined( heli.script_airspeed ) )
		baseSpeed = 40;
	else
		baseSpeed = heli.script_airspeed;

	if ( !isdefined( level.enemy_heli_killed ) )
		level.enemy_heli_killed = false;

	if ( !isdefined( level.commander_speaking ) )
		level.commander_speaking = false;

	if ( !isdefined( level.enemy_heli_attacking ) )
		level.enemy_heli_attacking = false;

	//players who have not hit the heli in the last 5 seconds
	//are invisible to the attack heli while in this volume
	level.attack_heli_safe_volumes = undefined;
	volumes = GetEntArray( "attack_heli_safe_volume", "script_noteworthy" );
	if ( volumes.size > 0 )
		level.attack_heli_safe_volumes = volumes;

	if ( ! level.enemy_heli_killed )
		thread dialog_nags_heli( heli );


	if( !isdefined( heli.helicopter_predator_target_shader ) )
	{
		switch( heli.vehicletype )
		{
			case "mi28":
				Target_Set( heli, ( 0, 0, -80 ) );
				break;
			case "hind":
				Target_Set( heli, ( 0, 0, -96 ) );
				break;
			case "littlebird":
				Target_Set( heli, ( 0, 0, -80 ) );
				break;
			default:
				AssertMsg( "Need to set up this heli type in the _attack_heli.gsc script: " + self.vehicletype );
				break;
		}
		Target_SetJavelinOnly( heli, true );
	}

	heli thread heli_damage_monitor();
	heli thread heli_death_monitor();

	heli endon( "death" );
	heli endon( "heli_players_dead" );
	heli endon( "returning_home" );
	heli SetVehWeapon( "turret_attackheli" );

	if ( !isdefined( heli.circling ) )
		heli.circling = false;
	if ( !heli.circling )
	{
		heli SetNearGoalNotifyDist( 100 );
		if ( !isdefined( heli.dontWaitForPathEnd ) )
			heli waittill( "reached_dynamic_path_end" );
	}
	else
	{
		heli SetNearGoalNotifyDist( 500 );
		heli waittill( "near_goal" );
	}

	heli thread heli_shoot_think();
	if ( heli.circling )
		heli thread heli_circling_think( heli_points, baseSpeed );
	else
		heli thread heli_goal_think( baseSpeed );
}

heli_circling_think( heli_points, baseSpeed )
{
	//create origins with "attack_heli_circle_node" targetname
	//each one targets 2 other origins
	//the heli randomly moves between the 2 points targeted by the closest node

	if ( !isdefined( heli_points ) )
		heli_points = "attack_heli_circle_node";

	points = GetEntArray( heli_points, "targetname" );
	if ( !isdefined( points ) || ( points.size < 1 ) )
		points = getstructarray( heli_points, "targetname" );

	Assert( IsDefined( points ) );

	heli = self;

	heli endon( "stop_circling" );
	heli endon( "death" );
	heli endon( "returning_home" );
	heli endon( "heli_players_dead" );

	for ( ;; )
	{
		heli Vehicle_SetSpeed( baseSpeed, baseSpeed / 4, baseSpeed / 4 );
		heli SetNearGoalNotifyDist( 100 );
		player = get_closest_player_healthy( heli.origin );
		playerOrigin = player.origin;
		heli SetLookAtEnt( player );

		player_location = getClosest( playerOrigin, points );
		heli_locations = GetEntArray( player_location.target, "targetname" );
		if ( !isdefined( heli_locations ) || ( heli_locations.size < 1 ) )
			heli_locations = getstructarray( player_location.target, "targetname" );
		Assert( IsDefined( heli_locations ) );
		goal = heli_locations[ RandomInt( heli_locations.size ) ];
		heli SetVehGoalPos( goal.origin, 1 );
		heli waittill( "near_goal" );

		if ( !isdefined( player.is_controlling_UAV ) )
		{
			wait 1;
			wait( RandomFloatRange( 0.8, 1.3 ) );
		}
	}
}

heli_goal_think( baseSpeed )
{
	self endon( "death" );
	points = GetEntArray( "kill_heli_spot", "targetname" );
	Assert( IsDefined( points ) );

	heli = self;
	goal = getClosest( heli.origin, points );
	current_node = goal;
	Assert( IsDefined( goal ) );
	heli endon( "death" );
	heli endon( "returning_home" );
	heli endon( "heli_players_dead" );
	eLookAtEnt = undefined;
	for ( ;; )
	{
		wait( 0.05 );
		/*-----------------------
		MOVE HELI TO CURRENT GOAL
		-------------------------*/	
		heli Vehicle_SetSpeed( baseSpeed, baseSpeed / 2, baseSpeed / 10 );
		heli SetNearGoalNotifyDist( 100 );
		player = get_closest_player_healthy( heli.origin );
		playerOrigin = player.origin;

		/*-----------------------
		DONT HOVER AT SAME NODE IF TAKING DAMAGE
		-------------------------*/	
		if ( ( goal == current_node ) && ( heli.isTakingDamage ) )
		{
			//if goal is current node and taking damage, choose another
			linked = get_linked_points( heli, goal, points, player, playerOrigin );
			goal = getClosest( playerOrigin, linked );
		}


		heli SetVehGoalPos( goal.origin, 1 );
		heli.moving = true;

		/*-----------------------
		HELI IS LOOKING AT CURRENT TARGET
		-------------------------*/	

		player = get_closest_player_healthy( heli.origin );


		if ( ( IsDefined( self.eTarget ) ) && ( IsDefined( self.eTarget.classname ) ) && ( self.eTarget.classname == "script_origin" ) )
			eLookAtEnt = player;
		else if ( isdefined( self.eTarget ) )
			eLookAtEnt = self.eTarget;
		else
			eLookAtEnt = self.targetdefault;
		
		heli SetLookAtEnt( eLookAtEnt );

		/*-----------------------
		HELI ARRIVES AT GOAL
		-------------------------*/	
		heli waittill( "near_goal" );
		heli.moving = false;

		/*-----------------------
		DONT MOVE IF PLAYER IS CURRENTLY AIMING WITH ROCKET (ON EASY AND NORMAL)
		-------------------------*/	
		if( !is_coop() )
		{
			if ( ( level.gameSkill == 0 ) || ( level.gameSkill == 1 ) )
			{
				while ( player_is_aiming_with_rocket( heli ) )
					wait( .5 );
				wait( 3 );
			}
		}
	
		/*-----------------------
		CHOOSE THE BEST NODE TO GO TO NEXT
		-------------------------*/	
		player = get_closest_player_healthy( heli.origin );
		playerOrigin = player.origin;

		linked = get_linked_points( heli, goal, points, player, playerOrigin );
		linked[ linked.size ] = goal;// add current node to possible points
		current_node = goal;

		//even if it's targeting another entity, always try to track down closest player
		player_location = getClosest( playerOrigin, points );
		closest_linked_point = getClosest( playerOrigin, linked );

		/*-----------------------
		CULL INVALID POINTS
		-------------------------*/	
		foreach ( point in linked )
		{
			//remove potential hover point if it cannot see any part of the player
			if ( player SightConeTrace( point.origin, heli ) != 1 )
			{
				linked = array_remove( linked, point );
				continue;
			}
		}

		//find the closest_neighbor with the culled linked points
		closest_neighbor = getClosest( playerOrigin, linked );

		//Only less than 2 points available, go to the last known closest linked point
		if ( linked.size < 2 )
			goal = closest_linked_point;

		//There is a point near the player but not right next to him
		else if ( closest_neighbor != player_location )
			goal = closest_neighbor;

		//the closest linked point IS the player position point, so pick either 2nd or 3rd best spot
		else
		{
			excluders = [];
			excluders[ 0 ] = closest_neighbor;
			//make "linked" array only contain the 2 closest points
			linked = get_array_of_closest( playerOrigin, linked, excluders, 2 );

			//randomly go to one of the two closest points or the player location
			iRand = RandomInt( linked.size );

			if ( RandomInt( 100 ) > 50 )
				goal = linked[ iRand ];
			else
				goal = player_location;
		}

		/*-----------------------
		WAIT TO MOVE, UNLESS BEING SHOT AT
		-------------------------*/
		fRand = RandomFloatRange( level.attackHeliMoveTime - 0.5, level.attackHeliMoveTime + 0.5 );
		self waittill_notify_or_timeout( "damage_by_player", fRand );
	}
}

player_is_aiming_with_rocket( eHeli )
{
	if ( !level.player usingAntiAirWeapon() )
		return false;
	if ( !level.player AdsButtonPressed() )
		return false;
	playerEye = level.player GetEye();
	if ( SightTracePassed( playerEye, eHeli.origin, false, level.player ) )
	{
		//thread debug_message( "AIMING", undefined, 1, eHeli );
		return true;
	}

	return false;
}

heli_shoot_think()
{
	self endon( "stop_shooting" );
	self endon( "death" );
	self endon( "heli_players_dead" );

	self thread heli_missiles_think();
	attackRangeSquared = level.attackheliRange * level.attackheliRange;
	level.attackHeliGracePeriod = false;

	while ( IsDefined( self ) )
	{

		wait( RandomFloatRange( 0.8, 1.3 ) );

		/*-----------------------
		TRY TO GET A PLAYER AS A TARGET FIRST
		-------------------------*/	
		//Heli has no target at all	or has a target but it's not the player		
		if ( ( !heli_has_target() ) || ( !heli_has_player_target() ) )
		{
			eTarget = self heli_get_target_player_only();
			if ( IsPlayer( eTarget ) )
			{
				self.eTarget = eTarget;

			}
		}

		/*-----------------------
		IF TARGET IS PLAYER MAKE SURE ITS THE CLOSEST PLAYER
		-------------------------*/		
		if ( ( heli_has_player_target() ) && ( level.players.size > 1 ) )
		{
			closest_player = get_closest_player_healthy( self.origin );
			if ( self.eTarget != closest_player )
			{
				eTarget = self heli_get_target_player_only();
				if ( IsPlayer( eTarget ) )
					self.eTarget = eTarget;
			}

		}
		/*-----------------------
		IF TARGET IS PLAYER MAKE SURE CAN STILL SEE
		-------------------------*/		
		if ( heli_has_player_target() )
		{
			if ( ( !heli_can_see_target() ) || ( level.attackHeliGracePeriod == true ) )
			{
				/*-----------------------
				IF CANT SEE PLAYER, GET A NEW NON-PLAYER TARGET
				-------------------------*/		
				eTarget = self heli_get_target_ai_only();
				self.eTarget = eTarget;
			}

		}

		/*-----------------------
		IF THE LAST GUY THAT ATTACKED IS A PLAYER, TARGET HIM NO MATTER WHERE HE IS
		-------------------------*/		
		if ( ( IsDefined( self.heli_lastattacker ) ) && ( IsPlayer( self.heli_lastattacker ) ) )
			self.eTarget = self.heli_lastattacker;


		/*-----------------------
		IF STILL NO VALID TARGET, GET AN ALTERNATE
		-------------------------*/		
		else if ( !heli_has_target() )
		{
			eTarget = self heli_get_target_ai_only();
			self.eTarget = eTarget;
		}

		/*-----------------------
		DON'T SHOOT IF IT'S NOT A VALID TARGET
		-------------------------*/	
		if ( !heli_has_target() )
			continue;

		/*-----------------------
		DON'T TRY TO SHOOT IF TARGET IN SAFE VOLUME
		-------------------------*/	
		if ( self.eTarget is_hidden_from_heli( self ) )
			continue;


		/*-----------------------
		DON'T TRY TO SHOOT IF TARGET OUT OF RANGE
		-------------------------*/	
		if ( ( heli_has_target() ) && ( DistanceSquared( self.eTarget.origin, self.origin ) > attackRangeSquared ) )
			continue;

		/*-----------------------
		MISS PLAYER INTENTIONALLY AT FIRST IF USING REGULAR TURRETS
		-------------------------*/	
		if ( ( self.turrettype == "default" ) && ( heli_has_player_target() ) )
		{
			//saw player, now miss for 2 bursts
			miss_player( self.eTarget );
			wait( RandomFloatRange( 0.8, 1.3 ) );

			miss_player( self.eTarget );
			wait( RandomFloatRange( 0.8, 1.3 ) );

			while ( can_see_player( self.eTarget ) && ( !self.eTarget is_hidden_from_heli( self ) ) )
			{
				fire_guns();
				wait( RandomFloatRange( 2.0, 4.0 ) );
			}
		}
		else
		{
			/*-----------------------
			FIRE AT TARGET
			-------------------------*/	
			//thread debug_message( "TARGET", undefined, 1, self.eTarget );
			if ( ( IsPlayer( self.eTarget ) ) || IsAI( self.eTarget ) )
				fire_guns();

			if ( IsPlayer( self.eTarget ) )
				thread player_grace_period( self );

			/*-----------------------
			WAIT A FEW MOMENTS TO REAQUIRE TARGETS (OR IMMEDIATELY IF BEING SHOT AT)
			-------------------------*/		
			//fRand = RandomFloatRange( 3, 5 );
			self waittill_notify_or_timeout( "damage_by_player", level.attackHeliTargetReaquire );
		}
	}
}

player_grace_period( eHeli )
{
	//if heli has been beating on the player, pick on someone else for this amt of time or until player attacks heli

	level notify( "player_is_heli_target" );
	level endon( "player_is_heli_target" );

	level.attackHeliGracePeriod = true;
	eHeli waittill_notify_or_timeout( "damage_by_player", level.attackHeliPlayerBreak );
	level.attackHeliGracePeriod = false;
}


heli_can_see_target()
{
	if ( !isdefined( self.eTarget ) )
		return false;
	org = self.eTarget.origin + ( 0, 0, 32 );
	if ( IsPlayer( self.eTarget ) )
		org = self.eTarget GetEye();

	tag_flash_loc = self GetTagOrigin( "tag_flash" );

	can_sight = SightTracePassed( tag_flash_loc, org, false, self );
	//can_see = BulletTracePassed( tag_flash_loc, org, false, self );
	//if( !can_see )
	//	thread draw_line_for_time( org, tag_flash_loc, 1, 0, 0, 1 );
	//if( !can_sight )
	//	thread draw_line_for_time( org, tag_flash_loc, 0, 1, 0, 1 );
	return can_sight;
}

heli_has_player_target()
{
	if ( !isdefined( self.eTarget ) )
		return false;
	if ( IsPlayer( self.eTarget ) )
		return true;
	else
		return false;
}

heli_has_target()
{
	if ( !isdefined( self.eTarget ) )
		return false;
	if ( !isalive( self.eTarget ) )
		return false;
	if ( self.eTarget == self.targetdefault )
		return false;
	else
		return true;
}

heli_get_target()
{

										//  getEnemyTarget( fRadius, iFOVcos, getAITargets, doSightTrace, getVehicleTargets, randomizeTargetArray, aExcluders )
	eTarget = maps\_helicopter_globals::getEnemyTarget( level.attackheliRange, level.attackHeliFOV, true, true, false, true, level.attackHeliExcluders );

	if ( ( IsDefined( eTarget ) ) && ( IsPlayer( eTarget ) ) )
		eTarget = self.targetdefault;
	if ( !isdefined( eTarget ) )
		eTarget = self.targetdefault;

	return eTarget;
}

heli_get_target_player_only()
{
	aExcluders = GetAIArray( "allies" );
									//  getEnemyTarget( fRadius, 			iFOVcos, 				getAITargets, doSightTrace, getVehicleTargets, randomizeTargetArray, aExcluders )
	eTarget = maps\_helicopter_globals::getEnemyTarget( level.attackheliRange, level.attackHeliFOV, true, false, false, false, aExcluders );


	if ( !isdefined( eTarget ) )
		eTarget = self.targetdefault;


	return eTarget;
}


heli_get_target_ai_only()
{

										//  getEnemyTarget( fRadius, iFOVcos, getAITargets, doSightTrace, getVehicleTargets, randomizeTargetArray, aExcluders )
	eTarget = maps\_helicopter_globals::getEnemyTarget( level.attackheliRange, level.attackHeliFOV, true, true, false, true, level.players );

	if ( !isdefined( eTarget ) )
		eTarget = self.targetdefault;

	return eTarget;
}



//heli_turret_think_old()
//{
//	self endon( "stop_shooting" );
//	self endon( "death" );
//	while ( true )
//	{
//		//choose our target based on distance and visibility
//		player = get_closest_player( self.origin );
//		if ( ! can_see_player( player ) )
//		{
//			dif_player = get_different_player( player );
//			if ( can_see_player( dif_player ) )
//				player = dif_player;
//		}
//		wait( RandomFloatRange( 0.8, 1.3 ) );
//
//		// don't try to shoot a player with an RPG or Stinger
//		if ( player usingAntiAirWeapon() )
//			continue;
//
//		//dont try to shoot a player who is hiding a safe volume
//		if ( player is_hidden_from_heli( self ) )
//			continue;
//
//		//wait for player to be visible
//		while ( !can_see_player( player ) )
//			wait( RandomFloatRange( 0.8, 1.3 ) );
//
//		/*-----------------------
//		MISS PLAYER INTENTIONALLY IF USING REGULAR TURRETS
//		-------------------------*/	
//		if ( self.turrettype == "default" )
//		{
//			//saw player, now miss for 2 bursts
//			miss_player( player );
//			wait( RandomFloatRange( 0.8, 1.3 ) );
//	
//			miss_player( player );
//			wait( RandomFloatRange( 0.8, 1.3 ) );
//		}
//
//		/*-----------------------
//		HIT PLAYER IF STILL EXPOSED
//		-------------------------*/	
//		while ( can_see_player( player ) && !player usingAntiAirWeapon() && !player is_hidden_from_heli( self ) )
//		{
//			fire_at_player( player );
//			wait( RandomFloatRange( 1.0, 2.0 ) );
//		}
//		
//		//player is hidden, now will suppress/hit him for 2 bursts if he tries to peek out
//		if ( !player usingAntiAirWeapon() && !player is_hidden_from_heli( self ) )
//			fire_at_player( player );
//		wait( RandomFloatRange( 1.0, 2.0 ) );
//
//		if ( !player usingAntiAirWeapon() && !player is_hidden_from_heli( self ) )
//			fire_at_player( player );
//	}
//}

heli_missiles_think()
{
	if ( !isdefined( self.script_missiles ) )
		return;

	self endon( "death" );
	self endon( "heli_players_dead" );
	self endon( "stop_shooting" );

	iShots = undefined;
	defaultWeapon = "turret_attackheli";
	weaponName = "missile_attackheli";
	weaponShootDelay  = undefined;
	loseTargetDelay  = undefined;
	tags = [];

	switch( self.vehicletype )
	{
		case "mi28":
			iShots = 1;
			weaponShootDelay = 1;
			loseTargetDelay  = 0.5;
			tags[ 0 ] = "tag_store_L_2_a";
			tags[ 1 ] = "tag_store_R_2_a";
			tags[ 2 ] = "tag_store_L_2_b";
			tags[ 3 ] = "tag_store_R_2_b";
			tags[ 4 ] = "tag_store_L_2_c";
			tags[ 5 ] = "tag_store_R_2_c";
			tags[ 6 ] = "tag_store_L_2_d";
			tags[ 7 ] = "tag_store_R_2_d";
			break;
		case "littlebird":
			iShots = 1;
			weaponShootDelay = 1;
			loseTargetDelay  = 0.5;
			tags[ 0 ] = "tag_missile_left";
			tags[ 1 ] = "tag_missile_right";
			break;
		default:
			AssertMsg( "Missiles have not been setup for helicoper model: " + self.vehicletype );
			break;
	}
	nextMissileTag = -1;

	while ( true )
	{
		wait( 0.05 );
		self waittill( "fire_missiles", other );
		if ( !isplayer( other ) )
			continue;

		player = other;
		if ( !player_is_good_missile_target( player ) )
			continue;
		for ( i = 0 ; i < iShots ; i++ )
		{
			nextMissileTag++;
			if ( nextMissileTag >= tags.size )
				nextMissileTag = 0;

			self SetVehWeapon( weaponName );
			self.firingMissiles = true;
			eMissile = self FireWeapon( tags[ nextMissileTag ], player );
			eMissile thread missileLoseTarget( loseTargetDelay );
			eMissile thread missile_earthquake();
			if ( i < iShots - 1 )
				wait weaponShootDelay;
		}
		self.firingMissiles = false;
		self SetVehWeapon( defaultWeapon );
		wait( 10 );
	}
}

player_is_good_missile_target( player )
{
	if ( self.moving )
		return false;
	else
		return true;
}

missile_earthquake()
{
	//does an earthquake when a missile hits and explodes
	if ( DistanceSquared( self.origin, level.player.origin ) > 9000000 )
		return;
	org = self.origin;
	while ( IsDefined( self ) )
	{
		org = self.origin;
		wait( 0.1 );
	}
	Earthquake( 0.7, 1.5, org, 1600 );
}

missileLoseTarget( fDelay )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	wait fDelay;
	if ( IsDefined( self ) )
		self Missile_ClearTarget();
}

get_different_player( player )
{
	for ( i = 0; i < level.players.size; i++ )
	{
		if ( player != level.players[ i ] )
			return level.players[ i ];
	}
	return level.players[ 0 ];
}

notify_disable()
{
	self notify( "notify_disable_thread" );
	self endon( "notify_disable_thread" );
	self endon( "death" );
	self endon( "heli_players_dead" );
	for ( ;; )
	{
		self waittill( "disable_turret" );
		self.allowShoot = false;
	}
}

notify_enable()
{
	self notify( "notify_enable_thread" );
	self endon( "notify_enable_thread" );
	self endon( "death" );
	self endon( "heli_players_dead" );
	for ( ;; )
	{
		self waittill( "enable_turret" );
		self.allowShoot = true;
	}
}

fire_guns()
{

	/*-----------------------
	FIRE MAIN TURRET OR MINIGUNS
	-------------------------*/	
	switch( self.turrettype )
	{
		//regular default turret
		case "default":
			burstsize = RandomIntRange( 5, 10 );
			fireTime = WeaponFireTime( "turret_attackheli" );
			self turret_default_fire( self.eTarget, burstsize, fireTime );
			break;
		case "miniguns":
			burstsize = getburstsize( self.eTarget );
			if ( ( self.allowShoot ) && ( !self.firingMissiles ) )
				self turret_minigun_fire( self.eTarget, burstsize );
			break;
		default:
			AssertMsg( "Gun firing logic has not been set up in the _attack_heli.gsc script for helicopter type: " + self.turrettype );
			break;
	}
}

getburstsize( eTarget )
{
	burstsize = undefined;
	if ( !isplayer( eTarget ) )
	{
		burstsize = level.attackHeliAIburstSize;
		return burstsize;
	}

	switch( level.gameSkill )
	{
		case 0:// easy
		case 1:// regular
		case 2:// hardened
		case 3:// veteran
			burstsize = RandomIntRange( 2, 3 );
			break;
	}
	return burstsize;
}

fire_missiles( fDelay )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	wait( fDelay );
	if ( !isplayer( self.eTarget ) )
		return;
	self notify( "fire_missiles", self.eTarget );
}

turret_default_fire( eTarget, burstsize, fireTime )
{
	self thread fire_missiles( RandomFloatRange( .2, 2 ) );

	/*-----------------------
	DEFAULT MAIN TURRET OF MOST CHOPPERS
	-------------------------*/	
	for ( i = 0; i < burstsize; i++ )
	{
		self SetTurretTargetEnt( eTarget, randomvector( 50 ) + ( 0, 0, 32 ) );
		//self SetTurretTargetEnt( eTarget, ( 0, 0, 32 ) );
		if ( ( self.allowShoot ) && ( !self.firingMissiles ) )
			self FireWeapon();
		wait fireTime;
	}
}

/*
=============
///ScriptDocBegin
"Name: turret_minigun_fire( <eTarget>, <burstsize>, <max_warmup_time> )"
"Summary: Fires minigun turrets mounted on a vehicle (such as dual miniguns of the Littlebird). Will play appropriate spin up and spin down sounds"
"Module: Vehicle"
"MandatoryArg: <eTarget>: Target entity to fire at"
"OptionalArg: <burstsize>: Length of time to fire the guns"
"OptionalArg: <delay>: Delay between multiple missiles fired. Defaults to one second"
"OptionalArg: <max_warmup_time>: Max random delay before it begins firing"
"Example: eHeli thread maps\_attack_heli::turret_minigun_fire( eTarget, 10 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
turret_minigun_fire( eTarget, burstsize, max_warmup_time )
{
	/*-----------------------
	DUAL MINIGUNS (FOR LITTLEBIRDS)
	-------------------------*/	
	self endon( "death" );
	self endon( "heli_players_dead" );
	self notify( "firing_miniguns" );
	self endon( "firing_miniguns" );

	turrets = self get_turrets();
	array_thread( turrets, ::turret_minigun_target_track, eTarget, self );
	if ( !self.minigunsspinning )
	{
		self.firingguns = true;
		self thread play_sound_on_tag( "littlebird_gatling_spinup", "tag_flash" );
		wait( 2.1 );
		self thread play_loop_sound_on_tag( "littlebird_minigun_spinloop", "tag_flash" );
	}

	self.minigunsspinning = true;

	if ( !isdefined( max_warmup_time ) )
		max_warmup_time = 3;

	min_warmup_time = 0.5;
	if ( min_warmup_time > max_warmup_time )
	{
		min_warmup_time = max_warmup_time;
	}

	if ( min_warmup_time > 0 )
	{
		wait( RandomFloatRange( min_warmup_time, max_warmup_time ) );
	}


	minigun_fire( eTarget, burstsize );
	turrets = self get_turrets();
	array_call( turrets, ::StopFiring );
//	array_thread( turrets, ::send_notify, "turretstatechange" );

	self thread minigun_spindown( eTarget );
	self notify( "stopping_firing" );
}

minigun_fire( eTarget, burstsize )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	if ( IsPlayer( eTarget ) )
		self endon( "cant_see_player" );

	turrets = self get_turrets();
	array_call( turrets, ::StartFiring );
//	array_thread( turrets, ::send_notify, "turretstatechange" );

	wait( RandomFloatRange( 1, 2 ) );

	if ( IsPlayer( eTarget ) )
		self thread target_track( eTarget );

	if ( IsPlayer( eTarget ) )
	{
		fRand = RandomFloatRange( .5, 3 );
		self thread fire_missiles( fRand );
	}

	wait( burstsize );
}



target_track( eTarget )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	self endon( "stopping_firing" );
	self notify( "tracking_player" );
	self endon( "tracking_player" );
	while ( true )
	{
		if ( !can_see_player( eTarget ) )
			break;
		wait( .5 );
	}
	wait level.attackHeliTimeout;
	self notify( "cant_see_player" );
}

turret_minigun_target_track( eTarget, eHeli )
{
	//self ==> individual minigun turret
	eHeli endon( "death" );
	eHeli endon( "heli_players_dead" );
	self notify( "miniguns_have_new_target" );
	self endon( "miniguns_have_new_target" );

	//If it's an AI, shoot 100 units above his origin unless scripted wants otherwise
	if ( ( !isPlayer( eTarget ) ) && ( IsAI( eTarget ) ) && ( level.attackHeliKillsAI == false ) )
	{
		eFake_AI_Target = Spawn( "script_origin", eTarget.origin + ( 0, 0, 100 ) );
		eFake_AI_Target LinkTo( eTarget );
		self thread minigun_AI_target_cleanup( eFake_AI_Target );
		eTarget = eFake_AI_Target;
	}
	while ( true )
	{
		wait( .5 );
		self SetTargetEntity( eTarget );
	}
}

//used to delete the fake target the AI has over his head when heli miniguns find a new target
minigun_AI_target_cleanup( eFake_AI_Target )
{
	self waittill_either( "death", "miniguns_have_new_target" );
	eFake_AI_Target Delete();
}

minigun_spindown( eTarget )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	self endon( "firing_miniguns" );
	if ( IsPlayer( eTarget ) )
		wait( RandomFloatRange( 3, 4 ) );		// if player is the target, wait a few seconds before giving up
	else
		wait( RandomFloatRange( 1, 2 ) );
	self thread minigun_spindown_sound();
	self.firingguns = false;
}

minigun_spindown_sound()
{
	self notify( "stop sound" + "littlebird_minigun_spinloop" );
	self.minigunsspinning = false;
	self play_sound_on_tag( "littlebird_gatling_cooldown", "tag_flash" );
}

miss_player( player )
{
	//for default turret types to allow the player to hide before getting owned

	PrintLn( "_attack_heli.gsc           missing player" );

	//right = AnglesToRight( self.angles );
	//miss_vec = vector_multiply( right, RandomIntRange( 128, 256 ) );
	//miss_vec = vector_multiply( right, RandomIntRange( 64, 128 ) );
	//if ( RandomInt( 2 ) == 0 )
	//	miss_vec *= -1;

	//point between player and heli
	//vec = VectorNormalize( self.origin - level.player.origin );
	//forward = vector_multiply( vec, 400 );
	//miss_vec = forward + ( 0, 0, -128 ) + randomvector( 50 );

	//point in front of player
	forward = AnglesToForward( level.player.angles );
	forwardfar = vector_multiply( forward, 400 );
	miss_vec = forwardfar + randomvector( 50 );


	burstsize = RandomIntRange( 10, 20 );
	fireTime = WeaponFireTime( "turret_attackheli" );
	for ( i = 0; i < burstsize; i++ )
	{
		//debug_org = ( player.origin + miss_vec );
		//thread draw_line_for_time( debug_org, debug_org + ( 0, 0, 10 ), 1, 0, 0, 5.0 );

		miss_vec = forwardfar + randomvector( 50 );

		self SetTurretTargetEnt( player, miss_vec );
		if ( self.allowShoot )
			self FireWeapon();
		wait fireTime;
	}
}

can_see_player( player )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	tag_flash_loc = self GetTagOrigin( "tag_flash" );
	//BulletTracePassed( <start>, <end>, <hit characters>, <ignore entity> );
	if ( SightTracePassed( tag_flash_loc, player GetEye(), false, undefined ) )
		return true;
	else
	{
		PrintLn( "_attack_heli.gsc        ---trace failed" );
		return false;
	}
}

get_linked_points( heli, goal, points, player, playerOrigin )
{
	/*-----------------------
	GET ALL LINKED POINTS FROM GURRENT GOAL
	-------------------------*/	
	linked = [];
	tokens = StrTok( goal.script_linkto, " " );
	for ( i = 0; i < points.size; i++ )
	{
		for ( j = 0; j < tokens.size; j++ )
		{
			if ( points[ i ].script_linkName == tokens[ j ] )
				linked[ linked.size ] = points[ i ];
		}
	}

	/*-----------------------
	REMOVE ANY POINTS THAT ARE INVALID
	-------------------------*/	
	foreach ( point in linked )
	{
		//remove potential hover point if it is physically below the player
		if ( point.origin[ 2 ] < playerOrigin[ 2 ] )
		{
			linked = array_remove( linked, point );
			continue;
		}

	}

	return linked;
}

heli_damage_monitor()
{
	if ( !getDvarInt( "scr_damagefeedback", 0 ) )
		damage_feedback = false;
	else
		damage_feedback = true;

	self endon( "death" );
	self endon( "heli_players_dead" );
	self endon( "crashing" );
	self endon( "leaving" );

	self.damagetaken = 0;
	self.seen_attacker = undefined;

	for ( ;; )
	{
		// this damage is done to self.health which isnt used to determine the helicopter's health, damageTaken is.
		self waittill( "damage", damage, attacker, direction_vec, P, type );

		if ( !isdefined( attacker ) || !isplayer( attacker ) )
			continue;

		self notify( "damage_by_player" );
		self thread heli_damage_update();
		self thread can_see_attacker_for_a_bit( attacker );
		if ( damage_feedback )
			attacker thread updateDamageFeedback();
	}
}

heli_damage_update()
{
	self notify( "taking damage" );
	self endon( "taking damage" );
	self endon( "death" );
	self endon( "heli_players_dead" );
	self.isTakingDamage = true;
	wait( 1 );
	self.isTakingDamage = false;
}


can_see_attacker_for_a_bit( attacker )
{
	self notify( "attacker_seen" );
	self endon( "attacker_seen" );
	self.seen_attacker = attacker;

	/*-----------------------
	HELI REMEMBERS THE PLAYER WHO DAMAGED HIM FOR A FEW SECONDS
	-------------------------*/	
	self.heli_lastattacker = attacker;
	wait level.attackHeliMemory;
	self.heli_lastattacker = undefined;

	self.seen_attacker = undefined;
}

is_hidden_from_heli( heli )
{
	if ( IsDefined( heli.seen_attacker ) )
		if ( heli.seen_attacker == self )
			return false;
	if ( IsDefined( level.attack_heli_safe_volumes ) )
	{
		foreach ( volume in level.attack_heli_safe_volumes )
			if ( self IsTouching( volume ) )
				return true;
	}
	return false;
}

updateDamageFeedback()
{
	if ( !isPlayer( self ) )
		return;

	self.hud_damagefeedback SetShader( "damage_feedback", 24, 48 );
	self PlayLocalSound( "player_feedback_hit_alert" );

	self.hud_damagefeedback.alpha = 1;
	self.hud_damagefeedback FadeOverTime( 1 );
	self.hud_damagefeedback.alpha = 0;
}

damage_feedback_setup()
{
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[ i ];
		player.hud_damagefeedback = NewClientHudElem( player );
		player.hud_damagefeedback.horzAlign = "center";
		player.hud_damagefeedback.vertAlign = "middle";
		player.hud_damagefeedback.x = -12;
		player.hud_damagefeedback.y = -12;
		player.hud_damagefeedback.alpha = 0;
		player.hud_damagefeedback.archived = true;
		player.hud_damagefeedback SetShader( "damage_feedback", 24, 48 );
	}
}

heli_death_monitor()
{
	self waittill( "death" );
	level notify( "attack_heli_destroyed" );
	level.enemy_heli_killed = true;
	wait 15;
	level.enemy_heli_attacking = false;
}

dialog_nags_heli( heli )
{
	heli endon( "death" );
	heli endon( "heli_players_dead" );
	wait 30;

	if ( ! level.enemy_heli_attacking )
		return;

	commander_dialog( "co_cf_cmd_heli_small_fire" );
	//"That heli is vulnerable to small arms fire." 

	if ( ! level.enemy_heli_attacking )
		return;

	commander_dialog( "co_cf_cmd_rpg_stinger" );
	//"Otherwise look for an RPG or Stinger." 

	wait 30;

	if ( ! level.enemy_heli_attacking )
		return;
	commander_dialog( "co_cf_cmd_heli_wonders" );
	//"Charlie Four, an RPG or Stinger would do wonders against that heli." 
}

commander_dialog( dialog_line )
{
	while ( level.commander_speaking )
		wait 1;

	level.commander_speaking = true;
	level.player PlaySound( dialog_line, "sounddone" );
	level.player waittill( "sounddone" );
	wait .5;
	level.commander_speaking = false;
}

usingAntiAirWeapon()
{
	weapon = self GetCurrentWeapon();

	if ( !isdefined( weapon ) )
		return false;

	if ( IsSubStr( ToLower( weapon ), "rpg" ) )
		return true;

	if ( IsSubStr( ToLower( weapon ), "stinger" ) )
		return true;

	if ( IsSubStr( ToLower( weapon ), "at4" ) )
		return true;

	return false;
}


heli_spotlight_cleanup( sTag )
{
	self waittill_any( "death", "crash_done", "turn_off_spotlight" );
	self.spotlight = undefined;
	if ( IsDefined( self ) )
		StopFXOnTag( getfx( "_attack_heli_spotlight" ), self, sTag );
}

heli_spotlight_aim()
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	/*-----------------------
	HELI SPOTLIGHT AIMING LOGIC
	-------------------------*/	

	if ( self.vehicletype != "littlebird" )// no need to aim...default gun turret will handle aiming at it's target
		return;
	self thread heli_spotlight_think();
	eSpotlightTarget = undefined;
	while ( true )
	{
		wait( .05 );
		switch( self.vehicletype )
		{
			case "littlebird":	// littlebird doesn't use its turret to shoot...only to point spotlight
				eSpotlightTarget = self.spotTarget;// have it point at any of the default targets so it scans, or sometimes the player
				break;
			default:		// no choice for most other helis since the spotlight is attached to the actual turret
				eSpotlightTarget = self.eTarget;
				break;
		}
		if ( IsDefined( eSpotlightTarget ) )
			self SetTurretTargetEnt( eSpotlightTarget, ( 0, 0, 0 ) );
	}
}

heli_spotlight_think()
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	original_ent = self.targetdefault;
	original_ent.targetname = "original_ent";

	self.left_ent = Spawn( "script_origin", original_ent.origin );
	self.left_ent.origin = original_ent.origin;
	self.left_ent.angles = original_ent.angles;
	self.left_ent.targetname = "left_ent";

	self.right_ent = Spawn( "script_origin", original_ent.origin );
	self.right_ent.origin = original_ent.origin;
	self.right_ent.angles = original_ent.angles;
	self.right_ent.targetname = "right_ent";


	ent = SpawnStruct();
	ent.entity = self.left_ent;
	ent.right = 250;
	ent translate_local();
	self.left_ent LinkTo( self );

	ent2 = SpawnStruct();
	ent2.entity = self.right_ent;
	ent2.right = -250;
	ent2 translate_local();
	self.right_ent LinkTo( self );

	aim_ents = [];
	aim_ents[ 0 ] = original_ent;
	aim_ents[ 1 ] = self.left_ent;
	aim_ents[ 2 ] = self.right_ent;

	//foreach ( ent in aim_ents )
		//thread debug_message( ent.targetname, undefined, 9999, ent );

	self.spotTarget = original_ent;

	array_thread( aim_ents, ::heli_spotlight_aim_ents_cleanup, self );

	while ( true )
	{
		wait( RandomFloatRange( 1, 3 ) );

		//shine on the player if the heli is currently targeting the player and player is not looking at the heli
		if	( ( heli_has_player_target() ) && ( !self within_player_fov() ) )
		{
			self.spotTarget = self.eTarget;
		}
		else// otherwise just aim at one of the default targets
		{
			iRand = RandomInt( aim_ents.size );
			self.targetdefault = aim_ents[ iRand ];
			self.spotTarget = self.targetdefault;

		}

	}
}

within_player_fov()
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	if ( !isdefined( self.eTarget ) )
		return false;
	if ( !isPlayer( self.eTarget ) )
		return false;
	player = self.eTarget;
	bInFOV = within_fov( player GetEye(), player GetPlayerAngles(), self.origin, level.cosine[ "35" ] );
	return bInFOV;
}

heli_spotlight_aim_ents_cleanup( eHeli )
{
	eHeli waittill_either( "death", "crash_done" );
	if ( IsDefined( self ) )
		self Delete();
}

littlebird_turrets_think( eHeli )
{
	//"self ==> each of the attached minigun turrets
	eTurret = self;
	eTurret turret_set_default_on_mode( "manual" );
	if ( IsDefined( eHeli.targetdefault ) )
		eTurret SetTargetEntity( eHeli.targetdefault );

	eTurret SetMode( "manual" );

	//clean up minigun sound in case it was firing while getting killed
	eHeli waittill( "death" );
	if ( ( IsDefined( eHeli.firingguns ) ) && ( eHeli.firingguns == true ) )
		self thread minigun_spindown_sound();

}

attack_heli_cleanup()
{
	self waittill_either( "death", "crash_done" );
	if ( IsDefined( self.attractor ) )
		Missile_DeleteAttractor( self.attractor );

	if ( IsDefined( self.attractor2 ) )
		Missile_DeleteAttractor( self.attractor2 );
}

/*
=============
///ScriptDocBegin
"Name: heli_default_missiles_on()"
"Summary: Call this on a spawned heli to fire missiles at any nodes that are linked(with script_linkTo)"
"OptionalArg: <customMissiles>: Pass in a custom missile name to use. Otherwise will default to missile_attackheli"
"Module: Vehicle"
"Example: self thread maps\_attack_heli::heli_default_missiles_on();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
heli_default_missiles_on( customMissiles )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	self endon( "stop_default_heli_missiles" );
	self.preferredTarget = undefined;
	while ( IsDefined( self ) )
	{
		wait( 0.05 );
		eTarget = undefined;
		iShots = undefined;
		delay = undefined;
		self.preferredTarget = undefined;
		eNextNode = undefined;

		/*-----------------------
		SEE IF THERE IS A NEXT NODE IN CHAIN
		-------------------------*/				
		if ( ( IsDefined( self.currentnode ) ) && ( IsDefined( self.currentnode.target ) ) )
			eNextNode = getent_or_struct( self.currentnode.target, "targetname" );

		/*-----------------------
		CHECK IF NEXT NODE HAS ANY PREFERRED TARGETS
		-------------------------*/		
		if ( ( IsDefined( eNextNode ) ) && ( IsDefined( eNextNode.script_linkTo ) ) )
			self.preferredTarget = getent_or_struct( eNextNode.script_linkTo, "script_linkname" );

		if ( IsDefined( self.preferredTarget ) )
		{
			eTarget = self.preferredTarget;
			iShots = eTarget.script_shotcount;
			delay = eTarget.script_delay;
			eNextNode waittill( "trigger" );
		}
		else
			self waittill_any( "near_goal", "goal" );

		/*-----------------------
		FIRE MISSILES IF I HAVE A GOOD TARGET
		-------------------------*/		
		if ( IsDefined( eTarget ) )
		{
			self thread heli_fire_missiles( eTarget, iShots, delay, customMissiles );
		}

	}
}

/*
=============
///ScriptDocBegin
"Name: heli_default_missiles_off()"
"Summary: Call this on a spawned heli to stop firing missiles at linked nodes"
"Module: Vehicle"
"Example: self thread maps\_attack_heli::heli_default_missiles_off();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
heli_default_missiles_off()
{
	self notify( "stop_default_heli_missiles" );
}



/*
=============
///ScriptDocBegin
"Name: heli_spotlight_on( <sTag>, <bUseAttackHeliBehavior> )"
"Summary: Turns on a spotlight on a helicopter. The spotlight is not aimed anywhere unless you are using the AI in the _attack_heli script and setting bUseAttackHeliBehavior to true"
"Module: Vehicle"
"OptionalArg: <sTag>: Specify the tag where the spotlight will attach to (tag_barrel is the default so that any turret aiming logic will aim the spotlight as well)"
"OptionalArg: <bUseAttackHeliBehavior>: Only set this to true if you are using the AI behavior in the _attack_heli script"
"Example: attack_heli thread maps\_attack_heli::heli_spotlight_on();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
heli_spotlight_on( sTag, bUseAttackHeliBehavior )
{
	if ( !isdefined( sTag ) )
		sTag = "tag_barrel";
	if ( !isdefined( bUseAttackHeliBehavior ) )
		bUseAttackHeliBehavior = false;


	PlayFXOnTag( getfx( "_attack_heli_spotlight" ), self, sTag );
	self.spotlight = 1;
	self thread heli_spotlight_cleanup( sTag );

	if ( bUseAttackHeliBehavior )
	{
		//give the turret/spotlight an initial target
		self endon( "death" );
		self endon( "heli_players_dead" );
		spawn_origin = self GetTagOrigin( "tag_origin" );

		if ( !isdefined( self.targetdefault ) )
			self heli_default_target_setup();
		self SetTurretTargetEnt( self.targetdefault );
		self thread heli_spotlight_aim();
	}
}

/*
=============
///ScriptDocBegin
"Name: heli_spotlight_off()"
"Summary: Turns off a spotlight on a helicopter that had it turned on with the heli_spotlight_on() function"
"Module: Vehicle"
"Example: eHeli thread maps\_attack_heli::heli_spotlight_off();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
heli_spotlight_off()
{
	self notify( "turn_off_spotlight" );
}


/*
=============
///ScriptDocBegin
"Name: heli_spotlight_random_targets_on()"
"Summary: Aims the helicopter turret randomly in a sweeping motion in front of the heli. Must first turn on the spotlight effect with heli_spotlight_on()"
"Module: Vehicle"
"Example: eHeli thread maps\_attack_heli::heli_spotlight_random_targets_on();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
heli_spotlight_random_targets_on()
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	self endon( "stop_spotlight_random_targets" );
	//setup default targets
	if ( !isdefined( self.targetdefault ) )
		self thread heli_default_target_setup();	// gives the heli an "self.targetdefault" right in front of its nose

	if ( !isdefined( self.left_ent ) )
		self thread heli_spotlight_think();			// spawns 2 more attached script_origins on the left and right and
												//and randomly makes one of the three the heli's "self.targetdefault"

	while ( IsDefined( self ) )
	{
		wait( .05 );
		self SetTurretTargetEnt( self.targetdefault, ( 0, 0, 0 ) );
	}
}

/*
=============
///ScriptDocBegin
"Name: heli_spotlight_random_targets_off()"
"Summary: Stopss the helicopter turret randomly aiming turret in a sweeping motion in front of the heli()"
"Module: Vehicle"
"Example: eHeli thread maps\_attack_heli::heli_spotlight_random_targets_off();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
heli_spotlight_random_targets_off()
{
	self notify( "stop_spotlight_random_targets" );
}


/*
=============
///ScriptDocBegin
"Name: heli_fire_missiles( <eTarget>, <iShots>, <delay> )"
"Summary: Fires missiles from a helicopter at a target"
"Module: Vehicle"
"MandatoryArg: <eTarget>: Target entity to fire at"
"OptionalArg: <iShots>: Number of missiles to fire 9default = 1)."
"OptionalArg: <delay>: Delay between multiple missiles fired. Defaults to one second"
"OptionalArg: <customMissiles>: Pass in a custom missile to use. Otherwise will default to missile_attackheli"
"Example: eHeli thread maps\_attack_heli::heli_fire_missiles( eTarget, 2, .5 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
heli_fire_missiles( eTarget, iShots, delay, customMissiles )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	if ( IsDefined( self.defaultWeapon ) )
		defaultWeapon = self.defaultWeapon;
	else
		defaultWeapon = "turret_attackheli";
	weaponName = "missile_attackheli";
	if ( isdefined( customMissiles ) )
		weaponName = customMissiles;
	loseTargetDelay  = undefined;
	tags = [];
	self SetVehWeapon( defaultWeapon );
	if ( !isdefined( iShots ) )
		iShots = 1;
	if ( !isdefined( delay ) )
		delay = 1;
	
	//if the target is a struct, need to spawn a dummy ent to fire at
	if ( !isdefined( eTarget.classname ) )
	{
		if ( !isdefined( self.dummyTarget) )
		{
			self.dummyTarget = Spawn( "script_origin", eTarget.origin );
			self thread delete_on_death( self.dummyTarget );
		}
		self.dummyTarget.origin = eTarget.origin;
		eTarget = self.dummyTarget;
	}
	
	switch( self.vehicletype )
	{
		case "mi28":
			loseTargetDelay  = 0.5;
			tags[ 0 ] = "tag_store_L_2_a";
			tags[ 1 ] = "tag_store_R_2_a";
			tags[ 2 ] = "tag_store_L_2_b";
			tags[ 3 ] = "tag_store_R_2_b";
			tags[ 4 ] = "tag_store_L_2_c";
			tags[ 5 ] = "tag_store_R_2_c";
			tags[ 6 ] = "tag_store_L_2_d";
			tags[ 7 ] = "tag_store_R_2_d";
			break;
		case "littlebird":
			loseTargetDelay  = 0.5;
			tags[ 0 ] = "tag_missile_left";
			tags[ 1 ] = "tag_missile_right";
			break;
		default:
			AssertMsg( "Missiles have not been setup for helicoper model: " + self.vehicletype );
			break;
	}
	nextMissileTag = -1;

	for ( i = 0 ; i < iShots ; i++ )
	{
		nextMissileTag++;
		if ( nextMissileTag >= tags.size )
			nextMissileTag = 0;

		self SetVehWeapon( weaponName );
		self.firingMissiles = true;
		eMissile = self FireWeapon( tags[ nextMissileTag ], eTarget );
		//eMissile thread missileLoseTarget( loseTargetDelay );
		eMissile thread missile_earthquake();
		if ( i < iShots - 1 )
			wait delay;
	}
	self.firingMissiles = false;
	self SetVehWeapon( defaultWeapon );

}

boneyard_style_heli_missile_attack()
{
	self waittill( "trigger", vehicle );
	struct_arr = getstructarray( self.target, "targetname" );
	struct_arr = array_index_by_script_index( struct_arr );
	
	boneyard_fire_at_targets( vehicle, struct_arr );
}

boneyard_style_heli_missile_attack_linked()
{
	self waittill( "trigger", vehicle );
	
	struct_arr = self get_linked_structs();
	struct_arr = array_index_by_script_index( struct_arr );
	
	boneyard_fire_at_targets( vehicle, struct_arr );
}

boneyard_fire_at_targets( vehicle, struct_arr )
{
	tags = [];
	tags[ 0 ] = "tag_missile_right";
	tags[ 1 ] = "tag_missile_left";
	
	if ( level.script == "roadkill" )
	{
		// apaches use insane tag names. It's like a weird form of binary.
		tags[ 0 ] = "tag_flash_2"; // 2 means right
		tags[ 1 ] = "tag_flash_11"; // 11 means left ><
	}

	if ( vehicle.vehicletype == "cobra" )
	{
		tags[ 0 ] = "tag_store_L_1_a";
		tags[ 1 ] = "tag_store_R_1_a";
	}

	ents = [];

	for ( i = 0; i < struct_arr.size; i++ )
	{
		AssertEx( IsDefined( struct_arr[ i ] ), "boneyard_style_heli_missile_attack requires script_index key/value to start at 0 and not have any gaps." );

		ents[ i ] = Spawn( "script_origin", struct_arr[ i ].origin );

		vehicle SetVehWeapon( "littlebird_FFAR" );
		vehicle SetTurretTargetEnt( ents[ i ] );
		missile = vehicle FireWeapon( tags[ i % tags.size ], ents[ i ], ( 0, 0, 0 ) );

		missile delayCall( 1, ::Missile_ClearTarget );

		wait RandomFloatRange( 0.2, 0.3 );
	}

	wait 2;
	foreach ( ent in ents )
	{
		ent Delete();
	}
}


