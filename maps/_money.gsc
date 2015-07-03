#include common_scripts\utility;
#include maps\_utility;
#include maps\_hud_util;

/* -=-=-=-=-=-=-=-=-=-=

PMC & CO-OP Money system

-=-=-=-=-=-=-=-=-=-=-=- */

// constants
CONST_money_notify_interval			 = 5000;					// Email notifies every $2000 earned
CONST_money_kill					 = 100;
CONST_money_kill_melee				 = 150;
CONST_money_juggernaut_kill			 = 500;
CONST_money_juggernaut_kill_melee	 = 600;
CONST_money_objective				 = 500;
CONST_money_completion				 = 1000;
  
CONST_bonus_money_sound				 = "extra_money_reward";

CONST_lootSound 					 = "loot_drop_epic";
CONST_lootString 					 = "New mail!";
CONST_lootIcon 						 = "temp_mail_icon";
CONST_lootColor 					 = ( 0.55, 1, 0.55 );

init()
{
	maps\_hud::init();

	precacheshader( "line_horizontal" );
	precacheshader( "line_vertical" );
	precacheshader( "gradient_fadein" );
	precachemenu( "coop_eog_summary" );
	precachemenu( "coop_eog_summary2" );
	precachemenu( "sp_eog_summary" );

	level.reward[ "kill" ]					 = CONST_money_kill;
	level.reward[ "kill_melee" ]			 = CONST_money_kill_melee;
	level.reward[ "juggernaut_kill" ]		 = CONST_money_juggernaut_kill;
	level.reward[ "juggernaut_kill_melee" ]	 = CONST_money_juggernaut_kill_melee;
	level.reward[ "completion" ]			 = CONST_money_completion;

	thread setupLoot();
	thread money_setup();
	foreach ( player in level.players )
	{
		player thread money_player_init();
	}
}

money_player_init()
{
	if ( !isDefined( self.summary ) )
	{
		self.summary[ "summary" ] = [];
		self.summary[ "summary" ][ "intervals" ] = 0;
		self.summary[ "summary" ][ "completion" ] = 0;
		self.summary[ "summary" ][ "total_money" ] = 0;
		self.summary[ "summary" ][ "mission_start_time" ] = getTime();
	}

	self.moneyUpdateTotal = 0;
	self.hud_moneyupdate = newclientHudElem( self );
	self.hud_moneyupdate.horzAlign = "center";
	self.hud_moneyupdate.vertAlign = "middle";
	self.hud_moneyupdate.alignX = "center";
	self.hud_moneyupdate.alignY = "middle";
	self.hud_moneyupdate.x = 0;
	self.hud_moneyupdate.y = -60;
	self.hud_moneyupdate.font = "default";
	self.hud_moneyupdate.fontscale = 2;
	self.hud_moneyupdate.archived = false;
	self.hud_moneyupdate.color = ( 0.55, 1, 0.55 );
	self.hud_moneyupdate fontPulseInit();

	self.hud_totalmoney = newclientHudElem( self );
	self.hud_totalmoney.horzAlign = "right";
	self.hud_totalmoney.vertAlign = "top";
	self.hud_totalmoney.alignX = "right";
	self.hud_totalmoney.alignY = "top";
	self.hud_totalmoney.x = 0;
	self.hud_totalmoney.y = 0;
	self.hud_totalmoney.font = "default";
	self.hud_totalmoney.fontscale = 2;
	self.hud_totalmoney.archived = false;
	self.hud_totalmoney.color = ( 0.55, 1, 0.55 );
	self.hud_totalmoney.alpha = 0;
	self.hud_totalmoney.label = "";
	self.hud_totalmoney fontPulseInit();

	self thread initNotifyMessage();

	self thread show_total_money();
}

