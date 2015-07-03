#include animscripts\Combat_utility;
#include animscripts\Utility;
#include common_scripts\Utility;
#using_animtree( "generic_human" );

main()
{
//	assert( !usingSidearm() );
	self endon( "killanimscript" );

//	[[ self.exception[ "cover_stand" ] ]]();

    animscripts\utility::initialize( "cover_stand" );

	self animscripts\cover_wall::cover_wall_think( "stand" );
}


end_script()
{
	animscripts\cover_behavior::end_script( "stand" );
}
