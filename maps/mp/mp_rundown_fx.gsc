main()
{
	//ambient fx
	level._effect[ "firelp_small_pm_a_nolight" ] 		= loadfx( "fire/firelp_small_pm_a_nolight" );

	level._effect[ "trash_spiral_runner" ] 				= loadfx( "misc/trash_spiral_runner" );

	level._effect[ "fog_ground_200_rundown" ] 			= loadfx( "smoke/fog_ground_200_rundown" );
	level._effect[ "fog_ground_200_heavy_rundown" ] 	= loadfx( "smoke/fog_ground_200_heavy_rundown" );
	level._effect[ "fog_ground_400_rundown" ] 			= loadfx( "smoke/fog_ground_400_rundown" );
	level._effect[ "fog_ground_500_far_rundown" ] 		= loadfx( "smoke/fog_ground_500_far_rundown" );

	level._effect[ "moth_runner" ] 						= loadfx( "misc/moth_runner" );
	level._effect[ "insects_carcass_runner" ] 			= loadfx( "misc/insects_carcass_runner" );
	level._effect[ "insect_trail_runner_icbm" ] 		= loadfx( "misc/insect_trail_runner_icbm" );
	

/#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_rundown_fx::main();
#/

}
