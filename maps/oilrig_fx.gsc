#include common_scripts\utility;
#include maps\_utility;

main()
{
	//LittleBird DeathFX override		
	maps\_vehicle::build_deathfx_override( "littlebird", "vehicle_little_bird_armed", "explosions/helicopter_explosion_secondary_small", 	"tag_engine", 	"littlebird_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		0.0, 		true );
	maps\_vehicle::build_deathfx_override( "littlebird", "vehicle_little_bird_armed", "fire/fire_smoke_trail_L", 							"tag_engine", 	"littlebird_helicopter_dying_loop", 	true, 				0.05, 			true, 			0.5, 		true );
	maps\_vehicle::build_deathfx_override( "littlebird", "vehicle_little_bird_armed", "explosions/helicopter_explosion_secondary_small",	"tag_engine", 	"littlebird_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		2.5, 		true );
	maps\_vehicle::build_deathfx_override( "littlebird", "vehicle_little_bird_armed", "explosions/mortarExp_water", 						undefined, 		"littlebird_helicopter_crash", 			undefined, 			undefined,		undefined, 		- 1, 		undefined, 	"stop_crash_loop_sound" );


	thread precacheFX();
	thread treadfx_override();
	maps\createfx\oilrig_fx::main();
}

precacheFX()
{
	level._effect[ "pipe_steam" ]		 = LoadFX( "impacts/pipe_steam" );
	level._effect[ "firelp_small_pm_nolight" ]					= loadfx( "fire/firelp_small_pm_nolight" );
	level._effect[ "firelp_small_pm" ]							= loadfx( "fire/firelp_small_pm" );
	level._effect[ "minigun_shell_eject" ] 								= loadfx( "shellejects/20mm_mp" );
	
	level._effect[ "cold_breath" ]				 = loadfx( "misc/cold_breath" );
	level._effect[ "player_death_explosion" ]				 = loadfx( "explosions/player_death_explosion" );
	
	level._effect[ "smokescreen" ]	 = loadfx( "smoke/smoke_screen" );

	level._effect[ "sdv_prop_wash_1" ]	 					= loadfx( "water/sdv_prop_wash_1" );
	//level._effect[ "sub_prop_wash_1" ]	 					= loadfx( "water/sdv_prop_wash_1" );
	level._effect[ "sdv_contrail" ]							= loadfx( "smoke/jet_contrail" );
	
	level._effect[ "scuba_bubbles" ]			 			= loadfx( "water/scuba_bubbles_breath" );
	level._effect[ "scuba_bubbles_friendly" ]				= loadfx( "water/scuba_bubbles_breath" );
	level._effect[ "oilrig_underwater_ambient" ]			= loadfx( "water/oilrig_underwater_ambient" );
	level._effect[ "oilrig_underwater_ambient_emitter" ]	= loadfx( "water/oilrig_underwater_ambient_emitter" );
	level._effect[ "oilrig_underwater_ambient_looped" ]		= loadfx( "water/oilrig_underwater_ambient_looped" );
	level._effect[ "fish_school01" ]	 					= loadfx( "animals/fish_school01" );
	level._effect[ "fish_school_top_oilrig_base" ]	 		= loadfx( "animals/fish_school_top_oilrig_base" );
	level._effect[ "fish_school_side_med" ]	 				= loadfx( "animals/fish_school_side_med" );
	level._effect[ "fish_school_side_large" ]	 			= loadfx( "animals/fish_school_side_large" );
	level._effect[ "oilrig_underwater_caustic" ]	 		= loadfx( "water/oilrig_underwater_caustic" );

	level._effect[ "bloodspurt_underwater" ]	 			= loadfx( "water/blood_spurt_underwater" );
	level._effect[ "deathfx_bloodpool_underwater" ]	 		= loadfx( "impacts/deathfx_bloodpool_underwater" );
	level._effect[ "splash_underwater_stealthkill" ]	 	= loadfx( "water/splash_underwater_stealthkill" );
	
	level._effect[ "drips_player_hand" ]	 				= loadfx( "water/drips_player_hand" );

	level._effect[ "oil_rig_fire" ]						 = loadfx( "fire/oil_rig_fire" );
	level._effect[ "wavebreak_oilrig_runner" ]			 = loadfx( "misc/wavebreak_oilrig_runner" );
	level._effect[ "water_froth_oilrig" ]				 = loadfx( "misc/water_froth_oilrig" );
	level._effect[ "water_froth_oilrig_leg_runner" ]	 = loadfx( "misc/water_froth_oilrig_leg_runner" );
	level._effect[ "bird_seagull_flock_large" ]			 = loadfx( "misc/bird_seagull_flock_large" );
	level._effect[ "powerline_runner" ]					 = loadfx( "explosions/powerline_runner" );

 	level._effect[ "oilrig_drips_riser" ]				= loadfx( "water/oilrig_drips_riser" );

 	level._effect[ "splash_ring_32_oilrig" ]			= loadfx( "water/splash_ring_32_oilrig" );
 	level._effect[ "drips_slow" ]					 	= loadfx( "misc/drips_slow" );
 	level._effect[ "steam_vent_small" ]					= loadfx( "smoke/steam_vent_small" );
 	level._effect[ "steam_manhole" ]					= loadfx( "smoke/steam_manhole" );
 	level._effect[ "steam_room_100" ]					= loadfx( "smoke/steam_room_100" );
 	level._effect[ "steam_hall_200" ]					= loadfx( "smoke/steam_hall_200" );
 	level._effect[ "steam_room_100_orange" ]			= loadfx( "smoke/steam_room_100_orange" );
 	level._effect[ "steam_hall_200_orange" ]			= loadfx( "smoke/steam_hall_200_orange" );
	level._effect[ "light_glow_grating_yellow" ]		= loadfx( "misc/light_glow_grating_yellow" );
	level._effect[ "oilrig_debri_large" ]		 		= loadfx( "misc/oilrig_debri_large" );
 	level._effect[ "ground_fog_oilrig" ]				= loadfx( "smoke/ground_fog_oilrig" );
 	level._effect[ "ground_fog_oilrig_far" ]			= loadfx( "smoke/ground_fog_oilrig_far" );

	level._effect[ "thin_black_smoke_M" ]				 = loadfx( "smoke/thin_black_smoke_M_nofog" );
	level._effect[ "thin_black_smoke_L" ]				 = loadfx( "smoke/thin_black_smoke_L_nofog" );
	level._effect[ "thin_black_smoke_S" ]				 = loadfx( "smoke/thin_black_smoke_S_nofog" );

	level._effect[ "underwater_particulates_01" ]		= loadfx( "dust/light_shaft_dust_large" );
 	level._effect[ "underwater_particulates_02" ]		= loadfx( "dust/room_dust_200" );
 	level._effect[ "underwater_particulates_03" ]		= loadfx( "dust/room_dust_100" );


	level._effect[ "body_splash_railing" ]			 	= loadfx( "impacts/water_splash_bodydump" );

	level._effect[ "ambush_explosion_03" ]			 	= loadfx( "explosions/window_explosion_1_oilrig" );
	level._effect[ "ambush_explosion_room" ]			= loadfx( "explosions/room_explosion_oilrig" );
	level._effect[ "light_c4_blink_nodlight" ] 			= loadfx( "misc/light_c4_blink_nodlight" );

	level._effect[ "zodiac_wake_geotrail_oilrig" ]		= loadfx( "treadfx/zodiac_wake_geotrail_oilrig" );

	level._effect[ "sub_surface_runner" ]			 	 = loadfx( "water/sub_surface_runner" );

	// "hunted light" required zfeather == 1 and r_zfeather is undefined on console.  So, test for != "0".
	if ( getdvarint( "sm_enable" ) && getdvar( "r_zfeather" ) != "0" )
		level._effect[ "spotlight" ]						 = loadfx( "misc/hunted_spotlight_model" );
	else
		level._effect[ "spotlight" ]						 = loadfx( "misc/spotlight_large" );

	level._effect[ "heli_dlight_blue" ]					 = loadfx( "misc/aircraft_light_cockpit_blue" );

}

submarine01_fx()
{
	//for engine exhaust, sounds, etc.
	flag_wait( "open_dds_door" );
//	while ( !flag( "sdv_01_passing" ) )
//	{
//		playfxontag( getfx( "sub_prop_wash_1" ), self, "TAG_PROPELLER" );
//		wait( .1 );
//	}
}

submarine02_fx()
{
	//for engine exhaust, sounds, etc.
	flag_wait( "intro_anim_sequence_starting" );
	wait( 14 );
	self thread play_sound_on_tag( "submarine_driveby", "TAG_PROPELLER" );
//	while ( !flag( "sdv_01_arriving" ) )
//	{
//		playfxontag( getfx( "sub_prop_wash_1" ), self, "TAG_PROPELLER" );
//		wait( .1 );
//	}
}


sdv01_fx()
{
	//for engine exhaust, sounds, etc.
	self waittill( "moving" );
	self thread play_sound_on_tag( "sdv_start_plr", "TAG_PROPELLER" );
	self delaythread( 1,::play_loop_sound_on_tag, "sdv_move_loop_plr", "TAG_PROPELLER", true );
	
	//PLACE FX HERE
	playfxontag( getfx( "oilrig_underwater_ambient_emitter" ), self, "TAG_PROPELLER" );

	/*-----------------------
	SDV STOPPING
	-------------------------*/		
	self waittill( "stopped_moving" );
	self notify( "stop sound" + "sdv_move_loop_plr" );
	self thread play_sound_on_tag( "sdv_stop_plr", "TAG_PROPELLER" );
}

sdv02_fx()
{
	//for engine exhaust, sounds, etc.
	
	/*-----------------------
	SDV STARTS MOVING
	-------------------------*/	
	self waittill( "moving" );
	self thread play_sound_on_tag( "sdv_start", "TAG_PROPELLER" );
	self delaythread( 1,::play_loop_sound_on_tag, "sdv_move_loop", "TAG_PROPELLER", true );
	
	/*-----------------------
	SDV PROP WASH FX
	-------------------------*/	
	playfxontag( getfx( "sdv_prop_wash_1" ), self, "TAG_PROPELLER" );
	

	/*-----------------------
	SDV STOPPING
	-------------------------*/	
	//self waittill( "arriving" );
	self waittill( "stopped_moving" );
	stopfxontag( getfx( "sdv_contrail" ), self, "TAG_PROPELLER" );
	self notify( "stop sound" + "sdv_move_loop" );
	self thread play_sound_on_tag( "sdv_stop", "TAG_PROPELLER" );
}

underwater_ambient_fx()
{
	self waittill( "moving" );
	while ( self.moving  )
	{
		playfxontag( getfx( "oilrig_underwater_ambient" ), self, "TAG_PROPELLER" );
		wait( .1 );
	}
}

underwater_bleedout( guy )
{
//	iprintlnbold( "Blood" );
	playfxontag( getfx( "deathfx_bloodpool_underwater" ), guy, "J_NECK");


}

knife_blood( playerRig )
{
//	iprintlnbold( "Throat" );
	playfxontag( getfx( "bloodspurt_underwater" ), playerRig, "TAG_KNIFE_FX");

}


underwater_struggle( guy )
{
//	iprintlnbold( "Splash" );
	playfxontag( getfx( "splash_underwater_stealthkill" ), guy, "J_SpineUpper");
}


playerDrips_left( model )
{
	tags_in_arm = [];
	tags_in_arm[ tags_in_arm.size ] = "J_Wrist_LE";
	tags_in_arm[ tags_in_arm.size ] = "J_Thumb_LE_1";
	tags_in_arm[ tags_in_arm.size ] = "J_Thumb_LE_2";

    num = 10;
    for( i = 0 ; i < num ; i++ )
    {
		//iprintlnbold( "left" );
        thread play_drip_fx( tags_in_arm, model );
        wait randomfloatrange( 0.05, 0.3 );
    }
}

playerDrips_right( model )
{
	tags_in_arm = [];
	tags_in_arm[ tags_in_arm.size ] = "J_Wrist_RI";
	tags_in_arm[ tags_in_arm.size ] = "J_Thumb_RI_1";
	tags_in_arm[ tags_in_arm.size ] = "J_Webbing_RI";
	tags_in_arm[ tags_in_arm.size ] = "J_Elbow_RI";

    num = 10;
    for( i = 0 ; i < num ; i++ )
    {
		//iprintlnbold( "right" );
        thread play_drip_fx( tags_in_arm, model );
        wait randomfloatrange( 0.05, 0.3 );
    }
}

play_drip_fx( tags_in_arm, model )
{
    foreach( bone in tags_in_arm )
    {
		playfxontag( getfx( "drips_player_hand" ), model, bone );
    }
}

treadfx_override()
{
	
	tread_effects = "treadfx/tread_snow_slush";
	flying_tread_fx = "treadfx/heli_snow_default";
	
	maps\_treadfx::setvehiclefx( "littlebird", "brick", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "bark", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "carpet", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "cloth", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "concrete", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "dirt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "flesh", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "foliage", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "glass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "grass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "gravel", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "ice", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "mud", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "paper", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "plaster", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "rock", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "sand", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "snow", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "water", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "wood", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "asphalt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "ceramic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "plastic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "rubber", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "cushion", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "fruit", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "painted metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "littlebird", "default", flying_tread_fx );
	maps\_treadfx::setvehiclefx( "littlebird", "none", flying_tread_fx );

	maps\_treadfx::setvehiclefx( "blackhawk", "brick", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "bark", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "carpet", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "cloth", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "concrete", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "dirt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "flesh", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "foliage", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "glass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "grass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "gravel", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "ice", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "mud", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "paper", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "plaster", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "rock", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "sand", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "snow", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "water", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "wood", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "asphalt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "ceramic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "plastic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "rubber", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "cushion", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "fruit", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "painted metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "blackhawk", "default", flying_tread_fx );
	maps\_treadfx::setvehiclefx( "blackhawk", "none", flying_tread_fx );

	maps\_treadfx::setvehiclefx( "zodiac", "brick", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "bark", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "carpet", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "cloth", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "concrete", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "dirt", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "flesh", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "foliage", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "glass", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "grass", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "gravel", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "ice", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "metal", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "mud", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "paper", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "plaster", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "rock", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "sand", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "snow", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "water", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "wood", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "asphalt", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "ceramic", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "plastic", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "rubber", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "cushion", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "fruit", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "painted metal", tread_effects );
 	maps\_treadfx::setvehiclefx( "zodiac", "default", tread_effects );
	maps\_treadfx::setvehiclefx( "zodiac", "none", tread_effects );
}

