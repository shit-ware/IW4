#include animscripts\traverse\shared;

// step_down.gsc
// Makes the character step down off a ledge.  Currently the ledge is assumed to be 36 units.

#using_animtree( "generic_human" );


main()
{
	if ( self.type == "dog" )
		dog_jump_down( 40, 3 );
	else
		step_down_human();
}


step_down_human()
{
	// do not do code prone in this script
	self.desired_anim_pose = "crouch";
	animscripts\utility::UpdateAnimPose();

	self endon( "killanimscript" );
	self.a.movement = "walk";
	self traverseMode( "nogravity" );
//	self traverseMode("noclip"); // Testing to see if a clip brush will stop regular pathfinding and force the traverse script to be used.

	// orient to the Negotiation start node
    startnode = self getnegotiationstartnode();
    assert( isdefined( startnode ) );
    self OrientMode( "face angle", startnode.angles[ 1 ] );


	self setFlaggedAnimKnoballRestart( "stepanim", %step_down_low_wall, %body, 1, .1, 1 );
	self waittillmatch( "stepanim", "gravity on" );
	self traverseMode( "gravity" );
	self animscripts\shared::DoNoteTracks( "stepanim" );
}