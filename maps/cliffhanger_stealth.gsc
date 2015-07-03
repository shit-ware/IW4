#include maps\_utility;
#include maps\_anim;
#include common_scripts\utility;
#include maps\_stealth_utility;
#include maps\_stealth_shared_utilities;
#include maps\cliffhanger_code;


/************************************************************************************************************/
/*												INITIALIZATIONS												*/
/************************************************************************************************************/

//stealth_price_accuracy_control()
//{
//	level endon( "price_starts_moving" );
//	self.baseaccuracy = 5000000;
//	
//	flag_wait( "near_camp_entrance" );
//	
//	self.baseaccuracy = .5;
//	
//	flag_wait( "at_hanger_entrance" );
//	
//	self.baseaccuracy = 1;
//}

init_cliffhanger_cold_patrol_anims()
{
	// make sure we alternate instead of doing a random selection
	if( !IsDefined( level.lastColdPatrolAnimSetAssigned ) )
	{
		level.lastColdPatrolAnimSetAssigned = "none";
	}
	
	if( level.lastColdPatrolAnimSetAssigned != "huddle" )
	{
		self.patrol_walk_anim = "patrol_cold_huddle";
		self.patrol_walk_twitch = "patrol_twitch_weights";
		
		self.patrol_scriptedanim[ "pause" ][ 0 ] = "patrol_cold_huddle_pause";
		self.patrol_stop[ "pause" ] = "patrol_cold_huddle_stop";
		self.patrol_start[ "pause" ] = "patrol_cold_huddle_start";
		
		self.patrol_stop[ "path_end_idle" ] = "patrol_cold_huddle_stop";
		self.patrol_end_idle[ 0 ] = "patrol_cold_huddle_pause";
		
		level.lastColdPatrolAnimSetAssigned = "huddle";
	}
	else
	{
		self.patrol_walk_anim = "patrol_cold_crossed";
		self.patrol_walk_twitch = "patrol_twitch_weights";
		
		self.patrol_scriptedanim[ "pause" ][ 0 ] = "patrol_cold_crossed_pause";
		self.patrol_stop[ "pause" ] = "patrol_cold_crossed_stop";
		self.patrol_start[ "pause" ] = "patrol_cold_crossed_start";
		
		self.patrol_stop[ "path_end_idle" ] = "patrol_cold_crossed_stop";
		self.patrol_end_idle[ 0 ] = "patrol_cold_crossed_pause";
		
		level.lastColdPatrolAnimSetAssigned = "crossed";
	}
}

clear_cliffhanger_cold_patrol_anims()
{
	self.patrol_walk_anim = undefined;
	self.patrol_walk_twitch = undefined;
		
	self.patrol_scriptedanim = undefined;
	self.patrol_stop = undefined;
	self.patrol_start = undefined;
		
	self.patrol_stop = undefined;
	self.patrol_end_idle = undefined;
	
	self maps\_patrol::set_patrol_run_anim_array();
}

set_cliffhanger_alert_cold_patrol_anims()
{
	self.patrol_walk_anim = "patrol_cold_gunup";
	self.patrol_walk_twitch = "patrol_gunup_twitch_weights";
}

stealth_cliffhanger_clifftop()
{
	self stealth_plugin_basic();

	if ( isplayer( self ) )
		return;

	threat_array[ "warning1" ] = maps\_stealth_threat_enemy::enemy_alert_level_warning2;

			
	switch( self.team )
	{
		case "axis":
			self stealth_plugin_threat();
			self stealth_pre_spotted_function_custom( ::clifftop_prespotted_func );
			self stealth_threat_behavior_custom( threat_array );
			self stealth_enable_seek_player_on_spotted();
			self stealth_plugin_corpse();
			self stealth_plugin_event_all();
			self.baseaccuracy = 1;
			self.fovcosine = .76;	// for the 2nd group -z
			self.fovcosinebusy = .1;
			//self thread dialog_price_kill();

			self init_cliffhanger_cold_patrol_anims();
			break;

		case "allies":
			//self stealth_plugin_aicolor();
			//self stealth_plugin_accuracy();
			//self stealth_plugin_smart_stance();
	}
}



