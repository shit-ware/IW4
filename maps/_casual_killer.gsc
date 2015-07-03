#include maps\_utility;
#include animscripts\utility;
#include common_scripts\utility;

/*
=============
///ScriptDocBegin
"Name: enable_casual_killer( <enable_casual_killer> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
enable_casual_killer()
{
	if( isdefined( self.casual_killer ) )
		return;
	
	self disable_turnAnims();
	self disable_surprise();
	
	self.casual_killer 					= true;	
	self.no_pistol_switch  				= true;
	self.ignoresuppression 				= true;
	self.maxFaceEnemyDist  				= 0;
	self.noRunReload 					= true;
	self.ammoCheatInterval 				= 2000;
	self.disableBulletWhizbyReaction 	= true;
	self.useChokePoints 				= false;
	self.disableDoorBehavior 			= true;
	self.combatmode						= "no_cover";
	self.oldgrenadeawareness 			= self.grenadeawareness;
	self.grenadeawareness 				= 0;
	self.oldGrenadeReturnThrow 			= self.noGrenadeReturnThrow;
	self.noGrenadeReturnThrow 			= true;
	
	self.old_walkDist = self.walkDist;
	self.old_walkDistFacingMotion = self.walkDistFacingMotion;
	self.walkDist = 0;
	self.walkDistFacingMotion = 0;
	
	self init_casual_killer_animsets();
}

/*
=============
///ScriptDocBegin
"Name: disable_casual_killer( <disable_casual_killer> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
disable_casual_killer()
{	
	if( !isdefined( self.casual_killer ) )
		return;
		
	self enable_turnAnims();
		
	self.casual_killer 					= undefined;		
	self.no_pistol_switch 				= undefined;
	self.ignoresuppression 				= false;
	self.maxFaceEnemyDist 				= 512;
	self.noRunReload 					= undefined;
	self.disableBulletWhizbyReaction 	= undefined;
	self.useChokePoints 				= true;
	self.disableDoorBehavior 			= undefined;
	self.combatmode						= "cover";
	self.grenadeawareness 				= self.oldgrenadeawareness;
	self.noGrenadeReturnThrow 			= self.oldGrenadeReturnThrow;
	
	self.walkDist = self.old_walkDist;
	self.walkDistFacingMotion = self.old_walkDistFacingMotion;
		
	self animscripts\animset::clear_custom_animset();
	
	self.prevMoveMode = "none";
	
	self allowedStances( "stand", "crouch", "prone" );
	
	self animscripts\animset::set_animset_run_n_gun();
	
	self.customMoveTransition = undefined;
	self.permanentCustomMoveTransition = undefined;
	self.approachTypeFunc = undefined;
	self.approachConditionCheckFunc = undefined;
	self.disableCoverArrivalsOnly = undefined;
}

#using_animtree( "generic_human" );
init_casual_killer_animsets()
{
	// move animations
	animset = [];
	animset[ "sprint" ] = %casual_killer_jog_A;
	animset[ "straight" ] = %casual_killer_walk_F;
	
	animset[ "move_f" ] = %casual_killer_walk_F;
	animset[ "move_l" ] = %walk_left;
	animset[ "move_r" ] = %walk_right;
	animset[ "move_b" ] = %walk_backward;
	
	animset[ "crouch" ] = %crouch_fastwalk_F;
	animset[ "crouch_l" ] = %crouch_fastwalk_L;
	animset[ "crouch_r" ] = %crouch_fastwalk_R;
	animset[ "crouch_b" ] = %crouch_fastwalk_B;
	
	animset[ "stairs_up" ] = %traverse_stair_run_01;
	animset[ "stairs_down" ] = %traverse_stair_run_down;
		
	self.customMoveAnimSet[ "run" ] = animset;
	self.customMoveAnimSet[ "walk" ] = animset;
	//self.customMoveAnimSet[ "cqb" ] = animset;
	
	self.customIdleAnimSet = [];
	self.customIdleAnimSet[ "stand" ] = %casual_killer_stand_aim5;
	self.customIdleAnimSet[ "stand_add" ] = %casual_killer_stand_idle;
	
	self.a.pose = "stand";
	self allowedStances( "stand" );
	
	// combat animations
	animset = anim.animsets.defaultStand;

	animset[ "add_aim_up" ] = %casual_killer_stand_aim8;
	animset[ "add_aim_down" ] = %casual_killer_stand_aim2;
	animset[ "add_aim_left" ] = %casual_killer_stand_aim4;
	animset[ "add_aim_right" ] = %casual_killer_stand_aim6;

	animset[ "straight_level" ] = %casual_killer_stand_aim5;

	animset[ "fire" ] = %casual_killer_stand_auto;
	animset[ "single" ] = array( %casual_killer_stand_auto );

	// remove this burst, semi nonsense soon
	animset[ "burst2" ] = %casual_killer_stand_auto;
	animset[ "burst3" ] = %casual_killer_stand_auto;
	animset[ "burst4" ] = %casual_killer_stand_auto;
	animset[ "burst5" ] = %casual_killer_stand_auto;
	animset[ "burst6" ] = %casual_killer_stand_auto;
	animset[ "semi2" ] = %casual_killer_stand_auto;
	animset[ "semi3" ] = %casual_killer_stand_auto;
	animset[ "semi4" ] = %casual_killer_stand_auto;
	animset[ "semi5" ] = %casual_killer_stand_auto;

	animset[ "exposed_idle" ] = array( %casual_killer_stand_idle );
		
	self animscripts\animset::init_animset_complete_custom_stand( animset );
	self animscripts\animset::init_animset_complete_custom_crouch( animset );	
	
	self set_casual_killer_run_n_gun();
	
	animscripts\init_move_transitions::init_move_transition_arrays();
	
	//exits
	self.customMoveTransition = ::casual_killer_startMoveTransition;
	self.permanentCustomMoveTransition = true;
	
	//arrivals
	anim.coverTrans[ "casual_killer" ] = [];
	anim.coverTrans[ "casual_killer" ][ 1 ] = %casual_killer_walk_stop;
	anim.coverTrans[ "casual_killer" ][ 2 ] = %casual_killer_walk_stop;
	anim.coverTrans[ "casual_killer" ][ 3 ] = %casual_killer_walk_stop;
	anim.coverTrans[ "casual_killer" ][ 4 ] = %casual_killer_walk_stop;
	anim.coverTrans[ "casual_killer" ][ 6 ] = %casual_killer_walk_stop;
	anim.coverTrans[ "casual_killer" ][ 7 ] = %casual_killer_walk_stop;
	anim.coverTrans[ "casual_killer" ][ 8 ] = %casual_killer_walk_stop;
	anim.coverTrans[ "casual_killer" ][ 9 ] = %casual_killer_walk_stop;
	
	anim.coverTrans[ "casual_killer_sprint" ] = [];
	anim.coverTrans[ "casual_killer_sprint" ][ 1 ] = %casual_killer_jog_stop;
	anim.coverTrans[ "casual_killer_sprint" ][ 2 ] = %casual_killer_jog_stop;
	anim.coverTrans[ "casual_killer_sprint" ][ 3 ] = %casual_killer_jog_stop;
	anim.coverTrans[ "casual_killer_sprint" ][ 4 ] = %casual_killer_jog_stop;
	anim.coverTrans[ "casual_killer_sprint" ][ 6 ] = %casual_killer_jog_stop;
	anim.coverTrans[ "casual_killer_sprint" ][ 7 ] = %casual_killer_jog_stop;
	anim.coverTrans[ "casual_killer_sprint" ][ 8 ] = %casual_killer_jog_stop;
	anim.coverTrans[ "casual_killer_sprint" ][ 9 ] = %casual_killer_jog_stop;
	
	casual_killerTransTypes = [];
	casual_killerTransTypes[0] = "casual_killer";
	casual_killerTransTypes[1] = "casual_killer_sprint";
	
	for ( j = 0; j < casual_killerTransTypes.size; j++ )
	{
		trans = casual_killerTransTypes[ j ];

		for ( i = 1; i <= 9; i++ )
		{
			if ( i == 5 )
				continue;
				
			if ( isdefined( anim.coverTrans[ trans ][ i ] ) )
			{
				anim.coverTransDist  [ trans ][ i ] = getMoveDelta( anim.coverTrans[ trans ][ i ], 0, 1 );
			}
		}
	}	
	
	anim.coverTransAngles[ "casual_killer" ][ 1 ] = 45;
	anim.coverTransAngles[ "casual_killer" ][ 2 ] = 0;
	anim.coverTransAngles[ "casual_killer" ][ 3 ] = -45;
	anim.coverTransAngles[ "casual_killer" ][ 4 ] = 90;
	anim.coverTransAngles[ "casual_killer" ][ 6 ] = -90;	
	anim.coverTransAngles[ "casual_killer" ][ 8 ] = 180;
	
	anim.coverTransAngles[ "casual_killer_sprint" ][ 1 ] = 45;
	anim.coverTransAngles[ "casual_killer_sprint" ][ 2 ] = 0;
	anim.coverTransAngles[ "casual_killer_sprint" ][ 3 ] = -45;
	anim.coverTransAngles[ "casual_killer_sprint" ][ 4 ] = 90;
	anim.coverTransAngles[ "casual_killer_sprint" ][ 6 ] = -90;	
	anim.coverTransAngles[ "casual_killer_sprint" ][ 8 ] = 180;
	
	anim.arrivalEndStance[ "casual_killer" ] = "stand";
	anim.arrivalEndStance[ "casual_killer_sprint" ] = "stand";
	
	self.approachTypeFunc = ::casual_killer_approach_type;
	self.approachConditionCheckFunc = ::casual_killer_approach_conditions;
	self.disableCoverArrivalsOnly = true;
}

casual_killer_approach_conditions( node )
{
	return true;
}

casual_killer_approach_type()
{
	if( self casual_killer_is_jogging() )
		return "casual_killer_sprint";
	
	return "casual_killer";
}

casual_killer_startMoveTransition()
{
	if ( isdefined( self.disableExits ) )
		return;
		
	self orientmode( "face angle", self.angles[1] );
	self animmode( "zonly_physics", false );

	rate = randomfloatrange( 0.9, 1.1 );
	

	if( self casual_killer_is_jogging() )
		startAnim = %casual_killer_jog_start;
	else
		startAnim = %casual_killer_walk_start;
	
	self setFlaggedAnimKnobAllRestart( "startmove", startAnim, %body, 1, .1, rate );
	self animscripts\shared::DoNoteTracks( "startmove" );

	self OrientMode( "face default" );
	self animmode( "none", false );
	
	if ( animHasNotetrack( startAnim, "code_move" ) )
		self animscripts\shared::DoNoteTracks( "startmove" );	// return on code_move
}

casual_killer_is_jogging()
{
	if( !isdefined( self.run_overrideanim ) )
		return false;
	
	if( isarray( self.run_overrideanim ) ) 
	{
		if( self.run_overrideanim[0] == %casual_killer_jog_A || self.run_overrideanim[0] == %casual_killer_jog_B )
			return true;
		else
			return false;
	}
	
	if( self.run_overrideanim == %casual_killer_jog_A || self.run_overrideanim == %casual_killer_jog_B )
		return true;
	
	return false;	
}

set_casual_killer_run_n_gun( type )
{
	self.maxRunNGunAngle = 90;
	self.runNGunTransitionPoint = 1;
	self.runNGunIncrement = 0.2;
	
	if( !isdefined( type ) )
		type = "straight";
		
	self clearanim( %run_n_gun, 0.2 );
	
	switch( type )
	{
		case "straight":	
			self.runNGunAnims[ "F" ] = %casual_killer_walk_shoot_F;
			self.runNGunAnims[ "L" ] = %casual_killer_walk_shoot_L;
			self.runNGunAnims[ "R" ] = %casual_killer_walk_shoot_R;
			self.runNGunAnims[ "LB" ] = %casual_killer_walk_shoot_L;
			self.runNGunAnims[ "RB" ] = %casual_killer_walk_shoot_R;
			break;
			
		case "down":
			self.runNGunAnims[ "F" ] = %casual_killer_walk_shoot_F_aimdown;
			self.runNGunAnims[ "L" ] = %casual_killer_walk_shoot_L_aimdown;
			self.runNGunAnims[ "R" ] = %casual_killer_walk_shoot_R_aimdown;
			self.runNGunAnims[ "LB" ] = %casual_killer_walk_shoot_L_aimdown;
			self.runNGunAnims[ "RB" ] = %casual_killer_walk_shoot_R_aimdown;
			break;	
	}
}		