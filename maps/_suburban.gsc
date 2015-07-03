#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );


/*QUAKED script_vehicle_suburban (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_suburban::main( "vehicle_suburban" );

and these lines in your CSV:
include,vehicle_suburban_suburban
sound,vehicle_suburban,vehicle_standard,all_sp


defaultmdl="vehicle_suburban"
default:"vehicletype" "suburban"
default:"script_team" "allies"
*/

//

main( model, type )
{
	build_template( "suburban", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_suburban", "vehicle_suburban_destroyed" );// "suburban_destroy" when finished
	build_deathmodel( "vehicle_suburban_minigun_viewmodel", "vehicle_suburban_minigun_viewmodel" );// "suburban_destroy" when finished

	build_deathfx( "fire/firelp_med_pm", "TAG_CAB_FIRE", "fire_metal_medium", undefined, undefined, true, 0 );
	build_deathfx( "explosions/vehicle_explosion_suburban", "TAG_DEATH_FX", "explo_metal_rand" );


	build_drive( %technical_driving_idle_forward, %technical_driving_idle_backward, 10 );
	build_treadfx();
	//build_life( 100 );
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_unload_groups( ::Unload_Groups );

	build_radiusdamage( ( 0, 0, 32 ), 300, 200, 0, false );
}

init_local()
{

}

#using_animtree( "vehicles" );
set_vehicle_anims( positions )
{
/*	positions[ 0 ].vehicle_getoutanim = %uaz_driver_exit_into_run_door;
	positions[ 1 ].vehicle_getoutanim = %uaz_rear_driver_exit_into_run_door;
	positions[ 2 ].vehicle_getoutanim = %uaz_passenger_exit_into_run_door;
	positions[ 3 ].vehicle_getoutanim = %uaz_passenger2_exit_into_run_door;

	positions[ 0 ].vehicle_getinanim = %uaz_driver_enter_from_huntedrun_door;
	positions[ 1 ].vehicle_getinanim = %uaz_rear_driver_enter_from_huntedrun_door;
	positions[ 2 ].vehicle_getinanim = %uaz_passenger_enter_from_huntedrun_door;
	positions[ 3 ].vehicle_getinanim = %uaz_passenger2_enter_from_huntedrun_door;
*/
	positions[ 0 ].vehicle_getoutanim = %suburban_dismount_frontL_door;
	positions[ 1 ].vehicle_getoutanim = %suburban_dismount_frontR_door;
	positions[ 2 ].vehicle_getoutanim = %suburban_dismount_backL_door;
	positions[ 3 ].vehicle_getoutanim = %suburban_dismount_backR_door;

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
	positions[ 2 ].sittag = "tag_guy1";
	positions[ 3 ].sittag = "tag_guy2";
	positions[ 4 ].sittag = "tag_guy3";
	positions[ 5 ].sittag = "tag_guy4";

	positions[ 0 ].idle = %suburban_idle_frontL;
	positions[ 1 ].idle = %suburban_idle_frontR;
	positions[ 2 ].idle = %suburban_idle_backL;
	positions[ 3 ].idle = %suburban_idle_backR;
	positions[ 5 ].idle = %suburban_idle_backL;
	positions[ 4 ].idle = %suburban_idle_backR;

	positions[ 0 ].getout = %suburban_dismount_frontL;
	positions[ 1 ].getout = %suburban_dismount_frontR;
	positions[ 2 ].getout = %suburban_dismount_backL;
	positions[ 3 ].getout = %suburban_dismount_backR;
	positions[ 5 ].getout = %suburban_dismount_backL; // cuts through the vehicle
	positions[ 4 ].getout = %suburban_dismount_backR; // cuts through the vehicle

	// old get in anims
	positions[ 0 ].getin = %humvee_driver_climb_in;
	positions[ 1 ].getin = %humvee_passenger_in_L;
	positions[ 2 ].getin = %humvee_passenger_in_R;
	positions[ 3 ].getin = %humvee_passenger_in_R;
	positions[ 4 ].getin = %humvee_passenger_in_L;
	positions[ 5 ].getin = %humvee_passenger_in_R;

	return positions;

/*	OLD ANIMS

	positions[ 0 ].idle[ 0 ] = %humvee_driver_twitch_1;
	positions[ 0 ].idle[ 1 ] = %humvee_driver_climb_idle;
	positions[ 0 ].idleoccurrence[ 0 ] = 100;
	positions[ 0 ].idleoccurrence[ 1 ] = 1000;

	positions[ 1 ].idle[ 0 ] = %humvee_passenger_twitch_1_R;
	positions[ 1 ].idle[ 1 ] = %humvee_passenger_idle_L;
	positions[ 1 ].idleoccurrence[ 0 ] = 100;
	positions[ 1 ].idleoccurrence[ 1 ] = 1000;

	positions[ 2 ].idle = %humvee_passenger_idle_R;
	positions[ 3 ].idle = %humvee_passenger_idle_R;
	positions[ 4 ].idle = %humvee_passenger_idle_R;
	positions[ 5 ].idle = %humvee_passenger_idle_R;

	positions[ 0 ].getout = %humvee_driver_climb_out;
	positions[ 1 ].getout = %humvee_passenger_out_R;
	positions[ 2 ].getout = %humvee_passenger_out_R;
	positions[ 3 ].getout = %humvee_passenger_out_L;
	positions[ 4 ].getout = %humvee_passenger_out_L;
	positions[ 5 ].getout = %humvee_passenger_out_R;
*/
}

unload_groups()
{
	unload_groups = [];
	unload_groups[ "passengers" ] = [];
	unload_groups[ "all" ] = [];

	group = "passengers";
	unload_groups[ group ][ unload_groups[ "passengers" ].size ] = 1;
	unload_groups[ group ][ unload_groups[ "passengers" ].size ] = 2;
	unload_groups[ group ][ unload_groups[ "passengers" ].size ] = 3;
	unload_groups[ group ][ unload_groups[ "passengers" ].size ] = 4;
	unload_groups[ group ][ unload_groups[ "passengers" ].size ] = 5;

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