stealth_cliffhanger()
{
	self stealth_plugin_basic();
		
	if( isplayer( self ) )
	{
		self._stealth_move_detection_cap = 0;
		return;
	}
				
	switch( self.team )
	{
		case "axis":
			self ent_flag_init( "player_found" );
			self ent_flag_init( "not_first_attack" );
			self thread maps\_stealth_shared_utilities::enemy_event_debug_print( "player_found" );
			self thread maps\_stealth_shared_utilities::enemy_event_debug_print( "not_first_attack" );
			self stealth_plugin_threat();//call first 
			
			custom_array = [];
			
			if ( level.gameskill < 2 )
			{
				custom_array[ "warning1" ] = maps\_stealth_threat_enemy::enemy_alert_level_warning1;
				custom_array[ "warning2" ] = maps\_stealth_threat_enemy::enemy_alert_level_warning2;
			}
			else
			{
				custom_array[ "warning1" ] = maps\_stealth_threat_enemy::enemy_alert_level_warning2;
			}
			self stealth_threat_behavior_custom( custom_array );
			
			//goal radius etc for attack
			//overridding this: enemy_alert_level_attack( enemy )
			//modify this to make sure you can see the player
			b_array = [];
			b_array [ "attack" ] = ::cliffhanger_enemy_attack_behavior;
			self stealth_threat_behavior_replace( b_array, undefined );
			
			//time till attack once stealth is broken
			//overriding this: enemy_animation_attack( type )
			new_array = [];
			new_array[ "attack" ] = ::cliffhanger_enemy_animation_attack; 
			self stealth_threat_behavior_replace( undefined, new_array );
			
			//how long till rest of group is notified
			//modify this to wait for ent_flag from attack_behavior
			self stealth_pre_spotted_function_custom( ::cliffhanger_prespotted_func_with_flag_wait );
			
			self stealth_enable_seek_player_on_spotted();
			self stealth_plugin_corpse();
			
			self stealth_plugin_event_all();
			
			self maps\_stealth_shared_utilities::ai_set_goback_override_function( ::cliffhanger_enemy_goback_startfunc );
			
			self.grenadeAmmo = 0;
			self.baseaccuracy = 1;
			self.fovcosine = .5; // cos60
			self.fovcosinebusy = .1;
			self thread dialog_player_kill();
			self thread dialog_price_kill();
			self thread dialog_theyre_looking_for_you();
			
			self init_cliffhanger_cold_patrol_anims();
			break;
		
		case "allies":
			//self stealth_plugin_aicolor();
			//self stealth_plugin_accuracy();
			
			//self allowedstances( "crouch" );
			self.grenadeawareness = 0;//dont chase grenades
			self thread stealth_plugin_smart_stance();
			self._stealth.behavior.no_prone = true;
			self._stealth.behavior.wait_resume_path = 4;
			self._stealth_move_detection_cap = 0;
			
			array = [];
			array[ "hidden" ] = ::cliffhanger_friendly_state_hidden;
			array[ "spotted" ] = ::cliffhanger_friendly_state_spotted;
			stealth_basic_states_custom( array );
	}
}

cliffhanger_enemy_goback_startfunc()
{
	self endon( "death" );
	self endon( "pain_death" );
	self endon( "_stealth_attack" );
	self endon( "restart_attack_behavior" );
	self endon( "_stealth_enemy_alert_level_change" );
	
	// report back to base that we didn't find anybody
	if ( self can_report_to_base() )
	{
		level.reportingToBase = true;
		level thread reset_reportingToBase( self );
		
		self thread enemy_announce_hmph();
		
		self.customMoveTransition = maps\_patrol::patrol_resume_move_start_func;
	}
	else
	{
		self.customMoveTransition = maps\_patrol::turn_180_move_start_func;
	}
	
	// set patrol cold walking anims back
	self init_cliffhanger_cold_patrol_anims();
	self maps\_patrol::set_patrol_run_anim_array();
}


// check to see if an enemy who has given up searching for the player
//  can do the "report back to base" anim
can_report_to_base()
{
	// don't do it if someone is already doing it
	if ( IsDefined( level.reportingToBase ) )
		return false;
	
	// don't do it if we're not standing
	if ( !IsDefined( self.a.stance ) || self.a.stance != "stand" )
		return false;
	
	// don't do it if we don't have enough room in front of us
	delta = GetMoveDelta( level.scr_anim[ "generic" ][ "patrol_radio_in_clear" ], 0, 1 );
	endPoint = self LocalToWorldCoords( delta );
	if ( !self MayMoveToPoint( endPoint ) )
		return false;
	
	return true;
}

reset_reportingToBase( ai )
{
	time = GetAnimLength( level.scr_anim[ "generic" ][ "patrol_radio_in_clear" ] );
	
	wait time;
	
	//ai waittill_any( "death", "pain_death", "_stealth_enemy_alert_level_change", "_stealth_attack", "restart_attack_behavior" );
	
	level.reportingToBase = undefined;
}


friendly_init_cliffhanger()
{
	spawner = level.price_spawner;
	spawner.count = 1;
	level.price = spawner stalingradSpawn();
	spawn_failed( level.price );
	assert( isDefined( level.price ) );

//add overrides for bcs and color nodes

	level.price.ref_node = Spawn( "script_origin", level.price.origin );
	//level.price.fixednode = false;
	level.price.animname = "price";
	
	//level.price thread disable_ai_color();
//	level.price stealth_plugin_aicolor();
//	array = [];
//	array[ "hidden" ] = ::do_nothing;
//	array[ "spotted" ] = ::do_nothing;
//	level.price stealth_color_state_custom( array );

	level.price enable_ai_color();
	level.price.pathRandomPercent = 0;
	
	level.price thread magic_bullet_shield();
	//level.price thread price_bullet_sheild(); //disables bullet shield if player is too far
	//level.price thread price_handle_death();  //mission fail if price dies
	level.price make_hero();
	level.price.allowdeath = false;
	level.price thread ShootEnemyWrapper_price();

	thread battlechatter_off( "allies" );
	
	//level.price thread stealth_price_accuracy_control();

	level.price.baseaccuracy = 5000000;

	//all stuff from scoutsniper that might be a good idea
//	level.price thread price_death();
//	level.price setthreatbiasgroup( "price" );
}



