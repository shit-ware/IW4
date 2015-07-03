main()
{

	level._effect[ "firelp_large_pm" ]								= loadfx( "fire/firelp_large_pm" );
	level._effect[ "firelp_med_pm" ]								= loadfx( "fire/firelp_med_pm" );
	level._effect[ "firelp_small_pm" ]								= loadfx( "fire/firelp_small_pm" );

	level._effect[ "traffic" ]										= loadfx( "props/traffic_mp_abandon" );

	level._effect[ "moth_runner" ]									= loadfx( "misc/moth_runner" );
	level._effect[ "insect_trail_runner_icbm" ]						= loadfx( "misc/insect_trail_runner_icbm" );
	level._effect[ "insects_carcass_runner" ]						= loadfx( "misc/insects_carcass_runner" );

	level._effect[ "leaves_fall_gentlewind" ]						= loadfx( "misc/leaves_fall_gentlewind" );
	level._effect[ "leaves_ground_gentlewind" ]						= loadfx( "misc/leaves_ground_gentlewind" );
	level._effect[ "ground_fog_1200_abandon" ]						= loadfx( "smoke/ground_fog_1200_abandon" );
	level._effect[ "ground_fog_600_abandon" ]						= loadfx( "smoke/ground_fog_600_abandon" );
	level._effect[ "ground_fog_300_abandon" ]						= loadfx( "smoke/ground_fog_300_abandon" );
	level._effect[ "fog_ground_200" ]								= loadfx( "smoke/fog_ground_200" );
	level._effect[ "trash_spiral_runner" ]							= loadfx( "misc/trash_spiral_runner" );

	level._effect[ "hallway_smoke_light" ]							= loadfx( "smoke/hallway_smoke_light" );
	level._effect[ "room_smoke_200" ]								= loadfx( "smoke/room_smoke_200" );

/#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_abandon_fx::main();
#/

}
