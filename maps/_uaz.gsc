#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );


main( model, type, no_death )
{
	build_template( "uaz", model, type );
	build_localinit( ::init_local );

//	build_destructible( "vehicle_uaz_hardtop_destructible_mp", "vehicle_uaz_hardtop" );
//	build_destructible( "vehicle_uaz_light_destructible_mp", "vehicle_uaz_light" );
//	build_destructible( "vehicle_uaz_open_destructible_mp", "vehicle_uaz_open" );
//	build_destructible( "vehicle_uaz_fabric_destructible_mp", "vehicle_uaz_fabric" );
	build_destructible( "vehicle_uaz_winter_destructible", "vehicle_uaz_winter" );
	build_destructible( "vehicle_uaz_open_destructible", "vehicle_uaz_open" );

	build_bulletshield( false );//no bullet shield for cliffhanger -z

	if ( !isdefined( no_death ) )
	{
		
		build_deathmodel( "vehicle_uaz_light", "vehicle_uaz_light_dsr" );
		build_deathmodel( "vehicle_uaz_winter", "vehicle_uaz_winter_destroy" );
		build_deathmodel( "vehicle_uaz_fabric", "vehicle_uaz_fabric_dsr" );
		build_deathmodel( "vehicle_uaz_hardtop", "vehicle_uaz_hardtop_dsr" );
		build_deathmodel( "vehicle_uaz_open", "vehicle_uaz_open_dsr" );
		build_deathmodel( "vehicle_uaz_hardtop_thermal", "vehicle_uaz_hardtop_thermal" );
		build_deathmodel( "vehicle_uaz_open_for_ride" );
		build_deathfx( "explosions/small_vehicle_explosion", undefined, "explo_metal_rand" );
	}

	build_radiusdamage( ( 0, 0, 32 ), 300, 200, 100, false );
	build_drive( %uaz_driving_idle_forward, %uaz_driving_idle_backward, 10 );
	build_deathquake( 1, 1.6, 500 );

	build_treadfx();
	build_life( 2500, 2400, 2600 );
	//explosives are x15
	build_team( "axis" );
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_compassicon( "uaz", false );

}

init_local()
{
	self.clear_anims_on_death  = true;// hackery workaround for strange anim differences in the variety of uaz models. clears driving and possibly door openning animations upon death.
	if( !isdefined( self.script_allow_rider_deaths ) )
		self.script_allow_rider_deaths = false; // this added at the end of the project some people wanted deathanims and some scripts assumed death would never happen.
}


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

		positions[ 0 ].vehicle_getoutsound = "uaz_door_open";
		positions[ 1 ].vehicle_getoutsound = "uaz_door_open";
		positions[ 2 ].vehicle_getoutsound = "uaz_door_open";
		positions[ 3 ].vehicle_getoutsound = "uaz_door_open";

		positions[ 0 ].vehicle_getinsound = "uaz_door_open";
		positions[ 1 ].vehicle_getinsound = "uaz_door_open";
		positions[ 2 ].vehicle_getinsound = "uaz_door_open";
		positions[ 3 ].vehicle_getinsound = "uaz_door_open";

//		positions[ 0 ].vehicle_getinsoundtag = "TAG_DOOR_LEFT_FRONT";
//		positions[ 1 ].vehicle_getinsoundtag = "TAG_DOOR_RIGHT_FRONT";
//		positions[ 2 ].vehicle_getinsoundtag = "TAG_DOOR_LEFT_BACK";
//		positions[ 3 ].vehicle_getinsoundtag = "TAG_DOOR_RIGHT_BACK";

		return positions;
}



#using_animtree( "generic_human" );

