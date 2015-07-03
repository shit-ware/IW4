#include common_scripts\utility;
#include animscripts\combat_utility;
#include animscripts\utility;
#include animscripts\shared;

// Ideally, this will be the only thread *anywhere* that decides what/where to shoot at
// and how to shoot at it.

// This thread keeps three variables updated, and notifies "shoot_behavior_change" when any of them have changed.
// They are:
//  shootEnt - an entity. aim/shoot at this if it's defined.
//  shootPos - a vector. aim/shoot towards this if shootEnt isn't defined. if not defined, stop shooting entirely and return to cover if possible.
//		Whenever shootEnt is defined, shootPos will be defined as its getShootAtPos().
//  shootStyle - how to shoot.
//    "full" (unload on the target),
//    "burst" (occasional groups of shots),
//    "semi" (occasianal single shots),
//    "single" (occasional single shots),
//    "none" (don't shoot, just aim).
// This thread will also notify "return_to_cover" and set self.shouldReturnToCover = true if it's a good idea to do so.
// Notify "stop_deciding_how_to_shoot" to end this thread if no longer trying to shoot.

decideWhatAndHowToShoot( objective )
{
	self endon( "killanimscript" );
	self notify( "stop_deciding_how_to_shoot" );// just in case...
	self endon( "stop_deciding_how_to_shoot" );
	self endon( "death" );

	assert( isdefined( objective ) );// just use "normal" if you don't know what to use

	maps\_gameskill::resetMissTime();
	self.shootObjective = objective;
	// self.shootObjective is always "normal", "suppress", or "ambush"

	self.shootEnt = undefined;
	self.shootPos = undefined;
	self.shootStyle = "none";
	self.fastBurst = false;
	self.shouldReturnToCover = undefined;

	if ( !isdefined( self.changingCoverPos ) )
		self.changingCoverPos = false;

	atCover = isDefined( self.coverNode ) && self.coverNode.type != "Cover Prone" && self.coverNode.type != "Conceal Prone";

	if ( atCover )
	{
		// it's not safe to do some things until the next frame,
		// such as canSuppressEnemy(), which may change the state of
		// self.goodShootPos, which will screw up cover_behavior::main
		// when this is called but then stopped immediately.
		wait .05;
	}

	prevShootEnt = self.shootEnt;
	prevShootPos = self.shootPos;
	prevShootStyle = self.shootStyle;

	if ( !isdefined( self.has_no_ir ) )
	{
		self.a.laserOn = true;
		self animscripts\shared::updateLaserStatus();
	}

	if ( self isSniper() )
		self resetSniperAim();

	// only watch for incoming fire if it will be beneficial for us to return to cover when shot at.
	if ( atCover && ( !self.a.atConcealmentNode || !self canSeeEnemy() ) )
		thread watchForIncomingFire();
	thread runOnShootBehaviorEnd();

	self.ambushEndTime = undefined;

	prof_begin( "decideWhatAndHowToShoot" );

	while ( 1 )
	{
		if ( isdefined( self.shootPosOverride ) )
		{
			if ( !isdefined( self.enemy ) )
			{
				self.shootPos = self.shootPosOverride;
				self.shootPosOverride = undefined;
				WaitABit();
			}
			else
			{
				self.shootPosOverride = undefined;
			}
		}

		assert( self.shootObjective == "normal" || self.shootObjective == "suppress" || self.shootObjective == "ambush" );
		assert( !isdefined( self.shootEnt ) || isdefined( self.shootPos ) );// shootPos must be shootEnt's shootAtPos if shootEnt is defined, for convenience elsewhere
		
		result = undefined;
		if ( self.weapon == "none" )
			noGunShoot();
		else if ( usingRocketLauncher() )
			result = rpgShoot();
		else if ( usingSidearm() )
			result = pistolShoot();
		else
			result = rifleShoot();
		
		if ( isDefined( self.a.specialShootBehavior ) )
			[[self.a.specialShootBehavior]]();

		
		if ( checkChanged( prevShootEnt, self.shootEnt ) || ( !isdefined( self.shootEnt ) && checkChanged( prevShootPos, self.shootPos ) ) || checkChanged( prevShootStyle, self.shootStyle ) )
			self notify( "shoot_behavior_change" );
		prevShootEnt = self.shootEnt;
		prevShootPos = self.shootPos;
		prevShootStyle = self.shootStyle;


		// (trying to prevent many AI from doing lots of work on the same frame)
		if ( !isdefined( result ) )
			WaitABit();
	}

	prof_end( "decideWhatAndHowToShoot" );
}

