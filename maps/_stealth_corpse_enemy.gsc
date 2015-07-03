#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include maps\_stealth_utility;
#include maps\_stealth_shared_utilities;
#include maps\_stealth_animation_funcs;

stealth_corpse_enemy_main()
{
	self enemy_init();

	self thread enemy_corpse_logic();
	self thread enemy_Corpse_Loop();
}

/************************************************************************************************************/
/*												BEHAVIOR LOOPS												*/
/************************************************************************************************************/
enemy_Corpse_Loop()
{
	self endon( "death" );
	self endon( "pain_death" );

	self thread enemy_found_corpse_loop();

	while ( 1 )
	{
		self waittill( "_stealth_saw_corpse" );

		if ( !self ent_flag( "_stealth_enabled" ) )
			continue;

		self enemy_saw_corpse_logic();
	}
}

enemy_found_corpse_loop()
{
	spotted_flag = self group_get_flagname( "_stealth_spotted" );
	corpse_flag = self group_get_flagname( "_stealth_found_corpse" );

	self endon( "death" );
	self endon( "pain_death" );

	if ( flag( spotted_flag ) )
		return;
	level endon( spotted_flag );

	while ( 1 )
	{
		self ent_flag_wait( "_stealth_enabled" );

		if ( self ent_flag_exist( "_stealth_behavior_asleep" ) )
			self ent_flag_waitopen( "_stealth_behavior_asleep" );

		self stealth_group_corpse_flag_wait();

		if ( !self ent_flag( "_stealth_enabled" ) )
			continue;
		while ( self stealth_group_corpse_flag() )
		{
			if ( !self ent_flag( "_stealth_enabled" ) )
				break;

			self enemy_corpse_found_wrapper();

			level waittill( corpse_flag );
		}
	}
}

enemy_saw_corpse_logic()
{
	spotted_flag = self group_get_flagname( "_stealth_spotted" );
	corpse_flag = self group_get_flagname( "_stealth_found_corpse" );

	if ( flag( spotted_flag ) )
		return;
	level endon( spotted_flag );
	
	self endon( "attack" );

	level endon( corpse_flag );
	
	while ( 1 )
	{
		self ent_flag_waitopen( "_stealth_enemy_alert_level_action" );

		self enemy_corpse_saw_wrapper();

		// the only reason we failed - and didn't end this function 
		// is if we had an alert change so wait to go back to normal 
		// and then resume looking for the corpse
		self waittill( "normal" );
	}
}

enemy_corpse_saw_wrapper()
{
	self enemy_find_original_goal();

	// if he maybe saw an enemy - that's more important
	self endon( "enemy_alert_level_change" );

	self thread enemy_announce_huh();

	//self enemy_stop_current_behavior();
	self ent_flag_set( "_stealth_running_to_corpse" );
	self ent_flag_set( "_stealth_override_goalpos" );

	funcs = self._stealth.behavior.ai_functions[ "corpse" ];
	self [[ funcs[ "saw" ] ]]();// ::enemy_corpse_saw_behavior()
}

enemy_corpse_found_wrapper()
{
	self enemy_find_original_goal();

	if ( !self ent_flag( "_stealth_found_corpse" ) )
		self notify( "awareness_corpse", "heard_corpse", ( 0, 0, 0 ) );

	self enemy_reaction_state_alert();

	if ( self.type == "dog" )
		self ent_flag_set( "_stealth_override_goalpos" );

	self thread enemy_corpse_reset_wrapper();

	funcs = self._stealth.behavior.ai_functions[ "corpse" ];
	self [[ funcs[ "found" ] ]]();// ::enemy_corpse_found_behavior()
}

enemy_corpse_reset_wrapper()
{
	spotted_flag = self group_get_flagname( "_stealth_spotted" );

	//if an event happens - we want to forget about this
	self endon( "death" );
	self endon( "_stealth_enemy_alert_level_change" );
	level endon( spotted_flag );
	//in this frame we'll receive this notify from our own event...so wait a frame so we dont end on it
	waittillframeend;
	self endon( "enemy_awareness_reaction" );

	self stealth_group_corpse_flag_waitopen();

	self ent_flag_set( "_stealth_normal" );
		
	funcs = self._stealth.behavior.ai_functions[ "corpse" ];
	self thread [[ funcs[ "reset" ] ]]();// ::enemy_corpse_reset_behavior()
}

/************************************************************************************************************/
/*												DEFAULT BEHAVIOR											*/
/************************************************************************************************************/
enemy_corpse_saw_behavior()
{
	self.disableArrivals = false;
	self.disableExits = false;

	if ( self.type != "dog" )
		self set_generic_run_anim( "_stealth_combat_jog" );
	else
	{
		self clear_run_anim();
		self.script_growl = 1;
		self.script_nobark = 1;
	}

	self.goalradius = 80;// the animation of finding the corpse
	self setgoalpos( self._stealth.logic.corpse.origin );
}

