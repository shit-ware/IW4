#include common_scripts\utility;
#include maps\_utility;
#include maps\_stealth_utility;
#include maps\_anim;
#include maps\_props;

create_animation_list()
{
	array = [];
	array[ array.size ] = "phone";		// 0
	array[ array.size ] = "smoke";		// 1
	array[ array.size ] = "lean_smoke";	// 2
	array[ array.size ] = "coffee";		// 3
	array[ array.size ] = "sleep";		// 4
	array[ array.size ] = "sit_load_ak";	// 5

	return array;
}

idle_main()
{
	level.global_callbacks[ "_idle_call_idle_func" ] = ::idle;
}

idle()
{
	//->since this system works with the stealth system - we want to make sure that _stealth has had a chance
	//to be initialized...if it's done through radient it will be, but if it's done through script with a 
	//spawn_func, then it will initalize after this causing problems...this waittillframeend insures that the
	//spawn_func for stealth apps has a chance to run before this does.
	waittillframeend;
	
	//the waittillframeend ( which is necessary ) is just enough time for this guy to be deleted from max 32 ai over-spawning.
	if( !isalive( self ) )
		return;
	
	node = undefined;

	if ( !isdefined( self.target ) )
		node = self;
	else
	{
		node 	 = getnode( self.target, "targetname" );
		ent 	 = getent( self.target, "targetname" );
		struct 	 = getstruct( self.target, "targetname" );
		getfunc = undefined;

		if ( isdefined( node ) )
			getfunc = ::get_node;
		else if ( isdefined( ent ) )
			getfunc = ::get_ent;
		else if ( isdefined( struct ) )
			getfunc = ::getstruct;

		node = [[ getfunc ]]( self.target, "targetname" );

		while ( isdefined( node.target ) )
			node = [[ getfunc ]]( node.target, "targetname" );
	}

	anime = node.script_animation;
	if ( !isdefined( anime ) )
		anime = "random";

	if ( !check_animation( anime, node ) )
		return;

	if ( anime == "random" )
	{
		anime = create_random_animation();
		node.script_animation = anime;
	}
	idle_anim = anime + "_idle";
	react_anim = anime + "_react";

	self thread idle_proc( node, idle_anim, react_anim );
}

idle_reach_node( node, idle_anim )
{
	self endon( "death" );
	self endon( "stop_idle_proc" );

	if ( isdefined( self._stealth ) )
	{
		level add_wait( ::flag_wait, self stealth_get_group_spotted_flag() );
		if( isdefined( self._stealth.plugins.corpse ) )
		{
			level add_wait( ::flag_wait, self stealth_get_group_corpse_flag() );
			self add_wait( ::ent_flag_wait, "_stealth_saw_corpse" );
		}
	}	
	else
		self add_wait( ::waittill_msg, "enemy" );

	self add_func( ::send_notify, "stop_idle_proc" );
	self thread do_wait_any();

	if ( isdefined( self.script_patroller ) )
		self waittill( "_patrol_reached_path_end" );
	else
		node anim_generic_reach( self, idle_anim );
}

idle_proc( node, idle_anim, react_anim )
{
	self.allowdeath = true;

	self endon( "death" );

	if ( isdefined( self.script_idlereach ) )
	{
		self endon( "stop_idle_proc" );
		self idle_reach_node( node, idle_anim );
	}

	if ( isdefined( self.script_idlereach ) )
	{
		self.script_animation = node.script_animation;
		node = self;
	}


	if ( node.script_animation == "sit_load_ak" )
	{
		chair = spawn_anim_model( "chair_ak" );
		self.has_delta = true;
		self.anim_props = make_array( chair );
		node thread anim_first_frame_solo( chair, "sit_load_ak_react" );
	}
	
	if( node.script_animation == "lean_smoke" )
		self thread attach_cig_self();
	
	if ( node.script_animation == "sleep" )
	{
		chair = spawn_anim_model( "chair" );
		self.has_delta = true;
		self.anim_props = make_array( chair );
		node thread anim_first_frame_solo( chair, "sleep_react" );
		self thread reaction_sleep();
	}

	node script_delay();

	if ( isdefined( self._stealth ) )
	{
		node stealth_ai_idle_and_react( self, idle_anim, react_anim );
		return;
	}

	ender = "stop_loop";
	node thread anim_generic_loop( self, idle_anim, ender );
	self thread animate_props_on_death( node, react_anim );
	self thread reaction_proc( node, ender, react_anim );
}

reaction_sleep()
{
	self endon( "death" );

	self.ignoreall = true;

	self reaction_sleep_wait_wakeup();

	self.ignoreall = false;
}

