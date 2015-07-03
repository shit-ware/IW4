#include maps\mp\_utility;

main()
{
	maps\mp\mp_nightshift_precache::main();
	maps\mp\mp_nightshift_fx::main();
	maps\createart\mp_nightshift_art::main();
	maps\mp\_load::main();
	maps\mp\_compass::setupMiniMap( "compass_map_mp_nightshift" );
	setdvar( "compassmaxrange", "2400" );

	ambientPlay( "ambient_mp_urban" );
	VisionSetNaked( "mp_nightshift" );

	game[ "attackers" ] = "axis";
	game[ "defenders" ] = "allies";
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.2 );
	setdvar( "r_lightGridContrast", 1 );
	
	// raise up planes to avoid them flying through buildings
	level.airstrikeHeightScale = 1.5;

	level._effect["explosive_fx"] = loadfx("explosions/tanker_explosion");
	level._effect[ "train_dust" ] = loadfx( "dust/train_dust" );
	level._effect[ "train_dust_linger" ] = loadfx( "dust/train_dust_linger" );
	
	thread hallwayPlunger();	
}

hallwayPlunger()
{
	plunger = getEnt( "plunger", "targetname" );
	
	if ( !isDefined( plunger ) )
		return;
		
	plunger waittill ( "trigger" );
	
	explosives = getEntArray( plunger.target, "targetname" );
	
	foreach ( explosive in explosives )
	{
		wait ( 0.25 );

		rot = randomfloat(360);
		explosionEffect = spawnFx( level._effect["explosive_fx"], explosive.origin + (0,0,0), (0,0,1), (cos(rot),sin(rot),0) );
		triggerFx( explosionEffect );
		
		//playFx( level._effect["explosive_fx"], explosive.origin, explosive.angles );
		radiusDamage( explosive.origin, 384, 200, 30 );
		//explosive playSound( "detpack_explo_default" );
		thread playSoundinSpace( "exp_suitcase_bomb_main", explosive.origin );
		explosive delete();		
	}
	
	plunger delete();
	return;	
}


