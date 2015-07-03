#include maps\_vehicle_aianim;
#include maps\_vehicle;
main( model, type )
{
	//SNDFILE=vehicle_hummer

	if ( !isdefined( type ) )
		type = "humvee50cal";
	maps\_humvee::main( model, type );
	level.vehicle_aianims[ type ] = setanims( type );
	build_turret( "humvee_50cal_mg", "tag_turret", "vehicle_humvee_camo_50cal_mg", undefined, undefined, 2.9 );
}

#using_animtree( "generic_human" );
setanims( type )
{
	positions = level.vehicle_aianims[ type ];
	positions[ 4 ] = spawnstruct();

	positions[ 4 ].sittag = "tag_guy_turret";
//	positions[ 4 ].idle = %humvee_turret_idle;

	positions[ 4 ].getout = %humvee_driver_climb_out;
	positions[ 4 ].getin = %humvee_driver_climb_in;

//	positions[ 4 ].turret_fire = %humvee_turret_fire;

	positions[ 4 ].mgturret = 0;// which of the turrets is this guy going to use

	return positions;
}

