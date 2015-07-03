#include maps\_ambient;

main()
{
	// Set the underlying ambient track
	level.ambient_track [ "boneyard_ext0" ] = "ambient_boneyard_ext0";
	level.ambient_track [ "boneyard_ext5" ] = "ambient_boneyard_ext5";
	

	ambientDelay( "boneyard_ext0", 5.0, 10.0 );// Trackname, min and max delay between ambient events
	ambientEvent( "boneyard_ext0", "null", 		1.0 );
	ambientEvent( "boneyard_ext0", "elm_wind_leafy", 		0.5 );
	ambientEvent( "boneyard_ext0", "elm_insect_fly", 		1.0 );
	ambientEvent( "boneyard_ext0", "elm_dog", 		1.0 );
	ambientEvent( "boneyard_ext0", "elm_stress", 		0.5 );
	ambientEvent( "boneyard_ext0", "elm_jet_flyover_dist", 		0.2 );

	thread maps\_utility::set_ambient( "boneyard_ext5" );
}
