#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_credits;
#include maps\_hud_util;

main()
{
	maps\_load::main();
	thread initcredits();

	credits();
}

credits()
{
	level.player TakeAllWeapons();
	level.player DisableWeapons();
	level.player FreezeControls( true );
	SetSavedDvar( "hud_showstance", 0 );
	SetSavedDvar( "compass", 0 );
	black = create_client_overlay( "black", 1 );
	setsaveddvar( "ui_hidemap", 1 );
	musicplay( "af_chase_ending_credits" );
	playCredits();
	wait 18;
	nextmission();
}