#include maps\_ambient;

main()
{
	// Set the underlying ambient track
	level.ambient_track [ "af_caves_ext" ] = "ambient_af_caves_ext";
	level.ambient_track [ "af_caves_int" ] = "ambient_af_caves_int";
	

	event = create_ambient_event( "af_caves_ext", 5.0, 15.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq( "af_caves_ext" ); // use this eq and reverb (if it exists), for this ambient events
	event add_to_ambient_event( "null", 1.0 );
	event add_to_ambient_event( "elm_rubble", 0.1 );

	event = create_ambient_event( "af_caves_int", 5.0, 15.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq( "af_caves_int" ); // use this eq and reverb (if it exists), for this ambient events
	event add_to_ambient_event( "null", 1.0 );
	event add_to_ambient_event( "elm_rubble", 0.1 );

	thread maps\_utility::set_ambient( "af_caves_ext" );
}