#include maps\_vehicle;
#include maps\_vehicle_aianim;
#include maps\_utility;
#include common_scripts\utility;
#using_animtree( "vehicles" );

main( model, type )
{
	build_template( "snowmobile", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_snowmobile", "vehicle_snowmobile_static" );
	build_deathfx( "explosions/large_vehicle_explosion", undefined, "explo_metal_rand" );
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_compassicon( "automobile", false );
	build_team( "allies" );
	build_unload_groups( ::Unload_Groups );

	if ( !isDefined( anim._effect ) )
		anim._effect = [];
	
	
	anim._effect[ "snowmobile_leftground"	] = loadfx( "treadfx/bigair_snow_snowmobile_emitter" );
	anim._effect[ "snowmobile_bumpbig"		] = loadfx( "treadfx/bigjump_land_snow_snowmobile" );
	anim._effect[ "snowmobile_bump"			] = loadfx( "treadfx/smalljump_land_snow_snowmobile" );
//	anim._effect[ "snowmobile_sway_left"	] = loadfx( "treadfx/leftturn_snow_snowmobile" );
//	anim._effect[ "snowmobile_sway_right"	] = loadfx( "treadfx/rightturn_snow_snowmobile" );
//	anim._effect[ "snowmobile_collision"	] = loadfx( "explosions/grenadeExp_snow" );
	
}

init_local()
{
	self.driver_shooting = false;
	self.passenger_shooting = true;
	self.steering_enable = true;
	self.steering_maxroll = 15;
	self.steering_maxdelta = 0.15;
	self.steering = 0;
	self.update_time = -1;
	
	if ( !is_specialop() )
		self thread do_steering();

	self.bigjump_timedelta = 500;
	self.event_time = -1;
	self.event = [];
	self.event[ "jump" ] = [];
	self.event[ "jump" ][ "driver" ] = false;
	self.event[ "jump" ][ "passenger" ] = false;
	self.event[ "bump" ] = [];
	self.event[ "bump" ][ "driver" ] = false;
	self.event[ "bump" ][ "passenger" ] = false;
	self.event[ "bump_big" ] = [];
	self.event[ "bump_big" ][ "driver" ] = false;
	self.event[ "bump_big" ][ "passenger" ] = false;
	self.event[ "sway_left" ] = [];
	self.event[ "sway_left" ][ "driver" ] = false;
	self.event[ "sway_left" ][ "passenger" ] = false;
	self.event[ "sway_right" ] = [];
	self.event[ "sway_right" ][ "driver" ] = false;
	self.event[ "sway_right" ][ "passenger" ] = false;
	self thread watchVelocity();
	self thread listen_leftground();
	self thread listen_landed();
	self thread listen_jolt();
	self thread listen_collision();
	
	self thread setRiderShooting();
	
	if ( issubstr( self.vehicletype, "player" ) )
	{
		glock = spawn( "script_model", (0,0,0) );
		glock setmodel( "viewmodel_glock" );
		glock linkto( self, "tag_origin", (0,0,0), (0,0,0) );
		glock hideallparts();
	}
}

watchVelocity()
{
	self endon( "death" );
	vel = self Vehicle_GetVelocity();
	for ( ;; )
	{
		self.prevFrameVelocity = vel;
		vel = self Vehicle_GetVelocity();
		wait .05;
	}
}

setRiderShooting()
{
	self endon( "death" );
	waittillframeend;
	
	if ( self.riders.size == 1 )
	{
		// no passenger, make the driver shoot
		self.driver_shooting = true;
		self.passenger_shooting = false;
	}
}

snowmobile_fx( fxName )
{
	if ( isDefined( anim._effect[ fxName ] ) )
		playFxOnTag( anim._effect[ fxName ], self, "tag_deathfx" );
		//println( fxName );
}


listen_leftground()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "veh_leftground" );
		self.event_time = gettime();
		self.event[ "jump" ][ "driver" ] = true;
		self.event[ "jump" ][ "passenger" ] = true;
		
		snowmobile_fx( "snowmobile_leftground" );
	}
}


