#include maps\_ambient;

main()
{
	level.ambient_track [ "amb_underwater_test1v1" ] = "ambient_oilrig_under_ext0";
	level.ambient_track [ "ambient_oilrig_test_ext1" ] = "ambient_oilrig_rumble_ext1";
	level.ambient_track [ "ambient_oilrig_int1" ] = "ambient_oilrig_rumble_ext1";

	ambientDelay( "amb_underwater_test1v1", 15.0, 25.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "amb_underwater_test1v1", "null", 		1.0 );

	ambientDelay( "ambient_oilrig_test_ext1", 5.0, 10.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "ambient_oilrig_test_ext1", "null", 		0.1 );
	ambientEvent( "ambient_oilrig_test_ext1", "elm_industry", 		1.0 );
	ambientEvent( "ambient_oilrig_test_ext1", "elm_quake_sub_rumble", 		1.0 );
	ambientEvent( "ambient_oilrig_test_ext1", "elm_metal_stress", 		1.0 );
	
	ambientDelay( "ambient_oilrig_int1", 5.0, 10.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "ambient_oilrig_int1", "null", 		0.1 );
	ambientEvent( "ambient_oilrig_int1", "elm_industry", 		1.0 );
	ambientEvent( "ambient_oilrig_int1", "elm_quake_sub_rumble", 		1.0 );
	ambientEvent( "ambient_oilrig_int1", "elm_metal_stress", 		1.0 );

	thread maps\_utility::set_ambient( "amb_underwater_test1v1" );

}



