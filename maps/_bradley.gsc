#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	build_template( "bradley", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_bradley", "vehicle_bradley" );
	build_deathfx( "explosions/large_vehicle_explosion", undefined, "exp_armor_vehicle" );
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	build_mainturret();
	build_compassicon( "tank" );
	build_frontarmor( .33 );// regens this much of the damage from attacks to the front
}

init_local()
{
}

set_vehicle_anims( positions )
{
	/*
	positions[ 0 ].vehicle_getinanim = %tigertank_hatch_open;
	positions[ 1 ].vehicle_getoutanim = %tigertank_hatch_open;
	*/
	return positions;
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


/*QUAKED script_vehicle_bradley (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_bradley::main( "vehicle_bradley" );

and these lines in your CSV:
include,vehicle_bradley_bradley
sound,vehicle_bradley,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp


defaultmdl="vehicle_bradley"
default:"vehicletype" "bradley"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_bradley_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_bradley::main( "vehicle_bradley", "bradley_physics" );

and these lines in your CSV:
include,vehicle_bradley_bradley
sound,vehicle_bradley,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp

defaultmdl="vehicle_bradley"
default:"vehicletype" "bradley_physics"
default:"script_team" "allies"
*/