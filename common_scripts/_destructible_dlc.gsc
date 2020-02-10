#include common_scripts\utility;
#include common_scripts\_destructible;

main()
{
	/#
	level.created_destructibles = [];
	#/

	if ( !isdefined( level.func ) )
	{
		// this array will be filled with code commands that SP or MP may use but doesn't exist in the other.
		level.func = [];
	}
	
	//---------------------------------------------------------------------
	// Find all new DLC destructibles by their targetnames and run the setup
	//---------------------------------------------------------------------

//	array_thread( GetEntArray( "destructible_vehicle", "targetname" ), ::setup_destructibles );

	//assuring orders -nate
	vehicles = GetEntArray( "destructible_vehicle", "targetname" );
	foreach ( vehicle in vehicles )
		vehicle setup_destructibles_dlc();

	destructible_toy = GetEntArray( "destructible_toy", "targetname" );
	foreach ( toy in destructible_toy )
		toy setup_destructibles_dlc();

	/#
	total = 0;
	if ( GetDvarInt( "destructibles_locate" ) > 0 )
	{
		// Print out the destructibles we created and where they are all located
		PrintLn( "##################" );
		PrintLn( "DESTRUCTIBLE LIST:" );
		PrintLn( "##################" );
		PrintLn( "" );

		keys = GetArrayKeys( level.created_destructibles );
		foreach ( key in keys )
		{
			PrintLn( key + ": " + level.created_destructibles[ key ].size );
			total += level.created_destructibles[ key ].size;
		}
		PrintLn( "" );
		PrintLn( "Total: " + total );
		PrintLn( "" );
		PrintLn( "Locations:" );

		foreach ( key in keys )
		{
			foreach ( destructible in level.created_destructibles[ key ] )
			{
				PrintLn( key + ": " + destructible.origin );
				//destructible thread maps\_debug::drawOrgForever();
			}
		}

		PrintLn( "" );
		PrintLn( "##################" );
		PrintLn( "##################" );
		PrintLn( "##################" );

		level.created_destructibles = undefined;
	}
	#/

}


setup_destructibles_dlc( cached )
{
	if ( !isdefined( cached ) )
		cached = false;

	//---------------------------------------------------------------------
	// Figure out what destructible information this entity should use
	//---------------------------------------------------------------------
	destuctableInfo = undefined;
	AssertEx( IsDefined( self.destructible_type ), "Destructible object with targetname 'destructible' does not have a 'destructible_type' key / value" );

	self.modeldummyon = false;// - nate added for vehicle dummy stuff. This is so I can turn a destructible into a dummy and throw it around on jeepride.
	self add_damage_owner_recorder();	// Mackey added to track who is damaging the car

	self.destuctableInfo = common_scripts\_destructible_types_dlc::makeType_dlc( self.destructible_type );
	
	if ( !isdefined( self.destuctableInfo ) )
	{
		// must be old destructible
		return;
	}
			
	//println( "### DESTRUCTIBLE ### assigned infotype index: " + self.destuctableInfo );
	if ( self.destuctableInfo < 0 )
		return;

	// change the targetname so the real _destructible script doesn't try to process the new destructibles
	self.targetname = self.targetname + "_dlc";

	/#
	// Store what destructibles we create and where they are located so we can get a list in the console
	if ( !isdefined( level.created_destructibles[ self.destructible_type ] ) )
		level.created_destructibles[ self.destructible_type ] = [];
	nextIndex = level.created_destructibles[ self.destructible_type ].size;
	level.created_destructibles[ self.destructible_type ][ nextIndex ] = self;
	#/

	if ( !cached )
		precache_destructibles();

	add_destructible_fx();

	//---------------------------------------------------------------------
	// Attach all parts to the entity
	//---------------------------------------------------------------------
	if ( IsDefined( level.destructible_type[ self.destuctableInfo ].parts ) )
	{
		self.destructible_parts = [];
		for ( i = 0; i < level.destructible_type[ self.destuctableInfo ].parts.size; i++ )
		{
			// create the struct where the info for each entity will be held
			self.destructible_parts[ i ] = SpawnStruct();

			// set it's current state to 0 since it has never taken damage yet and will be on it's first state
			self.destructible_parts[ i ].v[ "currentState" ] = 0;

			// if it has a health value then store it's value
			if ( IsDefined( level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "health" ] ) )
				self.destructible_parts[ i ].v[ "health" ] = level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "health" ];

			// find random attachements such as random advertisements on taxi cabs and attach them now
			if ( IsDefined( level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "random_dynamic_attachment_1" ] ) )
			{
				randAttachmentIndex = RandomInt( level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "random_dynamic_attachment_1" ].size );
				attachTag = level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "random_dynamic_attachment_tag" ][ randAttachmentIndex ];
				attach_model_1 = level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "random_dynamic_attachment_1" ][ randAttachmentIndex ];
				attach_model_2 = level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "random_dynamic_attachment_2" ][ randAttachmentIndex ];
				clipToRemove = level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "clipToRemove" ][ randAttachmentIndex ];
				self thread do_random_dynamic_attachment( attachTag, attach_model_1, attach_model_2, clipToRemove );
			}

			// continue if it's the base model since its not an attached part
			if ( i == 0 )
				continue;

			// attach the part now
			modelName = level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "modelName" ];
			tagName = level.destructible_type[ self.destuctableInfo ].parts[ i ][ 0 ].v[ "tagName" ];

			stateIndex = 1;
			while ( IsDefined( level.destructible_type[ self.destuctableInfo ].parts[ i ][ stateIndex ] ) )
			{
				stateTagName = level.destructible_type[ self.destuctableInfo ].parts[ i ][ stateIndex ].v[ "tagName" ];
				stateModelName = level.destructible_type[ self.destuctableInfo ].parts[ i ][ stateIndex ].v[ "modelName" ];
				if ( IsDefined( stateTagName ) && stateTagName != tagName )
				{
					self hideapart( stateTagName );
					if ( self.modeldummyon )
						self.modeldummy hideapart( stateTagName );
				}
				stateIndex++;
			}
		}
	}

	// some destructibles have collision that needs to change due to the large change in the destructible when it blows pu
	if ( IsDefined( self.target ) )
		thread destructible_handles_collision_brushes();

	//---------------------------------------------------------------------
	// Make this entity take damage and wait for events
	//---------------------------------------------------------------------
	if ( self.code_classname != "script_vehicle" )
		self SetCanDamage( true );
	if ( isSP() )
		self thread connectTraverses();
	self thread destructible_think();
}
