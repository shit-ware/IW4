#include animscripts\Utility;
#include animscripts\Combat_Utility;
#include animscripts\SetPoseMovement;
#include common_scripts\utility;
#using_animtree( "generic_human" );

MoveRun()
{
	desiredPose = [[ self.choosePoseFunc ]]( "stand" );

	switch( desiredPose )
	{
	case "stand":
		if ( BeginStandRun() )// returns false( and does nothing ) if we're already stand - running
			return;

		if ( isDefined( self.run_overrideanim ) )
		{
			animscripts\move::MoveStandMoveOverride( self.run_overrideanim, self.run_override_weights );
			return;
		}

		if ( changeWeaponStandRun() )
			return;

		if ( ReloadStandRun() )
			return;

		if ( self animscripts\utility::IsInCombat() )
			MoveStandCombatNormal();
		else
			MoveStandNoncombatNormal();
		break;

	case "crouch":
		if ( BeginCrouchRun() )// returns false( and does nothing ) if we're already crouch - running
			return;

		if ( isDefined( self.crouchrun_combatanim ) )
			MoveCrouchRunOverride();
		else
			MoveCrouchRunNormal();
		break;

	default:
		assert( desiredPose == "prone" );
		if ( BeginProneRun() )// returns false( and does nothing ) if we're already prone - running
			return;

		ProneCrawl();
		break;
	}
}

GetRunAnim()
{
	if ( !isdefined( self.a.moveAnimSet ) )
		return %run_lowready_F;
		
	if ( !self.faceMotion )
	{
		if ( self.stairsState == "none" || abs( self getMotionAngle() ) > 45 )
			return moveAnim( "move_f" );
	}

	if ( self.stairsState == "up" )
		return moveAnim( "stairs_up" );
	else if ( self.stairsState == "down" )
		return moveAnim( "stairs_down" );

	return moveAnim( "straight" );
}

GetCrouchRunAnim()
{
	if ( !isdefined( self.a.moveAnimSet ) )
		return %crouch_fastwalk_F;
		
	return moveAnim( "crouch" );
}


ProneCrawl()
{
	self.a.movement = "run";
	self setflaggedanimknob( "runanim", moveAnim( "prone" ), 1, .3, self.moveplaybackrate );
	animscripts\shared::DoNoteTracksForTime( 0.25, "runanim" );
}


InitRunNGun()
{
	if ( !isdefined( self.runNGun ) )
	{
		self notify( "stop_move_anim_update" );
		self.update_move_anim_type = undefined;
		
		self clearanim( %combatrun_backward, 0.2 );
		self clearanim( %combatrun_right, 0.2 );
		self clearanim( %combatrun_left, 0.2 );
		
		self clearanim( %w_aim_2, 0.2 );
		self clearanim( %w_aim_4, 0.2 );
		self clearanim( %w_aim_6, 0.2 );
		self clearanim( %w_aim_8, 0.2 );
		
		self.runNGun = true;
	}
}

StopRunNGun()
{
	if ( isdefined( self.runNGun ) )
	{
		self clearanim( %run_n_gun, 0.2 );
		self.runNGun = undefined;
	}
	
	return false;
}


