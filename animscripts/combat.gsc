#include animscripts\Utility;
#include animscripts\SetPoseMovement;
#include animscripts\Combat_utility;
#include animscripts\shared;
#include animscripts\animset;
#include common_scripts\Utility;

#using_animtree( "generic_human" );

sqr512 = 512 * 512;
sqr285 = 285 * 285;
sqr100 = 100 * 100;

pistolPullOutDistSq = sqr512 * 0.64;
pistolPutBackDistSq = sqr512;


main()
{
	if ( isdefined( self.no_ai ) )
		return;

	if ( isdefined( self.onSnowMobile ) )
	{
		animscripts\snowmobile::main();
		return;
	}

	//prof_begin("combat_init");

	self endon( "killanimscript" );

	[[ self.exception[ "exposed" ] ]]();

	animscripts\utility::initialize( "combat" );
	self.a.arrivalType = undefined;

	if ( isdefined( self.node ) && self.node.type == "Ambush" && self nearNode( self.node ) )
		self.ambushNode = self.node;

	/#
	if ( getdvar( "scr_testgrenadethrows" ) == "on" )
		testGrenadeThrowAnimOffsets();
	#/

	self transitionToCombat();
	
	self do_friendly_fire_reaction();
	
	animscripts\stop::specialIdleLoop();

	self setup();

	//prof_end("combat_init");
	
	self exposedCombatMainLoop();

	self notify( "stop_deciding_how_to_shoot" );
}


end_script()
{
	self.ambushNode = undefined;
}


do_friendly_fire_reaction()
{
	if ( self.team != "allies" )
		return;
	
	if ( self IsMoveSuppressed() && self.prevScript == "move" && self.a.pose == "stand" && !isdefined( self.disableFriendlyFireReaction ) )
	{
		if ( isdefined( self.enemy ) && distanceSquared( self.origin, self.enemy.origin ) < squared( 128 ) )
			return;
				
		self animmode( "zonly_physics" );
		self setFlaggedAnimKnobAllRestart( "react", %surprise_stop_v1, %root, 1, 0.2, self.animplaybackrate );
		self animscripts\shared::DoNoteTracks( "react" );
	}
}

transitionToCombat()
{
	if ( isdefined( self.specialIdleAnim ) || isdefined( self.customIdleAnimSet ) )
		return;
		
	if ( isdefined( self.enemy ) && distanceSquared( self.origin, self.enemy.origin ) < 512 * 512 )
		return;
		
	if ( self.prevScript == "stop" && !self isCQBWalking() && self.a.pose == "stand" )
	{
		self animmode( "zonly_physics" );
		self setFlaggedAnimKnobAllRestart( "transition", %casual_stand_idle_trans_out, %root, 1, 0.2, 1.2 * self.animplaybackrate );
		self animscripts\shared::DoNoteTracks( "transition" );
	}
}


/#
testGrenadeThrowAnimOffsets()
{
	model = getGrenadeModel();

	self animmode( "zonly_physics" );
	self OrientMode( "face angle", self.angles[ 1 ] );
	self.keepClaimedNodeIfValid = true;
	foreach ( throwAnim in anim.grenadeThrowAnims )
	{
		forward = anglestoforward( self.angles );
		right   = anglestoright( self.angles );
		startpos = self.origin;

		tag = "TAG_INHAND";

		self setFlaggedAnimKnobAllRestart( "grenadetest", throwAnim, %root, 1, 0, 1 );
		for ( ;; )
		{
			self waittill( "grenadetest", notetrack );
			if ( notetrack == "grenade_left" || notetrack == "grenade_right" )
				self attach( model, tag );
			if ( notetrack == "grenade_throw" || notetrack == "grenade throw" )
				break;
			assert( notetrack != "end" );// we shouldn't hit "end" until after we've hit "grenade_throw"!
			if ( notetrack == "end" )// failsafe
				break;
		}

		pos = self getTagOrigin( tag );
		baseoffset = pos - startpos;

		offset = ( vectordot( baseoffset, forward ), -1 * vectordot( baseoffset, right ), baseoffset[ 2 ] );

		// check our answer =)
		endpos = startpos + forward * offset[ 0 ] - right * offset[ 1 ] + ( 0, 0, 1 ) * offset[ 2 ];
		thread debugLine( startpos, endpos, ( 1, 1, 1 ), 20 );

		println( "addGrenadeThrowAnimOffset( %", throwAnim, ", ", offset, " );" );

		self detach( model, tag );

		wait 1;
	}
	self.keepClaimedNodeIfValid = false;
}
#/

setup_anim_array()
{
	if ( self.a.pose == "stand" )
	{
		self set_animarray_standing();
	}
	else if ( self.a.pose == "crouch" )
	{
		self set_animarray_crouching();
	}
	else if ( self.a.pose == "prone" )
	{
		self set_animarray_prone();
	}
	else
	{
		assertMsg( "Unsupported self.a.pose: " + self.a.pose );
	}
}

// SETUP FUNCTIONS
setup()
{
	if ( usingSidearm() && self isStanceAllowed( "stand" ) )
		transitionTo( "stand" );

	setup_anim_array();
	
	set_aim_and_turn_limits();

	self thread stopShortly();
	self.previousPitchDelta = 0.0;

	self clearAnim( %root, .2 );

	setupAim( .2 );

	self thread aimIdleThread();

	self.a.meleeState = "aim";
	
	self delayStandardMelee();
}

