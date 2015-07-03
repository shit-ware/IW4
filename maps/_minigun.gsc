#include common_scripts\utility;
#include maps\_utility;
#include maps\_hud_util;

main()
{
	flag_init( "player_on_minigun" );
	flag_init( "player_off_minigun" );
	flag_init( "disable_overheat" );
	flag_init( "minigun_lesson_learned" );
	precachestring( &"SCRIPT_PLATFORM_MINIGUN_SPIN_HINT" );
	precachestring( &"SCRIPT_PLATFORM_MINIGUN_FIRE_HINT" );
	precacheShader( "white" );
	precacheShader( "black" );
	precacheShader( "hud_temperature_gauge" );
	precacheRumble( "minigun_rumble" );
	precacheShader( "popmenu_bg" );
	level.turret_heat_status = 1;
	level.turret_heat_max = 114;
	level.turret_cooldownrate = 15;
	level._effect[ "_minigun_overheat_haze" ]		 = loadfx( "distortion/abrams_exhaust" );
	level._effect[ "_minigun_overheat_smoke" ]	 = loadfx( "distortion/armored_car_overheat" );
	
	minigun_anims();
}

#using_animtree( "vehicles" );
minigun_anims()
{
	level.scr_anim[ "minigun" ][ "spin" ]				= %bh_minigun_spin_loop;
	level.scr_animtree[ "minigun" ] 					= #animtree;	
	level.scr_model[ "minigun" ] 						= "weapon_minigun";
}

minigun_think()
{
	self.animname = "minigun";
	self assign_animtree();
	self thread minigun_used();

	for ( ;; )
	{
		for ( ;; )
		{
			// wait for the player to get on the turret
			if ( self player_on_minigun() )
				break;
			wait( 0.05 );
		}

		//level thread overheat_enable();

		flag_clear( "player_off_minigun" );
		flag_set( "player_on_minigun" );

		for ( ;; )
		{
			if ( !self player_on_minigun() )
				break;
			wait( 0.05 );
		}
		flag_clear( "player_on_minigun" );
		flag_set( "player_off_minigun" );
		wait( 0.05 );
		self stop_loop_sound_on_entity( "minigun_heli_gatling_fire" );
		self notify( "stop sound" + "minigun_heli_gatling_fire" );
		self.playingLoopSound = false;
		level notify( "stopMinigunSound" );
		break;

		//level thread overheat_disable();
		//self.rumble_ent stoprumble( "minigun_rumble" );
	}
}

player_on_minigun()
{
	//self ==> either the turret or the script_vehicle with the turret
	self endon( "death" );
	owner = undefined;
	if ( !isdefined( self ) )
		return false;
	if ( self.classname == "script_vehicle" )
	{
		owner = self getvehicleowner();
		if ( isdefined( owner ) && isplayer( owner ) )
			return true;
		else
			return false;
	}
	else
	{
		if ( isdefined( self getturretowner() ) )
			return true;
		else
			return false;
	}
}

minigun_rumble()
{
	self endon( "death" );
	//push the rumble origin in and out based on the momentum
	closedist = 0;
	fardist = 750;

	between = fardist - closedist;

	self.rumble_ent = spawn( "script_origin", self.minigunUser.origin );
	self.rumble_ent linkto( self.minigunUser );
	while ( flag( "player_on_minigun" ) )
	{
		wait .05;
		if ( self.momentum <= 0 || !flag( "player_on_minigun" ) )
		{
			continue;
		}
		//org = level.player geteye() + vector_multiply( vectornormalize(  anglestoforward( level.player getplayerangles() ) ), fardist - ( between * self.momentum ) );
		self.rumble_ent.origin = self.minigunUser geteye() + ( 0, 0, fardist - ( between * self.momentum ) );
		self.rumble_ent PlayRumbleOnentity( "minigun_rumble" );
	}
	self.rumble_ent delete();
}