listen_landed()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "veh_landed" );
		if ( self.event_time + self.bigjump_timedelta < gettime() )
		{
			self.event[ "bump_big" ][ "driver" ] = true;
			self.event[ "bump_big" ][ "passenger" ] = true;
			
			snowmobile_fx( "snowmobile_bumpbig" );
		}
		else
		{
			self.event[ "bump" ][ "driver" ] = true;
			self.event[ "bump" ][ "passenger" ] = true;
			
			snowmobile_fx( "snowmobile_bump" );
		}
	}
}


listen_jolt()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "veh_jolt", jolt );
		if ( jolt[ 1 ] >= 0 )
		{
			self.event[ "sway_left" ][ "driver" ] = true;
			self.event[ "sway_left" ][ "passenger" ] = true;
			
			snowmobile_fx( "snowmobile_sway_left" );
		}
		else
		{
			self.event[ "sway_right" ][ "driver" ] = true;
			self.event[ "sway_right" ][ "passenger" ] = true;
			
			snowmobile_fx( "snowmobile_sway_right" );
		}
	}
}

listen_collision()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "veh_collision", collision, start_vel );
		
		foreach ( rider in self.riders )
		{
			if ( isalive( rider ) && !isdefined( rider.magic_bullet_shield ) )
			{
				rider.specialDeathFunc = animscripts\snowmobile::snowmobile_collide_death;
				rider kill();
			}
		}
		snowmobile_fx( "snowmobile_collision" );
	}
}

do_steering()
{
	self endon( "death" );
	
	wait( 0.05 );

	self setanimknoball( %snowmobile, %root, 1, 0 );
	self setanimlimited( %sm_turn, 1, 0 );

	for ( ;; )
	{
		update_steering( self );

		if ( self.steering_enable )
		{
			if ( self.steering >= 0 )
			{
				self setanimknoblimited( %snowmobile_vehicle_lean_R_delta, 1, 0, 0 );
				self setanimtime( %snowmobile_vehicle_lean_R_delta, self.steering );
			}
			else
			{
				self setanimknoblimited( %snowmobile_vehicle_lean_L_delta, 1, 0, 0 );
				self setanimtime( %snowmobile_vehicle_lean_L_delta, abs( self.steering ) );
			}
		}
		else
		{
			self clearanim( %snowmobile_vehicle_lean_R_delta, 0 );
			self clearanim( %snowmobile_vehicle_lean_L_delta, 0 );
		}

		wait( 0.05 );
	}
}

init_snowmobile_mount_anims()
{
	
	level.snowmobile_mount_anims = [];
	level.snowmobile_mount_anims[ "snowmobile_passenger" ] = [];
	level.snowmobile_mount_anims[ "snowmobile_driver" ] = [];

	// go through all the generic anims and find ones with the specific prefix
	foreach ( scene_name, animation in level.scr_anim["generic"] )
	{
		if ( issubstr( scene_name, "snowmobile_passenger_mount" ) )
		{
			level.snowmobile_mount_anims[ "snowmobile_passenger" ][ scene_name ] = true;
			continue;
		}
		
		if ( issubstr( scene_name, "snowmobile_driver_mount" ) )
		{
			level.snowmobile_mount_anims[ "snowmobile_driver" ][ scene_name ] = true;
		}
	}
}



set_vehicle_anims( positions )
{
	return positions;
}

