#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );

main( model, type )
{
	//SNDFILE=vehicle_hummer

	precacheModel( "vehicle_m60a1_bridge" );
	build_template( "bridge_layer", model, type );
	build_localinit( ::init_local );

	build_deathmodel( "vehicle_bridge_layer", "vehicle_hummer_destroyed" );
	build_drive( %abrams_movement, %abrams_movement_backwards, 10 );

	build_deathfx( "fire/firelp_med_pm", "TAG_CAB_FIRE", "fire_metal_medium", undefined, undefined, true, 0 );
	build_deathfx( "explosions/vehicle_explosion_hummer", "tag_deathfx", "car_explode" );

//	build_drive( %humvee_50cal_driving_idle_forward, %humvee_50cal_driving_idle_backward, 10 );
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	build_compassicon( "automobile", false );

}

init_local()
{
	model = spawn( "script_model", (0,0,0) );
	model setmodel( "vehicle_m60a1_bridge" );
	model linkto( self, "tag_bridge_attach", (0,0,0), (0,0,0) );
	self.bridge_model = model;
}



/*QUAKED script_vehicle_bridge_layer (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_bridge_layer::main( "vehicle_bridge_layer" );

and these lines in your CSV:
include,vehicle_bridge_layer
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_bridge_layer,vehicle_standard,all_sp

defaultmdl="vehicle_bridge_layer"
default:"vehicletype" "bridge_layer"
default:"script_team" "allies"
*/

