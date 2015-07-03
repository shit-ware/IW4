#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include animscripts\shared;
#include animscripts\utility;

#using_animtree( "generic_human" );
CONST_MPHCONVERSION = 17.6;

main()
{
	assert( isdefined( self.ridingvehicle ) );

	self.current_event = "none";
    self.shoot_while_driving_thread = undefined;

    self snowmobile_geton();

	if ( isdefined( self.drivingvehicle ) )
		main_driver();
	else
		main_passenger();
}

snowmobile_geton()
{
	self.grenadeawareness = 0;
	self.a.pose = "crouch";
    self disable_surprise();
	self.allowpain = false;

    self.getOffVehicleFunc = ::snowmobile_getoff;
	self.specialDeathFunc = animscripts\snowmobile::snowmobile_normal_death;
    self.disableBulletWhizbyReaction = true;
}

snowmobile_getoff()
{
	self.allowpain = true;

	self.getOffVehicleFunc = undefined;
	self.specialDeathFunc = undefined;
	self.a.specialShootBehavior = undefined;
	self.disableBulletWhizbyReaction = undefined;
}



main_driver()
{
	driver_shooting = self.ridingvehicle.driver_shooting || self.ridingvehicle.riders.size == 1;
	snowmobile_setanim_driver( driver_shooting );

	if ( driver_shooting )
	{
		placeweaponon( self.primaryweapon, "left" );

		self.rightaimlimit = 90;
		self.leftaimlimit = -90;
		self setanimaimweight( 1, 0.2 );

		self thread snowmobile_trackshootentorpos_driver();
		self thread snowmobile_loop_driver_shooting();
	}
	else
	{
		placeweaponon( self.primaryweapon, "none" );

		self thread snowmobile_loop_driver();
	}
	
	snowmobile_handle_events( "driver" );
}

main_passenger()
{
	snowmobile_setanim_passenger( self.ridingvehicle.passenger_shooting );

	if ( self.ridingvehicle.passenger_shooting )
	{
		self.rightaimlimit = 180;
		self.leftaimlimit = -180;
		self.diraimlimit = 1;
		self setanimaimweight( 1, 0.2 );
	
		self thread snowmobile_trackshootentorpos_passenger();
		self thread snowmobile_loop_passenger_shooting();
	}
	else
	{
		self thread snowmobile_loop_passenger();
	}
	
	snowmobile_handle_events( "passenger" );
}

snowmobile_loop_driver()
{
	self endon( "death" );
	self endon( "killanimscript" );

	current_anim = "left2right";
	
	anim_length = [];
	anim_length[ "left2right" ] = getanimlength( animarray( "left2right" ) );
	anim_length[ "right2left" ] = getanimlength( animarray( "right2left" ) );

	self setanimknoball( %sm_turn, %body, 1, 0 );
	self setanim( animarray( "drive" ), 1, 0 );
	self setanimknob( animarray( current_anim ), 1, 0 );
	self setanimtime( animarray( current_anim ), 0.5 );

	for ( ;; )
	{
		if ( self.ridingvehicle.steering_enable )
		{
			steering = 0.5*(1 + maps\_vehicle::update_steering( self.ridingvehicle ));
		
			anim_time = self getanimtime( animarray( current_anim ) );
			if ( current_anim == "right2left" )
				anim_time = 1 - anim_time;
			
			rate = 20*abs( anim_time - steering );
			
			if ( anim_time < steering )
			{
				current_anim = "left2right";
				rate *= anim_length[ "left2right" ];
			}
			else
			{
				current_anim = "right2left";
				rate *= anim_length[ "right2left" ];
				anim_time = 1 - anim_time;
			}
		}
		else
		{
			current_anim = "left2right";
			rate = 0;
			anim_time = 0.5;
		}

		self setanimknoblimited( animarray( current_anim ), 1, 0.1, rate );
		self setanimtime( animarray( current_anim ), anim_time );
		
		wait( 0.05 );
	}
}

snowmobile_loop_passenger()
{
	self endon( "death" );
	self endon( "killanimscript" );
   
	self setanimknoball( animarray( "hide" ), %body, 1, 0 );
	self setanimknob( animarray( "drive" ), 1, 0 );

	for (;;)
	{
		steering = maps\_vehicle::update_steering( self.ridingvehicle );
		self setanimlimited( %sm_lean, abs( steering ), 0.05 );
		if ( steering >= 0 ) {
			self setanimknoblimited( animarray( "lean_right" ), 1, 0.05 );
		} else {
			self setanimknoblimited( animarray( "lean_left" ), 1, 0.05 );
		}
		
		wait 0.05;
	}
}

