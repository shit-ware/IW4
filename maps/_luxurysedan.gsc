#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	build_template( "luxurysedan", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_luxurysedan", "vehicle_luxurysedan_destroy" );
	build_deathmodel( "vehicle_luxurysedan_test", "vehicle_luxurysedan_destroy" );
	build_deathmodel( "vehicle_luxurysedan_2009_viewmodel", "vehicle_luxurysedan_2009_viewmodel" );
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

	for ( i = 0;i < 1;i++ )
		positions[ i ] = spawnstruct();
	positions[ 0 ].sittag = "tag_driver";
	positions[ 0 ].idle = %coup_driver_idle;

	return positions;
}

/*QUAKED script_vehicle_luxurysedan (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_luxurysedan::main( "vehicle_luxurysedan" );

and these lines in your CSV:
include,vehicle_luxurysedan_luxurysedan
sound,vehicle_luxerysedan,vehicle_standard,all_sp


defaultmdl="vehicle_luxurysedan"
default:"vehicletype" "luxurysedan"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_luxurysedan_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_luxurysedan::main( "vehicle_luxurysedan", "luxurysedan_physics" );

and these lines in your CSV:
include,vehicle_luxurysedan_luxurysedan
sound,vehicle_luxerysedan,vehicle_standard,all_sp


defaultmdl="vehicle_luxurysedan"
default:"vehicletype" "luxurysedan_physics"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_luxurysedan_test (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_luxurysedan::main( "vehicle_luxurysedan_test" );

and these lines in your CSV:
include,vehicle_luxurysedan_test_luxurysedan
sound,vehicle_luxerysedan,vehicle_standard,all_sp


defaultmdl="vehicle_luxurysedan_test"
default:"vehicletype" "luxurysedan"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_luxurysedan_viewmodel (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_luxurysedan::main( "vehicle_luxurysedan_2009_viewmodel" );

and these lines in your CSV:
include,vehicle_luxurysedan_viewmodel_luxurysedan
sound,vehicle_luxerysedan,vehicle_standard,all_sp


defaultmdl="vehicle_luxurysedan_2009_viewmodel"
default:"vehicletype" "luxurysedan"
default:"script_team" "allies"
*/

