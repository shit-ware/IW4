#include maps\_ambient;

main()
{
	// Set the underlying ambient track
	level.ambient_track [ "estate_ext0" ] = "ambient_ac130_int1";
	thread maps\_utility::set_ambient( "estate_ext0" );

	ambientDelay( "estate_ext0", 3.0, 6.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "estate_ext0", "null", 			1.0 );


	ambientEventStart( "estate_ext0" );

	level waittill( "action moment" );

	ambientEventStart( "action ambient" );
}



