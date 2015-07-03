#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	//SNDFILE=vehicle_80s_car
	build_template( "small_hatchback", model, type );
	build_localinit( ::init_local );

	build_deathmodel( "vehicle_small_hatchback_blue", "vehicle_small_hatchback_d_blue" );
	build_deathmodel( "vehicle_small_hatchback_green", "vehicle_small_hatchback_d_green" );
	build_deathmodel( "vehicle_small_hatchback_turq", "vehicle_small_hatchback_d_turq" );
	build_deathmodel( "vehicle_small_hatchback_white", "vehicle_small_hatchback_d_white" );

	build_destructible( "vehicle_small_hatch_blue_destructible_mp", "vehicle_small_hatch_blue" );
	build_destructible( "vehicle_small_hatch_green_destructible_mp", "vehicle_small_hatch_green" );
	build_destructible( "vehicle_small_hatch_turq_destructible_mp", "vehicle_small_hatch_turq" );
	build_destructible( "vehicle_small_hatch_white_destructible_mp", "vehicle_small_hatch_white" );

 	build_deathfx( "explosions/large_vehicle_explosion", undefined, "explo_metal_rand" );

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
	return positions;
}


/*QUAKED script_vehicle_small_hatch_blue_destructible_mp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_small_hatchback::main( "vehicle_small_hatch_blue_destructible_mp" );

and these lines in your CSV:
include,vehicle_small_hatch_blue_destructible_mp_small_hatchback
include,destructible_vehicle_small_hatch_blue_destructible_mp
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_small_hatch_blue_destructible_mp"
default:"vehicletype" "small_hatchback"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_small_hatch_green_destructible_mp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_small_hatchback::main( "vehicle_small_hatch_green_destructible_mp" );

and these lines in your CSV:
include,vehicle_small_hatch_green_destructible_mp_small_hatchback
include,destructible_vehicle_small_hatch_green_destructible_mp
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_small_hatch_green_destructible_mp"
default:"vehicletype" "small_hatchback"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_small_hatch_turq_destructible_mp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_small_hatchback::main( "vehicle_small_hatch_turq_destructible_mp" );

and these lines in your CSV:
include,vehicle_small_hatch_turq_destructible_mp_small_hatchback
include,destructible_vehicle_small_hatch_turq_destructible_mp
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_small_hatch_turq_destructible_mp"
default:"vehicletype" "small_hatchback"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_small_hatch_white_destructible_mp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_small_hatchback::main( "vehicle_small_hatch_white_destructible_mp" );

and these lines in your CSV:
include,vehicle_small_hatch_white_destructible_mp_small_hatchback
include,destructible_vehicle_small_hatch_white_destructible_mp
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_small_hatch_white_destructible_mp"
default:"vehicletype" "small_hatchback"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_small_hatchback_blue (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_small_hatchback::main( "vehicle_small_hatchback_blue" );

and these lines in your CSV:
include,vehicle_small_hatchback_blue_small_hatchback
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_small_hatchback_blue"
default:"vehicletype" "small_hatchback"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_small_hatchback_green (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_small_hatchback::main( "vehicle_small_hatchback_green" );

and these lines in your CSV:
include,vehicle_small_hatchback_green_small_hatchback
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_small_hatchback_green"
default:"vehicletype" "small_hatchback"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_small_hatchback_turq (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_small_hatchback::main( "vehicle_small_hatchback_turq" );

and these lines in your CSV:
include,vehicle_small_hatchback_turq_small_hatchback
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_small_hatchback_turq"
default:"vehicletype" "small_hatchback"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_small_hatchback_white (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_small_hatchback::main( "vehicle_small_hatchback_white" );

and these lines in your CSV:
include,vehicle_small_hatchback_white_small_hatchback
sound,vehicle_80s_car,vehicle_standard,all_sp


defaultmdl="vehicle_small_hatchback_white"
default:"vehicletype" "small_hatchback"
default:"script_team" "allies"
*/
