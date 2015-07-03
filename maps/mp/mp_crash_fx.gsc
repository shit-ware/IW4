main()
{

	level._effect[ "firelp_med_pm" ]				 = loadfx( "fire/firelp_med_pm_nodistort" );
	level._effect[ "firelp_small_pm" ]				 = loadfx( "fire/firelp_small_pm" );
	level._effect[ "firelp_small_pm_a" ]			 = loadfx( "fire/firelp_small_pm_a" );
	level._effect[ "dust_wind_fast" ]				 = loadfx( "dust/dust_wind_fast_paper" );
	level._effect[ "dust_wind_slow" ]				 = loadfx( "dust/dust_wind_slow_paper" );
	level._effect[ "dust_wind_spiral" ]				 = loadfx( "misc/trash_spiral_runner" );
	level._effect[ "battlefield_smokebank_S" ]		 = loadfx( "smoke/battlefield_smokebank_S" );
	level._effect[ "hallway_smoke_light" ]			 = loadfx( "smoke/hallway_smoke_light" );
 /#
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_crash_fx::main();
#/

}
