#include maps\_utility;
#include common_scripts\utility;

init()
{
	precacherumble( "stinger_lock_rumble" );

	foreach ( player in level.players )
		player ClearIRTarget();

	foreach ( player in level.players )
	{
		player thread StingerFiredNotify();
		player thread StingerToggleLoop();
	}
}

ClearIRTarget()
{
	if ( !isdefined( self.stinger ) )
		self.stinger = spawnStruct();
	self.stinger.stingerLockStartTime = 0;
	self.stinger.stingerLockStarted = false;
	self.stinger.stingerLockFinalized = false;
	self.stinger.stingerTarget = undefined;

	self notify( "stinger_irt_cleartarget" );
	self notify( "stop_lockon_sound" );
	self notify( "stop_locked_sound" );
	self.stinger.stingerlocksound = undefined;
	self StopRumble( "stinger_lock_rumble" );

	self WeaponLockFree();
	self WeaponLockTargetTooClose( false );
	self WeaponLockNoClearance( false );

	self StopLocalSound( "javelin_clu_lock" );
	self StopLocalSound( "javelin_clu_aquiring_lock" );
}

StingerFiredNotify()
{
	assert( self.classname == "player" );

	while ( true )
	{
		self waittill( "weapon_fired" );

		weap = self getCurrentWeapon();
		if ( weap != "stinger" )
			continue;

		self notify( "stinger_fired" );
	}
}


StingerToggleLoop()
{
	assert( self.classname == "player" );
	self endon( "death" );

	for ( ;; )
	{
		while ( !self PlayerStingerAds() )
			wait 0.05;

		self thread StingerIRTLoop();

		while ( self PlayerStingerAds() )
			wait 0.05;
		self notify( "stinger_IRT_off" );
		self ClearIRTarget();
	}
}

StingerIRTLoop()
{
	assert( self.classname == "player" );
	self endon( "death" );
	self endon( "stinger_IRT_off" );

	LOCK_LENGTH = 1150;

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

		if ( self.stinger.stingerLockFinalized )
		{
			if ( !self IsStillValidTarget( self.stinger.stingerTarget ) )
			{
				self ClearIRTarget();
				continue;
			}

			self thread LoopLocalLockSound( "javelin_clu_lock", 0.75 );

			self SetTargetTooClose( self.stinger.stingerTarget );
			continue;
		}

		if ( self.stinger.stingerLockStarted )
		{
			if ( !self IsStillValidTarget( self.stinger.stingerTarget ) )
			{
				self ClearIRTarget();
				continue;
			}

			timePassed = getTime() - self.stinger.stingerLockStartTime;
			if ( timePassed < LOCK_LENGTH )
				continue;

			assert( isdefined( self.stinger.stingerTarget ) );
			self notify( "stop_lockon_sound" );
			self.stinger.stingerLockFinalized = true;
			self WeaponLockFinalize( self.stinger.stingerTarget );
			self SetTargetTooClose( self.stinger.stingerTarget );

			continue;
		}

		bestTarget = self GetBestStingerTarget();
		if ( !isDefined( bestTarget ) )
			continue;

		self.stinger.stingerTarget = bestTarget;
		self.stinger.stingerLockStartTime = getTime();
		self.stinger.stingerLockStarted = true;

		self thread LoopLocalSeekSound( "javelin_clu_aquiring_lock", 0.6 );
	}
}

GetBestStingerTarget()
{
	targetsAll = target_getArray();
	targetsValid = [];

	for ( idx = 0; idx < targetsAll.size; idx++ )
	{
		if ( self InsideStingerReticleNoLock( targetsAll[ idx ] ) )
			targetsValid[ targetsValid.size ] = targetsAll[ idx ];
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

InsideStingerReticleNoLock( target )
{
	return target_isincircle( target, self, 65, 60 );
}

InsideStingerReticleLocked( target )
{
	return target_isincircle( target, self, 65, 75 );
}

IsStillValidTarget( ent )
{
	assert( self.classname == "player" );

	if ( !isDefined( ent ) )
		return false;
	if ( !target_isTarget( ent ) )
		return false;
	if ( !self InsideStingerReticleLocked( ent ) )
		return false;

	return true;
}

PlayerStingerAds()
{
	assert( self.classname == "player" );

	weap = self getCurrentWeapon();
	if ( weap != "stinger" )
		return false;

	if ( self playerads() == 1.0 )
		return true;

	return false;
}


SetTargetTooClose( ent )
{
	assert( self.classname == "player" );

	MINIMUM_STI_DISTANCE = 1000;

	if ( ! isDefined( ent ) )
		return false;
	dist = Distance2D( self.origin, ent.origin );

	//PrintLn( "Jav Distance: ", dist );

	if ( dist < MINIMUM_STI_DISTANCE )
	{
		self.stinger.targettoclose = true;
		self WeaponLockTargetTooClose( true );
	}
	else
	{
		self.stinger.targettoclose = false;
		self WeaponLockTargetTooClose( false );
	}

}

LoopLocalSeekSound( alias, interval )
{
	assert( self.classname == "player" );

	self endon( "stop_lockon_sound" );

	for ( ;; )
	{
		self playLocalSound( alias );
		self PlayRumbleOnEntity( "stinger_lock_rumble" );

		wait interval;
	}
}

LoopLocalLockSound( alias, interval )
{
	assert( self.classname == "player" );

	self endon( "stop_locked_sound" );

	if ( isdefined( self.stinger.stingerlocksound ) )
		return;

	self.stinger.stingerlocksound = true;
	for ( ;; )
	{
		self playLocalSound( alias );
		self PlayRumbleOnEntity( "stinger_lock_rumble" );
		wait interval / 3;

		self PlayRumbleOnEntity( "stinger_lock_rumble" );
		wait interval / 3;

		self PlayRumbleOnEntity( "stinger_lock_rumble" );
		wait interval / 3;

		self StopRumble( "stinger_lock_rumble" );
	}
	self.stinger.stingerlocksound = undefined;
}