#include animscripts\utility;
#include animscripts\combat_utility;
#include animscripts\shared;
#include common_scripts\utility;
#using_animtree( "generic_human" );

MoveCQB()
{
	animscripts\run::changeWeaponStandRun();

	// any endons in this function must also be in CQBShootWhileMoving and CQBDecideWhatAndHowToShoot

	if ( self.a.pose != "stand" )
	{
		// (get rid of any prone or other stuff that might be going on)
		self clearAnim( %root, 0.2 );
		if ( self.a.pose == "prone" )
			self ExitProneWrapper( 1 );
		self.a.pose = "stand";
	}
	self.a.movement = self.moveMode;

	//self clearanim(%combatrun, 0.2);

	self thread CQBTracking();

	cqbWalkAnim = DetermineCQBAnim();

	rate = self.moveplaybackrate;

	if ( self.moveMode == "walk" )
		rate *= 0.6;

	if ( self.stairsState == "none" )
		transTime = 0.3;
	else
		transTime = 0.1;	// need to transition to stairs quickly

	// (we don't use %body because that would reset the aiming knobs)
	self setFlaggedAnimKnobAll( "runanim", cqbWalkAnim, %walk_and_run_loops, 1, transTime, rate, true );

	self animscripts\run::SetMoveNonForwardAnims( %walk_backward, %walk_left, %walk_right );
	self thread animscripts\run::SetCombatStandMoveAnimWeights( "cqb" );

	animscripts\shared::DoNoteTracksForTime( 0.2, "runanim" );

	self thread animscripts\run::stopShootWhileMovingThreads();
}

DetermineCQBAnim()
{
	if ( isdefined( self.customMoveAnimSet ) && isdefined( self.customMoveAnimSet[ "cqb" ] ) )
		return animscripts\run::GetRunAnim();

	if ( self.stairsState == "up" )
		return %traverse_stair_run;

	if ( self.stairsState == "down" )
		return %traverse_stair_run_down_01;

	if ( self.movemode == "walk" )
		return %walk_CQB_F;

	variation = getRandomIntFromSeed( self.a.runLoopCount, 2 );
	if ( variation == 0 )
		return %run_CQB_F_search_v1;

	return %run_CQB_F_search_v2;
}

CQBTracking()
{
	assert( isdefined( self.aim_while_moving_thread ) == isdefined( self.trackLoopThread ) );
	assertex( !isdefined( self.trackLoopThread ) || (self.trackLoopThreadType == "faceEnemyAimTracking"), self.trackLoopThreadType );

	if ( animscripts\move::MayShootWhileMoving() )
		animscripts\run::runShootWhileMovingThreads();

	animscripts\run::faceEnemyAimTracking();
}

setupCQBPointsOfInterest()
{
	level.cqbPointsOfInterest = [];
	pointents = getEntArray( "cqb_point_of_interest", "targetname" );
	for ( i = 0; i < pointents.size; i++ )
	{
		level.cqbPointsOfInterest[ i ] = pointents[ i ].origin;
		pointents[ i ] delete();
	}
}