snowmobile_loop_driver_shooting()
{
	self endon( "death" );
	self endon( "killanimscript" );

	leanblendtime = .05;
	reloadFinishedTime = 0;

	self setanimknoball( %sm_aiming, %body, 1, 0 );
	self setanimknob( animarray( "idle" ), 1, 0 );

	for ( ;; )
	{
		if ( self.current_event != "none" )
		{
			self waittill( "snowmobile_event_finished" );
			continue;
		}
		
		steering = maps\_vehicle::update_steering( self.ridingvehicle );
		center_steering = 1 - abs( steering );
		left_steering = max( 0, 0 - steering );
		right_steering = max( 0, steering );
		
		self setanimlimited( animarray( "straight_level_center" ), center_steering, leanblendtime );
		self setanimlimited( animarray( "straight_level_left" ), left_steering, leanblendtime );
		self setanimlimited( animarray( "straight_level_right" ), right_steering, leanblendtime );
		
		if ( self.bulletsinclip <= 0 )
		{
			self animscripts\weaponList::RefillClip();
			reloadFinishedTime = gettime() + 3000;
		}
		
		if ( reloadFinishedTime <= gettime() )
			snowmobile_start_shooting();
		
		self setanimknoblimited( animarray( "add_aim_left_center" ), center_steering, leanblendtime );
		self setanimlimited( animarray( "add_aim_left_left" ), left_steering, leanblendtime );
		self setanimlimited( animarray( "add_aim_left_right" ), right_steering, leanblendtime );
		
		self setanimknoblimited( animarray( "add_aim_right_center" ), center_steering, leanblendtime );
		self setanimlimited( animarray( "add_aim_right_left" ), left_steering, leanblendtime );
		self setanimlimited( animarray( "add_aim_right_right" ), right_steering, leanblendtime );
		
		self thread snowmobile_stop_shooting();
		
		wait( 0.05 );
	}
}

snowmobile_loop_passenger_shooting()
{
	self endon( "death" );
	self endon( "killanimscript" );

	leanblendtime = .05;

	self setanimknoball( %sm_aiming, %body, 1, 0 );
	self setanimknob( animarray( "idle" ), 1, 0 );

	for ( ;; )
	{
		if ( self.current_event != "none" )
		{
			self waittill( "snowmobile_event_finished" );
			continue;
		}
		
		if ( snowmobile_reload() )
			continue;
		
		steering = maps\_vehicle::update_steering( self.ridingvehicle );
		center_steering = 1 - abs( steering );
		left_steering = max( 0, 0 - steering );
		right_steering = max( 0, steering );
		
		self setanimlimited( animarray( "straight_level_center" ), center_steering, leanblendtime );
		self setanimlimited( animarray( "straight_level_left" ), left_steering, leanblendtime );
		self setanimlimited( animarray( "straight_level_right" ), right_steering, leanblendtime );
		
		snowmobile_start_shooting();
		
		self setanimlimited( animarray( "aim_left_center" ), center_steering, leanblendtime );
		self setanimlimited( animarray( "aim_left_left" ), left_steering, leanblendtime );
		self setanimlimited( animarray( "aim_left_right" ), right_steering, leanblendtime );
		
		self setanimlimited( animarray( "aim_right_center" ), center_steering, leanblendtime );
		self setanimlimited( animarray( "aim_right_left" ), left_steering, leanblendtime );
		self setanimlimited( animarray( "aim_right_right" ), right_steering, leanblendtime );
		
		self setanimlimited( animarray( "add_aim_backleft_center" ), center_steering, leanblendtime );
		self setanimlimited( animarray( "add_aim_backleft_left" ), left_steering, leanblendtime );
		self setanimlimited( animarray( "add_aim_backleft_right" ), right_steering, leanblendtime );
		
		self setanimlimited( animarray( "add_aim_backright_center" ), center_steering, leanblendtime );
		self setanimlimited( animarray( "add_aim_backright_left" ), left_steering, leanblendtime );
		self setanimlimited( animarray( "add_aim_backright_right" ), right_steering, leanblendtime );
		
		if ( isplayer( self.enemy ) )
			self updateplayersightaccuracy();
		
		wait( 0.05 );
		self thread snowmobile_stop_shooting(); // stop shooting on the next frame unless snowmobile_start_shooting is called again
	}
}

