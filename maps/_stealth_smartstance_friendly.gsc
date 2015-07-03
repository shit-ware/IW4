#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include maps\_stealth_utility;
#include maps\_stealth_shared_utilities;

stealth_smartstance_friendly_main()
{
	self friendly_init();

	self thread friendly_stance_handler();
}

/************************************************************************************************************/
/*												FRIENDLY LOGIC												*/
/************************************************************************************************************/
friendly_stance_handler()
{
	self endon( "death" );
	self endon( "pain_death" );

	self.old_fixednode = self.fixednode;
	self.old_fixednodesaferadius = self.fixednodesaferadius;
	
	while ( 1 )
	{		
		self ent_flag_wait( "_stealth_stance_handler" );
		flag_waitopen( "_stealth_spotted" );
		
		self.fixednode = 1;
		self.fixednodesaferadius = 10;
		
		while ( self ent_flag( "_stealth_stance_handler" ) && !flag( "_stealth_spotted" ) )
		{			
			self friendly_stance_handler_set_stance_up();
			stances = [];
			stances = friendly_stance_handler_check_mightbeseen( stances );

			// this means we're currently visible we need to drop a stance or stay still
			if ( stances[ self._stealth.logic.stance ] )
				self thread friendly_stance_handler_change_stance_down();
			// ok coast is clear - we can go again if we were staying still
			else if ( self ent_flag( "_stealth_stay_still" ) )
				self thread friendly_stance_handler_resume_path();
			// this means we can actually go one stance up
			else if ( ! stances[ self._stealth.behavior.stance_up ] && self._stealth.behavior.stance_up != self._stealth.logic.stance )
				self thread friendly_stance_handler_change_stance_up();
			// so - we're not stancing up, we're not stancing down, or staying still...lets notify
			// ourselves that we should stay in the same stance( just in case we're about to stance up )
			else if ( self ent_flag( "_stealth_stance_change" ) )
				self notify( "_stealth_stance_dont_change" );

			wait .05;
		}

		self.fixednode = self.old_fixednode;
		self.fixednodesaferadius = self.old_fixednodesaferadius;
		
		self.moveplaybackrate = 1;
		self allowedstances( "stand", "crouch", "prone" );

		if ( self ent_flag( "_stealth_stay_still" ) )
			self thread friendly_stance_handler_resume_path( 0 );
	}
}

friendly_stance_handler_set_stance_up()
{
	// figure out what the next stance up is
	switch( self._stealth.logic.stance )
	{
		case "prone":
			self._stealth.behavior.stance_up = "crouch";
			break;
		case "crouch":
			self._stealth.behavior.stance_up = "stand";
			break;
		case "stand":
			self._stealth.behavior.stance_up = "stand";// can't leave it as undefined
			break;
	}
}

friendly_stance_handler_check_mightbeseen( stances )
{
	// not using species because we dont care about dogs...
	// when they're awake - we're already not in stealth mode anymore
	ai = getaispeciesarray( "bad_guys", "all" );

	stances[ self._stealth.logic.stance ] 		 = 0;
	stances[ self._stealth.behavior.stance_up ] = 0;

	foreach ( key, actor in ai )
	{
		//can the ai even see us?
//		if( !( actor cansee( self ) ) )
//			continue;

		// this is how much to add based on a fast sight trace
		dist_add_curr = self friendly_stance_handler_return_ai_sight( actor, self._stealth.logic.stance );
		dist_add_up = self friendly_stance_handler_return_ai_sight( actor, self._stealth.behavior.stance_up );

		// this is the score for both the current stance and the next one up
		score_current 	 = ( self maps\_stealth_visibility_friendly::friendly_compute_score() ) + dist_add_curr;
		score_up		 = ( self maps\_stealth_visibility_friendly::friendly_compute_score( self._stealth.behavior.stance_up ) ) + dist_add_up;

		dist = distance( actor.origin, self.origin );

		if ( dist < score_current )
		{
			stances[ self._stealth.logic.stance ] = score_current;
			break;
		}

		if ( dist < score_up )
			stances[ self._stealth.behavior.stance_up ] = score_up;
	}

//	if( ai.size > 0 )
//	{
//		println("score_current " + stances[ self._stealth.logic.stance ] );
//		println("score_up " + stances[ self._stealth.behavior.stance_up ] );
//		guy = getclosest( self.origin, ai );
//		println("dist " + distance( guy.origin, self.origin ) );
//	}

	return stances;
}

