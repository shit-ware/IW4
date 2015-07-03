#include maps\_ambient;
#include maps\_utility;

main()
{
	// Set the underlying ambient track
	level.ambient_track [ "airport_terminal0" ] = "ambient_airport_terminal0";
	level.ambient_track [ "airport_ext0" ] = "ambient_airport_ext0";
	level.ambient_track [ "airport_int0" ] = "ambient_airport_int0";
	level.ambient_track [ "airport_basement0" ] = "ambient_airport_int0";
	

	ambientDelay( "airport_terminal0", 5.0, 10.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "airport_terminal0", "null", 		0.1 );
	ambientEvent( "airport_terminal0", "elm_airport_jet_interior", 		1.0 );
	ambientEvent( "airport_terminal0", "elm_airport_jet_rumble", 		1.0 );
//	ambientEvent( "airport_terminal0", "airport_anc_random", 		1.0 );

	ambientDelay( "airport_ext0", 7.0, 15.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "airport_ext0", "null", 		1.0 );

	ambientDelay( "airport_int0", 7.0, 15.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "airport_int0", "null", 		1.0 );

	ambientDelay( "airport_basement0", 7.0, 15.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "airport_basement0", "null", 		1.0 );

	//to match up with elevator intro scene.
	delaythread( 16, maps\_utility::set_ambient, "airport_terminal0" );
}
