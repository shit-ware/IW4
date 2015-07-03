#include maps\_utility;
#include animscripts\utility;
#include common_scripts\utility;

#using_animtree( "dog" );

main()
{
	self endon( "killanimscript" );
	// self endon( "movemode" );

	self clearanim( %root, 0.2 );
	self clearanim( %german_shepherd_run_stop, 0 );

	if ( !isdefined( self.traverseComplete ) && !isdefined( self.skipStartMove ) && self.a.movement == "run" && ( !isdefined( self.disableExits ) || self.disableExits == false ) )
		self startMove();

	self thread randomSoundDuringRunLoop();

	self.traverseComplete = undefined;
	self.skipStartMove = undefined;

	if ( self.a.movement == "run" )
	{
		weights = undefined;
		weights = self getRunAnimWeights();

		self setanimrestart( %german_shepherd_run, weights[ "center" ], 0.2, 1 );
		self setanimrestart( %german_shepherd_run_lean_L, weights[ "left" ], 0.1, 1 );
		self setanimrestart( %german_shepherd_run_lean_R, weights[ "right" ], 0.1, 1 );
		self setflaggedanimknob( "dog_run", %german_shepherd_run_knob, 1, 0.2, self.moveplaybackrate );
		animscripts\shared::DoNoteTracksForTime( 0.1, "dog_run" );
	}
	else
	{
		self setflaggedanimrestart( "dog_walk", %german_shepherd_walk, 1, 0.2, self.moveplaybackrate );
	}

	//self thread animscripts\dog\dog_stop::lookAtTarget( "normal" );
	self thread pathChangeCheck();

	while ( 1 )
	{
		self moveLoop();

		if ( self.a.movement == "run" )
		{
			if ( self.disableArrivals == false )
				self thread stopMove();

			// if a "run" notify is received while stopping, clear stop anim and go back to moveLoop
			self waittill( "run" );
			self clearanim( %german_shepherd_run_stop, 0.1 );
		}
	}
}


moveLoop()
{
	self endon( "killanimscript" );
	self endon( "stop_soon" );

	self.moveLoopCleanupFunc = undefined;

	while ( 1 )
	{
		if ( self.disableArrivals )
			self.stopAnimDistSq = 0;
		else
			self.stopAnimDistSq = anim.dogStoppingDistSq;

		if ( isDefined( self.moveLoopCleanupFunc ) )
		{
			self [[self.moveLoopCleanupFunc]]();
			self.moveLoopCleanupFunc = undefined;
		}			
			
		if ( isdefined( self.moveLoopOverrideFunc ) )
			self [[ self.moveLoopOverrideFunc ]]();
		else
			self moveLoopStep();
	}
}

moveLoopStep()
{
	self endon( "move_loop_restart" );
	
	if ( self.a.movement == "run" )
	{
		weights = self getRunAnimWeights();

		self clearanim( %german_shepherd_walk, 0.3 );

		self setanim( %german_shepherd_run, weights[ "center" ], 0.2, 1 );
		self setanim( %german_shepherd_run_lean_L, weights[ "left" ], 0.2, 1 );
		self setanim( %german_shepherd_run_lean_R, weights[ "right" ], 0.2, 1 );
		self setflaggedanimknob( "dog_run", %german_shepherd_run_knob, 1, 0.2, self.moveplaybackrate );

		animscripts\shared::DoNoteTracksForTime( 0.2, "dog_run" );
	}
	else
	{
		assert( self.a.movement == "walk" );

		self clearanim( %german_shepherd_run_knob, 0.3 );
		self setflaggedanim( "dog_walk", %german_shepherd_walk, 1, 0.2, self.moveplaybackrate );
		animscripts\shared::DoNoteTracksForTime( 0.2, "dog_walk" );
	}
}

