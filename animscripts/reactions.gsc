#include animscripts\SetPoseMovement;
#include animscripts\Utility;
#include common_scripts\Utility;
#using_animtree( "generic_human" );

main()
{
	self endon( "killanimscript" );
	animscripts\utility::initialize( "reactions" );
	
	self newEnemySurprisedReaction();
}


initReactionAnims()
{
	anim.runningReactToBullets = [];
	anim.runningReactToBullets[ anim.runningReactToBullets.size ] = %run_react_duck;
	anim.runningReactToBullets[ anim.runningReactToBullets.size ] = %run_react_flinch;
	anim.runningReactToBullets[ anim.runningReactToBullets.size ] = %run_react_stumble;	
	
	anim.lastRunningReactAnim = 0;


	anim.coverReactions = [];
	anim.coverReactions[ "cover_stand" ]	= array( %stand_cover_reaction_A, %stand_cover_reaction_B );
	anim.coverReactions[ "cover_crouch" ]	= array( %crouch_cover_reaction_A, %crouch_cover_reaction_B );
	anim.coverReactions[ "cover_left" ]		= array( %CornerStndL_react_A );
	anim.coverReactions[ "cover_right" ]	= array( %CornerStndR_react_A );
}


///////////////////////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////////////////////
reactionsCheckLoop()
{	
	self thread bulletWhizbyCheckLoop();
}


///////////////////////////////////////////////////////////////////////////
// death reactions
///////////////////////////////////////////////////////////////////////////
/* disabled for now since the animations aren't in common csv

MoveDeathReaction()
{
	// Decide what pose to use
	desiredPose = self animscripts\utility::choosePose();
    
    if ( desiredPose == "stand" )
	{
		deathAnim = getDeathReactionAnim();
		DoDeathReactionAnim( deathAnim );
	}
}

ExposedCombatDeathReaction()
{
	// Decide what pose to use
	desiredPose = self animscripts\utility::choosePose();
    
    if ( desiredPose == "stand" )
	{
		deathAnim = getDeathReactionAnim();
		DoDeathReactionAnim( deathAnim );
	}
}

DoDeathReactionAnim( deathAnim )
{
	self endon( "movemode" );

	rate = self.moveplaybackrate;

	self setFlaggedAnimKnobAll( "deathanim", deathAnim, %body, 1, 1, rate, true );

//	self animscripts\run::SetMoveNonForwardAnims( %walk_backward, %walk_left, %walk_right );
//	self thread animscripts\run::SetCombatStandMoveAnimWeights( "walk" );

	self animscripts\shared::DoNoteTracks( "deathanim" );
	self.deathTeamate = false;
}

getDeathReactionAnim()
{
    if ( self.deathTeamateReaction == "back" )
        return %run_reaction_180;
    else if ( self.deathTeamateReaction == "left" )
        return %run_reaction_L_quick;
    else if ( self.deathTeamateReaction == "right" )
        return %run_reaction_R_quick;
}

deathCheck()
{
	self endon( "killanimscript" );
	
    self.deathTeamateReaction = "none";
    self.deathTeamate = false;

	minDeathDistance = 100;
	maxDeathDistance = 500;
	minGoalDistance = 200;
	maxTurnAngle = 135;
	minTurnAngle = 10;
	
    self AddAIEventListener( "death" );

	for ( ;; )
	{
	    self waittill( "ai_event", event, originator, position );
	    if ( event != "death" )
			continue;
			
	    deathDirection = position - self.origin;
	    deathDistance = Length( deathDirection );
	    if ( deathDistance >= minDeathDistance && deathDistance <= maxDeathDistance )
	    {
    	    goalDirection = self.goalpos - self.origin;
    	    goalDistance = Length( goalDirection );
    	    if ( goalDistance >= minGoalDistance )
    	    {
        	    goalAngles = VectorToAngles( goalDirection );
        	    deltaAngles = Abs( self.angles[1] - goalAngles[1] );
        	    if ( deltaAngles > minTurnAngle )
        	    {
            	    if ( deltaAngles > maxTurnAngle )
            	        self.deathTeamateReaction = "back";
            	    else if ( self.angles[1] > goalAngles[1] )
            	        self.deathTeamateReaction = "left";
            	    else
            	        self.deathTeamateReaction = "right";
            	    
            	    self.deathTeamate = true;
        	    }
    	    }
	    }
	}
}

*/

