main()
{
	setDevDvar( "scr_fog_disable", "0" );

	
	ent = maps\_utility::create_vision_set_fog( "roadkill" );
	ent.startDist = 639.671;
	ent.halfwayDist = 14192;
	ent.red = 0.356863;
	ent.green = 0.423;
	ent.blue = 0.505;
	ent.maxOpacity = 0.69;
	ent.transitionTime = 0;
	maps\_utility::vision_set_fog_changes( "roadkill", 0 );
	

	ent = maps\_utility::create_vision_set_fog( "roadkill_town_smokey" );
	ent.startDist = 0;
	ent.halfwayDist = 2070;
	ent.red = 0.356863;
	ent.green = 0.423;
	ent.blue = 0.505;
	ent.maxOpacity = 0;
	ent.transitionTime = 0;

	ent = maps\_utility::create_vision_set_fog( "roadkill_town_normal" );
	ent.startDist = 639.671;
	ent.halfwayDist = 14192;
	ent.red = 0.356863;
	ent.green = 0.423;
	ent.blue = 0.505;
	ent.maxOpacity = 0.69;
	ent.transitionTime = 0;

	ent = maps\_utility::create_vision_set_fog( "roadkill_ambush" );
	ent.startDist = 639.671;
	ent.halfwayDist = 14192;
	ent.red = 0.356863;
	ent.green = 0.423;
	ent.blue = 0.505;
	ent.maxOpacity = 0.69;
	ent.transitionTime = 0;

	ent = maps\_utility::create_vision_set_fog( "roadkill_dismount_building" );
	ent.startDist = 639.671;
	ent.halfwayDist = 14192;
	ent.red = 0.356863;
	ent.green = 0.423;
	ent.blue = 0.505;
	ent.maxOpacity = 0.69;
	ent.transitionTime = 0;

	ent = maps\_utility::create_vision_set_fog( "roadkill_walking_to_school" );
	ent.startDist = 639.671;
	ent.halfwayDist = 14192;
	ent.red = 0.356863;
	ent.green = 0.423;
	ent.blue = 0.505;
	ent.maxOpacity = 0.69;
	ent.transitionTime = 0;

	ent = maps\_utility::create_vision_set_fog( "roadkill_inside_school" );
	ent.startDist = 639.671;
	ent.halfwayDist = 14192;
	ent.red = 0.356863;
	ent.green = 0.423;
	ent.blue = 0.505;
	ent.maxOpacity = 0.69;
	ent.transitionTime = 0;

	ent = maps\_utility::create_vision_set_fog( "roadkill_left_school" );
	ent.startDist = 639.671;
	ent.halfwayDist = 14192;
	ent.red = 0.356863;
	ent.green = 0.423;
	ent.blue = 0.505;
	ent.maxOpacity = 0.69;
	ent.transitionTime = 0;

	ent = maps\_utility::create_vision_set_fog( "roadkill_ending" );
	ent.startDist = 100;
	ent.halfwayDist = 6800;
	ent.red = 0.356863;
	ent.green = 0.423;
	ent.blue = 0.505;
	ent.maxOpacity = 1;
	ent.transitionTime = 0;
}