minigun_fire_sounds()
{
	self endon( "death" );
	//Only need this logic for vehicle mounted miniguns
	if ( self.classname != "script_vehicle" )
		return;
	level endon( "player_off_minigun" );
	self.playingLoopSound = false;
	while ( flag( "player_on_minigun" ) )
	{
		wait( 0.05 );
		if ( ( self.minigunUser attackbuttonpressed() ) && ( self.allowedToFire == true ) )
		{
			self thread minigun_fire_loop();
			waittill_player_not_holding_fire_trigger_or_overheat();			
		}
		if ( self.playingLoopSound == true )
		{
			self notify( "stop sound" + "minigun_heli_gatling_fire" );
			self.playingLoopSound = false;
		}
	}
}

minigun_fire_loop()
{
	level endon( "player_off_minigun" );
	level endon( "player_off_blackhawk_gun" );
	self notify( "playing_fire_loop_sound" );
	self endon( "playing_fire_loop_sound" );
	self.playingLoopSound = true;
	self thread play_loop_sound_on_tag( "minigun_heli_gatling_fire", "tag_flash" );
}

waittill_player_not_holding_fire_trigger_or_overheat()
{
	while ( ( self.minigunUser attackbuttonpressed() ) && ( self.allowedToFire == true ) )
		wait( 0.05 );
}

minigun_fire()
{
	self endon( "death" );
	//Only need this logic for vehicle mounted miniguns
	if ( self.classname != "script_vehicle" )
		return;
		
	level endon( "player_off_minigun" );
	while( flag( "player_on_minigun" ) )
	{
		self waittill( "turret_fire" );
		if ( self.allowedToFire == false )
			continue;
		self fireWeapon();
		earthquake( 0.25, .13, self GetTagOrigin( "tag_turret" ), 200 );
		wait( 0.01 );
	}
}