pathChangeCheck()
{
	self endon( "killanimscript" );

	self.ignorePathChange = undefined;	// this will be turned on / off in other threads at appropriate times

	while ( 1 )
	{
		// no other thread should end on "path_changed"
		self waittill( "path_changed", doingReacquire, newDir );

		// no need to check for doingReacquire since faceMotion should be a good check
		if ( isdefined( self.ignorePathChange ) || isdefined( self.noTurnAnims ) )
			continue;
			
		if ( self.a.movement != "run" )
			continue;

		angleDiff = AngleClamp180( self.angles[ 1 ] - vectortoyaw( newDir ) );

		turnAnim = pathChange_getDogTurnAnim( angleDiff );
			
		if ( isdefined( turnAnim ) )
		{
			self.turnAnim = turnAnim;
			self.turnTime = getTime();
			self.moveLoopOverrideFunc = ::pathChange_doDogTurnAnim;
			
			self notify( "move_loop_restart" );
		}
	}
}


pathChange_getDogTurnAnim( angleDiff )
{
	turnAnim = undefined;
	
	if ( angleDiff < -135 )
	{
		turnAnim = %german_shepherd_run_start_180_L;
	}
	else if ( angleDiff > 135 )
	{
		turnAnim = %german_shepherd_run_start_180_R;
	}
	
	return turnAnim;
}


pathChange_doDogTurnAnim()
{
	self endon( "killanimscript" );
	
	self.moveLoopOverrideFunc = undefined;
	
	turnAnim = self.turnAnim;
	
	if ( gettime() > self.turnTime + 50 )
		return; // too late
	
	self animMode( "zonly_physics", false );
	self clearanim( %root, 0.2 );
	
	self.moveLoopCleanupFunc = ::pathChange_cleanupDogTurnAnim;
	
	self.ignorePathChange = true;
		
	self setflaggedanimrestart( "turnAnim", turnAnim, 1, 0.2, self.movePlaybackRate );
	self OrientMode( "face current" );

	// code move at 60%
	playTime = getanimlength( turnAnim ) * self.movePlaybackRate;
	self animscripts\shared::DoNoteTracksForTime( playTime * 0.60, "turnAnim" );

	self.ignorePathChange = undefined;
	self OrientMode( "face motion" );	// want to face motion, don't do l / r / b anims
	self animmode( "none", false );

	// cut off at 85%
	self animscripts\shared::DoNoteTracksForTime( playTime * 0.25, "turnAnim" );
}

pathChange_cleanupDogTurnAnim()
{
	self.ignorePathChange = undefined;
	
	self OrientMode( "face default" );
	self clearanim( %root, 0.2 );
	self animMode( "none", false );
}

startMoveTrackLookAhead()
{
	self endon( "killanimscript" );
	for ( i = 0; i < 2; i++ )
	{
		lookaheadAngle = vectortoangles( self.lookaheaddir );
		self OrientMode( "face angle", lookaheadAngle );
	}
}

playMoveStartAnim()
{
	endPos = self.origin;
	endPos += vector_multiply( self.lookaheaddir, anim.dogStartMoveDist );

	tooClose = distanceSquared( self.origin, self.pathgoalpos ) < anim.dogStartMoveDist * anim.dogStartMoveDist;

	if ( !tooClose && self mayMoveToPoint( endPos ) )
	{
		lookaheadAngle = vectortoangles( self.lookaheaddir );
		angle = AngleClamp180( lookaheadAngle[ 1 ] - self.angles[ 1 ] );
	
		if ( angle >= 0 )
		{
			if ( angle < 45 )
				index = 8;
			else if ( angle < 135 )
				index = 6;
			else
				index = 3;
		}
		else
		{
			if ( angle > -45 )
				index = 8;
			else if ( angle > -135 )
				index = 4;
			else
				index = 1;
		}

		self setanimrestart( anim.dogStartMoveAnim[ index ], 1, 0.2, 1 );

		animEndAngle = self.angles[ 1 ] + anim.dogStartMoveAngles[ index ];
		offsetAngle = AngleClamp180( lookaheadAngle[ 1 ] - animEndAngle );
		
		self OrientMode( "face angle", self.angles[ 1 ] + offsetAngle );
		self animMode( "zonly_physics", false );
		
		// code move at 60%
		playTime = getanimlength( anim.dogStartMoveAnim[ index ] ) * self.movePlaybackRate;
		self animscripts\shared::DoNoteTracksForTime( playTime * 0.60, "turnAnim" );

		self OrientMode( "face motion" );	// want to face motion, don't do l / r / b anims
		self animmode( "none", false );

		// cut off at 85%
		self animscripts\shared::DoNoteTracksForTime( playTime * 0.25, "turnAnim" );
		

		self clearanim( %root, 0.2 );
	}
}

