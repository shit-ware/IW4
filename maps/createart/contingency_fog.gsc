main()
{
	setDevDvar( "scr_fog_disable", "0" );
	
	/* original contingency fog from julian */
	
	ent = maps\_utility::create_fog( "contingency_fog_start" );
	ent.startDist = 3500;
	ent.halfwayDist = 8000;
	ent.red = 0.70;
	ent.green = 0.74;
	ent.blue = 0.80;
	ent.maxOpacity = 0.3;
	ent.transitionTime = 0;
	
	
	/* [ contingency_forest ] from contingency_art -> setExpFog( 502.373, 923.152, 0.672458, 0.743307, 0.849584, 0.769946, 0 ); */
	
	ent = maps\_utility::create_fog( "contingency_fog_forest" );
	ent.startDist = 250; //302.373;
	ent.halfwayDist = 350; //923.152;
	ent.red = 0.672458;
	ent.green = 0.733307;
	ent.blue = 0.849584;
	ent.maxOpacity = 0.8; //0.769946;
	ent.transitionTime = 0;
	
	// directional fog
	ent = maps\_utility::create_fog( "contingency_fog_preforest" );
	ent.startDist = 302.373;
	ent.halfwayDist = 923.152;
	ent.red = 0.672458;
	ent.green = 0.733307;
	ent.blue = 0.849584;
	ent.maxOpacity = 0.769946;
	ent.transitionTime = 0;
	ent.sunred = 0.672458;
	ent.sungreen = 0.733307;
	ent.sunblue = 0.849584;
	ent.sunDir = ( -0.994982, 0.0950552, 0.0312391 );
	ent.sunBeginFadeAngle = 125;
	ent.sunEndFadeAngle = 145;
	ent.normalFogScale = 0.1;

	// directional fog
	ent = maps\_utility::create_fog( "contingency_fog_postforest" );
	ent.startDist = 302.373;
	ent.halfwayDist = 923.152;
	ent.red = 0.672458;
	ent.green = 0.733307;
	ent.blue = 0.849584;
	ent.maxOpacity = 0.769946;
	ent.transitionTime = 0;
	ent.sunred = 0.672458;
	ent.sungreen = 0.733307;
	ent.sunblue = 0.849584;
	ent.sunDir = ( 0.83273, 0.547007, -0.0857018 );
	ent.sunBeginFadeAngle = 75;
	ent.sunEndFadeAngle = 100;
	ent.normalFogScale = 0.1;

	maps\_utility::fog_set_changes( "contingency_fog_start", 0 );
}
