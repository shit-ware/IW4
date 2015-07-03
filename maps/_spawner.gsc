#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;

// .script_delete	a group of guys, only one of which spawns
// .script_playerseek	spawn and run to the player
// .script_patroller	follow your targeted patrol
// .script_delayed_playerseek	spawn and run to the player with decreasing goal radius
// .script_followmin
// .script_followmax
// .script_radius
// .script_friendname
// .script_startinghealth
// .script_accuracy
// .script_grenades
// .script_sightrange
// .script_ignoreme

main()
{
	precachemodel( "grenade_bag" );
// 	precachemodel( "com_trashbag" );
	//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	//   connect auto AI spawners
	//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	// create default threatbiasgroups;
	createthreatbiasgroup( "allies" );
	createthreatbiasgroup( "axis" );
	createthreatbiasgroup( "team3" );
	createthreatbiasgroup( "civilian" );

	
	addNotetrack_customFunction( "generic", "rappel_pushoff_initial_npc",	::enable_achievement_harder_they_fall_guy );
	addNotetrack_customFunction( "generic", "ps_rappel_pushoff_initial_npc",	::enable_achievement_harder_they_fall_guy );
	
	addNotetrack_customFunction( "generic", "feet_on_ground",	::disable_achievement_harder_they_fall_guy );
	addNotetrack_customFunction( "generic", "ps_rappel_clipout_npc",	::disable_achievement_harder_they_fall_guy );
	
		
	foreach ( player in level.players )
	{
		player setthreatbiasgroup( "allies" );
	}
	
	// temp disabled, prototyping money
	if( getdvar( "xp_enable", "0" ) == "1" )
		thread maps\_rank::init();
		
	if( getdvar( "money_enable", "0" ) == "1" )
		thread maps\_money::init();
		
	/#
	// for combat mode testing
	setDvarIfUninitialized( "scr_force_ai_combat_mode", "0" );
	#/

/* 
	spawners = getSpawnerArray();
	for ( i = 0; i < spawners.size; i++ )
	{
		spawner = spawners[ i ];
		if ( !isDefined( spawner.targetname ) )
			continue;
			
		triggers = getEntArray( spawner.targetname, "target" );
		for ( j = 0; j < triggers.size; j++ )
		{
			trigger = triggers[ j ];
			
			if ( ( isdefined( trigger.targetname ) ) && ( trigger.targetname == "flood_spawner" ) )
				continue;
			
			switch( trigger.classname )
			{
			case "trigger_multiple":
			case "trigger_once":
			case "trigger_use":
			case "trigger_damage":
			case "trigger_radius":
			case "trigger_lookat":
				if ( spawner.count )
					trigger thread doAutoSpawn( spawner );
				break;
			}
		}
	}
*/ 

	//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	level._nextcoverprint = 0;
	level._ai_group = [];
	level.killedaxis = 0;
	level.ffpoints = 0;
	level.missionfailed = false;
	level.gather_delay = [];
	level.smoke_thrown = [];
	
	if ( !isdefined( level.deathflags ) )
		level.deathflags = [];
		
	level.spawner_number = 0;
	level.go_to_node_arrays = [];

	if ( !isdefined( level.subclass_spawn_functions ) )
		level.subclass_spawn_functions = [];
	level.subclass_spawn_functions[ "regular" ] = ::subclass_regular;
	level.subclass_spawn_functions[ "elite" ] = ::subclass_elite;
	
	level.team_specific_spawn_functions = [];
	level.team_specific_spawn_functions[ "axis" ] = ::spawn_team_axis;
	level.team_specific_spawn_functions[ "allies" ] = ::spawn_team_allies;
	level.team_specific_spawn_functions[ "team3" ] = ::spawn_team_team3;
	level.team_specific_spawn_functions[ "neutral" ] = ::spawn_team_neutral;	


	level.next_health_drop_time = 0;
	level.guys_to_die_before_next_health_drop = randomintrange( 1, 4 );
	if ( !isdefined( level.default_goalradius ) )
		level.default_goalradius = 2048;

	if ( !isdefined( level.default_goalheight ) )
		level.default_goalheight = 512;
	level.portable_mg_gun_tag = "J_Shoulder_RI";// need to get J_gun back to make it work properly
	level.mg42_hide_distance = 1024;
	
	if ( !isdefined( level.maxFriendlies ) )
		level.maxFriendlies = 11;

	level._max_script_health = 0;
	ai = getaispeciesarray();
	array_thread( ai, ::living_ai_prethink );

	level.ai_classname_in_level = [];

	level.drone_paths = [];

	spawners = getspawnerarray();
	for ( i = 0;i < spawners.size;i++ )
		spawners[ i ] thread spawn_prethink();
		
	level.drone_paths = undefined;

	thread process_deathflags();

	array_thread( ai, ::spawn_think );

	level.ai_classname_in_level_keys = getarraykeys( level.ai_classname_in_level );
	for ( i = 0 ; i < level.ai_classname_in_level_keys.size ; i++ )
	{
		if ( !issubstr( tolower( level.ai_classname_in_level_keys[ i ] ), "rpg" ) )
			continue;
		precacheItem( "rpg_player" );
		break;
	}
	level.ai_classname_in_level_keys = undefined;

	run_thread_on_noteworthy( "hiding_door_spawner", maps\_hiding_door::hiding_door_spawner );
	

	 /#
	// check to see if the designer has placed at least the minimal number of script_char_groups
//	check_script_char_group_ratio( spawners );
	#/
}

// check to see if the designer has placed at least the minimal number of script_char_groups
check_script_char_group_ratio( spawners )
{
	if ( spawners.size <= 16 )
		return;

	total = 0;
	grouped = 0;
	for ( i = 0; i < spawners.size; i++ )
	{
		if ( !spawners[ i ].team != "axis" )
			continue;

		total++;

		if ( !spawners[ i ] has_char_group() )
			continue;

		grouped++;
	}

	assertex( grouped / total >= 0.65, "Please group your enemies with script_char_group so that each group gets a unique character mix. This minimizes duplicate characters in close proximity. Or you can specify precise character choice with script_group_index." );
}

has_char_group()
{
	if ( isdefined( self.script_char_group ) )
		return true;
	return isdefined( self.script_char_index );
}

process_deathflags()
{
	foreach ( deathflag, array in level.deathflags )
	{
		if ( !isdefined( level.flag[ deathflag ] ) )
		{
			flag_init( deathflag );
		}
	}
}

spawn_guys_until_death_or_no_count()
{
	self endon( "death" );
	for ( ;; )
	{
		if ( self.count > 0 )
		{
			self waittill( "spawned" );
		}
		
		// give the other waittill( "spawned" ) a chance to hit and increment the deathspawn
		// on the ai or vehicle
		waittillframeend; 
			
		if ( !self.count )
			return;
	}
}

ai_deathflag()
{
	level.deathflags[ self.script_deathflag ][ "ai" ][ self.unique_id ] = self;
	ai_number = self.unique_id;
	deathflag = self.script_deathflag;

	if ( isdefined( self.script_deathflag_longdeath ) )
	{
		self waittillDeathOrPainDeath();
	}
	else
	{
		self waittill( "death" );
	}

	level.deathflags[ deathflag ][ "ai" ][ ai_number ] = undefined;
	update_deathflag( deathflag );
}

vehicle_deathflag()
{
	ai_number = self.unique_id;
	deathflag = self.script_deathflag;

	if ( !isdefined( level.deathflags ) || !isdefined( level.deathflags[ self.script_deathflag ] ) )
	{
		waittillframeend; // if its the first frame then process deathflags hasn't happened yet
		if ( !isdefined( self ) )
			return;
	}
	
	level.deathflags[ deathflag ][ "vehicles" ][ ai_number ] = self;

	self waittill( "death" );

	level.deathflags[ deathflag ][ "vehicles" ][ ai_number ] = undefined;
	update_deathflag( deathflag );
}


spawner_deathflag()
{
	level.deathflags[ self.script_deathflag ] = [];

	// wait for the process_deathflags script to run and setup the arrays
	waittillframeend;

	if ( !isdefined( self ) || self.count == 0 )
	{
		// the spawner was removed on the first frame
		return;
	}

	// give each spawner a unique id
	self.spawner_number = level.spawner_number;
	level.spawner_number++;

	// keep an array of spawner entities that have this deathflag
	level.deathflags[ self.script_deathflag ][ "spawners" ][ self.spawner_number ] = self;
	deathflag = self.script_deathflag;
	id = self.spawner_number;

	spawn_guys_until_death_or_no_count();

	level.deathflags[ deathflag ][ "spawners" ][ id ] = undefined;

	update_deathflag( deathflag );
}

vehicle_spawner_deathflag()
{
	level.deathflags[ self.script_deathflag ] = [];

	// wait for the process_deathflags script to run and setup the arrays
	waittillframeend;

	if ( !isdefined( self ) )
	{
		// the spawner was removed on the first frame
		return;
	}

	// give each spawner a unique id
	self.spawner_number = level.spawner_number;
	level.spawner_number++;

	// keep an array of spawner entities that have this deathflag
	level.deathflags[ self.script_deathflag ][ "vehicle_spawners" ][ self.spawner_number ] = self;
	deathflag = self.script_deathflag;
	id = self.spawner_number;

	spawn_guys_until_death_or_no_count();

	level.deathflags[ deathflag ][ "vehicle_spawners" ][ id ] = undefined;

	update_deathflag( deathflag );
}

update_deathflag( deathflag )
{
	level notify( "updating_deathflag_" + deathflag );
	level endon( "updating_deathflag_" + deathflag );

	// notify and endon and waittill so we only do this a max of once per frame
	// even if multiple spawners or ai are killed in the same frame
	// also gives ai a chance to spawn and be added to the ai deathflag array
	waittillframeend;
	
	foreach ( index, array in level.deathflags[ deathflag ] )
	{
		if ( getarraykeys( array ).size > 0 )
			return;
	}

/*
	spawnerKeys = getarraykeys( level.deathflags[ deathflag ][ "spawners" ] );
	if ( spawnerKeys.size > 0 )
		return;

	aiKeys = getarraykeys( level.deathflags[ deathflag ][ "ai" ] );
	if ( aiKeys.size > 0 )
		return;
*/

	// all the spawners and ai are gone
	flag_set( deathflag );
}

outdoor_think( trigger )
{
	assert( ( trigger.spawnflags & 1 ) || ( trigger.spawnflags & 2 ) || ( trigger.spawnflags & 4 ), "trigger_outdoor at " + trigger.origin + " is not set up to trigger AI! Check one of the AI checkboxes on the trigger." );

	trigger endon( "death" );
	for ( ;; )
	{
		trigger waittill( "trigger", guy );
		if ( !isAI( guy ) )
			continue;

		guy thread ignore_triggers( 0.15 );

		guy disable_cqbwalk();
		guy.wantShotgun = false;
	}
}

indoor_think( trigger )
{
	assert( ( trigger.spawnflags & 1 ) || ( trigger.spawnflags & 2 ) || ( trigger.spawnflags & 4 ), "trigger_indoor at " + trigger.origin + " is not set up to trigger AI! Check one of the AI checkboxes on the trigger." );

	trigger endon( "death" );
	for ( ;; )
	{
		trigger waittill( "trigger", guy );
		if ( !isAI( guy ) )
			continue;

		guy thread ignore_triggers( 0.15 );

		guy enable_cqbwalk();
		guy.wantShotgun = true;
	}
}

doAutoSpawn( spawner )
{
	spawner endon( "death" );
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "trigger" );
		if ( !spawner.count )
			return;
		if ( self.target != spawner.targetname )
			return;// manually disconnected
		if ( isdefined( spawner.triggerUnlocked ) )
			return;// manually disconnected

		guy = spawner spawn_ai();

		if ( spawn_failed( guy ) )
			spawner notify( "spawn_failed" );
		if ( isdefined( self.Wait ) && ( self.Wait > 0 ) )
			wait( self.Wait );
	}
}

trigger_spawner( trigger )
{
	assertEx( isdefined( trigger.target ), "Triggers with flag TRIGGER_SPAWN at " + trigger.origin + " must target at least one spawner." );
	//trigger endon( "death" );
	
	random_killspawner = trigger.random_killspawner;
	target = trigger.target;
	
	trigger waittill( "trigger" );
	
	trigger script_delay();
	
	if ( isdefined( random_killspawner ) )
		waittillframeend;// let our random killspawner fire before spawning guys

	spawners = getentarray( target, "targetname" );
	foreach ( spawner in spawners )
	{
		if ( spawner.code_classname == "script_vehicle" )
		{
			
			spawner thread maps\_vehicle::spawn_vehicle_and_gopath();
			continue;
		}
		
		spawner thread trigger_spawner_spawns_guys();
	}
	
}

trigger_spawner_spawns_guys()
{
	self endon( "death" );
	self script_delay();
	
	if ( !isdefined( self ) )
		return undefined;
	
	if ( isdefined( self.script_drone ) )
	{
		spawned = dronespawn( self );
		return undefined;
	}
	else
	if ( !issubstr( self.classname, "actor" ) )
		return undefined;
		
	// catch for stealth
	dontShareEnemyInfo = ( isdefined( self.script_stealth ) && flag( "_stealth_enabled" ) && !flag( "_stealth_spotted" ) );
		
	if ( isdefined( self.script_forcespawn ) )
		spawned = self stalingradSpawn( dontShareEnemyInfo );
	else
		spawned = self doSpawn( dontShareEnemyInfo );
	
	return spawned;
}

trigger_spawner_reinforcement( trigger )
{
	assertEx( isdefined( trigger.target ), "Triggers with flag TRIGGER_SPAWN at " + trigger.origin + " must target or link to at least one spawner." );
	
	target = trigger.target;
	
	targetsReinforcement = false;
	spawners = getentarray( target, "targetname" );
	foreach ( spawner in spawners )
	{
		if ( !isdefined( spawner.target ) )
			continue;
		reinforcement_spawner = getent( spawner.target, "targetname" );
		if ( !isdefined( reinforcement_spawner ) )
		{
			if ( !isdefined( spawner.script_linkto ) )
				continue;
			reinforcement_spawner = spawner get_linked_ent();
			if ( !isdefined( reinforcement_spawner ) )
				continue;
			if ( !isSpawner( reinforcement_spawner ) )
				continue;
		}
		targetsReinforcement = true;
		break;
	}
	assertEx( targetsReinforcement == true, "trigger_multiple_spawn_reinforcement trigger needs at least one AI to target a reinforcement spawner. You should just be using trigger_multiple_spawn in this case." );
	
	trigger waittill( "trigger" );
	
	trigger script_delay();
	
	// get array again because some might have been killspawned
	spawners = getentarray( target, "targetname" );
	foreach ( spawner in spawners )
	{
		spawner thread trigger_reinforcement_spawn_guys();
	}
}

trigger_reinforcement_spawn_guys()
{
	// get the reinforcement spawner
	reinforcement = self trigger_reinforcement_get_reinforcement_spawner();
	
	// spawn the first guy
	guy = self trigger_spawner_spawns_guys();
	
	// if the guy failed to spawn then try to spawn the reinforcement
	if ( !isdefined( guy ) )
	{
		// delete failed spawner
		self delete();
		
		if ( isdefined( reinforcement ) )
		{
			guy = reinforcement trigger_spawner_spawns_guys();
			reinforcement delete();
			
			// reinforcement guy failed to spawn too
			if ( !isdefined( guy ) )	
				return;
		}
		else
			return;
	}
	
	if ( !isdefined( reinforcement ) )
		return;
	
	guy waittill( "death" );
	
	// could have been killspawned
	if ( !isdefined( reinforcement ) )
		return;
	
	if ( !isdefined( reinforcement.count ) )
		reinforcement.count = 1;
	
	for(;;)
	{
		if ( !isdefined( reinforcement ) )
			break;
		
		spawned = reinforcement thread trigger_spawner_spawns_guys();
		if ( !isdefined( spawned ) )
		{
			reinforcement delete();
			break;
		}
		
		spawned thread reincrement_count_if_deleted( reinforcement );
		
		spawned waittill( "death", attacker );
		
		if ( !player_saw_kill( spawned, attacker ) )
		{
			println( "^3player didn't see kill, respawning the reinforcement" );
			// could have been killspawned
			if ( !isdefined( reinforcement ) )
				break;
			reinforcement.count++;
		}
		
		// soldier was deleted, not killed
		if ( !isDefined( spawned ) )
			continue;
		
		if ( !isdefined( reinforcement ) )
			break;
		
		if ( !isdefined( reinforcement.count ) )
			break;
		
		if ( reinforcement.count <= 0 )
			break;
		
		if ( !script_wait() )
			wait( randomFloatRange( 1, 3 ) );
	}
	
	if ( isdefined( reinforcement ) )
		reinforcement delete();
}

trigger_reinforcement_get_reinforcement_spawner()
{
	if ( isdefined( self.target ) )
	{
		reinforcement = getent( self.target, "targetname" );
		if ( isdefined( reinforcement ) && isSpawner( reinforcement ) )
			return reinforcement;
	}
	
	if ( isdefined( self.script_linkto ) )
	{
		reinforcement = self get_linked_ent();
		if ( isdefined( reinforcement ) && isSpawner( reinforcement ) )
			return reinforcement;
	}
	
	return undefined;
}

flood_spawner_scripted( spawners )
{
	assertEX( isDefined( spawners ) && spawners.size, "Script tried to flood spawn without any spawners" );

	array_thread( spawners, ::flood_spawner_init );
	array_thread( spawners, ::flood_spawner_think );
}


reincrement_count_if_deleted( spawner )
{
	spawner endon( "death" );
	
	if ( isdefined( self.script_force_count ) )
		if ( self.script_force_count )
			return;
	
	self waittill( "death" );
	if ( !isDefined( self ) )
		spawner.count++;
}


delete_start( startnum )
{
	for ( p = 0;p < 2;p++ )
	{
		switch( p )
		{
			case 0:
				aitype = "axis";
				break;

			default:
				assert( p == 1 );
				aitype = "allies";
				break;
		}

		ai = getentarray( aitype, "team" );
		for ( i = 0;i < ai.size;i++ )
		{
			if ( isdefined( ai[ i ].script_start ) )
			if ( ai[ i ].script_start == startnum )
				ai[ i ] thread delete_me();
		}
	}
}


kill_trigger( trigger )
{
	if ( !isdefined( trigger ) )
		return;

	if ( ( isdefined( trigger.targetname ) ) && ( trigger.targetname != "flood_spawner" ) )
		return;

	// temporary
	if ( level.script == "sniperescape" )
		return;

	trigger delete();
}

random_killspawner( trigger )
{
	trigger endon( "death" );
	random_killspawner = trigger.script_random_killspawner;
	waittillframeend;// wait for spawners to setup spawn_groups so we can verify ours exists

	if ( !isdefined( level.killspawn_groups[ random_killspawner ] ) )
		return;
		
//	assertex( isdefined( level.killspawn_groups[ random_killspawner ] ), "Trigger at " + trigger.origin + " has random_killspawner " + random_killspawner + ". There are no spawners with that random_killspawner value." );

	trigger waittill( "trigger" );

	cull_spawners_from_killspawner( random_killspawner );

	/*
	triggered_spawners = [];
	spawners = getspawnerarray();
	for ( i = 0 ; i < spawners.size ; i++ )
	{
		if ( ( isdefined( spawners[ i ].script_random_killspawner ) ) && ( random_killspawner == spawners[ i ].script_random_killspawner ) )
		{
			triggered_spawners = add_to_array( triggered_spawners, spawners[ i ] );
		}
	}
		
	cull_spawners_leaving_one_set( triggered_spawners );
	*/
}

