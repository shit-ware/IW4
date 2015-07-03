#include maps\_ambient;

main()
{
	// Set the underlying ambient track
	level.ambient_track [ "arcadia_ext1" ] = "ambient_arcadia_ext1";
	level.ambient_track [ "arcadia_ext3" ] = "ambient_arcadia_ext3";
	
	thread maps\_utility::set_ambient( "arcadia_ext3" );

	ambientDelay( "arcadia_ext1", 5.0, 10.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "arcadia_ext1", "null", 		0.3 );
	ambientEvent( "arcadia_ext1", "elm_wind_leafy", 		1.0 );
	ambientEvent( "arcadia_ext1", "elm_dog", 		3.0 );
	ambientEvent( "arcadia_ext1", "elm_explosions_med", 		1.0 );
	ambientEvent( "arcadia_ext1", "elm_explosion_low_dist", 		3.0 );
	ambientEvent( "arcadia_ext1", "elm_explosions_dist", 		0.5 );
	ambientEvent( "arcadia_ext1", "elm_helicopter_flyover_med", 	10.0 );
	ambientEvent( "arcadia_ext1", "elm_jet_flyover_med", 	10.0 );
	ambientEvent( "arcadia_ext1", "elm_jet_flyover_dist", 	10.0 );
	ambientEvent( "arcadia_ext1", "elm_gunfire_50cal_med", 	0.5 );
	ambientEvent( "arcadia_ext1", "elm_gunfire_50cal_dist", 	1.0 );
	ambientEvent( "arcadia_ext1", "elm_gunfire_ak47_med", 	0.5 );
	ambientEvent( "arcadia_ext1", "elm_gunfire_ak47_dist", 	1.0 );
	ambientEvent( "arcadia_ext1", "elm_gunfire_miniuzi_med", 	0.5 );
	ambientEvent( "arcadia_ext1", "elm_gunfire_miniuzi_dist", 	1.0 );
	ambientEvent( "arcadia_ext1", "elm_gunfire_m16_med", 	0.5 );
	ambientEvent( "arcadia_ext1", "elm_gunfire_m16_dist", 	1.0 );
	ambientEvent( "arcadia_ext1", "elm_gunfire_m240_med", 	0.5 );
	ambientEvent( "arcadia_ext1", "elm_gunfire_m240_dist", 	1.0 );
	ambientEvent( "arcadia_ext1", "elm_gunfire_mp5_med", 	0.5 );
	ambientEvent( "arcadia_ext1", "elm_gunfire_mp5_dist", 	1.0 );
	ambientEvent( "arcadia_ext1", "elm_gunfire_usassault_med", 	2.0 );


	ambientDelay( "arcadia_ext3", 5.0, 8.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "arcadia_ext3", "null", 		0.001 );
	ambientEvent( "arcadia_ext3", "elm_dog", 		3.0 );
	ambientEvent( "arcadia_ext3", "elm_explosions_med", 		1.0 );
	ambientEvent( "arcadia_ext3", "elm_explosion_low_dist", 		1.0 );
	ambientEvent( "arcadia_ext3", "elm_explosions_dist", 		0.1 );
	ambientEvent( "arcadia_ext3", "elm_helicopter_flyover_med", 	10.0 );
	ambientEvent( "arcadia_ext3", "elm_jet_flyover_med", 	10.0 );
	ambientEvent( "arcadia_ext3", "elm_jet_flyover_dist", 	10.0 );
	ambientEvent( "arcadia_ext3", "elm_gunfire_50cal_med", 	1.0 );
	ambientEvent( "arcadia_ext3", "elm_gunfire_50cal_dist", 	0.2 );
	ambientEvent( "arcadia_ext3", "elm_gunfire_ak47_med", 	1.0 );
	ambientEvent( "arcadia_ext3", "elm_gunfire_ak47_dist", 	0.2 );
	ambientEvent( "arcadia_ext3", "elm_gunfire_miniuzi_med", 	1.0 );
	ambientEvent( "arcadia_ext3", "elm_gunfire_miniuzi_dist", 	0.2 );
	ambientEvent( "arcadia_ext3", "elm_gunfire_m16_med", 	1.0 );
	ambientEvent( "arcadia_ext3", "elm_gunfire_m16_dist", 	0.2 );
	ambientEvent( "arcadia_ext3", "elm_gunfire_m240_med", 	1.0 );
	ambientEvent( "arcadia_ext3", "elm_gunfire_m240_dist", 	0.2 );
	ambientEvent( "arcadia_ext3", "elm_gunfire_mp5_med", 	1.0 );
	ambientEvent( "arcadia_ext3", "elm_gunfire_mp5_dist", 	0.2 );
	ambientEvent( "arcadia_ext3", "elm_gunfire_usassault_med", 	3.0 );


	ambientEventStart( "arcadia_ext3" );

	level waittill( "action moment" );

	ambientEventStart( "action ambient" );
}