setanims()
{

	positions = [];
	for ( i = 0;i < 6;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_passenger";
	positions[ 2 ].sittag = "tag_guy0";// driver_side_rear
	positions[ 3 ].sittag = "tag_guy1";// passenger_side_rear
	positions[ 4 ].sittag = "tag_guy2";// driver_far_rear
	positions[ 5 ].sittag = "tag_guy3";// passenger_side_far_rear

	positions[ 0 ].idle = %uaz_driver_idle_drive;
	positions[ 1 ].idle = %uaz_passenger_idle_drive;
	positions[ 2 ].idle = %uaz_rear_driver_idle;
	positions[ 3 ].idle = %uaz_passenger2_idle;
	positions[ 4 ].idle = %uaz_rear_driver_idle;
	positions[ 5 ].idle = %uaz_passenger2_idle;

	positions[ 0 ].getout = %uaz_driver_exit_into_stand;
	positions[ 1 ].getout = %uaz_passenger_exit_into_stand;
	positions[ 2 ].getout = %uaz_rear_driver_exit_into_stand;
	positions[ 3 ].getout = %uaz_passenger2_exit_into_stand;

	positions[ 0 ].getin = %uaz_driver_enter_from_huntedrun;
	positions[ 1 ].getin = %uaz_passenger_enter_from_huntedrun;
	positions[ 2 ].getin = %uaz_rear_driver_enter_from_huntedrun;
	positions[ 3 ].getin = %uaz_passenger2_enter_from_huntedrun;

	positions[ 0 ].death = %UAZ_driver_death;
	positions[ 1 ].death = %UAZ_rear_driver_death;
	positions[ 2 ].death = %UAZ_rear_driver_death;
	positions[ 3 ].death = %UAZ_rear_driver_death;
		
	positions[ 0 ].death_no_ragdoll = true;
	positions[ 1 ].death_no_ragdoll = true;
	positions[ 2 ].death_no_ragdoll = true;
	positions[ 3 ].death_no_ragdoll = true;

	return positions;


}


/*QUAKED script_vehicle_uaz_fabric (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_uaz::main( "vehicle_uaz_fabric" );

and these lines in your CSV:
include,vehicle_uaz_fabric_uaz
sound,vehicle_uaz,vehicle_standard,all_sp


defaultmdl="vehicle_uaz_fabric"
default:"vehicletype" "uaz"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_uaz_hardtop (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_uaz::main( "vehicle_uaz_hardtop" );

and these lines in your CSV:
include,vehicle_uaz_hardtop_uaz
sound,vehicle_uaz,vehicle_standard,all_sp


defaultmdl="vehicle_uaz_hardtop"
default:"vehicletype" "uaz"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_uaz_hardtop_thermal (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_uaz::main( "vehicle_uaz_hardtop_thermal" );

and these lines in your CSV:
include,vehicle_uaz_hardtop_thermal_uaz
sound,vehicle_uaz,vehicle_standard,all_sp


defaultmdl="vehicle_uaz_hardtop_thermal"
default:"vehicletype" "uaz"
default:"script_team" "axis"
*/


/*QUAKED script_vehicle_uaz_open (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_uaz::main( "vehicle_uaz_open" );

and these lines in your CSV:
include,vehicle_uaz_open_uaz
sound,vehicle_uaz,vehicle_standard,all_sp


defaultmdl="vehicle_uaz_open"
default:"vehicletype" "uaz"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_uaz_open_for_ride (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_uaz::main( "vehicle_uaz_open_for_ride" );

and these lines in your CSV:
include,vehicle_uaz_open_for_ride_uaz
sound,vehicle_uaz,vehicle_standard,all_sp


defaultmdl="vehicle_uaz_open_for_ride"
default:"vehicletype" "uaz"
*/

/*QUAKED script_vehicle_uaz_open_destructible (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_uaz::main( "vehicle_uaz_open_destructible", "uaz_physics" );

and these lines in your CSV:
include,vehicle_uaz_open_destructible
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_uaz,vehicle_standard,all_sp

defaultmdl="vehicle_uaz_open_destructible"
default:"vehicletype" "uaz_physics"
*/

/*QUAKED script_vehicle_uaz_hardtop_thermal (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_uaz_ac130::main( "vehicle_uaz_hardtop_thermal" );

and these lines in your CSV:
include,vehicle_uaz_hardtop_thermal_uaz_ac130


defaultmdl="vehicle_uaz_hardtop_thermal"
default:"vehicletype" "uaz_ac130"
*/

// disabled the winter destructible. It doesn't have tags fr the guys.
/*QUAKED script_vehicle_uaz_winter_destructible (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_uaz::main( "vehicle_uaz_winter_destructible" );

and these lines in your CSV:
include,vehicle_uaz_winter_destructible
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_uaz,vehicle_standard,all_sp

defaultmdl="vehicle_uaz_winter_destructible"
default:"vehicletype" "uaz"
*/

/*QUAKED script_vehicle_uaz_winter_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_uaz::main( "vehicle_uaz_winter_destructible", "uaz_physics" );

and these lines in your CSV:
include,vehicle_uaz_winter_destructible
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_uaz,vehicle_standard,all_sp

defaultmdl="vehicle_uaz_winter_destructible"
default:"vehicletype" "uaz_physics"
*/


/*QUAKED script_vehicle_uaz_winter (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_uaz::main( "vehicle_uaz_winter" );

and these lines in your CSV:
include,vehicle_uaz_winter
sound,vehicle_uaz,vehicle_standard,all_sp

defaultmdl="vehicle_uaz_winter"
default:"vehicletype" "uaz"
*/

/*QUAKED script_vehicle_uaz_light (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_uaz::main( "vehicle_uaz_light" );

and these lines in your CSV:
include,vehicle_uaz_light
sound,vehicle_uaz,vehicle_standard,all_sp

defaultmdl="vehicle_uaz_light"
default:"vehicletype" "uaz"
*/

/*QUAKED script_vehicle_uaz_open_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_uaz::main( "vehicle_uaz_open", "uaz_physics" );

and these lines in your CSV:
include,vehicle_uaz_open_uaz
sound,vehicle_uaz,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_uaz_open"
default:"vehicletype" "uaz_physics"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_uaz_hardtop_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_uaz::main( "vehicle_uaz_hardtop", "uaz_physics" );

and these lines in your CSV:
include,vehicle_uaz_hardtop_uaz
sound,vehicle_uaz,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_uaz_hardtop"
default:"vehicletype" "uaz_physics"
default:"script_team" "axis"
*/