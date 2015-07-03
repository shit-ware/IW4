main()
{
	//ambient fx
	level._effect[ "insect_trail_runner_icbm" ]						 = loadfx( "misc/insect_trail_runner_icbm" );
	level._effect[ "leaves_fall_gentlewind" ]						 = loadfx( "misc/leaves_fall_gentlewind" );
	level._effect[ "leaves_ground_gentlewind" ]						 = loadfx( "misc/leaves_ground_gentlewind" );
	level._effect[ "ground_fog1200x1200_brecourt" ]					 = loadfx( "smoke/ground_fog1200x1200_brecourt" );
	level._effect[ "fog_ground_200" ]								 = loadfx( "smoke/fog_ground_200" );


/#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_brecourt_fx::main();
#/

}