minigun_used()
{
	level endon( "player_off_minigun" );
	flag_wait( "player_on_minigun" );

	//Tweakable values	

	if ( level.console )
		overheat_time = 6;	// full usage to overheat( original 8 )
	else
		overheat_time = 10;

	cooldown_time = 4;	// time to cool down from max heat back to 0 if not operated during this time( original 4 )
	penalty_time = 7;	// hold inoperative for this amount of time
	rate = 0.02;
	slow_rate = 0.02;
	overheat_fx_rate = 0.35;

	adsbuttonAccumulate = 0;// check for left trigger hold down duration

	//Not to tweak
	self.allowedToFire = false;
	heatrate = 1 / ( overheat_time * 20 );	// increment of the temp gauge for heating up
	coolrate = 1 / ( cooldown_time * 20 );	// increment of the temp gauge for cooling down
	level.inuse = false;
	momentum = 0;
	self.momentum = 0;
	heat = 0;
	max = 1;
	maxed = false;
	firing = false;
	maxed_time = undefined;
	overheated = false;
	penalized_time = 0;	// if greater than gettime
	startFiringTime = undefined;
	oldheat = 0;
	level.frames = 0;
	level.normframes = 0;
	next_overheat_fx = 0;
	//thread minigun_rumble();
	self thread minigun_fire();
	self thread minigun_fire_sounds();
	for ( ;; )
	{
		level.normframes++ ;
		if ( flag( "player_on_minigun" ) )
		{
			if ( !level.inuse )
			{
				if ( ( self.minigunUser adsbuttonpressed() ) || ( self.minigunUser attackbuttonpressed() ) )
				{
						level.inuse = true;
						self thread minigun_sound_spinup();
				}
			}
			else
			{
				if ( ( !self.minigunUser attackbuttonpressed() ) && ( !self.minigunUser adsbuttonpressed() ) )
				{
					level.inuse = false;
					self thread minigun_sound_spindown();
				}
				else
				if ( self.minigunUser attackbuttonpressed() && overheated )
				{
					level.inuse = false;
					self thread minigun_sound_spindown();
				}
			}

			if ( !firing )
			{
				if ( self.minigunUser attackbuttonpressed() && !overheated && maxed )
				{
					firing = true;
					startFiringTime = gettime();
				}
				else
				if ( self.minigunUser attackbuttonpressed() && overheated )
				{
					firing = false;
					startFiringTime = undefined;
				}
			}
			else
			{
				if ( !self.minigunUser attackbuttonpressed() )
				{
					firing = false;
					startFiringTime = undefined;
				}

				if ( self.minigunUser attackbuttonpressed() && !maxed )
				{
					firing = false;
					startFiringTime = undefined;
				}
			}
		}
		else
		{
			if ( firing || level.inuse == true )
			{
				self thread minigun_sound_spindown();
			}

			firing = false;
			level.inuse = false;
		}

//		if ( overheated )
//		{
//			if ( !( heat >= max ) )
//			{
//				overheated = false;
//				startFiringTime = undefined;
//				self enable_turret_fire();
//			}
//		}

		if ( level.inuse )
		{
			momentum += rate;
			self.momentum = momentum;
		}
		else
		{
			momentum -= slow_rate;
			self.momentum = momentum;
		}

		if ( momentum > max )
		{
			momentum = max;
			self.momentum = momentum;
		}
		if ( momentum < 0 )
		{
			momentum = 0;
			self.momentum = momentum;
			self notify( "done" );
		}


//-----making max always true and commenting out rest to get rid of having to spin up
		maxed = true;
		self enable_turret_fire();

//		if ( momentum == max )
//		{
//			maxed = true;
//			maxed_time = gettime();
//			self enable_turret_fire();
//		}
//		else
//		{
//			maxed = false;
//			self disable_turret_fire();
//		}

//-----making max always true and commenting out rest to get rid of having to spin up






//		if ( firing && !overheated )
//		{
//			level.frames++ ;
//			heat += heatrate;
//		}
//
//		if ( gettime() > penalized_time && !firing )
//			heat -= coolrate;
//
//		if ( heat > max )
//				heat = max;
//		if ( heat < 0 )
//				heat = 0;
//
//		level.heat = heat;
//
//		level.turret_heat_status = int( heat * 114 );
//		if ( isdefined( level.overheat_status2 ) )
//			thread overheat_hud_update();
//
//		if ( ( heat >= max ) && ( heat <= max ) && ( ( oldheat < max ) || ( oldheat > max ) ) )
//		{
//			overheated = true;
//			penalized_time = gettime() + penalty_time * 1000;
//			next_overheat_fx = 0;
//			thread overheat_overheated();
//		}
//		oldheat = heat;
//
//		if ( overheated )
//		{
//			self disable_turret_fire();
//			firing = false;
//			//playfxOnTag( getfx( "_minigun_overheat_haze" ), self, "tag_flash");
//			if ( gettime() > next_overheat_fx )
//			{
//				playfxOnTag( getfx( "_minigun_overheat_smoke" ), self, "tag_flash" );
//				next_overheat_fx = gettime() + overheat_fx_rate * 1000;
//			}
//		}
		self setanim( getanim( "spin" ), 1, 0.2, momentum );
		wait( 0.05 );
	}
}

disable_turret_fire()
{
	//self ==> the turret entity or the script_vehicle with the turret
	self.allowedToFire = false;
	if ( self.classname != "script_vehicle" )
		self TurretFireDisable();

}

enable_turret_fire()
{
	//self ==> the turret entity or the script_vehicle with the turret
	self.allowedToFire = true;
	if ( self.classname != "script_vehicle" )
		self TurretFireEnable();
		
}

