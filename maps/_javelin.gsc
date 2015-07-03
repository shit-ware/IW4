#include maps\_utility;
#include common_scripts\utility;


PlayerJavelinAds()
{
	//self --> the player
	if ( self playerads() < 1.0 )
		return false;

	weap = self getCurrentWeapon();
	if ( !IsSubStr( weap, "javelin" ) )
		return false;

	return true;

}


InsideJavelinReticleNoLock( target )
{
	//self --> the player
	//TODO: sighttrace
	return target_isinrect( target, self, 25, 60, 30 );
}


InsideJavelinReticleLocked( target )
{
	//self --> the player
	//TODO: sighttrace
	return target_isinrect( target, self, 25, 90, 45 );
}


ClearCLUTarget()
{
	//self --> the player
	self notify( "javelin_clu_cleartarget" );
	self notify( "stop_lockon_sound" );
	level.javelinLockStartTime = 0;
	level.javelinLockStarted = false;
	level.javelinLockFinalized = false;
	level.javelinTarget = undefined;
	self WeaponLockFree();
	self WeaponLockTargetTooClose( false );
	self WeaponLockNoClearance( false );
	self StopLocalSound( "javelin_clu_lock" );
	self StopLocalSound( "javelin_clu_aquiring_lock" );
}


GetBestJavelinTarget()
{
	//self --> the player
	targetsAll = target_getArray();
	targetsValid = [];

	for ( idx = 0; idx < targetsAll.size; idx++ )
	{
		if ( self InsideJavelinReticleNoLock( targetsAll[ idx ] ) )
			targetsValid[ targetsValid.size ] = targetsAll[ idx ];

		target_setOffscreenShader( targetsAll[ idx ], "javelin_hud_target_offscreen" );
	}

	if ( targetsValid.size == 0 )
		return undefined;

	chosenEnt = targetsValid[ 0 ];
	if ( targetsValid.size > 1 )
	{
		//TODO: find the closest
	}

	return chosenEnt;
}


IsStillValidTarget( ent )
{
	//self --> the player
	if ( ! isDefined( ent ) )
		return false;
	if ( ! target_isTarget( ent ) )
		return false;
	if ( ! self InsideJavelinReticleLocked( ent ) )
		return false;

	return true;
}


SetTargetTooClose( ent )
{
	//self --> the player
	MINIMUM_JAV_DISTANCE = 1000;

	if ( ! isDefined( ent ) )
		return false;
	dist = Distance2D( self.origin, ent.origin );

	//PrintLn( "Jav Distance: ", dist );

	if ( dist < MINIMUM_JAV_DISTANCE )
		self WeaponLockTargetTooClose( true );
	else
		self WeaponLockTargetTooClose( false );
}


SetNoClearance()
{
	//self --> the player
	ORIGINOFFSET_UP = 60;
	ORIGINOFFSET_RIGHT = 10;
	DISTANCE = 400;

	COLOR_PASSED = ( 0, 1, 0 );
	COLOR_FAILED = ( 1, 0, 0 );

	checks = [];
	checks[ 0 ] = ( 0, 0, 80 );
	checks[ 1 ] = ( -40, 0, 120 );
	checks[ 2 ] = ( 40, 0, 120 );
	checks[ 3 ] = ( -40, 0, 40 );
	checks[ 4 ] = ( 40, 0, 40 );

	if ( GetDVar( "missileDebugDraw" ) == "1" )
		debug = true;
	else
		debug = false;

	playerAngles = self GetPlayerAngles();
	forward = AnglesToForward( playerAngles );
	right = AnglesToRight( playerAngles );
	up = AnglesToUp( playerAngles );

	origin = self.origin + ( 0, 0, ORIGINOFFSET_UP ) + right * ORIGINOFFSET_RIGHT;

	obstructed = false;
	for ( idx = 0; idx < checks.size; idx++ )
	{
		endpoint = origin + forward * DISTANCE + up * checks[ idx ][ 2 ] + right * checks[ idx ][ 0 ];
		trace = BulletTrace( origin, endpoint, false, undefined );

		if ( trace[ "fraction" ] < 1 )
		{
			obstructed = true;
			if ( debug )
				line( origin, trace[ "position" ], COLOR_FAILED, 1 );
			else
				break;
		}
		else
		{
			if ( debug )
				line( origin, trace[ "position" ], COLOR_PASSED, 1 );
		}
	}

	self WeaponLockNoClearance( obstructed );
}


