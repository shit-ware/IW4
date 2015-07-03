#include animscripts\combat_utility;
#include animscripts\shared;
#include animscripts\utility;
#include maps\_utility;
#using_animtree( "generic_human" );

main()
{
	anim.boatanims = [];
	anim.boatanims[ "left" ] = spawnstruct();
	anim.boatanims[ "left" ].base = %zodiac_aim_left;
	anim.boatanims[ "left" ].trans = %zodiac_trans_R2L; // Why would we use the "R_2_L" animation to transition from the "left" pose to the "right" pose, you ask? I don't know, my friend. I don't know.
	anim.boatanims[ "left" ].aim = spawnstruct();
	anim.boatanims[ "left" ].aim.left = %zodiac_rightside_aim4;
	anim.boatanims[ "left" ].aim.center = %zodiac_rightside_aim5;
	anim.boatanims[ "left" ].aim.right = %zodiac_rightside_aim6;
	anim.boatanims[ "left" ].reload = array( %zodiac_rightside_reload );
	anim.boatanims[ "left" ].leftAimLimit = -49;
	anim.boatanims[ "left" ].rightAimLimit = 48;
	anim.boatanims[ "left" ].idle = %zodiac_rightside_idle;
	anim.boatanims[ "left" ].twitch = array( %zodiac_rightside_shift, %zodiac_rightside_react );
	
	anim.boatanims[ "right" ] = spawnstruct();
	anim.boatanims[ "right" ].base = %zodiac_aim_right;
	anim.boatanims[ "right" ].trans = %zodiac_trans_L2R;
	anim.boatanims[ "right" ].aim = spawnstruct();
	anim.boatanims[ "right" ].aim.left = %zodiac_leftside_aim4;
	anim.boatanims[ "right" ].aim.center = %zodiac_leftside_aim5;
	anim.boatanims[ "right" ].aim.right = %zodiac_leftside_aim6;
	anim.boatanims[ "right" ].reload = array( %zodiac_leftside_reload, %zodiac_leftside_reloadB );
	anim.boatanims[ "right" ].idle = %zodiac_leftside_idle;
	anim.boatanims[ "right" ].twitch = array( %zodiac_leftside_duck );
	anim.boatanims[ "right" ].leftAimLimit = -51;
	anim.boatanims[ "right" ].rightAimLimit = 51;
}

draw_line_toshootpos()
{
	while(1)
	{
		if( isdefined( self.shootpos ) )
			Line( self.shootpos, self.origin, (1,0,0), 1 );
		if( isdefined( self.favoriteenemy ) )
			Line( self.favoriteenemy.origin, self.origin, (0,0,1), 1 );
		if( isdefined( self.zodiac_enemy ) )
			Line( self.zodiac_enemy.origin, self.origin, (0,1,0), 1 );
		wait .05;
	}
	
}

endthink() // this function is not called right now, but it should be if an AI ever gets off a zodiac.
{
	self.a.specialShootBehavior = undefined;
}

think()
{
	self endon ( "killanimscript" ); // (includes death)
	
	if( !ent_flag_exist( "transitioning_positions" ) )
		ent_flag_init( "transitioning_positions" );     
	else
		ent_flag_clear( "transitioning_positions" );
		
	animscripts\utility::initialize( "zodiac" );
	
	self.a.boatAimYaw = 0;
	if( !isdefined( self.a.boat_pose ) )
		self.a.boat_pose = "right";
		
	self.a.last_boat_pose_switch = gettime();
	
	self.a.lastBoatTwitchTime = gettime();
	
	self childthread animscripts\shoot_behavior::decideWhatAndHowToShoot( "normal" );
	
	self setup_anim_array_boat();
	
	self.a.wantBoatReloadTime = undefined;
	
	self.a.specialShootBehavior = ::zodiacShootBehavior;
	
	self childthread watchVelocity();
	self childthread idleAimDir();
//	self childthread draw_line_toshootpos();
	
	for ( ;; )
	{
		self thread disableBoatIdle();
		
		if ( self shouldReload() )
		{
			self boatReload();
			continue;
		}
		
		newPose = needToChangePose();
		if ( newPose != "none" )
		{
			assert( newPose != self.a.boat_pose );
			
			transanim = anim.boatanims[ self.a.boat_pose ].trans;
			self.a.boat_pose = newPose;
			ent_flag_set( "transitioning_positions" );
			self setFlaggedAnimKnobAllRestart( "trans", transanim, %body, 1, 0.2 );
			self animscripts\shared::DoNoteTracksForTime( getAnimLength( transanim ) - 0.3, "trans" );
			self.a.last_boat_pose_switch = gettime();
			ent_flag_clear( "transitioning_positions" );
			
			theanim = anim.boatanims[ self.a.boat_pose ].aim.center;
			self setAnimKnobAllRestart( theanim, %body, 1, 0.2 );
			self notify( "boat_pose_change" );
			
			self.a.boatAimYaw = 0;
			self setup_anim_array_boat();
			
			continue;
		}
		
		if ( shouldDoTwitch() )
		{
			doBoatTwitch();
			continue;
		}
		
		// we want the additive idle for anything after this point in the loop (shooting or aiming)
		self thread enableBoatIdle();
		
		if ( aimedAtShootEntOrPos() )
		{
			self shootUntilNeedToChangePose();
			continue;
		}
		else
		{
			self updateBoatAim();
		}
		
		wait .1;

	}
	
	self waittill( "forever" );
}

