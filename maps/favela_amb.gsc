#include maps\_ambient;

main()
{
	// Set the underlying ambient track
	level.ambient_track [ "favela_ext0" ] = "ambient_favela_ext0";
	

	ambientDelay("favela_ext0", 7.0, 20.0 );// Trackname, min and max delay between ambient events
	ambientEvent("favela_ext0", "elm_windgust1",	0.5);
	ambientEvent("favela_ext0", "elm_windgust2",	0.5);
	ambientEvent("favela_ext0", "elm_windgust3",	0.5);
	ambientEvent("favela_ext0", "elm_windgust4",	0.5);
	ambientEvent("favela_ext0", "elm_insect_fly", 6.0);
	ambientEvent("favela_ext0", "elm_jet_flyover_med",	2.0);
	ambientEvent("favela_ext0", "elm_jet_flyover_dist",	2.0);
	ambientEvent("favela_ext0", "elm_foreign_siren",	1.0);
	ambientEvent("favela_ext0", "null", 		6.0 );

	thread maps\_utility::set_ambient( "favela_ext0" );
}
