#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	//SNDFILE=vehicle_coupe_car
	build_template( "coupe", model, type );
	build_localinit( ::init_local );
	
	build_destructible( "vehicle_coupe_gold_destructible", "vehicle_coupe_gold" );
	build_destructible( "vehicle_coupe_gray_destructible", "vehicle_coupe_gray" );

	build_radiusdamage( ( 0, 0, 32 ), 300, 200, 100, false );
	build_drive( %uaz_driving_idle_forward, %uaz_driving_idle_backward, 10 );
	build_deathquake( 1, 1.6, 500 );

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
		positions[ 0 ].vehicle_getoutanim = %uaz_driver_exit_into_stand_door;
		positions[ 1 ].vehicle_getoutanim = %uaz_passenger_exit_into_stand_door;

		positions[ 0 ].vehicle_getoutanim_clear = false;
		positions[ 1 ].vehicle_getoutanim_clear = false;

		return positions;
}

#using_animtree( "generic_human" );

setanims()
{
	positions = [];
	
	for ( i = 0;i < 2;i++ )
		positions[ i ] = spawnstruct();
	positions[ 0 ].sittag = "tag_driver";
	positions[ 0 ].idle = %luxurysedan_driver_idle;
	positions[ 0 ].death = %luxurysedan_driver_idle;
	
	positions[ 1 ].sittag = "tag_passenger";
	positions[ 1 ].idle = %uaz_passenger_idle_drive;
	positions[ 1 ].death = %uaz_passenger_idle_drive;
	
	positions[ 0 ].getout = %humvee_passenger_out_L;
	positions[ 1 ].getout = %humvee_passenger_out_R;
	
	return positions;
}

/*QUAKED script_vehicle_coupe_gray (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_coupe::main( "vehicle_coupe_gray_destructible" );

and these lines in your CSV:
include,vehicle_coupe_gray
sound,vehicle_coupe,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp


defaultmdl="vehicle_coupe_gray_destructible"
default:"vehicletype" "coupe"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_coupe_gold (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_coupe::main( "vehicle_coupe_gold_destructible" );

and these lines in your CSV:
include,vehicle_coupe_gold
sound,vehicle_coupe,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp


defaultmdl="vehicle_coupe_gold_destructible"
default:"vehicletype" "coupe"
default:"script_team" "allies"
*/