stopShortly()
{
	self endon( "killanimscript" );

	// we want to stop at about the time we blend out of whatever we were just doing.
	wait .2;
	self.a.movement = "stop";
}


set_aim_and_turn_limits()
{
	//We have a slightly greater pitch reach when stand_exposed
	self setDefaultAimLimits();	
	
	if ( self.a.pose == "stand" )
	{
		self.upAimLimit = 60;
		self.downAimLimit = -60;
	}

	self.turnThreshold = self.defaultTurnThreshold;
}


setupExposedCombatLoop()
{
	self thread trackShootEntOrPos();
	self thread ReacquireWhenNecessary();
	self thread animscripts\shoot_behavior::decideWhatAndHowToShoot( "normal" );
	self thread watchShootEntVelocity();

	self resetGiveUpOnEnemyTime();

	if ( isdefined( self.a.magicReloadWhenReachEnemy ) )
	{
		self animscripts\weaponList::RefillClip();
		self.a.magicReloadWhenReachEnemy = undefined;
	}

	// Hesitate to crouch. Crouching too early can look stupid because we'll tend to stand right back up in a lot of cases.
	self.a.dontCrouchTime = gettime() + randomintrange( 500, 1500 );
}


exposedCombatStopUsingRPGCheck( distSqToShootPos )
{
	// too close for RPG or out of ammo
	if ( usingRocketLauncher() && ( distSqToShootPos < sqr512 || self.a.rockets < 1 ) )
	{
		if ( self.a.pose != "stand" && self.a.pose != "crouch" )
			transitionTo( "crouch" );

		if ( self.a.pose == "stand" )
			animscripts\shared::throwDownWeapon( %RPG_stand_throw );
		else
			animscripts\shared::throwDownWeapon( %RPG_crouch_throw );

		self clearAnim( %root, 0.2 );
		
		self endFireAndAnimIdleThread();
		self setup_anim_array();
		self startFireAndAimIdleThread();
		return true;
	}

	return false;
}


exposedCombatCheckStance( distSqToShootPos )
{
	if ( self.a.pose != "stand" && self isStanceAllowed( "stand" ) )
	{
		if ( distSqToShootPos < sqr285 )
		{
			transitionTo( "stand" );
			return true;
		}
		if ( standIfMakesEnemyVisible() )
			return true;
	}

	if ( distSqToShootPos > sqr512 && 
		 self.a.pose != "crouch" && 
		 self isStanceAllowed( "crouch" ) &&
		 !usingSidearm() && 
		 !isdefined( self.heat ) &&
		 gettime() >= self.a.dontCrouchTime && 
		 lengthSquared( self.shootEntVelocity ) < sqr100 )
	{
		if ( !isdefined( self.shootPos ) || sightTracePassed( self.origin + ( 0, 0, 36 ), self.shootPos, false, undefined ) )
		{
			transitionTo( "crouch" );
			return true;
		}
	}

	return false;
}


exposedCombatCheckReloadOrUsePistol( distSqToShootPos )
{
	if ( !usingSidearm() )
	{
		if ( isdefined( self.forceSideArm ) && self.a.pose == "stand" )
		{
			if ( self tryUsingSidearm() )
				return true;
		}

		if ( isSniper() && distSqToShootPos < pistolPullOutDistSq )
		{
			if ( self tryUsingSidearm() )
				return true;
		}
	}

	if ( NeedToReload( 0 ) )
	{
		// TODO: tweak prone exposed reloading to be considered safer
		// requiring self.weapon == self.primaryweapon because we dont want him to drop his shotgun and then, if wantshotgun = false, decide to pick up his rifle when he's done
		if ( !usingSidearm() && cointoss() && !usingRocketLauncher() && usingPrimary() &&
			distSqToShootPos < pistolPullOutDistSq && self isStanceAllowed( "stand" ) )
		{
			// we need to be standing to switch weapons
			if ( self.a.pose != "stand" )
			{
				transitionTo( "stand" );
				return true;
			}

			if ( self tryUsingSidearm() )
				return true;
		}

		if ( self exposedReload( 0 ) )
			return true;
	}

	return false;
}


exposedCombatCheckPutAwayPistol( distSqToShootPos )
{
	if ( usingSidearm() && self.a.pose == "stand" && !isdefined( self.forceSideArm ) )
		if ( ( distSqToShootPos > pistolPutBackDistSq ) || ( self.combatMode == "ambush_nodes_only" && ( !isdefined( self.enemy ) || !self cansee( self.enemy ) ) ) )
			switchToLastWeapon( %pistol_stand_switch );
}

exposedCombatPositionAdjust()
{
	if ( isdefined( self.heat ) && self nearClaimNodeAndAngle() )
	{
		assert( isdefined( self.node ) );
		self safeTeleport( self.nodeoffsetpos, self.node.angles );
	}
}

exposedCombatNeedToTurn()
{
	if ( needToTurn() )
	{
		predictTime = 0.25;
		if ( isdefined( self.shootEnt ) && !isSentient( self.shootEnt ) )
			predictTime = 1.5;
		yawToShootEntOrPos = getPredictedAimYawToShootEntOrPos( predictTime );// yaw to where we think our enemy will be in x seconds
		if ( TurnToFaceRelativeYaw( yawToShootEntOrPos ) )
			return true;
	}
	
	return false;
}