RunNGun( validTarget )
{
	if ( validTarget )
	{
		enemyyaw = self GetPredictedYawToEnemy( 0.2 );
		leftWeight = enemyyaw < 0;
	}
	else
	{
		enemyyaw = 0;
		leftWeight = self.runNGunWeight < 0;
	}
	
	rightWeight = 1 - leftWeight;
	
	maxRunNGunAngle = self.maxRunNGunAngle;
	runNGunTransitionPoint = self.runNGunTransitionPoint;
	runNGunIncrement = self.runNGunIncrement;

	if ( !validTarget || ( squared( enemyyaw ) > maxRunNGunAngle * maxRunNGunAngle ) )
	{
		// phase out run n gun
		self clearAnim( %add_fire, 0 );
		if ( squared( self.runNGunWeight ) < runNGunIncrement * runNGunIncrement )
		{
			self.runNGunWeight = 0;
			self.runNGun = undefined;
			return false;
		}
		else if ( self.runNGunWeight > 0 )
		{
			self.runNGunWeight = self.runNGunWeight - runNGunIncrement;
		}
		else
		{
			self.runNGunWeight = self.runNGunWeight + runNGunIncrement;
		}
	}
	else
	{
		newWeight = enemyyaw / maxRunNGunAngle;
		diff = newWeight - self.runNGunWeight;
		
		if ( abs( diff ) < runNGunTransitionPoint * 0.7 )
			self.runNGunWeight = newWeight;
		else if ( diff > 0 )
			self.runNGunWeight = self.runNGunWeight + runNGunIncrement;
		else
			self.runNGunWeight = self.runNGunWeight - runNGunIncrement;
	}

	InitRunNGun();
	
	absRunNGunWeight = abs( self.runNGunWeight );

	if ( absRunNGunWeight > runNGunTransitionPoint )
	{
		weight = ( absRunNGunWeight - runNGunTransitionPoint ) / runNGunTransitionPoint;
		weight = clamp( weight, 0, 1 );

		self clearanim( self.runNGunAnims[ "F" ], 0.2 );
		self setAnimLimited( self.runNGunAnims[ "L" ], ( 1.0 - weight ) * leftWeight, 0.2 );
		self setAnimLimited( self.runNGunAnims[ "R" ], ( 1.0 - weight ) * rightWeight, 0.2 );
		self setAnimLimited( self.runNGunAnims[ "LB" ], weight * leftWeight, 0.2 );
		self setAnimLimited( self.runNGunAnims[ "RB" ], weight * rightWeight, 0.2 );
	}
	else
	{
		weight = clamp( absRunNGunWeight / runNGunTransitionPoint, 0, 1 );

		self setAnimLimited( self.runNGunAnims[ "F" ], 1.0 - weight, 0.2 );
		self setAnimLimited( self.runNGunAnims[ "L" ], weight * leftWeight, 0.2 );
		self setAnimLimited( self.runNGunAnims[ "R" ], weight * rightWeight, 0.2 );
		
		if ( runNGunTransitionPoint < 1 )
		{
			self clearanim( self.runNGunAnims[ "LB" ], 0.2 );
			self clearanim( self.runNGunAnims[ "RB" ], 0.2 );
		}
	}

	self setFlaggedAnimKnob( "runanim", %run_n_gun, 1, 0.3, 0.8 );

	self.a.allowedPartialReloadOnTheRunTime = gettime() + 500;

	if ( validTarget && isplayer( self.enemy ) )
		self updatePlayerSightAccuracy();

	return true;
}

RunNGun_Backward()
{
	// we don't blend the running-backward animation because it
	// doesn't blend well with the run-left and run-right animations.
	// it's also easier to just play one animation than rework everything
	// to consider the possibility of multiple "backwards" animations

	InitRunNGun();

	self setFlaggedAnimKnob( "runanim", %combatwalk_B, 1, 0.3, 0.8 );

	if ( isplayer( self.enemy ) )
		self updatePlayerSightAccuracy();

	animscripts\shared::DoNoteTracksForTime( 0.2, "runanim" );

	self thread stopShootWhileMovingThreads();

	self clearAnim( %combatwalk_B, 0.2 );
}


ReactToBulletsInterruptCheck()
{
	self endon( "killanimscript" );
	
	while ( 1 )
	{
		wait 0.2;
			
		if ( !isdefined( self.reactingToBullet ) )
			break;
			
		if ( !isdefined( self.pathGoalPos ) || distanceSquared( self.pathGoalPos, self.origin ) < squared( 80 ) )
		{
			EndRunningReactToBullets();
			self notify( "interrupt_react_to_bullet" );
			break;			
		}
	}
}

EndRunningReactToBullets()
{
	self orientmode( "face default" );
	self.reactingToBullet = undefined;
	self.requestReactToBullet = undefined;
}

RunningReactToBullets()
{
	self.aim_while_moving_thread = undefined;
	self notify( "end_face_enemy_tracking" );

/#
	assert( !isdefined( self.trackLoopThread ) );
	self.trackLoopThread = undefined;
#/

	self endon( "interrupt_react_to_bullet" );

	self.reactingToBullet = true;
	self orientmode( "face motion" );

	reactAnimIndex = randomint( anim.runningReactToBullets.size );
	if ( reactAnimIndex == anim.lastRunningReactAnim )
		reactAnimIndex = ( reactAnimIndex + 1 ) % anim.runningReactToBullets.size;

	anim.lastRunningReactAnim = reactAnimIndex;
		
	reactAnim = anim.runningReactToBullets[ reactAnimIndex ];
	self setFlaggedAnimKnobRestart( "reactanim", reactAnim, 1, 0.5 );
	
	self thread ReactToBulletsInterruptCheck();
	self animscripts\shared::DoNoteTracks( "reactanim" );
	
	EndRunningReactToBullets();
}