WaitABit()
{
	self endon( "enemy" );
	self endon( "done_changing_cover_pos" );
	self endon( "weapon_position_change" );
	self endon( "enemy_visible" );

	if ( isdefined( self.shootEnt ) )
	{
		self.shootEnt endon( "death" );

		self endon( "do_slow_things" );

		// (want to keep self.shootPos up to date)
		wait .05;
		while ( isdefined( self.shootEnt ) )
		{
			self.shootPos = self.shootEnt getShootAtPos();
			wait .05;
		}
	}
	else
	{
		self waittill( "do_slow_things" );
	}
}

noGunShoot()
{
	 /#
	println( "^1Warning: AI at " + self.origin + ", entnum " + self getEntNum() + ", export " + self.export + " trying to shoot but has no gun" );
	#/
	self.shootEnt = undefined;
	self.shootPos = undefined;
	self.shootStyle = "none";
	self.shootObjective = "normal";
}

shouldSuppress()
{
	return !self isSniper() && !isShotgun( self.weapon );
}

shouldShootEnemyEnt()
{
	assert( isDefined ( self ) );
	
	if ( !self canSeeEnemy() )
		return false;

	// When not in cover, check if we can shoot at our current enemy as well
	if ( !isDefined( self.coverNode ) && !self canShootEnemy() )
		return false;

	return true;
}


rifleShootObjectiveNormal()
{
	if ( !shouldShootEnemyEnt() )
	{
		// enemy disappeared!
		if ( self isSniper() )
			self resetSniperAim();

		if ( self.doingAmbush )
		{
			self.shootObjective = "ambush";
			return "retry";
		}

		if ( !isdefined( self.enemy ) )
		{
			haveNothingToShoot();
		}
		else
		{
			markEnemyPosInvisible();

			if ( ( self.provideCoveringFire || randomint( 5 ) > 0 ) && shouldSuppress() )
				self.shootObjective = "suppress";
			else
				self.shootObjective = "ambush";
			return "retry";
		}
	}
	else
	{
		setShootEntToEnemy();
		self setShootStyleForVisibleEnemy();
	}
}


rifleShootObjectiveSuppress( enemySuppressable )
{
	if ( !enemySuppressable )
	{
		haveNothingToShoot();
	}
	else
	{
		self.shootEnt = undefined;
		self.shootPos = getEnemySightPos();

		self setShootStyleForSuppression();		
	}
}

rifleShootObjectiveAmbush( enemySuppressable )
{
	assert( self.shootObjective == "ambush" );

	self.shootStyle = "none";
	self.shootEnt = undefined;
	
	if ( !enemySuppressable )
	{
		getAmbushShootPos();

		if ( shouldStopAmbushing() )
		{
			self.ambushEndTime = undefined;
			self notify( "return_to_cover" );
			self.shouldReturnToCover = true;
		}	
	}
	else
	{
		self.shootPos = getEnemySightPos();

		if ( self shouldStopAmbushing() )
		{
			self.ambushEndTime = undefined;

			if ( shouldSuppress() )
				self.shootObjective = "suppress";
				
			if ( randomint( 3 ) == 0 )
			{
				self notify( "return_to_cover" );
				self.shouldReturnToCover = true;
			}
			return "retry";
		}
	}
}


