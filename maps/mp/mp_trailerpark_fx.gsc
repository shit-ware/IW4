main()
{

	level._effect[ "firelp_large_pm" ]								= loadfx( "fire/firelp_large_pm" );
	level._effect[ "firelp_med_pm" ]								= loadfx( "fire/firelp_med_pm" );
	level._effect[ "firelp_small_pm" ]								= loadfx( "fire/firelp_small_pm" );

	level._effect[ "moth_runner" ]									= loadfx( "misc/moth_runner" );
	level._effect[ "insect_trail_runner_icbm" ]						= loadfx( "misc/insect_trail_runner_icbm" );
	level._effect[ "insects_carcass_runner" ]						= loadfx( "misc/insects_carcass_runner" );

	level._effect[ "leaves_fall_gentlewind" ]						= loadfx( "misc/leaves_fall_gentlewind" );
	level._effect[ "leaves_ground_gentlewind" ]						= loadfx( "misc/leaves_ground_gentlewind" );


/#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_trailerpark_fx::main();
#/

}