canReactAgain()
{
	return ( !isdefined( self.lastReactTime ) || gettime() - self.lastReactTime > 2000 );
}

///////////////////////////////////////////////////////////////////////////
// bullet whizby reaction
///////////////////////////////////////////////////////////////////////////

bulletWhizbyReaction()
{
	self endon( "killanimscript" );

	self.lastReactTime = gettime();
	self.a.movement = "stop";
	
	enemyNear = ( isDefined( self.whizbyEnemy ) && distanceSquared( self.origin, self.whizbyEnemy.origin ) < 400 * 400 );

	self animmode( "gravity" );		
	self orientmode( "face current" );

	// react and go to prone
	if ( enemyNear || cointoss() )
	{
		self clearanim( %root, 0.1 );

		reactAnim = [];
		reactAnim[ 0 ] = %exposed_idle_reactA;
		reactAnim[ 1 ] = %exposed_idle_reactB;
		reactAnim[ 2 ] = %exposed_idle_twitch;
		reactAnim[ 3 ] = %exposed_idle_twitch_v4;

		reaction = reactAnim[ randomint( reactAnim.size ) ];

		if ( enemyNear )
			waitTime = 1 + randomfloat( 0.5 );
		else
			waitTime = 0.2 + randomfloat( 0.5 );

		self setFlaggedAnimKnobRestart( "reactanim", reaction, 1, 0.1, 1 );
		self animscripts\shared::DoNoteTracksForTime( waitTime, "reactanim" );

		self clearanim( %root, 0.1 );
		
		if ( !enemyNear && self.stairsState == "none" )
		{
			rate = 1 + randomfloat( 0.2 );
		
			diveAnim = randomAnimOfTwo( %exposed_dive_grenade_B, %exposed_dive_grenade_F );

			self setFlaggedAnimKnobRestart( "dive", diveAnim, 1, 0.1, rate );
			self animscripts\shared::DoNoteTracks( "dive" );
		}
	}
	else	// crouch then handsignal or turn
	{
		wait randomfloat( 0.2 );
		
		rate = 1.2 + randomfloat( 0.3 );
		
		if ( self.a.pose == "stand" )
		{
			self clearanim( %root, 0.1 );
			self setFlaggedAnimKnobRestart( "crouch", %exposed_stand_2_crouch, 1, 0.1, rate );
			self animscripts\shared::DoNoteTracks( "crouch" );
		}

		forward = anglesToForward( self.angles );

		if ( isDefined( self.whizbyEnemy ) )
			dirToEnemy = vectorNormalize( self.whizbyEnemy.origin - self.origin );
		else
			dirToEnemy = forward;

		if ( vectordot( dirToEnemy, forward ) > 0 )
		{
			twitchAnim = randomAnimOfTwo( %exposed_crouch_idle_twitch_v2, %exposed_crouch_idle_twitch_v3 );
		
			self clearanim( %root, 0.1 );
			self setFlaggedAnimKnobRestart( "twitch", twitchAnim, 1, 0.1, 1 );
			self animscripts\shared::DoNoteTracks( "twitch" );			
			
			//if ( cointoss() )
			//	self handsignal( "go" );
		}
		else
		{
			turnAnim = randomAnimOfTwo( %exposed_crouch_turn_180_left, %exposed_crouch_turn_180_right );
			
			self clearanim( %root, 0.1 );
			self setFlaggedAnimKnobRestart( "turn", turnAnim, 1, 0.1, 1 );
			self animscripts\shared::DoNoteTracks( "turn" );
		}
	}
	
	self clearanim( %root, 0.1 );
	self.whizbyEnemy = undefined;
	self animmode( "normal" );
	self orientmode( "face default" );		
}


bulletWhizbyCheckLoop()
{
	self endon( "killanimscript" );
	
	if ( isdefined( self.disableBulletWhizbyReaction ) )
		return;

	while ( 1 )
	{
		self waittill( "bulletwhizby", shooter );

		if ( !isdefined( shooter.team ) || self.team == shooter.team )
			continue;
			
		if ( isdefined( self.coverNode ) || isdefined( self.ambushNode ) )
			continue;
			
		if ( self.a.pose != "stand" )
			continue;

		if ( !canReactAgain() )
			continue;
			
		self.whizbyEnemy = shooter;
		self animcustom( ::bulletWhizbyReaction );
	}
}


