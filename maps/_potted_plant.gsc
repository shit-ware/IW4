#include maps\_utility;
#include maps\_vehicle;
#include common_scripts\utility;
#include maps\_anim;

potted_plant_init()
{
	level._effect[ "plant_large_thrower" ]				= loadfx( "props/plant_large_thrower" );
	level._effect[ "plant_medium_thrower" ]				= loadfx( "props/plant_medium_thrower" );
	level._effect[ "plant_small_thrower" ]				= loadfx( "props/plant_small_thrower" );
	run_thread_on_targetname( "potted_plant", ::potted_plant );
}

potted_plant()
{
	forward = anglesToForward( self.angles );
	up = anglesToUp( self.angles );
	pos = self.origin;
	
	trig = undefined;
	if ( isdefined( self.target ) )
		trig = getent( self.target, "targetname" );
	
	self thread potted_plant_damage();
	if ( isdefined( trig ) )
		self thread potted_plant_triggered( trig );
	
	self waittill( "fall" );
	
	fx = undefined;
	switch( self.model )
	{
		case "com_potted_plant_small":
			fx = getfx( "plant_small_thrower" );
			break;
		case "com_potted_plant_medium":
			fx = getfx( "plant_medium_thrower" );
			break;
		case "com_potted_plant_large":
			fx = getfx( "plant_large_thrower" );
			break;
		default:
			assertmsg( "Unknown potted plantmodel " + self.model );
	}
	assert( isdefined( fx ) );
	
	self delete();
	playFX( fx, pos, forward, up );
}

potted_plant_damage()
{
	self endon( "fall" );
	self setCanDamage( true );
	self waittill( "damage" );
	self notify( "fall" );
}

potted_plant_triggered( trig )
{
	self endon( "fall" );
	trig waittill( "trigger" );
	wait randomfloatrange( 0.0, 0.2 );
	self notify( "fall" );
}