getAmbushShootPos()
{
	if ( isdefined( self.enemy ) && self cansee( self.enemy ) ) 
	{
		setShootEntToEnemy();
		return;
	}
	
	likelyEnemyDir = self getAnglesToLikelyEnemyPath();
	
	if ( !isdefined( likelyEnemyDir ) )
	{
		if ( isDefined( self.coverNode ) )
			likelyEnemyDir = self.coverNode.angles;
		else if ( isdefined( self.ambushNode ) )
			likelyEnemyDir = self.ambushNode.angles;
		else if ( isdefined( self.enemy ) )
			likelyEnemyDir = vectorToAngles( self lastKnownPos( self.enemy ) - self.origin );
		else 
			likelyEnemyDir = self.angles;
	}

	dist = 1024;
	if ( isdefined( self.enemy ) )
		dist = distance( self.origin, self.enemy.origin );

	newShootPos = self getEye() + anglesToForward( likelyEnemyDir ) * dist;	
	
	if ( !isdefined( self.shootPos ) || distanceSquared( newShootPos, self.shootPos ) > 5 * 5 )// avoid frequent "shoot_behavior_change" notifies
		self.shootPos = newShootPos;
}


rifleShoot()
{
	if ( self.shootObjective == "normal" )
	{
		rifleShootObjectiveNormal();
	}
	else
	{
		if ( shouldShootEnemyEnt() )// later, maybe we can be more realistic than just shooting at the enemy the instant he becomes visible
		{
			self.shootObjective = "normal";
			self.ambushEndTime = undefined;
			return "retry";
		}

		markEnemyPosInvisible();

		if ( self isSniper() )
			self resetSniperAim();
			
		enemySuppressable = canSuppressEnemy();
			
		if ( self.shootObjective == "suppress" || ( self.team == "allies" && !isdefined( self.enemy ) && !enemySuppressable ) )
			rifleShootObjectiveSuppress( enemySuppressable );
		else
			rifleShootObjectiveAmbush( enemySuppressable );
	}
}

shouldStopAmbushing()
{
	if ( !isdefined( self.ambushEndTime ) )
	{
		if ( self isBadGuy() )
			self.ambushEndTime = gettime() + randomintrange( 10000, 60000 );
		else
			self.ambushEndTime = gettime() + randomintrange( 4000, 10000 );
	}
	return self.ambushEndTime < gettime();
}

rpgShoot()
{
	if ( !shouldShootEnemyEnt() )
	{
		markEnemyPosInvisible();

		haveNothingToShoot();
		return;
	}

	setShootEntToEnemy();
	self.shootStyle = "single";

	distSqToShootPos = lengthsquared( self.origin - self.shootPos );
	// too close for RPG
	if ( distSqToShootPos < squared( 512 ) )
	{
		self notify( "return_to_cover" );
		self.shouldReturnToCover = true;
		return;
	}
}


pistolShoot()
{
	if ( self.shootObjective == "normal" )
	{
		if ( !shouldShootEnemyEnt() )
		{
			// enemy disappeared!
			if ( !isdefined( self.enemy ) )
			{
				haveNothingToShoot();
				return;
			}
			else
			{
				markEnemyPosInvisible();

				self.shootObjective = "ambush";
				return "retry";
			}
		}
		else
		{
			setShootEntToEnemy();
			self.shootStyle = "single";
		}
	}
	else
	{
		if ( shouldShootEnemyEnt() )// later, maybe we can be more realistic than just shooting at the enemy the instant he becomes visible
		{
			self.shootObjective = "normal";
			self.ambushEndTime = undefined;
			return "retry";
		}

		markEnemyPosInvisible();

		self.shootEnt = undefined;
		self.shootStyle = "none";
		self.shootPos = getEnemySightPos();

		// stop ambushing after a while
		if ( !isdefined( self.ambushEndTime ) )
			self.ambushEndTime = gettime() + randomintrange( 4000, 8000 );

		if ( self.ambushEndTime < gettime() )
		{
			self.shootObjective = "normal";
			self.ambushEndTime = undefined;
			return "retry";
		}
	}
}