reaction_sleep_wait_wakeup()
{
	self endon( "death" );
	
	if ( isdefined( self._stealth ) )
	{
		self thread stealth_enemy_endon_alert();
		self endon( "stealth_enemy_endon_alert" );
	}

	dist = 70;
	array_thread( level.players, ::reaction_sleep_wait_wakeup_dist, self, dist );

	self waittill( "_idle_reaction" );
}

reaction_sleep_wait_wakeup_dist( guy, dist )
{
	guy endon( "death" );
	guy endon( "_idle_reaction" );
	self endon( "death" );
	guy endon( "enemy" );

	distsqrd = dist * dist;

	while ( 1 )
	{
		while ( distancesquared( self.origin, guy.origin ) > distsqrd )
			wait .1;
		guy.ignoreall = false;

		while ( distancesquared( self.origin, guy.origin ) <= distsqrd )
			wait .1;
		guy.ignoreall = true;
	}
}

reaction_proc( node, ender, react_anim, tag )
{
	self endon( "death" );

	self thread reaction_wait( "enemy" );
	self thread reaction_wait( "stop_idle_proc" );
	self thread reaction_wait( "react" );
	self thread reaction_wait( "doFlashBanged" );
	self thread reaction_wait( "explode" );

	type = undefined;
	self waittill( "_idle_reaction", type );

	// cut the loop
	node notify( ender );

	if ( isdefined( self.anim_props ) )
	{
		self.anim_props_animated = true;
		node thread anim_single( self.anim_props, react_anim );
	}

	if ( type == "stop_idle_proc" )
	{
		self anim_stopanimscripted();
		return;
	}

	if ( type != "doFlashBanged" )
	{
		// this is the reaction
		if ( isdefined( tag ) || isdefined( self.has_delta ) )
			node anim_generic( self, react_anim, tag );
		else
			node anim_generic_custom_animmode( self, "gravity", react_anim );
	}
}

reaction_wait( msg )
{
	self waittill( msg );
	self notify( "_idle_reaction", msg );
}

animate_props_on_death( node, anime )
{
	if ( !isdefined( self.anim_props ) )
		return;

	prop = self.anim_props;

	self waittill( "death" );

	if ( isdefined( self.anim_props_animated ) )
		return;

	node thread anim_single( prop, anime );
}

create_random_animation()
{
	array = create_animation_list();
	//never return sleep, lean smoke, coffee, or sit_load_ak as a random animation
	return array[ randomint( array.size - 4 ) ];
}

check_animation( anime, node )
{
	array = create_animation_list();

	if ( anime == "random" )
	{
		array2 = [];
		for ( i = 0; i < array.size; i++ )
		{
			if ( !isdefined( level.scr_anim[ "generic" ][ array[ i ] + "_react" ] ) )
				array2[ array2.size ] = array[ i ];
		}

		if ( !array2.size )
			return true;

		println( " -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );
		println( " -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );
		println( " -- -- - add these lines to your level script AFTER maps\\\_load::main(); -- -- -- -- -- -- - " );
		for ( i = 0; i < array2.size; i++ )
			println( "maps\\\_idle_" + array2[ i ] + "::main();" );
		println( " -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );
		println( " -- -- -- -- -- -- -- -- -- -- -- -- - hint copy paste them from console.log -- -- -- -- -- -- -- -- -- -- " );
		println( " -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );
		assertEX( false, "missing _idle scripts, see above console prints" );

		return false;
	}

	for ( i = 0; i < array.size; i++ )
	{
		if ( array[ i ] == anime )
		{
			if ( !isdefined( level.scr_anim[ "generic" ][ anime + "_react" ] ) )
			{
				println( " -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );
				println( " -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );
				println( " -- -- - add these lines to your level script AFTER maps\\\_load::main(); -- -- -- -- -- -- - " );
				println( "maps\\\_idle_" + anime + "::main();" );
				println( " -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );
				println( " -- -- -- -- -- -- -- -- -- -- -- -- - hint copy paste them from console.log -- -- -- -- -- -- -- -- -- -- " );
				println( " -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );
				assertEX( false, "missing _idle scripts, see above console prints" );

				return false;
			}

			return true;
		}
	}

	msg = "";
	for ( i = 0; i < array.size; i++ )
		msg = msg + array[ i ] + ", ";
	msg = msg + "and random.";

	assertmsg( "node at (" + node.origin[ 0 ] + ", " + node.origin[ 1 ] + ", " + node.origin[ 2 ] + ") using the maps\_idle:: system with script_animation set to " + anime + ", which isn't valid. Valid names are " + msg );
	return false;
}

get_ent( name, type )
{
	return getent( name, type );
}

get_node( name, type )
{
	return getnode( name, type );
}