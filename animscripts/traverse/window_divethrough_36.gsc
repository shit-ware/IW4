#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	if ( self.type == "dog" )
	{
		dog_wall_and_window_hop( "window_40", 40 );
	}
	else
	{
		low_wall_human();
	}
}

low_wall_human()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			= %traverse_window_M_2_dive;
	traverseData[ "traverseStopsAtEnd" ]	= true;
	traverseData[ "traverseHeight" ]		= 36.0;

	DoTraverse( traverseData );
}
