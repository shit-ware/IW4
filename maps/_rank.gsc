#include common_scripts\utility;
#include maps\_utility;
#include maps\_hud_util;

/* -=-=-=-=-=-=-=-=-=-=

SP & CO-OP XP/Rank system

-=-=-=-=-=-=-=-=-=-=-=- */

init()
{
	maps\_hud::init();

	// &&1 was promoted to &&2 &&3!
	precacheString( &"RANK_PLAYER_WAS_PROMOTED_N" );
	// &&1 was promoted to &&2!
	precacheString( &"RANK_PLAYER_WAS_PROMOTED" );
	// You've been promoted!
	precacheString( &"RANK_PROMOTED" );
	// I
	precacheString( &"RANK_ROMANI" );
	// II
	precacheString( &"RANK_ROMANII" );
	// +
	precachestring( &"SCRIPT_PLUS" );
	precacheshader( "line_horizontal" );
	precacheshader( "line_vertical" );
	precacheshader( "gradient_fadein" );
	precachemenu( "coop_eog_summary" );
	precachemenu( "coop_eog_summary2" );
	precachemenu( "sp_eog_summary" );

	level.maxRank = int( tableLookup( "sp/rankTable.csv", 0, "maxrank", 1 ) );

/*	for ( rId = 0; rId <= level.maxRank; rId++ )
		precacheShader( tableLookup( "sp/rankIconTable.csv", 0, rId, 1 ) );*/

	rankId = 0;
	rankName = tableLookup( "sp/ranktable.csv", 0, rankId, 1 );
	assert( isDefined( rankName ) && rankName != "" );

	while ( isDefined( rankName ) && rankName != "" )
	{
		level.rankTable[ rankId ][ 1 ] = tableLookup( "sp/ranktable.csv", 0, rankId, 1 );
		level.rankTable[ rankId ][ 2 ] = tableLookup( "sp/ranktable.csv", 0, rankId, 2 );
		level.rankTable[ rankId ][ 3 ] = tableLookup( "sp/ranktable.csv", 0, rankId, 3 );
		level.rankTable[ rankId ][ 7 ] = tableLookup( "sp/ranktable.csv", 0, rankId, 7 );

		precacheString( tableLookupIString( "sp/ranktable.csv", 0, rankId, 10 ) );

		rankId++ ;
		rankName = tableLookup( "sp/ranktable.csv", 0, rankId, 1 );
	}

	thread xp_setup();
	foreach ( player in level.players )
		player thread xp_player_init();
}

xp_player_init()
{
	if ( !isDefined( self.summary ) )
	{
		self.summary[ "summary" ] = [];
		self.summary[ "summary" ][ "xp" ] = 0;
		self.summary[ "summary" ][ "score" ] = 0;

		self.summary[ "rankxp" ] = 0;
		self.summary[ "rank" ] = 0;
	}

	setdvar( "player_1_xp", "0" );
	setdvar( "player_2_xp", "0" );

	setdvar( "player_1_rank", "0" );
	setdvar( "player_2_rank", "0" );

	self.rankUpdateTotal = 0;
	self.hud_rankscroreupdate = newclientHudElem( self );
	self.hud_rankscroreupdate.horzAlign = "center";
	self.hud_rankscroreupdate.vertAlign = "middle";
	self.hud_rankscroreupdate.alignX = "center";
	self.hud_rankscroreupdate.alignY = "middle";
	self.hud_rankscroreupdate.x = 0;
	self.hud_rankscroreupdate.y = -60;
	self.hud_rankscroreupdate.font = "default";
	self.hud_rankscroreupdate.fontscale = 2;
	self.hud_rankscroreupdate.archived = false;
	self.hud_rankscroreupdate.color = ( 1, 1, 0.65 );
	self.hud_rankscroreupdate fontPulseInit();

	// XP BAR
	self.hud_xpbar = xp_bar_client_elem( self );
	self xpbar_update();
}