CustomRunningReactToBullets()
{
	self.aim_while_moving_thread = undefined;
	self notify( "end_face_enemy_tracking" );

/#
	assert( !isdefined( self.trackLoopThread ) );
	self.trackLoopThread = undefined;
#/

	self.reactingToBullet = true;
	self orientmode( "face motion" );
	
	assert( isdefined( self.run_overrideBulletReact ) );

	reactAnimIndex = randomint( self.run_overrideBulletReact.size );
	reactAnim = self.run_overrideBulletReact[ reactAnimIndex ];

	self setFlaggedAnimKnobRestart( "reactanim", reactAnim, 1, 0.5 );
	self thread ReactToBulletsInterruptCheck();
	self animscripts\shared::DoNoteTracks( "reactanim" );
	
	EndRunningReactToBullets();
}


GetSprintAnim()
{
	sprintAnim = undefined;
	
	if ( isdefined( self.grenade ) )
		sprintAnim = moveAnim( "sprint_short" );

	if ( !isdefined( sprintAnim ) )
		sprintAnim = moveAnim( "sprint" );
		
	return sprintAnim;
}

ShouldSprint()
{
	if ( isdefined( self.sprint ) )
		return true;
		
	if ( isdefined( self.grenade ) && isdefined( self.enemy ) && self.frontShieldAngleCos == 1 )
		return ( distanceSquared( self.origin, self.enemy.origin ) > 300 * 300 );
		
	return false;
}


ShouldSprintForVariation()
{
	if ( isdefined( self.neverSprintForVariation ) )
		return false;
		
	if ( !self.faceMotion || self.stairsState != "none" )
		return false;
		
	time = gettime();
	
	if ( isdefined( self.dangerSprintTime ) )
	{
		if ( time < self.dangerSprintTime )
			return true;
		
		// if already sprinted, don't do it again for at least 5 seconds
		if ( time - self.dangerSprintTime < 6000 )
			return false;
	}

	if ( !isdefined( self.enemy ) || !isSentient( self.enemy ) )
		return false;
		
	if ( randomInt( 100 ) < 25 && ( self lastKnownTime( self.enemy ) + 2000 ) > time )
	{
		self.dangerSprintTime = time + 2000 + randomint( 1000 );
		return true;
	}
	
	return false;
}

GetMovePlaybackRate()
{
	rate = self.moveplaybackrate;
	
	if ( self.lookaheadHitsStairs && self.stairsState == "none" && self.lookaheadDist < 300 )
		rate *= 0.75;
		
	return rate;
}

MoveStandCombatNormal()
{
	//self clearanim( %walk_and_run_loops, 0.2 );

	rate = GetMovePlaybackRate();
		
	self setanimknob( %combatrun, 1.0, 0.5, rate );

	decidedAnimation = false;
	
	if ( isdefined( self.requestReactToBullet ) && gettime() - self.requestReactToBullet < 100 && randomFloat( 1 ) < self.a.reactToBulletChance )
	{
		StopRunNGun();
		RunningReactToBullets();
		return;
	}
	
	if ( self ShouldSprint() )
	{
		self setFlaggedAnimKnob( "runanim", GetSprintAnim(), 1, 0.5 );
		decidedAnimation = true;
	}
	else if ( isdefined( self.enemy ) && animscripts\move::MayShootWhileMoving() )
	{
		runShootWhileMovingThreads();

		if ( !self.faceMotion )
		{
			self thread faceEnemyAimTracking();
		}
		else if ( ( self.shootStyle != "none" && !isdefined( self.noRunNGun ) ) )
		{
			self notify( "end_face_enemy_tracking" );
			self.aim_while_moving_thread = undefined;

/#
			assert( !isdefined( self.trackLoopThread ) );
			self.trackLoopThread = undefined;
#/

			if ( CanShootWhileRunningForward() )
			{
				decidedAnimation = self RunNGun( true );
			}
			else if ( CanShootWhileRunningBackward() )
			{
				self RunNGun_Backward();
				return;
			}
		}
		else if ( isdefined( self.runNGunWeight ) && self.runNGunWeight != 0 )
		{
			// can't shoot enemy anymore but still need to clear out runNGun
			decidedAnimation = self RunNGun( false );
		}
	}
	else if ( isdefined( self.runNGunWeight ) && self.runNGunWeight != 0 )
	{
		decidedAnimation = self RunNGun( false );
	}

	if ( !decidedAnimation )
	{
		StopRunNGun();
	
		if ( isdefined( self.requestReactToBullet ) && gettime() - self.requestReactToBullet < 100 && self.a.reactToBulletChance != 0 )
		{
			RunningReactToBullets();
			return;
		}
		
		if ( ShouldSprintForVariation() )
			runAnim = moveAnim( "sprint_short" );
		else
			runAnim = GetRunAnim();
			
		self setFlaggedAnimKnobLimited( "runanim", runAnim, 1, 0.1, 1, true );
		self SetMoveNonForwardAnims( moveAnim( "move_b" ), moveAnim( "move_l" ), moveAnim( "move_r" ), self.sideStepRate );

		// Play the appropriately weighted run animations for the direction he's moving
		self thread SetCombatStandMoveAnimWeights( "run" );
	}

	animscripts\shared::DoNoteTracksForTime( 0.2, "runanim" );

	self thread stopShootWhileMovingThreads();
}