#using_animtree( "generic_human" );
setanims()
{
	level.scr_anim[ "generic" ][ "snowmobile_passenger_mount_dir1" ]					= %snowmobile_passenger_mount_dir3;
	level.scr_anim[ "generic" ][ "snowmobile_passenger_mount_dir3" ]					= %snowmobile_passenger_mount_dir1;
	level.scr_anim[ "generic" ][ "snowmobile_driver_mount_dir3" ] 						= %snowmobile_driver_mount_dir3;
	level.scr_anim[ "generic" ][ "snowmobile_driver_mount_dir1" ] 						= %snowmobile_driver_mount_dir1;

	level.scr_anim[ "generic" ][ "snowmobile_passenger_mount_dir1_short" ]				= %snowmobile_passenger_mount_dir3_short;
	level.scr_anim[ "generic" ][ "snowmobile_passenger_mount_dir3_short" ]				= %snowmobile_passenger_mount_dir1_short;
	level.scr_anim[ "generic" ][ "snowmobile_driver_mount_dir3_short" ] 				= %snowmobile_driver_mount_dir3_short;
	level.scr_anim[ "generic" ][ "snowmobile_driver_mount_dir1_short" ] 				= %snowmobile_driver_mount_dir1_short;
	
	level.scr_anim[ "snowmobile" ][ "driver" ][ "idle" ]                                = %snowmobile_driver_aiming_idle;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "drive" ]                               = %snowmobile_driver_driving_idle;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "left2right" ]                          = %snowmobile_driver_lean_L2R;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "right2left" ]                          = %snowmobile_driver_lean_R2L;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "fire" ]                                = %snowmobile_driver_autofire;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "single" ]                              = %snowmobile_driver_fire;

	level.scr_anim[ "snowmobile" ][ "driver" ][ "drive_jump" ]                          = %snowmobile_driver_driving_jump_01;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "drive_bump" ]                          = %snowmobile_driver_driving_bump_01;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "drive_bump_big" ]                      = %snowmobile_driver_driving_bump_02;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "drive_sway_left" ]                     = %snowmobile_driver_driving_swayL_01;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "drive_sway_right" ]                    = %snowmobile_driver_driving_swayR_01;
	
	level.scr_anim[ "snowmobile" ][ "driver" ][ "shoot_jump" ]                          = %snowmobile_driver_aiming_jump_01;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "shoot_bump" ]                          = %snowmobile_driver_aiming_bump_01;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "shoot_bump_big" ]                      = %snowmobile_driver_aiming_bump_02;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "shoot_sway_left" ]                     = %snowmobile_driver_aiming_swayL_01;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "shoot_sway_right" ]                    = %snowmobile_driver_aiming_swayR_01;
	
	level.scr_anim[ "snowmobile" ][ "driver" ][ "add_aim_left" ][ "left" ]              = %snowmobile_driver_aim4L_add;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "add_aim_left" ][ "center" ]            = %snowmobile_driver_aim4C_add;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "add_aim_left" ][ "right" ]             = %snowmobile_driver_aim4R_add;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "straight_level" ][ "left" ]            = %snowmobile_driver_aim5L;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "straight_level" ][ "center" ]          = %snowmobile_driver_aim5C;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "straight_level" ][ "right" ]           = %snowmobile_driver_aim5R;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "add_aim_right" ][ "left" ]             = %snowmobile_driver_aim6L_add;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "add_aim_right" ][ "center" ]           = %snowmobile_driver_aim6C_add;
	level.scr_anim[ "snowmobile" ][ "driver" ][ "add_aim_right" ][ "right" ]            = %snowmobile_driver_aim6R_add;


	level.scr_anim[ "snowmobile" ][ "passenger" ][ "hide" ]                             = %snowmobile_passenger_hide;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "drive" ]                            = %snowmobile_passenger_driving_idle;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "add_lean" ][ "left" ]               = %snowmobile_passenger_lean_L;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "add_lean" ][ "right" ]              = %snowmobile_passenger_lean_R;

	level.scr_anim[ "snowmobile" ][ "passenger" ][ "idle" ]                             = %snowmobile_passenger_aiming_idle;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "fire" ]                             = %snowmobile_passenger_autofire;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "single" ]                           = %snowmobile_passenger_fire;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "reload" ]                           = %snowmobile_passenger_reload;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "gun_down" ]                         = %snowmobile_passenger_aim2hide;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "gun_up" ]                           = %snowmobile_passenger_hide2aim;

	level.scr_anim[ "snowmobile" ][ "passenger" ][ "hide_jump" ]                        = %snowmobile_passenger_driving_jump_01;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "hide_bump" ]                        = %snowmobile_passenger_driving_bump_01;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "hide_bump_big" ]                    = %snowmobile_passenger_driving_bump_02;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "hide_sway_left" ]                   = %snowmobile_passenger_driving_swayL_01;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "hide_sway_right" ]                  = %snowmobile_passenger_driving_swayR_01;

	level.scr_anim[ "snowmobile" ][ "passenger" ][ "drive_jump" ]                       = %snowmobile_passenger_aiming_jump_01;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "drive_bump" ]                       = %snowmobile_passenger_aiming_bump_01;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "drive_bump_big" ]                   = %snowmobile_passenger_aiming_bump_02;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "drive_sway_left" ]                  = %snowmobile_passenger_aiming_swayL_01;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "drive_sway_right" ]                 = %snowmobile_passenger_aiming_swayR_01;

	level.scr_anim[ "snowmobile" ][ "passenger" ][ "aim_left" ][ "left" ]               = %snowmobile_passenger_aim4L;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "aim_left" ][ "center" ]             = %snowmobile_passenger_aim4C;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "aim_left" ][ "right" ]              = %snowmobile_passenger_aim4R;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "aim_right" ][ "left" ]              = %snowmobile_passenger_aim6L;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "aim_right" ][ "center" ]            = %snowmobile_passenger_aim6C;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "aim_right" ][ "right" ]             = %snowmobile_passenger_aim6R;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "add_aim_backleft" ][ "left" ]       = %snowmobile_passenger_aim1L_add;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "add_aim_backleft" ][ "center" ]     = %snowmobile_passenger_aim1C_add;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "add_aim_backleft" ][ "right" ]      = %snowmobile_passenger_aim1R_add;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "add_aim_backright" ][ "left" ]      = %snowmobile_passenger_aim3L_add;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "add_aim_backright" ][ "center" ]    = %snowmobile_passenger_aim3C_add;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "add_aim_backright" ][ "right" ]     = %snowmobile_passenger_aim3R_add;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "straight_level" ][ "left" ]         = %snowmobile_passenger_aim5L;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "straight_level" ][ "center" ]       = %snowmobile_passenger_aim5C;
	level.scr_anim[ "snowmobile" ][ "passenger" ][ "straight_level" ][ "right" ]        = %snowmobile_passenger_aim5R;

	level.scr_anim[ "snowmobile" ][ "big" ][ "death" ][ "back" ]                        = %snowmobile_driver_death_B_01;
	level.scr_anim[ "snowmobile" ][ "big" ][ "death" ][ "left" ]                        = %snowmobile_driver_death_L_01;
	level.scr_anim[ "snowmobile" ][ "big" ][ "death" ][ "front" ]                       = %snowmobile_driver_death_F_01;
	level.scr_anim[ "snowmobile" ][ "big" ][ "death" ][ "right" ]                       = %snowmobile_driver_death_R_01;
	
	level.scr_anim[ "snowmobile" ][ "small" ][ "death" ][ "back" ]                      = %snowmobile_driver_death_B_03;
	level.scr_anim[ "snowmobile" ][ "small" ][ "death" ][ "left" ]                      = %snowmobile_driver_death_L_03;
	level.scr_anim[ "snowmobile" ][ "small" ][ "death" ][ "right" ]                     = %snowmobile_driver_death_R_03;
	
	init_snowmobile_mount_anims();


	positions = [];
	for ( i = 0; i < 2; i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_passenger";

	positions[ 0 ].getout = %snowmobile_driver_dismount;
	positions[ 1 ].getout = %snowmobile_passenger_dismount;


	return positions;
}



