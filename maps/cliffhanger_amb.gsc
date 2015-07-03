#include maps\_ambient;

main()
{
	// Set the underlying ambient track
	level.ambient_track [ "snow_cliff" ] = "ambient_cliffhanger_climb_ext0";
	level.ambient_track [ "snow_base" ] = "ambient_cliffhanger_ext0";
	level.ambient_track [ "snow_base_white" ] = "ambient_cliffhanger_white_ext0";
	
	map_exterior_to_reverb_eq( "snow_base" ); // Reverb and EQ will use this setting when "exterior" ambience is triggered

	event = create_ambient_event( "snow_cliff", 7.0, 15.0 ); // Trackname, min and max delay between ambient events
//	event map_to_reverb_eq( "exterior" ); // use this eq and reverb (if it exists), for this ambient events
	event add_to_ambient_event( "null", 0.6 );
	event add_to_ambient_event( "elm_wind_buffet", 	1.0 );

	event = create_ambient_event( "snow_base", 7.0, 15.0 ); // Trackname, min and max delay between ambient events
//	event map_to_reverb_eq( "exterior" ); // use this eq and reverb (if it exists), for this ambient events
	event add_to_ambient_event( "null", 		0.3 );            
	event add_to_ambient_event( "elm_wind_buffet", 	4.0 );        
	event add_to_ambient_event( "walla_rus_mountain_conv", 	1.0 );
	event add_to_ambient_event( "walla_rus_mountain_chatter", 1.0 );
	event add_to_ambient_event( "elm_jet_flyover_dist", 	2.0 );

	event = create_ambient_event( "snow_base_white", 4.0, 8.0 ); // Trackname, min and max delay between ambient events
//	event map_to_reverb_eq( "exterior" ); // use this eq and reverb (if it exists), for this ambient events
	event add_to_ambient_event( "null", 		0.3 );                
	event add_to_ambient_event( "elm_wind_buffet", 	1.0 );            
	event add_to_ambient_event( "walla_rus_mountain_conv", 	1.0 );    
	event add_to_ambient_event( "walla_rus_mountain_chatter", 	1.0 );

	thread maps\_utility::set_ambient( "snow_cliff" );
}
