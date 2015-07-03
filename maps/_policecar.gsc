#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	//SNDFILE=vehicle_coupe_car
	build_template( "policecar", model, type );
	build_localinit( ::init_local );
	
	build_destructible( "vehicle_policecar_lapd_destructible", "vehicle_policecar" );
	build_destructible( "vehicle_policecar_russia_destructible", "vehicle_policecar_russia" );
	
	build_deathmodel( "vehicle_policecar_lapd_destructible", "vehicle_policecar_lapd_destroy" );
	build_deathmodel( "vehicle_policecar_russia_destructible", "vehicle_policecar_russia_destroy" );
	
	build_drive( %technical_driving_idle_forward, %technical_driving_idle_backward, 10 );

	build_treadfx();
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_compassicon( "automobile", false );
}

init_local()
{

}

//MO EDIT: Nate told me to put this in here ( from _uaz.gsc )
set_vehicle_anims( positions )
{
//
//tag_driver
//tag_passenger
//tag_guy0(behind driver)
//tag_guy1(behind passenger)	
	
	
//positions[ 0 ].sittag = "tag_driver";   
//positions[ 1 ].sittag = "tag_passenger";
//positions[ 2 ].sittag = "tag_guy0"; //driver_side_rear        
//positions[ 3 ].sittag = "tag_guy1";  //passenger_side_rear    
//positions[ 4 ].sittag = "tag_guy2"; //driver_far_rear         
//positions[ 5 ].sittag = "tag_guy3";  //passenger_side_far_rear

		positions[ 0 ].vehicle_getoutanim = %uaz_driver_exit_into_stand_door;
		positions[ 1 ].vehicle_getoutanim = %uaz_passenger_exit_into_stand_door;
		positions[ 2 ].vehicle_getoutanim = %uaz_rear_driver_exit_into_stand_door;                           
		positions[ 3 ].vehicle_getoutanim = %uaz_passenger2_exit_into_stand_door;                            


		positions[ 0 ].vehicle_getoutanim_clear = false;
		positions[ 1 ].vehicle_getoutanim_clear = false;
		positions[ 2 ].vehicle_getoutanim_clear = false;
		positions[ 3 ].vehicle_getoutanim_clear = false;

		positions[ 0 ].vehicle_getinanim = %uaz_driver_enter_from_huntedrun_door;
		positions[ 1 ].vehicle_getinanim = %uaz_passenger_enter_from_huntedrun_door;
		positions[ 2 ].vehicle_getinanim = %uaz_rear_driver_enter_from_huntedrun_door;
		positions[ 3 ].vehicle_getinanim = %uaz_passenger2_enter_from_huntedrun_door;

		positions[ 0 ].vehicle_getinsound = "truck_door_open";
		positions[ 1 ].vehicle_getinsound = "truck_door_open";
		positions[ 2 ].vehicle_getinsound = "truck_door_open";
		positions[ 3 ].vehicle_getinsound = "truck_door_open";

//		positions[ 0 ].vehicle_getinsoundtag = "TAG_DOOR_LEFT_FRONT";
//		positions[ 1 ].vehicle_getinsoundtag = "TAG_DOOR_RIGHT_FRONT";
//		positions[ 2 ].vehicle_getinsoundtag = "TAG_DOOR_LEFT_BACK";
//		positions[ 3 ].vehicle_getinsoundtag = "TAG_DOOR_RIGHT_BACK";

		return positions;
}


#using_animtree( "generic_human" );
//MO EDIT: Nate told me to put this in here ( from _uaz.gsc )
setanims()
{

	positions = [];
	for ( i = 0;i < 6;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_passenger";
	positions[ 2 ].sittag = "tag_guy0";// driver_side_rear
	positions[ 3 ].sittag = "tag_guy1";// passenger_side_rear
//	positions[ 4 ].sittag = "tag_guy2";// driver_far_rear
//	positions[ 5 ].sittag = "tag_guy3";// passenger_side_far_rear

	positions[ 0 ].idle = %uaz_driver_idle_drive;
	positions[ 1 ].idle = %uaz_passenger_idle_drive;
	positions[ 2 ].idle = %uaz_rear_driver_idle;
	positions[ 3 ].idle = %uaz_passenger2_idle;
//	positions[ 4 ].idle = %uaz_rear_driver_idle;
//	positions[ 5 ].idle = %uaz_passenger2_idle;

	positions[ 0 ].getout = %uaz_driver_exit_into_stand;
	positions[ 1 ].getout = %uaz_passenger_exit_into_stand;
	positions[ 2 ].getout = %uaz_rear_driver_exit_into_stand;
	positions[ 3 ].getout = %uaz_passenger2_exit_into_stand;

	positions[ 0 ].getin = %uaz_driver_enter_from_huntedrun;
	positions[ 1 ].getin = %uaz_passenger_enter_from_huntedrun;
	positions[ 2 ].getin = %uaz_rear_driver_enter_from_huntedrun;
	positions[ 3 ].getin = %uaz_passenger2_enter_from_huntedrun;


	return positions;


}


/*QUAKED script_vehicle_policecar_lapd (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_policecar::main( "vehicle_policecar_lapd_destructible" );

and these lines in your CSV:
include,vehicle_policecar_lapd
sound,vehicle_policecar_lapd,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_policecar_lapd_destructible"
default:"vehicletype" "policecar"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_policecar_russia (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_policecar::main( "vehicle_policecar_russia_destructible" );

and these lines in your CSV:
include,vehicle_policecar_russia
sound,vehicle_policecar_lapd,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_policecar_russia_destructible"
default:"vehicletype" "policecar"
default:"script_team" "axis"
*/