exposedCombatMainLoop()
{
	self endon( "killanimscript" );
	self endon( "combat_restart" );

	self setupExposedCombatLoop();

	self animMode( "zonly_physics", false );
	self OrientMode( "face angle", self.angles[ 1 ] );	// 	// just face current immediately and rely on turning.

	for ( ;; )
	{
		if ( usingRocketLauncher() )
			self.deathFunction = undefined;

		self IsInCombat();// reset our in - combat state

		// it is important for this to be *after* the set_animarray calls!
		if ( WaitForStanceChange() )
			continue;

		tryMelee();
		
		exposedCombatPositionAdjust();

		if ( !isdefined( self.shootPos ) )
		{
			assert( !isdefined( self.shootEnt ) );
			cantSeeEnemyBehavior();
			
			if ( !isdefined( self.enemy ) )
				justWaited = true;
			continue;
		}

		// we can use self.shootPos after this point.
		assert( isdefined( self.shootPos ) );
		self resetGiveUpOnEnemyTime();

		distSqToShootPos = lengthsquared( self.origin - self.shootPos );

		if ( exposedCombatStopUsingRPGCheck( distSqToShootPos ) )
			continue;

		if ( exposedCombatNeedToTurn() )
			continue;

		if ( considerThrowGrenade() )// TODO: make considerThrowGrenade work with shootPos rather than only self.enemy
			continue;

		if ( exposedCombatCheckReloadOrUsePistol( distSqToShootPos ) )
			continue;

		if ( usingRocketLauncher() && self.a.pose != "crouch" && randomFloat( 1 ) > 0.65 )
			self.deathFunction = ::rpgDeath;

		exposedCombatCheckPutAwayPistol( distSqToShootPos );

		if ( exposedCombatCheckStance( distSqToShootPos ) )
			continue;

		if ( aimedAtShootEntOrPos() )
		{
			self shootUntilNeedToTurn();
			self hideFireShowAimIdle();
			continue;
		}

		exposedWait();
	}
}


exposedWait()
{
	if ( !isdefined( self.enemy ) || !self cansee( self.enemy ) )
	{
		self endon( "enemy" );
		self endon( "shoot_behavior_change" );

		wait 0.2 + randomfloat( 0.1 );
		self waittill( "do_slow_things" );
	}
	else
	{
		wait 0.05;
	}
}

standIfMakesEnemyVisible()
{
	assert( self.a.pose != "stand" );
	assert( self isStanceAllowed( "stand" ) );
	if ( isdefined( self.enemy ) && ( !self cansee( self.enemy ) || !self canShootEnemy() ) && sightTracePassed( self.origin + ( 0, 0, 64 ), self.enemy getShootAtPos(), false, undefined ) )
	{
		self.a.dontCrouchTime = gettime() + 3000;
		transitionTo( "stand" );
		return true;
	}
	return false;
}

needToTurn()
{
	// Old way, slower
	/*
	yawToShootEntOrPos = getAimYawToShootEntOrPos(); // yaw to where we think our enemy will be in x seconds
	
	return (abs( yawToShootEntOrPos ) > self.turnThreshold);
	*/
	
	// New way
	point = self.shootPos;
	if ( !isdefined( point ) )
		return false;

	yaw = self.angles[ 1 ] - VectorToYaw( point - self.origin );

	// need to have fudge factor because the gun's origin is different than our origin,
	// the closer our distance, the more we need to fudge. 
	distsq = distanceSquared( self.origin, point );
	if ( distsq < 256 * 256 )
	{
		dist = sqrt( distsq );
		if ( dist > 3 )
			yaw += asin( -3 / dist );
	}
	return AbsAngleClamp180( yaw ) > self.turnThreshold;
}

WaitForStanceChange()
{
	curstance = self.a.pose;

	if ( isdefined( self.a.onback ) )
	{
		wait 0.1;	// something else should correct the stance from "back", or this AI will die on its back, so wait.
		return true;
	}

	if ( curstance == "stand" && isdefined( self.heat ) )
		return false;

	if ( !self isStanceAllowed( curstance ) )
	{
		assert( curstance == "stand" || curstance == "crouch" || curstance == "prone" );

		otherstance = "crouch";
		if ( curstance == "crouch" )
			otherstance = "stand";

		if ( self isStanceAllowed( otherstance ) )
		{
			if ( curstance == "stand" && usingSidearm() )
				return false;

			transitionTo( otherstance );
			return true;
		}
	}
	return false;
}

