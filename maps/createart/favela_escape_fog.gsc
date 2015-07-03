#include maps\_utility;

main()
{
	setDevDvar( "scr_fog_disable", "0" );
	
	create_fogs();
	
	vision_set_fog_changes( "favela_escape", 0 );
}

create_fogs()
{
	ent = create_vision_set_fog( "favela_escape" );
	ent.startDist = 154;
	ent.halfwayDist = 6560;
	ent.red = 0.58;
	ent.green = 0.6;
	ent.blue = 0.65;
	ent.maxOpacity = 0.34;
	ent.transitionTime = 0;
	// optional
	ent.sunred = 0.83;
	ent.sungreen = 0.83;
	ent.sunblue = 0.81;
	ent.sunDir = ( -0.36, -0.93, 0.11 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 51;
	ent.normalFogScale = 0.18;
	
	ent = create_vision_set_fog( "favela_escape_radiotower" );
	ent.startDist = 154;
	ent.halfwayDist = 6560;
	ent.red = 0.58;
	ent.green = 0.6;
	ent.blue = 0.65;
	ent.maxOpacity = 0.34;
	ent.transitionTime = 0;
	// optional
	ent.sunred = 0.83;
	ent.sungreen = 0.83;
	ent.sunblue = 0.81;
	ent.sunDir = ( -0.36, -0.93, 0.11 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 51;
	ent.normalFogScale = 0.18;
	
	ent = create_vision_set_fog( "favela_escape_street" );
	ent.startDist = 154;
	ent.halfwayDist = 6560;
	ent.red = 0.58;
	ent.green = 0.6;
	ent.blue = 0.65;
	ent.maxOpacity = 0.34;
	ent.transitionTime = 0;
	// optional
	ent.sunred = 0.83;
	ent.sungreen = 0.83;
	ent.sunblue = 0.81;
	ent.sunDir = ( -0.36, -0.93, 0.11 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 51;
	ent.normalFogScale = 0.18;
	
	ent = create_vision_set_fog( "favela_escape_market" );
	ent.startDist = 154;
	ent.halfwayDist = 6560;
	ent.red = 0.58;
	ent.green = 0.6;
	ent.blue = 0.65;
	ent.maxOpacity = 0.34;
	ent.transitionTime = 0;
	// optional
	ent.sunred = 0.83;
	ent.sungreen = 0.83;
	ent.sunblue = 0.81;
	ent.sunDir = ( -0.36, -0.93, 0.11 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 51;
	ent.normalFogScale = 0.18;
	
	ent = create_vision_set_fog( "favela_escape_soccerfield_buildings" );
	ent.startDist = 154;
	ent.halfwayDist = 6560;
	ent.red = 0.58;
	ent.green = 0.6;
	ent.blue = 0.65;
	ent.maxOpacity = 0.34;
	ent.transitionTime = 0;
	// optional
	ent.sunred = 0.83;
	ent.sungreen = 0.83;
	ent.sunblue = 0.81;
	ent.sunDir = ( -0.36, -0.93, 0.11 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 51;
	ent.normalFogScale = 0.18;
	
	ent = create_vision_set_fog( "favela_escape_soccerfield" );
	ent.startDist = 154;
	ent.halfwayDist = 6560;
	ent.red = 0.58;
	ent.green = 0.6;
	ent.blue = 0.65;
	ent.maxOpacity = 0.34;
	ent.transitionTime = 0;
	// optional
	ent.sunred = 0.83;
	ent.sungreen = 0.83;
	ent.sunblue = 0.81;
	ent.sunDir = ( -0.36, -0.93, 0.11 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 51;
	ent.normalFogScale = 0.18;
	
	ent = create_vision_set_fog( "favela_escape_rooftops" );
	ent.startDist = 154;
	ent.halfwayDist = 6560;
	ent.red = 0.58;
	ent.green = 0.6;
	ent.blue = 0.65;
	ent.maxOpacity = 0.34;
	ent.transitionTime = 0;
	// optional
	ent.sunred = 0.83;
	ent.sungreen = 0.83;
	ent.sunblue = 0.81;
	ent.sunDir = ( -0.36, -0.93, 0.11 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 51;
	ent.normalFogScale = 0.18;
	
	ent = create_vision_set_fog( "favela_escape_playerfall_recovery" );
	ent.startDist = 154;
	ent.halfwayDist = 6560;
	ent.red = 0.58;
	ent.green = 0.6;
	ent.blue = 0.65;
	ent.maxOpacity = 0.34;
	ent.transitionTime = 0;
	// optional
	ent.sunred = 0.83;
	ent.sungreen = 0.83;
	ent.sunblue = 0.81;
	ent.sunDir = ( -0.36, -0.93, 0.11 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 51;
	ent.normalFogScale = 0.18;
	
	ent = create_vision_set_fog( "favela_escape_solorun_buildings" );
	ent.startDist = 154;
	ent.halfwayDist = 6560;
	ent.red = 0.58;
	ent.green = 0.6;
	ent.blue = 0.65;
	ent.maxOpacity = 0.34;
	ent.transitionTime = 0;
	// optional
	ent.sunred = 0.83;
	ent.sungreen = 0.83;
	ent.sunblue = 0.81;
	ent.sunDir = ( -0.36, -0.93, 0.11 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 51;
	ent.normalFogScale = 0.18;
	
	ent = create_vision_set_fog( "favela_escape_solorun_nearend" );
	ent.startDist = 154;
	ent.halfwayDist = 6560;
	ent.red = 0.58;
	ent.green = 0.6;
	ent.blue = 0.65;
	ent.maxOpacity = 0.34;
	ent.transitionTime = 0;
	// optional
	ent.sunred = 0.83;
	ent.sungreen = 0.83;
	ent.sunblue = 0.81;
	ent.sunDir = ( -0.36, -0.93, 0.11 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 51;
	ent.normalFogScale = 0.18;
	
	ent = create_vision_set_fog( "favela_escape_chopperjump" );
	ent.startDist = 154;
	ent.halfwayDist = 6560;
	ent.red = 0.58;
	ent.green = 0.6;
	ent.blue = 0.65;
	ent.maxOpacity = 0.34;
	ent.transitionTime = 0;
	// optional
	ent.sunred = 0.83;
	ent.sungreen = 0.83;
	ent.sunblue = 0.81;
	ent.sunDir = ( -0.36, -0.93, 0.11 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 51;
	ent.normalFogScale = 0.18;
}
