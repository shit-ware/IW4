#include maps\_utility;
#include animscripts\Combat_utility;
#include animscripts\utility;
#include common_scripts\Utility;

#using_animtree( "generic_human" );

corner_think( direction, nodeAngleOffset )
{
	self endon( "killanimscript" );

	self.animArrayFuncs[ "exposed" ][ "stand" ] = animscripts\corner::set_standing_animarray_aiming;
	self.animArrayFuncs[ "exposed" ][ "crouch" ] = animscripts\corner::set_crouching_animarray_aiming;

	self.coverNode = self.node;
	self.cornerDirection = direction;
	self.a.cornerMode = "unknown";

	self.a.aimIdleThread = undefined;

	animscripts\cover_behavior::turnToMatchNodeDirection( nodeAngleOffset );

	set_corner_anim_array();
	
	self.isshooting = false;
	self.tracking = false;

	self.cornerAiming = false;

	animscripts\shared::setAnimAimWeight( 0 );

	self.haveGoneToCover = false;

	behaviorCallbacks = spawnstruct();

	if ( !self.fixedNode )
		behaviorCallbacks.moveToNearByCover	 = animscripts\cover_behavior::moveToNearbyCover;
	
	behaviorCallbacks.mainLoopStart			 = ::mainLoopStart;
	behaviorCallbacks.reload				 = ::cornerReload;
	behaviorCallbacks.leaveCoverAndShoot	 = ::stepOutAndShootEnemy;
	behaviorCallbacks.look					 = ::lookForEnemy;
	behaviorCallbacks.fastlook				 = ::fastlook;
	behaviorCallbacks.idle					 = ::idle;
	behaviorCallbacks.grenade				 = ::tryThrowingGrenade;
	behaviorCallbacks.grenadehidden			 = ::tryThrowingGrenadeStayHidden;
	behaviorCallbacks.blindfire				 = ::blindfire;

	animscripts\cover_behavior::main( behaviorCallbacks );
}

end_script_corner()
{
	self.stepOutYaw = undefined;
	self.a.leanAim = undefined;
}

set_corner_anim_array()
{
	if ( self.a.pose == "crouch" )
	{
		set_anim_array( "crouch" );
	}
	else if ( self.a.pose == "stand" )
	{
		set_anim_array( "stand" );
	}
	else
	{
		assert( self.a.pose == "prone" );
		self ExitProneWrapper( 1 );
		self.a.pose = "crouch";
		self set_anim_array( "crouch" );
	}
}

shouldChangeStanceForFun() // and for variety
{
	if ( !isDefined( self.enemy ) )
		return false;
	
	if ( !isDefined( self.changeStanceForFunTime ) )
		self.changeStanceForFunTime = gettime() + randomintrange( 5000, 20000 );
	
	if ( gettime() > self.changeStanceForFunTime )
	{
		self.changeStanceForFunTime = gettime() + randomintrange( 5000, 20000 );
		
		if ( isDefined( self.ramboChance ) && self.a.pose == "stand" )
			return false;
			
		self.a.prevAttack = undefined;
		return true;
	}
	
	return false;
}

mainLoopStart()
{
	desiredStance = "stand";
	
	if ( self.a.pose == "crouch" )
	{
		desiredStance = "crouch";
		if ( self.coverNode doesNodeAllowStance( "stand" ) )
		{
			if ( !self.coverNode doesNodeAllowStance( "crouch" ) || shouldChangeStanceForFun() )
				desiredStance = "stand";
		}
	}
	else
	{
		if ( self.coverNode doesNodeAllowStance( "crouch" ) )
		{
			if ( !self.coverNode doesNodeAllowStance( "stand" ) || shouldChangeStanceForFun() )
				desiredStance = "crouch";
		}
	}

	 /#
	if ( getdvarint( "scr_cornerforcecrouch" ) == 1 )
		desiredStance = "crouch";
	#/

	if ( self.haveGoneToCover )
	{
		self transitionToStance( desiredStance );
	}
	else
	{
		if ( self.a.pose == desiredStance )
		{
			GoToCover( animArray( "alert_idle" ), .3, .4 );
		}
		else
		{
			stanceChangeAnim = animarray( "stance_change" );
			GoToCover( stanceChangeAnim, .3, getAnimLength( stanceChangeAnim ) );
			set_anim_array( desiredStance );// ( sets anim_pose to stance )
		}
		assert( self.a.pose == desiredStance );
		self.haveGoneToCover = true;
	}
}

printYaws()
{
	wait( 2 );
	for ( ;; )
	{
		println( "coveryaw = ", self.coverNode GetYawToOrigin( getEnemyEyePos() ) );
		printYawToEnemy();
		wait( 0.05 );
	}
}

// used within canSeeEnemyFromExposed() (in utility.gsc)
canSeePointFromExposedAtCorner( point, node )
{
	yaw = node GetYawToOrigin( point );
	if ( ( yaw > 60 ) || ( yaw < - 60 ) )
		return false;

	if ( ( node.type == "Cover Left" ) && yaw > 14 )
		return false;
	if ( ( node.type == "Cover Right" ) && yaw < - 12 )
		return false;

	return true;
}