initNotifyMessage()
{
	if ( is_coop() )
	{
		titleSize = 2.5;
		textSize = 1.75;
		iconSize = 24;
		font = "objective";
		point = "TOP";
		relativePoint = "BOTTOM";
		yOffset = 30;
		xOffset = 0;
	}
	else
	{
		titleSize = 2.5;
		textSize = 1.75;
		iconSize = 30;
		font = "objective";
		point = "TOP";
		relativePoint = "BOTTOM";
		yOffset = 30;
		xOffset = 0;
	}

	self.notifyTitle = createClientFontString( font, titleSize );
	self.notifyTitle setPoint( point, undefined, xOffset, yOffset );
	self.notifyTitle.glowColor = ( 0.2, 0.3, 0.7 );
	self.notifyTitle.glowAlpha = 1;
	self.notifyTitle.hideWhenInMenu = true;
	self.notifyTitle.archived = false;
	self.notifyTitle.alpha = 0;

	self.notifyText = createClientFontString( font, textSize );
	self.notifyText setParent( self.notifyTitle );
	self.notifyText setPoint( point, relativePoint, 0, 0 );
	self.notifyText.glowColor = ( 0.2, 0.3, 0.7 );
	self.notifyText.glowAlpha = 1;
	self.notifyText.hideWhenInMenu = true;
	self.notifyText.archived = false;
	self.notifyText.alpha = 0;

	self.notifyText2 = createClientFontString( font, textSize );
	self.notifyText2 setParent( self.notifyTitle );
	self.notifyText2 setPoint( point, relativePoint, 0, 0 );
	self.notifyText2.glowColor = ( 0.2, 0.3, 0.7 );
	self.notifyText2.glowAlpha = 1;
	self.notifyText2.hideWhenInMenu = true;
	self.notifyText2.archived = false;
	self.notifyText2.alpha = 0;

	self.notifyIcon = createClientIcon( "white", iconSize, iconSize );
	self.notifyIcon setParent( self.notifyText2 );
	self.notifyIcon setPoint( point, relativePoint, 0, 0 );
	self.notifyIcon.hideWhenInMenu = true;
	self.notifyIcon.archived = false;
	self.notifyIcon.alpha = 0;

	self.doingNotify = false;
	self.notifyQueue = [];
}

show_total_money()
{
	// Shows total money the player has earned in the corner of the screen
	// Fades in when money is made, counts up, then fades out
	assert( isdefined( self.hud_totalmoney ) );

	currentCount = 0;
	moneyToAddPerFrame = 10;
	for ( ;; )
	{
		while ( self.summary[ "summary" ][ "total_money" ] == currentCount )
			wait 0.05;

		currentCount += moneyToAddPerFrame;
		if ( currentCount > self.summary[ "summary" ][ "total_money" ] )
			currentCount = self.summary[ "summary" ][ "total_money" ];

		self notify( "stop_total_money_fade" );
		self.hud_totalmoney.alpha = 1;
		self.hud_totalmoney setValue( currentCount );

		if ( self.summary[ "summary" ][ "total_money" ] == currentCount )
			self thread show_total_money_fadeout();

		wait 0.05;
	}
}

show_total_money_fadeout()
{
	self endon( "stop_total_money_fade" );
	//self.hud_totalmoney thread fontPulse( self );
	wait 3.0;
	self.hud_totalmoney fadeOverTime( 0.75 );
	self.hud_totalmoney.alpha = 0;
}

// returns bool if player's current money satisfies an email notification
money_mailNotify()
{
	// self is player
	cur_money = self.summary[ "summary" ][ "total_money" ];
	cur_emails = self.summary[ "summary" ][ "intervals" ];		// number of emails

	// notify condition A
	// send player email every CONST_money_notify_interval dollars
	if ( cur_emails < int( cur_money / CONST_money_notify_interval ) )
		self email_popup();
}

email_popup()
{
	giveLoot( self );
	//iprintln( self.summary[ "summary" ][ "intervals" ] + "th email" );
	self.summary[ "summary" ][ "intervals" ]++ ;
}