cull_spawners_from_killspawner( random_killspawner )
{
	if ( !isdefined( level.killspawn_groups[ random_killspawner ] ) )
		return;

	spawn_groups = level.killspawn_groups[ random_killspawner ];
	keys = getarraykeys( spawn_groups );
	if ( keys.size <= 1 )
		return;

	save_key = random( keys );
	spawn_groups[ save_key ] = undefined;

	// spawn_groups has several arrays of spawners in it
	// the array we randomly want to keep has been removed
	// so go through each array and delete all the spawners that remain.
	foreach ( key, spawners in spawn_groups )
	{
		foreach ( index, spawner in spawners )
		{
			if ( isdefined( spawner ) )
				spawner delete();
		}
		level.killspawn_groups[ random_killspawner ][ key ] = undefined;
	}
}

killspawner( killspawnerNum )
{
	println( "killing killspawner: " + killspawnerNum );
	spawners = getspawnerarray();
	for ( i = 0 ; i < spawners.size ; i++ )
	{
		if ( ( isdefined( spawners[ i ].script_killspawner ) ) && ( killspawnerNum == spawners[ i ].script_killspawner ) )
		{
			spawners[ i ] delete();
		}
	}
}


kill_spawner( trigger )
{
	killspawnerNum = trigger.script_killspawner;

	trigger waittill( "trigger" );

	// wait twice so random killspawners can first kill selective spawners
	// then the trigger could spawn guys, then the spawners will be deleted
	waittillframeend;
	waittillframeend;



	killspawner( killspawnerNum );

	kill_trigger( trigger );
}


empty_spawner( trigger )
{
	emptyspawner = trigger.script_emptyspawner;

	trigger waittill( "trigger" );
	spawners = getspawnerarray();
	for ( i = 0;i < spawners.size;i++ )
	{
		if ( !isdefined( spawners[ i ].script_emptyspawner ) )
			continue;
		if ( emptyspawner != spawners[ i ].script_emptyspawner )
			continue;

		if ( isdefined( spawners[ i ].script_flanker ) )
			level notify( "stop_flanker_behavior" + spawners[ i ].script_flanker );
		spawners[ i ] set_count( 0 );
		spawners[ i ] notify( "emptied spawner" );
	}
	trigger notify( "deleted spawners" );
}


kill_spawnerNum( number )
{
	spawners = getspawnerarray();
	for ( i = 0;i < spawners.size;i++ )
	{
		if ( !isdefined( spawners[ i ].script_killspawner ) )
			continue;

		if ( number != spawners[ i ].script_killspawner )
			continue;

		spawners[ i ] delete();
	}
}


trigger_spawn( trigger )
{
/* 
	if ( isdefined( trigger.target ) )
	{
		spawners = getentarray( trigger.target, "targetname" );
		for ( i = 0;i < spawners.size;i++ )
		if ( ( spawners[ i ].team == "axis" ) || ( spawners[ i ].team == "allies" ) || ( spawners[ i ].team == "team3" ) )
			level thread spawn_prethink( spawners[ i ] );
	}
*/ 
}



// spawn maximum 16 grenades per team
spawn_grenade( origin, team )
{
	// delete oldest grenade
	if ( !isdefined( level.grenade_cache ) || !isdefined( level.grenade_cache[ team ] ) )
	{
		level.grenade_cache_index[ team ] = 0;
		level.grenade_cache[ team ] = [];
	}

	index = level.grenade_cache_index[ team ];
	grenade = level.grenade_cache[ team ][ index ];
	if ( isdefined( grenade ) )
		grenade delete();

	grenade = spawn( "weapon_fraggrenade", origin );
	level.grenade_cache[ team ][ index ] = grenade;

	level.grenade_cache_index[ team ] = ( index + 1 ) % 16;

	return grenade;
}

waittillDeathOrPainDeath()
{
	self endon( "death" );
	self waittill( "pain_death" );// pain that ends in death
}

drop_gear()
{
	team = self.team;
	waittillDeathOrPainDeath();

	if ( !isdefined( self ) )
		return;
	
	if ( isdefined( self.noDrop ) )
		return;

	/*
	if ( level.tire_explosion )
	{
		org = self.origin;
		eye = self geteye();

		// try to fix the delete ai during think error
		waittillframeend;

		for ( i = 0; i < 15; i++ )
		{
			thread random_tire( org, eye );
		}

		if ( isdefined( self ) )
		{
			//self hide();
			self animscripts\shared::DropAllAIWeapons();
			self delete();
		}
		return;
	}
	*/

	self.ignoreForFixedNodeSafeCheck = true;

	if ( self.grenadeAmmo <= 0 )
		return;

	level.nextGrenadeDrop -- ;
	if ( level.nextGrenadeDrop > 0 )
		return;

	level.nextGrenadeDrop = 2 + randomint( 2 );
	max = 25;
	min = 12;
	org = self.origin + ( randomint( max ) - min, randomint( max ) - min, 2 ) + ( 0, 0, 42 );
	ang = ( 0, randomint( 360 ), 90 );
	thread spawn_grenade_bag( org, ang, self.team );
}

random_tire( start, end )
{
	if ( level.cheattirecount > 90 )
		return;
	level.cheattirecount++;
    model = spawn( "script_model", ( 0, 0, 0 ) );
    model.angles = ( 0, randomint( 360 ), 0 );

    dif = randomfloat( 1 );
    model.origin = start * dif + end * ( 1 - dif );
    model setmodel( "com_junktire" );
    vel = randomvector( 15000 );
    vel = ( vel[ 0 ], vel[ 1 ], abs( vel[ 2 ] ) );
    model PhysicsLaunchClient( model.origin, vel );

    wait( randomintrange( 8, 12 ) );
		level.cheattirecount -- ;
    model delete();
}


spawn_grenade_bag( org, angles, team )
{
	grenade = spawn_grenade( org, team );
	grenade setmodel( "grenade_bag" );
	grenade.angles = angles;
	
	// grenade ammo determined by weapon settings
	
	grenade hide(); // looks bad when it pops out of nowhere
 	wait( 0.7 );
 	if ( !isdefined( grenade ) )
 		return;
	grenade show();
}

dronespawner_init()
{
	self maps\_drone::drone_init_path();
}

empty()
{
}

spawn_prethink()
{
	assert( self != level );

	level.ai_classname_in_level[ self.classname ] = true;

	 /#
	if ( getdvar( "noai", "off" ) != "off" )
	{
		// NO AI in the level plz
		self set_count( 0 );
		return;
	}
	#/

	prof_begin( "spawn_prethink" );

	if ( isdefined( self.script_difficulty ) )
	{
		switch( self.script_difficulty )
		{
			case "easy":
				if ( level.gameSkill > 1 )// if on hard or veteran
				{
					self set_count( 0 );
				}
				break;
			case "hard":
				if ( level.gameSkill < 2 )// if on easy or regular
				{
					self set_count( 0 );
				}
				break;
		}
	}


	if ( isdefined( self.script_drone ) )
		self thread dronespawner_init();

	if ( isdefined( self.script_aigroup ) )
	{
		aigroup = self.script_aigroup;
		if ( !isdefined( level._ai_group[ aigroup ] ) )
			aigroup_create( aigroup );
		self thread aigroup_spawnerthink( level._ai_group[ aigroup ] );
	}

	if ( isdefined( self.script_delete ) )
	{
		array_size = 0;
		if ( isdefined( level._ai_delete ) )
		if ( isdefined( level._ai_delete[ self.script_delete ] ) )
			array_size = level._ai_delete[ self.script_delete ].size;

		level._ai_delete[ self.script_delete ][ array_size ] = self;
	}

	if ( isdefined( self.script_health ) )
	{
		if ( self.script_health > level._max_script_health )
			level._max_script_health = self.script_health;

		array_size = 0;
		if ( isdefined( level._ai_health ) )
		if ( isdefined( level._ai_health[ self.script_health ] ) )
			array_size = level._ai_health[ self.script_health ].size;

		level._ai_health[ self.script_health ][ array_size ] = self;
	}


	if ( isdefined( self.script_deathflag ) )
	{
		// sets this flag when all the spawners or ai with this flag are gone
		thread spawner_deathflag();
	}

	if ( isdefined( self.target ) )
	{
		crawl_through_targets_to_init_flags();
	}

	if ( isdefined( self.script_spawngroup ) )
	{
		self add_to_spawngroup();
	}

	if ( isdefined( self.script_random_killspawner ) )
	{
		self add_random_killspawner_to_spawngroup();
	}

	/* 
	// all guns are setup by default now
	// portable mg42 guys
	if ( issubstr( self.classname, "mgportable" ) || issubstr( self.classname, "30cal" ) )
		thread mg42setup_gun();
	*/ 

	if ( !isdefined( self.spawn_functions ) )
	{
		self.spawn_functions = [];
	}

	for ( ;; )
	{
		prof_begin( "spawn_prethink" );
		
		spawn = undefined;
		self waittill( "spawned", spawn );

		if ( !isalive( spawn ) )
			continue;

		if ( isdefined( level.spawnerCallbackThread ) )	// this looks like pre - spawnfunc functionality, should be depricated
			self thread [[ level.spawnerCallbackThread ]]( spawn );

		if ( isdefined( self.script_delete ) )
		{
			for ( i = 0;i < level._ai_delete[ self.script_delete ].size;i++ )
			{
				if ( level._ai_delete[ self.script_delete ][ i ] != self )
					level._ai_delete[ self.script_delete ][ i ] delete();
			}
		}

		spawn.spawn_funcs = self.spawn_functions;

		// stored temporarily so spawn functions can use it if they want it
		spawn.spawner = self;

		if ( isdefined( self.targetname ) )
			spawn thread spawn_think( self.targetname );
		else
			spawn thread spawn_think();
	}
}

// Wrapper for spawn_think
// should change this so run_spawn_functions() can also work on drones
// currently assumes AI
spawn_think( targetname )
{
	assert( self != level );
	level.ai_classname_in_level[ self.classname ] = true;
	spawn_think_action( targetname );
	assert( isalive( self ) );

	self endon( "death" );

	if ( shouldnt_spawn_because_of_script_difficulty() )
	{
		self delete();
		assertEx( 0, "Should never get here" );
	}

	thread run_spawn_functions();

	self.finished_spawning = true;
	self notify( "finished spawning" );
	assert( isdefined( self.team ) );
	if ( self.team == "allies" && !isdefined( self.script_nofriendlywave ) )
		self thread friendlydeath_thread();
}

shouldnt_spawn_because_of_script_difficulty()
{
	//set .script_difficulty = "hard" to make AI not spawn in normal or easy

	if ( !isdefined( self.script_difficulty ) )
		return false;
	should_delete = false;

	switch( self.script_difficulty )
	{
		case "easy":
			if ( level.gameSkill > 1 )// if on hard or veteran
			{
				should_delete = true;
			}
			break;
		case "hard":
			if ( level.gameSkill < 2 )// if on easy or regular
			{
				should_delete = true;
			}
			break;
	}
	return should_delete;
}

run_spawn_functions()
{
	if ( !isdefined( self.spawn_funcs ) )
	{
		self.spawner = undefined;
		return;
	}

	/* 
	if ( isdefined( self.script_vehicleride ) )
	{
		// guys that ride in a vehicle down run their spawn funcs until they land.
		self endon( "death" );
		self waittill( "jumpedout" );
	}
	*/ 

	for ( i = 0; i < self.spawn_funcs.size; i++ )
	{
		func = self.spawn_funcs[ i ];
		if ( isdefined( func[ "param5" ] ) )
			thread [[ func[ "function" ] ]]( func[ "param1" ], func[ "param2" ], func[ "param3" ], func[ "param4" ], func[ "param5" ] );
		else
		if ( isdefined( func[ "param4" ] ) )
			thread [[ func[ "function" ] ]]( func[ "param1" ], func[ "param2" ], func[ "param3" ], func[ "param4" ] );
		else
		if ( isdefined( func[ "param3" ] ) )
			thread [[ func[ "function" ] ]]( func[ "param1" ], func[ "param2" ], func[ "param3" ] );
		else
		if ( isdefined( func[ "param2" ] ) )
			thread [[ func[ "function" ] ]]( func[ "param1" ], func[ "param2" ] );
		else
		if ( isdefined( func[ "param1" ] ) )
			thread [[ func[ "function" ] ]]( func[ "param1" ] );
		else
			thread [[ func[ "function" ] ]]();
	}

	if ( isdefined( self.team ) )
	{
		// vehicles have no self team
		for ( i = 0; i < level.spawn_funcs[ self.team ].size; i++ )
		{
			func = level.spawn_funcs[ self.team ][ i ];
			if ( isdefined( func[ "param5" ] ) )
				thread [[ func[ "function" ] ]]( func[ "param1" ], func[ "param2" ], func[ "param3" ], func[ "param4" ], func[ "param5" ] );
			else
			if ( isdefined( func[ "param4" ] ) )
				thread [[ func[ "function" ] ]]( func[ "param1" ], func[ "param2" ], func[ "param3" ], func[ "param4" ] );
			else
			if ( isdefined( func[ "param3" ] ) )
				thread [[ func[ "function" ] ]]( func[ "param1" ], func[ "param2" ], func[ "param3" ] );
			else
			if ( isdefined( func[ "param2" ] ) )
				thread [[ func[ "function" ] ]]( func[ "param1" ], func[ "param2" ] );
			else
			if ( isdefined( func[ "param1" ] ) )
				thread [[ func[ "function" ] ]]( func[ "param1" ] );
			else
				thread [[ func[ "function" ] ]]();
		}
	}

	 /#
		self.saved_spawn_functions = self.spawn_funcs;
	#/

	self.spawn_funcs = undefined;
	// if you want to use the .spawner as reference then you need to yank it 
	// at the top of the spawn function, for var space sake.
	self.spawner = undefined;

	 /#
	// keep them around in developer mode, for debugging
		self.spawn_funcs = self.saved_spawn_functions;
		self.saved_spawn_functions = undefined;
	#/
}

specops_think()
{
	if ( !is_specialop() )
	{
		return;
	}

	self add_damage_function( ::specops_dmg );
}

// Keeps track of who last did damage to the given AI, and awards that person with the kill
specops_dmg( dmg, attacker, dir, point, type, model_name, tag_name )
{
	if ( !IsDefined( self ) )
	{
		return;
	}

	if ( IsDefined( attacker ) && IsPlayer( attacker ) )
	{
		self.last_dmg_player = attacker;
		self.last_dmg_type = type;
	}
}

// the functions that run on death for the ai
deathFunctions()
{
	self waittill( "death", attacker, cause );
	level notify( "ai_killed", self );

	if ( !IsDefined( self ) )
	{
		return;
	}

	if ( IsDefined( attacker ) )
	{
		if ( self.team == "axis" || self.team == "team3" )
		{
			// If the attacker is a vehicle, and the player is the owner, make the player the attacker
			if ( attacker.code_classname == "script_vehicle" )
			{
				owner = attacker GetVehicleOwner();
				if ( IsDefined( owner ) )
				{
					attacker = owner;
				}
			}
			
			validAttacker = false;
			if ( isplayer( attacker ) )
				validAttacker = true;
			if ( isdefined( level.pmc_match ) && level.pmc_match )
				validAttacker = true;
			
			if ( validAttacker )
			{
				level notify( "specops_player_kill", attacker );
				attacker maps\_player_stats::register_kill( self, cause );
			}
		}
	}

	for ( i = 0; i < self.deathFuncs.size; i++ )
	{
		array = self.deathFuncs[ i ];
		switch( array[ "params" ] )
		{
			case 0:
				[[ array[ "func" ] ]]( attacker );
			break;
			case 1:
				[[ array[ "func" ] ]]( attacker, array[ "param1" ] );
			break;
			case 2:
				[[ array[ "func" ] ]]( attacker, array[ "param1" ], array[ "param2" ] );
			break;
			case 3:
				[[ array[ "func" ] ]]( attacker, array[ "param1" ], array[ "param2" ], array[ "param3" ] );
			break;
		}
	}
}

AI_damage_think()
{
	// don't end on death 
	self.damage_functions = [];

	for ( ;; )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName );

		if ( isdefined( attacker ) && isPlayer( attacker ) )
			attacker thread maps\_player_stats::register_shot_hit();

		foreach ( func in self.damage_functions )
		{
			thread [[ func ]]( damage, attacker, direction_vec, point, type, modelName, tagName );
		}

		if ( !isalive( self ) || self.delayeddeath )
			break;
	}
}


living_ai_prethink()
{
	if ( isdefined( self.script_deathflag ) )
	{
		// later this is turned into the real ddeathflag array
		level.deathflags[ self.script_deathflag ] = true;
	}

	if ( isdefined( self.target ) )
	{
		crawl_through_targets_to_init_flags();
	}
}

crawl_through_targets_to_init_flags()
{
	// need to initialize flags on the path chain if need be
	array = get_node_funcs_based_on_target();
	if ( isdefined( array ) )
	{
		targets = array[ "destination" ];
		get_func = array[ "get_target_func" ];
		for ( i = 0; i < targets.size; i++ )
		{
			crawl_target_and_init_flags( targets[ i ], get_func );
		}
	}
}

spawn_team_allies()
{
	self.useChokePoints = false;

	// Set the followmin for friendlies
	if ( isdefined( self.script_followmin ) )
		self.followmin = self.script_followmin;

	// Set the followmax for friendlies
	if ( isdefined( self.script_followmax ) )
		self.followmax = self.script_followmax;
}

spawn_team_axis()
{
	// xp
	if ( getdvar( "xp_enable", "0" ) == "1" )
		self thread maps\_rank::AI_xp_init();

	// money
	if ( getdvar( "money_enable", "0" ) == "1" )
		self thread maps\_money::AI_money_init();
		
	if ( self.type == "human" )
		self thread drop_gear();

	self add_damage_function( maps\_gameskill::auto_adjust_enemy_death_detection );
	
	if( IsDefined( self.script_combatmode ) )
	{
		self.combatMode = self.script_combatmode;
	}

	 /#
	// for combat mode testing
	if ( getdvar( "scr_force_ai_combat_mode" ) == "ambush" )
		self.combatMode = "ambush";
	else if ( getdvar( "scr_force_ai_combat_mode" ) == "ambush_nodes_only" )
		self.combatMode = "ambush_nodes_only";
	#/
}

spawn_team_team3()
{
	self spawn_team_axis();
}

spawn_team_neutral()
{
}

subclass_elite()
{
	self endon( "death" );
	self.elite = true;
	self.doorFlashChance = .5;
	if ( !isdefined( self.script_accuracy ) )
		self.baseaccuracy = 5;
	self.aggressivemode = true;

	//give flashbanks if they have appropriate weapons
	if ( self has_shotgun() )
	{
		flashAmmo = undefined;
		switch( level.gameSkill )
		{
			case 0:// easy
				flashAmmo = 0;
				break;
			case 1:// regular
				flashAmmo = 2;
				break;
			case 2:// hardened
				flashAmmo = 3;
				break;
			case 3:// veteran
				flashAmmo = 4;
				break;
		}
		if ( level.gameSkill > 0 )
		{
			self.grenadeWeapon = "flash_grenade";
			self.grenadeAmmo = flashAmmo;
		}
	}
}

subclass_regular()
{
}

pain_resistance( damage, attacker, direction_vec, point, type, modelName, tagName )
{
	self endon( "death" );
	if ( self.health <= 0 )
		return;
	if ( damage >= self.minPainDamage )
	{
		old_amount = self.minPainDamage;
		self.minPainDamage = ( old_amount * 3 );
		wait 5;
		self.minPainDamage = old_amount;
	}
}

bullet_resistance( damage, attacker, direction_vec, point, type, modelName, tagName )
{
	assertex( isdefined( self.bullet_resistance ), "bullet_resistance add_damage_function must be called on guys with self.bullet_resistance = n" );

	if ( !isdefined( self ) || self.health <= 0 )
		return;
		
	if ( ! issubstr( type, "BULLET" ) )
		return;

	heal_amount = self.bullet_resistance;

	if ( damage < self.bullet_resistance )
		heal_amount = damage;

	self.health += heal_amount;
}