///////////////////////////////////////////////////////////////////////////
// surprised by new enemy reaction
///////////////////////////////////////////////////////////////////////////

clearLookAtThread()
{
	self endon( "killanimscript" );

	wait 0.3;
	self setLookAtEntity();
}


getNewEnemyReactionAnim()
{
	reactAnim = undefined;
	
	if ( self nearClaimNodeAndAngle() && isdefined( anim.coverReactions[ self.prevScript ] ) )
	{
		nodeForward = anglesToForward( self.node.angles );
		dirToReactionTarget = vectorNormalize( self.reactionTargetPos - self.origin );
		
		if ( vectorDot( nodeForward, dirToReactionTarget ) < -0.5 )
		{
			self orientmode( "face current" );
			index = randomint( anim.coverReactions[ self.prevScript ].size );
			reactAnim = anim.coverReactions[ self.prevScript ][ index ];
		}
	}
	
	if ( !isdefined( reactAnim ) )
	{
		reactAnimArray = [];
		reactAnimArray[ 0 ] = %exposed_backpedal;
		reactAnimArray[ 1 ] = %exposed_idle_reactB;

		if ( isdefined( self.enemy ) && distanceSquared( self.enemy.origin, self.reactionTargetPos ) < 256 * 256 )
			self orientmode( "face enemy" );
		else
			self orientmode( "face point", self.reactionTargetPos );

		if ( self.a.pose == "crouch" )
		{
			dirToReactionTarget = vectorNormalize( self.reactionTargetPos - self.origin );
			forward = anglesToForward( self.angles );
			if ( vectorDot( forward, dirToReactionTarget ) < -0.5 )
			{
				self orientmode( "face current" );
				reactAnimArray[ 0 ] = %crouch_cover_reaction_A;
				reactAnimArray[ 1 ] = %crouch_cover_reaction_B;
			}
		}

		reactAnim = reactAnimArray[ randomint( reactAnimArray.size ) ];
	}

	return reactAnim;
}


stealthNewEnemyReactAnim()
{
	self clearanim( %root, 0.2 );

	if ( randomint( 4 ) < 3 )
	{
		self orientmode( "face enemy" );
		self setFlaggedAnimKnobRestart( "reactanim", %exposed_idle_reactB, 1, 0.2, 1 );
		time = getAnimLength( %exposed_idle_reactB );
		self animscripts\shared::DoNoteTracksForTime( time * 0.8, "reactanim" );	

		self orientmode( "face current" );
	}
	else
	{
		self orientmode( "face enemy" );
		self setFlaggedAnimKnobRestart( "reactanim", %exposed_backpedal, 1, 0.2, 1 );
		time = getAnimLength( %exposed_backpedal );
		self animscripts\shared::DoNoteTracksForTime( time * 0.8, "reactanim" );	

		self orientmode( "face current" );

		self clearanim( %root, 0.2 );
		self setFlaggedAnimKnobRestart( "reactanim", %exposed_backpedal_v2, 1, 0.2, 1 );
		self animscripts\shared::DoNoteTracks( "reactanim" );	
	}
}


newEnemyReactionAnim()
{
	self endon( "death" );
	self endon( "endNewEnemyReactionAnim" );
	
	self.lastReactTime = gettime();
	self.a.movement = "stop";
	
	if ( isdefined( self._stealth ) && self.alertLevel != "combat" )
	{
		stealthNewEnemyReactAnim();
	}
	else
	{
		reactAnim = self getNewEnemyReactionAnim();
	
		self clearanim( %root, 0.2 );
		self setFlaggedAnimKnobRestart( "reactanim", reactAnim, 1, 0.2, 1 );
		self animscripts\shared::DoNoteTracks( "reactanim" );
	}

	self notify( "newEnemyReactionDone" );
}


newEnemySurprisedReaction()
{
	self endon( "death" );
	
	if ( isdefined( self.disableReactionAnims ) )
		return;		

	if ( !canReactAgain() )
		return;
		
	if ( self.a.pose == "prone" || isdefined( self.a.onback ) )
		return;

	self animmode( "gravity" );
	
	if ( isdefined( self.enemy ) )
		newEnemyReactionAnim();
}
