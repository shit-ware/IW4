#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	//SNDFILE=vehicle_80s_car
	build_template( "small_wagon", model, type );
	build_localinit( ::init_local );

	build_deathmodel( "vehicle_small_wagon_white", "vehicle_small_wagon_d_white" );
	build_deathmodel( "vehicle_small_wagon_turq", "vehicle_small_wagon_d_turq" );
	build_deathmodel( "vehicle_small_wagon_green", "vehicle_small_wagon_d_green" );
	build_deathmodel( "vehicle_small_wagon_blue", "vehicle_small_wagon_d_blue" );

// don't know where the small_wagon series of destructibles went.. 
//	build_destructible( "vehicle_small_wagon_white_destructible_mp", "vehicle_small_wagon_white" );
//	build_destructible( "vehicle_small_wagon_blue_destructible_mp", "vehicle_small_wagon_blue" );
//	build_destructible( "vehicle_small_wagon_green_destructible_mp", "vehicle_small_wagon_green" );
//	build_destructible( "vehicle_small_wagon_turq_destructible_mp", "vehicle_small_wagon_turq" );

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

set_vehicle_anims( positions )
{
	return positions;
}

#using_animtree( "generic_human" );

setanims()
{
	positions = [];
	return positions;// no anims yet
}

/*QUAKED script_vehicle_small_wagon_blue (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_small_wagon::main( "vehicle_small_wagon_blue" );

and these lines in your CSV:
include,vehicle_small_wagon_blue_small_wagon
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_small_wagon_blue"
default:"vehicletype" "small_wagon"
default:"script_team" "allies"
*/

/*DISABLED script_vehicle_small_wagon_blue_destructible_mp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_small_wagon::main( "vehicle_small_wagon_blue_destructible_mp" );

and these lines in your CSV:
include,vehicle_small_wagon_blue_destructible_mp_small_wagon
include,destructible_vehicle_small_wagon_blue_destructible_mp
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_small_wagon_blue_destructible_mp"
default:"vehicletype" "small_wagon"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_small_wagon_green (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_small_wagon::main( "vehicle_small_wagon_green" );

and these lines in your CSV:
include,vehicle_small_wagon_green_small_wagon
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_small_wagon_green"
default:"vehicletype" "small_wagon"
default:"script_team" "allies"
*/

/*DISABLED script_vehicle_small_wagon_green_destructible_mp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_small_wagon::main( "vehicle_small_wagon_green_destructible_mp" );

and these lines in your CSV:
include,vehicle_small_wagon_green_destructible_mp_small_wagon
include,destructible_vehicle_small_wagon_green_destructible_mp
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_small_wagon_green_destructible_mp"
default:"vehicletype" "small_wagon"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_small_wagon_turq (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_small_wagon::main( "vehicle_small_wagon_turq" );

and these lines in your CSV:
include,vehicle_small_wagon_turq_small_wagon
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_small_wagon_turq"
default:"vehicletype" "small_wagon"
default:"script_team" "allies"
*/

/*DISABLED script_vehicle_small_wagon_turq_destructible_mp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_small_wagon::main( "vehicle_small_wagon_turq_destructible_mp" );

and these lines in your CSV:
include,vehicle_small_wagon_turq_destructible_mp_small_wagon
include,destructible_vehicle_small_wagon_turq_destructible_mp
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_small_wagon_turq_destructible_mp"
default:"vehicletype" "small_wagon"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_small_wagon_white (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_small_wagon::main( "vehicle_small_wagon_white" );

and these lines in your CSV:
include,vehicle_small_wagon_white_small_wagon
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_small_wagon_white"
default:"vehicletype" "small_wagon"
default:"script_team" "allies"
*/

/*DISABLED script_vehicle_small_wagon_white_destructible_mp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_small_wagon::main( "vehicle_small_wagon_white_destructible_mp" );

and these lines in your CSV:
include,vehicle_small_wagon_white_destructible_mp_small_wagon
include,destructible_vehicle_small_wagon_white_destructible_mp
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_small_wagon_white_destructible_mp"
default:"vehicletype" "small_wagon"
default:"script_team" "allies"
*/
