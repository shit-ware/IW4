#include animscripts\Utility;
#include animscripts\SetPoseMovement;
#include animscripts\Combat_utility;
#include maps\_anim;
#include maps\_utility;
#using_animtree( "generic_human" );


initFlashed()
{
	anim.flashAnimArray[ 0 ] = %exposed_flashbang_v1;
	anim.flashAnimArray[ 1 ] = %exposed_flashbang_v2;
	anim.flashAnimArray[ 2 ] = %exposed_flashbang_v3;
	anim.flashAnimArray[ 3 ] = %exposed_flashbang_v4;
	anim.flashAnimArray[ 4 ] = %exposed_flashbang_v5;

	randomizeFlashAnimArray();

	anim.flashAnimIndex = 0;
}

randomizeFlashAnimArray()
{
	for ( i = 0; i < anim.flashAnimArray.size; i++ )
	{
		switchwith = randomint( anim.flashAnimArray.size );
		temp = anim.flashAnimArray[ i ];
		anim.flashAnimArray[ i ] = anim.flashAnimArray[ switchwith ];
		anim.flashAnimArray[ switchwith ] = temp;
	}
}

getNextFlashAnim()
{
	anim.flashAnimIndex++;
	if ( anim.flashAnimIndex >= anim.flashAnimArray.size )
	{
		anim.flashAnimIndex = 0;
		randomizeFlashAnimArray();
	}
	return anim.flashAnimArray[ anim.flashAnimIndex ];
}

flashBangAnim( animation )
{
	self endon( "killanimscript" );
	self setflaggedanimknoball( "flashed_anim", animation, %body, 0.2, randomFloatRange( 0.9, 1.1 ) );
	self animscripts\shared::DoNoteTracks( "flashed_anim" );
}

main()
{
	self endon( "death" );
	self endon( "killanimscript" );
	
	animscripts\utility::initialize( "flashed" );
	
	flashDuration = self flashBangGetTimeLeftSec();
	if ( flashDuration <= 0 )
		return;

	self animscripts\face::SayGenericDialogue( "flashbang" );

	if ( isdefined( self.specialFlashedFunc ) )
	{
		self [[ self.specialFlashedFunc ]]();
		return;
	}

	animation = getNextFlashAnim();
	flashBangedLoop( animation, flashDuration );
}

flashBangedLoop( animation, duration )
{
	self endon( "death" );
	self endon( "killanimscript" );
	
	assert( isDefined( animation ) );
	assert( isDefined( duration ) );
	assert( duration > 0 );

	if ( self.a.pose == "prone" )
		self ExitProneWrapper( 1 );

	self.a.pose = "stand";
	self.allowdeath = true;

	self thread flashBangAnim( animation );
	wait ( duration );

	self notify( "stop_flashbang_effect" );
	self.flashed = false;
}