startMove()
{
	if ( isdefined( self.pathgoalpos ) )
	{
		wait 0.05; // wait for lookaheaddir to settle
		
		if ( isdefined( self.pathgoalpos ) )
		{
			self playMoveStartAnim();
			return;
		}
	}

	// just use code movement
	self OrientMode( "face default" );
	self setanimrestart( %german_shepherd_run_start, 1, 0.2, 1 );
	self setflaggedanimknobrestart( "dog_prerun", %german_shepherd_run_start_knob, 1, 0.2, self.moveplaybackrate );

	self animscripts\shared::DoNoteTracks( "dog_prerun" );

	self animMode( "none", false );
	
	self clearanim( %root, 0.2 );
}


stopMove()
{
	self endon( "killanimscript" );
	self endon( "run" );

	self clearanim( %german_shepherd_run_knob, 0.1 );
	self setflaggedanimrestart( "stop_anim", %german_shepherd_run_stop, 1, 0.2, 1 );
	self animscripts\shared::DoNoteTracks( "stop_anim" );
}


dogPlaySoundAndNotify( sound, notifyStr )
{
	self play_sound_on_tag_endon_death( sound, "tag_eye" );
	if ( isalive( self ) )
		self notify( notifyStr );
}

randomSoundDuringRunLoop()
{
	self endon( "killanimscript" );
	
	wait 0.2; // incase move script gets killed right away
	
	while ( 1 )
	{
/#
		if ( getdebugdvar( "debug_dog_sound" ) != "" )
			iprintln( "dog " + ( self getentnum() ) + " bark start " + getTime() );
#/
		sound = undefined;
		if ( isdefined( self.script_growl ) )
			sound = "anml_dog_growl";
		else if ( !isdefined( self.script_nobark ) )
			sound = "anml_dog_bark";
			
		if ( !isdefined( sound ) )
			break;
		
		self thread dogPlaySoundAndNotify( sound, "randomRunSound" );
		self waittill( "randomRunSound" );
/#
		if ( getdebugdvar( "debug_dog_sound" ) != "" )
			iprintln( "dog " + ( self getentnum() ) + " bark end " + getTime() );
#/

		wait( randomfloatrange( 0.1, 0.3 ) );
	}
}


getRunAnimWeights()
{
	weights = [];
	weights[ "center" ] = 0;
	weights[ "left" ] = 0;
	weights[ "right" ] = 0;

	if ( self.leanAmount > 0 )
	{
		if ( self.leanAmount < 0.95 )
			self.leanAmount	 = 0.95;

		weights[ "left" ] = 0;
		weights[ "right" ] = ( 1 - self.leanAmount ) * 20;

		if ( weights[ "right" ] > 1 )
			weights[ "right" ] = 1;
		else if ( weights[ "right" ] < 0 )
			weights[ "right" ] = 0;

		weights[ "center" ] = 1 - weights[ "right" ];
	}
	else if ( self.leanAmount < 0 )
	{
		if ( self.leanAmount > - 0.95 )
			self.leanAmount	 = -0.95;

		weights[ "right" ] = 0;
		weights[ "left" ] = ( 1 + self.leanAmount ) * 20;

		if ( weights[ "left" ] > 1 )
			weights[ "left" ] = 1;
		if ( weights[ "left" ] < 0 )
			weights[ "left" ] = 0;

		weights[ "center" ] = 1 - weights[ "left" ];
	}
	else
	{
		weights[ "left" ] = 0;
		weights[ "right" ] = 0;
		weights[ "center" ] = 1;
	}

	return weights;
}