shouldReload()
{
	if ( NeedToReload( 0 ) )
	{
		// it looks bad to reload when we have targets.
		// we'll reload when we get a chance.
		
		if ( !isDefined( self.a.wantBoatReloadTime ) )
			self.a.wantBoatReloadTime = gettime();
		self animscripts\weaponList::RefillClip();
	}
	
	if ( isDefined( self.a.wantBoatReloadTime ) )
	{
		// don't wait too long.
		if ( gettime() - self.a.wantBoatReloadTime > 2500 )
			return true;
		
		if ( !canAimAtEnemy() )
			return true;
		
		if ( self.a.lastShootTime < gettime() - 1500 )
			return true;
	}
	
	return false;
}

boatReload()
{
	reloads = anim.boatanims[ self.a.boat_pose ].reload;
	reloadanim = reloads[ randomint( reloads.size ) ];
	
	self.a.wantBoatReloadTime = undefined;
	
	self setFlaggedAnimKnobAllRestart( "reload", reloadanim, %body, 1, 0.2 );
	self animscripts\shared::DoNoteTracks( "reload" );
	
	self animscripts\weaponList::RefillClip();
}

disableBoatIdle()
{
	if ( !isDefined( self.a.boatIdle ) )
		return;
	
	self endon( "killanimscript" );
	
	// actually wait a bit before clearing it in case we still want it
	self endon( "want_boat_idle" );
	wait .05;
	
	self notify( "end_boat_idle" );
	self.a.boatIdle = undefined;
	
	self clearAnim( %zodiac_idle, 0.2 );
}

enableBoatIdle()
{
	self notify( "want_boat_idle" );
	
	if ( isdefined( self.a.boatIdle ) )
		return;
	self.a.boatIdle = true;
	
	self endon( "end_boat_idle" );
	
	idleAnim = anim.boatanims[ self.a.boat_pose ].idle;
	if ( isDefined( idleAnim ) )
		self setAnimKnob( idleAnim, 1, 0.2 );
}

shouldDoTwitch()
{
	if ( self.a.lastShootTime > gettime() - 2000 )
		return false;
	
	if ( gettime() < self.a.lastBoatTwitchTime + 1500 )
		return false;
	
	if ( isDefined( self.enemy ) && self.enemy sightconetrace( self getEye() ) )
		return false;
	
	if ( !isDefined( anim.boatanims[ self.a.boat_pose ].twitch ) )
		return false;
	
	return true;
}

doBoatTwitch()
{
	twitches = anim.boatanims[ self.a.boat_pose ].twitch;
	
	twitchAnim = twitches[ randomint( twitches.size ) ];
	for ( i = 0; i < 5; i++ )
	{
		if ( !isdefined( self.a.lastBoatTwitchAnim ) || twitchAnim != self.a.lastBoatTwitchAnim )
			break;
		twitchAnim = twitches[ randomint( twitches.size ) ];
	}
	
	self setFlaggedAnimKnobAllRestart( "twitch", twitchAnim, %body, 1, 0.2 );
	self animscripts\shared::DoNoteTracks( "twitch" );
	
	self.a.lastBoatTwitchAnim = twitchAnim;
	self.a.lastBoatTwitchTime = gettime();
}

