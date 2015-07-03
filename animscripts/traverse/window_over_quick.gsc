#include animscripts\traverse\shared;
#include animscripts\utility;
#include maps\_utility;
#using_animtree( "generic_human" );


main()
{
	if ( self.type == "dog" )
		dog_wall_and_window_hop( "window_40", 40 );
	else
		jump_through_window_human();
}

jump_through_window_human()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %traverse_window_quick;
	traverseData[ "coverType" ]				 = "Cover Crouch";
	traverseData[ "traverseHeight" ]		 = 36.0;
	traverseData[ "interruptDeathAnim" ][ 0 ]	 = array( %traverse_window_death_start );
	traverseData[ "interruptDeathAnim" ][ 1 ]	 = array( %traverse_window_death_end );

	DoTraverse( traverseData );
}
