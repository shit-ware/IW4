main()
{

	level._effect[ "hallway_smoke" ]							= loadfx( "smoke/hallway_smoke_light" );
	level._effect[ "light_shaft_dust_large" ]					= loadfx( "dust/light_shaft_dust_large" );	
	level._effect[ "room_dust_200" ]							= loadfx( "dust/room_dust_200_blend" );	
	level._effect[ "room_dust_100" ]							= loadfx( "dust/room_dust_100_blend" );	
	level._effect[ "battlefield_smokebank_S" ]					= loadfx( "smoke/battlefield_smokebank_S" );
	level._effect[ "dust_ceiling_ash_large" ]					= loadfx( "dust/dust_ceiling_ash_large" );
	level._effect[ "ash_spiral_runner" ]			 			= loadfx( "dust/ash_spiral_runner" );
	level._effect[ "dust_wind_fast_paper" ]						= loadfx( "dust/dust_wind_fast_paper" );
	level._effect[ "dust_wind_slow_paper" ]						= loadfx( "dust/dust_wind_slow_paper" );
	level._effect[ "trash_spiral_runner" ]						= loadfx( "misc/trash_spiral_runner" );
	level._effect[ "leaves_spiral_runner" ]						= loadfx( "misc/leaves_spiral_runner" );
	level._effect[ "dust_ceiling_ash_large_mp_vacant" ]			= loadfx( "dust/dust_ceiling_ash_large_mp_vacant" );
	level._effect[ "room_dust_200_mp_vacant" ]					= loadfx( "dust/room_dust_200_blend_mp_vacant" );	
	level._effect[ "light_shaft_dust_large_mp_vacant" ]			= loadfx( "dust/light_shaft_dust_large_mp_vacant" );	
	level._effect[ "light_shaft_dust_large_mp_vacant_sidewall" ] = loadfx( "dust/light_shaft_dust_large_mp_vacant_sidewall" );	
	
/#		
	if ( getdvar( "clientSideEffects" ) != "1" )
		maps\createfx\mp_vacant_fx::main();
#/
}
