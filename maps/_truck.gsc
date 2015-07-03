#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	build_template( "truck", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_pickup_roobars", "vehicle_pickup_roobars_destroyed", 2 );
	build_deathmodel( "vehicle_pickup_4door", "vehicle_pickup_technical_destroyed", 2 );
	build_deathmodel( "vehicle_opfor_truck", "vehicle_pickup_technical_destroyed", 2 );

	//	build_deathfx( effect, 								tag, 					sound, 				bEffectLooping, 	delay, 			bSoundlooping, waitDelay, stayontag, notifyString )
/*  old
	build_deathfx( "explosions/small_vehicle_explosion", 	undefined, 				"car_explode", 		undefined, 			undefined, 		undefined, 		0 );
	build_deathfx( "fire/firelp_small_pm_a", 				"tag_fx_tire_right_r", 	"smallfire", 		undefined, 			undefined, 		true, 			0 );
	build_deathfx( "fire/firelp_med_pm", 					"tag_fx_cab", 			"smallfire", 		undefined, 			undefined, 		true, 			0 );
	build_deathfx( "fire/firelp_small_pm_a", 				"tag_engine_left", 		"smallfire", 		undefined, 			undefined, 		true, 			0 );
*/
/*  tech
	build_deathfx( "fire/firelp_med_pm", 						"tag_fx_tank", 			"smallfire", 		undefined, 			undefined, 		true, 			0 );
	build_deathfx( "explosions/ammo_cookoff", 					"tag_fx_bed", 			undefined, 			undefined, 			undefined, 		undefined, 		0.5 );
//	build_deathfx( "explosions/ammo_cookoff",					"tag_fx_bed",			undefined,			undefined,			undefined,		undefined,		1 );
	build_deathfx( "explosions/Vehicle_Explosion_Pickuptruck", 	"tag_deathfx", 			"car_explode", 		undefined, 			undefined, 		undefined, 		2.9 );
	build_deathfx( "fire/firelp_small_pm_a", 					"tag_fx_tire_right_r", 	"smallfire", 		undefined, 			undefined, 		true, 			3 );
	build_deathfx( "fire/firelp_med_pm", 						"tag_fx_cab", 			"fire_metal_medium", undefined, 			undefined, 		true, 			3.01 );
	build_deathfx( "fire/firelp_small_pm_a", 					"tag_engine_left", 		"smallfire", 		undefined, 			undefined, 		true, 			3.01 );
*/

	build_deathfx( "fire/firelp_med_pm", 					"tag_body", 			"smallfire", 		undefined, 			undefined, 		true, 			0, true );
	build_deathfx( "explosions/small_vehicle_explosion", 	undefined, 				"car_explode", 		undefined, 			undefined, 		undefined, 		1.9, true );
	build_deathfx( "fire/firelp_small_pm_a", 				"tag_fx_tire_right_r", 	"smallfire", 		undefined, 			undefined, 		true, 			2, true );
	build_deathfx( "fire/firelp_med_pm", 					"tag_fx_cab", 			"smallfire", 		undefined, 			undefined, 		true, 			2.01, true );
	build_deathfx( "fire/firelp_small_pm_a", 				"tag_engine_left", 		"smallfire", 		undefined, 			undefined, 		true, 			2.01, true );

	build_drive( %technical_driving_idle_forward, %technical_driving_idle_backward, 10 );

	build_treadfx();
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_unload_groups( ::Unload_Groups );


	build_light( model, "headlight_truck_left", 		"tag_headlight_left", 		"misc/car_headlight_truck_L", 		"headlights" );
	build_light( model, "headlight_truck_right", 		"tag_headlight_right", 		"misc/car_headlight_truck_R", 		"headlights" );
	build_light( model, "parkinglight_truck_left_f", 	"tag_parkinglight_left_f", 	"misc/car_parkinglight_truck_LF", 	"headlights" );
	build_light( model, "parkinglight_truck_right_f", 	"tag_parkinglight_right_f", "misc/car_parkinglight_truck_RF", 	"headlights" );
	build_light( model, "taillight_truck_right", 	 	"tag_taillight_right", 		"misc/car_taillight_truck_R", 		"headlights" );
	build_light( model, "taillight_truck_left", 		 	"tag_taillight_left", 		"misc/car_taillight_truck_L", 		"headlights" );

	build_light( model, "brakelight_truck_right", 		"tag_taillight_right", 		"misc/car_brakelight_truck_R", 		"brakelights" );
	build_light( model, "brakelight_truck_left", 		"tag_taillight_left", 		"misc/car_brakelight_truck_L", 		"brakelights" );
	build_compassicon( "automobile", false );

	build_radiusdamage( ( 0, 0, 32 ), 200, 150, 0, false, 2 );

}

