#include animscripts\Utility;

#using_animtree( "generic_human" );

main()
{
	animscripts\move::main();
}


civilian_nonCombatMoveTurn( angleDiff )
{
	assert( isdefined( level.scr_anim[ self.animname ][ "turn_left_90" ] ) );
	assert( isdefined( level.scr_anim[ self.animname ][ "turn_right_90" ] ) );

	turnAnim = undefined;

	if ( angleDiff < -60 && angleDiff > -120 )
		turnAnim = level.scr_anim[ self.animname ][ "turn_left_90" ];
		
	if ( angleDiff > 60 && angleDiff < 120 )
		turnAnim = level.scr_anim[ self.animname ][ "turn_right_90" ];
		
	if ( isdefined( turnAnim ) && animscripts\move::pathChange_canDoTurnAnim( turnAnim ) )
		return turnAnim;
	else
		return undefined;
}


civilian_combatMoveTurn( angleDiff )
{
	turnAnim = undefined;

	if ( angleDiff < -22.5 )
	{
		if ( angleDiff > -45 )
			turnAnim = %civilian_run_upright_turnL45;
		else if ( angleDiff > -112.5 )
			turnAnim = %civilian_run_upright_turnL90;
		else if ( angleDiff > -157.5 )
			turnAnim = %civilian_run_upright_turnL135;
		else
			turnAnim = %civilian_run_upright_turn180;
	}
	else if ( angleDiff > 22.5 )
	{
		if ( angleDiff < 45 )
			turnAnim = %civilian_run_upright_turnR45;
		else if ( angleDiff < 112.5 )
			turnAnim = %civilian_run_upright_turnR90;
		else if ( angleDiff < 157.5 )
			turnAnim = %civilian_run_upright_turnR135;
		else
			turnAnim = %civilian_run_upright_turn180;
	}

	if ( isdefined( turnAnim ) && animscripts\move::pathChange_canDoTurnAnim( turnAnim ) )
		return turnAnim;
	else
		return undefined;
}


civilian_combatHunchedMoveTurn( angleDiff )
{
	turnAnim = undefined;
	largeTurnAnim = undefined;

	if ( angleDiff < -22.5 )
	{
		if ( angleDiff > -45 )
			turnAnim = %civilian_run_hunched_turnL45;
		else if ( angleDiff > -112.5 )
		{
			turnAnim = %civilian_run_hunched_turnL90;
			largeTurnAnim = randomAnimOfTwo( %civilian_run_hunched_turnL90_slide, %civilian_run_hunched_turnL90_stumble );
		}
		else if ( angleDiff > -157.5 )
			turnAnim = %civilian_run_upright_turnL135;
		else
			turnAnim = %civilian_run_upright_turn180;
	}
	else if ( angleDiff > 22.5 )
	{
		if ( angleDiff < 45 )
			turnAnim = %civilian_run_hunched_turnR45;
		else if ( angleDiff < 112.5 )
		{
			turnAnim = %civilian_run_hunched_turnR90;
			largeTurnAnim = randomAnimOfTwo( %civilian_run_hunched_turnR90_slide, %civilian_run_hunched_turnR90_stumble );
		}
		else if ( angleDiff < 157.5 )
			turnAnim = %civilian_run_upright_turnR135;
		else
			turnAnim = %civilian_run_upright_turn180;
	}

	if ( isdefined( largeTurnAnim ) && ( randomint( 3 ) < 2 ) && animscripts\move::pathChange_canDoTurnAnim( largeTurnAnim ) )
		return largeTurnAnim;

	if ( isdefined( turnAnim ) && animscripts\move::pathChange_canDoTurnAnim( turnAnim ) )
		return turnAnim;
	else
		return undefined;
}