#include maps\mp\_utility;

init()
{
	level.healthOverlayCutoff = 0.55;
	
	regenTime = 5;
	regenTime = maps\mp\gametypes\_tweakables::getTweakableValue( "player", "healthregentime" );
	
	level.playerHealth_RegularRegenDelay = regenTime * 1000;
	
	level.healthRegenDisabled = (level.playerHealth_RegularRegenDelay <= 0);
	
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);

		player thread onPlayerSpawned();
	}
}


onPlayerSpawned()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("spawned_player");
		self thread playerHealthRegen();
		
		self thread showTempDamage();
	}
}


showTempDamage()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	/#
	setDevDvar( "scr_damage_wait", 0 );
	setDevDvar( "scr_damage_fadein", 0.25 );
	setDevDvar( "scr_damage_fadeout", 0.5 );
	setDevDvar( "scr_damage_holdtime", 0.5 );
	setDevDvar( "scr_damage_numfades", 5 );
	
	for ( ;; )
	{
		while ( getDvarFloat( "scr_damage_wait" ) <= 0 )
			wait ( 1.0 );
			
		wait ( getDvarFloat( "scr_damage_wait" ) );
		
		for ( i = 0; i < getDvarInt( "scr_damage_numfades" ); i++ )
		{
			self VisionSetNakedForPlayer( "mp_crash_damage", getDvarFloat( "scr_damage_fadein" ) * (getDvarInt( "scr_damage_numfades" ) - i) );
			wait ( getDvarFloat( "scr_damage_fadein" ) + getDvarFloat( "scr_damage_holdtime" ) );
			self VisionSetNakedForPlayer( "mp_crash", getDvarFloat( "scr_damage_fadeout" ) * getDvarInt( "scr_damage_numfades" ) );
			wait ( getDvarFloat( "scr_damage_fadeout" ) );
		}
		
	}
	#/
}

playerHealthRegen()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "joined_team" );
	self endon ( "joined_spectators" );
	
	if ( self.health <= 0 )
	{
		assert( !isalive( self ) );
		return;
	}
	
	oldhealth = self.maxhealth;
	
	regenRate = 0.1;
	veryHurt = false;
	
	self.breathingStopTime = -10000;
	
	thread playerBreathingSound( self.maxhealth * 0.35 );
	
	lastSoundTime_Recover = 0;
	hurtTime = 0;
	newHealth = 0;
	
	for (;;)
	{
		wait ( 0.05 );
		if ( isDefined( level.hostMigrationTimer ) )
		{
			timePassed = maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
			
			hurtTime += timePassed;
			lastSoundTime_Recover += timePassed;
		}
		
		if ( self.health == self.maxhealth || ( level.dieHardMode && isDefined( self.healthClamped ) && self.health >= self.healthClamped ) ) // runs every frame
		{
			oldHealth = self.maxhealth;
			veryHurt = false;
			self.atBrinkOfDeath = false;
			continue;
		}
					
		if ( self.health <= 0 ) // player dead
			return;

		curTime = getTime();

		ratio = self.health / self.maxHealth;

		if ( ratio <= level.healthOverlayCutoff )
		{
			if ( !veryHurt )
				hurtTime = curTime;

			veryHurt = true;
			self.atBrinkOfDeath = true;
		}
			
		if ( self.health >= oldhealth )
		{
			if ( curTime - hurtTime < level.playerHealth_RegularRegenDelay )
				continue;
			
			if ( level.healthRegenDisabled )
			{
				wait ( 3.0 );
				self.maxHealth = int( max( self.health, 2 ) );
				self.health = self.maxHealth;

				continue;
			}

			if ( curTime - lastSoundTime_Recover > level.playerHealth_RegularRegenDelay )
			{
				lastSoundTime_Recover = curTime;
				if ( !level.gameEnded )
					self playLocalSound("breathing_better");
			}
	
			if ( veryHurt )
			{
				newHealth = ratio;
				if ( curTime > hurtTime + 3000 )
					newHealth += regenRate;
			}
			else
			{
				newHealth = 1;	
			}
							
			if ( newHealth >= 1.0 )
			{
				if ( veryHurt )
					self maps\mp\gametypes\_missions::healthRegenerated();

				self maps\mp\gametypes\_damage::resetAttackerList();
				newHealth = 1.0;
			}
				
			if (newHealth <= 0)
			{
				// Player is dead
				return;
			}
			
			self setNormalHealth (newHealth);
			oldHealth = self.health;
			continue;
		}
		
		// first time damaged 
		oldHealth = self.health;
		hurtTime = curTime;
		self.breathingStopTime = hurtTime + 6000;
	}
}

playerBreathingSound( healthcap )
{
	level endon ( "game_ended" );
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "joined_team" );
	self endon ( "joined_spectators" );
	
	wait ( 2 );

	for (;;)
	{
		wait ( 0.2 );
		
		if ( self.health <= 0 )
			return;
			
		// Player still has a lot of health so no breathing sound
		if ( self.health >= healthcap )
			continue;
		
		if ( level.healthRegenDisabled && gettime() > self.breathingStopTime )
			continue;
			
		self playLocalSound( "breathing_hurt" );

		wait ( .784 );
		wait ( 0.1 + randomfloat (0.8) );
	}
}
