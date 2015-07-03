main()
{
	setDevDvar( "scr_fog_disable", "0" );
	
	/* original boneyuard fog */
	ent = maps\_utility::create_vision_set_fog( "boneyard_trailer" );
	ent.startDist = 463.626;
	ent.halfwayDist = 2484.36;
	ent.red = 0.541176;
	ent.green = 0.470588;
	ent.blue = 0.372549;
	ent.maxOpacity = 0.370242;
	ent.transitionTime = 0;
	ent.sunred =0.709804;
	ent.sungreen = 0.6;
	ent.sunblue = 0.517647;
	ent.sunDir = ( 0.576931, 0.674164, 0.461144 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 61.0525;
	ent.normalFogScale = 0;

	/* boneyard */
	ent = maps\_utility::create_vision_set_fog( "boneyard" );
	ent.startDist = 925.063;
	ent.halfwayDist = 10169.5;
	ent.red = 0.541176;
	ent.green = 0.470588;
	ent.blue = 0.372549;
	ent.maxOpacity = 0.370242;
	ent.transitionTime = 0;
	ent.sunred =0.709804;
	ent.sungreen = 0.6;
	ent.sunblue = 0.517647;
	ent.sunDir = ( 0.576931, 0.674164, 0.461144 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 61.0525;
	ent.normalFogScale = 0;

	/* boneyard */
	ent = maps\_utility::create_vision_set_fog( "boneyard_flyby" );
	ent.startDist = 925.063;
	ent.halfwayDist = 10169.5;
	ent.red = 0.541176;
	ent.green = 0.470588;
	ent.blue = 0.372549;
	ent.maxOpacity = 0.370242;
	ent.transitionTime = 0;
	ent.sunred =0.709804;
	ent.sungreen = 0.6;
	ent.sunblue = 0.517647;
	ent.sunDir = ( 0.576931, 0.674164, 0.461144 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 61.0525;
	ent.normalFogScale = 0;

	/* ride */
	ent = maps\_utility::create_vision_set_fog( "boneyard_ride" );
	ent.startDist = 925.063;
	ent.halfwayDist = 10169.5;
	ent.red = 0.541176;
	ent.green = 0.470588;
	ent.blue = 0.372549;
	ent.maxOpacity = 0.370242;
	ent.transitionTime = 0;
	ent.sunred =0.709804;
	ent.sungreen = 0.6;
	ent.sunblue = 0.517647;
	ent.sunDir = ( 0.576931, 0.674164, 0.461144 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 61.0525;
	ent.normalFogScale = 0;

	/* steering */
	ent = maps\_utility::create_vision_set_fog( "boneyard_steer" );
	ent.startDist = 925.063;
	ent.halfwayDist = 10169.5;
	ent.red = 0.541176;
	ent.green = 0.470588;
	ent.blue = 0.372549;
	ent.maxOpacity = 0.370242;
	ent.transitionTime = 0;
	ent.sunred =0.709804;
	ent.sungreen = 0.6;
	ent.sunblue = 0.517647;
	ent.sunDir = ( 0.576931, 0.674164, 0.461144 );
	ent.sunBeginFadeAngle = 0;
	ent.sunEndFadeAngle = 61.0525;
	ent.normalFogScale = 0;

	maps\_utility::vision_set_fog_changes( "boneyard", 0 );
}
