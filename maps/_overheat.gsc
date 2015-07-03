#include maps\_hud_util;
#include maps\_utility;
#include common_scripts\utility;

TURRET_HEAT_MAX = 114;// Dont touch

// Tweaks
TURRET_HEAT_RATE = 1.0;					// Rate that the gun overheats( high number means faster overheat )
TURRET_COOL_RATE = 1.0;					// Rate that the gun cools down( higher number means it cools off faster )
OVERHEAT_TIME = 2.0;					// Time to flash the overheat meter
OVERHEAT_FLASH_TIME = 0.2;				// When the gun first overheats the status bar blinks at this rate
OVERHEAT_FLASH_TIME_INCREMENT = 0.1;	// Each time the status bar blinks it increments by this much each blink( causes it to blink slower as the overheat period runs out )
GUN_USAGE_DELAY_AFTER_OVERHEAT = 2.0;	// Once you have overheated the gun waits this amount of time before turning on again

init_overheat()
{
	precacheShader( "hud_temperature_gauge" );
}

overheat_enable( vehicle )
{
	assert( isPlayer( self ) );
	assert( isdefined( vehicle ) );
	assert( vehicle.classname == "script_vehicle" );

	assertEx( !isdefined( self.overheat ), "Tried to call overheat_enable() on a player that is already doing overheat logic." );

	if ( isdefined( self.overheat ) )
		return;

	self.overheat = spawnStruct();
	self.overheat.turret_heat_status = 1;
	self.overheat.overheated = false;

	self thread create_hud();
	self thread status_meter_update( vehicle );
}

overheat_disable()
{
	assert( isPlayer( self ) );

	self notify( "disable_overheat" );
	level.savehere = undefined;

	waittillframeend;

	if ( isdefined( self.overheat.overheat_bg ) )
		self.overheat.overheat_bg destroy();
	if ( isdefined( self.overheat.overheat_status ) )
		self.overheat.overheat_status destroy();

	self.overheat = undefined;
}

status_meter_update( vehicle )
{
	// Notify doesn't work the way Ned is doing his vehicle ride so this hacked with attackButtonPressed() for now

	self endon( "disable_overheat" );

	for ( ;; )
	{
		//iprintln( self.overheat.turret_heat_status );

		if ( self.overheat.turret_heat_status >= TURRET_HEAT_MAX )
		{
			wait 0.05;
			continue;
		}

		if ( self attackButtonPressed() && !self.overheat.overheated )
			self.overheat.turret_heat_status += TURRET_HEAT_RATE;
		else
			self.overheat.turret_heat_status -= TURRET_COOL_RATE;

		self.overheat.turret_heat_status = cap_value( self.overheat.turret_heat_status, 1, TURRET_HEAT_MAX );

		self update_overheat_meter();
		self thread overheated( vehicle );

		wait 0.05;
	}
}

update_overheat_meter()
{
	self.overheat.overheat_status scaleOverTime( 0.05, 10, int( self.overheat.turret_heat_status ) );
	self thread overheat_setColor( self.overheat.turret_heat_status, 0.05 );
}

create_hud()
{
	//Draw the temperature gauge and filler bar components

	self endon( "disable_overheat" );

	coopOffset = 0;
	if ( is_coop() )
		coopOffset = 70;
	barX = -10;
	barY = -152 + coopOffset;
	
	if ( !isdefined( self.overheat.overheat_bg ) )
	{
		self.overheat.overheat_bg = newClientHudElem( self );
		self.overheat.overheat_bg.alignX = "right";
		self.overheat.overheat_bg.alignY = "bottom";
		self.overheat.overheat_bg.horzAlign = "right";
		self.overheat.overheat_bg.vertAlign = "bottom";
		self.overheat.overheat_bg.x = 2;
		self.overheat.overheat_bg.y = -120 + coopOffset;
		self.overheat.overheat_bg setShader( "hud_temperature_gauge", 35, 150 );
		self.overheat.overheat_bg.sort = 4;
	}

	//status bar
	if ( !isdefined( self.overheat.overheat_status ) )
	{
		self.overheat.overheat_status = newClientHudElem( self );
		self.overheat.overheat_status.alignX = "right";
		self.overheat.overheat_status.alignY = "bottom";
		self.overheat.overheat_status.horzAlign = "right";
		self.overheat.overheat_status.vertAlign = "bottom";
		self.overheat.overheat_status.x = barX;
		self.overheat.overheat_status.y = barY;
		self.overheat.overheat_status setShader( "white", 10, 1 );
		self.overheat.overheat_status.color = ( 1, .9, 0 );
		self.overheat.overheat_status.alpha = 1;
		self.overheat.overheat_status.sort = 1;
	}
}