cliffhanger_friendly_state_hidden()
{	
	self thread set_battlechatter( false );
		
	self.grenadeammo	 = 0;
	
	self.forceSideArm 	= undefined;
	//used to be ignore all - but that makes him not aim at enemies when exposed - which isn't good...also 
	//after stealth groups were created we want to differentiate between who should be shot at and who shouldn't
	//so we don't all of a sudden alert another stealth group by shooting at them
	//self.dontEverShoot 	= true; 
	self.ignoreme 		= true;
	//self enable_ai_color();
}

cliffhanger_friendly_state_spotted()
{	
	if( flag( "price_go_to_climb_ridge" ) )
		self.dontEverShoot 	= true;
	//self thread set_battlechatter( true );
	
	self.grenadeammo 	= 0;
	//used to be ignore all - but that makes him not aim at enemies when exposed - which isn't good...also 
	//after stealth groups were created we want to differentiate between who should be shot at and who shouldn't
	//so we don't all of a sudden alert another stealth group by shooting at them	
	//self.dontEverShoot 	= false;//self.ignoreall 	 = false;
	if( !flag( "said_lets_split_up" ) )
		self.ignoreme 	 	= false;
			
	//self.disablearrivals 	 = true;
	//self.disableexits 	 = true;
	
	self pushplayer( false );
	//self disable_cqbwalk();
	
	//self thread maps\_stealth_behavior_friendly::friendly_spotted_getup_from_prone();		
	//self allowedstances( "prone", "crouch", "stand" );
	//self anim_stopanimscripted();
	
	//self disable_ai_color();
	//self setgoalpos( self.origin );
}

check_near_enemy()
{
	self endon( "death" );
	self endon( "stop_check_near_enemy" );
	self endon( "restart_attack_behavior" );
	
	distanceSq = max( self.newEnemyReactionDistSq, squared( self.pathEnemyFightDist ) );
	
	waittillframeend;
	
	while ( 1 )
	{
		if( !isdefined( self.enemy ) )
			return;
		if( distanceSquared( self.origin, self.enemy.origin ) < distanceSq )
			break;
		wait 0.1;
	}
		
	self notify( "near_enemy" );
}

cliffhanger_enemy_attack_behavior_attacked_again()
{
	self endon( "death" );
	self endon( "_stealth_attack" );
	level endon( "_stealth_spotted" );
	
	wait 2;
		
	self waittill( "_stealth_bad_event_listener" );
	
	self maps\_stealth_shared_utilities::enemy_reaction_state_alert();

	self ent_flag_set( "not_first_attack" );
	
	self notify( "enemy_runto_and_lookaround" );
	self notify( "restart_attack_behavior" );
	
	self clear_generic_idle_anim();
	
	self thread cliffhanger_enemy_attack_behavior( self.enemy );
}

cliffhanger_enemy_attack_behavior( enemy )
{
	self endon( "restart_attack_behavior" );
	
	self set_cliffhanger_alert_cold_patrol_anims();
	
	//que up the yell
	if ( !self ent_flag( "not_first_attack" ) )
		self thread maps\_stealth_shared_utilities::enemy_announce_spotted( self.origin );
		
	self endon( "death" );
	
	self ent_flag_set( "_stealth_override_goalpos" );
	
	self thread cliffhanger_enemy_attack_behavior_attacked_again();

	if ( !self stealth_group_spotted_flag() )
	{
		self thread cliffhanger_enemy_attack_behavior_looking_for_player();

		//give the player a chance to hide
		wait_reaction_time();

		if ( !self ent_flag( "not_first_attack" ) )
		{
			self thread check_near_enemy();
			waittill_notify_or_timeout( "near_enemy", 3 );

			self notify( "stop_check_near_enemy" );
		}
	
		self thread flag_when_you_can_see_the_player( "player_found" );
		self ent_flag_wait( "player_found" );
	}

	self.dontevershoot = undefined;
	cliffhanger_enemy_attack_behavior_sees_player();
}

wait_reaction_time()
{
	//200 = 0, 700 = .5
	d = distance( self.origin, ( get_closest_player( self.origin ) ).origin );
	t = ( d - 200)/1000;
	t = clamp( t, 0, 0.5 );
	wait t;
	println( "---------reaction time: " + t );
}

/*
low sight dist
self orientmode( "face motion" );
patrol to here
reaction time
wait till "enemy visible"  = cansee
regular combat


*/