spawn_think_game_skill_related()
{
	//added .doorFragChance and .doorFlashChance for throwing frag/flash grenades through doors. 
	//Set it to a value between 0 and 1; 0 for never, 1 for always if possible.
	//add script override check here if needed.
	maps\_gameskill::default_door_node_flashbang_frequency();

	maps\_gameskill::grenadeAwareness();
}


ai_lasers()
{
	if ( !isalive( self ) )
		return;		
	if ( self.health <= 1 ) // dying soon
		return;
	self LaserForceOn();
	self waittill( "death" );
	if ( !isdefined( self ) )
		return;
	self LaserForceOff();
}


spawn_think_script_inits()
{
	if ( isdefined( self.script_dontshootwhilemoving ) )
	{
		self.dontshootwhilemoving = true;
	}

	if ( isdefined( self.script_deathflag ) )
	{
		thread ai_deathflag();
	}
	
	if ( isdefined( self.script_attackeraccuracy ) )
	{
		self.attackeraccuracy = self.script_attackeraccuracy;
	}
	
	if ( isdefined( self.script_startrunning ) )
	{
		self thread start_off_running();
	}
	
	if ( isdefined( self.script_deathtime ) )
	{
		self thread deathtime();
	}

	if ( isdefined( self.script_nosurprise ) )
	{
		self disable_surprise();
	}
	
	if ( isdefined( self.script_nobloodpool ) )
	{
		self.skipBloodPool = true;
	}

	if ( isdefined( self.script_laser ) )
	{
		self thread ai_lasers();
	}
	
	if ( isdefined( self.script_danger_react ) )
	{
		time = self.script_danger_react;
		if ( time == 1 )
			time = 8;
		self enable_danger_react( time );
	}
	
	if ( isdefined( self.script_faceenemydist ) )
	{
		self.maxFaceEnemyDist = self.script_faceenemydist;
	}
	else
	{
		self.maxFaceEnemyDist = 512; // the code default!
	}

	// send all forcecolor through a centralized function
	if ( isdefined( self.script_forceColor ) )
	{
		set_force_color( self.script_forceColor );
	}
	
	if ( isdefined( self.dontDropWeapon ) )
	{
		self.dropWeapon = false;
	}

	if ( isdefined( self.script_fixednode ) )
	{
		self.fixednode = ( self.script_fixednode == 1 );
	}
	else
	{
		self.fixednode = self.team == "allies";
	}
	
	self.provideCoveringFire = self.team == "allies" && self.fixedNode;

	if ( isdefined( self.script_noteworthy ) && self.script_noteworthy == "mgpair" )
	{
		// mgpair guys get angry when their fellow buddy dies
		thread maps\_mg_penetration::create_mg_team();
	}

	//if script_moveoverride is on an AI - then dont set his goalvolume, because most likely he doesn't have a goal inside the volume
	//if script_stealth is set then don't give him a goalvolume, because we assume we want him to FIGHT in the goal volume when stealth is broken, not at spawn.
	if ( isdefined( self.script_goalvolume ) && !( ( isdefined( self.script_moveoverride ) && self.script_moveoverride == 1 ) || isdefined( self.script_stealth ) ) )
	{
		// wait until frame end so that the AI's goal has a chance to get set
		thread set_goal_volume();
	}

	// create threatbiasgroups
	if ( isdefined( self.script_threatbiasgroup ) )
		self setthreatbiasgroup( self.script_threatbiasgroup );
	else if ( self.team == "neutral" )
		self setthreatbiasgroup( "civilian" );
	else
		self setthreatbiasgroup( self.team );

	if ( isdefined( self.script_bcdialog ) )
	{
		self set_battlechatter( self.script_bcdialog );
	}

	if ( isdefined( self.script_accuracy ) )
	{
		self.baseAccuracy = self.script_accuracy;
	}

	if ( isdefined( self.script_ignoreme ) )
	{
		assertEx( self.script_ignoreme == true, "Tried to set self.script_ignoreme to false, not allowed. Just set it to undefined." );
		self.ignoreme = true;
	}

	if ( isdefined( self.script_ignore_suppression ) )
	{
		assertEx( self.script_ignore_suppression == true, "Tried to set self.script_ignore_suppresion to false, not allowed. Just set it to undefined." );
		self.ignoreSuppression = true;
	}

	if ( isdefined( self.script_ignoreall ) )
	{
		assertEx( self.script_ignoreall == true, "Tried to set self.script_ignoreme to false, not allowed. Just set it to undefined." );
		self.ignoreall = true;
		self clearenemy();
	}

	if ( isdefined( self.script_sightrange ) )
	{
		self.maxSightDistSqrd = self.script_sightrange;
	}

	// sets the favorite enemy of a spawner
	if ( isdefined( self.script_favoriteenemy ) )
	{
		if ( self.script_favoriteenemy == "player" )
		{
			self.favoriteenemy = level.player;
			level.player.targetname = "player";
		}
	}

	if ( isdefined( self.script_fightdist ) )
	{
		self.pathenemyfightdist = self.script_fightdist;
	}

	if ( isdefined( self.script_maxdist ) )
	{
		self.pathenemylookahead = self.script_maxdist;
	}

	// disable long death like dying pistol behavior
	if ( isdefined( self.script_longdeath ) )
	{
		assertex( !self.script_longdeath, "Long death is enabled by default so don't set script_longdeath to true, check ai with export " + self.export );
		self.a.disableLongDeath = true;
		assertEX( self.team != "allies", "Allies can't do long death, so why disable it on guy with export " + self.export );
	}

	if ( isdefined( self.script_diequietly ) )
	{
		assertex( self.script_diequietly, "Quiet deaths are disabled by default so don't set script_diequietly to false, check ai with export " + self.export );
		self.dieQuietly = true;
	}

	if ( isdefined( self.script_flashbangs ) )
	{
		self.grenadeWeapon = "flash_grenade";
		self.grenadeAmmo = self.script_flashbangs;
	}

	// Puts AI in pacifist mode
	if ( isdefined( self.script_pacifist ) )
	{
		self.pacifist = true;
	}

	// Set the health for special cases
	if ( isdefined( self.script_startinghealth ) )
	{
		self.health = self.script_startinghealth;
	}
	
	if ( isdefined( self.script_nodrop ) )
	{
		self.nodrop = self.script_nodrop;
	}

/#	
	if ( getdvarint( "scr_heat" ) == 1 )
		self enable_heat_behavior();
#/
}

 /#
spawn_think_debug_checks()
{
	if ( getdebugdvar( "debug_misstime" ) == "start" )
		self thread maps\_debug::debugMisstime();

	thread show_bad_path();

	if ( self.type == "human" )
		assertEx( self.pathEnemyLookAhead == 0 && self.pathEnemyFightDist == 0, "Tried to change pathenemyFightDist or pathenemyLookAhead on an AI before running spawn_failed on guy with export " + self.export );
}
#/


// Actually do the spawn_think
spawn_think_action( targetname )
{
	// handle default ai flags for ent_flag * functions
	self thread AI_damage_think();
	self thread tanksquish();
	self thread death_achievements();
	self thread specops_think();

	//dont call this if you dont want AI guy to glow when the player uses thermal vision. Ai only glow when player is in thermal.
	if( !isdefined( level.ai_dont_glow_in_thermal ) )
		self ThermalDrawEnable();

	// ai get their values from spawners and theres no need to have this value on ai
	self.spawner_number = undefined;

	if ( !isdefined( self.unique_id ) )
	{
		set_ai_number();
	}

	// functions called on death
	if ( !isdefined( self.deathFuncs ) )
	{
		self.deathFuncs = [];
	}

	self thread deathFunctions();

	level thread maps\_friendlyfire::friendly_fire_think( self );

	self.walkdist = 16;

	// which eq triggers am I touching?
	//thread setup_ai_eq_triggers();

	 /# spawn_think_debug_checks(); #/

	init_reset_AI();

	spawn_think_game_skill_related();

	spawn_think_script_inits();

	[[ level.team_specific_spawn_functions[ self.team ] ]]();

	// special function for this AI's subclass, juggernaut, etc
	assertex( isdefined( level.subclass_spawn_functions[ self.subclass ] ), "subclass spawn function not defined for '" + self.subclass + "'" );
	thread [[ level.subclass_spawn_functions[ self.subclass ] ]]();

	self thread maps\_damagefeedback::monitorDamage();

	self common_scripts\_dynamic_world::ai_init();

	set_goal_height_from_settings();
	
	//
	// lots of returns from this point on. spawn_think_action may early out at any point.
	//

	// The AI will spawn and attack the player
	if ( isdefined( self.script_playerseek ) )
	{
		self setgoalentity( level.player );
		return;
	}

	// the AI will be linked into the stealth system
	if ( isdefined( self.script_stealth ) )
	{
		if ( isdefined( self.script_stealth_function ) )
		{
			assertex( isdefined( level.stealth_default_func[ self.script_stealth_function ] ), "spawner at " + self.origin + " has .script_stealth_function set to key of '" + self.script_stealth_function + "' but there is no reference for that key. Use stealth_set_default_stealth_function( key, func ) to set the key to a proper stealth function" );
			func = level.stealth_default_func[ self.script_stealth_function ];
			self thread [[ func ]]();
		}
		else
			self thread [[ level.global_callbacks[ "_spawner_stealth_default" ] ]]();
	}

	if ( isdefined( self.script_idleanim ) )
	{
		self thread [[ level.global_callbacks[ "_idle_call_idle_func" ] ]]();
		return;
	}

	if ( isdefined( self.script_idlereach ) && !isdefined( self.script_moveoverride ) )
	{
		self thread [[ level.global_callbacks[ "_idle_call_idle_func" ] ]]();
	}

	// The AI will spawn and follow a patrol
	if ( isdefined( self.script_patroller ) && !isdefined( self.script_moveoverride ) )
	{
		self thread maps\_patrol::patrol();
		return;
	}

	// The AI will spawn and use his .radius as a goalradius, and his goalradius will get smaller over time.
	if ( isdefined( self.script_delayed_playerseek ) )
	{
		if ( !isdefined( self.script_radius ) )
			self.goalradius = 800;

		self setgoalentity( level.player );
		level thread delayed_player_seek_think( self );
		return;
	}

	if ( isdefined( self.used_an_mg42 ) )// This AI was called upon to use an MG42 so he's not going to run to his node.
	{
		return;
	}

	if ( ( isdefined( self.script_moveoverride ) && self.script_moveoverride == 1 ) )
	{
		set_goal_from_settings();
		self setgoalpos( self.origin );
		return;
	}

	assertEx( self.goalradius == 4, "Changed the goalradius on guy with export " + self.export + " without waiting for spawn_failed. Note that this change will NOT show up by putting a breakpoint on the actors goalradius field because breakpoints don't properly handle the first frame an actor exists." );
	set_goal_from_settings();


	// The AI will run to a target node and use the node's .radius as his goalradius.
	// If script_seekgoal is set, then he will run to his node with a goalradius of 0, then set his goal radius
	//    to the node's radius.
	if ( isdefined( self.target ) )
		self thread go_to_node();
}


// this is called during init (spawn_think_action) and reset (scrub_guy)
init_reset_AI()
{
	self eqoff();

	set_default_pathenemy_settings();

	// Gives AI grenades
	if ( isdefined( self.script_grenades ) )
	{
		self.grenadeAmmo = self.script_grenades;
	}
	else
	{
		self.grenadeAmmo = 3;
	}
	
	if ( isdefined( self.primaryweapon ) )
		self.noAttackerAccuracyMod = self animscripts\combat_utility::isSniper();
		
	if ( !is_specialop() )
		self.neverSprintForVariation = true;
}


// reset this guy to default spec
scrub_guy()
{
	if ( self.team == "neutral" )
		self setthreatbiasgroup( "civilian" );
	else
		self setthreatbiasgroup( self.team );

	init_reset_AI();

	// Set the accuracy for the spawner
	self.baseAccuracy = 1;
	maps\_gameskill::grenadeAwareness();
	self clear_force_color();

	self.interval = 96;
	self.disableArrivals = undefined;
	self.ignoreme = false;
	self.threatbias = 0;
	self.pacifist = false;
	self.pacifistWait = 20;
	self.IgnoreRandomBulletDamage = false;
	self.pushable = true;
// 	self.favoriteenemy = undefined;
	self.accuracystationarymod = 1;
	self.allowdeath = false;
	self.anglelerprate = 540;
	self.badplaceawareness = 0.75;
	self.chainfallback = 0;
	self.dontavoidplayer = 0;
	self.drawoncompass = 1;
	self.dropweapon = 1;
	self.goalradius = level.default_goalradius;
	self.goalheight = level.default_goalheight;
	self.ignoresuppression = 0;
	self pushplayer( false );

	if ( isdefined( self.magic_bullet_shield ) && self.magic_bullet_shield )
	{
		stop_magic_bullet_shield();
	}

	self disable_replace_on_death();
	self.maxsightdistsqrd = 8192 * 8192;
	self.script_forceGrenade = 0;
	self.walkdist = 16;
	self unmake_hero();
	self.pushable = true;
	animscripts\init::set_anim_playback_rate();

	// allies use fixednode by default
	self.fixednode = self.team == "allies";
}

delayed_player_seek_think( spawned )
{
	spawned endon( "death" );
	while ( isalive( spawned ) )
	{
		if ( spawned.goalradius > 200 )
			spawned.goalradius -= 200;

		wait 6;
	}
}

flag_turret_for_use( ai )
{
	self endon( "death" );
	if ( !self.flagged_for_use )
	{
		ai.used_an_mg42 = true;
		self.flagged_for_use = true;
		ai waittill( "death" );
		self.flagged_for_use = false;
		self notify( "get new user" );
		return;
	}

	println( "Turret was already flagged for use" );
}

set_goal_volume()
{
	self endon( "death" );
	waittillframeend;

	volume = level.goalVolumes[ self.script_goalvolume ];
	if ( !isdefined( volume ) )
		return;

	if ( isdefined( volume.target ) )
	{
		node 	 = getnode( volume.target, "targetname" );
		ent 	 = getent( volume.target, "targetname" );
		struct 	 = getstruct( volume.target, "targetname" );
		pos 	 = undefined;

		if ( isdefined( node ) )
		{
			pos = node;
			self setgoalnode( pos );
		}
		else
		if ( isdefined( ent ) )
		{
			pos = ent;
			self setgoalpos( pos.origin );
		}
		else
		if ( isdefined( struct ) )
		{
			pos = struct;
			self setgoalpos( pos.origin );
		}

		if ( isdefined( pos.radius ) && pos.radius != 0 )
			self.goalradius = pos.radius;
		if ( isdefined( pos.goalheight ) && pos.goalheight != 0 )
			self.goalheight = pos.goalheight;
	}

	if ( isdefined( self.target ) )
	{
		self setgoalvolume( volume );
	}
	else
	{
		self setgoalvolumeauto( volume );
	}
}

get_target_ents( target )
{
	return getentarray( target, "targetname" );
}

get_target_nodes( target )
{
	return getnodearray( target, "targetname" );
}

get_target_structs( target )
{
	return getstructarray( target, "targetname" );
}

node_has_radius( node )
{
	return isdefined( node.radius ) && node.radius != 0;
}

go_to_origin( node, optional_arrived_at_node_func )
{
	self go_to_node( node, "origin", optional_arrived_at_node_func );
}

go_to_struct( node, optional_arrived_at_node_func )
{
	self go_to_node( node, "struct", optional_arrived_at_node_func );
}

go_to_node( node, goal_type, optional_arrived_at_node_func, require_player_dist )
{
	if ( isdefined( self.used_an_mg42 ) )// This AI was called upon to use an MG42 so he's not going to run to his node.
		return;

	array = get_node_funcs_based_on_target( node, goal_type );
	if ( !isdefined( array ) )
	{
		self notify( "reached_path_end" );
		// no goal type
		return;
	}

	if ( !isdefined( optional_arrived_at_node_func ) )
	{
		optional_arrived_at_node_func = ::empty_arrived_func;
	}

	go_to_node_using_funcs( array[ "destination" ], array[ "get_target_func" ], array[ "set_goal_func_quits" ], optional_arrived_at_node_func, require_player_dist );
}

empty_arrived_func( node )
{
}

get_least_used_from_array( array )
{
	assertex( array.size > 0, "Somehow array had zero entrees" );
	if ( array.size == 1 )
		return array[ 0 ];

	targetname = array[ 0 ].targetname;
	if ( !isdefined( level.go_to_node_arrays[ targetname ] ) )
	{
		level.go_to_node_arrays[ targetname ] = array;
	}

	array = level.go_to_node_arrays[ targetname ];

	// return the node at the front of the array and move it to the back of the array.
	first = array[ 0 ];
	newarray = [];
	for ( i = 0; i < array.size - 1; i++ )
	{
		newarray[ i ] = array[ i + 1 ];
	}
	newarray[ array.size - 1 ] = array[ 0 ];
	level.go_to_node_arrays[ targetname ] = newarray;

	return first;
}

go_to_node_using_funcs( node, get_target_func, set_goal_func_quits, optional_arrived_at_node_func, require_player_dist )
{

	self notify( "stop_going_to_node" );// kills the last call to go_to_node
	// AI is moving to a goal node
	self endon( "stop_going_to_node" );
	self endon( "death" );

	for ( ;; )
	{
		// node should always be an array at this point, so lets get just 1 out of the array
		node = get_least_used_from_array( node );
		
		player_wait_dist = require_player_dist;
		if( isdefined( node.script_requires_player ) )
		{
			if( node.script_requires_player > 1 )
				player_wait_dist = node.script_requires_player;
		
			node.script_requires_player = false;
		}

		if ( node_has_radius( node ) )
			self.goalradius = node.radius;
		else
			self.goalradius = level.default_goalradius;

		if ( isdefined( node.height ) )
			self.goalheight = node.height;
		else
			self.goalheight = level.default_goalheight;

		 
		[[ set_goal_func_quits ]]( node );

		//actually see if we're at our goal..._stealth might be tricking us
		if ( self ent_flag_exist( "_stealth_override_goalpos" ) )
		{
			while ( 1 )
			{
				self waittill( "goal" );
				if ( !( self ent_flag( "_stealth_override_goalpos" ) ) )
					break;
				self ent_flag_waitopen( "_stealth_override_goalpos" );
			}
		}
		else
			self waittill( "goal" );

		node notify( "trigger", self );

		[[ optional_arrived_at_node_func ]]( node );

		if ( isdefined( node.script_flag_set ) )
		{
			flag_set( node.script_flag_set );
		}

		if ( isdefined( node.script_ent_flag_set ) )
		{
			self ent_flag_set( node.script_ent_flag_set );
		}

		if ( isdefined( node.script_flag_clear ) )
		{
			flag_clear( node.script_flag_clear );
		}

		if ( targets_and_uses_turret( node ) )
			return true;
		
		node script_delay();
		
		if ( isdefined( node.script_flag_wait ) )
			flag_wait( node.script_flag_wait );
			
		if ( isdefined( node.script_delay_post ) )
			wait node.script_delay_post;
					
		while ( isdefined( node.script_requires_player ) )
		{
			node.script_requires_player = false;
			if ( self go_to_node_wait_for_player( node, get_target_func, player_wait_dist ) )
			{
				node.script_requires_player = true;
				node notify( "script_requires_player" );
				break;
			}
			wait 0.1;
		}

		if ( !isdefined( node.target ) )
			break;

		nextNode_array = [[ get_target_func ]]( node.target );
		if ( !nextNode_array.size )
			break;

		node = nextNode_array;
	}

	self notify( "reached_path_end" );
	if ( isDefined( self.script_forcegoal ) )
		return;
		
	if ( isdefined( self getGoalVolume() ) )
		self setGoalVolumeAuto( self getGoalVolume() );
	else
		self.goalradius = level.default_goalradius;
}