shootPosOutsideLegalYawRange()
{
	if ( !isdefined( self.shootPos ) )
		return false;

	yaw = self.coverNode GetYawToOrigin( self.shootPos );

	if ( self.a.cornerMode == "over" )
		return yaw < self.leftAimLimit || self.rightAimLimit < yaw;

	if ( self.cornerDirection == "left" )
	{
		if ( self.a.cornerMode == "B" )
		{
			return yaw < 0 - self.ABangleCutoff || yaw > 14;
		}
		else if ( self.a.cornerMode == "A" )
		{
			return yaw > 0 - self.ABangleCutoff;
		}
		else
		{
			assert( self.a.cornerMode == "lean" );
			return yaw < - 50 || yaw > 8;// TODO
		}
	}
	else
	{
		assert( self.cornerDirection == "right" );
		if ( self.a.cornerMode == "B" )
		{
			return yaw > self.ABangleCutoff || yaw < - 12;
		}
		else if ( self.a.cornerMode == "A" )
		{
			return yaw < self.ABangleCutoff;
		}
		else
		{
			assert( self.a.cornerMode == "lean" );
			return yaw > 50 || yaw < - 8;// TODO
		}
	}
}

// getCornerMode will return "none" if no corner modes are acceptable.
getCornerMode( node, point )
{
	noStepOut = false;
	yaw = 0;
	
	if ( isdefined( point ) )
		yaw = node GetYawToOrigin( point );

	modes = [];

	// don't want to get cover peekouts for crouch while standing
	if ( isdefined( node ) && self.a.pose == "crouch" && ( yaw > self.leftAimLimit && self.rightAimLimit > yaw ) )
		modes = node GetValidCoverPeekOuts();
	
	if ( self.cornerDirection == "left" )
	{
		if ( canLean( yaw, -40, 0 ) )
		{
			noStepOut = shouldLean();
			modes[ modes.size ] = "lean";
		}
					
		if ( !noStepOut && yaw < 14 )
		{
			if ( yaw < 0 - self.ABangleCutoff )
				modes[ modes.size ] = "A";
			else
				modes[ modes.size ] = "B";
		}
	}
	else
	{
		assert( self.cornerDirection == "right" );
		
		if ( canLean( yaw, 0, 40 ) )
		{
			noStepOut = shouldLean();
			modes[ modes.size ] = "lean";
		}
		
		if ( !noStepOut && yaw > -12 )
		{
			if ( yaw > self.ABangleCutoff )
				modes[ modes.size ] = "A";
			else
				modes[ modes.size ] = "B";
		}
	}

	return getRandomCoverMode( modes );
}

// getBestStepOutPos never returns "none".
// it returns the best stepoutpos that we can get to from our current one.
getBestStepOutPos()
{
	yaw = 0;
	if ( canSuppressEnemy() )
		yaw = self.coverNode GetYawToOrigin( getEnemySightPos() );
	else if ( self.doingAmbush && isdefined( self.shootPos ) )
		yaw = self.coverNode GetYawToOrigin( self.shootPos );

	 /#
	dvarval = getdvar( "scr_cornerforcestance" );
	if ( dvarval == "lean" || dvarval == "a" || dvarval == "b" )
		return dvarval;
	#/

	if ( self.a.cornerMode == "lean" )
		return "lean";
	if ( self.a.cornerMode == "over" )
		return "over";
	else if ( self.a.cornerMode == "B" )
	{
		if ( self.cornerDirection == "left" )
		{
			if ( yaw < 0 - self.ABangleCutoff )
				return "A";
		}
		else if ( self.cornerDirection == "right" )
		{
			if ( yaw > self.ABangleCutoff )
				return "A";
		}
		return "B";
	}
	else if ( self.a.cornerMode == "A" )
	{
		positionToSwitchTo = "B";
		if ( self.cornerDirection == "left" )
		{
			if ( yaw > 0 - self.ABangleCutoff )
				return "B";
		}
		else if ( self.cornerDirection == "right" )
		{
			if ( yaw < self.ABangleCutoff )
				return "B";
		}
		return "A";
	}
}

changeStepOutPos()
{
	self endon( "killanimscript" );

	positionToSwitchTo = getBestStepOutPos();

	if ( positionToSwitchTo == self.a.cornerMode )
		return false;

	// can't switch between lean/over and other stepoutposes
	// so if this assert fails then getBestStepOutPos gave us a bad return value
	assert( self.a.cornerMode != "lean" && positionToSwitchTo != "lean" );
	assert( self.a.cornerMode != "over" && positionToSwitchTo != "over" );

	self.changingCoverPos = true; self notify( "done_changing_cover_pos" );

	animname = self.a.cornerMode + "_to_" + positionToSwitchTo;
	assert( animArrayAnyExist( animname ) );
	switchanim = animArrayPickRandom( animname );

	midpoint = getPredictedPathMidpoint();
	if ( !self mayMoveToPoint( midpoint ) )
		return false;
	if ( !self mayMoveFromPointToPoint( midpoint, getAnimEndPos( switchanim ) ) )
		return false;

	self endAimIdleThread();

	// turn off aiming while we move.
	self StopAiming( .3 );

	prev_anim_pose = self.a.pose;

	self setanimlimited( animarray( "straight_level" ), 0, .2 );

	self setFlaggedAnimKnob( "changeStepOutPos", switchanim, 1, .2, 1.2 );
	self thread DoNoteTracksWithEndon( "changeStepOutPos" );

	if ( animHasNotetrack( switchanim, "start_aim" ) )
	{
		self waittillmatch( "changeStepOutPos", "start_aim" );
	}
	else
	{
		 /#println( "^1Corner position switch animation \"" + animname + "\" in corner_" + self.cornerDirection + " " + self.a.pose + " didn't have \"start_aim\" notetrack" );#/
		self waittillmatch( "changeStepOutPos", "end" );
	}

	self thread StartAiming( undefined, false, .3 );

	self waittillmatch( "changeStepOutPos", "end" );
	self clearanim( switchanim, .1 );
	self.a.cornerMode = positionToSwitchTo;

	self.changingCoverPos = false;
	self.coverPosEstablishedTime = gettime();

	assert( self.a.pose == "stand" || self.a.pose == "crouch" );
	if ( self.a.pose != prev_anim_pose )
		set_anim_array( self.a.pose );// don't call this if we don't have to, because we don't want to reset %exposed_aiming

	self thread ChangeAiming( undefined, true, .3 );

	return true;
}

