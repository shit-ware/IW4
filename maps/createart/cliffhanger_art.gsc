// _createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;
 
	//* depth of field section * 

	level.dofDefault[ "nearStart" ] = 0;
	level.dofDefault[ "nearEnd" ] = 1;
	level.dofDefault[ "farStart" ] = 16051;
	level.dofDefault[ "farEnd" ] = 19999;
	level.dofDefault[ "nearBlur" ] = 4;
	level.dofDefault[ "farBlur" ] = 1.75146;
	players = getentarray( "player", "classname" );
	for ( i = 0; i < players.size; i++ )
		players[i] maps\_art::setdefaultdepthoffield();

	//* Fog section * 

	setdevdvar( "scr_fog_disable", "0" );

	setExpFog( 54472.7, 15873.4, 0.699094, 0.741239, 0.82818, 0.901075, 0 );
	maps\_utility::set_vision_set( "cliffhanger", 0 );

}
