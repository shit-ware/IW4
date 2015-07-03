#include animscripts\Utility;
#using_animtree( "generic_human" );

main()
{
	self endon( "killanimscript" );
	animscripts\utility::initialize( "grenadecower" );

	if ( isdefined( self.grenadeCowerFunction ) )
	{
		self [[ self.grenadeCowerFunction ]]();
		return;
	}
	
	if ( self.a.pose == "prone" )
	{
		// TODO: use an i-just-dived loop?

		animscripts\stop::main();
		return;	// Should never get to here
	}

	self AnimMode( "zonly_physics" );
	self OrientMode( "face angle", self.angles[ 1 ] );

	grenadeAngle = 0;

	if ( isdefined( self.grenade ) )// failsafe
		grenadeAngle = AngleClamp180( vectorToAngles( self.grenade.origin - self.origin )[ 1 ] - self.angles[ 1 ] );
	else
		grenadeAngle = self.angles[ 1 ];

	if ( self.a.pose == "stand" )
	{
		if ( isdefined( self.grenade ) && TryDive( grenadeAngle ) )
			return;

		self setFlaggedAnimKnobAllRestart( "cowerstart", %exposed_squat_down_grenade_F, %body, 1, 0.2 );
		self animscripts\shared::DoNoteTracks( "cowerstart" );
	}
	self.a.pose = "crouch";
	self.a.movement = "stop";

	self setFlaggedAnimKnobAllRestart( "cower", %exposed_squat_idle_grenade_F, %body, 1, 0.2 );
	self animscripts\shared::DoNoteTracks( "cower" );

	self waittill( "never" );
}

end_script()
{
	self.safeToChangeScript = true;
}

TryDive( grenadeAngle )
{
	if ( randomint( 2 ) == 0 )
		return false;
		
	if ( self.stairsState != "none" )
		return false;

	diveAnim = undefined;
	if ( abs( grenadeAngle ) > 90 )
	{
		// grenade behind us
		diveAnim = %exposed_dive_grenade_B;
	}
	else
	{
		// grenade in front of us
		diveAnim = %exposed_dive_grenade_F;
	}

	// when the dives are split into a dive, idle, and get up,
	// maybe we can get a better point to do the moveto check with
	moveBy = getMoveDelta( diveAnim, 0, 0.5 );
	diveToPos = self localToWorldCoords( moveBy );

	if ( !self MayMoveToPoint( diveToPos ) )
		return false;

	self.safeToChangeScript = false;

	self setFlaggedAnimKnobAllRestart( "cowerstart", diveAnim, %body, 1, 0.2 );
	self animscripts\shared::DoNoteTracks( "cowerstart" );

	self.safeToChangeScript = true;

	return true;
}