cliffhanger_enemy_attack_behavior_looking_for_player()
{
	self endon( "player_found" );
	self endon( "death" );
	self endon( "_stealth_attack" );
	self endon( "restart_attack_behavior" );
	self endon( "_stealth_enemy_alert_level_change" );
	level endon( "_stealth_spotted" );

	//dont shoot until you can see him
	self.dontevershoot = true;

	//cqb halfway to enemy
	self enable_cqbwalk();
	self.disablearrivals = false;
	self.disableexits = false;
	self.goalradius = 64;

	player = get_closest_player( self.origin );
	
	lastknownspot = player.origin;
	distance = distance( lastknownspot, self.origin );

	self ent_flag_set( "_stealth_override_goalpos" );
	
	if ( self cansee( player ) )
	{
		self setgoalpos( lastknownspot );
	}
	else
	{
		searchRadius = 256;
		
		nodes = getNodesInRadius( lastknownspot, searchRadius, 0, 512, "Path" );
		
		if ( nodes.size )
		{
			node = nodes[ randomint( nodes.size ) ];
			self setgoalpos( node.origin );
		}
		else
		{
			self setgoalpos( lastknownspot );
		}
	}
	
	self.goalradius = distance * .5;
	self waittill( "goal" );

	//switch to a walk
	if ( !flag( "_stealth_spotted" ) && ( !isdefined( self.enemy ) || !self cansee( self.enemy ) ) )
	{
		self set_cliffhanger_search_walk();

		self thread maps\_stealth_shared_utilities::enemy_runto_and_lookaround( undefined, lastknownspot );
	}
}

set_cliffhanger_search_walk()
{
	self disable_cqbwalk();

	self set_generic_run_anim( "patrol_cold_gunup_search", true );

	self.disablearrivals = true;
	self.disableexits = true;
}

cliffhanger_enemy_attack_behavior_sees_player()
{
	self endon( "death" );
	self endon( "_stealth_enemy_alert_level_change" );
	
	//there is a .5 second delay in enemy_runto_and_lookaround...
	//this notify makes sure that script dies here so that the 
	//looping anim doesn't start after we stop current behavior below
	self notify( "enemy_runto_and_lookaround" );
	self maps\_stealth_shared_utilities::enemy_stop_current_behavior();
	
	self.dontevershoot = undefined;
	self.aggressivemode = true;//dont linger at cover when you cant see your enemy
	prev_pos = undefined;

	while( !flag( "script_attack_override" ) )
	{
		player = get_closest_player( self.origin );

		if ( animscripts\utility::isShotgun( self.weapon ) )
			radius = 250;
		else
			radius = max( 500, player.maxVisibleDist );

		self.goalradius = radius;
		
		last_known_pos = self lastKnownPos( player );
		player_pos = ( player.origin * 0.25 ) + ( last_known_pos * 0.75 );
		
		if ( self set_goal_near_pos( player_pos, prev_pos ) )
			prev_pos = player_pos;
			
		wait 5;
	}
}


set_goal_near_pos( pos, prev_pos )
{
	if ( !isdefined( prev_pos ) || distanceSquared( pos, prev_pos ) > squared( 64 ) )
	{
		searchRadius = 256;
		
		nodes = getNodesInRadius( pos, searchRadius, 0 );
		
		if ( nodes.size )
		{
			node = nodes[ randomint( nodes.size ) ];
			self setgoalpos( node.origin );
		}
		else
		{
			self setgoalpos( pos );
		}
			
		return true;
	}
	
	return false;
}


flag_when_you_can_see_the_player( flag_name )
{
	self endon( "death" );
	self endon( "restart_attack_behavior" );

	while ( 1 )
	{
		player = get_closest_player( self.origin );

		if ( self cansee( player ) )
		{
			self ent_flag_set( flag_name );
			break;
		}
		wait .1;
	}
}

cliffhanger_enemy_animation_attack( type )
{
	// no animation, just attack
	self thread maps\_stealth_shared_utilities::enemy_announce_attack();				
}

stealth_settings()
{
	stealth_set_default_stealth_function( "cliffhanger", ::stealth_cliffhanger );
	stealth_set_default_stealth_function( "clifftop", ::stealth_cliffhanger_clifftop );

	ai_event = [];
	ai_event[ "ai_eventDistNewEnemy" ] = [];
	ai_event[ "ai_eventDistNewEnemy" ][ "spotted" ]		 = 512;
	ai_event[ "ai_eventDistNewEnemy" ][ "hidden" ] 		 = 256;

	ai_event[ "ai_eventDistExplosion" ] = [];
	ai_event[ "ai_eventDistExplosion" ][ "spotted" ]	 = 1500;
	ai_event[ "ai_eventDistExplosion" ][ "hidden" ] 	 = 1500;

	ai_event[ "ai_eventDistDeath" ] = [];
	ai_event[ "ai_eventDistDeath" ][ "spotted" ] 		 = 512;
	ai_event[ "ai_eventDistDeath" ][ "hidden" ] 		 = 512; // used to be 256
	
	ai_event[ "ai_eventDistPain" ] = [];
	ai_event[ "ai_eventDistPain" ][ "spotted" ] 		 = 256;
	ai_event[ "ai_eventDistPain" ][ "hidden" ] 		 = 256; // used to be 256
	
	ai_event[ "ai_eventDistBullet" ] = [];
	ai_event[ "ai_eventDistBullet" ][ "spotted" ]		 = 96;
	ai_event[ "ai_eventDistBullet" ][ "hidden" ] 		 = 96;
	

	stealth_ai_event_dist_custom( ai_event );

	array = [];
	array[ "player_dist" ]	 = 1000;
	array[ "sight_dist" ]	 = 400;
	array[ "detect_dist" ]	 = 200;
	stealth_corpse_ranges_custom( array );
}