faceEnemyAimTracking()
{
	self notify( "want_aim_while_moving" );

	assert( isdefined( self.aim_while_moving_thread ) == isdefined( self.trackLoopThread ) );
	assertex( !isdefined( self.trackLoopThread ) || (self.trackLoopThreadType == "faceEnemyAimTracking"), self.trackLoopThreadType );

	if ( isdefined( self.aim_while_moving_thread ) )
		return;

	self.aim_while_moving_thread = true;

/#
	self.trackLoopThread = thisthread;
	self.trackLoopThreadType = "faceEnemyAimTracking";
#/

	self endon( "killanimscript" );
	self endon( "end_face_enemy_tracking" );

	self setDefaultAimLimits();

	self setAnimLimited( %walk_aim_2 );
	self setAnimLimited( %walk_aim_4 );
	self setAnimLimited( %walk_aim_6 );
	self setAnimLimited( %walk_aim_8 );

	self animscripts\shared::trackLoop( %w_aim_2, %w_aim_4, %w_aim_6, %w_aim_8 );
}

endFaceEnemyAimTracking()
{
	self.aim_while_moving_thread = undefined;
	self notify( "end_face_enemy_tracking" );

/#
	assert( !isdefined( self.trackLoopThread ) );
	self.trackLoopThread = undefined;
#/
}

runShootWhileMovingThreads()
{
	self notify( "want_shoot_while_moving" );

	if ( isdefined( self.shoot_while_moving_thread ) )
		return;
	self.shoot_while_moving_thread = true;

	self thread RunDecideWhatAndHowToShoot();
	self thread RunShootWhileMoving();
}

stopShootWhileMovingThreads()// we don't stop them if we shoot while moving again
{
	self endon( "killanimscript" );
	self endon( "want_shoot_while_moving" );
	self endon( "want_aim_while_moving" );

	wait .05;

	self notify( "end_shoot_while_moving" );
	self notify( "end_face_enemy_tracking" );
	self.shoot_while_moving_thread = undefined;
	self.aim_while_moving_thread = undefined;

/#
	assert( !isdefined( self.trackLoopThread ) );
	self.trackLoopThread = undefined;
#/

	self.runNGun = undefined;
}


RunDecideWhatAndHowToShoot()
{
	self endon( "killanimscript" );
	self endon( "end_shoot_while_moving" );
	self animscripts\shoot_behavior::decideWhatAndHowToShoot( "normal" );
}
RunShootWhileMoving()
{
	self endon( "killanimscript" );
	self endon( "end_shoot_while_moving" );
	self animscripts\move::shootWhileMoving();
}

aimedSomewhatAtEnemy()
{
	weaponAngles = self getMuzzleAngle();
	anglesToShootPos = vectorToAngles( self.enemy getShootAtPos() - self getMuzzlePos() );

	if ( AbsAngleClamp180( weaponAngles[ 1 ] - anglesToShootPos[ 1 ] ) > 15 )
		return false;

	return AbsAngleClamp180( weaponAngles[ 0 ] - anglesToShootPos[ 0 ] ) <= 20;
}