go_to_node_wait_for_player( node, get_target_func, dist )
{
	//are any of the players closer to the node than we are?
	foreach ( player in level.players )
	{
		if ( distancesquared( player.origin, node.origin ) < distancesquared( self.origin, node.origin ) )
			return true;
	}

	//are any of the player ahead of us based on our forward angle?
	vec = anglestoforward( self.angles );
	if ( isdefined( node.target ) )
	{
		temp = [[ get_target_func ]]( node.target );

		//if we only have one node then we can get the forward from that one to us
		if ( temp.size == 1 )
			vec = vectornormalize( temp[ 0 ].origin - node.origin );
		//otherwise since we dont know which one we're taking yet the next best thing to do is to take the forward of the node we're on
		else if ( isdefined( node.angles ) )
			vec = anglestoforward( node.angles );
	}
	//also if there is no target since we're at the end of the chain, the next best thing to do is to take the forward of the node we're on
	else if ( isdefined( node.angles ) )
		vec = anglestoforward( node.angles );

	vec2 = [];
	foreach ( player in level.players )
	{
		vec2[ vec2.size ] = vectornormalize( ( player.origin - self.origin ) );
	}

	//i just created a vector which is in the direction i want to
	//go, lets see if the player is closer to our goal than we are			
	foreach ( value in vec2 )
	{
		if ( vectordot( vec, value ) > 0 )
			return true;
	}

	//ok so that just checked if he was a mile away but more towards the target
	//than us...but we dont want him to be right on top of us before we start moving
	//so lets also do a distance check to see if he's close behind
	dist2rd = dist * dist;
	foreach ( player in level.players )
	{
		if ( distancesquared( player.origin, self.origin ) < dist2rd )
			return true;
	}

	//ok guess he's not here yet	
	return false;
}

go_to_node_set_goal_ent( ent )
{
	if ( ent.classname == "info_volume" )
	{
		self setgoalvolumeauto( ent );
		self notify( "go_to_node_new_goal" );
		return;
	}
	
	self go_to_node_set_goal_pos( ent );
}

go_to_node_set_goal_pos( ent )
{
	self set_goal_ent( ent );//this change by Mo should allow stealth and dynamic run speed to use structs for follow_path. reverted because of GI build
	//self set_goal_pos( ent.origin );
	self notify( "go_to_node_new_goal" );
}

go_to_node_set_goal_node( node )
{
	self set_goal_node( node );
	self notify( "go_to_node_new_goal" );
}

targets_and_uses_turret( node )
{
	if ( !isdefined( node.target ) )
		return false;

	turrets = getentarray( node.target, "targetname" );
	if ( !turrets.size )
		return false;

	turret = turrets[ 0 ];
	if ( turret.classname != "misc_turret" )
		return false;

	thread use_a_turret( turret );
	return true;
}

remove_crawled( ent )
{
	waittillframeend;
	if ( isdefined( ent ) )
		ent.crawled = undefined;
}

crawl_target_and_init_flags( ent, get_func )
{
	oldsize = 0;
	targets = [];
	index = 0;
	for ( ;; )
	{
		if ( !isdefined( ent.crawled ) )
		{
			ent.crawled = true;
			level thread remove_crawled( ent );

			if ( isdefined( ent.script_flag_set ) )
			{
				if ( !isdefined( level.flag[ ent.script_flag_set ] ) )
				{
					flag_init( ent.script_flag_set );
				}
			}

			if ( isdefined( ent.script_flag_wait ) )
			{
				if ( !isdefined( level.flag[ ent.script_flag_wait ] ) )
				{
					flag_init( ent.script_flag_wait );
				}
			}

			if ( isdefined( ent.script_flag_clear ) )
			{
				if ( !isdefined( level.flag[ ent.script_flag_clear ] ) )
				{
					flag_init( ent.script_flag_clear );
				}
			}

			if ( isdefined( ent.target ) )
			{
				new_targets = [[ get_func ]]( ent.target );
				targets = add_to_array( targets, new_targets );
			}
		}

		index++;
		if ( index >= targets.size )
			break;

		ent = targets[ index ];
	}
}

get_node_funcs_based_on_target( node, goal_type )
{
	// figure out if its a node or script origin and set the goal_type index based on that.

	// true is for script_origins, false is for nodes
	get_target_func[ "entity" ] = ::get_target_ents;
	get_target_func[ "node" ] = ::get_target_nodes;
	get_target_func[ "struct" ] = ::get_target_structs;

	set_goal_func_quits[ "entity" ] = ::go_to_node_set_goal_ent;
	set_goal_func_quits[ "struct" ] = ::go_to_node_set_goal_pos;
	set_goal_func_quits[ "node" ] = ::go_to_node_set_goal_node;

	// if you pass a node, we'll assume you actually passed a node. We can make it find out if its a script origin later if we need that functionality.
	if ( !isdefined( goal_type ) )
		goal_type = "node";

	array = [];
	if ( isdefined( node ) )
	{
		array[ "destination" ][ 0 ] = node;
	}
	else
	{
		// if you dont pass a node then we need to figure out what type of target it is
		node = getentarray( self.target, "targetname" );

		if ( node.size > 0 )
		{
			goal_type = "entity";
		}

		if ( goal_type == "node" )
		{
			node = getnodearray( self.target, "targetname" );
			if ( !node.size )
			{
				node = getstructarray( self.target, "targetname" );
				if ( !node.size )
				{
					// Targetting neither
					return;
				}
				goal_type = "struct";
			}
		}

		array[ "destination" ] = node;
	}

	array[ "get_target_func" ] = get_target_func[ goal_type ];
	array[ "set_goal_func_quits" ] = set_goal_func_quits[ goal_type ];
	return array;
}


set_goal_height_from_settings()
{
	if ( isdefined( self.script_goalheight ) )
		self.goalheight = self.script_goalheight;
	else
		self.goalheight = level.default_goalheight;
}


set_goal_from_settings( node )
{
	// sets goal radius
	
	if ( isdefined( self.script_radius ) )
	{
		// use the override from radiant
		self.goalradius = self.script_radius;
		return;
	}

	if ( isDefined( self.script_forcegoal ) )
	{
		if ( isdefined( node ) && isdefined( node.radius ) )
		{
			// use the node's radius
			self.goalradius = node.radius;
			return;
		}
	}

	// otherwise use the script default
	if ( !isdefined( self getGoalVolume() ) )
	{
		if ( self.type == "civilian" )
			self.goalradius = 128;
		else
			self.goalradius = level.default_goalradius;
	}
}

autoTarget( targets )
{
	for ( ;; )
	{
		user = self getturretowner();
		if ( !isalive( user ) )
		{
			wait( 1.5 );
			continue;
		}

		if ( !isdefined( user.enemy ) )
		{
			self settargetentity( random( targets ) );
			self notify( "startfiring" );
			self startFiring();
		}

		wait( 2 + randomfloat( 1 ) );
	}
}

manualTarget( targets )
{
	for ( ;; )
	{
		self settargetentity( random( targets ) );
		self notify( "startfiring" );
		self startFiring();

		wait( 2 + randomfloat( 1 ) );
	}
}

// this is called from two places w / generally identical code... maybe larger scale cleanup is called for.
use_a_turret( turret )
{
	if ( self isBadGuy() && self.health == 150 )
	{
		self.health = 100;// mg42 operators aren't going to do long death
		self.a.disableLongDeath = true;
	}

// 	thread maps\_mg_penetration::gunner_think( turret );

	self useturret( turret );// dude should be near the mg42
// 	turret setmode( "auto_ai" );// auto, auto_ai, manual
// 	turret settargetentity( level.player );
// 	turret setmode( "manual" );// auto, auto_ai, manual
	if ( ( isdefined( turret.target ) ) && ( turret.target != turret.targetname ) )
	{
		ents = getentarray( turret.target, "targetname" );
		targets = [];
		for ( i = 0; i < ents.size;i++ )
		{
			if ( ents[ i ].classname == "script_origin" )
				targets[ targets.size ] = ents[ i ];
		}

		if ( isdefined( turret.script_autotarget ) )
		{
			turret thread autoTarget( targets );
		}
		else
		if ( isdefined( turret.script_manualtarget ) )
		{
			turret setmode( "manual_ai" );
			turret thread manualTarget( targets );
		}
		else
		if ( targets.size > 0 )
		{
			if ( targets.size == 1 )
			{
				turret.manual_target = targets[ 0 ];
				turret settargetentity( targets[ 0 ] );
// 				turret setmode( "manual_ai" );// auto, auto_ai, manual
				self thread maps\_mgturret::manual_think( turret );
// 				if ( isdefined( self.script_mg42auto ) )
// 					println( "AI at origin ", self.origin, " has script_mg42auto" );
			}
			else
			{
				turret thread maps\_mgturret::mg42_suppressionFire( targets );
			}
		}
	}

	self thread maps\_mgturret::mg42_firing( turret );
	turret notify( "startfiring" );
}

fallback_spawner_think( num, node )
{
	self endon( "death" );
	level.current_fallbackers[ num ] += self.count;
	firstspawn = true;
	while ( self.count > 0 )
	{
		self waittill( "spawned", spawn );
		if ( firstspawn )
		{
			if ( getDvar("fallback", "0") == "1" )
				println( "^a First spawned: ", num );
			level notify( ( "fallback_firstspawn" + num ) );
			firstspawn = false;
		}

		waitframe();// Wait until he does all his usual spawned logic so he will run to his node
		if ( maps\_utility::spawn_failed( spawn ) )
		{
			level notify( ( "fallbacker_died" + num ) );
			level.current_fallbackers[ num ] -- ;
			continue;
		}

		spawn thread fallback_ai_think( num, node, "is spawner" );
	}

// 	level notify( ( "fallbacker_died" + num ) );
}

fallback_ai_think_death( ai, num )
{
	ai waittill( "death" );
	level.current_fallbackers[ num ] -- ;

	level notify( ( "fallbacker_died" + num ) );
}

fallback_ai_think( num, node, spawner )
{
	if ( ( !isdefined( self.fallback ) ) || ( !isdefined( self.fallback[ num ] ) ) )
		self.fallback[ num ] = true;
	else
		return;

	self.script_fallback = num;
	if ( !isdefined( spawner ) )
		level.current_fallbackers[ num ]++;

	if ( ( isdefined( node ) ) && ( level.fallback_initiated[ num ] ) )
	{
		self thread fallback_ai( num, node );
		/* 
		self notify( "stop_going_to_node" );
		self setgoalnode( node );
		if ( isdefined( node.radius ) )
			self.goalradius = node.radius;
		*/ 
	}

	level thread fallback_ai_think_death( self, num );
}

fallback_death( ai, num )
{
	ai waittill( "death" );
	level notify( ( "fallback_reached_goal" + num ) );
// 	ai notify( "fallback_notify" );
}

fallback_goal()
{
	self waittill( "goal" );
	self.ignoresuppression = false;

	self notify( "fallback_notify" );
	self notify( "stop_coverprint" );
}

fallback_ai( num, node )
{
	self notify( "stop_going_to_node" );

	self stopuseturret();
	self.ignoresuppression = true;
	self setgoalnode( node );
	if ( node.radius != 0 )
		self.goalradius = node.radius;

	self endon( "death" );
	level thread fallback_death( self, num );
	self thread fallback_goal();

	if ( getDvar("fallback", "0") == "1" )
		self thread coverprint( node.origin );

	self waittill( "fallback_notify" );
	level notify( ( "fallback_reached_goal" + num ) );
}

coverprint( org )
{
	self endon( "fallback_notify" );
	self endon( "stop_coverprint" );

	while ( 1 )
	{
		line( self.origin + ( 0, 0, 35 ), org, ( 0.2, 0.5, 0.8 ), 0.5 );
		print3d( ( self.origin + ( 0, 0, 70 ) ), "Falling Back", ( 0.98, 0.4, 0.26 ), 0.85 );
		waitframe();
	}
}


newfallback_overmind( num, group )
{
	fallback_nodes = undefined;
	nodes = getallnodes();
	for ( i = 0;i < nodes.size;i++ )
	{
		if ( ( isdefined( nodes[ i ].script_fallback ) ) && ( nodes[ i ].script_fallback == num ) )
			fallback_nodes = add_to_array( fallback_nodes, nodes[ i ] );
	}

	if ( !isdefined( fallback_nodes ) )
		return;

	level.current_fallbackers[ num ] = 0;
	level.spawner_fallbackers[ num ] = 0;
	level.fallback_initiated[ num ] = false;

	spawners = getspawnerarray();
	for ( i = 0;i < spawners.size;i++ )
	{
		if ( ( isdefined( spawners[ i ].script_fallback ) ) && ( spawners[ i ].script_fallback == num ) )
		{
			if ( spawners[ i ].count > 0 )
			{
				spawners[ i ] thread fallback_spawner_think( num, fallback_nodes[ randomint( fallback_nodes.size ) ] );
				level.spawner_fallbackers[ num ]++;
			}
		}
	}

	ai = getaiarray();
	for ( i = 0;i < ai.size;i++ )
	{
		if ( ( isdefined( ai[ i ].script_fallback ) ) && ( ai[ i ].script_fallback == num ) )
			ai[ i ] thread fallback_ai_think( num );
	}

	if ( ( !level.current_fallbackers[ num ] ) && ( !level.spawner_fallbackers[ num ] ) )
		return;

	spawners = undefined;
	ai = undefined;

	thread fallback_wait( num, group );
	level waittill( ( "fallbacker_trigger" + num ) );
	if ( getDvar("fallback", "0") == "1" )
		println( "^a fallback trigger hit: ", num );
	level.fallback_initiated[ num ] = true;

	fallback_ai = undefined;
	ai = getaiarray();
	for ( i = 0;i < ai.size;i++ )
	{
		if ( ( ( isdefined( ai[ i ].script_fallback ) ) && ( ai[ i ].script_fallback == num ) ) ||
			( ( isdefined( ai[ i ].script_fallback_group ) ) && ( isdefined( group ) ) && ( ai[ i ].script_fallback_group == group ) ) )
			fallback_ai = add_to_array( fallback_ai, ai[ i ] );
	}
	ai = undefined;

	if ( !isdefined( fallback_ai ) )
		return;

	first_half = fallback_ai.size * 0.4;
	first_half = int( first_half );

	level notify( "fallback initiated " + num );

	fallback_text( fallback_ai, 0, first_half );
	for ( i = 0;i < first_half;i++ )
		fallback_ai[ i ] thread fallback_ai( num, fallback_nodes[ randomint( fallback_nodes.size ) ] );

	for ( i = 0;i < first_half;i++ )
		level waittill( ( "fallback_reached_goal" + num ) );

	fallback_text( fallback_ai, first_half, fallback_ai.size );

	for ( i = first_half;i < fallback_ai.size;i++ )
	{
		if ( isalive( fallback_ai[ i ] ) )
			fallback_ai[ i ] thread fallback_ai( num, fallback_nodes[ randomint( fallback_nodes.size ) ] );
	}
}

fallback_text( fallbackers, start, end )
{
	if ( gettime() <= level._nextcoverprint )
		return;

	for ( i = start;i < end;i++ )
	{
		if ( !isalive( fallbackers[ i ] ) )
			continue;

		level._nextcoverprint = gettime() + 2500 + randomint( 2000 );
		total = fallbackers.size;
		temp = int( total * 0.4 );

		if ( randomint( 100 ) > 50 )
		{
			if ( total - temp > 1 )
			{
				if ( randomint( 100 ) > 66 )
					msg = "dawnville_defensive_german_1";
				else
				if ( randomint( 100 ) > 66 )
					msg = "dawnville_defensive_german_2";
				else
					msg = "dawnville_defensive_german_3";
			}
			else
			{
				if ( randomint( 100 ) > 66 )
					msg = "dawnville_defensive_german_4";
				else
				if ( randomint( 100 ) > 66 )
					msg = "dawnville_defensive_german_5";
				else
					msg = "dawnville_defensive_german_1";
			}
		}
		else
		{

			if ( temp > 1 )
			{
				if ( randomint( 100 ) > 66 )
					msg = "dawnville_defensive_german_2";
				else
				if ( randomint( 100 ) > 66 )
					msg = "dawnville_defensive_german_3";
				else
					msg = "dawnville_defensive_german_4";
			}
			else
			{
				if ( randomint( 100 ) > 66 )
					msg = "dawnville_defensive_german_5";
				else
				if ( randomint( 100 ) > 66 )
					msg = "dawnville_defensive_german_1";
				else
					msg = "dawnville_defensive_german_2";
			}
		}

		fallbackers[ i ] animscripts\face::SaySpecificDialogue( undefined, msg, 1.0 );

		return;
	}
}

fallback_wait( num, group )
{
	level endon( ( "fallbacker_trigger" + num ) );
	if ( getDvar("fallback", "0") == "1" )
		println( "^a Fallback wait: ", num );
	for ( i = 0;i < level.spawner_fallbackers[ num ];i++ )
	{
		if ( getDvar("fallback", "0") == "1" )
			println( "^a Waiting for spawners to be hit: ", num, " i: ", i );
		level waittill( ( "fallback_firstspawn" + num ) );
	}
	if ( getDvar("fallback", "0") == "1" )
		println( "^a Waiting for AI to die, fall backers for group ", num, " is ", level.current_fallbackers[ num ] );

// 	total_fallbackers = 0;
	ai = getaiarray();
	for ( i = 0;i < ai.size;i++ )
	{
		if ( ( ( isdefined( ai[ i ].script_fallback ) ) && ( ai[ i ].script_fallback == num ) ) ||
			( ( isdefined( ai[ i ].script_fallback_group ) ) && ( isdefined( group ) ) && ( ai[ i ].script_fallback_group == group ) ) )
			ai[ i ] thread fallback_ai_think( num );
	}
	ai = undefined;

// 	if ( !total_fallbackers )
// 		return;

	max_fallbackers = level.current_fallbackers[ num ];

	deadfallbackers = 0;
	while ( level.current_fallbackers[ num ] > max_fallbackers * 0.5 )
	{
		if ( getDvar("fallback", "0") == "1" )
			println( "^cwaiting for " + level.current_fallbackers[ num ] + " to be less than " + ( max_fallbackers * 0.5 ) );
		level waittill( ( "fallbacker_died" + num ) );
		deadfallbackers++;
	}

	println( deadfallbackers, " fallbackers have died, time to retreat" );
	level notify( ( "fallbacker_trigger" + num ) );
}

fallback_think( trigger )// for fallback trigger
{
	if ( ( !isdefined( level.fallback ) ) || ( !isdefined( level.fallback[ trigger.script_fallback ] ) ) )
		level thread newfallback_overmind( trigger.script_fallback, trigger.script_fallback_group );

	trigger waittill( "trigger" );
	level notify( ( "fallbacker_trigger" + trigger.script_fallback ) );
// 	level notify( ( "fallback" + trigger.script_fallback ) );

	// Maybe throw in a thing to kill triggers with the same fallback? God my hands are cold.
	kill_trigger( trigger );
}

arrive( node )
{
	self waittill( "goal" );

	if ( node.radius != 0 )
		self.goalradius = node.radius;
	else
		self.goalradius = level.default_goalradius;
}

fallback_coverprint()
{
// 	self endon( "death" );
	self endon( "fallback" );
	self endon( "fallback_clear_goal" );
	self endon( "fallback_clear_death" );
	while ( 1 )
	{
		if ( isdefined( self.coverpoint ) )
			line( self.origin + ( 0, 0, 35 ), self.coverpoint.origin, ( 0.2, 0.5, 0.8 ), 0.5 );
		print3d( ( self.origin + ( 0, 0, 70 ) ), "Covering", ( 0.98, 0.4, 0.26 ), 0.85 );
		waitframe();
	}
}