sight_ranges_long()
{
	ai_event[ "ai_eventDistFootstep" ] = [];
	ai_event[ "ai_eventDistFootstep" ][ "spotted" ]		 = 300;
	ai_event[ "ai_eventDistFootstep" ][ "hidden" ] 		 = 300;

	ai_event[ "ai_eventDistFootstepWalk" ] = [];
	ai_event[ "ai_eventDistFootstepWalk" ][ "spotted" ]	 = 300;
	ai_event[ "ai_eventDistFootstepWalk" ][ "hidden" ] 	 = 300;

	ai_event[ "ai_eventDistFootstepSprint" ] = [];
	ai_event[ "ai_eventDistFootstepSprint" ][ "spotted" ]	 = 400;
	ai_event[ "ai_eventDistFootstepSprint" ][ "hidden" ] 	 = 400;

	stealth_ai_event_dist_custom( ai_event );
	
	rangesHidden = [];
	rangesHidden[ "prone" ]		= 800;
	rangesHidden[ "crouch" ]	= 800;
	rangesHidden[ "stand" ]		= 800;

	rangesSpotted = [];
	rangesSpotted[ "prone" ]	= 8192;
	rangesSpotted[ "crouch" ]	= 8192;
	rangesSpotted[ "stand" ]	= 8192;

	stealth_detect_ranges_set( rangesHidden, rangesSpotted );
	
	stealth_alert_level_duration( 0.5 );	
}

sight_ranges_blizzard()
{
	ai_event[ "ai_eventDistFootstep" ] = [];
	ai_event[ "ai_eventDistFootstep" ][ "spotted" ]		 = 120;
	ai_event[ "ai_eventDistFootstep" ][ "hidden" ] 		 = 120;
		
	ai_event[ "ai_eventDistFootstepWalk" ] = [];
	ai_event[ "ai_eventDistFootstepWalk" ][ "spotted" ]	 = 60;
	ai_event[ "ai_eventDistFootstepWalk" ][ "hidden" ] 	 = 60;
	
	ai_event[ "ai_eventDistFootstepSprint" ] = [];
	ai_event[ "ai_eventDistFootstepSprint" ][ "spotted" ]	 = 400;
	ai_event[ "ai_eventDistFootstepSprint" ][ "hidden" ] 	 = 400;
	
	stealth_ai_event_dist_custom( ai_event );
	
	rangesHidden = [];
	rangesHidden[ "prone" ]		= 250;
	rangesHidden[ "crouch" ]	= 450;
	rangesHidden[ "stand" ]		= 500;

	rangesSpotted = [];
	rangesSpotted[ "prone" ]	= 500;
	rangesSpotted[ "crouch" ]	= 500;
	rangesSpotted[ "stand" ]	= 600;
		
	stealth_detect_ranges_set( rangesHidden, rangesSpotted );
	
	alert_duration = [];
	alert_duration[0] = 1;
	alert_duration[1] = 1;
	alert_duration[2] = 1;
	alert_duration[3] = 0.75;

	// easy and normal have 2 alert levels so the above times are effectively doubled
	stealth_alert_level_duration( alert_duration[ level.gameskill ] );	
}

clifftop_prespotted_func()
{
	//thread debug_timer();
	self.battlechatter = false;
	wait 5;
	self.battlechatter = true;
}


debug_timer()
{
	time_past = 0;
	while( time_past < 10 )
	{	
		wait .05;
		time_past = time_past + .05;
		println( "time past: " + time_past );
	}
}

cliffhanger_prespotted_func_with_flag_wait()
{
	self.battlechatter = false;
	if( level.gameskill < 3 )
		self ent_flag_wait( "player_found" );
		
	if( level.gameskill < 2 )
		wait 3;
	else
		wait .25;
		
	self.battlechatter = true;
}


////////////////////////////////////////////////////

