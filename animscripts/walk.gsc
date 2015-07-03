#include animscripts\SetPoseMovement;
#include animscripts\Utility;
#include common_scripts\utility;
#using_animtree( "generic_human" );

MoveWalk()
{
	// Decide what pose to use
	preferredPose = undefined;
	if ( isdefined( self.pathGoalPos ) && distanceSquared( self.origin, self.pathGoalPos ) > 64 * 64 )
		preferredPose = "stand";
		
	desiredPose = [[ self.choosePoseFunc ]]( preferredPose );

	switch( desiredPose )
	{
	case "stand":
		if ( BeginStandWalk() )
			return;

		if ( isdefined( self.walk_overrideanim ) )
		{
			animscripts\move::MoveStandMoveOverride( self.walk_overrideanim, self.walk_override_weights );
			return;
		}

		DoWalkAnim( GetWalkAnim( "straight" ) );
		break;

	case "crouch":
		if ( BeginCrouchWalk() )
			return;

		DoWalkAnim( GetWalkAnim( "crouch" ) );
		break;

	default:
		assert( desiredPose == "prone" );
		if ( BeginProneWalk() )
			return;

		self.a.movement = "walk";
		DoWalkAnim( GetWalkAnim( "prone" ) );
		break;
	}
}

DoWalkAnimOverride( walkAnim )
{
	self endon( "movemode" );
	self clearanim( %combatrun, 0.6 );
	self setanimknoball( %combatrun, %body, 1, 0.5, self.moveplaybackrate );

	if ( isarray( self.walk_overrideanim ) )
	{
		if ( isdefined( self.walk_override_weights ) )
			moveAnim = choose_from_weighted_array( self.walk_overrideanim, self.walk_override_weights );	
		else
			moveAnim = self.walk_overrideanim[ randomint( self.walk_overrideanim.size ) ];
	}
	else
	{
		moveAnim = self.walk_overrideanim;
	}

	self setflaggedanimknob( "moveanim", moveAnim, 1, 0.2 );
	animscripts\shared::DoNoteTracks( "moveanim" );
}

GetWalkAnim( desiredAnim )
{
	if ( self.stairsState == "up" )
		return moveAnim( "stairs_up" );
	else if ( self.stairsState == "down" )
		return moveAnim( "stairs_down" );

	walkAnim = moveAnim( desiredAnim );

	if ( isarray( walkAnim ) )
		walkAnim = walkAnim[ randomint( walkAnim.size ) ];
		
	return walkAnim;	
}

DoWalkAnim( walkAnim )
{
	self endon( "movemode" );
	
	rate = self.moveplaybackrate;
	
	if ( self.stairsState != "none" )
		rate *= 0.6;

	if ( self.a.pose == "stand" )
	{
		if ( isdefined( self.enemy ) )
		{
			self thread animscripts\cqb::CQBTracking();
			// (we don't use %body because that would reset the aiming knobs)
			self setFlaggedAnimKnobAll( "walkanim", animscripts\cqb::DetermineCQBAnim(), %walk_and_run_loops, 1, 1, rate, true );
		}
		else
		{
			self setFlaggedAnimKnobAll( "walkanim", walkAnim, %body, 1, 1, rate, true );
		}

		self animscripts\run::SetMoveNonForwardAnims( moveAnim( "move_b" ), moveAnim( "move_l" ), moveAnim( "move_r" ) );
		self thread animscripts\run::SetCombatStandMoveAnimWeights( "walk" );
	}
	else
	{
		self setFlaggedAnimKnobAll( "walkanim", walkAnim, %body, 1, 1, rate, true );

		self animscripts\run::SetMoveNonForwardAnims( moveAnim( "move_b" ), moveAnim( "move_l" ), moveAnim( "move_r" ) );
		self thread animscripts\run::SetCombatStandMoveAnimWeights( "walk" );
	}

	self animscripts\shared::DoNoteTracksForTime( 0.2, "walkanim" );

	self thread animscripts\run::stopShootWhileMovingThreads();
}

