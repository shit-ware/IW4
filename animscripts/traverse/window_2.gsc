#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	if ( self.type == "dog" )
		dog_wall_and_window_hop( "wallhop", 40 );
	else
		self advancedWindowTraverse( %windowclimb, 35 );
}

advancedWindowTraverse( traverseAnim, normalHeight )
{
	// do not do code prone in this script
	self.desired_anim_pose = "crouch";
	animscripts\utility::UpdateAnimPose();

	self endon( "killanimscript" );
	self traverseMode( "nogravity" );
	self traverseMode( "noclip" );// So he doesn't get stuck if the wall is a little too high

	// orient to the Negotiation start node
	startnode = self getnegotiationstartnode();
	assert( isdefined( startnode ) );
	self OrientMode( "face angle", startnode.angles[ 1 ] );
	realHeight = startnode.traverse_height - startnode.origin[ 2 ];

	self setFlaggedAnimKnoballRestart( "traverse", traverseAnim, %body, 1, 0.15, 1 );

//	self waittillmatch("traverse", "gravity on");

	// keeps the actor from sinking in to the ground or from levitating to some extent.
	wait 0.7;
	self thread teleportThread( realHeight - normalHeight );
	wait 0.9;
//	wait 1.6;

	self traverseMode( "gravity" );

	self animscripts\shared::DoNoteTracks( "traverse" );

}