canLean( yaw, yawMin, yawMax )
{
	if ( self.a.neverLean )
		return false;
		
	return ( yawMin <= yaw && yaw <= yawMax );
}

shouldLean()
{
	if ( self.team == "allies" )
		return true;

	if ( self isPartiallySuppressedWrapper() )
		return true;
	
	return false;
}

DoNoteTracksWithEndon( animname )
{
	self endon( "killanimscript" );
	self animscripts\shared::DoNoteTracks( animname );
}

StartAiming( spot, fullbody, transtime )
{
	assert( !self.cornerAiming );
	self.cornerAiming = true;
	if ( self.a.cornerMode == "lean" )
		self.a.leanAim = true;
	else
		self.a.leanAim = undefined;

	self SetAimingParams( spot, fullbody, transTime );
}

ChangeAiming( spot, fullbody, transtime )
{
	assert( self.cornerAiming );
	if ( self.a.cornerMode == "lean" )
		self.a.leanAim = true;
	else
		self.a.leanAim = undefined;
		
	self SetAimingParams( spot, fullbody, transTime );
}

StopAiming( transtime )
{
	assert( self.cornerAiming );
	self.cornerAiming = false;

	// turn off shooting
	self clearAnim( %add_fire, transtime );
	// and turn off aiming
	animscripts\shared::setAnimAimWeight( 0, transtime );
}

SetAimingParams( spot, fullbody, transTime )
{
	assert( isdefined( fullbody ) );

	self.spot = spot;// undefined is ok

	self setanimlimited( %exposed_modern, 1, transTime );
	self setanimlimited( %exposed_aiming, 1, transTime );
	self setanimlimited( %add_idle, 1, transTime );
	animscripts\shared::setAnimAimWeight( 1, transTime );

	leanAnim = undefined;
	if ( isdefined( self.a.array[ "lean_aim_straight" ] ) )
		leanAnim = self.a.array[ "lean_aim_straight" ];
	
	self thread aimIdleThread();

	if ( isdefined( self.a.leanAim ) )
	{
		self setAnimLimited( leanAnim, 1, transTime );
		self setAnimLimited( animArray( "straight_level" ), 0, 0 );

		self setAnimKnobLimited( animArray( "lean_aim_left" ), 1, transTime );
		self setAnimKnobLimited( animArray( "lean_aim_right" ), 1, transTime );
		self setAnimKnobLimited( animArray( "lean_aim_up" ), 1, transTime );
		self setAnimKnobLimited( animArray( "lean_aim_down" ), 1, transTime );
	}
	else if ( fullbody )
	{
		self setAnimLimited( animarray( "straight_level" ), 1, transTime );
		if ( isdefined( leanAnim ) )
			self setAnimLimited( leanAnim, 0, 0 );

		self setAnimKnobLimited( animArray( "add_aim_up" ), 1, transTime );
		self setAnimKnobLimited( animArray( "add_aim_down" ), 1, transTime );
		self setAnimKnobLimited( animArray( "add_aim_left" ), 1, transTime );
		self setAnimKnobLimited( animArray( "add_aim_right" ), 1, transTime );
	}
	else
	{
		self setAnimLimited( animarray( "straight_level" ), 0, transTime );
		if ( isdefined( leanAnim ) )
			self setAnimLimited( leanAnim, 0, 0 );

		self setAnimKnobLimited( animArray( "add_turn_aim_up" ), 1, transTime );
		self setAnimKnobLimited( animArray( "add_turn_aim_down" ), 1, transTime );
		self setAnimKnobLimited( animArray( "add_turn_aim_left" ), 1, transTime );
		self setAnimKnobLimited( animArray( "add_turn_aim_right" ), 1, transTime );
	}
}

// These should be adjusted in animation data
stepOutAndHideSpeed()
{
	if ( self.a.cornerMode == "over" )
		return 1;

	//if ( self.a.cornerMode == "B" )
	//	return 1;

	return randomFasterAnimSpeed();
}