fallback_print()
{
// 	self endon( "death" );
	self endon( "fallback_clear_goal" );
	self endon( "fallback_clear_death" );
	while ( 1 )
	{
		if ( isdefined( self.coverpoint ) )
			line( self.origin + ( 0, 0, 35 ), self.coverpoint.origin, ( 0.2, 0.5, 0.8 ), 0.5 );
		print3d( ( self.origin + ( 0, 0, 70 ) ), "Falling Back", ( 0.98, 0.4, 0.26 ), 0.85 );
		waitframe();
	}
}

fallback()
{
// 	self endon( "death" );
	dest = getnode( self.target, "targetname" );
	self.coverpoint = dest;

	self setgoalnode( dest );
	if ( isdefined( self.script_seekgoal ) )
		self thread arrive( dest );
	else
	{
		if ( dest.radius != 0 )
			self.goalradius = dest.radius;
		else
			self.goalradius = level.default_goalradius;
	}

	while ( 1 )
	{
		self waittill( "fallback" );
		self.interval = 20;
		level thread fallback_death( self );

		if ( getDvar("fallback", "0") == "1" )
			self thread fallback_print();

		if ( isdefined( dest.target ) )
		{
			dest = getnode( dest.target, "targetname" );
			self.coverpoint = dest;
			self setgoalnode( dest );
			self thread fallback_goal();
			if ( dest.radius != 0 )
				self.goalradius = dest.radius;
		}
		else
		{
			level notify( ( "fallback_arrived" + self.script_fallback ) );
			return;
		}
	}
}


delete_me()
{
	waitframe();
	self delete();
}

vlength( vec1, vec2 )
{
	v0 = vec1[ 0 ] - vec2[ 0 ];
	v1 = vec1[ 1 ] - vec2[ 1 ];
	v2 = vec1[ 2 ] - vec2[ 2 ];

	v0 = v0 * v0;
	v1 = v1 * v1;
	v2 = v2 * v2;

	veclength = v0 + v1 + v2;

	return veclength;
}

specialCheck( name )
{
	for ( ;; )
	{
		assertEX( getentarray( name, "targetname" ).size, "Friendly wave trigger that targets " + name + " doesnt target any spawners" );
		wait( 0.05 );
	}
}

friendly_wave( trigger )
{
// 	thread specialCheck( trigger.target );

	if ( !isdefined( level.friendly_wave_active ) )
		thread friendly_wave_masterthread();
 /#
	if ( trigger.targetname == "friendly_wave" )
	{
		assert = false;
		targs = getentarray( trigger.target, "targetname" );
		for ( i = 0;i < targs.size;i++ )
		{
			if ( isdefined( targs[ i ].classname[ 7 ] ) )
			if ( targs[ i ].classname[ 7 ] != "l" )
			{
				println( "Friendyl_wave spawner at ", targs[ i ].origin, " is not an ally" );
				assert = true;
			}
		}
		if ( assert )
			error( "Look above" );
	}
#/
	while ( 1 )
	{
		trigger waittill( "trigger" );
		level notify( "friendly_died" );
		if ( trigger.targetname == "friendly_wave" )
			level.friendly_wave_trigger = trigger;
		else
		{
			level.friendly_wave_trigger = undefined;
			println( "friendly wave OFF" );
		}

		wait( 1 );
	}
}


set_spawncount( count )
{
	if ( !isdefined( self.target ) )
		return;

	spawners = getentarray( self.target, "targetname" );
	for ( i = 0;i < spawners.size;i++ )
		spawners[ i ] set_count( count );
}

friendlydeath_thread()
{
	if ( !isdefined( level.totalfriends ) )
		level.totalfriends = 0;
	level.totalfriends++;

	self waittill( "death" );

	level notify( "friendly_died" );
	level.totalfriends -- ;
}

friendly_wave_masterthread()
{
	level.friendly_wave_active = true;
	// level.totalfriends = 0;
	triggers = getentarray( "friendly_wave", "targetname" );
	array_thread( triggers, ::set_spawncount, 0 );

	// friends = getaiarray( "allies" );
	// array_thread( friends, ::friendlydeath_thread );

	if ( !isdefined( level.maxfriendlies ) )
		level.maxfriendlies = 7;

	names = 1;
	while ( 1 )
	{
		if ( ( isdefined( level.friendly_wave_trigger ) ) && ( isdefined( level.friendly_wave_trigger.target ) ) )
		{
			old_friendly_wave_trigger = level.friendly_wave_trigger;

			spawn = getentarray( level.friendly_wave_trigger.target, "targetname" );

			if ( !spawn.size )
			{
				level waittill( "friendly_died" );
				continue;
			}
			num = 0;

			script_delay = isdefined( level.friendly_wave_trigger.script_delay );
			while ( ( isdefined( level.friendly_wave_trigger ) ) && ( level.totalfriends < level.maxfriendlies ) )
			{
				if ( old_friendly_wave_trigger != level.friendly_wave_trigger )
				{
					script_delay = isdefined( level.friendly_wave_trigger.script_delay );
					old_friendly_wave_trigger = level.friendly_wave_trigger;
					assertex( isdefined( level.friendly_wave_trigger.target ), "Wave trigger must target spawner" );
					spawn = getentarray( level.friendly_wave_trigger.target, "targetname" );
				}


				else if ( !script_delay )
					num = randomint( spawn.size );
				else if ( num == spawn.size )
					num = 0;

				spawn[ num ] set_count( 1 );
				
				//catch for stealth
				dontShareEnemyInfo = ( isdefined( spawn[ num ].script_stealth ) && flag( "_stealth_enabled" ) && !flag( "_stealth_spotted" ) );
				
				if ( isdefined( spawn[ num ].script_forcespawn ) )
					spawned = spawn[ num ] stalingradSpawn( dontShareEnemyInfo );
				else
					spawned = spawn[ num ] doSpawn( dontShareEnemyInfo );


				spawn[ num ] set_count( 0 );

				if ( spawn_failed( spawned ) )
				{
					wait( 0.2 );
					continue;
				}

				if ( isdefined( level.friendlywave_thread ) )
					level thread [[ level.friendlywave_thread ]]( spawned );
				else
					spawned setgoalentity( level.player );

				if ( script_delay )
				{
					if ( level.friendly_wave_trigger.script_delay == 0 )
						waittillframeend;
					else
						wait level.friendly_wave_trigger.script_delay;
					num++;
				}
				else
					wait( randomfloat( 5 ) );
			}
		}

		level waittill( "friendly_died" );
	}
}

friendly_mgTurret( trigger )
{
 /#
	if ( !isdefined( trigger.target ) )
		error( "No target for friendly_mg42 trigger, origin:" + trigger getorigin() );
#/

	node = getnode( trigger.target, "targetname" );

 /#
	if ( !isdefined( node.target ) )
		error( "No mg42 for friendly_mg42 trigger's node, origin: " + node.origin );
#/

	mg42 = getent( node.target, "targetname" );
	mg42 setmode( "auto_ai" );// auto, auto_ai, manual
	mg42 cleartargetentity();


	in_use = false;
	while ( 1 )
	{
// 		println( "^a mg42 waiting for trigger" );
		trigger waittill( "trigger", other );
// 		println( "^a MG42 TRIGGERED" );
		if ( !isAI( other ) )
			continue;

		if ( !isdefined( other.team ) )
			continue;

		if ( other.team != "allies" )
		 	continue;

		if ( ( isdefined( other.script_usemg42 ) ) && ( other.script_usemg42 == false ) )
			continue;

		if ( other thread friendly_mg42_useable( mg42, node ) )
		{
			other thread friendly_mg42_think( mg42, node );

			mg42 waittill( "friendly_finished_using_mg42" );
			if ( isalive( other ) )
				other.turret_use_time = gettime() + 10000;
		}

		wait( 1 );
	}
}

friendly_mg42_death_notify( guy, mg42 )
{
	mg42 endon( "friendly_finished_using_mg42" );
	guy waittill( "death" );
	mg42 notify( "friendly_finished_using_mg42" );
	println( "^a guy using gun died" );
}

friendly_mg42_wait_for_use( mg42 )
{
	mg42 endon( "friendly_finished_using_mg42" );
	self.useable = true;
	self setcursorhint( "HINT_NOICON" );
	// Hold &&1 to commandeer the MG42
	self setHintString( &"PLATFORM_USEAIONMG42" );
	self waittill( "trigger" );
	println( "^a was used by player, stop using turret" );
	self.useable = false;
	self setHintString( "" );
	self stopuseturret();
	self notify( "stopped_use_turret" );// special hook for decoytown guys - nate
	mg42 notify( "friendly_finished_using_mg42" );
}

friendly_mg42_useable( mg42, node )
{
	if ( self.useable )
		return false;

	if ( ( isdefined( self.turret_use_time ) ) && ( gettime() < self.turret_use_time ) )
	{
// 		println( "^a Used gun too recently" );
		return false;
	}

	if ( distance( level.player.origin, node.origin ) < 100 )
	{
// 		println( "^a player too close" );
		return false;
	}

	if ( isdefined( self.chainnode ) )
	if ( distance( level.player.origin, self.chainnode.origin ) > 1100 )
	{
// 		println( "^a too far from chain node" );
		return false;
	}
	return true;
}

friendly_mg42_endtrigger( mg42, guy )
{
	mg42 endon( "friendly_finished_using_mg42" );
	self waittill( "trigger" );
	println( "^a Told friendly to leave the MG42 now" );
// 	guy stopuseturret();
// 	badplace_cylinder( undefined, 3, level.player.origin, 150, 150, "allies" );

	mg42 notify( "friendly_finished_using_mg42" );
}

friendly_mg42_stop_use()
{
	if ( !isdefined( self.friendly_mg42 ) )
		return;
	self.friendly_mg42 notify( "friendly_finished_using_mg42" );
}

noFour()
{
	self endon( "death" );
	self waittill( "goal" );
	self.goalradius = self.oldradius;
	if ( self.goalradius < 32 )
		self.goalradius = 400;
}

friendly_mg42_think( mg42, node )
{
	self endon( "death" );
	mg42 endon( "friendly_finished_using_mg42" );
// 	self endon( "death" );
	level thread friendly_mg42_death_notify( self, mg42 );
// 	println( self.name + "^a is using an mg42" );
	self.oldradius = self.goalradius;
	self.goalradius = 28;
	self thread noFour();
	self setgoalnode( node );

	self.ignoresuppression = true;

	self waittill( "goal" );
	self.goalradius = self.oldradius;
	if ( self.goalradius < 32 )
		self.goalradius = 400;

// 	println( "^3 my goal radius is ", self.goalradius );
	self.ignoresuppression = false;

	// Temporary fix waiting on new code command to see who the player is following.
// 	self setgoalentity( level.player );
	self.goalradius = self.oldradius;

	if ( distance( level.player.origin, node.origin ) < 32 )
	{
		mg42 notify( "friendly_finished_using_mg42" );
		return;
	}

	self.friendly_mg42 = mg42;// For making him stop using the mg42 from another script
	self thread friendly_mg42_wait_for_use( mg42 );
	self thread friendly_mg42_cleanup( mg42 );
	self useturret( mg42 );// dude should be near the mg42
// 	println( "^a Told AI to use mg42" );

	if ( isdefined( mg42.target ) )
	{
		stoptrigger = getent( mg42.target, "targetname" );
		if ( isdefined( stoptrigger ) )
			stoptrigger thread friendly_mg42_endtrigger( mg42, self );
	}

	while ( 1 )
	{
		if ( distance( self.origin, node.origin ) < 32 )
			self useturret( mg42 );// dude should be near the mg42
		else
			break;// a friendly is too far from mg42, stop using turret

		if ( isdefined( self.chainnode ) )
		{
			if ( distance( self.origin, self.chainnode.origin ) > 1100 )
				break;// friendly node is too far, stop using turret
		}

		wait( 1 );
	}

	mg42 notify( "friendly_finished_using_mg42" );
}

friendly_mg42_cleanup( mg42 )
{
	self endon( "death" );
	mg42 waittill( "friendly_finished_using_mg42" );
	self friendly_mg42_doneUsingTurret();
}

friendly_mg42_doneUsingTurret()
{
	self endon( "death" );
	turret = self.friendly_mg42;
	self.friendly_mg42 = undefined;
	self stopuseturret();
	self notify( "stopped_use_turret" );// special hook for decoytown guys - nate
	self.useable = false;
	self.goalradius = self.oldradius;
	if ( !isdefined( turret ) )
		return;

	if ( !isdefined( turret.target ) )
		return;

	node = getnode( turret.target, "targetname" );
	oldradius = self.goalradius;
	self.goalradius = 8;
	self setgoalnode( node );
	wait( 2 );
	self.goalradius = 384;
	return;
	self waittill( "goal" );
	if ( isdefined( self.target ) )
	{
		node = getnode( self.target, "targetname" );
		if ( isdefined( node.target ) )
			node = getnode( node.target, "targetname" );

		if ( isdefined( node ) )
			self setgoalnode( node );
	}
	self.goalradius = oldradius;
}

tanksquish()
{
	if ( isdefined( level.noTankSquish ) )
	{
		assertex( level.noTankSquish, "level.noTankSquish must be true or undefined" );
		return;
	}

	if ( isdefined( level.levelHasVehicles ) && !level.levelHasVehicles )
		return;
	self add_damage_function( ::tanksquish_damage_check );
}

tanksquish_damage_check( amt, who, force, b, c, d, e )
{
	if ( !isdefined( self ) )
	{
		// deleted?
		return;
	}

	if ( isalive( self ) )
		return;

	if ( !isalive( who ) )
		return;
	if ( !isdefined( who.vehicletype ) )
		return;
	if ( who maps\_vehicle::ishelicopter() )
		return;

	if( !isdefined( self.noragdoll ) )
		self startRagdoll();

	if ( !isdefined( self ) )
	{
		return;
	}
	self remove_damage_function( ::tanksquish_damage_check );

//		self playsound( "human_crunch" );
}

// Makes a panzer guy run to a spot and shoot a specific spot
panzer_target( ai, node, pos, targetEnt, targetEnt_offsetVec )
{
	ai endon( "death" );
	ai.panzer_node = node;

	if ( isdefined( node.script_delay ) )
		ai.panzer_delay = node.script_delay;

	if ( ( isdefined( targetEnt ) ) && ( isdefined( targetEnt_offsetVec ) ) )
	{
		ai.panzer_ent = targetEnt;
		ai.panzer_ent_offset = targetEnt_offsetVec;
	}
	else
		ai.panzer_pos = pos;
	ai setgoalpos( ai.origin );
	ai setgoalnode( node );
	ai.goalradius = 12;
	ai waittill( "goal" );
	ai.goalradius = 28;
	ai waittill( "shot_at_target" );
	ai.panzer_ent = undefined;
	ai.panzer_pos = undefined;
	ai.panzer_delay = undefined;
// 	ai.exception_exposed = animscripts\combat::exception_exposed_panzer_guy;
// 	ai.exception_stop = animscripts\combat::exception_exposed_panzer_guy;
// 	ai waittill( "panzer mission complete" );
}

#using_animtree( "generic_human" );
showStart( origin, angles, anime )
{
	org = getstartorigin( origin, angles, anime );
	for ( ;; )
	{
		print3d( org, "x", ( 0.0, 0.7, 1.0 ), 1, 0.25 );	// origin, text, RGB, alpha, scale
		wait( 0.05 );
	}
}

spawnWaypointFriendlies()
{
	self set_count( 1 );

	if ( isdefined( self.script_forcespawn ) )
		spawn = self stalingradSpawn();
	else
		spawn = self doSpawn();

	if ( spawn_failed( spawn ) )
		return;
	spawn.friendlyWaypoint = true;
}

// Newvillers global stuff:

waittillDeathOrLeaveSquad()
{
	self endon( "death" );
	self waittill( "leaveSquad" );
}


friendlySpawnWave()
{
	/* 
		Triggers a spawn point for incoming friendlies.
	
		trigger targetname friendly_spawn
		Targets a trigger or triggers. The targetted trigger targets a script origin.
		Touching the friendly_spawn trigger enables the targetted trigger.
		Touching the enabled trigger causes friendlies to spawn from the targetted script origin.
		Touching the original trigger again stops the friendlies from spawning.
		The script origin may target an additional trigger that halts spawning.
		Make friendly spawn spot sparkle
	*/ 

	 /#
	triggers = getentarray( self.target, "targetname" );
	for ( i = 0;i < triggers.size;i++ )
	{
		if ( triggers[ i ] getentnum() == 526 )
			println( "Target: " + triggers[ i ].target );
	}
	#/
	array_thread( getentarray( self.target, "targetname" ), ::friendlySpawnWave_triggerThink, self );
	for ( ;; )
	{
		self waittill( "trigger", other );
		// If we're the current friendly spawn spot then stop friendly spawning because
		// the player is backtracking
		if ( activeFriendlySpawn() && getFriendlySpawnTrigger() == self )
			unsetFriendlySpawn();

		self waittill( "friendly_wave_start", startPoint );
		setFriendlySpawn( startPoint, self );


		// If the startpoint targets a trigger, that trigger can
		// disable the startpoint too
		if ( !isdefined( startPoint.target ) )
			continue;
		trigger = getent( startPoint.target, "targetname" );
		trigger thread spawnWaveStopTrigger( self );
	}
}



flood_and_secure( instantRespawn )
{
	/* 
		Spawns AI that run to a spot then get a big goal radius. They stop spawning when auto delete kicks in, then start
		again when they are retriggered or the player gets close.
	
		trigger targetname flood_and_secure
		ai spawn and run to goal with small goalradius then get large goalradius
		spawner starts with a notify from any flood_and_secure trigger that triggers it
		spawner stops when an AI from it is deleted to make space for a new AI or when count is depleted
		spawners with count of 1 only make 1 guy.
		Spawners with count of more than 1 only deplete in count when the player kills the AI.
		spawner can target another spawner. When first spawner's ai dies from death( not deletion ), second spawner activates.
		script_noteworth "instant_respawn" on the trigger will disable the wave respawning
	*/ 

	// Instantrespawn disables wave respawning or waiting for time to pass before respawning
	if ( !isdefined( instantRespawn ) )
		instantRespawn = false;

	if ( ( isdefined( self.script_noteworthy ) ) && ( self.script_noteworthy == "instant_respawn" ) )
		instantRespawn = true;

	level.spawnerWave = [];
	spawners = getentarray( self.target, "targetname" );
	array_thread( spawners, ::flood_and_secure_spawner, instantRespawn );

	playerTriggered = false;

	didDelay = false;
	
	for ( ;; )
	{
		self waittill( "trigger", other );
		
		if ( !objectiveIsAllowed() )
			continue;

		if ( !didDelay )
		{
			didDelay = true;
			script_delay();
		}

		if ( self isTouching( level.player ) )
			playerTriggered = true;
		else
		{
			if ( !isalive( other ) )
				continue;
			if ( isplayer( other ) )
				playerTriggered = true;
			else
			if ( !isdefined( other.isSquad ) || !other.isSquad )
			{
				// Non squad AI are not allowed to spawn enemies
				continue;
			}
		}

		// Reacquire spawners in case one has died / been deleted and moved up to another
		// because spawners can target other spawners that are used when the first spawner dies.
		spawners = getentarray( self.target, "targetname" );


		if ( isdefined( spawners[ 0 ] ) )
		{
			if ( isdefined( spawners[ 0 ].script_randomspawn ) )
			{
				cull_spawners_from_killspawner( spawners[ 0 ].script_randomspawn );
				//cull_spawners_leaving_one_set( spawners );
			}
		}

		spawners = getentarray( self.target, "targetname" );

		for ( i = 0;i < spawners.size;i++ )
		{
			spawners[ i ].playerTriggered = playerTriggered;
			spawners[ i ] notify( "flood_begin" );
		}

		if ( playerTriggered )
			wait( 5 );
		else
			wait( 0.1 );
	}
}