JavelinCLULoop()
{
	//self --> the player
	self endon( "death" );
	self endon( "javelin_clu_off" );

	LOCK_LENGTH = 2000;

	for ( ;; )
	{
		wait 0.05;

		//-------------------------
		// Four possible states:
		//      No missile in the tube, so CLU will not search for targets.
		//		CLU has a lock.
		//		CLU is locking on to a target.
		//		CLU is searching for a target to begin locking on to.
		//-------------------------

		clipAmmo = self GetCurrentWeaponClipAmmo();
		if ( !clipAmmo )
		{
			self ClearCLUTarget();
			continue;
		}

		if ( level.javelinLockFinalized )
		{
			if ( ! self IsStillValidTarget( level.javelinTarget ) )
			{
				self ClearCLUTarget();
				continue;
			}
			self SetTargetTooClose( level.javelinTarget );
			self SetNoClearance();
			//print3D( level.javelinTarget.origin, "* LOCKED!", (.2, 1, .3), 1, 5 );
			continue;
		}

		if ( level.javelinLockStarted )
		{
			if ( ! self IsStillValidTarget( level.javelinTarget ) )
			{
				self ClearCLUTarget();
				continue;
			}

			//print3D( level.javelinTarget.origin, "* locking...!", (.2, 1, .3), 1, 5 );

			timePassed = getTime() - level.javelinLockStartTime;
			if ( timePassed < LOCK_LENGTH )
				continue;

			assert( isdefined( level.javelinTarget ) );
			self notify( "stop_lockon_sound" );
			level.javelinLockFinalized = true;
			self WeaponLockFinalize( level.javelinTarget );
			self PlayLocalSound( "javelin_clu_lock" );
			self SetTargetTooClose( level.javelinTarget );
			self SetNoClearance();
			continue;
		}

		bestTarget = self GetBestJavelinTarget();
		if ( !isDefined( bestTarget ) )
			continue;

		level.javelinTarget = bestTarget;
		level.javelinLockStartTime = getTime();
		level.javelinLockStarted = true;
		self WeaponLockStart( bestTarget );
		self thread LoopLocalSeekSound( "javelin_clu_aquiring_lock", 0.6 );
	}
}


JavelinToggleLoop()
{
	//self --> the player
	self endon( "death" );

	for ( ;; )
	{
		while ( ! self PlayerJavelinAds() )
			wait 0.05;
		self thread JavelinCLULoop();

		while ( self PlayerJavelinAds() )
			wait 0.05;
		self notify( "javelin_clu_off" );
		self ClearCLUTarget();
	}
}


TraceConstantTest()
{
	for ( ;; )
	{
		wait 0.05;
		SetNoClearance();
	}
}

init()
{
	precacheShader( "javelin_hud_target_offscreen" );

	array_thread( level.players, :: ClearCLUTarget );

	SetSavedDvar( "vehHudTargetSize", 50 );
	SetSavedDvar( "vehHudTargetScreenEdgeClampBufferLeft", 120 );
	SetSavedDvar( "vehHudTargetScreenEdgeClampBufferRight", 126 );
	SetSavedDvar( "vehHudTargetScreenEdgeClampBufferTop", 139 );
	SetSavedDvar( "vehHudTargetScreenEdgeClampBufferBottom", 134 );

	array_thread( level.players, ::JavelinToggleLoop );
	//array_thread( level.players,::JavelinFiredNotify );
	//thread TraceConstantTest();
}


/*
JavelinFiredNotify()
{
	assert( self.classname == "player" );
	
	while ( true )
	{
		self waittill( "weapon_fired" );

		weap = self getCurrentWeapon();
		IPrintLn( weap );
		if ( weap != "javelin" )
			continue;
	}
}
*/


LoopLocalSeekSound( alias, interval )
{
	//self --> the player
	self endon( "stop_lockon_sound" );

	for ( ;; )
	{
		self PlayLocalSound( alias );
		wait interval;
	}
}