enemy_corpse_found_behavior()
{
	if ( self.type == "dog" )
	{
		self setgoalpos( self.origin );
		return;
	}

	//self enemy_stop_current_behavior();

	node = enemy_find_free_pathnode_near( level._stealth.logic.corpse.last_pos, 512, 40 );

	if ( !isdefined( node ) )
		return;

	self thread enemy_runto_and_lookaround( node );
}

enemy_corpse_reset_behavior()
{
	wait randomfloatrange( 0, 5 );
	self enemy_stop_current_behavior();
	
	self maps\_stealth_threat_enemy::enemy_alert_level_change( "reset" );
}

/************************************************************************************************************/
/*													LOGIC													*/
/************************************************************************************************************/
player_can_see_corpse( corpse_location )
{
	player = get_closest_player( corpse_location );
	d = distance( player.origin, corpse_location );

	//if very close line of sight doesnt matter
	if ( d < 150 )
		return true;

	//if very far from nearest player line of sight doesnt matter
	if ( d > level._stealth.logic.corpse.player_distsqrd )
		return false;

	return sightTracePassed( ( corpse_location + ( 0, 0, 48 ) ), player geteye(), false, player );
}

enemy_corpse_logic()
{
	self endon( "death" );
	self endon( "pain_death" );

	self thread enemy_corpse_found_loop();
	while ( 1 )
	{
		if ( self ent_flag_exist( "_stealth_behavior_asleep" ) )
			self ent_flag_waitopen( "_stealth_behavior_asleep" );

		self ent_flag_wait( "_stealth_enabled" );

		while ( !self stealth_group_spotted_flag() && !self ent_flag( "_stealth_attack" ) )
		{
			found = false;
			saw = false;
			corpse = undefined;
			dist = undefined;

			corpseArray = GetCorpseArray();
			
			for ( i = 0; i < corpseArray.size; i++ )
			{
				corpse = corpseArray[ i ];
				
				if ( isdefined( corpse.found ) )
					continue;

				if( !isdefined( level.corpse_behavior_doesnt_require_player_sight ) )
					if ( !player_can_see_corpse( corpse.origin ) )
						continue;

				distsqrd = distancesquared( self.origin, corpse.origin );

				if ( self.type != "dog" )
					dist = level._stealth.logic.corpse.found_distsqrd;
				else
					dist = level._stealth.logic.corpse.found_dog_distsqrd;

				//are we so close that we actually found one?
				if ( distsqrd < dist )
				{
					found = true;
					break;
				}

				//that's the only check for finding a guy - now lets see if we just see anyone
				//and make sure not to make any duplicates...we don't want to notify seeing the 
				//same corpse multiple times

				//have we already seen this guy?
				if ( isdefined( self._stealth.logic.corpse.corpse_entity ) )
				{
					if ( self._stealth.logic.corpse.corpse_entity == corpse )
						continue;

					//ok so it's a new guy - is this one closer than the one we already have?
					distsqrd2 = distancesquared( self.origin, self._stealth.logic.corpse.corpse_entity.origin );
					if ( distsqrd2 <= distsqrd )
						continue;
				}

				//are we close enough to check?
				if ( distsqrd > level._stealth.logic.corpse.sight_distsqrd )
					continue;

				//ok how about close enough to automatically see one?
				if ( distsqrd < level._stealth.logic.corpse.detect_distsqrd )
				{
					//do we have clear line of sight to the corpse
					if ( self cansee( corpse ) )
					{
						saw = true;
						break;
					}
				}

				//if not do we happen to look at him at this distance?
				angles = self gettagangles( "tag_eye" );
				origin = self getEye();

				sight 			 = anglestoforward( angles );
				vec_to_corpse 	 = vectornormalize( corpse.origin - origin );

				//are we looking towards a corpse
				if ( vectordot( sight, vec_to_corpse ) > .55 )
				{
					//do we have clear line of sight to the corpse
					if ( self cansee( corpse ) )
					{
						saw = true;
						break;
					}
				}
			}
			
			if ( found )
			{
				if ( !ent_flag( "_stealth_found_corpse" ) )
					self ent_flag_set( "_stealth_found_corpse" );
				else
					self notify( "_stealth_found_corpse" );

				//if he found it then we can clear his seeing one
				self ent_flag_clear( "_stealth_saw_corpse" );

				self thread enemy_corpse_found( corpse );

				self notify( "awareness_corpse", "found_corpse", corpse );
			}
			else if ( saw )
			{
				self._stealth.logic.corpse.corpse_entity = corpse;
				self._stealth.logic.corpse.origin = corpse.origin;

				if ( !ent_flag( "_stealth_saw_corpse" ) )
					self ent_flag_set( "_stealth_saw_corpse" );
				else
					self notify( "_stealth_saw_corpse" );

				level notify( "_stealth_saw_corpse" );
				self notify( "awareness_corpse", "saw_corpse", corpse );
			}

			wait .5;// was .05
		}

		self remove_corpse_loop_while_stealth_broken();
		self stealth_group_spotted_flag_waitopen();
		self ent_flag_waitopen( "_stealth_attack" );
	}
}

