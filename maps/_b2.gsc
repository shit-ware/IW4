#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	build_template( "b2", model, type );
	build_localinit( ::init_local );

	build_deathmodel( "vehicle_b2_bomber" );
	
	build_treadfx();
	
	//special for mig29/////
	level._effect[ "engineeffect" ]				= loadfx( "fire/jet_afterburner" );
	level._effect[ "afterburner" ]				= loadfx( "fire/jet_afterburner_ignite" );
	level._effect[ "contrail" ]					= loadfx( "smoke/jet_contrail" );
	////////////////////////

	build_deathfx( "explosions/large_vehicle_explosion", undefined, "explo_metal_rand" );
	build_life( 999, 500, 1500 );
	build_rumble( "mig_rumble", .1, .2, 11300, .05, .05 );
	build_team( "allies" );
	build_compassicon( "mig29", false );
}


init_local()
{
	thread playEngineEffects();
	thread playConTrail();
}



#using_animtree( "vehicles" );
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

	return positions;
}

playEngineEffects()
{
	self endon( "death" );
	self endon( "stop_engineeffects" );

	self ent_flag_init( "engineeffects" );
	self ent_flag_set( "engineeffects" );
	engineeffects = getfx( "engineeffect" );

	for ( ;; )
	{
		self ent_flag_wait( "engineeffects" );
		playfxontag( engineeffects, self, "tag_engine_right" );
		playfxontag( engineeffects, self, "tag_engine_left" );
		self ent_flag_waitopen( "engineeffects" );
		StopFXOnTag( engineeffects, self, "tag_engine_left" );
		StopFXOnTag( engineeffects, self, "tag_engine_right" );
	}
}

playAfterBurner()
{
	//After Burners are pretty much like turbo boost. They don't use them all the time except when 
	//bursts of speed are needed. Needs a cool sound when they're triggered. Currently, they are set
	//to be on all the time, but it would be cool to see them engauge as they fly away.

	playfxontag( level._effect[ "afterburner" ], self, "tag_engine_right" );
	playfxontag( level._effect[ "afterburner" ], self, "tag_engine_left" );

}

playConTrail()
{
	//This is a geoTrail effect that loops forever. It has to be enabled and disabled while playing as 
	//one effect. It can't be played in a wait loop like other effects because a geo trail is one 
	//continuous effect. ConTrails should only be played during high "G" or high speed maneuvers.
	playfxontag( level._effect[ "contrail" ], self, "tag_right_wingtip" );
	playfxontag( level._effect[ "contrail" ], self, "tag_left_wingtip" );
}



/*QUAKED script_vehicle_b2 (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\_b2::main( "vehicle_b2_bomber" );

and these lines in your CSV:
include,vehicle_b2
sound,vehicle_b2,vehicle_standard,all_sp


defaultmdl="vehicle_b2_bomber"
default:"vehicletype" "b2"
default:"script_team" "allies"
*/