price_stealth_kills_guy( targetguy2 )
{
	level.price.fixednode = false;
	level.price disable_ai_color();
	level.price setgoalpos( level.price.origin );
	level.price.goalradius = 8;
	self.dontattackme = undefined;
	level.price.favoriteenemy = self;
	self.health = 1;
	self waittill( "death" );
	
	//alert second guy and tell price to kill him
	if( isalive( targetguy2 ) )
	{
		targetguy2.favoriteenemy = level.player;
		wait .2;
		level.price.favoriteenemy = self;
		targetguy2.dontattackme = undefined;
		
		targetguy2 waittill( "death" );
	}
	wait .8;
	wait 2;
	level.price.fixednode = true;
	level.price enable_ai_color();
	
	//level.price Shoot();
	//aim_spot = self geteye();
	//MagicBullet( level.price.weapon, level.price gettagorigin( "tag_flash" ), aim_spot );
}

wait_for_player_interupt( msg )
{
	if( flag( msg ) )
		return;
	level endon ( "_stealth_spotted" );
	level endon ( msg );
	level.player waittill( "weapon_fired" );
}

///////////////////////////////////////////////////////////////////////////////////

start_truck_patrol()
{
 	array_thread( getentarray( "truck_guys", "script_noteworthy" ), ::add_spawn_function, ::base_truck_guys_think );

	flag_wait( "start_truck_patrol" );
	autosave_stealth();
	
	truck_spawner = getent( "truck_patrol", "targetname" );
	truck_spawner.script_badplace = true;
	level.truck_patrol = maps\_vehicle::spawn_vehicle_from_targetname_and_drive( "truck_patrol" );

	level.truck_patrol thread dialog_truck_coming();
	
	level.truck_patrol thread play_loop_sound_on_entity( "cliffhanger_truck_music" );

	level.truck_patrol thread base_truck_think();
	
	level.truck_patrol thread truck_headlights();
	
	thread dialog_jeep_blown_up();
	level.truck_patrol  thread dialog_jeep_stopped();
	
	level.truck_patrol waittill( "death" );
	
	flag_set( "jeep_blown_up" );
	level.truck_patrol notify( "stop sound" + "cliffhanger_truck_music" );
}

truck_headlights()
{
	//level.truck_patrol maps\_vehicle::lights_on( "headlights" );
	PlayFXOnTag( level._effect[ "lighthaze_snow_headlights" ], self, "TAG_LIGHT_RIGHT_FRONT" );
	PlayFXOnTag( level._effect[ "lighthaze_snow_headlights" ], self, "TAG_LIGHT_LEFT_FRONT" );
 	//level.truck_patrol maps\_vehicle::lights_on( "brakelights" );

	//taillights 
	PlayFXOnTag( level._effect[ "car_taillight_uaz_l" ], self, "TAG_LIGHT_LEFT_TAIL" );
	PlayFXOnTag( level._effect[ "car_taillight_uaz_l" ], self, "TAG_LIGHT_RIGHT_TAIL" );
 	
 	self waittill ( "death" );
 	
 	if( isdefined( self ) )
	 	delete_truck_headlights();
 }	
 
delete_truck_headlights()
 {
	StopFXOnTag( level._effect[ "lighthaze_snow_headlights" ], self, "TAG_LIGHT_RIGHT_FRONT" );
 	StopFXOnTag( level._effect[ "lighthaze_snow_headlights" ], self, "TAG_LIGHT_LEFT_FRONT" );
	StopFXOnTag( level._effect[ "car_taillight_uaz_l" ], self, "TAG_LIGHT_LEFT_TAIL" );
	StopFXOnTag( level._effect[ "car_taillight_uaz_l" ], self, "TAG_LIGHT_RIGHT_TAIL" );
}
	

base_truck_think()
{
	self endon( "death" );

	//level.truck_patrol thread handle_end_of_path();
	//array_thread( level.players, ::base_truck_see, self );
	
	
	level.truck_patrol thread unload_and_attack_if_stealth_broken_and_close();
 	//level.truck_patrol thread break_stealth_if_player_spotted();
 	//level.truck_patrol thread break_stealth_if_damage_taken();//handled by wizz bys
	
	flag_wait( "truck_guys_alerted" );

	//self.runtovehicleoverride = ::truck_guy_runtovehicle;

	//guys = self.attachedguys;
	guys = get_living_ai_array( "truck_guys", "script_noteworthy" );
	
	if( guys.size == 0 )
	{
		self Vehicle_SetSpeed( 0, 15 );
		return;
	}
	
	screamer = random( guys );
	screamer maps\_stealth_shared_utilities::enemy_announce_wtf();

	//wait .5;
	self waittill( "safe_to_unload" );

	self Vehicle_SetSpeed( 0, 15 );
	wait 1;
	self maps\_vehicle::vehicle_unload();
	
	flag_set( "jeep_stopped" );



	//self waittill( "unloaded" );
}



/*
handle_end_of_path()
{
	while( 1 )
	{
		self waittillmatch( "noteworthy", "end_of_path" );
		path = getent( self.target, "targetname" );
		self maps\_vehicle::vehicle_paths( path );
	}
}
*/


//break_stealth_if_damage_taken()
//{
//	self waittill( "damage" );
//	
//	flag_set( "truck_guys_alerted" );
//}