remove_corpse_loop_while_stealth_broken()
{
	spotted_flag = self group_get_flagname( "_stealth_spotted" );
	
	while ( flag( spotted_flag ) )
	{
		corpseArray = GetCorpseArray();
		
		for ( i = 0; i < corpseArray.size; i++ )
		{
			corpse = corpseArray[ i ];
			
			if ( isdefined( corpse.found ) )
				continue;
				
			distsqrd = distancesquared( self.origin, corpse.origin );

			if ( self.type != "dog" )
				dist = level._stealth.logic.corpse.found_distsqrd;
			else
				dist = level._stealth.logic.corpse.found_dog_distsqrd;
				
			if ( distsqrd < dist )
			{				
				corpse setCorpseRemoveTimer( 10 );
				corpse.found = true;
			}
		}
		
		 wait 0.5;
	}
}

enemy_corpse_found_loop()
{
	self endon( "death" );
	self endon( "pain_death" );

	_flag = self stealth_get_group_corpse_flag();

	while ( 1 )
	{
		level waittill( _flag );

		//make sure the flag's not notifying because it's getting cleared
		if ( !self stealth_group_corpse_flag() )
			continue;

		self enemy_corpse_alert_level();
	}
}

enemy_corpse_alert_level()
{
	enemy = undefined;

	if ( isdefined( self.enemy ) )
		enemy = self.enemy;
	else
		enemy = random( level.players );

	//we want the ai to detect an enemy without actually causing the behavior to happen
	//so we can't use the regular alert function, because that causes a notify

	if ( !isdefined( enemy._stealth.logic.spotted_list[ self.unique_id ] ) )
		enemy._stealth.logic.spotted_list[ self.unique_id ] = 0;

	//basically take up their alert level each time they see a corpse...but not enough
	//to start attacking the player	
	if ( enemy._stealth.logic.spotted_list[ self.unique_id ] < self._stealth.logic.alert_level.max_warnings )
	{
		enemy._stealth.logic.spotted_list[ self.unique_id ]++ ;// this takes it to 1
		self thread enemy_alert_level_forget( enemy );
	}
}

enemy_corpse_found( corpse )
{
	self endon( "death" );

	level._stealth.logic.corpse.last_pos = corpse.origin;
	corpse setCorpseRemoveTimer( level._stealth.logic.corpse.reset_time );
	corpse.found = true;

	//give a chance
	if ( self.type == "dog" && self ent_flag_exist( "_stealth_behavior_reaction_anim_in_progress" ) )
	{
		wait .1;
		self ent_flag_waitopen( "_stealth_behavior_reaction_anim_in_progress" );
		wait .5;
	}
	else
		wait 2;

	self thread enemy_announce_corpse();
	wait 2;

	corpse_flag = self group_get_flagname( "_stealth_found_corpse" );
	if ( !self stealth_group_corpse_flag() )
		self group_flag_set( "_stealth_found_corpse" );
	else
		level notify( corpse_flag );

	self thread enemy_corpse_clear();
}

enemy_corpse_clear()
{
	corpse_flag = self group_get_flagname( "_stealth_found_corpse" );
	group = self.script_stealthgroup;

	level endon( corpse_flag );

	waittill_dead_or_dying( group_get_ai_in_group( group ), undefined, level._stealth.logic.corpse.reset_time );
	
	thread group_flag_clear( "_stealth_found_corpse", group );
}

/************************************************************************************************************/
/*													SETUP													*/
/************************************************************************************************************/
enemy_init()
{
	self._stealth.logic.corpse = spawnstruct();
	self._stealth.logic.corpse.corpse_entity = undefined;

	self ent_flag_init( "_stealth_saw_corpse" );
	self ent_flag_init( "_stealth_found_corpse" );

	self enemy_default_corpse_behavior();
	self enemy_default_corpse_anim_behavior();

	self._stealth.plugins.corpse = true;
}

enemy_default_corpse_anim_behavior()
{

	if ( self.type == "dog" )
	{
		self ai_create_behavior_function( "animation", "heard_corpse", 		::dog_animation_generic );
		self ai_create_behavior_function( "animation", "saw_corpse", 		::dog_animation_sawcorpse );
		self ai_create_behavior_function( "animation", "found_corpse", 		::dog_animation_foundcorpse );
		self ai_create_behavior_function( "animation", "howl", 				::dog_animation_howl );
	}
	else
	{
		self ai_create_behavior_function( "animation", "heard_corpse", 		::enemy_animation_generic );
		self ai_create_behavior_function( "animation", "saw_corpse", 		::enemy_animation_sawcorpse );
		self ai_create_behavior_function( "animation", "found_corpse", 		::enemy_animation_foundcorpse );
	}
}

enemy_default_corpse_behavior()
{
	array = [];
	array[ "saw" ] 		 = ::enemy_corpse_saw_behavior;
	array[ "found" ] 	 = ::enemy_corpse_found_behavior;
	array[ "reset" ] 	 = ::enemy_corpse_reset_behavior;

	self enemy_custom_corpse_behavior( array );
}

enemy_custom_corpse_behavior( array )
{
	foreach ( key, function in array )
		self ai_create_behavior_function( "corpse", key, function );
}