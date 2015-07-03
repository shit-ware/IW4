#include animscripts\utility;
#include animscripts\Combat_utility;

#using_animtree( "generic_human" );

main()
{
	if ( isDefined( anim.ramboAnims ) )
		return;
	
	if ( !isdefined( level.subclass_spawn_functions ) )
		level.subclass_spawn_functions = [];
	level.subclass_spawn_functions[ "militia" ] = ::enable_militia_behavior;
	
	anim.ramboAnims = spawnstruct();
	
	anim.ramboAnims.coverleft90 = array( %favela_chaotic_cornerL_hop90, %favela_chaotic_cornerL_high90, %favela_chaotic_cornerL_mid90 );
	anim.ramboAnims.coverleft45 = array( %favela_chaotic_cornerL_high45, %favela_chaotic_cornerL_mid45 );
	anim.ramboAnims.coverleftgrenade = %favela_chaotic_cornerL_grenade;
	
	anim.ramboAnims.coverright90 = array( %favela_chaotic_cornerR_med90, %favela_chaotic_cornerR_low90, %favela_chaotic_cornerR_high90 );
	anim.ramboAnims.coverright45 = array( %favela_chaotic_cornerR_med45, %favela_chaotic_cornerR_low45, %favela_chaotic_cornerR_high45 );
	anim.ramboAnims.coverrightgrenade = %favela_chaotic_cornerR_grenade;
	
	anim.ramboAnims.coverstand = array( %favela_chaotic_standcover_fireA, %favela_chaotic_standcover_fireB, %favela_chaotic_standcover_fireC );
	anim.ramboAnims.coverstandfail = array( %favela_chaotic_standcover_gunjamA, %favela_chaotic_standcover_gunjamB );
	anim.ramboAnims.coverstandgrenade = array( %favela_chaotic_standcover_grenadefireA );
	
	anim.ramboAnims.covercrouch = array( %favela_chaotic_crouchcover_fireA, %favela_chaotic_crouchcover_fireB, %favela_chaotic_crouchcover_fireC );
	anim.ramboAnims.covercrouchfail = array( %favela_chaotic_crouchcover_gunjamA, %favela_chaotic_crouchcover_gunjamB );
	anim.ramboAnims.covercrouchgrenade = array( %favela_chaotic_crouchcover_grenadefireA );
	
	SetRamboGrenadeOffsets();
}

SetRamboGrenadeOffsets()
{
	addGrenadeThrowAnimOffset( %favela_chaotic_cornerr_grenade, (52.4535, 10.107, 64.2898) );
	addGrenadeThrowAnimOffset( %favela_chaotic_cornerl_grenade, (19.1753, -18.9954, 49.3355) );
	addGrenadeThrowAnimOffset( %favela_chaotic_standcover_grenadefirea, (6.66898, -0.135193, 72.117) );
	addGrenadeThrowAnimOffset( %favela_chaotic_crouchcover_grenadefirea, (4.53614, -10.4574, 59.7186) );
}


/*
=============
///ScriptDocBegin
"Name: enable_militia_behavior()"
"Summary: Enables militia behavior"
"Module: AI"
"CallOn: An AI"
"Example: guy enable_militia_behavior();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
enable_militia_behavior()
{
	if ( self.type == "dog" )
		return;
	
	self.neverEnableCQB = true;
	self.maxfaceenemydist = 256; //default 512
	
	// don't enable rambo type behaviour on long range, rpg, or shotgun types
	if ( animscripts\combat_utility::isLongRangeAI() )
		return;
	if ( isShotgun( self.weapon ) )
		return;

	self.disable_blindfire = undefined;
	self.favor_blindfire = true;
	self.ramboChance = .9;
	self.ramboAccuracyMult = 1.0;
	self.baseAccuracy = 0.75;
	self.neverSprintForVariation = undefined;
}


/*
=============
///ScriptDocBegin
"Name: disable_militia_behavior()"
"Summary: Disables militia behavior"
"Module: AI"
"CallOn: An AI"
"Example: guy disable_militia_behavior();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
disable_militia_behavior()
{
	self.favor_blindfire = undefined;
	self.ramboChance = undefined;
	self.neverEnableCQB = false;
	self.maxfaceenemydist = 512; //default 512
	self.ramboAccuracyMult = undefined;
}