unload_and_attack_if_stealth_broken_and_close()
{	
	self endon( "truck_guys_alerted" );
	
	while( 1 )
	{
		flag_wait( "_stealth_spotted" );
		level.player waittill_entity_in_range( self, 800 );
		if( !flag( "_stealth_spotted" ) )
			continue;
		else
			break;
	}
	flag_set( "truck_guys_alerted" );
}



//base_truck_see( truck )
//{
//	truck endon( "death" );
//	self endon( "death" );
//
//	while ( 1 )
//	{
//		dist = self.maxVisibleDist * .75;
//		dist = dist * dist;
//
//		if ( distancesquared( self.origin, truck.origin ) <= dist )
//			break;
//
//		wait .1;
//	}
//
//	flag_set( "truck_guys_alerted" );
//}




base_truck_guys_attacked_again()
{
	self endon( "death" );
	self endon( "_stealth_attack" );
	level endon( "_stealth_spotted" );
		
	wait 2;
		
	self waittill( "_stealth_bad_event_listener" );
	
	self maps\_stealth_shared_utilities::enemy_reaction_state_alert();

	self ent_flag_set( "not_first_attack" );
}


base_truck_guys_think()
{
	self endon( "death" );

	//if ( flag( "_stealth_spotted" ) || self ent_flag( "_stealth_attack" ) )
	//	return;
		
	level endon( "_stealth_spotted" );
	self endon( "_stealth_attack" );

	self ent_flag_init( "jumped_out" );
	self thread truck_guys_think_jumpout();

	corpse_array = [];
	corpse_array[ "saw" ] 	 = ::truck_guys_reaction_behavior;
	corpse_array[ "found" ] = ::truck_guys_reaction_behavior;

	alert_array = [];
	alert_array[ "warning1" ] = ::truck_guys_reaction_behavior;
	alert_array[ "warning2" ] = ::truck_guys_reaction_behavior;
	alert_array[ "attack" ] = ::truck_alert_level_attack;

	awareness_array = [];
	awareness_array[ "explode" ] = ::truck_guys_no_enemy_reaction_behavior;
	awareness_array[ "heard_scream" ] = ::truck_guys_no_enemy_reaction_behavior;
	awareness_array[ "doFlashBanged" ] = ::truck_guys_no_enemy_reaction_behavior;

	self maps\_stealth_shared_utilities::ai_create_behavior_function( "animation", "wrapper", ::truck_animation_wrapper );
	self stealth_threat_behavior_custom( alert_array );
	self stealth_corpse_behavior_custom( corpse_array );
	foreach ( key, value in awareness_array )
		self maps\_stealth_event_enemy::stealth_event_mod( key, value );

	self ent_flag_set( "_stealth_behavior_reaction_anim" );
}

truck_guys_base_search_behavior( node )
{
	self endon( "_stealth_enemy_alert_level_change" );
	level endon( "_stealth_spotted" );
	self endon( "_stealth_attack" );
	self endon( "death" );
	self endon( "pain_death" );

	self thread base_truck_guys_attacked_again();

	self.disablearrivals = false;
	self.disableexits = false;

	distance = distance( node.origin, self.origin );

	self setgoalnode( node );
	self.goalradius = distance * .5;

	wait 0.05;	// because stealth system keeps clearing run anim on every enemy_animation_wrapper
	self set_generic_run_anim( "_stealth_patrol_cqb" );
	self waittill( "goal" );

	if ( !flag( "_stealth_spotted" ) && ( !isdefined( self.enemy ) || !self cansee( self.enemy ) ) )
	{
		set_cliffhanger_search_walk();
		
		self maps\_stealth_shared_utilities::enemy_runto_and_lookaround( node );
	}
}


truck_guys_think_jumpout()
{
	self endon( "death" );
	self endon( "pain_death" );

	while ( 1 )
	{
		self waittill( "jumpedout" );
		self enemy_set_original_goal( self.origin );
		self.got_off_truck_origin = self.origin;
		self ent_flag_set( "jumped_out" );

		self waittill( "enteredvehicle" );
		wait .15;
		self ent_flag_clear( "jumped_out" );
		self ent_flag_set( "_stealth_behavior_reaction_anim" );
	}
}

truck_animation_wrapper( type )
{
	self endon( "death" );
	self endon( "pain_death" );

	flag_set( "truck_guys_alerted" );

	self ent_flag_wait( "jumped_out" );

	self maps\_stealth_shared_utilities::enemy_animation_wrapper( type );
}

