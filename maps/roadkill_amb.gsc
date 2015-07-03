#include maps\_ambient;

main()
{
	// Set the underlying ambient track
	level.ambient_track [ "exterior_level2" ] = "ambient_roadkill_ext2";

	ambientDelay( "exterior_level2", 2.0, 8.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "exterior_level2", "elm_windgust1", 	3.0 );
	ambientEvent( "exterior_level2", "elm_windgust2", 	3.0 );
	ambientEvent( "exterior_level2", "elm_windgust3", 	3.0 );
	ambientEvent( "exterior_level2", "elm_windgust4", 	3.0 );
	ambientEvent( "exterior_level2", "elm_insect_fly", 6.0 );
	ambientEvent( "exterior_level2", "elm_explosions_dist", 	3.0 );
	ambientEvent( "exterior_level2", "elm_explosions_med", 	3.0 );
	ambientEvent( "exterior_level2", "elm_artillery_med", 	3.0 );
	ambientEvent( "exterior_level2", "elm_gunfire_50cal_dist", 	3.0 );
	ambientEvent( "exterior_level2", "elm_gunfire_50cal_med", 	3.0 );
	ambientEvent( "exterior_level2", "elm_gunfire_ak47_dist", 	3.0 );
	ambientEvent( "exterior_level2", "elm_gunfire_ak47_med", 	3.0 );
	ambientEvent( "exterior_level2", "elm_gunfire_m16_dist", 	3.0 );
	ambientEvent( "exterior_level2", "elm_gunfire_m16_med", 	3.0 );
	ambientEvent( "exterior_level2", "elm_jet_flyover_med", 	2.0 );
	ambientEvent( "exterior_level2", "elm_jet_flyover_dist", 	2.0 );

	ambientEvent( "exterior_level2", "null", 			0.3 );

	thread maps\_utility::set_ambient( "exterior_level2" );
	ambientEventStart( "exterior_level2" );
}