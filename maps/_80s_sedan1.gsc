#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	//SNDFILE=vehicle_80s_car
	build_template( "80s_sedan1", model, type );
	build_localinit( ::init_local );

	build_deathmodel( "vehicle_80s_sedan1_brn", "vehicle_80s_sedan1_brn_destroyed" );
	build_deathmodel( "vehicle_80s_sedan1_green", "vehicle_80s_sedan1_green_destroyed" );
	build_deathmodel( "vehicle_80s_sedan1_red", "vehicle_80s_sedan1_red_destroyed" );
	build_deathmodel( "vehicle_80s_sedan1_silv", "vehicle_80s_sedan1_silv_destroyed" );
	build_deathmodel( "vehicle_80s_sedan1_tan", "vehicle_80s_sedan1_tan_destroyed" );
	build_deathmodel( "vehicle_80s_sedan1_yel", "vehicle_80s_sedan1_yel_destroyed" );

//	vehicle_80s_sedan1_brn_destructible
	build_destructible( "vehicle_80s_sedan1_brn_destructible_mp", "vehicle_80s_sedan1_brn" );
	build_destructible( "vehicle_80s_sedan1_green_destructible_mp", "vehicle_80s_sedan1_green" );
	build_destructible( "vehicle_80s_sedan1_red_destructible_mp", "vehicle_80s_sedan1_red" );
	build_destructible( "vehicle_80s_sedan1_silv_destructible_mp", "vehicle_80s_sedan1_silv" );
	build_destructible( "vehicle_80s_sedan1_tan_destructible_mp", "vehicle_80s_sedan1_tan" );
	build_destructible( "vehicle_80s_sedan1_yel_destructible_mp", "vehicle_80s_sedan1_yel" );
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

	for ( i = 0;i < 1;i++ )
		positions[ i ] = spawnstruct();
	positions[ 0 ].sittag = "tag_driver";
	positions[ 0 ].idle = %luxurysedan_driver_idle;

	return positions;
}


/*QUAKED script_vehicle_80s_sedan1_brn (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_80s_sedan1::main( "vehicle_80s_sedan1_brn" );

and these lines in your CSV:
include,vehicle_80s_sedan1_brn_80s_sedan1
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_80s_sedan1_brn"
default:"vehicletype" "80s_sedan1"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_80s_sedan1_brn_destructible_mp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_80s_sedan1::main( "vehicle_80s_sedan1_brn_destructible_mp" );

and these lines in your CSV:
include,vehicle_80s_sedan1_brn_destructible_mp_80s_sedan1
include,destructible_vehicle_80s_sedan1_brn_destructible_mp
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_80s_sedan1_brn_destructible_mp"
default:"vehicletype" "80s_sedan1"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_80s_sedan1_green (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_80s_sedan1::main( "vehicle_80s_sedan1_green" );

and these lines in your CSV:
include,vehicle_80s_sedan1_green_80s_sedan1
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_80s_sedan1_green"
default:"vehicletype" "80s_sedan1"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_80s_sedan1_green_destructible_mp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_80s_sedan1::main( "vehicle_80s_sedan1_green_destructible_mp" );

and these lines in your CSV:
include,vehicle_80s_sedan1_green_destructible_mp_80s_sedan1
include,destructible_vehicle_80s_sedan1_green_destructible_mp
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_80s_sedan1_green_destructible_mp"
default:"vehicletype" "80s_sedan1"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_80s_sedan1_red (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_80s_sedan1::main( "vehicle_80s_sedan1_red" );

and these lines in your CSV:
include,vehicle_80s_sedan1_red_80s_sedan1
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_80s_sedan1_red"
default:"vehicletype" "80s_sedan1"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_80s_sedan1_red_destructible_mp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_80s_sedan1::main( "vehicle_80s_sedan1_red_destructible_mp" );

and these lines in your CSV:
include,vehicle_80s_sedan1_red_destructible_mp_80s_sedan1
include,destructible_vehicle_80s_sedan1_red_destructible_mp
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_80s_sedan1_red_destructible_mp"
default:"vehicletype" "80s_sedan1"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_80s_sedan1_silv (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_80s_sedan1::main( "vehicle_80s_sedan1_silv" );

and these lines in your CSV:
include,vehicle_80s_sedan1_silv_80s_sedan1
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_80s_sedan1_silv"
default:"vehicletype" "80s_sedan1"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_80s_sedan1_silv_destructible_mp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_80s_sedan1::main( "vehicle_80s_sedan1_silv_destructible_mp" );

and these lines in your CSV:
include,vehicle_80s_sedan1_silv_destructible_mp_80s_sedan1
include,destructible_vehicle_80s_sedan1_silv_destructible_mp
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_80s_sedan1_silv_destructible_mp"
default:"vehicletype" "80s_sedan1"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_80s_sedan1_tan (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_80s_sedan1::main( "vehicle_80s_sedan1_tan" );

and these lines in your CSV:
include,vehicle_80s_sedan1_tan_80s_sedan1
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_80s_sedan1_tan"
default:"vehicletype" "80s_sedan1"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_80s_sedan1_tan_destructible_mp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_80s_sedan1::main( "vehicle_80s_sedan1_tan_destructible_mp" );

and these lines in your CSV:
include,vehicle_80s_sedan1_tan_destructible_mp_80s_sedan1
include,destructible_vehicle_80s_sedan1_tan_destructible_mp
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_80s_sedan1_tan_destructible_mp"
default:"vehicletype" "80s_sedan1"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_80s_sedan1_yel (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_80s_sedan1::main( "vehicle_80s_sedan1_yel" );

and these lines in your CSV:
include,vehicle_80s_sedan1_yel_80s_sedan1
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_80s_sedan1_yel"
default:"vehicletype" "80s_sedan1"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_80s_sedan1_yel_destructible_mp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_80s_sedan1::main( "vehicle_80s_sedan1_yel_destructible_mp" );

and these lines in your CSV:
include,vehicle_80s_sedan1_yel_destructible_mp_80s_sedan1
include,destructible_vehicle_80s_sedan1_yel_destructible_mp
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_80s_sedan1_yel_destructible_mp"
default:"vehicletype" "80s_sedan1"
default:"script_team" "allies"
*/