markEnemyPosInvisible()
{
	if ( isdefined( self.enemy ) && !self.changingCoverPos && self.script != "combat" )
	{
		// make sure they're not just hiding
		if ( isAI( self.enemy ) && isdefined( self.enemy.script ) && ( self.enemy.script == "cover_stand" || self.enemy.script == "cover_crouch" ) )
		{
			if ( isdefined( self.enemy.a.coverMode ) && self.enemy.a.coverMode == "hide" )
				return;
		}

		self.couldntSeeEnemyPos = self.enemy.origin;
	}
}

watchForIncomingFire()
{
	self endon( "killanimscript" );
	self endon( "stop_deciding_how_to_shoot" );

	while ( 1 )
	{
		self waittill( "suppression" );

		if ( self.suppressionMeter > self.suppressionThreshold )
		{
			if ( self readyToReturnToCover() )
			{
				self notify( "return_to_cover" );
				self.shouldReturnToCover = true;
			}
		}
	}
}

readyToReturnToCover()
{
	if ( self.changingCoverPos )
		return false;

	assert( isdefined( self.coverPosEstablishedTime ) );

	if ( !isdefined( self.enemy ) || !self canSee( self.enemy ) )
		return true;

	if ( gettime() < self.coverPosEstablishedTime + 800 )
	{
		// don't return to cover until we had time to fire a couple shots;
		// better to look daring than indecisive
		return false;
	}

	if ( isPlayer( self.enemy ) && self.enemy.health < self.enemy.maxHealth * .5 )
	{
		// give ourselves some time to take them down
		if ( gettime() < self.coverPosEstablishedTime + 3000 )
			return false;
	}

	return true;
}

runOnShootBehaviorEnd()
{
	self endon( "death" );

	self waittill_any( "killanimscript", "stop_deciding_how_to_shoot"/*, "return_to_cover"*/ );

	self.a.laserOn = false;
	self animscripts\shared::updateLaserStatus();
}

checkChanged( prevval, newval )
{
	if ( isdefined( prevval ) != isdefined( newval ) )
		return true;
	if ( !isdefined( newval ) )
	{
		assert( !isdefined( prevval ) );
		return false;
	}
	return prevval != newval;
}

setShootEntToEnemy()
{
	self.shootEnt = self.enemy;
	self.shootPos = self.shootEnt getShootAtPos();
}

haveNothingToShoot()
{
	self.shootEnt = undefined;
	self.shootPos = undefined;
	self.shootStyle = "none";

	if ( self.doingAmbush )
		self.shootObjective = "ambush";

	if ( !self.changingCoverPos )
	{
		self notify( "return_to_cover" );
		self.shouldReturnToCover = true;
	}
}

shouldBeAJerk()
{
	return level.gameskill == 3 && isPlayer( self.enemy );// && self shouldDoSemiForVariety();
}

fullAutoRangeSq = 250 * 250;
burstRangeSq = 900 * 900;
singleShotRangeSq = 1600 * 1600;