CanShootWhileRunningForward()
{
	// continue runNGun if runNGunWeight != 0
	if ( ( !isdefined( self.runNGunWeight ) || self.runNGunWeight == 0 ) && abs( self getMotionAngle() ) > self.maxRunNGunAngle )
		return false;

	return true;
}

CanShootWhileRunningBackward()
{
	if ( 180 - abs( self getMotionAngle() ) >= 45 )
		return false;

	enemyyaw = self GetPredictedYawToEnemy( 0.2 );
	if ( abs( enemyyaw ) > 30 )
		return false;

	return true;
}

CanShootWhileRunning()
{
	return animscripts\move::MayShootWhileMoving() && isdefined( self.enemy ) && ( CanShootWhileRunningForward() || CanShootWhileRunningBackward() );
}

GetPredictedYawToEnemy( lookAheadTime )
{
	assert( isdefined( self.enemy ) );

	selfPredictedPos = self.origin;
	moveAngle = self.angles[ 1 ] + self getMotionAngle();
	selfPredictedPos += ( cos( moveAngle ), sin( moveAngle ), 0 ) * length( self.velocity ) * lookAheadTime;

	yaw = self.angles[ 1 ] - VectorToYaw( self.enemy.origin - selfPredictedPos );
	yaw = AngleClamp180( yaw );
	return yaw;
}

MoveStandNoncombatNormal()
{
	self endon( "movemode" );

	self clearanim( %combatrun, 0.6 );

	rate = GetMovePlaybackRate();
	
	self setanimknoball( %combatrun, %body, 1, 0.2, rate );

	if ( self ShouldSprint() )
		runAnim = GetSprintAnim();
	else
		runAnim = GetRunAnim();

	if ( self.stairsState == "none" )
		transTime = 0.3;	// 0.3 because it pops when the AI goes from combat to noncombat
	else
		transTime = 0.1;	// need to transition to stairs quickly

	self setflaggedanimknob( "runanim", runAnim, 1, transTime, 1, true );

	self SetMoveNonForwardAnims( moveAnim( "move_b" ), moveAnim( "move_l" ), moveAnim( "move_r" ) );
	self thread SetCombatStandMoveAnimWeights( "run" );

	animscripts\shared::DoNoteTracksForTime( 0.2, "runanim" );
}

MoveCrouchRunOverride()
{
	self endon( "movemode" );

	self setflaggedanimknoball( "runanim", self.crouchrun_combatanim, %body, 1, 0.4, self.moveplaybackrate );
	animscripts\shared::DoNoteTracks( "runanim" );
}

MoveCrouchRunNormal()
{
	self endon( "movemode" );

	// Play the appropriately weighted crouchrun animations for the direction he's moving
	forward_anim = GetCrouchRunAnim();

	self setanimknob( forward_anim, 1, 0.4 );

	self thread UpdateMoveAnimWeights( "crouchrun", forward_anim, %crouch_fastwalk_B, %crouch_fastwalk_L, %crouch_fastwalk_R );

	self setflaggedanimknoball( "runanim", %crouchrun, %body, 1, 0.2, self.moveplaybackrate );

	animscripts\shared::DoNoteTracksForTime( 0.2, "runanim" );
}

ReloadStandRun()
{
	reloadIfEmpty = isdefined( self.a.allowedPartialReloadOnTheRunTime ) && self.a.allowedPartialReloadOnTheRunTime > gettime();
	reloadIfEmpty = reloadIfEmpty || ( isdefined( self.enemy ) && distanceSquared( self.origin, self.enemy.origin ) < 256 * 256 );
	if ( reloadIfEmpty )
	{
		if ( !self NeedToReload( 0 ) )
			return false;
	}
	else
	{
		if ( !self NeedToReload( .5 ) )
			return false;
	}

	if ( isdefined( self.grenade ) )
		return false;

	if ( !self.faceMotion || self.stairsState != "none" )
		return false;

	// if not allowed to shoot, not allowed to reload
	if ( isdefined( self.dontShootWhileMoving ) || isdefined( self.noRunReload ) )
		return false;

	if ( self CanShootWhileRunning() && !self NeedToReload( 0 ) )
		return false;

	if ( !isdefined( self.pathGoalPos ) || distanceSquared( self.origin, self.pathGoalPos ) < 256 * 256 )
		return false;

	motionAngle = AngleClamp180( self getMotionAngle() );

	// want to be running forward; otherwise we won't see the animation play!
	if ( abs( motionAngle ) > 25 )
		return false;

	if ( !usingRifleLikeWeapon() )
		return false;

	// need to restart the run cycle because the reload animation has to be played from start to finish!
	// the goal is to play it only when we're near the end of the run cycle.
	if ( !runLoopIsNearBeginning() )
		return false;

	// call in a separate function so we can cleanup if we get an endon
	ReloadStandRunInternal();

	// notify "abort_reload" in case the reload didn't finish, maybe due to "movemode" notify. works with handleDropClip() in shared.gsc
	self notify( "abort_reload" );

	self orientmode( "face default" );

	return true;
}