cantSeeEnemyBehavior()
{
	//prof_begin("combat_cantSeeEnemyBehavior");

	if ( self.a.pose != "stand" && self isStanceAllowed( "stand" ) && standIfMakesEnemyVisible() )
		return true;

	time = gettime();

	self.a.dontCrouchTime = time + 1500;
	
	if ( isdefined( self.group ) && isdefined( self.group.forward ) )
	{
		relYaw = AngleClamp180( self.angles[ 1 ] - vectorToYaw( self.group.forward ) );
		if ( self TurnToFaceRelativeYaw( relYaw ) )
			return true;
	}
	
	if ( isdefined( self.node ) && isdefined( anim.isCombatScriptNode[ self.node.type ] ) )
	{
		relYaw = AngleClamp180( self.angles[ 1 ] - self.node.angles[ 1 ] );
		if ( self TurnToFaceRelativeYaw( relYaw ) )
			return true;
	}
	else if ( (isdefined( self.enemy ) && self seeRecently( self.enemy, 2 )) || time > self.a.scriptStartTime + 1200 )
	{
		relYaw = undefined;
		likelyEnemyDir = self getAnglesToLikelyEnemyPath();
		if ( isdefined( likelyEnemyDir ) )
		{
			relYaw = AngleClamp180( self.angles[ 1 ] - likelyEnemyDir[ 1 ] );
		}
		else if ( isdefined( self.node ) )
		{
			relYaw = AngleClamp180( self.angles[ 1 ] - self.node.angles[ 1 ] );
		}
		else if ( isdefined( self.enemy ) )
		{
			likelyEnemyDir = vectorToAngles( self lastKnownPos( self.enemy ) - self.origin );
			relYaw = AngleClamp180( self.angles[ 1 ] - likelyEnemyDir[ 1 ] );
		}

		if ( isdefined( relYaw ) && self TurnToFaceRelativeYaw( relYaw ) )
			return true;
	}
	// the above likely enemy path is more important than node angles
	else if ( isdefined( self.heat ) && self nearClaimNode() )
	{
		relYaw = AngleClamp180( self.angles[ 1 ] - self.node.angles[ 1 ] );
		if ( self TurnToFaceRelativeYaw( relYaw ) )
			return true;
	}

	if ( considerThrowGrenade() )
		return true;

	givenUpOnEnemy = ( self.a.nextGiveUpOnEnemyTime < time );

	threshold = 0;
	if ( givenUpOnEnemy )
		threshold = 0.99999;

	if ( self exposedReload( threshold ) )
		return true;

	if ( givenUpOnEnemy && usingSidearm() )
	{
		// switch back to main weapon so we can reload it too before another enemy appears
		switchToLastWeapon( %pistol_stand_switch );
		return true;
	}

	/*if ( shouldSwapShotgun() )
	{
		self swapShotgun();
		return true;
	}*/

	cantSeeEnemyWait();
	return true;
}

cantSeeEnemyWait()
{
	self endon( "shoot_behavior_change" );

	wait 0.4 + randomfloat( 0.4 );
	self waittill( "do_slow_things" );
}

resetGiveUpOnEnemyTime()
{
	self.a.nextGiveUpOnEnemyTime = gettime() + randomintrange( 2000, 4000 );
}

TurnToFaceRelativeYaw( faceYaw )
{	
	if ( faceYaw < 0 - self.turnThreshold )
	{
		if ( self.a.pose == "prone" )
		{
			self animscripts\cover_prone::proneTo( "crouch" );
			self set_animarray_crouching();
		}

		self doTurn( "left", 0 - faceYaw );
		self maps\_gameskill::didSomethingOtherThanShooting();
		return true;
	}
	if ( faceYaw > self.turnThreshold )
	{
		if ( self.a.pose == "prone" )
		{
			self animscripts\cover_prone::proneTo( "crouch" );
			self set_animarray_crouching();
		}

		self doTurn( "right", faceYaw );
		self maps\_gameskill::didSomethingOtherThanShooting();
		return true;
	}
	return false;
}

watchShootEntVelocity()
{
	self endon( "killanimscript" );

	self.shootEntVelocity = ( 0, 0, 0 );

	prevshootent = undefined;
	prevpos = self.origin;

	interval = .15;

	while ( 1 )
	{
		if ( isdefined( self.shootEnt ) && isdefined( prevshootent ) && self.shootEnt == prevshootent )
		{
			curpos = self.shootEnt.origin;
			self.shootEntVelocity = vector_multiply( curpos - prevpos, 1 / interval );
			prevpos = curpos;
		}
		else
		{
			if ( isdefined( self.shootEnt ) )
				prevpos = self.shootEnt.origin;
			else
				prevpos = self.origin;
			prevshootent = self.shootEnt;

			self.shootEntVelocity = ( 0, 0, 0 );
		}

		wait interval;
	}
}

shouldSwapShotgun()
{
	return false;// anims aren't set up yet

	/*
	if ( self.a.pose != "stand" )
		return false;
	
	if ( self usingSidearm() )
		return false;
	
	usingShotgun = isShotgun( self.primaryweapon );
	wantShotgun = isdefined( self.wantShotgun ) && self.wantShotgun );
	
	if ( wantShotgun == usingShotgun )
		return false;
	
	if ( !wantShotgun ) // there is no standing shotgun putaway animation
		return false;
	
	return true;*/
}

/*swapShotgun()
{
	assert( self shouldSwapShotgun() );
	assert( isdefined( self.wantShotgun ) );
	
	if ( self.wantShotgun )
	{
		self setFlaggedAnimKnobAllRestart( "weapon_swap", %shotgun_stand_pullout, %body, 1, .2, 1 );
		
		self thread DoNoteTracksWithEndon( "weapon_swap" );
		
		self waittill( "weapon_swap", "" );
		self waittill( "weapon_swap", "end" );
	}
	else
	{
		assert(false); // we don't have a standing shotgun putaway animation
	}
}*/

DoNoteTracksWithEndon( animname )
{
	self endon( "killanimscript" );
	self animscripts\shared::DoNoteTracks( animname );
}

// does turntable movement to face the enemy;
// should be used sparingly because turn animations look better.
faceEnemyImmediately()
{
	self endon( "killanimscript" );
	self notify( "facing_enemy_immediately" );
	self endon( "facing_enemy_immediately" );

	maxYawChange = 5;// degrees per frame

	while ( 1 )
	{
		yawChange = 0 - GetYawToEnemy();

		if ( abs( yawChange ) < 2 )
			break;

		if ( abs( yawChange ) > maxYawChange )
			yawChange = maxYawChange * sign( yawChange );

		self OrientMode( "face angle", self.angles[ 1 ] + yawChange );

		wait .05;
	}

	self OrientMode( "face current" );

	self notify( "can_stop_turning" );
}

