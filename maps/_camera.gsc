#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	build_template( "camera", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_camera" );
	build_compassicon( "camera", false );
}

init_local()
{
}

/*QUAKED script_vehicle_camera (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_camera::main( "vehicle_camera" );

and these lines in your CSV:
include,vehicle_camera_camera


defaultmdl="vehicle_camera"
default:"vehicletype" "camera"
*/