ReloadStandRunInternal()
{
	self endon( "movemode" );

	self orientmode( "face motion" );
	
	flagName = "reload_" + getUniqueFlagNameIndex();

	self setFlaggedAnimKnobAllRestart( flagName, %run_lowready_reload, %body, 1, 0.25 );

	self.update_move_front_bias	 = true;

	self SetMoveNonForwardAnims( moveAnim( "move_b" ), moveAnim( "move_l" ), moveAnim( "move_r" ) );
	self thread SetCombatStandMoveAnimWeights( "run" );
	animscripts\shared::DoNoteTracks( flagName );

	self.update_move_front_bias	 = undefined;
}

runLoopIsNearBeginning()
{
	// there are actually 3 loops (left foot, right foot) in one animation loop.

	animfraction = self getAnimTime( %walk_and_run_loops );
	loopLength = getAnimLength( %run_lowready_F ) / 3.0;
	animfraction *= 3.0;
	if ( animfraction > 3 )
		animfraction -= 2.0;
	else if ( animfraction > 2 )
		animfraction -= 1.0;

	if ( animfraction < .15 / loopLength )
		return true;
	if ( animfraction > 1 - .3 / loopLength )
		return true;

	return false;
}

SetMoveNonForwardAnims( backAnim, leftAnim, rightAnim, rate )
{
	if ( !isdefined( rate ) )
		rate = 1;
		
	self setAnimKnobLimited( backAnim, 1, 0.1, rate, true );
	self setAnimKnobLimited( leftAnim, 1, 0.1, rate, true );
	self setAnimKnobLimited( rightAnim, 1, 0.1, rate, true );
}

SetCombatStandMoveAnimWeights( moveAnimType )
{
	UpdateMoveAnimWeights( moveAnimType, %combatrun_forward, %combatrun_backward, %combatrun_left, %combatrun_right );
}

UpdateMoveAnimWeights( moveAnimType, frontAnim, backAnim, leftAnim, rightAnim )
{
	if ( isdefined( self.update_move_anim_type ) && self.update_move_anim_type == moveAnimType )
		return;

	self notify( "stop_move_anim_update" );

	self.update_move_anim_type = moveAnimType;
	self.wasFacingMotion = undefined;

	self endon( "killanimscript" );
	self endon( "move_interrupt" );
	self endon( "stop_move_anim_update" );

	for ( ;; )
	{
		UpdateRunWeightsOnce( frontAnim, backAnim, leftAnim, rightAnim );
		wait .05;
		waittillframeend;
	}
}

UpdateRunWeightsOnce( frontAnim, backAnim, leftAnim, rightAnim )
{
	//assert( !isdefined( self.runNGun ) || isdefined( self.update_move_front_bias ) );

	if ( self.faceMotion && !self shouldCQB() && !isdefined( self.update_move_front_bias ) )
	{
		// once you start to face motion, don't need to change weights
		if ( !isdefined( self.wasFacingMotion ) )
		{
			self.wasFacingMotion = 1;
			self setanim( frontAnim, 1, 0.2, 1, true );
			self setanim( backAnim, 0, 0.2, 1, true );
			self setanim( leftAnim, 0, 0.2, 1, true );
			self setanim( rightAnim, 0, 0.2, 1, true );
		}
	}
	else
	{
		self.wasFacingMotion = undefined;

		// Play the appropriately weighted animations for the direction he's moving.
	    animWeights = animscripts\utility::QuadrantAnimWeights( self getMotionAngle() );

    	if ( isdefined( self.update_move_front_bias ) )
		{
			animWeights[ "back" ] = 0.0;
			if ( animWeights[ "front" ] < .2 )
				animWeights[ "front" ] = .2;
		}

	    self setanim( frontAnim, animWeights[ "front" ], 0.2, 1, true );
	    self setanim( backAnim, animWeights[ "back" ], 0.2, 1, true );
	    self setanim( leftAnim, animWeights[ "left" ], 0.2, 1, true );
	    self setanim( rightAnim, animWeights[ "right" ], 0.2, 1, true );
	}
}