truck_guys_reaction_behavior( type )
{
	self endon( "death" );
	self endon( "pain_death" );
	level endon( "_stealth_spotted" );	
	self endon( "_stealth_attack" );

	flag_set( "truck_guys_alerted" );
	
	self ent_flag_wait( "jumped_out" );

	if ( !flag( "truck_guys_alerted" ) )
		return;
	if ( flag_exist( "truck_guys_not_going_back" ) && flag( "truck_guys_not_going_back" ) )
		return;

	if ( !flag( "_stealth_spotted" ) && !self ent_flag( "_stealth_attack" ) )
	{
		player = get_closest_player( self.origin );
		node = maps\_stealth_shared_utilities::enemy_find_free_pathnode_near( player.origin, 1500, 128 );

		if ( isdefined( node ) )
			self thread truck_guys_base_search_behavior( node );
	}
	
	spotted_flag = self group_get_flagname( "_stealth_spotted" );
	if ( flag( spotted_flag ) )
		self flag_waitopen( spotted_flag );
	else
		self waittill( "normal" );		
}


truck_guys_no_enemy_reaction_behavior( type )
{
	self endon( "death" );
	self endon( "pain_death" );
	level endon( "_stealth_spotted" );	
	self endon( "_stealth_attack" );

	flag_set( "truck_guys_alerted" );
	
	self ent_flag_wait( "jumped_out" );

	if ( !flag( "truck_guys_alerted" ) )
		return;
	if ( flag_exist( "truck_guys_not_going_back" ) && flag( "truck_guys_not_going_back" ) )
		return;

	if ( !flag( "_stealth_spotted" ) && !self ent_flag( "_stealth_attack" ) )
	{
		origin = self._stealth.logic.event.awareness_param[ type ];

		node = self maps\_stealth_shared_utilities::enemy_find_free_pathnode_near( origin, 300, 40 );

		self thread maps\_stealth_shared_utilities::enemy_announce_wtf();

		if ( isdefined( node ) )
			self thread truck_guys_base_search_behavior( node );
	}

	spotted_flag = self group_get_flagname( "_stealth_spotted" );
	if ( flag( spotted_flag ) )
		self flag_waitopen( spotted_flag );
	else
		self waittill( "normal" );		
}


truck_alert_level_attack( enemy )
{
	self endon( "death" );
	self endon( "pain_death" );

	flag_set( "truck_guys_alerted" );
	self ent_flag_wait( "jumped_out" );

	self cliffhanger_enemy_attack_behavior();
}



////////////////////////////////////////////////////

spawn_beehive()
{		
	level endon ( "done_with_stealth_camp" );
	
	
	spawner_triggers = getentarray( "beehive_spawner", "targetname" );
	array_thread( getentarray( "beehive_spawner", "script_noteworthy" ), ::add_spawn_function, ::beehive_enemies );

	
	while( 1 )
	{
		println( "                   beehive ready" );
		flag_wait( "_stealth_spotted" );
		
		wait 1;
		
		num = alert_enemies_count();
		hives = 0;
		if ( num <= 3 )
			hives = 2;
		if ( num > 3 )
			hives = 1;
		if ( num > 5 )
			hives = 0;
		if(! is_group77_alert() )
			hives = 0;
		

		
		println( "                   beehives     : " + hives );
		//sort from closest to furtherest
		spawner_triggers = get_array_of_closest( getAveragePlayerOrigin(), spawner_triggers );
	
		//skip the closest 2
		for( i = 2 ; i < (2 + hives); i++ )
		{
			spawner_triggers[i] notify ( "trigger" );
		}
		
		flag_waitopen( "_stealth_spotted" );
	}
}

is_group77_alert()
{
	alerted_groups = stealth_group_return_groups_with_spotted_flag();
	foreach( group in alerted_groups )
	{
		if( group == "77" )
			return true;
	}
	return false;
}

alert_enemies_count()
{
	enemies = getaiarray( "axis" );
	count = 0;
	foreach( guy in enemies )
	{
		if( guy ent_flag_exist( "_stealth_normal" ) )
			if( !guy ent_flag( "_stealth_normal" ) )
				count++;
	}
	return count;
}

beehive_enemies()
{
	self endon( "death" );
	self.baseaccuracy = 1;
	self.aggressivemode = true;
	g_radius = 700;
	if( self.weapon == "m1014" )
		g_radius = 250;
	
	while( 1 )
	{
		if ( isdefined( self.enemy ) )
		{
			self.goalradius = g_radius;
			player = get_closest_player( self.origin );
			self setgoalpos( player.origin );
		}
		wait 4;
	}
}



////////////////////////////////////////////////////
MIN_NON_ALERT_TEAMMATE_DIST_SQ = 300 * 300;
MIN_ALERT_TEAMMATE_DIST_SQ = 1000 * 1000;

// price should snipe if AI is not alert or there are no teammates nearby it.
price_should_snipe_me()
{
	teammates = getAIArray( self.team );
	foreach( ai in teammates )
	{
		if ( self == ai )
			continue;
			
		if ( ai.alertLevel == "alert" )
			checkDistSq = MIN_ALERT_TEAMMATE_DIST_SQ;
		else
			checkDistSq = MIN_NON_ALERT_TEAMMATE_DIST_SQ;

		if ( distanceSquared( self.origin, ai.origin ) < checkDistSq )
			return false;
	}
	
	return true;
}
