#include common_scripts\utility;
#include maps\_utility;
#include common_scripts\_createFxMenu;
#include common_scripts\_createfx;
#include common_scripts\_fx;

createfx()
{
	level.func_position_player = ::func_position_player;
	level.func_position_player_get = ::func_position_player_get;
	level.func_loopfxthread = ::loopfxthread;
	level.func_oneshotfxthread = ::oneshotfxthread;
	level.func_create_loopsound = ::create_loopsound;
//	level.func_exploder_preload = ::exploder_before_load;;
//	level.func_exploder_postload = ::exploder_after_load;;
	level.func_updatefx = ::restart_fx_looper;
	level.func_process_fx_rotater = ::process_fx_rotater;

	level.mp_createfx = false;

	// SP only stuff
	ai = getaiarray();
	for ( i = 0;i < ai.size;i++ )
		ai[ i ] delete();

	thread createFxLogic();

	thread func_get_level_fx(); // start gettin these on start
	createfx_common();

	level waittill( "eternity" );
}

func_position_player_get( lastPlayerOrigin )
{
	if ( distance( lastPlayerOrigin, level.player.origin ) > 64 )
	{
		// save the players position so we can go back here on a map restart
		setdvar( "createfx_playerpos_x", level.player.origin[ 0 ] );
		setdvar( "createfx_playerpos_y", level.player.origin[ 1 ] );
		setdvar( "createfx_playerpos_z", level.player.origin[ 2 ] );
	}

	return level.player.origin;
}

func_position_player()
{
	// if we're still on the same map then..
	// set the players position so map restart doesnt move your origin in createfx

	playerPos = [];
	playerPos[ 0 ] = getdvarint( "createfx_playerpos_x" );
	playerPos[ 1 ] = getdvarint( "createfx_playerpos_y" );
	playerPos[ 2 ] = getdvarint( "createfx_playerpos_z" );

	level.player setOrigin( ( playerPos[ 0 ], playerPos[ 1 ], playerPos[ 2 ] ) );
}
