#include maps\_ambient;

main()
{
	// Set the underlying ambient track
	level.ambient_track [ "gulag_ext0" ] = "ambient_gulag_ext0";
	level.ambient_track [ "gulag_hall_int0" ] = "ambient_gulag_hall_int0";
	level.ambient_track [ "gulag_shower_int0" ] = "ambient_gulag_shower_int0";
	level.ambient_track [ "gulag_exit" ] = "ambient_gulag_tunnel_int0";

	/*
	ambientDelay( "gulag_ext0", 7.0, 15.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "gulag_ext0", "null", 		1.0 );
	ambientEvent( "gulag_ext0", "null", 		1.0 );
	*/

	thread maps\_utility::set_ambient( "gulag_ext0" );
//	thread maps\_utility::set_ambient( "gulag_hall_int0" );

	ambientDelay( "gulag_hall_int0", 7, 15 );// Trackname, min and max delay between ambient events
	ambientEvent( "gulag_hall_int0", "elm_quake_sub_rumble", 	1 );
//	ambientEvent_no_block( "gulag_hall_int0", "elm_quake_sub_rumble",  	1 );

	ambientDelay( "gulag_shower_int0", 7, 15 );// Trackname, min and max delay between ambient events
	ambientEvent( "gulag_shower_int0", "elm_quake_sub_rumble", 	1 );

	ambientDelay( "gulag_exit", 7, 15 );// Trackname, min and max delay between ambient events
//	ambientEvent( "gulag_exit", "amb_rock_rubble", 				1.2 );
//	ambientEvent( "gulag_exit", "amb_ceiling_debris", 	1 );
	ambientEvent( "gulag_exit", "elm_quake_sub_rumble", 	1 );
	
                  
}   
