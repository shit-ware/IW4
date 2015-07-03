// Jump_across_100.gsc
// Makes the character do a lateral jump of 100 units.

#using_animtree( "generic_human" );

main()
{
 	// do not do code prone in this script
	self.desired_anim_pose = "stand";
	animscripts\utility::UpdateAnimPose();

	self endon( "killanimscript" );
	self traverseMode( "nogravity" );
	self traverseMode( "noclip" );

	// orient to the Negotiation start node
    startnode = self getnegotiationstartnode();
    assert( isdefined( startnode ) );
    self OrientMode( "face angle", startnode.angles[ 1 ] );

	jumpAnims = [];
	jumpAnims[0] = %jump_across_100_spring;
	jumpAnims[1] = %jump_across_100_lunge;
	jumpAnims[2] = %jump_across_100_stumble;
	
	jumpanim = jumpAnims[ randomint( jumpAnims.size ) ];

	self setFlaggedAnimKnoballRestart( "jumpanim", jumpanim, %body, 1, .1, 1 );
	self animscripts\shared::DoNoteTracks( "jumpanim" );
}
