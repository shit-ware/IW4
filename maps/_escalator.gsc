#include common_scripts\utility;

/*******************

	- prefabs/bookstore/escalator_up.map
	- prefabs/bookstore/escalator_down.map

	These two prefabs are set up to work with the script.

	TODO: Make them trigger or radius based so that they don't run all the time.
		
*******************/

init()
{
	flag_init( "_escalator_on" );
	flag_set( "_escalator_on" );
	
	level.escalator_movespeed = .5;
	array = getentarray( "escalator", "targetname" );
	array_thread( array, ::escalator_startup );
}

escalator_startup()
{
	step = self;

	while ( isdefined( step.target ) )
	{		
		step StartUsingLessFrequentLighting();
		step.true_origin = step.origin;
		step.next_step = getent( step.target, "targetname" );
		step = step.next_step;
	}
		
	step.true_origin = step.origin;
	step.last = 1;
	step.next_step = self;

	thread escalator_move( self );
}

escalator_move( first_step )
{
	step = first_step;
	first_origin = step.origin;

	while ( flag( "_escalator_on" ) )
	{
		movespeed = level.escalator_movespeed;
		next_step = step.next_step;

		step show();

		if ( next_step != first_step )
			step moveto( next_step.true_origin, movespeed );
		else
			step.origin = first_origin;

		if ( next_step == first_step )
		{
			step hide();
			step.true_origin = first_origin;
			first_step = step;
			wait movespeed;
			continue;
		}

		step.true_origin = next_step.true_origin;
		step = next_step;
	}
	
	step = first_step;
		
	while( 1 )
	{
		movespeed = 2;
		next_step = step.next_step;
	
		step show();
	
		step thread final_move( movespeed, next_step );
		
		if ( next_step == first_step )
		{
			step hide();
			step.true_origin = first_origin;
		}
		
		step.true_origin = next_step.true_origin;	
		step = next_step;
		if( step == first_step )
			return;
	}
}

final_move( movespeed, next_step )
{
	self moveto( next_step.true_origin, movespeed, 0, movespeed );
	wait movespeed;
	self moveto( self.origin, .05 );
}