xp_bar_client_elem( client )
{
	hudelem = newClientHudElem( client );
	hudelem.x = ( hud_width_format() / 2 ) * ( -1 );
	hudelem.y = 0;
	hudelem.sort = 5;
	hudelem.horzAlign = "center_adjustable";
	hudelem.vertAlign = "bottom_adjustable";
	hudelem.alignX = "left";
	hudelem.alignY = "bottom";
	hudelem setshader( "gradient_fadein", get_xpbarwidth(), 4 );// gradient_fadein
	hudelem.color = ( 1, 0.8, 0.4 );
	hudelem.alpha = 0.65;
	hudelem.foreground = true;
	return hudelem;
}

hud_width_format()
{
	// screen formatting
	if ( getDvar( "hiDef" ) == "1" || getDvar( "wideScreen" ) == "1" )
	{
		if ( isSplitscreen() )
			return 966;// customized to match hud's xpbar background
		else
			return 720;
	}
	else
	{
		if ( isSplitscreen() )
			return 726;// customized to match hud's xpbar background
		else
			return 540;
	}
}

xpbar_update()
{
	if ( !get_xpbarwidth() )
		self.hud_xpbar.alpha = 0;
	else
		self.hud_xpbar.alpha = 0.65;

	self.hud_xpbar setshader( "gradient_fadein", get_xpbarwidth(), 4 );
}

get_xpbarwidth()
{
	if ( self == level.player )
		player_num = "1";
	else
		player_num = "2";

	rank_range = int( tableLookup( "sp/rankTable.csv", 0, getdvar( "player_" + player_num + "_rank" ), 3 ) );
	rank_xp = int( getdvar( "player_" + player_num + "_xp" ) ) - int( tableLookup( "sp/rankTable.csv", 0, getdvar( "player_" + player_num + "_rank" ), 2 ) );

	fullwidth = hud_width_format();
	newwidth = int( fullwidth * ( rank_xp / rank_range ) );

	return newwidth;
}

xp_setup()
{
	level.xpScale = 1;
	if ( level.console )
	{
		level.xpScale = 1;// getDvarInt( "scr_xpscale" );
	}

	registerScoreInfo( "kill", 10 );
	registerScoreInfo( "headshot", 10 );
	registerScoreInfo( "assist", 2 );
	registerScoreInfo( "suicide", 0 );
	registerScoreInfo( "teamkill", 0 );
}

giveXP_think()
{
	self waittill( "death", attacker, type, weapon );
	// split for recursive call
	self giveXP_helper( attacker );
}

giveXP_helper( attacker )
{
	// if AI removed by script/game, no xp to player
	if ( !isdefined( attacker ) )
		return;

	// if player is last to kill, give player kill points	
	if ( isPlayer( attacker ) )
	{
		attacker thread giveXp( "kill" );
		return;
	}

	// no xp if enemy was finished off by other enemies
	if ( isAI( attacker ) && attacker isBadGuy() )
		return;

	// if enemy shot by player was killed by destructibles
	if ( is_special_targetname_attacker( attacker ) )
	{
		if ( isdefined( attacker.attacker ) )
			self thread giveXP_helper( attacker.attacker );
		return;
	}

	// if enemy shot by player was killed by natural causes, no xp
	if ( !isPlayer( attacker ) && !isAI( attacker ) )
		return;

	// if enemy shot by player was killed by friendly, give assist
	if ( isdefined( self.attacker_list ) && self.attacker_list.size > 0 )
	{
		for ( i = 0; i < self.attacker_list.size; i++ )
		{
			// if attacker is player and not the last to kill, give player assist points
			if ( isPlayer( self.attacker_list[ i ] ) && self.attacker_list[ i ] != attacker )
				self.attacker_list[ i ] thread giveXp( "assist" );
		}
	}
}

is_special_targetname_attacker( attacker )
{
	assert( isdefined( attacker ) );

	if ( !isdefined( attacker.targetname ) )
		return false;

	 if ( attacker.targetname == "destructible" )
	 	return true;

	  if ( string_starts_with( attacker.targetname, "sentry_" ) )
	  	return true;

	  return false;
}

AI_xp_init()
{
	self thread giveXP_think();
	self.attacker_list = [];
	self.last_attacked = 0;
	self add_damage_function( ::xp_took_damage );
}

