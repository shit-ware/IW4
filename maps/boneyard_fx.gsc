#include common_scripts\utility;
#include maps\_utility;

main()
{
	level._effect[ "large_explosion" ]				= loadfx( "explosions/large_vehicle_explosion" );
	level._effect[ "wood_burst" ]					= loadfx( "explosions/wood_explosion_1" );
	level._effect[ "wood_burst2" ]					= loadfx( "explosions/grenadeExp_wood" );
	level._effect[ "wing_drop_dust" ]				= loadfx( "dust/wing_drop_dust" );
	level._effect[ "dust_spiral01" ]				= loadfx( "dust/dust_spiral01" );
	level._effect[ "angel_flare_geotrail" ]			= loadfx( "smoke/angel_flare_geotrail" );
	level._effect[ "angel_flare_swirl" ]			= loadfx( "smoke/angel_flare_swirl_runner" );
	level._effect[ "scrape_sparks" ]				= loadfx( "misc/vehicle_scrape_sparks_c130" );
	level._effect[ "blood" ]					 	= loadfx( "impacts/sniper_escape_blood" );
	level._effect[ "blood_dashboard_splatter" ]		= loadfx( "impacts/blood_dashboard_splatter_boneyard" );


	//Ambient FX
	level._effect[ "dust_wind_fast" ]					= loadfx( "dust/dust_wind_fast" );
	level._effect[ "dust_wind_fast_light" ] 			= LoadFX( "dust/dust_wind_fast_light" );
	level._effect[ "trash_spiral_runner" ]				= loadfx( "misc/trash_spiral_runner" );
	level._effect[ "thin_black_smoke_L" ]			 	= LoadFX( "smoke/thin_black_smoke_L_nofog" );
	level._effect[ "hallway_smoke_light" ]				= LoadFX( "smoke/hallway_smoke_light" );
	level._effect[ "insects_carcass_runner" ] 			= LoadFX( "misc/insects_carcass_runner" );

	treadfx_override();
	footstep_effects();
	
	maps\createfx\boneyard_fx::main();
}