minigun_sound_spinup()
{
	level endon( "player_off_minigun" );
	level endon( "player_off_blackhawk_gun" );
	level notify( "stopMinigunSound" );
	level endon( "stopMinigunSound" );

	/*
	Minigun_heli_gatling_spinup1 0.6 s
	Minigun_heli_gatling_spinup2 0.5 s
	Minigun_heli_gatling_spinup3 0.5 s
	Minigun_heli_gatling_spinup4 0.5 s
	*/

	if ( self.momentum < 0.25 )
	{
		self playsound( "minigun_heli_gatling_spinup1" );
		wait 0.6;
		self playsound( "minigun_heli_gatling_spinup2" );
		wait 0.5;
		self playsound( "minigun_heli_gatling_spinup3" );
		wait 0.5;
		self playsound( "minigun_heli_gatling_spinup4" );
		wait 0.5;
	}
	else
	if ( self.momentum < 0.5 )
	{
		self playsound( "minigun_heli_gatling_spinup2" );
		wait 0.5;
		self playsound( "minigun_heli_gatling_spinup3" );
		wait 0.5;
		self playsound( "minigun_heli_gatling_spinup4" );
		wait 0.5;
	}
	else
	if ( self.momentum < 0.75 )
	{
		self playsound( "minigun_heli_gatling_spinup3" );
		wait 0.5;
		self playsound( "minigun_heli_gatling_spinup4" );
		wait 0.5;
	}
	else
	if ( self.momentum < 1 )
	{
		self playsound( "minigun_heli_gatling_spinup4" );
		wait 0.5;
	}

	thread minigun_sound_spinloop();
}

minigun_sound_spinloop()
{
	//Minigun_heli_gatling_spinloop  (loops until canceled) 2.855 s
	level endon( "player_off_minigun" );
	level endon( "player_off_blackhawk_gun" );
	level notify( "stopMinigunSound" );
	level endon( "stopMinigunSound" );

	while ( 1 )
	{
		self playsound( "minigun_heli_gatling_spin" );
		wait 2.5;
	}
}

minigun_sound_spindown()
{
	level endon( "player_off_minigun" );
	level endon( "player_off_blackhawk_gun" );
	level notify( "stopMinigunSound" );
	level endon( "stopMinigunSound" );

	/*
	Minigun_heli_gatling_spindown4 0.5 s
	Minigun_heli_gatling_spindown3 0.5 s
	Minigun_heli_gatling_spindown2 0.5 s
	Minigun_heli_gatling_spindown1 0.65 s
	*/

	if ( self.momentum > 0.75 )
	{
		self stopsounds();
		self playsound( "minigun_heli_gatling_spindown4" );
		wait 0.5;
		self playsound( "minigun_heli_gatling_spindown3" );
		wait 0.5;
		self playsound( "minigun_heli_gatling_spindown2" );
		wait 0.5;
		self playsound( "minigun_heli_gatling_spindown1" );
		wait 0.65;
	}
	else
	if ( self.momentum > 0.5 )
	{
		self playsound( "minigun_heli_gatling_spindown3" );
		wait 0.5;
		self playsound( "minigun_heli_gatling_spindown2" );
		wait 0.5;
		self playsound( "minigun_heli_gatling_spindown1" );
		wait 0.65;
	}
	else
	if ( self.momentum > 0.25 )
	{
		self playsound( "minigun_heli_gatling_spindown2" );
		wait 0.5;
		self playsound( "minigun_heli_gatling_spindown1" );
		wait 0.65;
	}
	else
	{
		self playsound( "minigun_heli_gatling_spindown1" );
		wait 0.65;
	}
}

//overheat_enable()
//{
//	//Draw the temperature gauge
//
//	//level.turretOverheat = true;
//	level thread overheat_hud();
//	flag_clear( "disable_overheat" );
//}