unload_groups()
{
	unload_groups = [];
	unload_groups[ "all" ] = [];

	group = "all";
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ "default" ] = unload_groups[ "all" ];

	return unload_groups;
}






/*QUAKED script_vehicle_snowmobile (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_snowmobile::main( "vehicle_snowmobile" );

and these lines in your CSV:
include,vehicle_snowmobile_snowmobile
sound,vehicle_snowmobile,vehicle_standard,all_sp


defaultmdl="vehicle_snowmobile"
default:"vehicletype" "snowmobile"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_snowmobile_alt (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_snowmobile::main( "vehicle_snowmobile_alt" );

and these lines in your CSV:
include,vehicle_snowmobile_snowmobile
sound,vehicle_snowmobile,vehicle_standard,all_sp


defaultmdl="vehicle_snowmobile_alt"
default:"vehicletype" "snowmobile"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_snowmobile_coop (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_snowmobile::main( "vehicle_snowmobile", "snowmobile_player_coop" );

and these lines in your CSV:
include,vehicle_snowmobile_snowmobile
sound,vehicle_snowmobile,vehicle_standard,all_sp


defaultmdl="vehicle_snowmobile"
default:"vehicletype" "snowmobile_player_coop"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_snowmobile_coop_alt (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_snowmobile::main( "vehicle_snowmobile_alt", "snowmobile_player_coop" );

and these lines in your CSV:
include,vehicle_snowmobile_snowmobile
sound,vehicle_snowmobile,vehicle_standard,all_sp


defaultmdl="vehicle_snowmobile_alt"
default:"vehicletype" "snowmobile_player_coop"
default:"script_team" "allies"
*/