snowmobile_do_event( animation )
{
	self endon( "death" );

	self.ridingvehicle.steering_enable = false;
	self setflaggedanimknoblimitedrestart( "snowmobile_event", animation, 1, 0.17 );
	donotetracks( "snowmobile_event", ::snowmobile_waitfor_start_lean );
	self setanimknoblimited( animarray( "event_restore" ), 1, 0.1 );
	self.ridingvehicle.steering_enable = true;
	self.current_event = "none";
	self notify( "snowmobile_event_finished" );
}

snowmobile_handle_events( rider )
{
	self endon( "death" );
	self endon( "killanimscript" );

	snowmobile = self.ridingvehicle;
	
	for ( ;; )
	{
		if ( snowmobile.event[ "jump" ][ rider ] )
		{
			snowmobile.event[ "jump" ][ rider ] = false;
			self notify( "snowmobile_event_occurred" );
			self.current_event = "jump";
			snowmobile.steering_enable = false;
			self setflaggedanimknoblimitedrestart( "jump", animarray( "event_jump" ), 1, 0.17 );
		}
	
		if ( snowmobile.event[ "bump" ][ rider ] )
		{
			snowmobile.event[ "bump" ][ rider ] = false;
			self notify( "snowmobile_event_occurred" );
			if ( self.current_event != "bump_big" )
				self thread snowmobile_do_event( animarray( "event_bump" ) );
		}
	
		if ( snowmobile.event[ "bump_big" ][ rider ] )
		{
			snowmobile.event[ "bump_big" ][ rider ] = false;
			self notify( "snowmobile_event_occurred" );
			self.current_event = "bump_big";
			self thread snowmobile_do_event( animarray( "event_bump_big" ) );
		}
	
		if ( snowmobile.event[ "sway_left" ][ rider ] )
		{
			snowmobile.event[ "sway_left" ][ rider ] = false;
			self notify( "snowmobile_event_occurred" );
			if ( self.current_event != "bump_big" )
				self thread snowmobile_do_event( animarray( "event_sway" )[ "left" ] );
		}
	
		if ( snowmobile.event[ "sway_right" ][ rider ] )
		{
			snowmobile.event[ "sway_right" ][ rider ] = false;
			self notify( "snowmobile_event_occurred" );
			if ( self.current_event != "bump_big" )
				self thread snowmobile_do_event( animarray( "event_sway" )[ "right" ] );
		}
		
		wait( 0.05 );
	}
}

snowmobile_start_shooting()
{
	self notify( "want_shoot_while_driving" );
	
	self setAnim( %sm_add_fire, 1, 0.2 );
	
	if ( isdefined( self.shoot_while_driving_thread ) )
		return;
	self.shoot_while_driving_thread = true;

	self thread snowmobile_decide_shoot();
	self thread snowmobile_shoot();
}

snowmobile_stop_shooting()
{
	self endon( "killanimscript" );
	self endon( "want_shoot_while_driving" );

	wait .05;

	self notify( "end_shoot_while_driving" );
	self.shoot_while_driving_thread = undefined;
	self clearAnim( %sm_add_fire, 0.2 );
}

snowmobile_decide_shoot()
{
	self endon( "killanimscript" );
	self endon( "end_shoot_while_driving" );
	
	self.a.specialShootBehavior = ::snowmobileShootBehavior;
	
	snowmobile_decide_shoot_internal();
	
	self.shoot_while_driving_thread = undefined; // start shooting again the next time we want it
}

snowmobile_decide_shoot_internal()
{
	// events stop the shooting animations, so stop shooting when they happen
	self endon( "snowmobile_event_occurred" );
	
	self animscripts\shoot_behavior::decideWhatAndHowToShoot( "normal" );
}


