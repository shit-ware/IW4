#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	build_template( "stryker50cal", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_stryker_config2", "vehicle_stryker_config2_destroyed" );
	build_deathfx( "explosions/large_vehicle_explosion", undefined, "exp_armor_vehicle" );
	build_drive( %stryker_movement, %stryker_movement_backwards, 10 );
	
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	build_mainturret();
	build_compassicon( "tank" );
	build_frontarmor( .33 );// regens this much of the damage from attacks to the front
	build_rumble( "stryker_rumble", 0.15, 4.5, 900, 1, 1 );
}

init_local()
{
	
}

#using_animtree( "generic_human" );
setanims()
{
	positions = [];
	for ( i = 0;i < 11;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].getout_delete = true;
	return positions;
}

/*QUAKED script_vehicle_stryker50cal (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_stryker50cal::main( "vehicle_stryker_config2" );

and these lines in your CSV:
include,vehicle_stryker50cal
sound,vehicle_stryker,vehicle_standard,all_sp


defaultmdl="vehicle_stryker_config2"
default:"vehicletype" "stryker50cal"
default:"script_team" "allies"
*/