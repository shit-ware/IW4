main()
{

	level._effect[ "firelp_large_pm" ]							= loadfx( "fire/firelp_large_pm" );
	level._effect[ "firelp_med_pm" ]							= loadfx( "fire/firelp_med_pm" );
	level._effect[ "firelp_small_pm" ]							= loadfx( "fire/firelp_small_pm" );

	level._effect[ "snow_spray_detail_oriented_runner" ]		= loadfx( "snow/snow_spray_detail_oriented_runner" );
	level._effect[ "snow_spiral_runner" ]						= loadfx( "snow/snow_spiral_runner" );
	level._effect[ "room_smoke_200" ] 							= loadfx( "smoke/room_smoke_200" );

	level._effect[ "falling_junk_ring_runner" ] 				= loadfx( "misc/falling_junk_ring_runner" );

/#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_compact_fx::main();
#/

}