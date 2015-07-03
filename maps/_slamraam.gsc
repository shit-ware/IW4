#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );
main( model, type )
{
	build_template( "slamraam", model, type );
	build_localinit( ::init_local );

	build_deathmodel( "vehicle_slamraam", "vehicle_slamraam_base" );

	// nate - lets fix this up.
	precachemodel( "projectile_slamraam_missile" );

	build_deathfx( "explosions/vehicle_explosion_slamraam", undefined, "exp_slamraam_destroyed" );
//	build_life( 999, 500, 1500 );
	build_life( 50 );
	build_team( "allies" );
}

init_local()
{
	self.missileModel = "projectile_slamraam_missile";
	self.missileTags = [];
	self.missileTags[ 0 ] = "tag_missle1";
	self.missileTags[ 1 ] = "tag_missle2";
	self.missileTags[ 2 ] = "tag_missle3";
	self.missileTags[ 3 ] = "tag_missle4";
	self.missileTags[ 4 ] = "tag_missle5";
	self.missileTags[ 5 ] = "tag_missle6";
	self.missileTags[ 6 ] = "tag_missle7";
	self.missileTags[ 7 ] = "tag_missle8";
	//thread maps\_vehicle_missile::main();
}


/*QUAKED script_vehicle_slamraam (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_slamraam::main( "vehicle_slamraam" );

and these lines in your CSV:
include,vehicle_slamraam_slamraam


defaultmdl="vehicle_slamraam"
default:"vehicletype" "slamraam"
default:"script_team" "allies"
*/