snowmobileShootBehavior()
{
	if ( !isdefined( self.enemy ) )
	{
		self.shootent = undefined;
		self.shootpos = undefined;
		self.shootstyle = "none";
		return;
	}
	
	self.shootent = self.enemy;
	self.shootpos = self.enemy getShootAtPos();
	distSq = distanceSquared( self.origin, self.enemy.origin );
	
	if ( distSq < 1000*1000 )
		self.shootstyle = "full";
	else if ( distSq < 2000*2000 )
		self.shootstyle = "burst";
	else
		self.shootstyle = "single";
	

	if ( isdefined( self.enemy.vehicle ) )
	{
		shoot_ahead_speed_multiplier = 0.5;
		//shoot_ahead_random_spread = 50;
		
		vehicle = self.shootent.vehicle;
		snowmobile = self.ridingvehicle;
		delta = snowmobile.origin - vehicle.origin;
		forward = anglestoforward( vehicle.angles );            
		right = anglestoright( vehicle.angles );            
		dot = vectordot( delta, forward );
		if ( dot < 0 )
		{
			speed = vehicle vehicle_getspeed() * shoot_ahead_speed_multiplier;
			speed *= CONST_MPHCONVERSION;
			
			if ( speed > 50 )
			{
				sideness = vectordot( delta, right );
				sideness /= 3;
				if ( sideness > 128 )
					sideness = 128;
				else if ( sideness < -128 )
					sideness = -128;
				// flip it so guys farther to the side shoot in front of you
				if ( sideness > 0 )
					sideness = 128 - sideness;
				else
					sideness = -128 - sideness;
				
				self.shootent = undefined;
				self.shootpos = vehicle.origin + speed * forward + sideness * right;
				
				return;
			}
		}
	}
}


snowmobile_shoot()
{
	self endon( "killanimscript" );
	self endon( "end_shoot_while_driving" );

	self notify( "doing_shootWhileDriving" );
	self endon( "doing_shootWhileDriving" );

	for ( ;; )
	{
		if ( !self.bulletsInClip )
		{
			wait 0.5;
			continue;
		}

		self animscripts\combat_utility::shootUntilShootBehaviorChange();
	//	self clearAnim( %exposed_modern, 0.2 );
	}
}

snowmobile_reload()
{
	if ( !self.ridingvehicle.steering_enable )
		return false;
	
	if ( !self animscripts\combat_utility::needtoreload( 0 ) )
		return false;
	
	if ( !usingRifleLikeWeapon() )
		return false;
	
	snowmobile_reload_internal();
	
	// notify "abort_reload" in case the reload didn't finish. works with handledropclip() in shared.gsc
	self notify( "abort_reload" );
	
	return true;
}

snowmobile_reload_internal()
{
	self endon( "snowmobile_event_occurred" );
	
	self.stop_aiming_for_reload = true;
	self waittill( "start_blending_reload" );

	self setanim( %sm_aiming, 0, 0.25 );
	self setflaggedanimrestart( "gun_down", animarray( "gun_down" ), 1, 0.25 );
	DoNoteTracks( "gun_down" );
	self clearAnim( animarray( "gun_down" ), 0 );

	self setflaggedanimknoballrestart( "reload_anim", animarray( "reload" ), %body, 1, 0.25 );
	DoNoteTracks( "reload_anim" );
	self clearAnim( %sm_reload, 0.2 );

	self setflaggedanimrestart( "gun_up", animarray( "gun_up" ), 1, 0.25 );
	self.gun_up_for_reload = true;
	DoNoteTracks( "gun_up", ::snowmobile_waitfor_start_aim );
	
	
	self.stop_aiming_for_reload = undefined;
	self clearAnim( %sm_reload, 0.1 );
	self setanim( %sm_aiming, 1, 0.1 );

	if ( isdefined( self.gun_up_for_reload ) )
	{
		self.gun_up_for_reload = undefined;
		DoNoteTracks( "gun_up", ::snowmobile_waitfor_end );
		self clearAnim( animarray( "gun_up" ), 0 );
	}
}

snowmobile_waitfor_start_aim( note )
{
	if ( note == "start_aim" )
		return true;
}

snowmobile_waitfor_end( note )
{
	if ( note == "end" )
		return true;
}

snowmobile_waitfor_start_lean( note )
{
	if ( note == "start_lean" )
		return true;
}