zodiacShootBehavior()
{
	if ( !isdefined( self.enemy ) || !self.enemy sightconetrace( self getEye() ) ) 
	{
		self.shootent = undefined;
		self.shootpos = undefined;
		self.shootstyle = "none";
		return;
	}
	
	self.shootent = self.enemy;
	self.shootpos = self.enemy getShootAtPos();
	distSq = distanceSquared( self.origin, self.enemy.origin );
	
	if ( distSq < 4000*4000 )
		self.shootstyle = "burst";
	else
		self.shootstyle = "single";
}


watchVelocity()
{
	self endon( "killanimscript" );
	self.prevpos = self.origin;
	self.boatvelocity = (0,0,0);
	
	for ( ;; )
	{
		wait .05;
		self.boatvelocity = (self.origin - self.prevpos) / .05;
		self.prevpos = self.origin;
	}
}

waitRandomTimeBoat()
{
	self endon( "boat_pose_change" );
	wait randomfloatrange( 0.5, 3.5 );
}

idleAimDir()
{
	self endon( "killanimscript" );
	
	for ( ;; )
	{
		if ( self.a.boat_pose == "left" )
			self.idleAimYaw = randomfloatrange( -20, 40 );
		else
			self.idleAimYaw = randomfloatrange( -40, 20 );
		
		self waitRandomTimeBoat();
	}
}


getBoatAimYawToShootPos( predictionTime )
{
	if ( !isDefined( self.shootPos ) )
		return 0;
	
	predictedShootPos = self.shootPos - self.boatvelocity * predictionTime;
	
	aimYaw = getAimYawToPoint( predictedShootPos );
	return aimYaw;
}


canAimAtEnemy()
{
	if ( !isDefined( self.shootPos ) )
		return false;
	
	aimYaw = getDesiredBoatAimYaw();
	anims = anim.boatanims[ self.a.boat_pose ];
	return ( aimYaw >= anims.leftAimLimit && aimYaw <= anims.rightAimLimit );
}

getDesiredBoatAimYaw()
{
	aimYaw = 0;
	
	if ( isDefined( self.shootPos ) )
	{
		aimYaw = getBoatAimYawToShootPos( .1 );
		if ( self.a.boat_pose == "left" )
			aimYaw = AngleClamp180( aimYaw + 40.5 );
		else
			aimYaw = AngleClamp180( aimYaw - 36 );
	}
	else
	{
		aimYaw = self.idleAimYaw;
	}
	
	return aimYaw;
}

updateBoatAim()
{
	// need to be able to aim quickly because we're moving quickly, so don't cap too much
	maxTurn = 15;
	if ( !isDefined( self.shootPos ) )
		maxTurn = 5;
	
	aimYaw = getDesiredBoatAimYaw();
	
	if ( abs( aimYaw - self.a.boatAimYaw ) > maxTurn )
	{
		if ( aimYaw < self.a.boatAimYaw )
			aimYaw = self.a.boatAimYaw - maxTurn;
		else
			aimYaw = self.a.boatAimYaw + maxTurn;
	}
	
	anims = anim.boatanims[ self.a.boat_pose ];
	if ( aimYaw < 0 )
	{
		frac = aimYaw / anims.leftAimLimit;
		if ( frac > 1 )
			frac = 1;
		self setAnimKnob( anims.aim.center, 1 - frac, 0.1 );
		self setAnim    ( anims.aim.left  ,     frac, 0.1 );
	}
	else
	{
		frac = aimYaw / anims.rightAimLimit;
		if ( frac > 1 )
			frac = 1;
		self setAnimKnob( anims.aim.center, 1 - frac, 0.1 );
		self setAnim    ( anims.aim.right ,     frac, 0.1 );
	}
	self setAnimKnobAll( anims.base, %zodiac_actions, 1, 0.2 );
	
	self.a.boatAimYaw = aimYaw;
}

updateBoatAimThread()
{
	self endon( "killanimscript" );
	self endon( "end_shootUntilNeedToChangePose" );
	
	for ( ;; )
	{
		updateBoatAim();
		wait .1;
	}
}


shootUntilNeedToChangePose()
{
	self thread watchForNeedToChangePoseOrTimeout();
	self endon( "end_shootUntilNeedToChangePose" );
	
	self thread updateBoatAimThread();
	
	shootUntilShootBehaviorChange();
	
	self notify( "end_shootUntilNeedToChangePose" );
}