overheated( vehicle )
{
	self endon( "disable_overheat" );

	if ( self.overheat.turret_heat_status < TURRET_HEAT_MAX )
		return;

	if ( self.overheat.overheated )
		return;
	self.overheat.overheated = true;

	// Gun has overheated

	level.savehere = false;
	self thread play_sound_on_entity( "smokegrenade_explode_default" );

	self.overheat.turret_heat_status = TURRET_HEAT_MAX;

	if ( isdefined( vehicle.mgturret ) )
		vehicle.mgturret[ 0 ] turretFireDisable();

	time = getTime();

	flashTime = OVERHEAT_FLASH_TIME;
	for ( ;; )
	{
		self.overheat.overheat_status fadeovertime( flashTime );
		self.overheat.overheat_status.alpha = 0.2;
		wait flashTime;
		self.overheat.overheat_status fadeovertime( flashTime );
		self.overheat.overheat_status.alpha = 1.0;
		wait flashTime;

		flashTime += OVERHEAT_FLASH_TIME_INCREMENT;

		if ( getTime() - time >= OVERHEAT_TIME * 1000 )
			break;
	}
	self.overheat.overheat_status.alpha = 1.0;

	// Start cooldown again
	self.overheat.turret_heat_status -= TURRET_COOL_RATE;

	// wait for it to cool down a bit
	wait GUN_USAGE_DELAY_AFTER_OVERHEAT;

	// Make gun usable
	if ( isdefined( vehicle.mgturret ) )
		vehicle.mgturret[ 0 ] turretFireEnable();

	level.savehere = undefined;
	self.overheat.overheated = false;
}

overheat_setColor( value, fadeTime )
{
	self endon( "disable_overheat" );

	//define what colors to use
	color_cold = [];
	color_cold[ 0 ] = 1.0;
	color_cold[ 1 ] = 0.9;
	color_cold[ 2 ] = 0.0;
	color_warm = [];
	color_warm[ 0 ] = 1.0;
	color_warm[ 1 ] = 0.5;
	color_warm[ 2 ] = 0.0;
	color_hot = [];
	color_hot[ 0 ] = 0.9;
	color_hot[ 1 ] = 0.16;
	color_hot[ 2 ] = 0.0;

	//default color
	CurrentColor = [];
	CurrentColor[ 0 ] = color_cold[ 0 ];
	CurrentColor[ 1 ] = color_cold[ 1 ];
	CurrentColor[ 2 ] = color_cold[ 2 ];

	//define where the non blend points are
	cold = 0;
	warm = ( TURRET_HEAT_MAX / 2 );
	hot = TURRET_HEAT_MAX;

	iPercentage = undefined;
	difference = undefined;
	increment = undefined;

	if ( ( value > cold ) && ( value <= warm ) )
	{
		iPercentage = int( value * ( 100 / warm ) );
		for ( colorIndex = 0 ; colorIndex < CurrentColor.size ; colorIndex++ )
		{
			difference = ( color_warm[ colorIndex ] - color_cold[ colorIndex ] );
			increment = ( difference / 100 );
			CurrentColor[ colorIndex ] = color_cold[ colorIndex ] + ( increment * iPercentage );
		}
	}
	else if ( ( value > warm ) && ( value <= hot ) )
	{
		iPercentage = int( ( value - warm ) * ( 100 / ( hot - warm ) ) );
		for ( colorIndex = 0 ; colorIndex < CurrentColor.size ; colorIndex++ )
		{
			difference = ( color_hot[ colorIndex ] - color_warm[ colorIndex ] );
			increment = ( difference / 100 );
			CurrentColor[ colorIndex ] = color_warm[ colorIndex ] + ( increment * iPercentage );
		}
	}

	if ( isdefined( fadeTime ) )
		self.overheat.overheat_status fadeOverTime( fadeTime );

	if ( isdefined( self.overheat.overheat_status.color ) )
		self.overheat.overheat_status.color = ( CurrentColor[ 0 ], CurrentColor[ 1 ], CurrentColor[ 2 ] );
}