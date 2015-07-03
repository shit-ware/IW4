#include common_scripts\utility;
#include maps\_utility;
#include maps\_debug;
#include maps\_hud_util;
init()
{
	precacheShader( "damage_feedback" );

	if ( getDvar( "scr_damagefeedback" ) == "" )
		setDvar( "scr_damagefeedback", "0" );

	if ( !getDvarInt( "scr_damagefeedback", 0 ) )
		return;

	array_thread( level.players, ::init_damage_feedback );
	array_thread( level.players, ::monitorDamage );
}

init_damage_feedback()
{
	self.hud_damagefeedback = newClientHudElem( self );
	self.hud_damagefeedback.alignX = "center";
	self.hud_damagefeedback.alignY = "middle";
	self.hud_damagefeedback.horzAlign = "center";
	self.hud_damagefeedback.vertAlign = "middle";
	self.hud_damagefeedback.alpha = 0;
	self.hud_damagefeedback.archived = true;
	self.hud_damagefeedback setShader( "damage_feedback", 24, 24 * 2 );
	self.hud_damagefeedback.y = 12;	// aligns it to the center of the crosshair.
}

monitorDamage()
{
	if ( !getDvarInt( "scr_damagefeedback", 0 ) )
		return;

	self add_damage_function( ::damagefeedback_took_damage );
}

damagefeedback_took_damage( damage, attacker, direction_vec, point, type, modelName, tagName )
{
	if ( !isplayer( attacker ) )
		return;
	if ( isdefined( self.bullet_resistance ) )
	{
		legal_bullet_types = [];
		legal_bullet_types[ "MOD_PISTOL_BULLET" ] = true;
		legal_bullet_types[ "MOD_RIFLE_BULLET" ] = true;

		if ( isdefined( legal_bullet_types[ type ] ) )
		{
			if ( damage <= self.bullet_resistance )
				return;
		}
	}
	attacker updateDamageFeedback( self );
}

updateDamageFeedback( attacked )
{
	if ( !isPlayer( self ) )
		return;
	if ( !isdefined( attacked.team ) )
		return;
	if ( ( attacked.team == self.team ) || ( attacked.team == "neutral" ) )
		return;
	self playlocalsound( "SP_hit_alert" );
	
	fadeTime = 1;	//fade out crosshair damage indicator over this time 
	
	//If in slomo, fade out damage indicator faster (the value entered for the slomo time fraction
	if ( isdefined( level.slowmo.speed_slow ) )
		 fadeTime = level.slowmo.speed_slow;
	
	self.hud_damagefeedback.alpha = 1;
	self.hud_damagefeedback fadeOverTime( fadeTime );
	self.hud_damagefeedback.alpha = 0;

	offset = getdvarfloat( "cg_crosshairVerticalOffset" ) * 240;
	self.hud_damagefeedback.y = 12 - int( offset );
}