#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;

#using_animtree( "generic_human" );

clear_animation( blend_time )
{
	self clearanim( %root, blend_time );
}

enemy_animation_attack( type )
{
	//->took out this assert because in rare cases, an enemy is so far away or in such complex geo
	//like af_caves that we can actually lose our enemy in the short time it takes to between getting
	//the "attack" logic and hitting this function....we can just assume, that this guy can do a long animation
	//assert( isdefined( self.enemy ) );
	
	//arbitrary number to say the enemy is far away - if we have one we'll get a real number
	//if we don't, then we can assume he's far away
	dist = 600;
	
	if( IsDefined( self.enemy ) )
		dist = distance( self.enemy.origin, self.origin );
		
	if ( dist < 512 )
		anime = "_stealth_behavior_spotted_short";
	else
		anime = "_stealth_behavior_spotted_long";
	
	self.allowdeath = true;
	self thread anim_generic_custom_animmode( self, "gravity", anime );

	if ( dist < 200 )
		wait .5;
	else
		self waittill_notify_or_timeout( anime, randomfloatrange( 1.5, 3 ) );

	self notify( "stop_animmode" );
}

enemy_animation_nothing( type )
{
	// these dont actually do anything, however their existance
	// allows for custom reaction animations to be played even
	// at this alert stage
}

enemy_animation_generic( type )
{
	self.allowdeath = true;

	target = level.player;
	if ( isdefined( self.enemy ) )
		target = self.enemy;
	else if ( isdefined( self.favoriteenemy ) )
		target = self.favoriteenemy;

	dist = ( distance( self.origin, target.origin ) );
	max = 4;
	range = 1024;

	for ( i = 1; i < max; i++ )
	{
		test = range * ( i / max );
		if ( dist < test )
			break;
	}

	anime = "_stealth_behavior_generic" + i;

	self anim_generic_custom_animmode( self, "gravity", anime );
}

dog_animation_generic( type )
{
	self.allowdeath = true;

	anime = undefined;

	// check if dog is in melee sequence with player
	if ( isdefined( self.meleeingPlayer ) )
	{
		player = self.meleeingPlayer;
		if ( isdefined( player.player_view ) && isdefined( player.player_view.dog ) && self == player.player_view.dog )
			return;
	}

	if ( self ent_flag( "_stealth_behavior_asleep" ) )
	{
		if ( randomint( 100 ) < 50 )
			anime = "_stealth_dog_wakeup_fast";
		else
			anime = "_stealth_dog_wakeup_slow";
	}
	else
		anime = "_stealth_dog_growl";

	self anim_generic_custom_animmode( self, "gravity", anime );
}

dog_animation_wakeup_fast( type )
{
	self.allowdeath = true;

	anime = undefined;

	if ( self ent_flag( "_stealth_behavior_asleep" ) )
		anime = "_stealth_dog_wakeup_fast";
	else
		anime = "_stealth_dog_growl";

	self anim_generic_custom_animmode( self, "gravity", anime );
}
dog_animation_wakeup_slow( type )
{
	self.allowdeath = true;

	anime = undefined;

	if ( self ent_flag( "_stealth_behavior_asleep" ) )
		anime = "_stealth_dog_wakeup_slow";
	else
		anime = "_stealth_dog_growl";

	self anim_generic_custom_animmode( self, "gravity", anime );
}

enemy_animation_sawcorpse( type )
{
	self.allowdeath = true;

	anime = "_stealth_behavior_saw_corpse";

	self anim_generic_custom_animmode( self, "gravity", anime );
}

dog_animation_sawcorpse( type )
{
	self.allowdeath = true;

	anime = "_stealth_dog_saw_corpse";

	self anim_generic_custom_animmode( self, "gravity", anime );
}

dog_animation_howl( type )
{
	self.allowdeath = true;

	anime = "_stealth_dog_howl";

	self anim_generic_custom_animmode( self, "gravity", anime );
	self anim_generic_custom_animmode( self, "gravity", anime );
	self anim_generic_custom_animmode( self, "gravity", anime );
	self anim_generic_custom_animmode( self, "gravity", anime );
	self anim_generic_custom_animmode( self, "gravity", anime );
	self anim_generic_custom_animmode( self, "gravity", anime );
}

enemy_animation_foundcorpse( type )
{
	self endon( "enemy" );
	
	if ( isdefined( self.enemy ) )
		return;
		
	self.allowdeath = true;

	if ( self.a.movement == "stop" )
		anime = "_stealth_find_stand";
	else
		anime = "_stealth_find_jog";

	self anim_generic_custom_animmode( self, "gravity", anime );
}

dog_animation_foundcorpse( type )
{
	self endon( "enemy" );

	if ( isdefined( self.enemy ) )
		return;

	self.allowdeath = true;

	anime = "_stealth_dog_find";

	self anim_generic_custom_animmode( self, "gravity", anime );
}