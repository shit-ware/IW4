#include maps\_vehicle_aianim;
#include maps\_vehicle;
#include maps\_utility;
#include common_scripts\utility;
#using_animtree( "vehicles" );
main( model, type, no_destroyed )
{
	build_template( "stryker", model, type );
	build_localinit( ::init_local );
	
	if ( !isdefined( no_destroyed ) )
	{
		// dont blow up in roadkill
		build_deathmodel( "vehicle_stryker", "vehicle_stryker_destroyed" );
		build_deathfx( "explosions/large_vehicle_explosion", undefined, "exp_armor_vehicle" );
	}
	
	build_drive( %stryker_movement, %stryker_movement_backwards, 10 );
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	build_mainturret();
	build_compassicon( "tank" );
	build_frontarmor( .33 );// regens this much of the damage from attacks to the front
	
	
	level._effect[ "stryker_shell" ] = loadfx( "shellejects/stryker_shell" );
}

init_local()
{
	thread additional_firing_anims();
}

additional_firing_anims()
{
	self endon( "death" );
		
	anims = [];
	anims[ "fire" ] = %stryker_cannon_fire;
	anims[ "hatch" ] = %stryker_shell_hatch;
	
	fx = getfx( "stryker_shell" );
	
	for ( ;; )
	{
		self waittill( "weapon_fired" );// waits for Code notify when FireWeapon() is called.
		foreach ( animation in anims )
		{
			self SetAnimRestart( animation, 1, 0, 1 );
		}
		
		PlayFXOnTag( fx, self, "tag_ammo_fx" );
	}
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


/*QUAKED script_vehicle_stryker (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_stryker::main( "vehicle_stryker" );

and these lines in your CSV:
include,vehicle_stryker
sound,vehicle_stryker,vehicle_standard,all_sp


defaultmdl="vehicle_stryker"
default:"vehicletype" "stryker"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_stryker_nophysics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_stryker::main( "vehicle_stryker", "stryker_nophysics" );

and these lines in your CSV:
include,vehicle_stryker
sound,vehicle_stryker,vehicle_standard,all_sp


defaultmdl="vehicle_stryker"
default:"vehicletype" "stryker_nophysics"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_stryker_desert_nophysics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_stryker::main( "vehicle_stryker_desert", "stryker_nophysics" );

and these lines in your CSV:
include,vehicle_stryker_desert
sound,vehicle_stryker,vehicle_standard,all_sp


defaultmdl="vehicle_stryker_desert"
default:"vehicletype" "stryker_nophysics"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_stryker_desert_nophysics_nodestroyed (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_stryker::main( "vehicle_stryker_desert", "stryker_nophysics", "no_destroyed" );

and these lines in your CSV:
include,vehicle_stryker_desert_nodestroyed
sound,vehicle_stryker,vehicle_standard,all_sp


defaultmdl="vehicle_stryker_desert"
default:"vehicletype" "stryker_nophysics"
default:"script_team" "allies"
*/


/*QUAKED script_vehicle_stryker_desert (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_stryker::main( "vehicle_stryker_desert" );

and these lines in your CSV:
include,vehicle_stryker_desert
sound,vehicle_stryker,vehicle_standard,all_sp


defaultmdl="vehicle_stryker_desert"
default:"vehicletype" "stryker"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_stryker_desert_nodestroyed (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_stryker::main( "vehicle_stryker_desert", undefined, "no_destroyed" );

and these lines in your CSV:
include,vehicle_stryker_desert_nodestroyed
sound,vehicle_stryker,vehicle_standard,all_sp


defaultmdl="vehicle_stryker_desert"
default:"vehicletype" "stryker"
default:"script_team" "allies"
*/
