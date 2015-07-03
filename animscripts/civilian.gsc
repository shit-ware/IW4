#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include animscripts\shared;

#using_animtree( "generic_human" );

cover()
{
	self endon( "killanimscript" );

	self clearanim( %root, 0.2 );
	
	if ( self animscripts\utility::IsInCombat() )
		situation = "idle_combat";
	else
		situation = "idle_noncombat";

	idle_array = undefined;
	if ( isdefined( self.animname ) && isdefined( level.scr_anim[ self.animname ] ) )
		idle_array = level.scr_anim[ self.animname ][ situation ];

	if ( !isdefined( idle_array ) )
	{
		if ( !isdefined( level.scr_anim[ "default_civilian" ] ) )
			return;
			
		idle_array = level.scr_anim[ "default_civilian" ][ situation ];
	}
	
	thread move_check();

	for ( ;; )
	{
		self setflaggedanimknoball( "idle", random( idle_array ), %root, 1, 0.2, 1 );
		self waittillmatch( "idle", "end" );
	}
}

move_check()
{
	self endon( "killanimscript" );
	
	while ( !isdefined( self.champion ) )
	{
		wait( 1 );
	}
}

stop()
{
	cover();
}

get_flashed_anim()
{
	return anim.civilianFlashedArray[ randomint( anim.civilianFlashedArray.size ) ];
}
