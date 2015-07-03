// Weapon configuration for anim scripts.
// Supplies information for all AI weapons.
#using_animtree( "generic_human" );


usingAutomaticWeapon()
{
	return( WeaponIsAuto( self.weapon ) || WeaponBurstCount( self.weapon ) > 0 );
}

usingSemiAutoWeapon()
{
	return( weaponIsSemiAuto( self.weapon ) );
}

autoShootAnimRate()
{
	if ( usingAutomaticWeapon() )
	{
		// The auto fire animation fires 10 shots a second, so we divide the weapon's fire rate by 
		// 10 to get the correct anim playback rate.
//		return weaponFireTime( self.weapon ) * 10;
		return 0.1 / weaponFireTime( self.weapon );
	}
	else
	{
//		println ("weaponList::standAimShootAnims: No auto fire rate for "+self.weapon);
		return 0.5;
	}
}

burstShootAnimRate()
{
	if ( usingAutomaticWeapon() )
	{
		return 0.1 / weaponFireTime( self.weapon );
	}
	else
	{
//		println ("weaponList::standAimShootAnims: No auto fire rate for "+self.weapon);
		return 0.2;	// Equates to 2 shots a second, decent for a non - auto weapon.
	}
}

waitAfterShot()
{
	return 0.25;
}

shootAnimTime( semiAutoFire )
{
	if ( !usingAutomaticWeapon() || ( isdefined( semiAutofire ) && ( semiAutofire == true ) ) )
	{
		// We randomize the result a little from the real time, just to make things more 
		// interesting.  In reality, the 20Hz server is going to make this much less variable.
		rand = 0.5 + randomfloat( 1 );// 0.8 + 0.4
		return weaponFireTime( self.weapon ) * rand;
	}
	else
	{
		return weaponFireTime( self.weapon );
	}

}

RefillClip()
{
	assertEX( isDefined( self.weapon ), "self.weapon is not defined for " + self.model );

	if ( self.weapon == "none" )
	{
		self.bulletsInClip = 0;
		return false;
	}

	if ( weaponClass( self.weapon ) == "rocketlauncher" )
	{
		if ( !self.a.rocketVisible )
			self thread animscripts\combat_utility::showRocketWhenReloadIsDone();
		/*
		// TODO: proper rocket ammo tracking
		if ( self.a.rockets < 1 )
			self animscripts\shared::placeWeaponOn( self.secondaryweapon, "right" );
		*/
	}

	if ( !isDefined( self.bulletsInClip ) )
	{
		self.bulletsInClip = weaponClipSize( self.weapon );
	}
	else
	{
		self.bulletsInClip = weaponClipSize( self.weapon );
	}

	assertEX( isDefined( self.bulletsInClip ), "RefillClip failed" );

	if ( self.bulletsInClip <= 0 )
		return false;
	else
		return true;
}


add_weapon( name, type, time, clipsize, anims )
{
	assert( isdefined( name ) );
	assert( isdefined( type ) );
	if ( !isdefined( time ) )
		time = 3.0;
	if ( !isdefined( clipsize ) )
		time = 1;
	if ( !isdefined( anims ) )
		anims = "rifle";

	name = tolower( name );
	anim.AIWeapon[ name ][ "type" ] = 	type;
	anim.AIWeapon[ name ][ "time" ] 	 = 	time;
	anim.AIWeapon[ name ][ "clipsize" ] = 	clipsize;
	anim.AIWeapon[ name ][ "anims" ] 	 = 	anims;
}

addTurret( turret )
{
	anim.AIWeapon[ tolower( turret ) ][ "type" ] = "turret";
}