footstep_effects()
{
	//Regular footstep fx
	animscripts\utility::setFootstepEffect( "dirt",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "grass",		loadfx ( "impacts/footstep_dust" ) );
	
	//Small footstep fx
	animscripts\utility::setFootstepEffectSmall( "dirt",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffectSmall( "grass",		loadfx ( "impacts/footstep_dust" ) );
}

treadfx_override()
{
	
	driving_tread_fx = "treadfx/tread_dust_boneyard";
	
	maps\_treadfx::setvehiclefx( "suburban", "brick", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "bark", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "carpet", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "cloth", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "concrete", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "dirt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "flesh", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "foliage", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "glass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "grass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "gravel", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "ice", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "metal", undefined );
 	//maps\_treadfx::setvehiclefx( "suburban", "mud", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "paper", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "plaster", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "rock", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "sand", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "snow", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "slush", driving_tread_fx );
 	//maps\_treadfx::setvehiclefx( "suburban", "water", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "wood", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "asphalt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "ceramic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "plastic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "rubber", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "cushion", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "fruit", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "painted metal", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban", "default", driving_tread_fx );
	//maps\_treadfx::setvehiclefx( "suburban", "none", driving_tread_fx );

	maps\_treadfx::setvehiclefx( "suburban_minigun", "brick", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "bark", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "carpet", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "cloth", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "concrete", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "dirt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "flesh", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "foliage", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "glass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "grass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "gravel", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "ice", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "metal", undefined );
 	//maps\_treadfx::setvehiclefx( "suburban_minigun", "mud", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "paper", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "plaster", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "rock", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "sand", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "snow", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "slush", driving_tread_fx );
 	//maps\_treadfx::setvehiclefx( "suburban_minigun", "water", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "wood", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "asphalt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "ceramic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "plastic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "rubber", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "cushion", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "fruit", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "painted metal", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "suburban_minigun", "default", driving_tread_fx );
	//maps\_treadfx::setvehiclefx( "suburban_minigun", "none", driving_tread_fx );

	maps\_treadfx::setvehiclefx( "truck_physics", "brick", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "bark", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "carpet", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "cloth", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "concrete", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "dirt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "flesh", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "foliage", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "glass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "grass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "gravel", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "ice", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "metal", undefined );
 	//maps\_treadfx::setvehiclefx( "truck_physics", "mud", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "paper", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "plaster", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "rock", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "sand", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "snow", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "slush", driving_tread_fx );
 	//maps\_treadfx::setvehiclefx( "truck_physics", "water", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "wood", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "asphalt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "ceramic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "plastic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "rubber", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "cushion", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "fruit", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "painted metal", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "truck_physics", "default", driving_tread_fx );
	//maps\_treadfx::setvehiclefx( "truck_physics", "none", driving_tread_fx );

	maps\_treadfx::setvehiclefx( "uaz_physics", "brick", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "bark", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "carpet", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "cloth", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "concrete", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "dirt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "flesh", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "foliage", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "glass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "grass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "gravel", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "ice", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "metal", undefined );
 	//maps\_treadfx::setvehiclefx( "uaz_physics", "mud", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "paper", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "plaster", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "rock", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "sand", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "snow", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "slush", driving_tread_fx );
 	//maps\_treadfx::setvehiclefx( "uaz_physics", "water", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "wood", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "asphalt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "ceramic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "plastic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "rubber", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "cushion", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "fruit", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "painted metal", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "uaz_physics", "default", driving_tread_fx );
	//maps\_treadfx::setvehiclefx( "uaz_physics", "none", driving_tread_fx );

	maps\_treadfx::setvehiclefx( "hummer_physics", "brick", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "bark", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "carpet", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "cloth", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "concrete", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "dirt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "flesh", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "foliage", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "glass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "grass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "gravel", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "ice", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "metal", undefined );
 	//maps\_treadfx::setvehiclefx( "hummer_physics", "mud", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "paper", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "plaster", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "rock", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "sand", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "snow", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "slush", driving_tread_fx );
 	//maps\_treadfx::setvehiclefx( "hummer_physics", "water", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "wood", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "asphalt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "ceramic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "plastic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "rubber", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "cushion", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "fruit", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "painted metal", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_physics", "default", driving_tread_fx );
	//maps\_treadfx::setvehiclefx( "hummer_physics", "none", driving_tread_fx );

	maps\_treadfx::setvehiclefx( "hummer_minigun", "brick", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "bark", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "carpet", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "cloth", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "concrete", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "dirt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "flesh", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "foliage", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "glass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "grass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "gravel", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "ice", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "metal", undefined );
 	//maps\_treadfx::setvehiclefx( "hummer_minigun", "mud", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "paper", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "plaster", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "rock", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "sand", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "snow", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "slush", driving_tread_fx );
 	//maps\_treadfx::setvehiclefx( "hummer_minigun", "water", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "wood", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "asphalt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "ceramic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "plastic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "rubber", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "cushion", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "fruit", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "painted metal", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "hummer_minigun", "default", driving_tread_fx );
	//maps\_treadfx::setvehiclefx( "hummer_minigun", "none", driving_tread_fx );

	maps\_treadfx::setvehiclefx( "btr80_physics", "brick", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "bark", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "carpet", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "cloth", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "concrete", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "dirt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "flesh", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "foliage", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "glass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "grass", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "gravel", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "ice", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "metal", undefined );
 	//maps\_treadfx::setvehiclefx( "btr80_physics", "mud", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "paper", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "plaster", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "rock", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "sand", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "snow", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "slush", driving_tread_fx );
 	//maps\_treadfx::setvehiclefx( "btr80_physics", "water", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "wood", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "asphalt", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "ceramic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "plastic", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "rubber", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "cushion", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "fruit", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "painted metal", driving_tread_fx );
 	maps\_treadfx::setvehiclefx( "btr80_physics", "default", driving_tread_fx );
	//maps\_treadfx::setvehiclefx( "btr80_physics", "none", driving_tread_fx );

}