//overheat_disable()
//{
//	//Erase the temperature gauge
//
//	//level.turretOverheat = false;
//	//level notify ( "disable_overheat" );
//	flag_set( "disable_overheat" );
//	level.savehere = undefined;
//
//	waittillframeend;
//
//	if ( isdefined( level.overheat_bg ) )
//		level.overheat_bg destroy();
//	if ( isdefined( level.overheat_status ) )
//		level.overheat_status destroy();
//	if ( isdefined( level.overheat_status2 ) )
//		level.overheat_status2 destroy();
//	if ( isdefined( level.overheat_flashing ) )
//		level.overheat_flashing destroy();
//}
//
//overheat_hud()
//{
//	//Draw the temperature gauge and filler bar components
//
//	level endon( "disable_overheat" );
//	if ( !isdefined( level.overheat_bg ) )
//	{
//		level.overheat_bg = newhudelem();
//		level.overheat_bg.alignX = "right";
//		level.overheat_bg.alignY = "bottom";
//		level.overheat_bg.horzAlign = "right";
//		level.overheat_bg.vertAlign = "bottom";
//		level.overheat_bg.x = 2;
//		level.overheat_bg.y = -120;
//		level.overheat_bg setShader( "hud_temperature_gauge", 35, 150 );
//		level.overheat_bg.sort = 4;
//	}
//
//	barX = -10;
//	barY = -152;
//
//	//status bar
//	if ( !isdefined( level.overheat_status ) )
//	{
//		level.overheat_status = newhudelem();
//		level.overheat_status.alignX = "right";
//		level.overheat_status.alignY = "bottom";
//		level.overheat_status.horzAlign = "right";
//		level.overheat_status.vertAlign = "bottom";
//		level.overheat_status.x = barX;
//		level.overheat_status.y = barY;
//		level.overheat_status setShader( "white", 10, 0 );
//		level.overheat_status.color = ( 1, .9, 0 );
//		level.overheat_status.alpha = 0;
//		level.overheat_status.sort = 1;
//	}
//
//	//draw fake bar to cover up a hitch
//
//	if ( !isdefined( level.overheat_status2 ) )
//	{
//		level.overheat_status2 = newhudelem();
//		level.overheat_status2.alignX = "right";
//		level.overheat_status2.alignY = "bottom";
//		level.overheat_status2.horzAlign = "right";
//		level.overheat_status2.vertAlign = "bottom";
//		level.overheat_status2.x = barX;
//		level.overheat_status2.y = barY;
//		level.overheat_status2 setShader( "white", 10, 0 );
//		level.overheat_status2.color = ( 1, .9, 0 );
//		level.overheat_status2.alpha = 0;
//		level.overheat_status.sort = 2;
//	}
//
//	if ( !isdefined( level.overheat_flashing ) )
//	{
//		level.overheat_flashing = newhudelem();
//		level.overheat_flashing.alignX = "right";
//		level.overheat_flashing.alignY = "bottom";
//		level.overheat_flashing.horzAlign = "right";
//		level.overheat_flashing.vertAlign = "bottom";
//		level.overheat_flashing.x = barX;
//		level.overheat_flashing.y = barY;
//		level.overheat_flashing setShader( "white", 10, level.turret_heat_max );
//		level.overheat_flashing.color = ( .8, .16, 0 );
//		level.overheat_flashing.alpha = 0;
//		level.overheat_status.sort = 3;
//	}
//}
//
//overheat_overheated()
//{
//	//Gun has overheated - flash full temp bar, do not drain
//
//	level endon( "disable_overheat" );
//	if ( !flag( "disable_overheat" ) )
//	{
//		level.savehere = false;
//		level.player thread play_sound_on_entity( "smokegrenade_explode_default" );
//
//		level.overheat_flashing.alpha = 1;
//		level.overheat_status.alpha = 0;
//		level.overheat_status2.alpha = 0;
//
//		level notify( "stop_overheat_drain" );
//		level.turret_heat_status = level.turret_heat_max;
//		thread overheat_hud_update();
//
//		for ( i = 0;i < 4;i++ )
//		{
//			level.overheat_flashing fadeovertime( 0.5 );
//			level.overheat_flashing.alpha = 0.5;
//			wait 0.5;
//			level.overheat_flashing fadeovertime( 0.5 );
//			level.overheat_flashing.alpha = 1.0;
//		}
//		level.overheat_flashing fadeovertime( 0.5 );
//		level.overheat_flashing.alpha = 0.0;
//		level.overheat_status.alpha = 1;
//		wait 0.5;
//
//		thread overheat_hud_drain();
//
//		wait 2;
//		level.savehere = undefined;
//	}
//}
//
//overheat_hud_update()
//{
//	level endon( "disable_overheat" );
//	level notify( "stop_overheat_drain" );
//
//	if ( level.turret_heat_status > 1 )
//		level.overheat_status.alpha = 1;
//	else
//	{
//		level.overheat_status.alpha = 0;
//		level.overheat_status fadeovertime( 0.25 );
//	}
//
//	if ( isdefined( level.overheat_status2 ) && level.turret_heat_status > 1 )
//	{
//		level.overheat_status2.alpha = 1;
//		level.overheat_status2 setShader( "white", 10, int( level.turret_heat_status ) );
//		level.overheat_status scaleovertime( 0.05, 10, int( level.turret_heat_status ) );
//	}
//	else
//	{
//		level.overheat_status2.alpha = 0;
//		level.overheat_status2 fadeovertime( 0.25 );
//	}
//
//	//set color of bar
//	overheat_setColor( level.turret_heat_status );
//
//	wait 0.05;
//	if ( isdefined( level.overheat_status2 ) )
//		level.overheat_status2.alpha = 0;
//	if ( isdefined( level.overheat_status ) && level.turret_heat_status < level.turret_heat_max )
//		thread overheat_hud_drain();
//}
//
//overheat_setColor( value, fadeTime )
//{
//	level endon( "disable_overheat" );
//
//	//define what colors to use
//	color_cold = [];
//	color_cold[ 0 ] = 1.0;
//	color_cold[ 1 ] = 0.9;
//	color_cold[ 2 ] = 0.0;
//	color_warm = [];
//	color_warm[ 0 ] = 1.0;
//	color_warm[ 1 ] = 0.5;
//	color_warm[ 2 ] = 0.0;
//	color_hot = [];
//	color_hot[ 0 ] = 0.9;
//	color_hot[ 1 ] = 0.16;
//	color_hot[ 2 ] = 0.0;
//
//	//default color
//	SetValue = [];
//	SetValue[ 0 ] = color_cold[ 0 ];
//	SetValue[ 1 ] = color_cold[ 1 ];
//	SetValue[ 2 ] = color_cold[ 2 ];
//
//	//define where the non blend points are
//	cold = 0;
//	warm = ( level.turret_heat_max / 2 );
//	hot = level.turret_heat_max;
//
//	iPercentage = undefined;
//	difference = undefined;
//	increment = undefined;
//
//	if ( ( value > cold ) && ( value <= warm ) )
//	{
//		iPercentage = int( value * ( 100 / warm ) );
//		for ( colorIndex = 0 ; colorIndex < SetValue.size ; colorIndex++ )
//		{
//			difference = ( color_warm[ colorIndex ] - color_cold[ colorIndex ] );
//			increment = ( difference / 100 );
//			SetValue[ colorIndex ] = color_cold[ colorIndex ] + ( increment * iPercentage );
//		}
//	}
//	else if ( ( value > warm ) && ( value <= hot ) )
//	{
//		iPercentage = int( ( value - warm ) * ( 100 / ( hot - warm ) ) );
//		for ( colorIndex = 0 ; colorIndex < SetValue.size ; colorIndex++ )
//		{
//			difference = ( color_hot[ colorIndex ] - color_warm[ colorIndex ] );
//			increment = ( difference / 100 );
//			SetValue[ colorIndex ] = color_warm[ colorIndex ] + ( increment * iPercentage );
//		}
//	}
//
//	if ( isdefined( fadeTime ) )
//		level.overheat_status fadeOverTime( fadeTime );
//
//	if ( isdefined( level.overheat_status.color ) )
//		level.overheat_status.color = ( SetValue[ 0 ], SetValue[ 1 ], SetValue[ 2 ] );
//
//	if ( isdefined( level.overheat_status2.color ) )
//		level.overheat_status2.color = ( SetValue[ 0 ], SetValue[ 1 ], SetValue[ 2 ] );
//}
//
//overheat_hud_drain()
//{
//	level endon( "disable_overheat" );
//	level endon( "stop_overheat_drain" );
//
//	waitTime = 1.0;
//	for ( ;; )
//	{
//		if ( level.turret_heat_status > 1 )
//			level.overheat_status.alpha = 1;
//
//		value = level.turret_heat_status - level.turret_cooldownrate;
//		thread overheat_status_rampdown( value, waitTime );
//		if ( value < 1 )
//			value = 1;
//		level.overheat_status scaleovertime( waitTime, 10, int( value ) );
//		overheat_setColor( level.turret_heat_status, waitTime );
//		wait waitTime;
//
//		if ( isdefined( level.overheat_status ) && level.turret_heat_status <= 1 )
//			level.overheat_status.alpha = 0;
//
//		if ( isdefined( level.overheat_status2 ) && level.turret_heat_status <= 1 )
//			level.overheat_status2.alpha = 0;
//	}
//}
//
//overheat_status_rampdown( targetvalue, time )
//{
//	level endon( "disable_overheat" );
//	level endon( "stop_overheat_drain" );
//
//	frames = ( 20 * time );
//	difference = ( level.turret_heat_status - targetvalue );
//	frame_difference = ( difference / frames );
//
//	for ( i = 0; i < frames; i++ )
//	{
//		level.turret_heat_status -= frame_difference;
//		if ( level.turret_heat_status < 1 )
//		{
//			level.turret_heat_status = 1;
//			return;
//		}
//		wait 0.05;
//	}
//}

