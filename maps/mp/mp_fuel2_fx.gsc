main()
{

	level._effect[ "room_smoke_200" ] 						= loadfx( "smoke/room_smoke_200" );
	level._effect[ "oil_rig_fire_fuel" ]					= loadfx( "fire/oil_rig_fire_fuel" );
	level._effect[ "sand_spray_detail_oriented_runner" ]	= loadfx( "dust/sand_spray_detail_oriented_runner_fuel" );
	level._effect[ "sand_spray_cliff_oriented_runner" ] 	= loadfx( "dust/sand_spray_cliff_oriented_runner" );
	
	level._effect[ "insects_carcass_runner" ]				= loadfx( "misc/insects_carcass_runner" );

	level._effect[ "firelp_med_pm" ]						= loadfx( "fire/firelp_med_pm" );
	level._effect[ "firelp_small_pm_a" ]					= loadfx( "fire/firelp_small_pm_a" );

	level._effect[ "trash_spiral_runner" ]					= loadfx( "misc/trash_spiral_runner" );
	level._effect[ "leaves_fall_gentlewind" ]		 		= loadfx( "misc/leaves_fall_gentlewind" );

	level._effect[ "hallway_smoke_light" ]					= loadfx( "smoke/hallway_smoke_light" );
	
	
	
	level._effect[ "dust_wind_fast_fuel" ]				 	= loadfx( "dust/dust_wind_fast_fuel" );
	
	level._effect[ "insect_trail_runner_icbm" ] 			= loadfx( "misc/insect_trail_runner_icbm" );
	
	

	
	/#
		if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_fuel2_fx::main();
	#/
}