// change our weapon while running if we want to and can
changeWeaponStandRun()
{
	// right now this only handles shotguns, but it could do other things too
	wantShotgun = ( isdefined( self.wantShotgun ) && self.wantShotgun );
	usingShotgun = isShotgun( self.weapon );
	if ( wantShotgun == usingShotgun )
		return false;

	if ( !isdefined( self.pathGoalPos ) || distanceSquared( self.origin, self.pathGoalPos ) < 256 * 256 )
		return false;

	if ( usingSidearm() )
		return false;
	assert( self.weapon == self.primaryweapon || self.weapon == self.secondaryweapon );

	if ( self.weapon == self.primaryweapon )
	{
		if ( !wantShotgun )
			return false;
		if ( isShotgun( self.secondaryweapon ) )
			return false;
	}
	else
	{
		assert( self.weapon == self.secondaryweapon );

		if ( wantShotgun )
			return false;
		if ( isShotgun( self.primaryweapon ) )
			return false;
	}

	// want to be running forward; otherwise we won't see the animation play!
	motionAngle = AngleClamp180( self getMotionAngle() );
	if ( abs( motionAngle ) > 25 )
		return false;

	if ( !runLoopIsNearBeginning() )
		return false;

	if ( wantShotgun )
		shotgunSwitchStandRunInternal( "shotgunPullout", %shotgun_CQBrun_pullout, "gun_2_chest", "none", self.secondaryweapon, "shotgun_pickup" );
	else
		shotgunSwitchStandRunInternal( "shotgunPutaway", %shotgun_CQBrun_putaway, "gun_2_back", "back", self.primaryweapon, "shotgun_pickup" );

	self notify( "switchEnded" );

	return true;
}

shotgunSwitchStandRunInternal( flagName, switchAnim, dropGunNotetrack, putGunOnTag, newGun, pickupNewGunNotetrack )
{
	self endon( "movemode" );

	self setFlaggedAnimKnobAllRestart( flagName, switchAnim, %body, 1, 0.25 );

	self.update_move_front_bias = true;

	self SetMoveNonForwardAnims( moveAnim( "move_b" ), moveAnim( "move_l" ), moveAnim( "move_r" ) );
	self thread SetCombatStandMoveAnimWeights( "run" );

	self thread watchShotgunSwitchNotetracks( flagName, dropGunNotetrack, putGunOnTag, newGun, pickupNewGunNotetrack );

	animscripts\shared::DoNoteTracksForTimeIntercept( getAnimLength( switchAnim ) - 0.25, flagName, ::interceptNotetracksForWeaponSwitch );

	self.update_move_front_bias = undefined;
}

interceptNotetracksForWeaponSwitch( notetrack )
{
	if ( notetrack == "gun_2_chest" || notetrack == "gun_2_back" )
		return true;// "don't do the default behavior for this notetrack"
}

watchShotgunSwitchNotetracks( flagName, dropGunNotetrack, putGunOnTag, newGun, pickupNewGunNotetrack )
{
	self endon( "killanimscript" );
	self endon( "movemode" );
	self endon( "switchEnded" );

	self waittillmatch( flagName, dropGunNotetrack );

	animscripts\shared::placeWeaponOn( self.weapon, putGunOnTag );
	self thread shotgunSwitchFinish( newGun );

	self waittillmatch( flagName, pickupNewGunNotetrack );
	self notify( "complete_weapon_switch" );
}

shotgunSwitchFinish( newGun )
{
	self endon( "death" );

	self waittill_any( "killanimscript", "movemode", "switchEnded", "complete_weapon_switch" );

	self.lastweapon = self.weapon;

	animscripts\shared::placeWeaponOn( newGun, "right" );
	assert( self.weapon == newGun );// placeWeaponOn should have handled this

	// reset ammo (assume fully loaded weapon)
	self.bulletsInClip = weaponClipSize( self.weapon );
}

