#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	if ( self.type == "dog" )
		dog_jump_up( 52.0, 5 );
	else
		low_wall_human();
}

low_wall_human()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %traverse_stepup_52;
	traverseData[ "traverseHeight" ]		 = 52.0;

	DoTraverse( traverseData );
}
