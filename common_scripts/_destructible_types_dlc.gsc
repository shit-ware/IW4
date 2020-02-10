#include common_scripts\utility;
#include common_scripts\_destructible;
#include common_scripts\_destructible_types;
#using_animtree( "destructibles_dlc" );

makeType_dlc( destructibleType ) 
{
	//println( destructibleType );

	// if it's already been created dont create it again
	infoIndex = getInfoIndex( destructibleType );
	if ( infoIndex >= 0 )
		return infoIndex;

	found_dlc_destructible = true;
	switch ( destructibleType )
	{
		// add new destructibles here, you can write new functions for them or call the old ones
		case "toy_new_dlc_destructible":
			toy_glass( "120x110" );
			break;
		case "toy_security_camera":
			toy_security_camera( destructibleType );
			break;
		case "toy_arcade_machine_1":
			toy_arcade_machine( "_1" );
			break;
		case "toy_arcade_machine_2":
			toy_arcade_machine( "_2" );
			break;
		case "toy_pinball_machine_1":
			toy_pinball_machine( "_1" );
			break;
		case "toy_pinball_machine_2":
			toy_pinball_machine( "_2" );
			break;
		default:
			found_dlc_destructible = false;
			break;
	}
	
	if ( !found_dlc_destructible )
	{
		return undefined;
	}

	infoIndex = getInfoIndex( destructibleType );
	assert( infoIndex >= 0 );
	return infoIndex;
}





toy_security_camera( destructibleType )
{
	//---------------------------------------------------------------------
	// Rotating security camera
	//---------------------------------------------------------------------
	destructible_create( destructibleType, "tag_camera_tilt", 0, undefined, 32 );
			destructible_anim( get_precached_anim( "security_camera_idle" ), #animtree, "setanimknob", undefined, undefined, "security_camera_idle" );
		destructible_state( "tag_camera_tilt", "com_security_camera_tilt_animated", 75 );
			destructible_anim( get_precached_anim( "security_camera_destroy" ), #animtree, "setanimknob", undefined, undefined, "security_camera_destroy" );
			destructible_fx( "tag_fx", "props/security_camera_explosion_moving" );
			destructible_sound( "security_camera_sparks" );
		destructible_state( undefined, "com_security_camera_d_tilt_animated", undefined, undefined, "no_melee" );
}


toy_arcade_machine( version )
{
	//---------------------------------------------------------------------
	// Exploding Arcade Maching
	//---------------------------------------------------------------------
	destructible_create( "toy_arcade_machine" + version, "tag_origin", 0, undefined, 32 );
		destructible_state( "tag_origin", "arcade_machine" + version, 75 );
			destructible_fx( "tag_fx", "props/arcade_machine_exp" );
			destructible_fx( "tag_fx2", "props/arcade_machine_coins" );
			destructible_sound( "arcade_machine_destroy" );
		destructible_state( undefined, "arcade_machine" + version + "_des", undefined, undefined, "no_melee" );
}


toy_pinball_machine( version )
{
	//---------------------------------------------------------------------
	// Exploding Arcade Maching
	//---------------------------------------------------------------------
	destructible_create( "toy_pinball_machine" + version, "tag_origin", 0, undefined, 32 );
		destructible_state( "tag_origin", "pinball_machine" + version, 75 );
			destructible_fx( "tag_fx", "props/pinball_machine_exp", undefined, undefined, undefined, 1 );
			destructible_fx( "tag_fx2", "props/arcade_machine_coins" );
			destructible_fx( "tag_fx3", "props/pinball_machine_glass" );
			destructible_sound( "pinball_machine_destroy" );
		destructible_state( undefined, "pinball_machine" + version + "_des", undefined, undefined, "no_melee" );
}



