#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );

main( model, type )
{

	build_template( "snowmobile_player", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_snowmobile", "vehicle_snowmobile_static" );// RADNAME = _player
	build_deathfx( "explosions/large_vehicle_explosion", undefined, "explo_metal_rand" );
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_compassicon( "automobile", false );
	build_team( "allies" );
}

init_local()
{
}

set_vehicle_anims( positions )
{
	return positions;
}

#using_animtree( "generic_human" );
setanims()
{
	positions = [];
	for ( i = 0; i < 2; i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].getout_delete = true;

	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_passenger";


	return positions;
}

/*QUAKED script_vehicle_snowmobile_player (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_snowmobile_player::main( "vehicle_snowmobile" );

and these lines in your CSV:
include,vehicle_snowmobile_snowmobile_player
sound,vehicle_snowmobile,vehicle_standard,all_sp


defaultmdl="vehicle_snowmobile"
default:"vehicletype" "snowmobile_player"
default:"script_team" "allies"
*/


/*QUAKED script_vehicle_snowmobile_player_alt (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_snowmobile_player::main( "vehicle_snowmobile_alt" );

and these lines in your CSV:
include,vehicle_snowmobile_snowmobile_player
sound,vehicle_snowmobile,vehicle_standard,all_sp


defaultmdl="vehicle_snowmobile_alt"
default:"vehicletype" "snowmobile_player"
default:"script_team" "allies"
*/