stepOut() /* bool */
{
	self.a.cornerMode = "alert";

	if ( self.goalRadius < 64 )
		self.goalRadius = 64;

	self animMode( "zonly_physics" );

	if ( self.a.pose == "stand" )
	{
		self.ABangleCutoff = 38;
	}
	else
	{
		assert( self.a.pose == "crouch" );
		self.ABangleCutoff = 31;
	}

	thisNodePose = self.a.pose;
	set_anim_array( thisNodePose );
	
	self setDefaultAimLimits();	// do exposed animations once stepped out
	
	newCornerMode = "none";
	if ( hasEnemySightPos() )
		newCornerMode = getCornerMode( self.coverNode, getEnemySightPos() );
	else
		newCornerMode = getCornerMode( self.coverNode );

	if ( !isdefined( newCornerMode ) )
		return false;

	animname = "alert_to_" + newCornerMode;
	assert( animArrayAnyExist( animname ) );
	switchanim = animArrayPickRandom( animname );

	if ( newCornerMode == "lean" && !self isPeekOutPosClear() )
		return false;

	if ( newCornerMode != "over" && !isPathClear( switchanim, newCornerMode != "lean" ) )
		return false;

	self.a.cornerMode = newCornerMode;
	self.a.prevAttack = newCornerMode;

	if ( self.a.cornerMode == "lean" )
		self setDefaultAimLimits( self.coverNode );

	if ( newCornerMode == "A" || newCornerMode == "B" ) 
		self.a.special = "cover_" + self.cornerDirection + "_" + self.a.pose + "_" + newCornerMode;
	else if ( newCornerMode == "over" )
		self.a.special = "cover_crouch_aim";
	else
		self.a.special = "none";

	self.keepClaimedNodeIfValid = true;

	hasStartAim = false;
	
	self.changingCoverPos = true; 
	self notify( "done_changing_cover_pos" );

	animRate = stepOutAndHideSpeed();
	
	self.pushable = false;

	self setFlaggedAnimKnobAllRestart( "stepout", switchanim, %root, 1, .2, animRate );
	self thread DoNoteTracksWithEndon( "stepout" );

	hasStartAim = animHasNotetrack( switchanim, "start_aim" );
	if ( hasStartAim )
	{
		// Store our final step out angle so that we may use it when doing track loop aiming
		self.stepOutYaw = self.angles[1] + getAngleDelta( switchanim, 0, 1 );

		self waittillmatch( "stepout", "start_aim" );
	}
	else
	{
		/#println( "^1Corner stepout animation \"" + animname + "\" in corner_" + self.cornerDirection + " " + self.a.pose + " didn't have \"start_aim\" notetrack" );#/
		self waittillmatch( "stepout", "end" );
	}

	if ( newCornerMode == "B" && coinToss() && self.cornerDirection == "right" )
		self.a.special = "corner_right_martyrdom";

	set_anim_array_aiming( thisNodePose );

	fullbody = ( newCornerMode == "over" );

	self StartAiming( undefined, fullbody, .3 );
	self thread animscripts\shared::trackShootEntOrPos();

	if ( hasStartAim )
	{
		self waittillmatch( "stepout", "end" );
		
		// Clear the forced yaw after the animation is fully played
		self.stepOutYaw = undefined;
	}
	
	self ChangeAiming( undefined, true, 0.2 );
	self clearAnim( %cover, 0.1 );
	self clearAnim( %corner, 0.1 );
	
	self.changingCoverPos = false;
	self.coverPosEstablishedTime = gettime();
	
	self.pushable = true;

	return true;
}

stepOutAndShootEnemy()
{
	self.keepClaimedNodeIfValid = true;
	
	// do rambo behavior sometimes on rambo AI guys. Normal AI never do rambo
	if ( isdefined( self.ramboChance ) && randomFloat( 1 ) < self.ramboChance )
	{
		if ( rambo() )
			return true;
	}
	
	if ( !StepOut() ) // may not be room to step out
		return false;

	shootAsTold();

	if ( isDefined( self.shootPos ) )
	{
		distSqToShootPos = lengthsquared( self.origin - self.shootPos );
		// too close for RPG or out of ammo
		if ( usingRocketLauncher() && ( distSqToShootPos < squared( 512 ) || self.a.rockets < 1 ) )
		{
			if ( self.a.pose == "stand" )
				animscripts\shared::throwDownWeapon( %RPG_stand_throw );
			else
				animscripts\shared::throwDownWeapon( %RPG_crouch_throw );

			self thread runCombat();
			return;
		}
	}

	returnToCover();
		
	self.keepClaimedNodeIfValid = false;

	return true;
}

haventRamboedWithinTime( time )
{
	if ( !isdefined( self.lastRamboTime ) )
		return true;
	return gettime() - self.lastRamboTime > time * 1000;
}

rambo()
{
	if ( !hasEnemySightPos() )
		return false;
	
	ramboAimOffset = 0;
	angle = 90;
	yaw = self.coverNode GetYawToOrigin( getEnemySightPos() );
	if ( self.cornerDirection == "left" )
		yaw = 0 - yaw;
	if ( yaw > 30 ) // this cutoff works better visually than 22.5
	{
		angle = 45;
		if ( self.cornerDirection == "left" )
			ramboAimOffset = 45;
		else
			ramboAimOffset = -45;
	}
	
	animType = "rambo" + angle;
	if ( !animArrayAnyExist( animType ) )
		return false;
	
	// commented out so we see rambo a lot, might want to adjust this later
	//if ( !haventRamboedWithinTime( 2 ) )
	//	return false;
	
	// move check
	ramboAnim = animArrayPickRandom( animType );
	midpoint = getPredictedPathMidpoint( 48 );
	if ( !self mayMoveToPoint( midpoint ) )
		return false;
	// no point doing this check, since the animation will end at the cover node.
	//if ( !self mayMoveFromPointToPoint( midpoint, getAnimEndPos( ramboAnim ) ) )
	//	return false;
	
	self.coverPosEstablishedTime = gettime();
	
	self animMode( "zonly_physics" );
	self.keepClaimedNodeIfValid = true;
	self.isRambo = true;
	self.a.prevAttack = "rambo";
	
	self.changingCoverPos = true;
	
	self thread animscripts\shared::ramboAim( ramboAimOffset );
	
	self setFlaggedAnimKnobAllRestart( "rambo", ramboAnim, %body, 1, 0, 1 );
	self animscripts\shared::DoNoteTracks( "rambo" );
	
	self notify( "rambo_aim_end" );
	
	self.changingCoverPos = false;
	
	self.keepClaimedNodeIfValid = false;
	self.lastRamboTime = getTime();
	
	self.changingCoverPos = false;
	self.isRambo = undefined;
	
	return true;
}

