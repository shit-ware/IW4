#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );

/*QUAKED script_vehicle_motorcycle_01 (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_motorcycle::main( "vehicle_motorcycle_01" );

and these lines in your CSV:
include,vehicle_motorcycle

defaultmdl="vehicle_motorcycle_01"
default:"vehicletype" "motorcycle"
*/

/*QUAKED script_vehicle_motorcycle_02 (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_motorcycle::main( "vehicle_motorcycle_02" );

and these lines in your CSV:
include,vehicle_motorcycle

defaultmdl="vehicle_motorcycle_02"
default:"vehicletype" "motorcycle"
*/

main( model, type )
{
	build_template( "motorcycle", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_motorcycle_01", "vehicle_motorcycle_01" );
	build_deathmodel( "vehicle_motorcycle_02", "vehicle_motorcycle_02" );
	build_deathfx( "explosions/large_vehicle_explosion", undefined, "explo_metal_rand" );

	//build_drive( %technical_driving_idle_forward, %technical_driving_idle_backward, 10 );
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_team( "axis" );
	build_aianims( ::setanims, ::set_vehicle_anims );
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

	for ( i = 0;i < 1;i++ )
		positions[ i ] = spawnstruct();
	positions[ 0 ].sittag = "tag_body";
	positions[ 0 ].idle = %motorcycle_rider_pose_f;

	return positions;
}