isDeltaAllowed( theanim )
{
	delta = getMoveDelta( theanim, 0, 1 );
	endPoint = self localToWorldCoords( delta );

	return self isInGoal( endPoint ) && self mayMoveToPoint( endPoint );
}

isAnimDeltaInGoal( theanim )
{
	delta = getMoveDelta( theanim, 0, 1 );
	endPoint = self localToWorldCoords( delta );

	return self isInGoal( endPoint );
}

doTurn( direction, amount )
{
	knowWhereToShoot = isdefined( self.shootPos );
	rate = 1;
	transTime = 0.2;
	mustFaceEnemy = ( isdefined( self.enemy ) && !isdefined( self.turnToMatchNode ) && self seeRecently( self.enemy, 2 ) && distanceSquared( self.enemy.origin, self.origin ) < sqr512 );
	if ( self.a.scriptStartTime + 500 > gettime() )
	{
		transTime = 0.25;// if it's the first thing we're doing, always blend slowly
		if ( mustFaceEnemy )
			self thread faceEnemyImmediately();
	}
	else if ( mustFaceEnemy )
	{
		urgency = 1.0 - ( distance( self.enemy.origin, self.origin ) / 512 );
		rate = 1 + urgency * 1;

		// ( ensure transTime <= 0.2 / rate )
		if ( rate > 2 )
			transTime = .05;
		else if ( rate > 1.3 )
			transTime = .1;
		else
			transTime = .15;
	}

	angle = 0;
	if ( amount > 157.5 )
		angle = 180;
	else if ( amount > 112.5 )
		angle = 135;
	else if ( amount > 67.5 )
		angle = 90;
	else
		angle = 45;

	animname = "turn_" + direction + "_" + angle;
	turnanim = animarray( animname );

	if ( isdefined( self.turnToMatchNode ) )
		self animmode( "angle deltas", false );
	else if ( isdefined( self.node ) && isdefined( anim.isCombatPathNode[ self.node.type ] ) && distanceSquared( self.origin, self.node.origin ) < 16 * 16 )
		self animmode( "angle deltas", false );
	else if ( isAnimDeltaInGoal( turnanim ) )
		self animMode( "zonly_physics", false );
	else
		self animmode( "angle deltas", false );

	self setAnimKnobAll( %exposed_aiming, %body, 1, transTime );

	if ( !isdefined( self.turnToMatchNode ) )
		self TurningAimingOn( transTime );

	self setAnimLimited( %turn, 1, transTime );

	if ( isdefined( self.heat ) )
		rate = min( 1.0, rate );	// TEMP 1.0, adjust animations first
	else if ( isdefined( self.turnToMatchNode ) )
		rate = max( 1.5, rate );

	self setFlaggedAnimKnobLimitedRestart( "turn", turnanim, 1, transTime, rate );
	self notify( "turning" );

	if ( knowWhereToShoot && !isdefined( self.turnToMatchNode ) && !isdefined( self.heat ) )
		self thread shootWhileTurning();

	doTurnNotetracks();

	self setanimlimited( %turn, 0, .2 );

	if ( !isdefined( self.turnToMatchNode ) )
		self TurningAimingOff( .2 );

	if ( !isdefined( self.turnToMatchNode ) )
	{
		self clearanim( %turn, .2 );
		self setanimknob( %exposed_aiming, 1, .2, 1 );
	}
	else
	{
		self clearanim( %exposed_modern, .3 );
	}

	// if we didn't actually turn, code prevented us from doing so.
	// give up and turntable.
	if ( isdefined( self.turnLastResort ) )
	{
		self.turnLastResort = undefined;
		self thread faceEnemyImmediately();
	}

	self animMode( "zonly_physics", false );

	self notify( "done turning" );
}

doTurnNotetracks()
{
	//self endon( "turning_isnt_working" );
	self endon( "can_stop_turning" );

	//self thread makeSureTurnWorks();
	self animscripts\shared::DoNoteTracks( "turn" );
}

makeSureTurnWorks()
{
	self endon( "killanimscript" );
	self endon( "done turning" );

	startAngle = self.angles[ 1 ];

	wait .3;

	if ( self.angles[ 1 ] == startAngle )
	{
		self notify( "turning_isnt_working" );
		self.turnLastResort = true;
	}
}

TurningAimingOn( transTime )
{
	self setAnimLimited( animarray( "straight_level" ), 0, transTime );
	self setAnim( %add_idle, 0, transTime );
	
	if ( !weapon_pump_action_shotgun() )
		self clearAnim( %add_fire, .2 );	
}

TurningAimingOff( transTime )
{
	self setAnimLimited( animarray( "straight_level" ), 1, transTime );
	self setAnim( %add_idle, 1, transTime );
}

shootWhileTurning()
{
	self endon( "killanimscript" );
	self endon( "done turning" );

	if ( usingRocketLauncher() )
		return;

	shootUntilShootBehaviorChange();

	self clearAnim( %add_fire, .2 );
}

shootUntilNeedToTurn()
{
	self thread watchForNeedToTurnOrTimeout();
	self endon( "need_to_turn" );

	self thread keepTryingToMelee();

	shootUntilShootBehaviorChange();

	self notify( "stop_watching_for_need_to_turn" );
	self notify( "stop_trying_to_melee" );
}