shootAsTold()
{
	self maps\_gameskill::didSomethingOtherThanShooting();

	while ( 1 )
	{
		while ( 1 )
		{
			if ( isdefined( self.shouldReturnToCover ) )
				break;

			if ( !isdefined( self.shootPos ) ) {
				assert( !isdefined( self.shootEnt ) );
				// give shoot_behavior a chance to iterate
				self waittill( "do_slow_things" );
				waittillframeend;
				if ( isdefined( self.shootPos ) )
					continue;
				break;
			}

			if ( !self.bulletsInClip )
				break;

			if ( shootPosOutsideLegalYawRange() )
			{
				if ( !changeStepOutPos() )
				{
					// if we failed because there's no better step out pos, give up
					if ( getBestStepOutPos() == self.a.cornerMode )
						break;

					// couldn't change position, shoot for a short bit and we'll try again
					shootUntilShootBehaviorChangeForTime( .2 );
					continue;
				}

				// if they're moving back and forth too fast for us to respond intelligently to them,
				// give up on firing at them for the moment
				if ( shootPosOutsideLegalYawRange() )
					break;

				continue;
			}

			shootUntilShootBehaviorChange_corner( true );

			self clearAnim( %add_fire, .2 );
		}

		if ( self canReturnToCover( self.a.cornerMode != "lean" ) )
			break;

		// couldn't return to cover. keep shooting and try again

		// (change step out pos if necessary and possible)
		if ( shootPosOutsideLegalYawRange() && changeStepOutPos() )
			continue;

		shootUntilShootBehaviorChangeForTime( .2 );
	}
}

shootUntilShootBehaviorChangeForTime( time )
{
	self thread notifyStopShootingAfterTime( time );

	starttime = gettime();

	shootUntilShootBehaviorChange_corner( false );
	self notify( "stopNotifyStopShootingAfterTime" );

	timepassed = ( gettime() - starttime ) / 1000;
	if ( timepassed < time )
		wait time - timepassed;
}

notifyStopShootingAfterTime( time )
{
	self endon( "killanimscript" );
	self endon( "stopNotifyStopShootingAfterTime" );

	wait time;

	self notify( "stopShooting" );
}

shootUntilShootBehaviorChange_corner( runAngleRangeThread )
{
	self endon( "return_to_cover" );

	if ( runAngleRangeThread )
		self thread angleRangeThread();// gives stopShooting notify when shootPosOutsideLegalYawRange returns true
	self thread aimIdleThread();

	shootUntilShootBehaviorChange();
}


angleRangeThread()
{
	self endon( "killanimscript" );
	self notify( "newAngleRangeCheck" );
	self endon( "newAngleRangeCheck" );
	self endon( "take_cover_at_corner" );

	while ( 1 )
	{
		if ( shootPosOutsideLegalYawRange() )
			break;
		wait( 0.1 );
	}

	self notify( "stopShooting" );// For changing shooting pose to compensate for player moving
}

showstate()
{
	self.enemy endon( "death" );
	self endon( "enemy" );
	self endon( "stopshowstate" );

	while ( 1 )
	{
		wait .05;
		print3d( self.origin + ( 0, 0, 60 ), self.statetext );
	}
}

canReturnToCover( doMidpointCheck )
{
	if ( doMidpointCheck )
	{
		midpoint = getPredictedPathMidpoint();

		if ( !self mayMoveToPoint( midpoint ) )
			return false;

		return self mayMoveFromPointToPoint( midpoint, self.coverNode.origin );
	}
	else
	{
		return self mayMoveToPoint( self.coverNode.origin );
	}
}

returnToCover()
{
	assert( self canReturnToCover( self.a.cornerMode != "lean" ) );

	endFireAndAnimIdleThread();

	// Go back into hiding.
	suppressed = issuppressedWrapper();
	self notify( "take_cover_at_corner" );// Stop doing the adjust - stance transition thread

	self.changingCoverPos = true;
	self notify( "done_changing_cover_pos" );

	animname = self.a.cornerMode + "_to_alert";
	assert( animArrayAnyExist( animname ) );
	switchanim = animArrayPickRandom( animname );

	self StopAiming( .3 );

	reloading = false;
	if ( self.a.cornerMode != "lean" && suppressed && animArrayAnyExist( animname + "_reload" ) && randomfloat( 100 ) < 75 )
	{
		switchanim = animArrayPickRandom( animname + "_reload" );
		reloading = true;
	}

	rate = stepOutAndHideSpeed();

	self clearanim( %body, 0.1 );
	self setFlaggedAnimRestart( "hide", switchanim, 1, .1, rate );
	self animscripts\shared::DoNoteTracks( "hide" );

	if ( reloading )
		self animscripts\weaponList::RefillClip();

	self.changingCoverPos = false;
	if ( self.cornerDirection == "left" )
		self.a.special = "cover_left";
	else
		self.a.special = "cover_right";

	self.keepClaimedNodeIfValid = false;

	self clearAnim( switchanim, 0.2 );
}

blindfire()
{
	if ( !animArrayAnyExist( "blind_fire" ) )
		return false;

	self animMode( "zonly_physics" );
	self.keepClaimedNodeIfValid = true;

	self setFlaggedAnimKnobAllRestart( "blindfire", animArrayPickRandom( "blind_fire" ), %body, 1, 0, 1 );
	self animscripts\shared::DoNoteTracks( "blindfire" );

	self.keepClaimedNodeIfValid = false;

	return true;
}

linethread( a, b, col )
{
	if ( !isdefined( col ) )
		col = ( 1, 1, 1 );
	for ( i = 0; i < 100; i++ )
	{
		line( a, b, col );
		wait .05;
	}
}

tryThrowingGrenadeStayHidden( throwAt )
{
	return tryThrowingGrenade( throwAt, true );
}