snowmobile_trackshootentorpos_driver()
{
	self endon( "killanimscript" );
	self endon( "stop tracking" );

/#
	assert( !isdefined( self.trackLoopThread ) );
	self.trackLoopThread = thisthread;
	self.trackLoopThreadType = "snowmobile_trackshootentorpos_driver";
#/

	aimblendtime = .05;

	maxyawdeltachange = 8;// max change in yaw in 1 frame
	prevyawdelta = 0;
	yawdelta = 0;

	firstframe = true;

	for ( ;; )
	{
		incranimaimweight();

		selfshootatpos = ( self.origin[ 0 ], self.origin[ 1 ], self geteye()[ 2 ] );

		shootpos = self.shootpos;
		if ( isdefined( self.shootent ) )
			shootpos = self.shootent getshootatpos();

		if ( !isdefined( shootpos ) )
		{
			assert( !isdefined( self.shootent ) );

			yawdelta = 0;
			likelyenemydir = self getanglestolikelyenemypath();
			if ( isdefined( likelyenemydir ) )
			{
				yawdelta = angleclamp180( self.angles[ 1 ] - likelyenemydir[ 1 ] );
			}
		}
		else
		{
			vectortoshootpos = shootpos - selfshootatpos;
			anglestoshootpos = vectortoangles( vectortoshootpos );

			yawdelta = self.angles[ 1 ] - anglestoshootpos[ 1 ];
			yawdelta = angleclamp180( yawdelta );
		}

		assert( self.rightaimlimit >= 0 );
		assert( self.leftaimlimit <= 0 );
		if ( yawdelta > self.rightaimlimit || yawdelta < self.leftaimlimit )
			yawdelta = 0;

		if ( firstframe )
		{
			firstframe = false;
		}
		else
		{
			yawdeltachange = yawdelta - prevyawdelta;

			if ( abs( yawdeltachange ) > maxyawdeltachange )
				yawdelta = prevyawdelta + maxyawdeltachange * sign( yawdeltachange );
		}

		prevyawdelta = yawdelta;

		weight4 = min( max( 0 - yawdelta, 0 ), 90 ) / 90 * self.a.aimweight;
		weight6 = min( max( yawdelta, 0 ), 90 ) / 90 * self.a.aimweight;

		self setanimlimited( %sm_aim_4, weight4, aimblendtime );
		self setanimlimited( %sm_aim_6, weight6, aimblendtime );

		wait( 0.05 );
	}
}

snowmobile_trackshootentorpos_passenger()
{
	self endon( "killanimscript" );
	self endon( "stop tracking" );

/#
	assert( !isdefined( self.trackLoopThread ) );
	self.trackLoopThread = thisthread;
	self.trackLoopThreadType = "snowmobile_trackshootentorpos_passenger";
#/

	aimblendtime = .05;

	maxyawdeltachange_default = 5;// max change in yaw in 1 frame
	maxyawdeltachange_fast = 20;
	maxyawdeltachange_reload = 15;
	yawdelta_overshoot_begin = 40;
	yawdelta_overshoot_end = 30;
	
	prevyawdelta = 0;
	yawdelta = 0;

	firstframe = true;

	for ( ;; )
	{
		incranimaimweight();
		
		selfshootatpos = ( self.origin[ 0 ], self.origin[ 1 ], self geteye()[ 2 ] );
		
		shootpos = self.shootpos;
		if ( isdefined( self.shootent ) )
			shootpos = self.shootent getshootatpos();
		
		if ( !isdefined( shootpos ) )
		{
			assert( !isdefined( self.shootent ) );

			yawdelta = 0;
			likelyenemydir = self getanglestolikelyenemypath();
			if ( isdefined( likelyenemydir ) )
			{
				yawdelta = angleclamp180( self.angles[ 1 ] - likelyenemydir[ 1 ] );
			}
		}
		else
		{
			vectortoshootpos = shootpos - selfshootatpos;
			anglestoshootpos = vectortoangles( vectortoshootpos );

			yawdelta = self.angles[ 1 ] - anglestoshootpos[ 1 ];
			yawdelta = angleclamp180( yawdelta );
			
			//line( selfshootatpos, shootpos );
		}

		assert( self.diraimlimit == 1 || self.diraimlimit == -1 );

		if ( isdefined( self.stop_aiming_for_reload ) || ( yawdelta > 0 && ( yawdelta - self.rightaimlimit ) * self.diraimlimit > 0 ) || ( yawdelta < 0 && ( yawdelta - self.leftaimlimit ) * self.diraimlimit < 0 ) )
			yawdelta = 0;

		if ( firstframe )
		{
			firstframe = false;
		}
		else
		{
			if ( prevyawdelta < -180 + yawdelta_overshoot_begin && yawdelta > 180 - yawdelta_overshoot_end )
				yawdelta = -179;
			if ( prevyawdelta > 180 - yawdelta_overshoot_begin && yawdelta < -180 + yawdelta_overshoot_end )
				yawdelta = 179;
			
			yawdeltachange = yawdelta - prevyawdelta;

			maxyawdeltachange = (maxyawdeltachange_fast - maxyawdeltachange_default) * abs( yawdeltachange ) / 180 + maxyawdeltachange_default;
			if ( isdefined( self.stop_aiming_for_reload ) )
			{
				maxyawdeltachange = maxyawdeltachange_reload;
				if ( abs( prevyawdelta ) < 45 )
					self notify( "start_blending_reload" );
			}

			if ( abs( yawdeltachange ) > maxyawdeltachange )
				yawdelta = prevyawdelta + maxyawdeltachange * sign( yawdeltachange );
		}

		prevyawdelta = yawdelta;

		weight1 = max( -90 - yawdelta, 0 ) / 90 * self.a.aimweight;
		weight4 = min( max( 0 - yawdelta, 0 ), 90 ) / 90 * self.a.aimweight;
		weight5 = max( 90 - abs( yawdelta ), 0 ) / 90 * self.a.aimweight;
		weight6 = min( max( yawdelta, 0 ), 90 ) / 90 * self.a.aimweight;
		weight3 = max( -90 + yawdelta, 0 ) / 90 * self.a.aimweight;

		self setanimlimited( %sm_aim_1, weight1, aimblendtime );
		self setanimlimited( %sm_aim_4_delta, weight4, aimblendtime );
		self setanimlimited( %sm_aim_5_delta, weight5, aimblendtime );
		self setanimlimited( %sm_aim_6_delta, weight6, aimblendtime );
		self setanimlimited( %sm_aim_3, weight3, aimblendtime );

		wait( 0.05 );
	}
}