watchForNeedToTurnOrTimeout()
{
	self endon( "killanimscript" );
	self endon( "stop_watching_for_need_to_turn" );

	endtime = gettime() + 4000 + randomint( 2000 );

	while ( 1 )
	{
		if ( gettime() > endtime || needToTurn() )
		{
			self notify( "need_to_turn" );
			break;
		}
		wait .1;
	}
}

considerThrowGrenade()
{
	if ( !myGrenadeCoolDownElapsed() )// early out for efficiency
		return false;

	if ( isdefined( anim.throwGrenadeAtPlayerASAP ) && isAlive( level.player ) )
	{
		if ( tryExposedThrowGrenade( level.player, 200 ) )
			return true;
	}

	if ( isdefined( self.enemy ) && tryExposedThrowGrenade( self.enemy, self.minExposedGrenadeDist ) )
		return true;

	self.a.nextGrenadeTryTime = gettime() + 500;// don't try this too often

	return false;
}

tryExposedThrowGrenade( throwAt, minDist )
{
	threw = false;
	
	if ( isdefined( self.dontEverShoot ) || isdefined( throwAt.dontAttackMe ) )
		return false;

	if ( !isdefined( self.a.array[ "exposed_grenade" ] ) )
		return false;

	throwSpot = throwAt.origin;
	if ( !self canSee( throwAt ) )
	{
		if ( isdefined( self.enemy ) && throwAt == self.enemy && isdefined( self.shootPos ) )
			throwSpot = self.shootPos;
	}

	if ( !self canSee( throwAt ) )
		minDist = 100;
		
	if ( distanceSquared( self.origin, throwSpot ) > minDist * minDist && self.a.pose == self.a.grenadeThrowPose )
	{
		self setActiveGrenadeTimer( throwAt );
	
		if ( !grenadeCoolDownElapsed( throwAt ) )
			return false;

		yaw = GetYawToSpot( throwSpot );
		if ( abs( yaw ) < 60 )
		{
			throwAnims = [];
			
			foreach( throwAnim in ( self.a.array[ "exposed_grenade" ] ) )
			{
				if ( isDeltaAllowed( throwAnim ) )
					throwAnims[ throwAnims.size ] = throwAnim;
			}

			if ( throwAnims.size > 0 )
			{
				self setanim( %exposed_aiming, 0, .1 );
				self animMode( "zonly_physics" );

				setAnimAimWeight( 0, 0 );

				threw = TryGrenade( throwAt, throwAnims[ randomint( throwAnims.size ) ] );

				self setanim( %exposed_aiming, 1, .1 );

				if ( threw )
					setAnimAimWeight( 1, .5 );// ease into aiming
				else
					setAnimAimWeight( 1, 0 );
			}
		}
	}

	if ( threw )
		self maps\_gameskill::didSomethingOtherThanShooting();

	return threw;
}

transitionTo( newPose )
{
	if ( newPose == self.a.pose )
		return;

	// allow using pistol but it might look bad, put a new animation if so
	// assert( !usingSidearm() );

	transAnimName = self.a.pose + "_2_" + newPose;

	if ( !isdefined( self.a.array ) )
		return;
		
	transAnim = self.a.array[ transAnimName ];
	
	if ( !isdefined( transAnim ) )
		return;

	self clearanim( %root, .3 );

	self endFireAndAnimIdleThread();

	if ( newPose == "stand" )
		rate = 2;// gotta stand up fast!
	else
		rate = 1.5;

	if ( !animHasNoteTrack( transAnim, "anim_pose = \"" + newPose + "\"" ) )
	{
		println( "error: " + self.a.pose + "_2_" + newPose + " missing notetrack to set pose!" );
	}

	self setFlaggedAnimKnobAllRestart( "trans", transanim, %body, 1, .2, rate );
	transTime = getAnimLength( transanim ) / rate;
	playTime = transTime - 0.3;
	if ( playTime < 0.2 )
		playTime = 0.2;
	self animscripts\shared::DoNoteTracksForTime( playTime, "trans" );

	self.a.pose = newPose;

	setup_anim_array();

	self startFireAndAimIdleThread();

	self maps\_gameskill::didSomethingOtherThanShooting();
}

keepTryingToMelee()
{
	self endon( "killanimscript" );
	self endon( "stop_trying_to_melee" );
	self endon( "done turning" );
	self endon( "need_to_turn" );
	self endon( "shoot_behavior_change" );

	while ( 1 )
	{
		wait .2 + randomfloat( .3 );

		// this function is running when we're doing something like shooting or reloading.
		// we only want to melee if we would look really stupid by continuing to do what we're trying to get done.
		// only melee if our enemy is very close.
		if ( isdefined( self.enemy ) )
		{
			if ( isPlayer( self.enemy ) )
				checkDistSq = 200 * 200;
			else
				checkDistSq = 100 * 100;
				
			if ( distanceSquared( self.enemy.origin, self.origin ) < checkDistSq )
				tryMelee();
		}
	}
}

tryMelee()
{
	animscripts\melee::Melee_TryExecuting();	// will start a new anim script and stop combat when successful
}

delayStandardMelee()
{
	if ( isdefined( self.noMeleeChargeDelay ) )
		return;

	if ( isPlayer( self.enemy ) )
		return;
		
	// give the AI a chance to charge the player if he forced him out of cover
	//if ( isPlayer( self.enemy ) && isDefined( self.meleeCoverChargeGraceEndTime ) && (self.meleeCoverChargeGraceEndTime > getTime()) )
	//	return;

	animscripts\melee::Melee_Standard_DelayStandardCharge( self.enemy );
}