tryThrowingGrenade( throwAt, safe )
{
	if ( !self mayMoveToPoint( self getPredictedPathMidpoint() ) )
		return false;
		
	if ( isdefined( self.dontEverShoot ) || isdefined( throwAt.dontAttackMe ) )
		return false;

	theanim = undefined;
	if ( isdefined( self.ramboChance ) && randomFloat( 1 ) < self.ramboChance )
	{
		if ( isdefined( self.a.array[ "grenade_rambo" ] ) )
			theanim = animArray( "grenade_rambo" );
	}
	if ( !isdefined( theanim ) )
	{
		if ( isdefined( safe ) && safe )
		{
			if ( !isdefined( self.a.array[ "grenade_safe" ] ) )
				return false;
			theanim = animArray( "grenade_safe" );
		}
		else
		{
			if ( !isdefined( self.a.array[ "grenade_exposed" ] ) )
				return false;
			theanim = animArray( "grenade_exposed" );
		}
	}
	assert( isdefined( theanim ) );
	
	self animMode( "zonly_physics" );// Unlatch the feet
	self.keepClaimedNodeIfValid = true;

	threwGrenade = TryGrenade( throwAt, theanim );

	self.keepClaimedNodeIfValid = false;
	return threwGrenade;
}

printYawToEnemy()
{
	println( "yaw: ", self getYawToEnemy() );
}

lookForEnemy( lookTime )
{
	if ( !isdefined( self.a.array[ "alert_to_look" ] ) )
		return false;

	self animMode( "zonly_physics" );// Unlatch the feet
	self.keepClaimedNodeIfValid = true;

	// look out from alert
	if ( !peekOut() )
		return false;

	animscripts\shared::playLookAnimation( animarray( "look_idle" ), lookTime, ::canStopPeeking );

	lookanim = undefined;
	if ( self isSuppressedWrapper() )
		lookanim = animArray( "look_to_alert_fast" );
	else
		lookanim = animArray( "look_to_alert" );

	self setflaggedanimknoballrestart( "looking_end", lookanim, %body, 1, .1, 1.0 );
	animscripts\shared::DoNoteTracks( "looking_end" );

	self animMode( "zonly_physics" );// Unlatch the feet

	self.keepClaimedNodeIfValid = false;

	return true;
}


PEEKOUT_OFFSET = 30;

isPeekOutPosClear()
{
	assert( isdefined( self.coverNode ) );
	
	eyePos = self geteye();
	rightDir = anglestoright( self.coverNode.angles );
	if ( self.cornerDirection == "right" )
		eyePos = eyePos + (rightDir * PEEKOUT_OFFSET);
	else
		eyePos = eyePos - (rightDir * PEEKOUT_OFFSET);

	lookAtPos = eyePos + anglesToForward( self.coverNode.angles ) * PEEKOUT_OFFSET;
	
	// /# thread debugLine( eyePos, lookAtPos, ( 1, 0, 0 ), 1.5 ); #/
	
	return sightTracePassed( eyePos, lookAtPos, true, self );
}


peekOut()
{
	if ( isdefined( self.coverNode.script_dontpeek ) )
		return false;	

	if ( isdefined( self.nextPeekOutAttemptTime ) && gettime() < self.nextPeekOutAttemptTime )
		return false;

	if ( !self isPeekOutPosClear() )
	{
		self.nextPeekOutAttemptTime = gettime() + 3000;
		return false;
	}

	peekanim = animArray( "alert_to_look" );

	// assuming no delta, so no maymovetopoint check
	//if ( !self mayMoveToPoint( getAnimEndPos( peekanim ) ) )
	//	return false;

	// not safe to stop peeking in the middle because it will screw up our deltas
	//self thread _peekStop();
	//self endon ("stopPeeking");

	self setflaggedanimknobAll( "looking_start", peekanim, %body, 1, .2, 1 );
	animscripts\shared::DoNoteTracks( "looking_start" );
	//self notify ("stopPeekCheckThread");

	return true;
}

canStopPeeking()
{
	return self mayMoveToPoint( self.coverNode.origin );
}

fastlook()
{
	// corner fast look animations aren't set up right.
	return false;

	/*
	if ( !isdefined( self.a.array["look"] ) )
		return false;
	
	self setFlaggedAnimKnobAllRestart( "look", animArray( "look" ), %body, 1, .1 );
	self animscripts\shared::DoNoteTracks( "look" );
	
	return true;
	*/
}

cornerReload()
{
	assert( animArrayAnyExist( "reload" ) );

	reloadanim = animArrayPickRandom( "reload" );
	self setFlaggedAnimKnobRestart( "cornerReload", reloadanim, 1, .2 );

	self animscripts\shared::DoNoteTracks( "cornerReload" );

	self animscripts\weaponList::RefillClip();

	self setAnimRestart( animarray( "alert_idle" ), 1, .2 );
	self clearAnim( reloadanim, .2 );

	return true;
}

isPathClear( stepoutanim, doMidpointCheck )
{
	if ( doMidpointCheck )
	{
		midpoint = getPredictedPathMidpoint();

		if ( !self maymovetopoint( midpoint ) )
			return false;

		return self maymovefrompointtopoint( midpoint, getAnimEndPos( stepoutanim ) );
	}
	else
	{
		return self maymovetopoint( getAnimEndPos( stepoutanim ) );
	}
}

