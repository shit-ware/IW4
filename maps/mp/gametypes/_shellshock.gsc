#include maps\mp\_utility;
#include common_scripts\utility;

init()
{
	precacheShellShock( "frag_grenade_mp" );
	precacheShellShock( "damage_mp" );
	precacheRumble( "artillery_rumble" );
	precacheRumble( "grenade_rumble" );
	
	precacheMenu( "dirt_effect_center" );
	precacheMenu( "dirt_effect_left" );
	precacheMenu( "dirt_effect_right" );
}

shellshockOnDamage( cause, damage )
{
	if ( self maps\mp\_flashgrenades::isFlashbanged() )
		return; // don't interrupt flashbang shellshock

	if ( self _hasPerk( "specialty_blastshield" ) )
		return;
	
	if ( cause == "MOD_EXPLOSIVE" ||
	     cause == "MOD_GRENADE" ||
	     cause == "MOD_GRENADE_SPLASH" ||
	     cause == "MOD_PROJECTILE" ||
	     cause == "MOD_PROJECTILE_SPLASH" )
	{
		time = 0;
		
		if(damage >= 90)
			time = 4;
		else if(damage >= 50)
			time = 3;
		else if(damage >= 25)
			time = 2;
		else if(damage > 10)
			time = 2;
		
		if ( time )
		{
			self shellshock("frag_grenade_mp", 0.5);
		}
	}
}

endOnDeath()
{
	self waittill( "death" );
	waittillframeend;
	self notify ( "end_explode" );
}

grenade_earthQuake()
{
	self thread endOnDeath();
	self endon( "end_explode" );
	self waittill( "explode", position );
	PlayRumbleOnPosition( "grenade_rumble", position );
	earthquake( 0.5, 0.75, position, 800 );
	
	foreach ( player in level.players )
	{
		if ( player isUsingRemote() )
			continue;
			
		if ( distance( position, player.origin ) > 600 )
			continue;
			
		if ( player DamageConeTrace( position ) )
			player thread dirtEffect( position );
	}
}


dirtEffect( position )
{
	self endon ( "disconnect" );
	
	forwardVec = vectorNormalize( anglesToForward( self.angles ) );
	rightVec = vectorNormalize( anglesToRight( self.angles ) );
	grenadeVec = vectorNormalize( position - self.origin );
	
	fDot = vectorDot( grenadeVec, forwardVec );
	rDot = vectorDot( grenadeVec, rightVec );
	
	printLn( fDot );
	printLn( rDot );
	
	effectMenus = [];
	if ( fDot > 0 && fDot > 0.5 && self getCurrentWeapon() != "riotshield_mp" )
		effectMenus[effectMenus.size] = "dirt_effect_center";
	
	if ( abs(fDot) < 0.866 )
	{
		if ( rDot > 0 )
			effectMenus[effectMenus.size] = "dirt_effect_right";
		else
			effectMenus[effectMenus.size] = "dirt_effect_left";		
	}

	foreach ( menu in effectMenus )
		self openMenu( menu );
	
	if ( isAlive( self ) )
		self waittill_notify_or_timeout( "death", 2.0 );

	foreach ( menu in effectMenus )
		self closeMenu( menu );
}

c4_earthQuake()
{
	self thread endOnDeath();
	self endon( "end_explode" );
	self waittill( "explode", position );
	PlayRumbleOnPosition( "grenade_rumble", position );
	earthquake( 0.4, 0.75, position, 512 );
}

barrel_earthQuake()
{
	PlayRumbleOnPosition( "grenade_rumble", self.origin );
	earthquake( 0.4, 0.5, self.origin, 512 );
}


artillery_earthQuake()
{
	PlayRumbleOnPosition( "artillery_rumble", self.origin );
	earthquake( 0.7, 0.5, self.origin, 800 );
}