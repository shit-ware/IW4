#include common_scripts\utility;
#include maps\mp\_utility;


init()
{	
	level thread onPlayerConnect();
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );

		//@NOTE: Should we make sure they're really unlocked before setting them? Catch cheaters...
		//			e.g. isItemUnlocked( iconHandle )

		iconHandle = player maps\mp\gametypes\_persistence::statGet( "cardIcon" );				
		player SetCardIcon( iconHandle );
		
		titleHandle = player maps\mp\gametypes\_persistence::statGet( "cardTitle" );
		player SetCardTitle( titleHandle );
		
		nameplateHandle = player maps\mp\gametypes\_persistence::statGet( "cardNameplate" );
		player SetCardNameplate( nameplateHandle );
	}
}