friendly_stance_handler_return_ai_sight( ai, stance )
{
	// check to see where the ai is facing
	vec1 = anglestoforward( ai.angles );// this is the direction the ai is facing
	vec2 = vectornormalize( self.origin - ai.origin );// this is the direction from him to us

	// comparing the dotproduct of the 2 will tell us if he's facing us and how much so..
	// 0 will mean his direction is exactly perpendicular to us, 
	// 1 will mean he's facing directly at us
	// - 1 will mean he's facing directly away from us 
	vecdot = vectordot( vec1, vec2 );

	// is the ai facing us?
	if ( vecdot > .3 )
		return self._stealth.behavior.stance_handler[ "looking_towards" ][ stance ];
	// is the ai facing away from us
	else if ( vecdot < - .7 )
		return self._stealth.behavior.stance_handler[ "looking_away" ][ stance ];
	// the ai is kinda not facing us or away
	else
		return self._stealth.behavior.stance_handler[ "neutral" ][ stance ];
}

friendly_stance_handler_change_stance_down()
{
	self.moveplaybackrate = 1;

	self notify( "_stealth_stance_down" );

	switch( self._stealth.logic.stance )
	{
		case "stand":
			self.moveplaybackrate = .7;
			self allowedstances( "crouch" );
			break;
		case "crouch":
			if( self._stealth.behavior.no_prone )
				friendly_stance_handler_stay_still();
			else		
				self allowedstances( "prone" );
			break;
		case "prone":
			friendly_stance_handler_stay_still();
			break;
	}
}

friendly_stance_handler_change_stance_up()
{
	self endon( "_stealth_stance_down" );
	self endon( "_stealth_stance_dont_change" );
	self endon( "_stealth_stance_handler" );

	if ( self ent_flag( "_stealth_stance_change" ) )
		return;

	time = 4;

	// we wait a sec before deciding to actually stand up - just like a real player
	self ent_flag_set( "_stealth_stance_change" );
	self add_wait( ::_wait, time );
	self add_wait( ::waittill_msg, "_stealth_stance_down" );
	self add_wait( ::waittill_msg, "_stealth_stance_dont_change" );
	self add_wait( ::waittill_msg, "_stealth_stance_handler" );
	self add_func( ::ent_flag_clear, "_stealth_stance_change" );
	thread do_wait_any();

	wait time;

	self.moveplaybackrate = 1;

	switch( self._stealth.logic.stance )
	{
		case "prone":
			self allowedstances( "crouch" );
			break;
		case "crouch":
			self allowedstances( "stand" );
			break;
		case "stand":
			break;
	}
}

friendly_stance_handler_stay_still()
{
	self notify( "friendly_stance_handler_stay_still" );
	
	if ( self ent_flag( "_stealth_stay_still" ) )
		return;
	self ent_flag_set( "_stealth_stay_still" );

	badplace_cylinder( "_stealth_" + self.unique_id + "_prone", 0, self.origin, 30, 90, "bad_guys" );

	//we're going to use fixed node to make him stay still	
	self.fixednodesaferadius = 5000; //arbitrarily large number - maybe in the future we should actually set this to be a little larger than his current smart stance safe distance
}