getPredictedPathMidpoint( dist )
{
	angles = self.coverNode.angles;
	right = anglestoright( angles );
	if ( !isdefined( dist ) )
		dist = 36;
	switch( self.script )
	{
		case "cover_left":
			right = vector_multiply( right, 0-dist );
		break;

		case "cover_right":
			right = vector_multiply( right, dist );
		break;

		default:
			assertEx( 0, "What kind of node is this????" );
	}

	return self.coverNode.origin + ( right[ 0 ], right[ 1 ], 0 );
}

idle()
{
	self endon( "end_idle" );

	while ( 1 )
	{
		useTwitch = ( randomint( 2 ) == 0 && animArrayAnyExist( "alert_idle_twitch" ) );
		if ( useTwitch )
			idleanim = animArrayPickRandom( "alert_idle_twitch" );
		else
			idleanim = animarray( "alert_idle" );

		playIdleAnimation( idleAnim, useTwitch );
	}
}

flinch()
{
	if ( !animArrayAnyExist( "alert_idle_flinch" ) )
		return false;

	playIdleAnimation( animArrayPickRandom( "alert_idle_flinch" ), true );

	return true;
}

playIdleAnimation( idleAnim, needsRestart )
{
	if ( needsRestart )
		self setFlaggedAnimKnobAllRestart( "idle", idleAnim, %body, 1, .1, 1 );
	else
		self setFlaggedAnimKnobAll( "idle", idleAnim, %body, 1, .1, 1 );

	self animscripts\shared::DoNoteTracks( "idle" );
}


set_anim_array( stance )
{
	[[ self.animArrayFuncs[ "hiding" ][ stance ] ]]();
	[[ self.animArrayFuncs[ "exposed" ][ stance ] ]]();
}
set_anim_array_aiming( stance )
{
	[[ self.animArrayFuncs[ "exposed" ][ stance ] ]]();
}

transitionToStance( stance )
{
	if ( self.a.pose == stance )
	{
		set_anim_array( stance );
		return;
	}

//	self ExitProneWrapper(0.5);
	self setFlaggedAnimKnobAllRestart( "changeStance", animarray( "stance_change" ), %body );

	set_anim_array( stance );// ( sets anim_pose to stance )

	self animscripts\shared::DoNoteTracks( "changeStance" );
	assert( self.a.pose == stance );
	wait( 0.2 );
}

GoToCover( coveranim, transTime, playTime )
{
	cornerAngle = GetNodeDirection();
	cornerOrigin = GetNodeOrigin();

	desiredYaw = cornerAngle + self.hideyawoffset;

	self OrientMode( "face angle", desiredYaw );

	self animMode( "normal" );

	assert( transTime <= playTime );

	self thread animscripts\shared::moveToOriginOverTime( cornerOrigin, transTime );
	self setFlaggedAnimKnobAllRestart( "coveranim", coveranim, %body, 1, transTime );
	self animscripts\shared::DoNoteTracksForTime( playTime, "coveranim" );

	while ( AbsAngleClamp180( self.angles[ 1 ] - desiredYaw ) > 1 )
	{
		self animscripts\shared::DoNoteTracksForTime( 0.1, "coveranim" );
	}

	self animMode( "zonly_physics" );

	if ( self.cornerDirection == "left" )
		self.a.special = "cover_left";
	else
		self.a.special = "cover_right";
}

drawoffset()
{
	self endon( "killanimscript" );
	for ( ;; )
	{
		line( self.node.origin + ( 0, 0, 20 ), ( 0, 0, 20 ) + self.node.origin + vector_multiply( anglestoright( self.node.angles + ( 0, 0, 0 ) ), 16 ) );
		wait( 0.05 );
	}
}


set_standing_animarray_aiming()
{
	if ( !isdefined( self.a.array ) )
		assertmsg( "set_standing_animarray_aiming_AandC::this function needs to be called after the initial corner set_ functions" );

	self.a.array[ "add_aim_up" ] = %exposed_aim_8;
	self.a.array[ "add_aim_down" ] = %exposed_aim_2;
	self.a.array[ "add_aim_left" ] = %exposed_aim_4;
	self.a.array[ "add_aim_right" ] = %exposed_aim_6;
	self.a.array[ "add_turn_aim_up" ] = %exposed_turn_aim_8;
	self.a.array[ "add_turn_aim_down" ] = %exposed_turn_aim_2;
	self.a.array[ "add_turn_aim_left" ] = %exposed_turn_aim_4;
	self.a.array[ "add_turn_aim_right" ] = %exposed_turn_aim_6;
	self.a.array[ "straight_level" ] = %exposed_aim_5;

	if ( self.a.cornerMode == "lean" )
	{
		// use the lean animations set up in cover_left and cover_right.gsc
		leanfire = self.a.array[ "lean_fire" ];
		leanSemiFire = self.a.array[ "lean_single" ];
		self.a.array[ "fire" ] = leanfire;
		self.a.array[ "single" ] = array( leanSemiFire );

		self.a.array[ "semi2" ] = leanSemiFire;
		self.a.array[ "semi3" ] = leanSemiFire;
		self.a.array[ "semi4" ] = leanSemiFire;
		self.a.array[ "semi5" ] = leanSemiFire;

		self.a.array[ "burst2" ] = leanfire;
		self.a.array[ "burst3" ] = leanfire;
		self.a.array[ "burst4" ] = leanfire;
		self.a.array[ "burst5" ] = leanfire;
		self.a.array[ "burst6" ] = leanfire;
	}
	else
	{
		self.a.array[ "fire" ] = %exposed_shoot_auto_v2;
		self.a.array[ "semi2" ] = %exposed_shoot_semi2;
		self.a.array[ "semi3" ] = %exposed_shoot_semi3;
		self.a.array[ "semi4" ] = %exposed_shoot_semi4;
		self.a.array[ "semi5" ] = %exposed_shoot_semi5;

		if ( weapon_pump_action_shotgun() )
			self.a.array[ "single" ] = array( %shotgun_stand_fire_1A );
		else
			self.a.array[ "single" ] = array( %exposed_shoot_semi1 );

		self.a.array[ "burst2" ] = %exposed_shoot_burst3;// ( will be limited to 2 shots )
		self.a.array[ "burst3" ] = %exposed_shoot_burst3;
		self.a.array[ "burst4" ] = %exposed_shoot_burst4;
		self.a.array[ "burst5" ] = %exposed_shoot_burst5;
		self.a.array[ "burst6" ] = %exposed_shoot_burst6;
	}
	self.a.array[ "exposed_idle" ] = array( %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 );
}

