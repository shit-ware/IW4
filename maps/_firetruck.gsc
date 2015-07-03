#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type, no_death )
{
	build_template( "firetruck", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_ambulance_swat" );
	build_radiusdamage( ( 0, 0, 32 ), 300, 200, 100, false );
	build_drive( %uaz_driving_idle_forward, %uaz_driving_idle_backward, 10 );
	build_deathquake( 1, 1.6, 500 );
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
	for ( i = 0;i < 2;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "TAG_DRIVER";
	positions[ 1 ].sittag = "TAG_PASSENGER";

	positions[ 0 ].idle = %uaz_driver_idle_drive;
	positions[ 1 ].idle = %uaz_passenger_idle_drive;

	return positions;
}

/*QUAKED script_vehicle_firetruck (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_firetruck::main( "vehicle_firetruck" );

and these lines in your CSV:
include,vehicle_firetruck
sound,vehicle_firetruck,vehicle_standard,all_sp

defaultmdl="vehicle_firetruck"
default:"vehicletype" "firetruck"
*/