findCQBPointsOfInterest()
{
	if ( isdefined( anim.findingCQBPointsOfInterest ) )
		return;
	anim.findingCQBPointsOfInterest = true;

	// one AI per frame, find best point of interest.
	if ( !level.cqbPointsOfInterest.size )
		return;

	while ( 1 )
	{
		ai = getaiarray();
		waited = false;
		foreach( guy in ai )
		{
			if ( isAlive( guy ) && guy isCQBWalking() )
			{
				moving = ( guy.a.movement != "stop" );
				
				// if you change this, change the debug function below too
				
				shootAtPos = (guy.origin[0], guy.origin[1], guy getShootAtPos()[2]);
				lookAheadPoint = shootAtPos;
				forward = anglesToForward( guy.angles );
				if ( moving )
				{
					trace = bulletTrace( lookAheadPoint, lookAheadPoint + forward * 128, false, undefined );
					lookAheadPoint = trace[ "position" ];
				}

				best = -1;
				bestdist = 1024 * 1024;
				for ( j = 0; j < level.cqbPointsOfInterest.size; j++ )
				{
					point = level.cqbPointsOfInterest[ j ];

					dist = distanceSquared( point, lookAheadPoint );
					if ( dist < bestdist )
					{
						if ( moving )
						{
							if ( distanceSquared( point, shootAtPos ) < 64 * 64 )
								continue;
							dot = vectorDot( vectorNormalize( point - shootAtPos ), forward );
							if ( dot < 0.643 || dot > 0.966 )// 0.643 = cos( 50 ), 0.966 = cos( 15 )
								continue;
						}
						else
						{
							if ( dist < 50 * 50 )
								continue;
						}

						if ( !sightTracePassed( lookAheadPoint, point, false, undefined ) )
							continue;

						bestdist = dist;
						best = j;
					}
				}

				if ( best < 0 )
					guy.cqb_point_of_interest = undefined;
				else
					guy.cqb_point_of_interest = level.cqbPointsOfInterest[ best ];

				wait .05;
				waited = true;
			}
		}
		if ( !waited )
			wait .25;
	}
}

 /#
CQBDebug()
{
	self notify( "end_cqb_debug" );
	self endon( "end_cqb_debug" );
	self endon( "death" );

	setDvarIfUninitialized( "scr_cqbdebug", "off" );

	level thread CQBDebugGlobal();

	while ( 1 )
	{
		if ( getdebugdvar( "scr_cqbdebug" ) == "on" || getdebugdvarint( "scr_cqbdebug" ) == self getentnum() )
		{
			shootAtPos = (self.origin[0], self.origin[1], self getShootAtPos()[2]);
			if ( isdefined( self.shootPos ) )
			{
				line( shootAtPos, self.shootPos, ( 1, 1, 1 ) );
				print3d( self.shootPos, "shootPos", ( 1, 1, 1 ), 1, 0.5 );
			}
			else if ( isdefined( self.cqb_target ) )
			{
				line( shootAtPos, self.cqb_target.origin, ( .5, 1, .5 ) );
				print3d( self.cqb_target.origin, "cqb_target", ( .5, 1, .5 ), 1, 0.5 );
			}
			else
			{
				moving = ( self.a.movement != "stop" );

				forward = anglesToForward( self.angles );
				lookAheadPoint = shootAtPos;
				if ( moving )
				{
					lookAheadPoint += forward * 128;
					line( shootAtPos, lookAheadPoint, ( 0.7, .5, .5 ) );

					right = anglesToRight( self.angles );
					leftScanArea  = shootAtPos + ( forward * 0.643 - right ) * 64;
					rightScanArea = shootAtPos + ( forward * 0.643 + right ) * 64;
					line( shootAtPos, leftScanArea, ( 0.5, 0.5, 0.5 ), 0.7 );
					line( shootAtPos, rightScanArea, ( 0.5, 0.5, 0.5 ), 0.7 );
				}

				if ( isdefined( self.cqb_point_of_interest ) )
				{
					line( lookAheadPoint, self.cqb_point_of_interest, ( 1, .5, .5 ) );
					print3d( self.cqb_point_of_interest, "cqb_point_of_interest", ( 1, .5, .5 ), 1, 0.5 );
				}
			}

			wait .05;
			continue;
		}

		wait 1;
	}
}

CQBDebugGlobal()
{
	if ( isdefined( level.cqbdebugglobal ) )
		return;
	level.cqbdebugglobal = true;

	while ( 1 )
	{
		if ( getdebugdvar( "scr_cqbdebug" ) != "on" )
		{
			wait 1;
			continue;
		}

		for ( i = 0; i < level.cqbPointsOfInterest.size; i++ )
		{
			print3d( level.cqbPointsOfInterest[ i ], ".", ( .7, .7, 1 ), .7, 3 );
		}

		wait .05;
	}
}
#/

