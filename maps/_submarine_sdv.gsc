#include common_scripts\utility;
#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );

main( model, type )
{
	build_template( "submarine_sdv", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_submarine_sdv" );
	build_compassicon( "camera", false );
	build_life( 999, 500, 1500 );
	build_rumble( "tank_rumble", 0.05, 1.5, 900, 1, 1 );
	build_team( "allies" );
}

init_local()
{
}


/*QUAKED script_vehicle_submarine_sdv (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_submarine_sdv::main( "vehicle_submarine_sdv" );

and these lines in your CSV:
include,vehicle_submarine_sdv_submarine_sdv
sound,vehicle_submarine_sdv,vehicle_standard,all_sp


defaultmdl="vehicle_submarine_sdv"
default:"vehicletype" "submarine_sdv"
default:"script_team" "allies"
*/