watchForNeedToChangePoseOrTimeout()
{
	self endon( "killanimscript" );
	self endon( "end_shootUntilNeedToChangePose" );
	
	endtime = gettime() + 4000 + randomint( 2000 );
	
	while ( 1 )
	{
		if ( gettime() > endtime || needToChangePose() != "none" )
			break;
		
		if ( self shouldReload() )
			break;
		
		wait .1;
	}
	
	self notify( "end_shootUntilNeedToChangePose" );
}

needToChangePose_other()
{
	if ( self.a.last_boat_pose_switch > gettime() - 2000 )
		return "none"; 
		
	if ( self.a.lastShootTime > gettime() - 2000 )
		return "none"; 
		
	if ( !isDefined( self.shootPos ) )
		return "none";
	
	aimYaw = getBoatAimYawToShootPos( 0.5 ); // half second prediction
	
	if ( self.a.boat_pose == "left" )
	{
		if ( aimYaw > 15 && aimYaw < 160 )
			return "right";
	}
	else if ( self.a.boat_pose == "right" )
	{
		if ( aimYaw < -15 && aimYaw > -160 )
			return "left";
	}
	
	return "none";
}

needToChangePose()
{
	if ( isdefined( self.use_auto_pose ) )
		return needToChangePose_other();
		
	if ( isDefined( self.scripted_boat_pose ) )
	{
		if ( self.a.boat_pose == self.scripted_boat_pose )
			return "none";
		
		return self.scripted_boat_pose;
	}
	
	// we always want the "left" pose now
	if ( self.a.boat_pose == "right" )
		return "left";
	
	return "none";
	
	/*
	if ( !isDefined( self.shootPos ) )
		return "none";
	
	aimYaw = getBoatAimYawToShootPos( 0.5 ); // half second prediction
	
	if ( self.a.boat_pose == "left" )
	{
		if ( aimYaw > 15 && aimYaw < 160 )
			return "right";
	}
	else if ( self.a.boat_pose == "right" )
	{
		if ( aimYaw < -15 && aimYaw > -160 )
			return "left";
	}
	
	return "none";
	*/
}


setup_anim_array_boat()
{
	self.a.array = [];
	
	self.a.array[ "fire" ] = %exposed_shoot_auto_v3;
	
	if ( self.a.boat_pose == "left" )
	{
		self.a.array[ "single" ] = array( %zodiac_rightside_fire_single );
		self.a.array[ "burst2" ] = %zodiac_rightside_fire_burst;
		self.a.array[ "burst3" ] = %zodiac_rightside_fire_burst;
		self.a.array[ "burst4" ] = %zodiac_rightside_fire_burst;
		self.a.array[ "burst5" ] = %zodiac_rightside_fire_burst;
		self.a.array[ "burst6" ] = %zodiac_rightside_fire_burst;
		self.a.array[ "semi2" ] = %zodiac_rightside_fire_burst;
		self.a.array[ "semi3" ] = %zodiac_rightside_fire_burst;
		self.a.array[ "semi4" ] = %zodiac_rightside_fire_burst;
		self.a.array[ "semi5" ] = %zodiac_rightside_fire_burst;
		self.a.array[ "semi6" ] = %zodiac_rightside_fire_burst;
	}
	else
	{
		self.a.array[ "single" ] = array( %zodiac_leftside_fire_single );
		self.a.array[ "burst2" ] = %zodiac_leftside_fire_burst;
		self.a.array[ "burst3" ] = %zodiac_leftside_fire_burst;
		self.a.array[ "burst4" ] = %zodiac_leftside_fire_burst;
		self.a.array[ "burst5" ] = %zodiac_leftside_fire_burst;
		self.a.array[ "burst6" ] = %zodiac_leftside_fire_burst;
		self.a.array[ "semi2" ] = %zodiac_leftside_fire_burst;
		self.a.array[ "semi3" ] = %zodiac_leftside_fire_burst;
		self.a.array[ "semi4" ] = %zodiac_leftside_fire_burst;
		self.a.array[ "semi5" ] = %zodiac_leftside_fire_burst;
		self.a.array[ "semi6" ] = %zodiac_leftside_fire_burst;
	}
}