cull_spawners_leaving_one_set( spawners )
{
	groups = [];
	for ( i = 0; i < spawners.size; i++ )
	{
		assertEx( isdefined( spawners[ i ].script_randomspawn ), "Spawner at " + spawners[ i ].origin + " doesn't have script_randomspawn set" );
		groups[ spawners[ i ].script_randomspawn ] = true;
	}

	keys = getarraykeys( groups );
	num_that_lives = random( keys );

	for ( i = 0; i < spawners.size; i++ )
	{
		if ( spawners[ i ].script_randomspawn != num_that_lives )
			spawners[ i ] delete();
	}


	/* 
	highest_num = 0;
	for ( i = 0;i < spawners.size;i++ )
	{
		if ( spawners[ i ].script_randomspawn > highest_num )
			highest_num = spawners[ i ].script_randomspawn;
	}
	
	selection = randomint( highest_num + 1 );
	for ( i = 0;i < spawners.size;i++ )
	{
		if ( spawners[ i ].script_randomspawn != selection )
			spawners[ i ] delete();
	}
	*/ 
}

flood_and_secure_spawner( instantRespawn )
{
	if ( isdefined( self.secureStarted ) )
	{
		// Multiple triggers can trigger a flood and secure spawner, but they need to run
		// their logic just once so we exit out if its already running.
		return;
	}

	self.secureStarted = true;
	self.triggerUnlocked = true;// So we don't run auto targetting behavior

	/* 
	mg42 = issubstr( self.classname, "mgportable" ) || issubstr( self.classname, "30cal" );
	if ( !mg42 )
	{
		// So we don't go script error'ing or whatnot off auto spawn logic
		// Unless we're an mg42 guy that has to set an mg42 up.
		self.script_moveoverride = true; 
	}
	*/ 

	target = self.target;
	targetname = self.targetname;
	if ( ( !isdefined( target ) ) && ( !isdefined( self.script_moveoverride ) ) )
	{
		println( "Entity " + self.classname + " at origin " + self.origin + " has no target" );
		waittillframeend;
		assert( isdefined( target ) );
	}

	// follow up spawners
	spawners = [];
	if ( isdefined( target ) )
	{
		possibleSpawners = getentarray( target, "targetname" );
		for ( i = 0;i < possibleSpawners.size;i++ )
		{
			if ( !issubstr( possibleSpawners[ i ].classname, "actor" ) )
				continue;
			spawners[ spawners.size ] = possibleSpawners[ i ];
		}
	}

	ent = spawnstruct();
	org = self.origin;
	flood_and_secure_spawner_think( ent, spawners.size > 0, instantRespawn );
	if ( isalive( ent.ai ) )
		ent.ai waittill( "death" );

	if ( !isdefined( target ) )
		return;

	// follow up spawners
	possibleSpawners = getentarray( target, "targetname" );
	if ( !possibleSpawners.size )
		return;

	for ( i = 0;i < possibleSpawners.size;i++ )
	{
		if ( !issubstr( possibleSpawners[ i ].classname, "actor" ) )
			continue;

		possibleSpawners[ i ].targetname = targetname;
		newTarget = target;
		if ( isdefined( possibleSpawners[ i ].target ) )
		{
			targetEnt = getent( possibleSpawners[ i ].target, "targetname" );
			if ( !isdefined( targetEnt ) || !issubstr( targetEnt.classname, "actor" ) )
				newTarget = possibleSpawners[ i ].target;
		}

		// The guy might already be targetting a different destination
		// But if not, he goes to the node his parent went to. 
		possibleSpawners[ i ].target = newTarget;

		possibleSpawners[ i ] thread flood_and_secure_spawner( instantRespawn );

		// Pass playertriggered flag as true because at this point the player must have been involved because one shots dont
		// spawn without the player triggering and multishot guys require player kills or presense to move along
		possibleSpawners[ i ].playerTriggered = true;
		possibleSpawners[ i ] notify( "flood_begin" );
	}
}

flood_and_secure_spawner_think( ent, oneShot, instantRespawn )
{
	assert( isdefined( instantRespawn ) );
	self endon( "death" );
	count = self.count;
	// oneShot = ( count == 1 );
	if ( !oneShot )
		oneshot = ( isdefined( self.script_noteworthy ) && self.script_noteworthy == "delete" );
	self set_count( 2 );// running out of count counts as a dead spawner to script_deathchain

	if ( isdefined( self.script_delay ) )
		delay = self.script_delay;
	else
		delay = 0;

	for ( ;; )
	{
		self waittill( "flood_begin" );
		if ( self.playerTriggered )
			break;
/* 			
		// Lets let AI spawn oneshots!
		// Oneshots require player triggering to activate
		if ( oneShot )
			continue;
*/ 
		// guys that have a delay require triggering from the player 	
		if ( delay )
			continue;
		break;
	}

	dist = distance( level.player.origin, self.origin );

	prof_begin( "flood_and_secure_spawner_think" );

	while ( count )
	{
		self.trueCount = count;
		self set_count( 2 );
		wait( delay );

		dontShareEnemyInfo = ( isdefined( self.script_stealth ) && flag( "_stealth_enabled" ) && !flag( "_stealth_spotted" ) );

		if ( isdefined( self.script_forcespawn ) )
			spawn = self stalingradSpawn( dontShareEnemyInfo );
		else
			spawn = self doSpawn( dontShareEnemyInfo );

		if ( spawn_failed( spawn ) )
		{
			playerKill = false;
			if ( delay < 2 )
				wait( 2 );// debounce
			continue;
		}
		else
		{
			thread addToWaveSpawner( spawn );
			spawn thread flood_and_secure_spawn( self );

			// Set the accuracy for the spawner
			if ( isdefined( self.script_accuracy ) )
				spawn.baseAccuracy = self.script_accuracy;

			ent.ai = spawn;
			ent notify( "got_ai" );
			self waittill( "spawn_died", deleted, playerKill );
			if ( delay > 2 )
				delay = randomint( 4 ) + 2;// first delay can be long, after that its always a set amount.
			else
				delay = 0.5 + randomfloat( 0.5 );
		}

		if ( deleted )
		{
			// Deletion indicates that we've hit the max AI limit and this is the oldest / farthest AI
			// so we need to stop this spawner until it gets triggered again or the player gets close

			waittillRestartOrDistance( dist );
		}
		else
		{
			/* 
			// Only player kills count towards the count unless the spawner only has a count of 1
			// or NOT
			if ( playerKill || oneShot )
			*/ 
			if ( playerWasNearby( playerKill || oneShot, ent.ai ) )
				count -- ;

			if ( !instantRespawn )
				waitUntilWaveRelease();
		}
	}

	prof_end( "flood_and_secure_spawner_think" );

	self delete();
}

waittillDeletedOrDeath( spawn )
{
	self endon( "death" );
	spawn waittill( "death" );
}

addToWaveSpawner( spawn )
{
	name = self.targetname;
	if ( !isdefined( level.spawnerWave[ name ] ) )
	{
		level.spawnerWave[ name ] = spawnStruct();
		level.spawnerWave[ name ] set_count( 0 );
		level.spawnerWave[ name ].total = 0;
	}

	if ( !isdefined( self.addedToWave ) )
	{
		self.addedToWave = true;
		level.spawnerWave[ name ].total++;
	}

	level.spawnerWave[ name ].count++;
	/* 
	 /#
	if ( level.debug_corevillers )
		thread debugWaveCount( level.spawnerWave[ name ] );
	#/ 
	*/ 
	waittillDeletedOrDeath( spawn );
	level.spawnerWave[ name ].count -- ;
	if ( !isdefined( self ) )
		level.spawnerWave[ name ].total -- ;

	/* 
	 /#
	if ( isdefined( self ) )
	{
		if ( level.debug_corevillers )
			self notify( "debug_stop" );
	}
	#/ 
	*/ 

// 	if ( !level.spawnerWave[ name ].count )
	// Spawn the next wave if 68% of the AI from the wave are dead.
	if ( level.spawnerWave[ name ].total )
	{
		if ( level.spawnerWave[ name ].count / level.spawnerWave[ name ].total < 0.32 )
			level.spawnerWave[ name ] notify( "waveReady" );
	}
}

debugWaveCount( ent )
{
	self endon( "debug_stop" );
	self endon( "death" );
	for ( ;; )
	{
		print3d( self.origin, ent.count + "/" + ent.total, ( 0, 0.8, 1 ), 0.5 );
		wait( 0.05 );
	}
}


waitUntilWaveRelease()
{
	name = self.targetName;
	if ( level.spawnerWave[ name ].count )
		level.spawnerWave[ name ] waittill( "waveReady" );
}


playerWasNearby( playerKill, ai )
{
	if ( playerKill )
		return true;

	if ( isdefined( ai ) && isdefined( ai.origin ) )
	{
		org = ai.origin;
	}
	else
	{
		org = self.origin;
	}

	if ( distance( level.player.origin, org ) < 700 )
	{
		return true;
	}

	return bulletTracePassed( level.player geteye(), ai geteye(), false, undefined );
}

waittillRestartOrDistance( dist )
{
	self endon( "flood_begin" );

	dist = dist * 0.75;// require the player to get a bit closer to force restart the spawner

	while ( distance( level.player.origin, self.origin ) > dist )
		wait( 1 );
}

flood_and_secure_spawn( spawner )
{
	self thread flood_and_secure_spawn_goal();

	self waittill( "death", other );

	playerKill = isalive( other ) && isplayer( other );
	if ( !playerkill && isdefined( other ) && other.classname == "worldspawn" )// OR THE WORLDSPAWN???
	{
		playerKill = true;
	}

	deleted = !isdefined( self );
	spawner notify( "spawn_died", deleted, playerKill );
}

flood_and_secure_spawn_goal()
{
	if ( isdefined( self.script_moveoverride ) )
		return;

	self endon( "death" );
	node = getnode( self.target, "targetname" );
	self setgoalnode( node );

// 	if ( isdefined( self.script_deathChain ) )
// 		self setgoalvolume( level.deathchain_goalVolume[ self.script_deathChain ] );

	if ( isdefined( level.fightdist ) )
	{
		self.pathenemyfightdist = level.fightdist;
		self.pathenemylookahead = level.maxdist;
	}

	if ( node.radius )
		self.goalradius = node.radius;
	else
		self.goalradius = 256;

	self waittill( "goal" );

	while ( isdefined( node.target ) )
	{
		newNode = getnode( node.target, "targetname" );
		if ( isdefined( newNode ) )
			node = newNode;
		else
			break;

		self setgoalnode( node );

		if ( node.radius )
			self.goalradius = node.radius;
		else
			self.goalradius = 256;

		self waittill( "goal" );
	}


	if ( isdefined( self.script_noteworthy ) )
	{
		if ( self.script_noteworthy == "delete" )
		{
// 			self delete();
			// Do damage instead of delete so he counts as "killed" and we dont have to write 
			// stuff to let the spawner know to stop trying to spawn him.
			self kill();
			return;
		}
	}

	if ( isDefined( node.target ) )
	{
		turret = getEnt( node.target, "targetname" );
		if ( isDefined( turret ) && ( turret.code_classname == "misc_mgturret" || turret.code_classname == "misc_turret" ) )
		{
			self setGoalNode( node );
			self.goalradius = 4;
			self waittill( "goal" );
			if ( !isDefined( self.script_forcegoal ) )
				self.goalradius = level.default_goalradius;
			self maps\_spawner::use_a_turret( turret );
		}
	}

	if ( isdefined( self.script_noteworthy ) )
	{
		if ( isdefined( self.script_noteworthy2 ) )
		{
			if ( self.script_noteworthy2 == "furniture_push" )
				thread furniturePushSound();
		}

		if ( self.script_noteworthy == "hide" )
		{
			self thread set_battlechatter( false );
			return;
		}
	}

	if ( !isdefined( self.script_forcegoal ) && !isdefined( self getGoalVolume() ) )
	{
		self.goalradius = level.default_goalradius;
	}
}

furniturePushSound()
{
	org = getent( self.target, "targetname" ).origin;
	play_sound_in_space( "furniture_slide", org );
	wait( 0.9 );
	if ( isdefined( level.whisper ) )
		play_sound_in_space( random( level.whisper ), org );

}


friendlychain()
{
	/* 
		Selectively enable and disable friendly chains with triggers

		trigger targetname friendlychain
		Targets a trigger. When the player hits the friendly chain trigger it enables the targetted trigger.
		When the player hits the enabled trigger, it activates the friendly chain of nodes that it targets.
		If the enabled trigger links to a "friendy_spawn" trigger, it enables that friendly_spawn trigger.
	*/ 
	waittillframeend;
	triggers = getentarray( self.target, "targetname" );
	if ( !triggers.size )
	{
		// trigger targets chain directly, has no direction
		node = getnode( self.target, "targetname" );
		assert( isdefined( node ) );
	assert( isdefined( node.script_noteworthy ) );
		for ( ;; )
		{
			self waittill( "trigger" );
			if ( isdefined( level.lastFriendlyTrigger ) && level.lastFriendlyTrigger == self )
			{
				wait( 0.5 );
				continue;
			}

			if ( !objectiveIsAllowed() )
			{
				wait( 0.5 );
				continue;
			}

			level notify( "new_friendly_trigger" );
			level.lastFriendlyTrigger = self;

			rejoin = !isdefined( self.script_baseOfFire ) || self.script_baseOfFire == 0;
			setNewPlayerChain( node, rejoin );
		}
	}

	 /#
	for ( i = 0;i < triggers.size;i++ )
	{
		node = getnode( triggers[ i ].target, "targetname" );
		assert( isdefined( node ) );
		assert( isdefined( node.script_noteworthy ) );
	}
	#/

	for ( ;; )
	{
		self waittill( "trigger" );
// 		if ( level.currentObjective != self.script_noteworthy2 )
		while ( level.player istouching( self ) )
			wait( 0.05 );

		if ( !objectiveIsAllowed() )
		{
			wait( 0.05 );
			continue;
		}

		if ( isdefined( level.lastFriendlyTrigger ) && level.lastFriendlyTrigger == self )
			continue;

		level notify( "new_friendly_trigger" );
		level.lastFriendlyTrigger = self;

		array_thread( triggers, ::friendlyTrigger );
		wait( 0.5 );
	}
}

objectiveIsAllowed()
{
	active = true;
	if ( isdefined( self.script_objective_active ) )
	{
		active = false;
		// objective must be active for this trigger to hit
		for ( i = 0;i < level.active_objective.size;i++ )
		{
			if ( !issubstr( self.script_objective_active, level.active_objective[ i ] ) )
				continue;
			active = true;
			break;
		}

		if ( !active )
			return false;
	}

	if ( !isdefined( self.script_objective_inactive ) )
		return( active );

	// trigger only hits if this objective is inactive
	inactive = 0;
	for ( i = 0;i < level.inactive_objective.size;i++ )
	{
		if ( !issubstr( self.script_objective_inactive, level.inactive_objective[ i ] ) )
			continue;
		inactive++;
	}

	tokens = strtok( self.script_objective_inactive, " " );
	return( inactive == tokens.size );
}

friendlyTrigger( node )
{
	level endon( "new_friendly_trigger" );
	self waittill( "trigger" );
	node = getnode( self.target, "targetname" );
	rejoin = !isdefined( self.script_baseOfFire ) || self.script_baseOfFire == 0;
	setNewPlayerChain( node, rejoin );
}



waittillDeathOrEmpty()
{
	self endon( "death" );
	num = self.script_deathChain;
	while ( self.count )
	{
		self waittill( "spawned", spawn );
		spawn thread deathChainAINotify( num );
	}
}

deathChainAINotify( num )
{
	level.deathSpawner[ num ]++;
	self waittill( "death" );
	level.deathSpawner[ num ] -- ;
	level notify( "spawner_expired" + num );
}


deathChainSpawnerLogic()
{
	num = self.script_deathChain;
	level.deathSpawner[ num ]++;
	 /#
	level.deathSpawnerEnts[ num ][ level.deathSpawnerEnts[ num ].size ] = self;
	#/

	org = self.origin;
	self waittillDeathOrEmpty();
	 /#
	newDeathSpawners = [];
	if ( isdefined( self ) )
	{
		for ( i = 0;i < level.deathSpawnerEnts[ num ].size;i++ )
		{
			if ( !isdefined( level.deathSpawnerEnts[ num ][ i ] ) )
				continue;

			if ( self == level.deathSpawnerEnts[ num ][ i ] )
				continue;
			newDeathSpawners[ newDeathSpawners.size ] = level.deathSpawnerEnts[ num ][ i ];
		}
	}
	else
	{
		for ( i = 0;i < level.deathSpawnerEnts[ num ].size;i++ )
		{
			if ( !isdefined( level.deathSpawnerEnts[ num ][ i ] ) )
				continue;
			newDeathSpawners[ newDeathSpawners.size ] = level.deathSpawnerEnts[ num ][ i ];
		}
	}

	level.deathSpawnerEnts[ num ] = newDeathSpawners;
	#/
 	level notify( "spawner dot" + org );
	level.deathSpawner[ num ] -- ;
	level notify( "spawner_expired" + num );
}

friendlychain_onDeath()
{
	/* 
		Enables a friendly chain when certain AI are cleared
		
		trigger targetname friendly_chain_on_death
		trigger is script_deathchain grouped with spawners
		When the spawners have depleted and all their ai are dead:
			the triggers become active.
		When triggered they set the friendly chain to the chain they target
		The triggers deactivate when a "friendlychain" targetnamed trigger is hit.
	*/ 
	triggers = getentarray( "friendly_chain_on_death", "targetname" );
	spawners = getspawnerarray();
	level.deathSpawner = [];
	 /#
	// for debugging deathspawners
	level.deathSpawnerEnts = [];
	#/
	for ( i = 0;i < spawners.size;i++ )
	{
		if ( !isdefined( spawners[ i ].script_deathchain ) )
			continue;

		num = spawners[ i ].script_deathchain;
		if ( !isdefined( level.deathSpawner[ num ] ) )
		{
			level.deathSpawner[ num ] = 0;
			 /#
			level.deathSpawnerEnts[ num ] = [];
			#/
		}

		spawners[ i ] thread deathChainSpawnerLogic();
// 		level.deathSpawner[ num ]++;
	}

	for ( i = 0;i < triggers.size;i++ )
	{
		if ( !isdefined( triggers[ i ].script_deathchain ) )
		{
			println( "trigger at origin " + triggers[ i ] getorigin() + " has no script_deathchain" );
			return;
		}

		triggers[ i ] thread friendlyChain_onDeathThink();
	}
}

friendlyChain_onDeathThink()
{
	while ( level.deathSpawner[ self.script_deathChain ] > 0 )
		level waittill( "spawner_expired" + self.script_deathChain );

	level endon( "start_chain" );
	node = getnode( self.target, "targetname" );
	for ( ;; )
	{
		self waittill( "trigger" );
		setNewPlayerChain( node, true );
		iprintlnbold( "Area secured, move up!" );
		wait( 5 );// debounce
	}
}

setNewPlayerChain( node, rejoin )
{
	level.player set_friendly_chain_wrapper( node );
	level notify( "new_escort_trigger" );// stops escorting guy from getting back on escort chain
	level notify( "new_escort_debug" );
	level notify( "start_chain", rejoin );// get the SMG guy back on the friendly chain
}


friendlyChains()
{
	level.friendlySpawnOrg = [];
	level.friendlySpawnTrigger = [];
	array_thread( getentarray( "friendlychain", "targetname" ), ::friendlychain );
}


unsetFriendlySpawn()
{
	newOrg = [];
	newTrig = [];
	for ( i = 0;i < level.friendlySpawnOrg.size;i++ )
	{
		newOrg[ newOrg.size ] = level.friendlySpawnOrg[ i ];
		newTrig[ newTrig.size ] = level.friendlySpawnTrigger[ i ];
	}
	level.friendlySpawnOrg = newOrg;
	level.friendlySpawnTrigger = newTrig;

	if ( activeFriendlySpawn() )
		return;

	// If we've stepped back through all the spawners then turn off spawning
	flag_Clear( "spawning_friendlies" );
}