xp_took_damage( damage, attacker, direction_vec, point, type, modelName, tagName )
{
	if ( !isdefined( attacker ) )
		return;

	currentTime = gettime();
	timeElapsed = currentTime - self.last_attacked;
	if ( timeElapsed <= 10 * 1000 )
	{
		self.attacker_list[ self.attacker_list.size ] = attacker;
		self.last_attacked = gettime();
		return;
	}

	self.attacker_list = [];
	self.attacker_list[ 0 ] = attacker;
	self.last_attacked = gettime();
}

// used by _utility.gsc, edit with cre
updatePlayerScore( type, value )
{
	self notify( "update_xp" );
	self endon( "update_xp" );

	if ( getdvar( "xp_enable", "0" ) != "1" )
		return;

	//assertex ( isDefined( level.scoreInfo ), "Trying to give player XP when XP feature is not enabled, set dvar xp_enable to 1." );
	//assertex ( isDefined( type ), "First string parameter <type> is undefined or missing, you must label this XP reward." );

	if ( !isDefined( value ) )
	{
		if ( isDefined( level.scoreInfo[ type ] ) )
			value = getScoreInfoValue( type );
		else
			value = getScoreInfoValue( "kill" );
	}

	value = int( value * level.xpScale );

	if ( type == "kill" )
		self.hud_rankscroreupdate.color = ( 1, 1, 0.5 );

	if ( type == "assist" )
	{
		// assist points can never add up over kill points
		if ( value > getScoreInfoValue( "kill" ) )
			value = getScoreInfoValue( "kill" );

		self.hud_rankscroreupdate.color = ( 1, 1, 0.5 );
	}

	self.rankUpdateTotal += value;

	// +
	self.hud_rankscroreupdate.label = &"SCRIPT_PLUS";

	self.hud_rankscroreupdate setValue( self.rankUpdateTotal );
	self.hud_rankscroreupdate.alpha = 0.65;
	self.hud_rankscroreupdate thread fontPulse( self );

	wait 1;
	self.hud_rankscroreupdate fadeOverTime( 0.75 );
	self.hud_rankscroreupdate.alpha = 0;

	// set xp dvar for hud menu to print
	self.summary[ "summary" ][ "score" ] += self.rankUpdateTotal;
	self.summary[ "summary" ][ "xp" ] += self.rankUpdateTotal;
	self.summary[ "rankxp" ] += self.rankUpdateTotal;

	if ( self == level.player )
	{
		setdvar( "player_1_xp", self.summary[ "summary" ][ "xp" ] );
		setdvar( "player_1_rank", self.summary[ "rank" ] );
	}
	else
	{
		setdvar( "player_2_xp", self.summary[ "summary" ][ "xp" ] );
		setdvar( "player_2_rank", self.summary[ "rank" ] );
	}

	self xpbar_update();

	self.rankUpdateTotal = 0;

	if ( self updateRank() )
		self thread updateRankAnnounceHUD();
}

fontPulseInit()
{
	self.baseFontScale = self.fontScale;
	self.maxFontScale = self.fontScale * 2;
	//self.moveUpSpeed = 1.25;
	self.inFrames = 3;
	self.outFrames = 5;
}


fontPulse( player )
{
	self notify( "fontPulse" );
	self endon( "fontPulse" );

	scaleRange = self.maxFontScale - self.baseFontScale;
	//self thread fontMoveup( -60 );

	while ( self.fontScale < self.maxFontScale )
	{
		self.fontScale = min( self.maxFontScale, self.fontScale + ( scaleRange / self.inFrames ) );
		wait 0.05;
	}

	while ( self.fontScale > self.baseFontScale )
	{
		self.fontScale = max( self.baseFontScale, self.fontScale - ( scaleRange / self.outFrames ) );
		wait 0.05;
	}
}

/*
fontMoveup( start )
{
	self endon( "fontPulse" );
	self.y = start;

	while ( abs( start ) - abs( self.y ) < 60 )
	{
		self.y = self.y - self.moveUpSpeed;
		wait 0.05;
	}
}*/