minigun_hints_on()
{
	level.minigunHintSpin = createFontString( "default", 1.5 );
	level.minigunHintSpin setPoint( "TOPLEFT", undefined, 0, 50 );
	level.minigunHintSpin setText( &"SCRIPT_PLATFORM_MINIGUN_SPIN_HINT" );
	level.minigunHintSpin.sort = 1;
	level.minigunHintSpin.alpha = 0;
	
	level.minigunHintFire = createFontString( "default", 1.5 );
	level.minigunHintFire setPoint( "TOPRIGHT", undefined, 0, 50 );
	level.minigunHintFire setText( &"SCRIPT_PLATFORM_MINIGUN_FIRE_HINT" );
	level.minigunHintFire.sort = 1;
	level.minigunHintFire.alpha = 0;


	level.hintbackground1 = createIcon( "popmenu_bg", 200, 23 );
	level.hintbackground1.hidewheninmenu = true;
	level.hintbackground1 setPoint( "TOPLEFT", undefined, -80, 47 );
	level.hintbackground1.alpha = 0;

	level.hintbackground2 = createIcon( "popmenu_bg", 150, 23 );
	level.hintbackground2.hidewheninmenu = true;
	level.hintbackground2 setPoint( "TOPRIGHT", undefined, 60, 47 );
	level.hintbackground2.alpha = 0;
	
	level.minigunHintFire fadeovertime( .5 );
	level.minigunHintFire.alpha = .8;
	level.minigunHintSpin fadeovertime( .5 );
	level.minigunHintSpin.alpha = .8;
	level.hintbackground1 fadeovertime( .5 );
	level.hintbackground1.alpha = .8;
	level.hintbackground2 fadeovertime( .5 );
	level.hintbackground2.alpha = .8;
}

minigun_hints_off()
{

	level.minigunHintFire fadeovertime( .5 );
	level.minigunHintFire.alpha = 0;
	level.minigunHintSpin fadeovertime( .5 );
	level.minigunHintSpin.alpha = 0;
	level.hintbackground1 fadeovertime( .5 );
	level.hintbackground1.alpha = 0;
	level.hintbackground2 fadeovertime( .5 );
	level.hintbackground2.alpha = 0;
	
	level.minigunHintFire destroyElem();
	level.minigunHintSpin destroyElem();
	level.hintbackground1 destroyElem();
	level.hintbackground2 destroyElem();
}