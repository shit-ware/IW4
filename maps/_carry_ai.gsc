#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;

initCarry()
{
	anims();
}

#using_animtree( "generic_human" );
anims()
{
	level.scr_anim[ "generic" ][ "wounded_idle" ][ 0 ]		 	 	= %wounded_carry_closet_idle_wounded;
	
	level.scr_anim[ "generic" ][ "pickup_wounded" ]			 		= %wounded_carry_pickup_closet_wounded_straight;
	level.scr_anim[ "generic" ][ "pickup_carrier" ]		 			= %wounded_carry_pickup_closet_carrier_straight;
	
	level.scr_anim[ "generic" ][ "wounded_walk_loop" ][ 0 ]			= %wounded_carry_fastwalk_wounded_relative;
	level.scr_anim[ "generic" ][ "carrier_walk_loop" ]		 		= %wounded_carry_fastwalk_carrier;
	/*
	level.scr_anim[ "generic" ][ "wounded_walk_loop" ][ 0 ]			= %wounded_carry_sprint_wounded;
	level.scr_anim[ "generic" ][ "carrier_walk_loop" ]		 		= %wounded_carry_sprint_carrier;
	*/
	level.scr_anim[ "generic" ][ "putdown_wounded" ]		 		= %wounded_carry_putdown_closet_wounded;
	level.scr_anim[ "generic" ][ "putdown_carrier" ]		 		= %wounded_carry_putdown_closet_carrier;
}

setWounded( eNode )
{
	assert( isAI( self ) );
	assert( isAlive( self ) );
	assert( isdefined( eNode ) );
	
	self animscripts\shared::DropAIWeapon();
	
	// make the president go into his wounded idle
	self.woundedNode = eNode;
	self.woundedNode thread anim_generic_loop( self, "wounded_idle", "stop_wounded_idle" );
	self.allowdeath = true;
}

move_president_to_node( wounded, eNode )
{
	goto_and_pickup_wounded( wounded, eNode );
	carry_to_and_putdown_wounded( wounded, eNode );
}

move_president_to_node_nopickup( wounded, eNode )
{
	wounded forceTeleport( self.origin, self.angles );
	carry_to_and_putdown_wounded( wounded, eNode );
}

goto_and_pickup_wounded( wounded, eNode )
{
	//##############################
	// don't use this, internal only
	// use move_president_to_node()
	//##############################
	
	assert( isdefined( self ) );
	assert( isAI( self ) );
	assert( isAlive( self ) );
	assert( isdefined( wounded ) );
	assert( isAI( wounded ) );
	assert( isAlive( wounded ) );
	assert( isdefined( eNode ) );
	assert( isdefined( wounded.woundedNode ) );
	
	// get the carrier to the president
	wounded.woundedNode anim_generic_reach( self, "pickup_carrier" );
	
	// carrier picks up the president, they both play the pickup anim
	wounded notify( "stop_wounded_idle" );
	wounded.woundedNode notify( "stop_wounded_idle" );
	wounded.allowdeath = true;
	wounded.woundedNode thread anim_generic( wounded, "pickup_wounded" );
	wounded.woundedNode anim_generic( self, "pickup_carrier" );
	
	self.dontMelee = true;
	wounded invisibleNotSolid();
}


link_wounded( wounded )
{
	self endon( "death" );
	wounded endon( "death" );
	
	wounded linkto( self, "tag_origin" );

	// wait for carrier to get a path and start move script
	wait 0.05;
	wounded thread anim_generic_loop( wounded, "wounded_walk_loop", "stop_carried_loop" );
}


carry_to_and_putdown_wounded( wounded, eNode )
{
	//##############################
	// don't use this, internal only
	// use move_president_to_node()
	//##############################
	
	assert( isdefined( self ) );
	assert( isAI( self ) );
	assert( isAlive( self ) );
	assert( isdefined( wounded ) );
	assert( isAI( wounded ) );
	assert( isAlive( wounded ) );
	assert( isdefined( eNode ) );
	
	wounded.being_carried = true;
	
	// once the carrier arrives set his walk anim to the carry walk
	self thread set_generic_run_anim( "carrier_walk_loop", true );
	
	wounded notify( "stop_wounded_idle" );
	wounded.woundedNode notify( "stop_wounded_idle" );
	
	// president gets linked to the carrier and plays a loop anim
	
	setsaveddvar( "ai_friendlyFireBlockDuration", 0 );
	self animmode( "none" );
	self.allowpain = false;
	self.disableBulletWhizbyReaction = true;
	self.ignoreall = true;
	self.ignoreme = true;
	self.grenadeawareness = 0;
	self setFlashbangImmunity( true );
	self.neverEnableCqb = true;
	self.disablearrivals = true;
	self.disableexits = true;
	self.nododgemove = true;
	
	self disable_cqbwalk();

	self.oldgoal = self.goalradius;
	
	self thread link_wounded( wounded );
	
	while( isdefined( eNode.target ) )
	{
		self.ignoresuppression = true;
		self.disablearrivals = true;
		goal = getent( eNode.target, "targetname" );
		if( !isdefined( goal.target ) )
		{
			eNode = goal;
			break;
		}
		self.goalradius = 64;
		self setgoalpos( goal.origin );
		self waittill( "goal" );
		eNode = goal;
	}
	
	// carrier walks to the new node for putdown anim
	eNode anim_generic_reach( self, "putdown_carrier" );
	
	// carrier arrives, put down the president. They both play putdown anim
	wounded.woundedNode = eNode;
	wounded notify( "stop_carried_loop" );
	wounded unlink();
	
	self.ignoresuppression = false;
	self.disablearrivals = false;
	self.goalradius = self.oldgoal;
	
	self thread clear_run_anim();
	wounded.woundedNode thread anim_generic( self, "putdown_carrier" );
	wounded.woundedNode anim_generic( wounded, "putdown_wounded" );
	
	setsaveddvar( "ai_friendlyFireBlockDuration", 2000 );
	self.allowpain = true;
	self.disableBulletWhizbyReaction = false;
	self.ignoreall = false;
	//self.ignoreme = false;
	self.grenadeawareness = 1;
	self setFlashbangImmunity( false );
	self.dontMelee = undefined;
	self.neverEnableCqb = undefined;
	self.disablearrivals = undefined;
	self.disableexits = undefined;
	self.nododgemove = false;
	self pushplayer( false );
	
	wounded visibleSolid();

	wounded.woundedNode thread anim_generic_loop( wounded, "wounded_idle", "stop_wounded_idle" );
	wounded.allowdeath = true;
	
	wounded notify( "stop_putdown" );
	wounded.being_carried = undefined;
}
