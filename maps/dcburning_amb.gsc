#include maps\_ambient;

main()
{
	// Set the underlying ambient track
	level.ambient_track[ "dcburning_bunker1" ] = "ambient_dcburning_bunker1";
	level.ambient_track[ "dcburning_ext1" ] = "ambient_dcburning_ext1";
	level.ambient_track[ "dcburning_building1" ] = "ambient_dcburning_building1";
	
	event = create_ambient_event( "dcburning_bunker1", 5.0, 15.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq( "dcburning_bunker1" ); // use this eq and reverb (if it exists), for this ambient events
	event add_to_ambient_event( "null", 1.0 );
	event add_to_ambient_event( "elm_rubble", 1.0 );
	event add_to_ambient_event( "elm_quake_sub_rumble", 1.0 );

	event = create_ambient_event( "dcburning_ext1", 10.0, 25.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq( "dcburning_ext1" ); // use this eq and reverb (if it exists), for this ambient events
	event add_to_ambient_event( "null", 		5.0 );                
	event add_to_ambient_event( "elm_wind_leafy", 		1.0 );        
	event add_to_ambient_event( "elm_explosions_med", 		1.0 );    
	event add_to_ambient_event( "elm_explosion_low_dist", 		3.0 );
	event add_to_ambient_event( "elm_explosions_dist", 		0.5 );    
	event add_to_ambient_event( "elm_helicopter_flyover_med", 	0.1 );
	event add_to_ambient_event( "elm_jet_flyover_med", 	0.1 );        
	event add_to_ambient_event( "elm_jet_flyover_dist", 	1.0 );    
	event add_to_ambient_event( "elm_gunfire_50cal_med", 	0.5 );    
	event add_to_ambient_event( "elm_gunfire_50cal_dist", 	1.0 );    
	event add_to_ambient_event( "elm_gunfire_ak47_med", 	0.5 );    
	event add_to_ambient_event( "elm_gunfire_ak47_dist", 	1.0 );    
	event add_to_ambient_event( "elm_gunfire_miniuzi_med", 	0.5 );    
	event add_to_ambient_event( "elm_gunfire_miniuzi_dist", 	1.0 );
	event add_to_ambient_event( "elm_gunfire_m16_med", 	0.5 );        
	event add_to_ambient_event( "elm_gunfire_m16_dist", 	1.0 );    
	event add_to_ambient_event( "elm_gunfire_m240_med", 	0.5 );    
	event add_to_ambient_event( "elm_gunfire_m240_dist", 	1.0 );    
	event add_to_ambient_event( "elm_gunfire_mp5_med", 	0.5 );        
	event add_to_ambient_event( "elm_gunfire_mp5_dist", 	1.0 );    
	event add_to_ambient_event( "elm_gunfire_usassault_med", 	2.0 );

	event = create_ambient_event( "dcburning_building1", 10.0, 25.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq( "dcburning_building1" ); // use this eq and reverb (if it exists), for this ambient events
	event add_to_ambient_event( "null", 		5.0 );                
	event add_to_ambient_event( "elm_jet_flyover_dist", 	1.0 );    
	event add_to_ambient_event( "elm_explosion_low_dist", 		3.0 );
	event add_to_ambient_event( "elm_explosions_dist", 		0.5 );    

	thread maps\_utility::set_ambient( "dcburning_bunker1" );
}
