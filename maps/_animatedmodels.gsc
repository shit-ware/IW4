#include common_scripts\utility;

#using_animtree( "animated_props" );
main()
{
	// wait until the end of the frame so that maps can init their trees
	// in their _anim instead of only above _load
	waittillframeend;

	init_wind_if_uninitialized();

	level.init_animatedmodels_dump = false;
	level.anim_prop_models_animtree = #animtree;

	if ( !isdefined( level.anim_prop_models ) )
		level.anim_prop_models = [];// this is what the LD puts in their map

	animated_models = GetEntArray( "animated_model", "targetname" );
	array_thread( animated_models, ::model_init );

	// one or more of the models initialized by model_init() was not setup by the map
	// so print this helpful note so the designer can see how to add it ot their level
	if ( level.init_animatedmodels_dump )
		AssertMsg( "anims not cached for animated prop model, Repackage Zones and Rebuild Precache Script in Launcher:" );

	// Handle blended tree anims differently
	foreach ( model in animated_models )
	{
		keys = GetArrayKeys( level.anim_prop_models[ model.model ] );
		scriptedWind = false;
		foreach ( key in keys )
		{
			if ( key == "still" )
			{
				scriptedWind = true;
				break;
			}
		}
		
		if ( scriptedWind )
			model thread animateTreeWind();
		else
			model thread animateModel();
	}
}

init_wind_if_uninitialized()
{
	if ( IsDefined( level.wind ) )
		return;
	level.wind = SpawnStruct();
	level.wind.rate = 0.4;
	level.wind.weight = 1;
	level.wind.variance = 0.2;
}

model_init()
{
	if ( !isdefined( level.anim_prop_models[ self.model ] ) )
		level.init_animatedmodels_dump = true;
}

// TODO: instead of purely random, do round-robin animation selection to get an even spread
animateModel()
{
	self UseAnimTree( #animtree );
	keys = GetArrayKeys( level.anim_prop_models[ self.model ] );
	animkey = keys[ RandomInt( keys.size ) ];
	animation = level.anim_prop_models[ self.model ][ animkey ];
	
	self SetAnim( animation, 1, self GetAnimTime( animation ), 1 );
	self SetAnimTime( animation, RandomFloatRange( 0, 1 ) );
}

animateTreeWind()
{
	self UseAnimTree( #animtree );
	wind = "strong";
	while ( 1 )
	{
		thread blendTreeAnims( wind );
		level waittill( "windchange", wind );
	}
}

blendTreeAnims( animation )
{
	level endon( "windchange" );
	windweight = level.wind.weight;
	windrate = level.wind.rate + RandomFloat( level.wind.variance );
	self SetAnim( level.anim_prop_models[ self.model ][ "still" ], 1, self GetAnimTime( level.anim_prop_models[ self.model ][ "still" ] ), windrate );
	self SetAnim( level.anim_prop_models[ self.model ][ animation ], windweight, self GetAnimTime( level.anim_prop_models[ self.model ][ animation ] ), windrate );
}