getFriendlySpawnStart()
{
	assert( level.friendlySpawnOrg.size > 0 );
	return( level.friendlySpawnOrg[ level.friendlySpawnOrg.size - 1 ] );
}

activeFriendlySpawn()
{
	return level.friendlySpawnOrg.size > 0;
}

getFriendlySpawnTrigger()
{
	assert( level.friendlySpawnTrigger.size > 0 );
	return( level.friendlySpawnTrigger[ level.friendlySpawnTrigger.size - 1 ] );
}

setFriendlySpawn( org, trigger )
{
	level.friendlySpawnOrg[ level.friendlySpawnOrg.size ] = org.origin;
	level.friendlySpawnTrigger[ level.friendlySpawnTrigger.size ] = trigger;
	flag_set( "spawning_friendlies" );
}

delayedPlayerGoal()
{
	self endon( "death" );
	self endon( "leaveSquad" );
	wait( 0.5 );
	self setgoalentity( level.player );
}

spawnWaveStopTrigger( startTrigger )
{
	self notify( "stopTrigger" );
	self endon( "stopTrigger" );

	self waittill( "trigger" );
	if ( getFriendlySpawnTrigger() != startTrigger )
		return;

	unsetFriendlySpawn();
}

friendlySpawnWave_triggerThink( startTrigger )
{
	org = getent( self.target, "targetname" );
// 	thread linedraw();

	for ( ;; )
	{
		self waittill( "trigger" );
		startTrigger notify( "friendly_wave_start", org );
		if ( !isdefined( org.target ) )
			continue;
	}
}


goalVolumes()
{
	volumes = getentarray( "info_volume", "classname" );
	level.deathchain_goalVolume = [];
	level.goalVolumes = [];

	for ( i = 0; i < volumes.size; i++ )
	{
		volume = volumes[ i ];
		if ( isdefined( volume.script_deathChain ) )
		{
			level.deathchain_goalVolume[ volume.script_deathChain ] = volume;
		}
		if ( isdefined( volume.script_goalvolume ) )
		{
			assertex( !isdefined( level.goalVolumes[ volume.script_goalVolume ] ), "Tried to overwrite goalvolume with script_goalvolume " + volume.script_goalVolume + ". Maybe you are using the same script_goalvolume value in a prefab? Script_goalvolume is not autocast in prefabs." );
			level.goalVolumes[ volume.script_goalVolume ] = volume;
		}
	}
}

debugPrint( msg, endonmsg, color )
{
// 	if ( !level.debug_corevillers )
	if ( 1 )
		return;

	org = self getorigin();
	height = 40 * sin( org[ 0 ] + org[ 1 ] ) - 40;
	org = ( org[ 0 ], org[ 1 ], org[ 2 ] + height );
	level endon( endonmsg );
	self endon( "new_color" );
	if ( !isdefined( color ) )
		color = ( 0, 0.8, 0.6 );
	num = 0;
	for ( ;; )
	{
		num += 12;
		scale = sin( num ) * 0.4;
		if ( scale < 0 )
			scale *= -1;
		scale += 1;
		print3d( org, msg, color, 1, scale );
		wait( 0.05 );
	}
}

aigroup_create( aigroup )
{
	level._ai_group[ aigroup ] = spawnstruct();
	level._ai_group[ aigroup ].aicount = 0;
	level._ai_group[ aigroup ].spawnercount = 0;
	level._ai_group[ aigroup ].ai = [];
	level._ai_group[ aigroup ].spawners = [];
}

aigroup_spawnerthink( tracker )
{
	self endon( "death" );

	self.decremented = false;
	tracker.spawnercount++;

	self thread aigroup_spawnerdeath( tracker );
	self thread aigroup_spawnerempty( tracker );

	while ( self.count )
	{
		self waittill( "spawned", soldier );

		if ( spawn_failed( soldier ) )
			continue;

		soldier thread aigroup_soldierthink( tracker );
	}
	waittillframeend;

	if ( self.decremented )
		return;

	self.decremented = true;
	tracker.spawnercount -- ;
}

aigroup_spawnerdeath( tracker )
{
	self waittill( "death" );

	if ( self.decremented )
		return;

	tracker.spawnercount -- ;
}

aigroup_spawnerempty( tracker )
{
	self endon( "death" );

	self waittill( "emptied spawner" );

	waittillframeend;
	if ( self.decremented )
		return;

	self.decremented = true;
	tracker.spawnercount -- ;
}

aigroup_soldierthink( tracker )
{
	tracker.aicount++;
	tracker.ai[ tracker.ai.size ] = self;

	if ( isdefined( self.script_deathflag_longdeath ) )
	{
		self waittillDeathOrPainDeath();
	}
	else
	{
		self waittill( "death" );
	}

	tracker.aicount -- ;
}


camper_trigger_think( trigger )
{
	// wait( 0.05 );
	tokens = strtok( trigger.script_linkto, " " );
	spawners = [];
	nodes = [];
	for ( i = 0; i < tokens.size; i++ )
	{
		token = tokens[ i ];
		ai = getent( token, "script_linkname" );
		if ( isdefined( ai ) )
		{
			spawners = add_to_array( spawners, ai );
			continue;
		}
		node = getnode( token, "script_linkname" );
		if ( !isdefined( node ) )
		{
			println( "Warning: Trigger token number " + token + " did not exist." );
			continue;
		}
		nodes = add_to_array( nodes, node );
	}
	assertEX( spawners.size, "camper_spawner without any spawners associated" );
	assertEX( nodes.size, "camper_spawner without any nodes associated" );
	assertEX( nodes.size >= spawners.size, "camper_spawner with less nodes than spawners" );

	trigger waittill( "trigger" );

	nodes = array_randomize( nodes );
	for ( i = 0; i < nodes.size; i++ )
		nodes[ i ].claimed = false;
	j = 0;
	for ( i = 0; i < spawners.size; i++ )
	{
		spawner = spawners[ i ];

		if ( !isdefined( spawner ) )
			continue;

		if ( isdefined( spawner.script_spawn_here ) )
		{
			// these guys spawn where they're placed
			continue;
		}

		while ( isdefined( nodes[ j ].script_noteworthy ) && nodes[ j ].script_noteworthy == "dont_spawn" )
			j++;
		spawner.origin = nodes[ j ].origin;
		spawner.angles = nodes[ j ].angles;
		spawner add_spawn_function( ::claim_a_node, nodes[ j ] );
		j++;
	}

	array_thread( spawners, ::add_spawn_function, ::camper_guy );
	array_thread( spawners, ::add_spawn_function, ::move_when_enemy_hides, nodes );
	array_thread( spawners, ::spawn_ai );
}

camper_guy()
{
	self.goalradius = 8;
	self.fixednode = true;
}

move_when_enemy_hides( nodes )
{
	self endon( "death" );

	waitingForEnemyToDisappear = false;

	while ( 1 )
	{
		// it is important that we check whether our enemy is defined before doing a cansee check on him.
		if ( !isalive( self.enemy ) )
		{
			self waittill( "enemy" );
			waitingForEnemyToDisappear = false;
			continue;
		}


		if ( isplayer( self.enemy ) )
		{
			if ( self.enemy ent_flag( "player_has_red_flashing_overlay" ) || flag( "player_flashed" ) )
			{
				// player is wounded, chase him with a suicide charge. One must fall!
				self.fixednode = 0;
				for ( ;; )
				{
					self.goalradius = 180;
					self setgoalpos( level.player.origin );
					wait( 1 );
				}
				return;
			}
		}


		if ( waitingForEnemyToDisappear )
		{
			if ( self cansee( self.enemy ) )
			{
				wait .05;
				continue;
			}
			waitingForEnemyToDisappear = false;
		}
		else
		{
			if ( self cansee( self.enemy ) )
			{
				// enemy is seen, wait until you cant see him
				waitingForEnemyToDisappear = true;
			}
			wait .05;
			continue;
		}

		// you cant see him, 2 / 3rds of the time move to a different node
		if ( randomint( 3 ) > 0 )
		{
			node = find_unclaimed_node( nodes );
			if ( isdefined( node ) )
			{
				self claim_a_node( node, self.claimed_node );
				self waittill( "goal" );
			}
		}
	}
}

claim_a_node( claimed_node, old_claimed_node )
{
	self setgoalnode( claimed_node );
	self.claimed_node = claimed_node;
	claimed_node.claimed = true;
	if ( isdefined( old_claimed_node ) )
		old_claimed_node.claimed = false;

// 	self OrientMode( "face angle", claimed_node.angles[ 1 ] );
}

find_unclaimed_node( nodes )
{
	for ( i = 0; i < nodes.size; i++ )
	{
		if ( nodes[ i ].claimed )
			continue;
		else
			return nodes[ i ];
	}
	return undefined;
}



// flood_spawner

flood_trigger_think( trigger )
{
	assertEX( isDefined( trigger.target ), "flood_spawner at " + trigger.origin + " without target" );

	floodSpawners = getEntArray( trigger.target, "targetname" );
	assertEX( floodSpawners.size, "flood_spawner at with target " + trigger.target + " without any targets" );

	array_thread( floodSpawners, ::flood_spawner_init );

	trigger waittill( "trigger" );
	// reget the target array since targets may have been deletes, etc... between initialization and triggering
	floodSpawners = getEntArray( trigger.target, "targetname" );


	array_thread( floodSpawners, ::flood_spawner_think, trigger );
}


flood_spawner_init( spawner )
{
	assertEX( ( isDefined( self.spawnflags ) && self.spawnflags & 1 ), "Spawner at origin" + self.origin + "/" + ( self getOrigin() ) + " is not a spawner!" );
}

trigger_requires_player( trigger )
{
	if ( !isdefined( trigger ) )
		return false;

	return isDefined( trigger.script_requires_player );
}


two_stage_spawner_think( trigger )
{
	trigger_target = getent( trigger.target, "targetname" );
	assertEx( isdefined( trigger_target ), "Trigger with targetname two_stage_spawner that doesnt target anything." );
	assertEx( issubstr( trigger_target.classname, "trigger" ), "Triggers with targetname two_stage_spawner must target a trigger" );
	assertEx( isdefined( trigger_target.target ), "The second trigger of a two_stage_spawner must target at least one spawner" );

	// wait until _spawner has initialized before adding spawn functions
	waittillframeend;

	spawners = getentarray( trigger_target.target, "targetname" );
	for ( i = 0; i < spawners.size; i++ )
	{
		spawners[ i ].script_moveoverride = true;
		spawners[ i ] add_spawn_function( ::wait_to_go, trigger_target );
	}

	trigger waittill( "trigger" );

	spawners = getentarray( trigger_target.target, "targetname" );
	array_thread( spawners, ::spawn_ai );
}

wait_to_go( trigger_target )
{
	trigger_target endon( "death" );
	self endon( "death" );
	self.goalradius	 = 8;

	trigger_target waittill( "trigger" );

	self thread go_to_node();
}


flood_spawner_think( trigger )
{
	self endon( "death" );
	self notify( "stop current floodspawner" );
	self endon( "stop current floodspawner" );

	// pyramid spawner is a spawner that targets another spawner or spawners
	// First the targetted spawners spawn, then when they die, the reinforcement spawns from
	// the spawner this initial spawner
	if ( is_pyramid_spawner() )
	{
		pyramid_spawn( trigger );
		return;
	}

	requires_player = trigger_requires_player( trigger );

	script_delay();

	while ( self.count > 0 )
	{
		while ( requires_player && !level.player isTouching( trigger ) )
			wait( 0.5 );
		
		dontShareEnemyInfo = ( isdefined( self.script_stealth ) && flag( "_stealth_enabled" ) && !flag( "_stealth_spotted" ) );

		if ( isdefined( self.script_forcespawn ) )
			soldier = self stalingradSpawn( dontShareEnemyInfo );
		else
			soldier = self doSpawn( dontShareEnemyInfo );

		if ( spawn_failed( soldier ) )
		{
			wait( 2 );
			continue;
		}

		soldier thread reincrement_count_if_deleted( self );
		soldier thread expand_goalradius( trigger );

		soldier waittill( "death", attacker );

		if ( !player_saw_kill( soldier, attacker ) )
		{
			self.count++;
		}
		else if ( isdefined( level.ac130_flood_respawn ) )
		{
			if ( isdefined( level.ac130gunner ) && ( attacker == level.ac130gunner ) )
			{
				if ( randomint( 2 ) == 0 )
					self.count++;
			}
		}

		// soldier was deleted, not killed
		if ( !isDefined( soldier ) )
			continue;

		if ( !script_wait() )
			wait( randomFloatRange( 5, 9 ) );
	}
}

player_saw_kill( guy, attacker )
{
	if ( isdefined( self.script_force_count ) )
		if ( self.script_force_count )
			return true;

	if ( !isdefined( guy ) )
	{
		return false;
	}

	if ( isalive( attacker ) )
	{
		if ( isplayer( attacker ) )
		{
			return true;
		}

		if ( distance( attacker.origin, level.player.origin ) < 200 )
		{
			// player was near the guy that killed the ai?
			return true;
		}
	}
	else
	{
		if ( isdefined( attacker ) )
		{
			if ( attacker.classname	 == "worldspawn" )
			{
				return false;
			}

			if ( distance( attacker.origin, level.player.origin ) < 200 )
			{
				// player was near the guy that killed the ai?
				return true;
			}
		}
	}

	if ( distance( guy.origin, level.player.origin ) < 200 )
	{
		// player was near the guy that got killed?
		return true;
	}

	// did the player see the guy die?
	return bulletTracePassed( level.player geteye(), guy geteye(), false, undefined );
}

is_pyramid_spawner()
{
	if ( !isdefined( self.target ) )
		return false;

	ent = getentarray( self.target, "targetname" );
	if ( !ent.size )
		return false;

	return issubstr( ent[ 0 ].classname, "actor" );
}


pyramid_death_report( spawner )
{
	spawner.spawn waittill( "death" );
	self notify( "death_report" );
}

pyramid_spawn( trigger )
{

	self endon( "death" );
	requires_player = trigger_requires_player( trigger );

	script_delay();

	if ( requires_player )
	{
		while ( !level.player isTouching( trigger ) )
			wait( 0.5 );
	}

	// first spawn all the guys we target. They decrement our count tho, so we spawn them in a random order in case 
	// our count is just 1( default )

	spawners = getentarray( self.target, "targetname" );
	 /#
		for ( i = 0; i < spawners.size; i++ )
			assertEx( issubstr( spawners[ i ].classname, "actor" ), "Pyramid spawner targets non AI!" );
	#/

	// the spawners have to report their death to the head of the pyramid so it can kill itself when they're all gone
	self.spawners = 0;
	array_thread( spawners, ::pyramid_spawner_reports_death, self );

	offset = randomint( spawners.size );
	for ( i = 0; i < spawners.size; i++ )
	{
		if ( self.count <= 0 )
			return;

		offset++;
		if ( offset >= spawners.size )
			offset = 0;
		spawner = spawners[ offset ];

		// the count is local to self, not to the spawners that are targetted
		spawner set_count( 1 );

		soldier = spawner spawn_ai();
		if ( spawn_failed( soldier ) )
		{
// 			assertEx( 0, "Initial spawning from spawner at " + self.origin + " failed." );
			wait( 2 );
			continue;
		}

		self.count -- ;
		spawner.spawn = soldier;

		soldier thread reincrement_count_if_deleted( self );
		soldier thread expand_goalradius( trigger );
		thread pyramid_death_report( spawner );
	}

	culmulative_wait = 0.01;
	while ( self.count > 0 )
	{
		self waittill( "death_report" );
		script_wait();
		wait( culmulative_wait );
		culmulative_wait += 2.5;

		offset = randomint( spawners.size );
		for ( i = 0; i < spawners.size; i++ )
		{
			// cleanup in case any spawners were deleted
			spawners = array_removeUndefined( spawners );

			if ( !spawners.size )
			{
				if ( isdefined( self ) )
					self delete();
				return;
			}

			offset++;
			if ( offset >= spawners.size )
				offset = 0;

			spawner = spawners[ offset ];

			// find a spawner that has lost its AI
			if ( isalive( spawner.spawn ) )
				continue;

			// spawn from self now, we're reinforcement			
			if ( isdefined( spawner.target ) )
			{
				self.target = spawner.target;
			}
			else
			{
				self.target = undefined;
			}

			soldier = self spawn_ai();
			if ( spawn_failed( soldier ) )
			{
				wait( 2 );
				continue;
			}

			assertEx( isdefined( spawner ), "Theoretically impossible." );
			soldier thread reincrement_count_if_deleted( self );
			soldier thread expand_goalradius( trigger );
			spawner.spawn = soldier;
			thread pyramid_death_report( spawner );

			if ( self.count <= 0 )
				return;
		}
	}
}

pyramid_spawner_reports_death( parent )
{
	parent endon( "death" );
	parent.spawners++;
	self waittill( "death" );
	parent.spawners -- ;
	if ( !parent.spawners )
		parent delete();
}

expand_goalradius( trigger )
{
	if ( isDefined( self.script_forcegoal ) )
		return;

	// triggers with a script_radius of - 1 dont override the goalradius
	// triggers with a script_radius of anything else set the goalradius to that size
	radius = level.default_goalradius;
	if ( isdefined( trigger ) )
	{
		if ( isdefined( trigger.script_radius ) )
		{
			if ( trigger.script_radius == -1 )
				return;
			radius = trigger.script_radius;
		}
	}

	if ( isdefined( self.script_forcegoal ) )
		return;

	// expands the goalradius of the ai after they reach there initial goal.
	self endon( "death" );
	self waittill( "goal" );
	self.goalradius = radius;
}


drop_health_timeout_thread()
{
	self endon( "death" );
	wait( 95 );
	self notify( "timeout" );
}

drop_health_trigger_think()
{
	self endon( "timeout" );
	thread drop_health_timeout_thread();
	self waittill( "trigger" );
	change_player_health_packets( 1 );
}

traceShow( org )
{
	for ( ;; )
	{
		line( org + ( 0, 0, 100 ), org, ( 0.2, 0.5, 0.8 ), 0.5 );
		wait( 0.05 );
	}
}

/*drophealth()
{
	// wait until regular scripts have a change to set self.script_nohealth on the guy from script, after spawn_failed.
	waittillframeend;
	waittillframeend;

	if ( !isalive( self ) )
		return;
	
	if ( isdefined( self.script_nohealth ) )
		return;
	
	self waittill( "death" );
	
	if ( !isdefined( self ) )
		return;
		
	// drop health disabled once again
	if ( 1 )
		return;
		

	// has enough time passed since the last health drop?
	if ( gettime() < level.next_health_drop_time )
		return;
		
	// have enough guys died?
	level.guys_to_die_before_next_health_drop -- ;
	if ( level.guys_to_die_before_next_health_drop > 0 )
		return;
	
	level.guys_to_die_before_next_health_drop = randomintrange( 2, 5 );
	level.next_health_drop_time = gettime() + 3500;// probably make this a _gameskill thing later
	
	trace = bullettrace( self.origin + ( 0, 0, 50 ), self.origin + ( 0, 0, -220 ), true, self );
	health = spawn( "script_model", self.origin + ( 0, 0, 10 ) );
	health.origin = trace[ "position" ];
// 	health setmodel( "com_trashbag" );
	
	trigger = spawn( "trigger_radius", self.origin + ( 0, 0, 10 ), 0, 10, 32 );
	trigger.radius = 10;

	trigger drop_health_trigger_think();	
	
	trigger delete();
	health delete();
	

// 	health = spawn( "item_health", self.origin + ( 0, 0, 10 ) );
// 	health.angles = ( 0, randomint( 360 ), 0 );

	/* 
	if ( isdefined( level._health_queue ) )
	{
		if ( isdefined( level._health_queue[ level._health_queue_num ] ) )
			level._health_queue[ level._health_queue_num ] delete();
	}

	level._health_queue[ level._health_queue_num ] = health;
 	level._health_queue_num++;
 	if ( level._health_queue_num > level._health_queue_max )
	 	level._health_queue_num = 0;
	*/ 
