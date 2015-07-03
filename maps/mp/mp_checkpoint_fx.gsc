main()
{
	//ambient fx
	level._effect[ "firelp_med_pm" ]					= loadfx( "fire/firelp_med_pm" );
	level._effect[ "firelp_small_pm_a" ]				= loadfx( "fire/firelp_small_pm_a" );

	level._effect[ "room_smoke_200" ]					= loadfx( "smoke/room_smoke_200" );
	level._effect[ "room_smoke_400" ]					= loadfx( "smoke/room_smoke_400" );
	level._effect[ "hallway_smoke_light" ]				= loadfx( "smoke/hallway_smoke_light" );
	level._effect[ "ground_smoke_1200x1200" ]			= loadfx( "smoke/ground_smoke1200x1200" );

	level._effect[ "dust_wind_fast" ]					= loadfx( "dust/dust_wind_fast_light" );
	level._effect[ "trash_spiral_runner" ]				= loadfx( "misc/trash_spiral_runner" );


/#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_checkpoint_fx::main();
#/

}
