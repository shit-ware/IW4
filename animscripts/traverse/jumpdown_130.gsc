#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	if ( self.type == "dog" )
		dog_jump_down( 7, 0.7 );
	else
		jumpdown_130_human();
}

jumpdown_130_human()
{
	traverseData = [];
	traverseData[ "traverseAnim" ] = %traverse_jumpdown_130;

	DoTraverse( traverseData );
}