//}

show_bad_path()
{
	/#
	if ( getdebugdvar( "debug_badpath_count" ) == "" )
		setdvar( "debug_badpath_count", 10 );

	self endon( "death" );
	last_bad_path_time = -5000;
	bad_path_count = 0;
	for ( ;; )
	{
		self waittill( "bad_path", badPathPos );
		if ( !level.debug_badpath )
			continue;

		if ( gettime() - last_bad_path_time > 5000 )
		{
			bad_path_count = 0;
		}
		else
		{
			bad_path_count++;
		}

		last_bad_path_time = gettime();

		if ( bad_path_count < getdebugdvarint( "debug_badpath_count" ) )
			continue;

		for ( p = 0; p < 10 * 20; p++ )
		{
			line( self.origin, badPathPos, ( 1, 0.4, 0.1 ), 0, 10 * 20 );
			wait( 0.05 );
		}
	}
	#/
}

random_spawn( trigger )
{
	trigger waittill( "trigger" );
	// get a random target and all the links to that target and spawn them
	spawners = getentarray( trigger.target, "targetname" );
	if ( !spawners.size )
		return;
	spawner = random( spawners );

	spawners = [];
	spawners[ spawners.size ] = spawner;
	// grab the other spawners linked to the parent spawner
	if ( isdefined( spawner.script_linkto ) )
	{
		links = strTok( spawner.script_linkto, " " );
		for ( i = 0; i < links.size; i++ )
		{
			spawners[ spawners.size ] = getent( links[ i ], "script_linkname" );
		}
	}

	waittillframeend;// _load needs to finish entirely before we can add spawn functions to spawners
	array_thread( spawners, ::add_spawn_function, ::blowout_goalradius_on_pathend );
	array_thread( spawners, ::spawn_ai );
}

blowout_goalradius_on_pathend()
{
	if ( isDefined( self.script_forcegoal ) )
		return;

	self endon( "death" );
	self waittill( "reached_path_end" );
	
	if ( !isdefined( self getGoalVolume() )	)
		self.goalradius = level.default_goalradius;
}

objective_event_init( trigger )
{
	flag = trigger get_trigger_flag();
	assertEx( isdefined( flag ), "Objective event at origin " + trigger.origin + " does not have a script_flag. " );
	flag_init( flag );

	assertEx( isdefined( level.deathSpawner[ trigger.script_deathChain ] ), "The objective event trigger for deathchain " + trigger.script_deathchain + " is not associated with any AI." );
	 /#
	if ( !isdefined( level.deathSpawner[ trigger.script_deathChain ] ) )
		return;
	#/
	while ( level.deathSpawner[ trigger.script_deathChain ] > 0 )
		level waittill( "spawner_expired" + trigger.script_deathChain );

	flag_set( flag );
}

setup_ai_eq_triggers()
{
	self endon( "death" );
	// ai placed in the level run their spawn func before the triggers are initialized
	waittillframeend;

	self.is_the_player = isplayer( self );
	self.eq_table = [];
	self.eq_touching = [];
	for ( i = 0; i < level.eq_trigger_num; i++ )
	{
		self.eq_table[ i ] = false;
	}
}

ai_array()
{
	level.ai_array[ level.unique_id ] = self;
	self waittill( "death" );
	waittillframeend;
	level.ai_array[ level.unique_id ] = undefined;
}

#using_animtree( "generic_human" );
spawner_dronespawn( spawner )
{
	drone = spawner spawnDrone();

	drone UseAnimTree( #animtree );
	
	if ( drone.weapon != "none" )
	{
		weapon_model = getWeaponModel( drone.weapon );
		drone attach( weapon_model, "tag_weapon_right" );
		
		hideTagList = GetWeaponHideTags( drone.weapon );
		for ( i = 0; i < hideTagList.size; i++ )
			drone HidePart( hideTagList[ i ], weapon_model );
	}

	drone.spawner = spawner;

	drone.drone_delete_on_unload = ( isdefined( spawner.script_noteworthy ) && spawner.script_noteworthy == "drone_delete_on_unload" );

	spawner notify( "drone_spawned", drone );
	return drone;
}

spawner_makerealai( drone )
{
	if ( !isdefined( drone.spawner ) )
	{
		println( " -- -- failed dronespawned guy info -- -- " );
		println( "drone.classname: " + drone.classname );
		println( "drone.origin   : " + drone.origin );
		assertmsg( "makerealai called on drone does with no .spawner" );
	}
	orgorg = drone.spawner.origin;
	organg = drone.spawner.angles;
	drone.spawner.origin = drone.origin;
	drone.spawner.angles = drone.angles;
	guy = drone.spawner stalingradspawn();

	failed = spawn_failed( guy );
	if ( failed )
	{
		println( " -- -- failed dronespawned guy info -- -- " );
		println( "failed guys spawn position : " + drone.origin );
		println( "failed guys spawner export key: " + drone.spawner.export );
		println( "getaiarray size is: " + getaiarray().size );
		println( " -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );
		assertMSG( "failed to make real ai out of drone( see console for more info )" );
	}

	guy.vehicle_idling = drone.vehicle_idling;
	guy.vehicle_position = drone.vehicle_position;
	guy.standing = drone.standing;
	guy.forceColor = drone.forceColor;

	
	drone.spawner.origin = orgorg;
	drone.spawner.angles = organg;
	drone delete();
	return guy;
}

death_achievements()
{
	self thread death_achievements_rappel_hack();
	
	self waittill( "death", attacker, type, weapon );

	if ( ! isdefined( self ) )
		return;// deleted
	if ( !self isBadGuy() )
		return;
	if ( ! isdefined( attacker ) )
		return;
		
//	thread achieve_ten_plus_hellfire( attacker );->moved to _REMOVEMISSLE
	
	//dont want these to include long death because it's not as obvious
	thread achieve_2_birds_1_stone( attacker, type );
	thread achieve_driveby( attacker );
	thread achieve_harder_they_fall( attacker );
	thread achieve_riotshield_melee( attacker, type );
	thread achieve_slowmo_breach_kills( attacker );
	thread achieve_downed_kills( attacker );
	thread achieve_stealth_knife( attacker, type );
	thread achieve_threesome( attacker, type, weapon );
	
	//long deaths
	if( isdefined( self.last_dmg_type ) )
		type = self.last_dmg_type;
		
	thread achieve_some_like_hot_thermal( attacker, type );
	thread achieve_one_man_army( attacker, type, weapon );
	thread achieve_akimbo( attacker, type );
}

death_achievements_rappel_hack()
{
	self waittill( "rope_death", attacker );
	
	if ( ! isdefined( self ) )
		return;// deleted
	
	thread achieve_harder_they_fall( attacker );
}

achieve_engineer_turret( attacker )
{
	if ( attacker.code_classname != "misc_turret" )
		return;
	if ( ! isdefined( attacker.owner ) )
		return;	
	if ( !isplayer( attacker.owner ) )
		return;
	
	if ( !isdefined( attacker.owner.achieve_engineer_turret ) )
		attacker.owner.achieve_engineer_turret = 1;
	else
		attacker.owner.achieve_engineer_turret++;
		
	if ( attacker.owner.achieve_engineer_turret == 10 )
		attacker.owner player_giveachievement_wrapper( "ENGINEER" );
}

achieve_ten_plus_hellfire( attacker )
{
	Bplayer = false;
	if( isplayer( attacker ) || ( isdefined( attacker.attacker ) && isplayer( attacker.attacker ) ) )
		Bplayer = true;
		
	if ( !Bplayer )
		return;
	if ( ! isdefined( attacker.is_controlling_UAV ) )
		return;
	
	if ( !isdefined( attacker.achieve_ten_plus_hellfire ) )
		attacker.achieve_ten_plus_hellfire = 1;
	else
		attacker.achieve_ten_plus_hellfire++;
		
	if ( attacker.achieve_ten_plus_hellfire == 10 )
		attacker player_giveachievement_wrapper( "TEN_PLUS_FOOT_MOBILES" );
		
	level notify( "achieve_ten_plus_hellfire" );
	level endon( "achieve_ten_plus_hellfire" );
	wait .5;
	attacker.achieve_ten_plus_hellfire = undefined;
}

achieve_key_master_shotgun( attacker, type )
{
	if ( ! isplayer( attacker ) )
		return;
	
	weapon = attacker getcurrentweapon();
	if ( ! isdefined( weapon ) )
	{
		attacker.achieve_key_master_shotgun = undefined;
		return;
	}
	
	if( weapon == "none" )
	{
		attacker.achieve_key_master_shotgun = undefined;
		return;
	}
	
	if ( weaponinventorytype( weapon ) != "altmode" )
	{
		attacker.achieve_key_master_shotgun = undefined;
		return;
	}
	
	class = weaponClass( weapon );
	if ( ! isdefined( class ) )
	{
		attacker.achieve_key_master_shotgun = undefined;
		return;
	}
	
	if( type != "MOD_PISTOL_BULLET" || class != "spread" )
	{
		attacker.achieve_key_master_shotgun = undefined;
		return;
	}
	
	if ( !isdefined( attacker.achieve_key_master_shotgun ) )
		attacker.achieve_key_master_shotgun = 1;
	else
		attacker.achieve_key_master_shotgun++;
	
	if ( attacker.achieve_key_master_shotgun == 5 )
		attacker player_giveachievement_wrapper( "KEY_MASTER" );
			
	level notify( "achieve_key_master_shotgun" );
	level endon( "achieve_key_master_shotgun" );
	
	wait 12;
	level.achieve_key_master_shotgun = undefined;
}

achieve_some_like_hot_thermal( attacker, type )
{
	if ( ! isplayer( attacker ) )
		return;
		
	weapon = attacker getcurrentweapon();
	if ( ! isdefined( weapon ) )
	{
		attacker.achieve_some_like_hot_thermal = undefined;
		return;
	}
	
	if( weapon == "none" )
	{
		attacker.achieve_some_like_hot_thermal = undefined;
		return;
	}
	
	if ( ! WeaponHasThermalScope( weapon ) )
	{
		attacker.achieve_some_like_hot_thermal = undefined;
		return;
	}
				
	if( !( type == "MOD_PISTOL_BULLET" || type == "MOD_RIFLE_BULLET" ) )
	{
		attacker.achieve_some_like_hot_thermal = undefined;
		return;
	}
	
	if ( !isdefined( attacker.achieve_some_like_hot_thermal ) )
		attacker.achieve_some_like_hot_thermal = 1;
	else
		attacker.achieve_some_like_hot_thermal++;
	
	if ( attacker.achieve_some_like_hot_thermal == 6 )
		attacker player_giveachievement_wrapper( "SOME_LIKE_IT_HOT" );
			
	level notify( "achieve_some_like_hot_thermal" );
	level endon( "achieve_some_like_hot_thermal" );
	
	wait 12;
	level.achieve_some_like_hot_thermal = undefined;
}

achieve_2_birds_1_stone( attacker, type )
{
	if ( ! isplayer( attacker ) )
		return;		
	if( !( type == "MOD_PISTOL_BULLET" || type == "MOD_RIFLE_BULLET" ) )
		return;

	if ( isdefined( attacker.drivingVehicle ) )
	{
		attacker.achieve_2_birds_1_stone = undefined;
		return;
	}
	
	if ( !isdefined( attacker.achieve_2_birds_1_stone ) )
		attacker.achieve_2_birds_1_stone = 1;
	else
		attacker.achieve_2_birds_1_stone++;
	
	if ( attacker.achieve_2_birds_1_stone == 2 )
		attacker player_giveachievement_wrapper( "TWO_BIRDS_WITH_ONE_STONE" );
	
	waittillframeend;
	attacker.achieve_2_birds_1_stone = undefined;
}

achieve_driveby( attacker )
{
	if ( ! isplayer( attacker ) )
		return;		
	
	if ( ! isdefined( attacker.drivingVehicle ) )
	{
		attacker.achieve_driveby = undefined;
		return;
	}
	
	if ( !isdefined( attacker.achieve_driveby ) )
		attacker.achieve_driveby = 1;
	else
		attacker.achieve_driveby++;
	
	if ( attacker.achieve_driveby == 20 )
		attacker player_giveachievement_wrapper( "DRIVE_BY" );
}

achieve_harder_they_fall( attacker )
{
	if( isdefined( self.achieve_harder_they_fall ) )
		return;
	self.achieve_harder_they_fall = 1;
		
	if ( ! isplayer( attacker ) )
		return;		
	
	if ( ! isdefined( self.rappeller ) )
	{
		attacker.achieve_harder_they_fall = undefined;
		return;
	}
	
	if ( !isdefined( attacker.achieve_harder_they_fall ) )
		attacker.achieve_harder_they_fall = 1;
	else
		attacker.achieve_harder_they_fall++;
	
	if ( attacker.achieve_harder_they_fall == 2 )
		attacker player_giveachievement_wrapper( "THE_HARDER_THEY_FALL" );
	
	level notify( "achieve_harder_they_fall" );
	level endon( "achieve_harder_they_fall" );
	
	wait 12;
	attacker.achieve_harder_they_fall = undefined;
}

achieve_riotshield_melee( attacker, type )
{
	if ( !isplayer( attacker ) )
		return;
	if ( type != "MOD_MELEE" )
		return;

	weapon = attacker getcurrentweapon();
	if ( ! isdefined( weapon ) )
		return;
	if( weapon != "riotshield" )
		return;
		
	attacker player_giveachievement_wrapper( "UNNECESSARY_ROUGHNESS" );
}

achieve_slowmo_breach_kills( attacker )
{
	if ( !isplayer( attacker ) )
		return;
	if ( !isdefined( attacker.isbreaching ) )
	{
		attacker.achieve_slowmo_breach_kills = undefined;
		return;	
	}
	
	if ( !isdefined( attacker.achieve_slowmo_breach_kills ) )
		attacker.achieve_slowmo_breach_kills = 1;
	else
		attacker.achieve_slowmo_breach_kills++;
	
	//wait a second to make sure the player didn't fire off a 5th shot in a reasonable amount of time
	wait .1;
	
	//killed a hostage
	if( !isdefined( attacker.achieve_slowmo_breach_kills ) )
		return;
	
	if ( attacker.achieve_slowmo_breach_kills == 4 && attacker.breaching_shots_fired <= 4 )
		attacker player_giveachievement_wrapper( "KNOCK_KNOCK" );
}

achieve_downed_kills( attacker )
{
	if ( !isplayer( attacker ) )
		return;
	if ( !attacker.laststand )
	{
		attacker.achieve_downed_kills = undefined;
		return;	
	}
	
	if ( !isdefined( attacker.achieve_downed_kills ) )
		attacker.achieve_downed_kills = 1;
	else
		attacker.achieve_downed_kills++;
		
	if ( attacker.achieve_downed_kills == 4 )
		attacker player_giveachievement_wrapper( "DOWNED_BUT_NOT_OUT" );
}

achieve_one_man_army( attacker, type, weapon )
{
	if ( !isplayer( attacker ) )
		return;
			
	if ( ! isdefined( weapon ) )
	{
		if( attacker isusingturret() )
		{
			weapon = "turret";
		}		
		else
		{
			attacker.achieve_one_man_army = [];
			return;
		}
	}
	else
	if( type == "MOD_MELEE" && weapon != "riotshield" )
		weapon = "knife";
		
	if ( !isdefined( attacker.achieve_one_man_army ) )
		attacker.achieve_one_man_army = [];

	foreach( weap in attacker.achieve_one_man_army )
	{
		if( weapon != weap )
			continue;
		attacker.achieve_one_man_army = [];
	}
		
	attacker.achieve_one_man_army[ attacker.achieve_one_man_army.size ] = weapon;
	
	if( attacker.achieve_one_man_army.size == 5 )
		attacker player_giveachievement_wrapper( "ONE_MAN_ARMY" );
}

achieve_akimbo( attacker, type )
{
	if ( !isplayer( attacker ) )
		return;
	
	if( !( attacker isDualWielding() ) )
	{
		attacker.achieve_akimbo = undefined;
		return;
	}

	if( !( type == "MOD_PISTOL_BULLET" || type == "MOD_RIFLE_BULLET" ) )
	{
		attacker.achieve_akimbo = undefined;
		return;
	}	
	
	if ( !isdefined( attacker.achieve_akimbo ) )
		attacker.achieve_akimbo = 1;
	else
		attacker.achieve_akimbo++;
	
	if ( attacker.achieve_akimbo == 10 )
		attacker player_giveachievement_wrapper( "LOOK_MA_TWO_HANDS" );
}

achieve_stealth_knife( attacker, type )
{
	if ( !isplayer( attacker ) )
		return;
	if ( type != "MOD_MELEE" )
		return;
	if ( ! self ent_flag_exist( "_stealth_normal" ) )
		return;
	if ( ! self ent_flag( "_stealth_normal" ) )
		return;
	if ( isdefined( self.lastenemysightpos ) )
		return;
	if ( isdefined( self.lastenemysighttime ) && self.lastenemysighttime > 0 )
		return;
			
	attacker player_giveachievement_wrapper( "NO_REST_FOR_THE_WARY" );
}

achieve_threesome( attacker, type, weapon )
{
	if ( !isplayer( attacker ) )
		return;
	
	if( type != "MOD_GRENADE_SPLASH" )
	{
		attacker.achieve_threesome = undefined;
		return;
	}
	
	if( !isdefined( weapon ) )
	{
		attacker.achieve_threesome = undefined;
		return;
	}
	
	if( weaponinventorytype( weapon ) == "offhand" )
	{
		attacker.achieve_threesome = undefined;
		return;	
	}
		
	if ( !isdefined( attacker.achieve_threesome ) )
		attacker.achieve_threesome = 1;
	else
		attacker.achieve_threesome++;
	
	if ( attacker.achieve_threesome == 3 )
		attacker player_giveachievement_wrapper( "THREESOME" );
	
	waittillframeend;
	attacker.achieve_threesome = undefined;
}

add_random_killspawner_to_spawngroup()
{
	assertex( isdefined( self.script_randomspawn ), "Spawner at origin " + self.origin + " has no script_randomspawn!" );
	spawngroup = self.script_random_killspawner;
	subgroup = self.script_randomspawn;

	if ( !isdefined( level.killspawn_groups[ spawngroup ] ) )
		level.killspawn_groups[ spawngroup ] = [];

	if ( !isdefined( level.killspawn_groups[ spawngroup ][ subgroup ] ) )
		level.killspawn_groups[ spawngroup ][ subgroup ] = [];

	level.killspawn_groups[ spawngroup ][ subgroup ][ self.export ] = self;
}

add_to_spawngroup()
{
	assertex( isdefined( self.script_spawnsubgroup ), "Spawner at origin " + self.origin + " has no script_spawnsubgroup!" );
	spawngroup = self.script_spawngroup;
	subgroup = self.script_spawnsubgroup;

	if ( !isdefined( level.spawn_groups[ spawngroup ] ) )
		level.spawn_groups[ spawngroup ] = [];

	if ( !isdefined( level.spawn_groups[ spawngroup ][ subgroup ] ) )
		level.spawn_groups[ spawngroup ][ subgroup ] = [];

	level.spawn_groups[ spawngroup ][ subgroup ][ self.export ] = self;
}

start_off_running()
{
	self endon( "death" );
	self.disableexits = true;
	wait( 3 );
	self.disableexits = false;
}

deathtime()
{
	self endon( "death" );
	wait( self.script_deathtime );
	wait( randomfloat( 10 ) );
	self kill();	
}