snowmobile_get_death_anim( deathAnims, deathAnimDirs, goalDir )
{
	bestDeathAnim = undefined;
	secondBestDeathAnim = undefined;
	bestDeathAnimDiff = 0;
	for ( i = 0; i < deathAnims.size; i++ )
	{
		diff = AbsAngleClamp180( goalDir - deathAnimDirs[i] );
		if ( !isdefined( bestDeathAnim ) || diff < bestDeathAnimDiff )
		{
			secondBestDeathAnim = bestDeathAnim;
			
			bestDeathAnim = deathAnims[i];
			bestDeathAnimDiff = diff;
		}
		else if ( !isdefined( secondBestDeathAnim ) )
		{
			secondBestDeathAnim = deathAnims[i];
		}
	}
	assert( isdefined( bestDeathAnim ) );
	assert( isdefined( secondBestDeathAnim ) );
	
	deathAnim = bestDeathAnim;
	if ( isDefined( anim.prevSnowmobileDeath ) && deathAnim == anim.prevSnowmobileDeath && gettime() - anim.prevSnowmobileDeathTime < 500 )
		deathAnim = secondBestDeathAnim;
	anim.prevSnowmobileDeath = deathAnim;
	anim.prevSnowmobileDeathTime = gettime();
	
	return deathAnim;
}

snowmobile_death_launchslide()
{
	snowmobile = self.ridingvehicle;
	assert( isdefined( snowmobile ) );
	
	velocity = snowmobile.prevFrameVelocity;
	velocity = ( velocity[0], velocity[1], randomfloatrange( 200, 400 ) ) * .75;
	//println( length( velocity ) );
	if ( lengthSquared( velocity ) > 1000 * 1000 )
		velocity = vectornormalize( velocity ) * 1000;
	
	model = spawn( "script_origin", self.origin );
	model moveSlide( ( 0, 0, 40 ), 15, velocity );
	self linkto( model );
	
	model thread deleteShortly();
}

snowmobile_normal_death()
{
	//self snowmobile_death_launchslide();
	
	deathAnims = [];
	deathAnims[0] = level.scr_anim[ "snowmobile" ][ "small" ][ "death" ][ "back" ];
	deathAnims[1] = level.scr_anim[ "snowmobile" ][ "small" ][ "death" ][ "right" ];
	deathAnims[2] = level.scr_anim[ "snowmobile" ][ "small" ][ "death" ][ "left" ];
	deathAnimDirs = [];
	deathAnimDirs[0] = -180;
	deathAnimDirs[1] = -90;
	deathAnimDirs[2] = 90;
	
	deathAnim = snowmobile_get_death_anim( deathAnims, deathAnimDirs, self.damageyaw );
	
	animscripts\death::playDeathAnim( deathAnim );
	return true;
}

