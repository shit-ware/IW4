#include maps\mp\_utility;
#include common_scripts\utility;

Callback_HostMigration()
{
	level.hostMigrationReturnedPlayerCount = 0;
	
	if ( level.gameEnded )
	{
		println( "Migration starting at time " + gettime() + ", but game has ended, so no countdown." );
		return;
	}
		
	println( "Migration starting at time " + gettime() );
	
	level.hostMigrationTimer = true;
	
	level notify( "host_migration_begin" );
	maps\mp\gametypes\_gamelogic::UpdateTimerPausedness();
	
	foreach ( player in level.players )
	{
		player thread hostMigrationTimerThink();
	}
	
	level endon( "host_migration_begin" );
	hostMigrationWait();
	
	
	level.hostMigrationTimer = undefined;
	println( "Migration finished at time " + gettime() );
	
	level notify( "host_migration_end" );
	maps\mp\gametypes\_gamelogic::UpdateTimerPausedness();
}

hostMigrationWait()
{
	level endon( "game_ended" );
	level endon( "nuke_death" );
	
	// start with a 20 second wait.
	// once we get enough players, or the first 15 seconds pass, switch to a 5 second timer.
	
	thread maps\mp\gametypes\_gamelogic::matchStartTimer( "waiting_for_players", 20.0 );
	hostMigrationWaitForPlayers();
	
	thread maps\mp\gametypes\_gamelogic::matchStartTimer( "match_resuming_in", 5.0 );
	wait 5;
}

hostMigrationWaitForPlayers()
{
	level endon( "hostmigration_enoughplayers" );
	wait 15;
}

hostMigrationTimerThink_Internal()
{
	level endon( "host_migration_begin" );
	level endon( "host_migration_end" );
	
	self.hostMigrationControlsFrozen = false;
	
	while ( !isReallyAlive( self ) )
	{
		self waittill( "spawned" );
	}
	
	self.hostMigrationControlsFrozen = true;
	self freezeControlsWrapper( true );
	
	level waittill( "host_migration_end" );
}

hostMigrationTimerThink()
{
	self endon( "disconnect" );
	
	self setClientDvar( "cg_scoreboardPingGraph", "0" );
	
	hostMigrationTimerThink_Internal();
	
	if ( self.hostMigrationControlsFrozen )
		self freezeControlsWrapper( false );
	
	self setClientDvar( "cg_scoreboardPingGraph", "1" );
}

waitTillHostMigrationDone()
{
	if ( !isDefined( level.hostMigrationTimer ) )
		return 0;
	
	starttime = gettime();
	level waittill( "host_migration_end" );
	return gettime() - starttime;
}

waitTillHostMigrationStarts( duration )
{
	if ( isDefined( level.hostMigrationTimer ) )
		return;
	
	level endon( "host_migration_begin" );
	wait duration;
}

waitLongDurationWithHostMigrationPause( duration )
{
	if ( duration == 0 )
		return;
	assert( duration > 0 );
	
	starttime = gettime();
	
	endtime = gettime() + duration * 1000;
	
	while ( gettime() < endtime )
	{
		waitTillHostMigrationStarts( (endtime - gettime()) / 1000 );
		
		if ( isDefined( level.hostMigrationTimer ) )
		{
			timePassed = waitTillHostMigrationDone();
			endtime += timePassed;
		}
	}
	
	assert( gettime() == endtime );
	waitTillHostMigrationDone();
	
	return gettime() - starttime;
}

waitLongDurationWithGameEndTimeUpdate( duration )
{
	if ( duration == 0 )
		return;
	assert( duration > 0 );
	
	starttime = gettime();
	
	endtime = gettime() + duration * 1000;
	
	while ( gettime() < endtime )
	{
		waitTillHostMigrationStarts( (endtime - gettime()) / 1000 );
		
		while ( isDefined( level.hostMigrationTimer ) )
		{
			endTime += 1000;
			setGameEndTime( int( endTime ) );
			wait 1;
		}
	}
	
	assert( gettime() == endtime );
	while ( isDefined( level.hostMigrationTimer ) )
	{
		endTime += 1000;
		setGameEndTime( int( endTime ) );
		wait 1;
	}
	
	return gettime() - starttime;
}