exposedReload( threshold )
{
	if ( NeedToReload( threshold ) )
	{
		self.a.exposedReloading = true;
		self endFireAndAnimIdleThread();
		
		reloadAnim = undefined;
		if ( isdefined( self.specialReloadAnimFunc ) )
		{
			reloadAnim = self [[ self.specialReloadAnimFunc ]]();
			self.keepClaimedNode = true;
		}
		else
		{
			reloadAnim = animArrayPickRandom( "reload" );

			if ( self.a.pose == "stand" && animArrayAnyExist( "reload_crouchhide" ) && cointoss() )
				reloadAnim = animArrayPickRandom( "reload_crouchhide" );
		}

		self thread keepTryingToMelee();

		self.finishedReload = false;

		// pistol reload looks weird pointing at fixed current angle
		if ( weaponClass( self.weapon ) == "pistol" )
			self orientmode( "face default" );
			
		self doReloadAnim( reloadAnim, threshold > .05 );// this will return at the time when we should start aiming
		self notify( "abort_reload" );// make sure threads that doReloadAnim() started finish
		self orientmode( "face current" );

		if ( self.finishedReload )
			self animscripts\weaponList::RefillClip();

		self clearanim( %reload, .2 );
		self.keepClaimedNode = false;

		self notify( "stop_trying_to_melee" );

		self.a.exposedReloading = false;

		self maps\_gameskill::didSomethingOtherThanShooting();
		
		self startFireAndAimIdleThread();

		return true;
	}

	return false;
}

doReloadAnim( reloadAnim, stopWhenCanShoot )
{
	self endon( "abort_reload" );
	if ( stopWhenCanShoot )
		self thread abortReloadWhenCanShoot();

	animRate = 1;
	
	if ( !self usingSidearm() && !isShotgun( self.weapon ) && isdefined( self.enemy ) && self canSee( self.enemy ) && distanceSquared( self.enemy.origin, self.origin ) < 1024*1024 )
		animRate = 1.2;

	flagName = "reload_" + getUniqueFlagNameIndex();

	self clearanim( %root, 0.2 );
	self setflaggedanimrestart( flagName, reloadAnim, 1, .2, animRate );
	self thread notifyOnStartAim( "abort_reload", flagName );
	self endon( "start_aim" );
	self animscripts\shared::DoNoteTracks( flagName );

	self.finishedReload = true;
}

abortReloadWhenCanShoot()
{
	self endon( "abort_reload" );
	self endon( "killanimscript" );
	while ( 1 )
	{
		if ( isdefined( self.shootEnt ) && self canSee( self.shootEnt ) )
			break;
		wait .05;
	}
	self notify( "abort_reload" );
}

notifyOnStartAim( endonStr, flagName )
{
	self endon( endonStr );
	self waittillmatch( flagName, "start_aim" );
	self.finishedReload = true;
	self notify( "start_aim" );
}

finishNoteTracks( animname )
{
	self endon( "killanimscript" );
	animscripts\shared::DoNoteTracks( animname );
}

drop_turret()
{
	maps\_mgturret::dropTurret();
//	level.theturret = turret;
//	throwVel = 75 + randomInt(50);

//	self animscripts\shared::PutGunInHand("right");
	self animscripts\weaponList::RefillClip();
	self.a.needsToRechamber = 0;
	self notify( "dropped_gun" );
	maps\_mgturret::restoreDefaults();
}

exception_exposed_mg42_portable()
{
	drop_turret();
}


tryUsingSidearm()
{
	// temp fix! we run out of bones on a particular friendly model with a shotgun who tries to pull out his pistol.
	if ( isdefined( self.secondaryWeapon ) && isShotgun( self.secondaryweapon ) )
		return false;

	if ( isdefined( self.no_pistol_switch ) )
		return false;

	// TEMP no pistol crouch pullout yet
	self.a.pose = "stand";
	
	switchToSidearm( %pistol_stand_pullout );

	return true;
}


switchToSidearm( swapAnim )
{
	self endon( "killanimscript" );
	assert( self.sidearm != "" );

	self thread putGunBackInHandOnKillAnimScript();
	self endFireAndAnimIdleThread();

	self.swapAnim = swapAnim;
	self setFlaggedAnimKnobAllRestart( "weapon swap", swapAnim, %body, 1, .2, fasterAnimSpeed() );
	self DoNoteTracksPostCallbackWithEndon( "weapon swap", ::handlePickup, "end_weapon_swap" );
	self clearAnim( self.swapAnim, 0.2 );

	self notify( "facing_enemy_immediately" );
	
	// notify for level script
	self notify( "switched_to_sidearm" );	
	self maps\_gameskill::didSomethingOtherThanShooting();
}

DoNoteTracksPostCallbackWithEndon( flagName, interceptFunction, endonMsg )
{
	self endon( endonMsg );
	self animscripts\shared::DoNoteTracksPostCallback( flagName, interceptFunction );
}

faceEnemyDelay( delay )
{
	self endon( "killanimscript" );
	wait delay;
	self faceEnemyImmediately();
}

handlePickup( notetrack )
{
	if ( notetrack == "pistol_pickup" )
	{
		self clearAnim( animarray( "straight_level" ), 0 );
		self set_animarray_standing();

		self thread faceEnemyDelay( 0.25 );
	}
	else if ( notetrack == "start_aim" )
	{
		startFireAndAimIdleThread();
		
		if ( self needToTurn() )
			self notify( "end_weapon_swap" );
	}
}