setShootStyleForVisibleEnemy()
{
	assert( isdefined( self.shootPos ) );
	assert( isdefined( self.shootEnt ) );

	if ( isdefined( self.shootEnt.enemy ) && isdefined( self.shootEnt.enemy.syncedMeleeTarget ) )
		return setShootStyle( "single", false );

	if ( self isSniper() )
		return setShootStyle( "single", false );
	
	if ( isShotgun( self.weapon ) )
	{
		if ( weapon_pump_action_shotgun() )
			return setShootStyle( "single", false );
		else
			return setShootStyle( "semi", false );
	}

	if ( weaponBurstCount( self.weapon ) > 0 )
		return setShootStyle( "burst", false );

	distanceSq = distanceSquared( self getShootAtPos(), self.shootPos );

	isMG = weaponClass( self.weapon ) == "mg";

	if ( self.provideCoveringFire && isMG )
		return setShootStyle( "full", false );

	if ( distanceSq < fullAutoRangeSq )
	{
		if ( isdefined( self.shootEnt ) && isdefined( self.shootEnt.magic_bullet_shield ) )
			return setShootStyle( "single", false );
		else
			return setShootStyle( "full", false );
	}
	else if ( distanceSq < burstRangeSq || shouldBeAJerk() )
	{
		if ( weaponIsSemiAuto( self.weapon ) || shouldDoSemiForVariety() )
			return setShootStyle( "semi", true );
		else
			return setShootStyle( "burst", true );
	}
	else if ( self.provideCoveringFire || isMG || distanceSq < singleShotRangeSq )
	{
		if ( shouldDoSemiForVariety() )
			return setShootStyle( "semi", false );
		else
			return setShootStyle( "burst", false );
	}

	return setShootStyle( "single", false );
}

setShootStyleForSuppression()
{
	assert( isdefined( self.shootPos ) );

	distanceSq = distanceSquared( self getShootAtPos(), self.shootPos );

	assert( !self isSniper() );// snipers shouldn't be suppressing!
	assert( !isShotgun( self.weapon ) );// shotgun users shouldn't be suppressing!

	if ( weaponIsSemiAuto( self.weapon ) )
	{
		if ( distanceSq < singleShotRangeSq )
			return setShootStyle( "semi", false );
		return setShootStyle( "single", false );
	}

	if ( weaponClass( self.weapon ) == "mg" )
		return setShootStyle( "full", false );

	if ( self.provideCoveringFire || distanceSq < singleShotRangeSq )
	{
		if ( shouldDoSemiForVariety() )
			return setShootStyle( "semi", false );
		else
			return setShootStyle( "burst", false );
	}

	return setShootStyle( "single", false );
}

setShootStyle( style, fastBurst )
{
	self.shootStyle = style;
	self.fastBurst = fastBurst;
}

shouldDoSemiForVariety()
{
	if ( weaponClass( self.weapon ) != "rifle" )
		return false;

	if ( self.team != "allies" )
		return false;

	// true randomness isn't safe, because that will cause frequent shoot_behavior_change notifies.
	// fake the randomness in a way that won't change frequently.
	changeFrequency = safemod( int( self.origin[ 1 ] ), 10000 ) + 2000;
	fakeTimeValue = int( self.origin[ 0 ] ) + gettime();

	return fakeTimeValue %( 2 * changeFrequency ) > changeFrequency;
}

resetSniperAim()
{
	assert( self isSniper() );
	self.sniperShotCount = 0;
	self.sniperHitCount = 0;
	
	thread sniper_glint_behavior();
}

sniper_glint_behavior()
{
	self endon( "killanimscript" );
	self endon( "enemy" );
	self endon( "return_to_cover" );
	self notify( "new_glint_thread" );
	self endon( "new_glint_thread" );
	
	assertex( self isSniper(), "Not a sniper!" );
	if ( !isdefined( level._effect[ "sniper_glint" ] ) )
	{
		println( "^3Warning, sniper glint is not setup for sniper with classname " + self.classname );
		return;
	}
	
	if ( !isAlive( self.enemy ) )
		return;
	
	//if ( !isPlayer( self.enemy ) )
	//	return;
		
	fx = getfx( "sniper_glint" );
	
	wait 0.2;
		
	for ( ;; )
	{
		if ( self.weapon == self.primaryweapon && player_sees_my_scope() )
		{
			if ( distanceSquared( self.origin, self.enemy.origin ) > 256 * 256 )
				PlayFXOnTag( fx, self, "tag_flash" );
				
			timer = randomfloatrange( 3, 5 );
			wait( timer );
		}
		wait( 0.2 );
	}
}