money_setup()
{
	// in dollars $$$
	registerMoneyType( "kill", CONST_money_kill );
	registerMoneyType( "kill_melee", CONST_money_kill_melee );
	registerMoneyType( "juggernaut_kill", CONST_money_juggernaut_kill );
	registerMoneyType( "juggernaut_kill_melee", CONST_money_juggernaut_kill_melee );
	registerMoneyType( "headshot", CONST_money_juggernaut_kill );
	registerMoneyType( "assist", 0 );
	registerMoneyType( "objective", CONST_money_objective );
	registerMoneyType( "completion", CONST_money_completion );
	registerMoneyType( "suicide", 0 );
	registerMoneyType( "teamkill", 0 );
}

giveMoney_think()
{
	self waittill( "death", attacker, type, weapon );
	// split for recursive call
	self giveMoney_helper( attacker, type );
}

giveMoney_helper( attacker, type )
{
	if ( isdefined( attacker ) && !isplayer( attacker ) )
	{
		if ( isdefined( self.saved_player_attacker ) )
			attacker = self.saved_player_attacker;
	}

	// if AI removed by script/game, no money to player
	if ( !isdefined( attacker ) )
		return;

	playBonusSound = false;
	juggernaut = false;
	killType = "kill";
	if ( isdefined( self.juggernaut ) )
	{
		killType = "juggernaut_kill";
		juggernaut = true;
		playBonusSound = true;
	}

	// Melee kills are worth more money cuz you're good like dat
	if ( ( isdefined( type ) ) && ( issubstr( tolower( type ), "melee" ) ) )
	{
		if ( juggernaut )
			killType = "juggernaut_kill_melee";
		else
			killType = "kill_melee";
		playBonusSound = true;
	}

	// if player is last to kill, give player kill points	
	if ( isPlayer( attacker ) )
	{
		if ( getdvar( "money_sharing" ) == "1" )
		{
			foreach ( player in level.players )
			{
				if ( isdefined( self.kill_reward_money ) )
				{
					if ( killType == "kill_melee" && isdefined( self.kill_melee_reward_money ) )
						player thread giveMoney( killType, self.kill_melee_reward_money, attacker );
					else
						player thread giveMoney( killType, self.kill_reward_money, attacker );
				}
				else
					player thread giveMoney( killType, undefined, attacker );
			}
		}
		else
			attacker thread giveMoney( killType );

		if ( playBonusSound )
			attacker playLocalSound( CONST_bonus_money_sound );

		return;
	}

	// no money if enemy was finished off by other enemies
	if ( isAI( attacker ) && attacker isBadGuy() )
		return;

	// if enemy shot by player was killed by destructibles
	if ( is_special_targetname_attacker( attacker ) )
	{
		if ( isdefined( attacker.attacker ) )
			self thread giveMoney_helper( attacker.attacker );
		return;
	}

	// if enemy shot by player was killed by natural causes, no money
	if ( !isPlayer( attacker ) && !isAI( attacker ) )
		return;

	/*
	// if enemy shot by player was killed by friendly, give assist
	if ( isdefined( self.attacker_list ) && self.attacker_list.size > 0 )
	{
		for ( i = 0; i < self.attacker_list.size; i++ )
		{
			// if attacker is player and not the last to kill, give player assist points
			if ( isPlayer( self.attacker_list[ i ] ) && self.attacker_list[ i ] != attacker )
				self.attacker_list[ i ] thread giveMoney( "assist" );
		}
	}
	*/
}