snowmobile_collide_death()
{
	snowmobile = self.ridingvehicle;
	if ( !isdefined( snowmobile ) )
		return snowmobile_normal_death();
	
	velocity = snowmobile.prevFrameVelocity;
	
	self snowmobile_death_launchslide();
	
	angles = vectortoangles( velocity );
	delta = AngleClamp180( angles[1] - self.angles[1] );
	
	deathAnims = [];
	deathAnims[0] = level.scr_anim[ "snowmobile" ][ "big" ][ "death" ][ "back" ];
	deathAnims[1] = level.scr_anim[ "snowmobile" ][ "big" ][ "death" ][ "left" ];
	deathAnims[2] = level.scr_anim[ "snowmobile" ][ "big" ][ "death" ][ "front" ];
	deathAnims[3] = level.scr_anim[ "snowmobile" ][ "big" ][ "death" ][ "right" ];
	deathAnimDirs = [];
	deathAnimDirs[0] = -180;
	deathAnimDirs[1] = -90;
	deathAnimDirs[2] = 0;
	deathAnimDirs[3] = 90;
	
	deathAnim = snowmobile_get_death_anim( deathAnims, deathAnimDirs, delta );

	animscripts\death::playDeathAnim( deathAnim );
	return true;
}

deleteShortly()
{
	prevorg = self.origin;
	for ( i = 0; i < 60; i++ )
	{
		wait .05;
		line(self.origin,prevorg);
		prevorg = self.origin;
	}
	wait 3;
	if ( isdefined( self ) )
		self delete();
}


snowmobile_setanim_common( seat )
{
	self.a.array[ "idle" ] = level.scr_anim[ "snowmobile" ][ seat ][ "idle" ];
	self.a.array[ "drive" ] = level.scr_anim[ "snowmobile" ][ seat ][ "drive" ];

	self.a.array[ "fire" ] = level.scr_anim[ "snowmobile" ][ seat ][ "fire" ];
	self.a.array[ "single" ] = array( level.scr_anim[ "snowmobile" ][ seat ][ "single" ] );

	self.a.array[ "burst2" ] = level.scr_anim[ "snowmobile" ][ seat ][ "fire" ];
	self.a.array[ "burst3" ] = level.scr_anim[ "snowmobile" ][ seat ][ "fire" ];
	self.a.array[ "burst4" ] = level.scr_anim[ "snowmobile" ][ seat ][ "fire" ];
	self.a.array[ "burst5" ] = level.scr_anim[ "snowmobile" ][ seat ][ "fire" ];
	self.a.array[ "burst6" ] = level.scr_anim[ "snowmobile" ][ seat ][ "fire" ];

	self.a.array[ "semi2" ] = level.scr_anim[ "snowmobile" ][ seat ][ "fire" ];
	self.a.array[ "semi3" ] = level.scr_anim[ "snowmobile" ][ seat ][ "fire" ];
	self.a.array[ "semi4" ] = level.scr_anim[ "snowmobile" ][ seat ][ "fire" ];
	self.a.array[ "semi5" ] = level.scr_anim[ "snowmobile" ][ seat ][ "fire" ];
}

snowmobile_setanim_driver( shooting )
{
	self.a.array = [];

	snowmobile_setanim_common( "driver" );

	self.a.array[ "left2right" ] = level.scr_anim[ "snowmobile" ][ "driver" ][ "left2right" ];
	self.a.array[ "right2left" ] = level.scr_anim[ "snowmobile" ][ "driver" ][ "right2left" ];

	self.a.array[ "straight_level_left" ] = level.scr_anim[ "snowmobile" ][ "driver" ][ "straight_level" ][ "left" ];
	self.a.array[ "straight_level_center" ] = level.scr_anim[ "snowmobile" ][ "driver" ][ "straight_level" ][ "center" ];
	self.a.array[ "straight_level_right" ] = level.scr_anim[ "snowmobile" ][ "driver" ][ "straight_level" ][ "right" ];
	self.a.array[ "add_aim_left_left" ] = level.scr_anim[ "snowmobile" ][ "driver" ][ "add_aim_left" ][ "left" ];
	self.a.array[ "add_aim_left_center" ] = level.scr_anim[ "snowmobile" ][ "driver" ][ "add_aim_left" ][ "center" ];
	self.a.array[ "add_aim_left_right" ] = level.scr_anim[ "snowmobile" ][ "driver" ][ "add_aim_left" ][ "right" ];
	self.a.array[ "add_aim_right_left" ] = level.scr_anim[ "snowmobile" ][ "driver" ][ "add_aim_right" ][ "left" ];
	self.a.array[ "add_aim_right_center" ] = level.scr_anim[ "snowmobile" ][ "driver" ][ "add_aim_right" ][ "center" ];
	self.a.array[ "add_aim_right_right" ] = level.scr_anim[ "snowmobile" ][ "driver" ][ "add_aim_right" ][ "right" ];
	
	if ( shooting )
	{
		self.a.array["event_jump"] = level.scr_anim[ "snowmobile" ][ "driver" ][ "shoot_jump" ];
		self.a.array["event_bump"] = level.scr_anim[ "snowmobile" ][ "driver" ][ "shoot_bump" ];
		self.a.array["event_bump_big"] = level.scr_anim[ "snowmobile" ][ "driver" ][ "shoot_bump_big" ];
		self.a.array["event_sway"] = [];
		self.a.array["event_sway"][ "left" ] = level.scr_anim[ "snowmobile" ][ "driver" ][ "shoot_sway_left" ];
		self.a.array["event_sway"][ "right" ] = level.scr_anim[ "snowmobile" ][ "driver" ][ "shoot_sway_right" ];
		
		self.a.array["event_restore"] = %sm_aiming;
	}
	else
	{
		self.a.array["event_jump"] = level.scr_anim[ "snowmobile" ][ "driver" ][ "drive_jump" ];
		self.a.array["event_bump"] = level.scr_anim[ "snowmobile" ][ "driver" ][ "drive_bump" ];
		self.a.array["event_bump_big"] = level.scr_anim[ "snowmobile" ][ "driver" ][ "drive_bump_big" ];
		self.a.array["event_sway"] = [];
		self.a.array["event_sway"][ "left" ] = level.scr_anim[ "snowmobile" ][ "driver" ][ "drive_sway_left" ];
		self.a.array["event_sway"][ "right" ] = level.scr_anim[ "snowmobile" ][ "driver" ][ "drive_sway_right" ];
		
		self.a.array["event_restore"] = %sm_turn;
	}
}

