#include maps\_ambient;

main()
{
	// Set the underlying ambient track
	
	level.ambient_track [ "dcemp_iss" ] = "ambient_dcemp_iss";	
	level.ambient_track [ "dcemp_dry" ] = "ambient_dcemp_dry";
	level.ambient_track [ "dcemp_dry_int" ] = "ambient_dcemp_dry";
	level.ambient_track [ "dcemp_light_rain" ] = "ambient_dcemp_light_rain";
	level.ambient_track [ "dcemp_light_rain_int" ] = "ambient_dcemp_light_rain";
	level.ambient_track [ "dcemp_heavy_rain" ] = "ambient_dcemp_heavy_rain";
	level.ambient_track [ "dcemp_heavy_rain_int" ] = "ambient_dcemp_heavy_rain";
	level.ambient_track [ "dcemp_heavy_rain_tunnel" ] = "ambient_dcemp_heavy_rain";

//	thread maps\_utility::set_ambient( "dcemp_dry" );

	ambientDelay( "dcemp_iss", 20.0, 30.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "dcemp_iss", "null", 	12.0 );

	ambientDelay( "dcemp_dry", 2.0, 8.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "dcemp_dry", "elm_wind_leafy", 	12.0 );
	ambientEvent( "dcemp_dry", "null", 			0.3 );
	
	ambientDelay( "dcemp_dry_int", 2.0, 8.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "dcemp_dry_int", "elm_wind_leafy", 	12.0 );
	ambientEvent( "dcemp_dry_int", "null", 			0.3 );

	ambientDelay( "dcemp_light_rain", 2.0, 8.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "dcemp_light_rain", "elm_wind_leafy", 	12.0 );
	ambientEvent( "dcemp_light_rain", "null", 			0.3 );
	
	ambientDelay( "dcemp_light_rain_int", 2.0, 8.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "dcemp_light_rain_int", "elm_wind_leafy", 	12.0 );
	ambientEvent( "dcemp_light_rain_int", "null", 			0.3 );

	ambientDelay( "dcemp_heavy_rain", 2.0, 8.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "dcemp_heavy_rain", "elm_wind_leafy", 	12.0 );
	ambientEvent( "dcemp_heavy_rain", "null", 			0.3 );
	
	ambientDelay( "dcemp_heavy_rain_int", 2.0, 8.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "dcemp_heavy_rain_int", "elm_wind_leafy", 	12.0 );
	ambientEvent( "dcemp_heavy_rain_int", "null", 			0.3 );
	
	ambientDelay( "dcemp_heavy_rain_tunnel", 2.0, 8.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "dcemp_heavy_rain_tunnel", "elm_wind_leafy", 	12.0 );
	ambientEvent( "dcemp_heavy_rain_tunnel", "null", 			0.3 );

//	ambientEventStart( "dcemp_dry" );

	level waittill( "action moment" );

	ambientEventStart( "action ambient" );
}
