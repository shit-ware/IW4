#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	build_template( "gauntlet", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_sa15_gauntlet", "vehicle_sa15_gauntlet_destroy" );
	build_deathfx( "explosions/large_vehicle_explosion", undefined, "exp_armor_vehicle" );
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_team( "axis" );
	build_idle( %sa15_turret_scanloop );
	build_idle( %sa15_radar_spinloop );
	//build_mainturret();
	//build_compassicon( "tank" );
	//build_frontarmor( .33 );// regens this much of the damage from attacks to the front
	
	//like BTR80 it is destroyed by rockets & semtex but not frags or bullets
	build_bulletshield( true );
	build_grenadeshield( true );
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


/*QUAKED script_vehicle_gauntlet (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_gauntlet::main( "vehicle_sa15_gauntlet" );

and these lines in your CSV:
include,vehicle_gauntlet_gauntlet
sound,vehicle_gauntlet,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp


defaultmdl="vehicle_sa15_gauntlet"
default:"vehicletype" "gauntlet"
default:"script_team" "axis"
*/