snowmobile_setanim_passenger( shooting )
{
	self.a.array = [];

	snowmobile_setanim_common( "passenger" );

	self.a.array[ "hide" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "hide" ];
	self.a.array[ "lean_left" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "add_lean" ][ "left" ];
	self.a.array[ "lean_right" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "add_lean" ][ "right" ];

	self.a.array[ "reload" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "reload" ];
	self.a.array[ "gun_up" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "gun_up" ];
	self.a.array[ "gun_down" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "gun_down" ];

	self.a.array[ "aim_left_left" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "aim_left" ][ "left" ];
	self.a.array[ "aim_left_center" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "aim_left" ][ "center" ];
	self.a.array[ "aim_left_right" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "aim_left" ][ "right" ];
	self.a.array[ "aim_right_left" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "aim_right" ][ "left" ];
	self.a.array[ "aim_right_center" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "aim_right" ][ "center" ];
	self.a.array[ "aim_right_right" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "aim_right" ][ "right" ];
	self.a.array[ "add_aim_backleft_left" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "add_aim_backleft" ][ "left" ];
	self.a.array[ "add_aim_backleft_center" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "add_aim_backleft" ][ "center" ];
	self.a.array[ "add_aim_backleft_right" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "add_aim_backleft" ][ "right" ];
	self.a.array[ "add_aim_backright_left" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "add_aim_backright" ][ "left" ];
	self.a.array[ "add_aim_backright_center" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "add_aim_backright" ][ "center" ];
	self.a.array[ "add_aim_backright_right" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "add_aim_backright" ][ "right" ];
	self.a.array[ "straight_level_left" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "straight_level" ][ "left" ];
	self.a.array[ "straight_level_center" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "straight_level" ][ "center" ];
	self.a.array[ "straight_level_right" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "straight_level" ][ "right" ];

	if ( shooting )
	{
		self.a.array["event_jump"] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "drive_jump" ];
		self.a.array["event_bump"] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "drive_bump" ];
		self.a.array["event_bump_big"] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "drive_bump_big" ];
		self.a.array["event_sway"] = [];
		self.a.array["event_sway"][ "left" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "drive_sway_left" ];
		self.a.array["event_sway"][ "right" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "drive_sway_right" ];
		self.a.array["event_restore"] = %sm_aiming;
	}
	else
	{
		self.a.array["event_jump"] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "hide_jump" ];
		self.a.array["event_bump"] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "hide_bump" ];
		self.a.array["event_bump_big"] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "hide_bump_big" ];
		self.a.array["event_sway"] = [];
		self.a.array["event_sway"][ "left" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "hide_sway_left" ];
		self.a.array["event_sway"][ "right" ] = level.scr_anim[ "snowmobile" ][ "passenger" ][ "hide_sway_right" ];
		self.a.array["event_restore"] = %sm_turn;
	}
}
