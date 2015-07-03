#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	if ( self.type == "dog" )
		dog_jump_down( 7, 0.8 );
	else
		low_wall_human();
}

low_wall_human()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %traverse_jumpdown_96;

	DoTraverse( traverseData );
}