updateRank()
{
	newRankId = self getRank();
	if ( newRankId == self.summary[ "rank" ] )
		return false;

	oldRank = self.summary[ "rank" ];
	rankId = self.summary[ "rank" ];

	self.summary[ "rank" ] = newRankId;

	if ( self == level.player )
		setdvar( "player_1_rank", self.summary[ "rank" ] );
	else
		setdvar( "player_2_rank", self.summary[ "rank" ] );

	self xpbar_update();

	while ( rankId <= newRankId )
	{
		self.setPromotion = true;
		rankId++ ;
	}
	return true;
}

updateRankAnnounceHUD()
{
	self endon( "disconnect" );

	self notify( "update_rank" );
	self endon( "update_rank" );

	self notify( "reset_outcome" );
	newRankName = self getRankInfoFull( self.summary[ "rank" ] );

	notifyData = spawnStruct();

	// You've been promoted!
	notifyData.titleText = &"RANK_PROMOTED";
	notifyData.iconName = self getRankInfoIcon( self.summary[ "rank" ] );
	notifyData.sound = "sp_level_up";
	notifyData.duration = 4.0;

	rank_char = level.rankTable[ self.summary[ "rank" ] ][ 1 ];
	subRank = int( rank_char[ rank_char.size - 1 ] );

	if ( subRank == 2 )
	{
		notifyData.textLabel = newRankName;
		// I
		notifyData.notifyText = &"RANK_ROMANI";
		notifyData.textIsString = true;
	}
	else if ( subRank == 3 )
	{
		notifyData.textLabel = newRankName;
		// II
		notifyData.notifyText = &"RANK_ROMANII";
		notifyData.textIsString = true;
	}
	else
	{
		notifyData.notifyText = newRankName;
	}

	self thread notifyMessage( notifyData );

	if ( subRank > 1 )
		return;

}


notifyMessage( notifyData )
{
	self endon( "death" );
	self endon( "disconnect" );

	if ( !self.doingNotify )
	{
		self thread showNotifyMessage( notifyData );
		return;
	}

	self.notifyQueue[ self.notifyQueue.size ] = notifyData;
}


showNotifyMessage( notifyData )
{
	self endon( "disconnect" );

	self.doingNotify = true;

	waitRequireVisibility( 0 );

	if ( isDefined( notifyData.duration ) )
		duration = notifyData.duration;
	else
		duration = 4.0;

	self thread resetOnCancel();

	if ( isDefined( notifyData.sound ) )
		self playLocalSound( notifyData.sound );

	if ( isDefined( notifyData.glowColor ) )
		glowColor = notifyData.glowColor;
	else
		glowColor = ( 0.3, 0.6, 0.3 );

	anchorElem = self.notifyTitle;

	if ( isDefined( notifyData.titleText ) )
	{

			if ( isDefined( notifyData.titleLabel ) )
				self.notifyTitle.label = notifyData.titleLabel;
			else
				// string not found for 
				self.notifyTitle.label = &"";

			if ( isDefined( notifyData.titleLabel ) && !isDefined( notifyData.titleIsString ) )
				self.notifyTitle setValue( notifyData.titleText );
			else
				self.notifyTitle setText( notifyData.titleText );
			self.notifyTitle setPulseFX( 100, int( duration * 1000 ), 1000 );
			self.notifyTitle.glowColor = glowColor;
			self.notifyTitle.alpha = 1;
	}

	if ( isDefined( notifyData.notifyText ) )
	{
			if ( isDefined( notifyData.textLabel ) )
				self.notifyText.label = notifyData.textLabel;
			else
				// string not found for 
				self.notifyText.label = &"";

			if ( isDefined( notifyData.textLabel ) && !isDefined( notifyData.textIsString ) )
				self.notifyText setValue( notifyData.notifyText );
			else
				self.notifyText setText( notifyData.notifyText );
			self.notifyText setPulseFX( 100, int( duration * 1000 ), 1000 );
			self.notifyText.glowColor = glowColor;
			self.notifyText.alpha = 1;
			anchorElem = self.notifyText;
	}

	if ( isDefined( notifyData.notifyText2 ) )
	{
			self.notifyText2 setParent( anchorElem );

			if ( isDefined( notifyData.text2Label ) )
				self.notifyText2.label = notifyData.text2Label;
			else
				// string not found for 
				self.notifyText2.label = &"";

			self.notifyText2 setText( notifyData.notifyText2 );
			self.notifyText2 setPulseFX( 100, int( duration * 1000 ), 1000 );
			self.notifyText2.glowColor = glowColor;
			self.notifyText2.alpha = 1;
			anchorElem = self.notifyText2;
	}

	if ( isDefined( notifyData.iconName ) )
	{
		self.notifyIcon setParent( anchorElem );
		self.notifyIcon setShader( notifyData.iconName, 60, 60 );
		self.notifyIcon.alpha = 0;
		self.notifyIcon fadeOverTime( 1.0 );
		self.notifyIcon.alpha = 1;

		waitRequireVisibility( duration );

		self.notifyIcon fadeOverTime( 0.75 );
		self.notifyIcon.alpha = 0;
	}
	else
	{
		waitRequireVisibility( duration );
	}

	self notify( "notifyMessageDone" );
	self.doingNotify = false;

	if ( self.notifyQueue.size > 0 )
	{
		nextNotifyData = self.notifyQueue[ 0 ];

		newQueue = [];
		for ( i = 1; i < self.notifyQueue.size; i++ )
			self.notifyQueue[ i - 1 ] = self.notifyQueue[ i ];
		self.notifyQueue[ i - 1 ] = undefined;

		self thread showNotifyMessage( nextNotifyData );
	}
}

