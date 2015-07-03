// _createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;

	//* Fog section * 

	setDevDvar( "scr_fog_disable", "0" );

	//setExpFog( 673.133, 3437.72, 0.180067, 0.140928, 0.126203, 0.704814, 0, 0.796079, 0.572549, 0.282353, (0.549292, -0.0385565, -0.834741), 0, 85.6848, 1.5191 );
	setExpFog( 673.133, 7700.72, 0.180067, 0.140928, 0.126203, 0.704814, 0, 0.796079, 0.572549, 0.282353, (0.549292, -0.0385565, -0.834741), 0, 85.6848, 1.5191 );
	maps\_utility::set_vision_set( "invasion", 0 );

}
