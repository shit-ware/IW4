#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include animscripts\shared;


get_flashed_anim()
{
	return anim.civilianFlashedArray[ randomint( anim.civilianFlashedArray.size ) ];
}

main()
{
	flashDuration = self flashBangGetTimeLeftSec();
	if ( flashDuration <= 0 )
		return;

	animscripts\flashed::flashBangedLoop( get_flashed_anim(), flashDuration );
}