resetOnCancel()
{
	self notify( "resetOnCancel" );
	self endon( "resetOnCancel" );
	self endon( "notifyMessageDone" );
	self endon( "disconnect" );

	level waittill( "cancel_notify" );

	self.notifyTitle.alpha = 0;
	self.notifyText.alpha = 0;
	self.notifyIcon.alpha = 0;
	self.doingNotify = false;
}

// waits for waitTime, plus any time required to let flashbangs go away.
waitRequireVisibility( waitTime )
{
	interval = .05;

	while ( !self canReadText() )
		wait interval;

	while ( waitTime > 0 )
	{
		wait interval;
		if ( self canReadText() )
			waitTime -= interval;
	}
}

canReadText()
{
	if ( self isFlashbanged() )
		return false;
	return true;
}

isFlashbanged()
{
	return isDefined( self.flashEndTime ) && gettime() < self.flashEndTime;
}

// ============== helpers ===============

registerScoreInfo( type, value )
{
	level.scoreInfo[ type ][ "value" ] = value;
}

getScoreInfoValue( type )
{
	return( level.scoreInfo[ type ][ "value" ] );
}

getRankInfoMinXP( rankId )
{
	return int( level.rankTable[ rankId ][ 2 ] );
}

getRankInfoXPAmt( rankId )
{
	return int( level.rankTable[ rankId ][ 3 ] );
}

getRankInfoMaxXp( rankId )
{
	return int( level.rankTable[ rankId ][ 7 ] );
}

getRankInfoFull( rankId )
{
	return tableLookupIString( "sp/ranktable.csv", 0, rankId, 10 );
}

getRankInfoIcon( rankId )
{
	return tableLookup( "sp/rankIconTable.csv", 0, rankId, 1 );
}

getRank()
{
	rankXp = self.summary[ "rankxp" ];
	rankId = self.summary[ "rank" ];

	if ( rankXp < ( getRankInfoMinXP( rankId ) + getRankInfoXPAmt( rankId ) ) )
		return rankId;
	else
		return self getRankForXp( rankXp );
}

getRankForXp( xpVal )
{
	rankId = 0;
	rankName = level.rankTable[ rankId ][ 1 ];
	assert( isDefined( rankName ) );

	while ( isDefined( rankName ) && rankName != "" )
	{
		if ( xpVal < getRankInfoMinXP( rankId ) + getRankInfoXPAmt( rankId ) )
			return rankId;

		rankId++ ;
		if ( isDefined( level.rankTable[ rankId ] ) )
			rankName = level.rankTable[ rankId ][ 1 ];
		else
			rankName = undefined;
	}

	rankId -- ;
	return rankId;
}

getRankXP()
{
	return self.summary[ "rankxp" ];
}