set_crouching_animarray_aiming()
{
	if ( !isdefined( self.a.array ) )
		assertmsg( "set_standing_animarray_aiming_AandC::this function needs to be called after the initial corner set_ functions" );

	if ( self.a.cornerMode == "over" )
	{
		self.a.array[ "add_aim_up" ] = %covercrouch_aim8_add;
		self.a.array[ "add_aim_down" ] = %covercrouch_aim2_add;
		self.a.array[ "add_aim_left" ] = %covercrouch_aim4_add;
		self.a.array[ "add_aim_right" ] = %covercrouch_aim6_add;
		self.a.array[ "straight_level" ] = %covercrouch_aim5;

		anim_array[ "fire" ] = %exposed_shoot_auto_v2;
		anim_array[ "semi2" ] = %exposed_shoot_semi2;
		anim_array[ "semi3" ] = %exposed_shoot_semi3;
		anim_array[ "semi4" ] = %exposed_shoot_semi4;
		anim_array[ "semi5" ] = %exposed_shoot_semi5;

		anim_array[ "burst2" ] = %exposed_shoot_burst3;// ( will be limited to 2 shots )
		anim_array[ "burst3" ] = %exposed_shoot_burst3;
		anim_array[ "burst4" ] = %exposed_shoot_burst4;
		anim_array[ "burst5" ] = %exposed_shoot_burst5;
		anim_array[ "burst6" ] = %exposed_shoot_burst6;

		if ( weapon_pump_action_shotgun() )
			anim_array[ "single" ] = array( %shotgun_crouch_fire );
		else
			anim_array[ "single" ] = array( %exposed_shoot_semi1 );

		self.a.array[ "exposed_idle" ] = array( %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 );
		return;
	}

	if ( self.a.cornerMode == "lean" )
	{
		// use the lean animations set up in cover_left and cover_right.gsc
		leanfire = self.a.array[ "lean_fire" ];
		leanSemiFire = self.a.array[ "lean_single" ];
		self.a.array[ "fire" ] = leanfire;
		self.a.array[ "single" ] = array( leanSemiFire );

		self.a.array[ "semi2" ] = leanSemiFire;
		self.a.array[ "semi3" ] = leanSemiFire;
		self.a.array[ "semi4" ] = leanSemiFire;
		self.a.array[ "semi5" ] = leanSemiFire;

		self.a.array[ "burst2" ] = leanfire;
		self.a.array[ "burst3" ] = leanfire;
		self.a.array[ "burst4" ] = leanfire;
		self.a.array[ "burst5" ] = leanfire;
		self.a.array[ "burst6" ] = leanfire;
	}
	else
	{
		self.a.array[ "fire" ] = %exposed_crouch_shoot_auto_v2;
		self.a.array[ "semi2" ] = %exposed_crouch_shoot_semi2;
		self.a.array[ "semi3" ] = %exposed_crouch_shoot_semi3;
		self.a.array[ "semi4" ] = %exposed_crouch_shoot_semi4;
		self.a.array[ "semi5" ] = %exposed_crouch_shoot_semi5;

		if ( weapon_pump_action_shotgun() )
			self.a.array[ "single" ] = array( %shotgun_crouch_fire );
		else
			self.a.array[ "single" ] = array( %exposed_crouch_shoot_semi1 );

		self.a.array[ "burst2" ] = %exposed_crouch_shoot_burst3;// ( will be limited to 2 shots )
		self.a.array[ "burst3" ] = %exposed_crouch_shoot_burst3;
		self.a.array[ "burst4" ] = %exposed_crouch_shoot_burst4;
		self.a.array[ "burst5" ] = %exposed_crouch_shoot_burst5;
		self.a.array[ "burst6" ] = %exposed_crouch_shoot_burst6;
	}

	self.a.array[ "add_aim_up" ] = %exposed_crouch_aim_8;
	self.a.array[ "add_aim_down" ] = %exposed_crouch_aim_2;
	self.a.array[ "add_aim_left" ] = %exposed_crouch_aim_4;
	self.a.array[ "add_aim_right" ] = %exposed_crouch_aim_6;
	self.a.array[ "add_turn_aim_up" ] = %exposed_crouch_turn_aim_8;
	self.a.array[ "add_turn_aim_down" ] = %exposed_crouch_turn_aim_2;
	self.a.array[ "add_turn_aim_left" ] = %exposed_crouch_turn_aim_4;
	self.a.array[ "add_turn_aim_right" ] = %exposed_crouch_turn_aim_6;
	self.a.array[ "straight_level" ] = %exposed_crouch_aim_5;

	self.a.array[ "exposed_idle" ] = array( %exposed_crouch_idle_alert_v1, %exposed_crouch_idle_alert_v2, %exposed_crouch_idle_alert_v3 );
}

runCombat()
{
	self notify( "killanimscript" );
	self thread animscripts\combat::main();
}