friendly_stance_handler_resume_path( time )
{
	self endon( "friendly_stance_handler_stay_still" );
	
	if( !isdefined( time ) )
		time = self._stealth.behavior.wait_resume_path;
	
	wait( time );
	
	if( !self ent_flag( "_stealth_stay_still" ) )
		return;
	self ent_flag_clear( "_stealth_stay_still" );
	
	badplace_delete( "_stealth_" + self.unique_id + "_prone" );
		
	self.fixednodesaferadius = 10;
}

/*
friendly_stance_handler_stay_still()
{
	//need this in here because we could start resuming the path before we actually hit the line
	//near the bottom to loop the prone anim...when that happens - the system thinks we're not 
	//staying still even though we're playing a looping animation
	self endon( "friendly_stance_handler_resume_path" );
	
	if ( self ent_flag( "_stealth_stay_still" ) )
		return;
	self ent_flag_set( "_stealth_stay_still" );
	
	badplace_cylinder( "_stealth_" + self.unique_id + "_prone", 0, self.origin, 30, 90, "bad_guys" ); 
	
	//MIGHT NEED THIS IN THE FUTURE
	//self ent_flag_set( "_stealth_custom_anim" ); --> this is for dynamic run speed
	
	self notify( "stop_loop" ); 
	self anim_generic_custom_animmode( self, "gravity", "_stealth_prone_stop" );
	self thread anim_generic_custom_animmode_loop( self, "gravity", "_stealth_prone_idle" );
}

friendly_stance_handler_resume_path()
{	
	self notify( "friendly_stance_handler_resume_path" );
	
	self ent_flag_clear( "_stealth_stay_still" );

	badplace_delete( "_stealth_" + self.unique_id + "_prone" ); 
	
	self notify( "stop_loop" ); 
	self anim_generic_custom_animmode( self, "gravity", "_stealth_prone_start" );
	//MIGHT NEED THIS IN THE FUTURE
	//self ent_flag_clear( "_stealth_custom_anim" ); --> this is for dynamic run speed
}
*/

/************************************************************************************************************/
/*													SETUP													*/
/************************************************************************************************************/
friendly_init()
{
	self ent_flag_init( "_stealth_stance_handler" );
	self ent_flag_init( "_stealth_stay_still" );
	self ent_flag_init( "_stealth_stance_change" );

	self._stealth.behavior.stance_up = undefined;
	self._stealth.behavior.stance_handler = [];
	self friendly_default_stance_handler_distances();

	self._stealth.behavior.no_prone = false;
	self._stealth.behavior.wait_resume_path = 2;

	self._stealth.plugins.smartstance = true;
}

friendly_default_stance_handler_distances()
{
	// i do this because the player doesn't look as bad sneaking up on the enemies
	// friendlies however don't look as good getting so close
	looking_away = [];
	looking_away[ "stand" ] 	 = 500;
	looking_away[ "crouch" ] 	 = -400;
	looking_away[ "prone" ] 	 = 0;

	neutral = [];
	neutral[ "stand" ] 			 = 500;
	neutral[ "crouch" ] 		 = 200;
	neutral[ "prone" ] 			 = 50;

	looking_towards = [];
	looking_towards[ "stand" ] 	 = 800;
	looking_towards[ "crouch" ]  = 400;
	looking_towards[ "prone" ] 	 = 100;

	friendly_set_stance_handler_distances( looking_away, neutral, looking_towards );
}

friendly_set_stance_handler_distances( looking_away, neutral, looking_towards )
{
	if ( isdefined( looking_away ) )
	{
		foreach ( key, value in looking_away )
			self._stealth.behavior.stance_handler[ "looking_away" ][ key ] = value;
	}

	if ( isdefined( neutral ) )
	{
		foreach ( key, value in neutral )
			self._stealth.behavior.stance_handler[ "neutral" ][ key ] = value;
	}

	if ( isdefined( looking_towards ) )
	{
		foreach ( key, value in looking_towards )
			self._stealth.behavior.stance_handler[ "looking_towards" ][ key ] = value;
	}
}