// %pistol_stand_switch
switchToLastWeapon( swapAnim, cleanUp )
{
	self endon( "killanimscript" );
	
	assertex( self.lastWeapon != getAISidearmWeapon() || self.lastWeapon == "none", "AI \"" + self.classname + "\" using sidearm trying to switch back to sidearm. lastweapon = \"" + self.lastWeapon + "\", primaryweapon = \"" + self.primaryweapon + "\"" );
	assertex( self.lastWeapon == getAIPrimaryWeapon() || self.lastWeapon == getAISecondaryWeapon() );
	
	self endFireAndAnimIdleThread();

	self.swapAnim = swapAnim;
	self setFlaggedAnimKnobAllRestart( "weapon swap", swapAnim, %body, 1, .1, 1 );
	
	if ( isdefined( cleanUp ) )
		self DoNoteTracksPostCallbackWithEndon( "weapon swap", ::handleCleanUpPutaway, "end_weapon_swap" );
	else
		self DoNoteTracksPostCallbackWithEndon( "weapon swap", ::handlePutaway, "end_weapon_swap" );
	self clearanim( self.swapAnim, 0.2 );

	self notify( "switched_to_lastweapon" );
	self maps\_gameskill::didSomethingOtherThanShooting();
}

handlePutaway( notetrack )
{
	if ( notetrack == "pistol_putaway" )
	{
		self clearAnim( animarray( "straight_level" ), 0 );
		self set_animarray_standing();
		
		self thread putGunBackInHandOnKillAnimScript();
	}
	else if ( notetrack == "start_aim" )
	{
		startFireAndAimIdleThread();
		
		if ( self needToTurn() )
			self notify( "end_weapon_swap" );
	}
}

handleCleanUpPutaway( notetrack )
{
	if ( notetrack == "pistol_putaway" )
		self thread putGunBackInHandOnKillAnimScript();
	else if ( issubstr( notetrack, "anim_gunhand" ) )
		self notify( "end_weapon_swap" );
}


rpgDeath()
{
	if ( !usingRocketLauncher() || self.bulletsInClip == 0 )
		return false;
		
	if ( randomFloat( 1 ) > 0.5 )
		self SetFlaggedAnimKnobAll( "deathanim", %RPG_stand_death, %root, 1, .05, 1 );
	else
		self SetFlaggedAnimKnobAll( "deathanim", %RPG_stand_death_stagger, %root, 1, .05, 1 );

	self animscripts\shared::DoNoteTracks( "deathanim" );
	self animscripts\shared::DropAllAIWeapons();
	return;
}

ReacquireWhenNecessary()
{
	self endon( "killanimscript" );	

	self.a.exposedReloading = false;

	while ( 1 )
	{
		wait .2;

		if ( isdefined( self.enemy ) && !self seeRecently( self.enemy, 2 ) )
		{
			if ( self.combatMode == "ambush" || self.combatMode == "ambush_nodes_only" )
				continue;				
		}

		TryExposedReacquire();
	}
}

// this function is meant to be called many times in succession.
// each time it tries another option, until eventually it finds something it can do.
TryExposedReacquire()
{
	if ( self.fixedNode )
		return;

	//prof_begin( "TryExposedReacquire" );
	if ( !isdefined( self.enemy ) )
	{
		self.reacquire_state = 0;
		return;
	}

	// don't do reacquire move when temporarily blocked by teammate
	if ( gettime() < self.teamMoveWaitTime )
	{
		self.reacquire_state = 0;
		return;
	}
	
	if ( isdefined( self.prevEnemy ) && self.prevEnemy != self.enemy )
	{
		self.reacquire_state = 0;
		self.prevEnemy = undefined;
		return;
	}
	self.prevEnemy = self.enemy;

	if ( self canSee( self.enemy ) && self canShootEnemy() )
	{
		self.reacquire_state = 0;
		return;
	}
	
	if ( isdefined( self.finishedReload ) && !self.finishedReload )
	{
		self.reacquire_state = 0;
		return;
	}
	
	// don't do reacquire unless facing enemy 
	dirToEnemy = vectornormalize( self.enemy.origin - self.origin );
	forward = anglesToForward( self.angles );
	
	if ( vectordot( dirToEnemy, forward ) < 0.5 )	// (0.5 = cos60)
	{
		self.reacquire_state = 0;
		return;
	}	

	if ( self.a.exposedReloading && NeedToReload( .25 ) && self.enemy.health > self.enemy.maxhealth * .5 )
	{
		self.reacquire_state = 0;
		return;
	}
	
	if ( shouldHelpAdvancingTeammate() && self.reacquire_state < 3 )
		self.reacquire_state = 3;

	switch( self.reacquire_state )
	{
	case 0:
		if ( self ReacquireStep( 32 ) )
			return;
		break;

	case 1:
		if ( self ReacquireStep( 64 ) )
		{
			self.reacquire_state = 0;
			return;
		}
		break;

	case 2:
		if ( self ReacquireStep( 96 ) )
		{
			self.reacquire_state = 0;
			return;
		}
		break;

	case 3:
		if ( tryRunningToEnemy( false ) )
		{
			self.reacquire_state = 0;
			return;
		}
		break;

	case 4:
		if ( !( self canSee( self.enemy ) ) || !( self canShootEnemy() ) )
			self FlagEnemyUnattackable();
		break;

	default:
		// don't do anything for a while
		if ( self.reacquire_state > 15 )
		{
			self.reacquire_state = 0;
			return;
		}
		break;
	}

	self.reacquire_state++;
}