give_objective_reward()
{
	if ( getdvar( "money_sharing" ) == "1" )
	{
		foreach ( player in level.players )
			player giveMoney( "objective" );
	}
	else if ( isdefined( self ) && isPlayer( self ) )
		self giveMoney( "objective" );
	else
		level.player giveMoney( "objective" );
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

AI_money_init()
{
	self thread giveMoney_think();
	self.attacker_list = [];
	self.last_attacked = 0;
	self add_damage_function( ::took_damage );
}

took_damage( damage, attacker, direction_vec, point, type, modelName, tagName )
{
	if ( !isdefined( self ) )
	{
		// AI removed, no need to keep track
		return;
	}
		
	if ( !isdefined( attacker ) )
		return;

	// this is to make sure player gets money after killing enemy during their traversal anim
	if ( isplayer( attacker ) )
		self.saved_player_attacker = attacker;

	currentTime = gettime();
	timeElapsed = currentTime - self.last_attacked;
	if ( timeElapsed <= 10 * 3000 )	// 10 * 1000
	{
		self.attacker_list[ self.attacker_list.size ] = attacker;
		self.last_attacked = gettime();
		return;
	}

	self.attacker_list = [];
	self.attacker_list[ 0 ] = attacker;
	self.last_attacked = gettime();
}

// used by _utility.gsc, edit with care
updatePlayerMoney( type, value, attacker )
{
	self notify( "update_money" );
	self endon( "update_money" );

	if ( getdvar( "money_enable", "0" ) != "1" )
		return;

	// optional in game reward control
	if ( getdvar( "in_game_reward" ) != "1" )
	{
		allowed_types = "completion ";
		allowed_types_array = strTok( allowed_types, " " );

		//disabled_types = "kill kill_melee juggernaut_kill juggernaut_kill_melee headshot assist objective";
		//disabled_types_array = [];
		//disabled_types_array = strTok( disabled_types, " " );

		foreach ( s_type in allowed_types_array )
		{
			if ( type != s_type )
				return;
		}
	}

	if ( !isDefined( value ) )
	{
		if ( isDefined( level.scoreInfo[ type ] ) )
			value = getScoreInfoValue( type );
		else
			value = getScoreInfoValue( "kill" );
	}

	// update reward value trackers

	value = int( value );

	if ( !( type == "kill" || type == "kill_melee" || type == "headshot" ) )
		self.summary[ "summary" ][ "completion" ] += value;	// if custom reward type, it counts towards level completion
	else if ( type == "assist" )
	{
		// assist points can never add up over kill points
		if ( value > getScoreInfoValue( "kill" ) )
			value = getScoreInfoValue( "kill" );
	}

	self.moneyUpdateTotal += value;

	bShowMoneyUpdate = true;
	if ( isdefined( attacker ) && self != attacker )
		bShowMoneyUpdate = false;

	if ( bShowMoneyUpdate )
	{
		// $
		self.hud_moneyupdate.label = "";
		self.hud_moneyupdate setValue( self.moneyUpdateTotal );
		self.hud_moneyupdate.alpha = 0.65;
		self.hud_moneyupdate thread fontPulse( self );
	}

	wait 1;

	if ( bShowMoneyUpdate )
	{
		self.hud_moneyupdate fadeOverTime( 0.75 );
		self.hud_moneyupdate.alpha = 0;
	}

	self.summary[ "summary" ][ "total_money" ] += self.moneyUpdateTotal;

	self.moneyUpdateTotal = 0;

	// email notify
	self thread money_mailNotify();
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

// ============== LOOT NOTIFY ================

giveLoot( attacker )
{
	if ( !isDefined( attacker.lootIcon ) )
	{
		attacker.lootIcon = attacker createIcon( "white", 32, 16 );
		attacker.lootIcon setPoint( "TOPRIGHT", undefined, getDvarFloat( "scr_loot_offsetX" ), getDvarFloat( "scr_loot_offsetY" ) );
		attacker.lootIcon.alpha = 0;
	}

	if ( !isDefined( attacker.lootString ) )
	{
		attacker.lootString = attacker createFontString( "default", 1.5 );
		attacker.lootString setParent( attacker.lootIcon );
		attacker.lootString setPoint( "RIGHT", "LEFT", 0, 0 );
		attacker.lootString setText( "ASDF" );
		attacker.lootString.glowColor = ( 1, 1, 1 );
		attacker.lootString.glowAlpha = 0;
		attacker.lootString.alpha = 0;
		attacker.lootString fontPulseInit();
	}

	if ( !isDefined( attacker.moneyString ) )
	{
		attacker.moneyString = attacker createFontString( "default", 2 );
		attacker.moneyString setParent( attacker.lootIcon );
		attacker.moneyString setPoint( "RIGHT", "LEFT", 0, 0 );
		attacker.moneyString setText( "ASDF" );
		attacker.moneyString.glowColor = ( 1, 1, 1 );
		attacker.moneyString.glowAlpha = 0;
		attacker.moneyString.alpha = 0;
		attacker.moneyString fontPulseInit();
	}

	attacker.lootIcon setPoint( "TOPRIGHT", undefined, getDvarFloat( "scr_loot_offsetX" ), getDvarFloat( "scr_loot_offsetY" ) );
	attacker.lootString setPoint( "RIGHT", "LEFT", -10, 0 );
	attacker.moneyString setPoint( "RIGHT", "LEFT", -10, 20 );
	attacker thread showLoot( CONST_lootString, CONST_lootIcon, CONST_lootSound, CONST_lootColor );
	attacker thread showMoney( attacker.summary[ "summary" ][ "total_money" ] );
}

showMoney( amount )
{
	self endon( "got_loot" );
	self endon( "disconnect" );

	self.moneyString setText( "$0" );
	self thread moneyCountUp( amount );
	self.moneyString.alpha = 1;
	self.moneyString.color = CONST_lootColor;

	if ( getDvarInt( "scr_loot_slowPrint" ) )
		self.moneyString setPulseFX( 100, int( getDvarFloat( "scr_loot_showTime" ) * 1000 ), 1000 );
	else
		self.moneyString thread fontPulse( self );

	wait( getDvarFloat( "scr_loot_showTime" ) );
	self.moneyString fadeOverTime( 1.0 );
	self.moneyString.alpha = 0;
}

moneyCountUp( amount )
{
	self endon( "got_loot" );
	self endon( "disconnect" );

	counts = 10;
	for ( i = counts; i > 0; i -- )
	{
		self.moneyString setText( "$" + int( amount / i ) );
		wait 0.1;
	}
}

showLoot( lootString, lootIcon, lootSound, lootColor )
{
	self notify( "got_loot" );
	self endon( "got_loot" );
	self endon( "disconnect" );

	wait( getDvarFloat( "scr_loot_dropDelay" ) );

	self playLocalSound( lootSound );

	self.lootString setText( lootString );
	self.lootString.alpha = 1;
	self.lootString.color = lootColor;

	if ( getDvarInt( "scr_loot_slowPrint" ) )
		self.lootString setPulseFX( 100, int( getDvarFloat( "scr_loot_showTime" ) * 1000 ), 1000 );
	else
		self.lootString thread fontPulse( self );

	self.lootIcon setIconShader( lootIcon );
	self.lootIcon.alpha = 1;
	wait( getDvarFloat( "scr_loot_showTime" ) );
	self.lootString fadeOverTime( 1.0 );
	self.lootString.alpha = 0;
	self.lootIcon fadeOverTime( 1.0 );
	self.lootIcon.alpha = 0;
}

setupLoot()
{
	precacheShader( "temp_mail_icon" );

	if ( getDvar( "scr_loot_dropDelay" ) == "" )
		setDvar( "scr_loot_dropDelay", 0.0 );

	if ( getDvar( "scr_loot_showTime" ) == "" )
		setDvar( "scr_loot_showTime", 7.0 );

	if ( getDvar( "scr_loot_offsetX" ) == "" )
		setDvar( "scr_loot_offsetX", 0 );

	if ( getDvar( "scr_loot_offsetY" ) == "" )
		setDvar( "scr_loot_offsetY", 0 );

	if ( getDvar( "scr_loot_slowPrint" ) == "" )
		setDvar( "scr_loot_slowPrint", 1 );
}


// ============== helpers ===============

registerMoneyType( type, value )
{
	level.scoreInfo[ type ][ "value" ] = value;
}

getScoreInfoValue( type )
{
	return( level.scoreInfo[ type ][ "value" ] );
}