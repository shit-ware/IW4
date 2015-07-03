#include maps\mp\_utility;
#include common_scripts\utility;

main()
{
	maps\mp\mp_highrise_precache::main();
	maps\createart\mp_highrise_art::main();
	maps\mp\mp_highrise_fx::main();
	maps\mp\_explosive_barrels::main();
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_mp_highrise" );
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.11 );
	setdvar( "r_lightGridContrast", .9 );

	VisionSetNaked( "mp_highrise" );
	ambientPlay( "embient_mp_highrise" );

	game[ "attackers" ] = "axis";
	game[ "defenders" ] = "allies";
	
	// raise up planes to avoid them flying through buildings
	level.airstrikeHeightScale = 3;

	setdvar( "compassmaxrange", "2100" );
	//thread Elevator( "elev1" );
	//thread Elevator( "elev2" );
	//thread Elevator( "elev3" );	
	//thread Elevator( "elev4" );

	//thread SetupRappel();
}

Elevator( elevatorID )
{
	elevator = getent( elevatorID, "targetname" );
	elevFloors = [];
	elevFloors[ 0 ] = getent( elevatorID + "_floor1", "targetname" ).origin;
	elevFloors[ 1 ] = getent( elevatorID + "_floor2", "targetname" ).origin;

	moveSpeed = 192;// units / second

	waitTime = 2.0;

	floorIndex = 0;
	while ( 1 )
	{
		newPos = elevFloors[ floorIndex ];
		moveDist = distance( elevator.origin, newPos );
		if ( moveDist <= 0.0 )
		{
			floorIndex = ( floorIndex + 1 ) % elevFloors.size;
			continue;
		}
		moveTime = moveDist / moveSpeed;
		elevator moveTo( newPos, moveTime, moveTime * 0.25, moveTime * 0.25 );

		floorIndex = ( floorIndex + 1 ) % elevFloors.size;

		wait moveTime + waitTime;
	}
}



SetupRappel()
{
	// Press and hold ^3[{+activate}]^7 to rappel
	//precacheString( &"MP_PRESS_TO_RAPPEL" );
	trigs = getentarray( "rappeltrigger", "targetname" );
	foreach ( trig in trigs )
	{
		org = getent( trig.target, "targetname" );
		trig.rappelPoint = org.origin;
		trig.dir = anglesToForward( org.angles );
		org delete();
		trig thread RappelThink();
	}
	foreach ( trig in trigs )
	{
		org = getent( trig.target, "targetname" );
		if ( isdefined( org ) )
			org delete();
	}
}

RappelThink()
{
	// Press and hold ^3[{+activate}]^7 to rappel
	//self setHintString( &"MP_PRESS_TO_RAPPEL" );

	while ( 1 )
	{
		self waittill( "trigger", player );
		if ( !isPlayer( player ) )
			continue;

		if ( !player isOnGround() )
			continue;

		if ( isdefined( player.rapelling ) )
			continue;

		player thread Rappel( self );
	}
}

Rappel( trig )
{
	toRappelPoint = trig.rappelPoint - self.origin;
	rappelPoint = self.origin + vectordot( toRappelPoint, trig.dir ) * trig.dir;
	rappelPoint = ( rappelPoint[ 0 ], rappelPoint[ 1 ], trig.rappelPoint[ 2 ] );

	upTime = .5;// sec
	overTime = .75;// sec
	downSpeed = 512;// units / sec

	upPoint = self.origin;
	upPoint = ( upPoint[ 0 ], upPoint[ 1 ], rappelPoint[ 2 ] );
	overPoint = rappelPoint + trig.dir * 20;
	tracePosition = playerPhysicsTrace( overPoint, overPoint + ( 0, 0, -10000 ), false, self );
	downPoint = tracePosition + ( 0, 0, 16 );

	org = spawn( "script_origin", self.origin );
	org hide();

	self.rapelling = true;
	self _disableWeapon();
	self linkto( org );
	self PlayerLinkedOffsetEnable();

	org moveto( upPoint, upTime, 0, 0 );
	org waittill( "movedone" );
	org moveto( overPoint, overTime, 0, 0 );
	org waittill( "movedone" );

	downTime = distance( overPoint, downPoint ) / downSpeed;

	org moveto( downPoint, downTime, 0, 0 );
	org waittill( "movedone" );

	self _enableWeapon();
	self unlink();
	org delete();

	self.rapelling = undefined;
}