init_local()
{
//	maps\_vehicle::lights_on( "headlights" );
//	maps\_vehicle::lights_on( "brakelights" );
}

set_vehicle_anims( positions )
{

	positions[ 0 ].vehicle_getoutanim = %door_pickup_driver_climb_out;
	positions[ 1 ].vehicle_getoutanim = %door_pickup_passenger_climb_out;
	positions[ 2 ].vehicle_getoutanim = %door_pickup_passenger_RR_climb_out;
	positions[ 3 ].vehicle_getoutanim = %door_pickup_passenger_RL_climb_out;

	positions[ 0 ].vehicle_getoutanim_clear = false;
	positions[ 1 ].vehicle_getoutanim_clear = false;
	positions[ 2 ].vehicle_getoutanim_clear = false;
	positions[ 3 ].vehicle_getoutanim_clear = false;

	positions[ 0 ].vehicle_getinanim = %door_pickup_driver_climb_in;
	positions[ 1 ].vehicle_getinanim = %door_pickup_passenger_climb_in;
	//positions[ 2 ].vehicle_getinanim = %door_pickup_driver_climb_in;
	//positions[ 3 ].vehicle_getinanim = %door_pickup_passenger_climb_in;
		return positions;

}


#using_animtree( "generic_human" );

setanims()
{
	positions = [];
	for ( i = 0;i < 6;i++ )
		positions[ i ] = spawnstruct();

	//	positions[ 0 ].getout_delete = true;

	/*
	pickup_driver_climb_out
	pickup_passenger_climb_out
	pickup_passenger_RL_idle
	pickup_passenger_RL_climb_out
	pickup_passenger_RR_idle
	pickup_passenger_RR_climb_out
	technical_passenger_climb_out
	
	*/

	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_passenger";
	positions[ 2 ].sittag = "tag_guy1";// RR
	positions[ 3 ].sittag = "tag_guy0";// RL
	positions[ 4 ].sittag = "tag_guy3";// RR
	positions[ 5 ].sittag = "tag_guy4";// RL

	positions[ 0 ].idle = %technical_driver_idle;
	positions[ 1 ].idle = %technical_passenger_idle;
	positions[ 2 ].idle = %pickup_passenger_RR_idle; // RL
	positions[ 3 ].idle = %pickup_passenger_RR_idle; // RR
	positions[ 4 ].idle = %pickup_passenger_RR_idle; // RL
	positions[ 5 ].idle = %pickup_passenger_RR_idle; // RR

	positions[ 0 ].getout = %pickup_driver_climb_out;
	positions[ 1 ].getout = %pickup_passenger_climb_out;
	positions[ 2 ].getout = %pickup_passenger_RR_climb_out;
	positions[ 3 ].getout = %pickup_passenger_RL_climb_out;
	positions[ 4 ].getout = %pickup_passenger_RR_climb_out;
	positions[ 5 ].getout = %pickup_passenger_RL_climb_out;

	positions[ 0 ].getin = %pickup_driver_climb_in;
	positions[ 1 ].getin = %pickup_passenger_climb_in;
	//positions[ 2 ].getin = %pickup_driver_climb_in;  //ghetto temp
	//positions[ 3 ].getin = %pickup_passenger_climb_in; //ghetto temp

	return positions;
}

unload_groups()
{
	unload_groups = [];
	unload_groups[ "passengers" ] = [];
	unload_groups[ "all" ] = [];

	group = "passengers";
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ group ][ unload_groups[ group ].size ] = 4;
	unload_groups[ group ][ unload_groups[ group ].size ] = 5;

	group = "all";
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ group ][ unload_groups[ group ].size ] = 4;
	unload_groups[ group ][ unload_groups[ group ].size ] = 5;

	unload_groups[ "default" ] = unload_groups[ "all" ];

	return unload_groups;
}





/*QUAKED script_vehicle_opfor_truck (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_truck::main( "vehicle_opfor_truck" );

and these lines in your CSV:
include,vehicle_opfor_truck_truck
sound,vehicle_truck,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_opfor_truck"
default:"vehicletype" "truck"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_pickup_4door (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_truck::main( "vehicle_pickup_4door" );

and these lines in your CSV:
include,vehicle_pickup_4door_truck
sound,vehicle_truck,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_pickup_4door"
default:"vehicletype" "truck"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_pickup_roobars (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_truck::main( "vehicle_pickup_roobars" );

and these lines in your CSV:
include,vehicle_pickup_roobars_truck
sound,vehicle_truck,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_pickup_roobars"
default:"vehicletype" "truck"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_pickup_roobars_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_truck::main( "vehicle_pickup_roobars", "truck_physics" );

and these lines in your CSV:
include,vehicle_pickup_roobars_truck
sound,vehicle_truck,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_pickup_roobars"
default:"vehicletype" "truck_physics"
default:"script_team" "allies"
*/