#include common_scripts\utility;
#include maps\_utility;

main()
{
	
	maps\createfx\estate_fx::main();
	level thread treadfx_override();
	
	
	level._effect[ "bouncing_betty_launch" ]				= loadfx( "impacts/bouncing_betty_launch_dirt" );
	level._effect[ "bouncing_betty_explosion" ]				= loadfx( "explosions/bouncing_betty_explosion" );
	level._effect[ "bouncing_betty_swirl" ]					= loadfx( "dust/bouncing_betty_swirl" );
	
	level._effect[ "smoke_cloud" ]							= loadfx( "smoke/smoke_grenade" );
	
	level._effect[ "mortar" ][ "dirt" ]      				= loadfx( "explosions/artilleryExp_dirt_brown_2" );
	
	level._effect[ "breach_estate_door" ]					= LoadFX( "explosions/breach_door2" );
	
	level._effect[ "fenceblast" ]      						= loadfx( "explosions/artilleryExp_dirt_brown" );
	
	level._effect[ "suicide_bomber" ]      					= loadfx( "explosions/propane_large_exp" );
	
	level._effect[ "redsmoke" ]      						= loadfx( "smoke/signal_smoke_red_estate" );
	
	level._effect[ "bodydump_dust_large" ]					= loadfx( "impacts/bodydump_dust_large_runner" );
	level._effect[ "flesh_hit_body_fatal_exit" ]			= loadfx( "impacts/flesh_hit_body_fatal_exit" );
	
	level._effect[ "gas_can_splash" ]						= loadfx( "props/gas_can_splash" );
	level._effect[ "gas_can_drips" ]						= loadfx( "props/gas_can_drips" );
	level._effect[ "gasoline_fire_on_player" ]				= loadfx( "fire/firelp_med_pm_estate" );
	level._effect[ "gasoline_fire_on_player_ignite" ]		= loadfx( "fire/firelp_med_pm_estate_ignite" );
	
	level._effect[ "cigar_glow" ]						 	= loadFX( "fire/cigar_glow" );
	level._effect[ "cigar_glow_puff" ]					 	= loadFX( "fire/cigar_glow_puff" );
	level._effect[ "cigar_smoke_puff" ]					 	= loadFX( "smoke/cigarsmoke_puff" );
	level._effect[ "cigar_exhale_estate" ]					= loadFX( "smoke/cigarsmoke_exhale_estate" );
	
	level._effect[ "anaconda_muzzle_flash" ]			 	= loadFX( "muzzleflashes/pistolflash" );
	
	
	//ambient fx
	level._effect[ "moth_runner" ]									= loadfx( "misc/moth_runner" );
	level._effect[ "insect_trail_runner_icbm" ]						= loadfx( "misc/insect_trail_runner_icbm" );
	level._effect[ "leaves_ground_gentlewind_dust" ]				= loadfx( "misc/leaves_ground_gentlewind_dust" );
	level._effect[ "leaves_fall_gentlewind" ]						= loadfx( "misc/leaves_fall_gentlewind" );
	level._effect[ "leaves_spiral_runner" ]						 	= loadfx( "misc/leaves_spiral_runner" );
	level._effect[ "leaves_spiral_estate_ending" ]					= loadfx( "misc/leaves_spiral_estate_ending" );
	level._effect[ "ground_fog1200x1200_estate" ]					= loadfx( "smoke/ground_fog1200x1200_estate" );
	level._effect[ "ground_fog1200x1200_estate_2" ]					= loadfx( "smoke/ground_fog1200x1200_estate_2" );
	level._effect[ "fog_ground_200" ]								= loadfx( "smoke/fog_ground_200" );
	level._effect[ "fog_ground_400" ]								= loadfx( "smoke/fog_ground_400" );

	level._effect[ "insects_carcass_runner" ]						= loadfx( "misc/insects_carcass_runner" );
	level._effect[ "waterfall_drainage_splash" ] 					= loadfx( "water/waterfall_drainage_splash_estate" );
	level._effect[ "waterfall_splash_large" ] 						= loadfx( "water/waterfall_splash_large_estate" );
	level._effect[ "waterfall_splash_large_drops" ]					= loadfx( "water/waterfall_splash_large_drops_estate" );
	level._effect[ "falling_water_trickle" ]	 					= loadfx( "water/falling_water_trickle" );

	level._effect[ "hallway_smoke_light" ]							= loadfx( "smoke/hallway_smoke_light" );
	level._effect[ "room_smoke_200" ]								= loadfx( "smoke/room_smoke_200" );
	
	level._effect[ "dust_outdoor_large" ]							= loadfx( "dust/dust_outdoor_large" );
	
	level._effect[ "bird_takeoff_pm" ]								= loadfx( "misc/bird_takeoff_pm" );
	level._effect[ "breach_room_residual_estate" ]					= loadfx( "explosions/breach_room_residual_estate" );
	level._effect[ "breach_room_residual_estate_fill" ]				= loadfx( "explosions/breach_room_residual_estate_fill" );
	level._effect[ "heli_dust_estate" ]								= loadfx( "treadfx/heli_dust_estate" );
	level._effect[ "heli_dust_estate_large" ]						= loadfx( "treadfx/heli_dust_estate_large" );
	level._effect[ "thin_black_smoke_M" ]							= loadfx( "smoke/thin_black_smoke_M" );
	level._effect[ "firelp_small_pm" ]								= loadfx( "fire/firelp_small_pm" );
	level._effect[ "steam_solar_panels" ]							= loadfx( "smoke/steam_solar_panels" );

}
	

treadfx_override()
{
	
	flying_tread_fx = "treadfx/heli_dust_estate";
	flying_tread_fx_large = "treadfx/heli_dust_estate_large";
	
	maps\_treadfx::setvehiclefx( "pavelow", "brick", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "bark", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "carpet", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "cloth", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "concrete", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "dirt", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "flesh", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "foliage", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "glass", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "grass", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "gravel", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "ice", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "metal", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "mud", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "paper", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "plaster", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "rock", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "sand", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "snow", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "water", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "wood", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "asphalt", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "ceramic", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "plastic", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "rubber", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "cushion", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "fruit", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "painted metal", flying_tread_fx_large );
 	maps\_treadfx::setvehiclefx( "pavelow", "default", flying_tread_fx_large );
	maps\_treadfx::setvehiclefx( "pavelow", "none", flying_tread_fx_large );
	
	
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
	
	maps\_treadfx::setvehiclefx( "mi17", "brick", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "bark", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "carpet", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "cloth", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "concrete", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "dirt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "flesh", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "foliage", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "glass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "grass", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "gravel", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "ice", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "mud", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "paper", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "plaster", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "rock", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "sand", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "snow", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "water", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "wood", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "asphalt", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "ceramic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "plastic", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "rubber", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "cushion", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "fruit", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "painted metal", flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "mi17", "default", flying_tread_fx );
	maps\_treadfx::setvehiclefx( "mi17", "none", flying_tread_fx );
	
}
