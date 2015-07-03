#include common_scripts\utility;
#include maps\_utility;

// bcs requests:
// Roadkill:
// single story roof or just generic roof
// school lines unnec

// gulag:
// dont need trigger_multiple_bcs_tfstealth_landmark_lockers_SWside
// dont need trigger_multiple_bcs_tfstealth_landmark_lockers_NEside
// instead did left and right

// For new stuff I put this above it:  //** new

bcs_location_trigs_init()
{
	ASSERT( !IsDefined( level.bcs_location_mappings ) );
	level.bcs_location_mappings = [];
	
	bcs_location_trigs_do_mappings();
	
	bcs_trigs_assign_aliases();
	
	// now that the trigger ents have their aliases set on them, clear out our big array
	//  so we can save on script variables
	level.bcs_location_mappings = undefined;
}

bcs_trigs_assign_aliases()
{
	ASSERT( !IsDefined( anim.bcs_locations ) );
	anim.bcs_locations = [];
	
	ents = GetEntArray();
	trigs = [];
	foreach( trig in ents )
	{
		if( IsDefined( trig.classname ) && IsSubStr( trig.classname, "trigger_multiple_bcs" ) )
		{
			trigs[ trigs.size ] = trig;
		}
	}
	
	foreach( trig in trigs )
	{
		ASSERT( IsDefined( level.bcs_location_mappings[ trig.classname ] ), "Couldn't find bcs location mapping for battlechatter trigger with classname " + trig.classname );
		
		aliases = ParseLocationAliases( level.bcs_location_mappings[ trig.classname ] );
		if( aliases.size > 1 )
		{
			aliases = array_randomize( aliases );
		}
		
		trig.locationAliases = aliases;
	}
	
	anim.bcs_locations = trigs;
}

// parses locationStr using a space as a token and returns an array of the data in that field
ParseLocationAliases( locationStr )
{
	locationAliases = StrTok( locationStr, " " );
	return locationAliases;
}

add_bcs_location_mapping( classname, alias )
{
	// see if we have to add to an existing entry
	if( IsDefined( level.bcs_location_mappings[ classname ] ) )
	{
		existing = level.bcs_location_mappings[ classname ];
		existingArr = ParseLocationAliases( existing );
		aliases = ParseLocationAliases( alias );
		
		foreach( a in aliases )
		{
			foreach( e in existingArr )
			{
				if( a == e )
				{
					return;
				}
			}
		}
		
		existing += " " + alias;
		level.bcs_location_mappings[ classname ] = existing;
		
		return;
	}
	
	// otherwise make a new entry
	level.bcs_location_mappings[ classname ] = alias;
}


// here's where we set up each kind of trigger and map them to their (partial) soundaliases
bcs_location_trigs_do_mappings()
{	
//-----------------
// -- GENERICS --
//-----------------

// ----------- BUILDINGS -----------

/*QUAKED trigger_multiple_bcs_us_building_1stfloor_window (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_1stfloor_window", "blg_1f_wndw callout_loc_wndw_1st_report" );

/*QUAKED trigger_multiple_bcs_taskforce_building_1stfloor_window (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_1stfloor_window", "blg_1f_wndw callout_loc_wndw_1st_report" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_1stfloor_window (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_1stfloor_window", "blg_1f_wndw callout_loc_wndw_1st_report" );


/*QUAKED trigger_multiple_bcs_us_building_1stfloor_door (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_1stfloor_door", "blg_1f_door callout_loc_door_1st_report" );

/*QUAKED trigger_multiple_bcs_taskforce_building_1stfloor_door (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_1stfloor_door", "blg_1f_door callout_loc_door_1st_report" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_1stfloor_door (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_1stfloor_door", "blg_1f_door callout_loc_door_1st_report" );


/*QUAKED trigger_multiple_bcs_us_building_1stfloor_yellow (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_1stfloor_yellow", "blg_1f_ylw" );

/*QUAKED trigger_multiple_bcs_taskforce_building_1stfloor_yellow (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_1stfloor_yellow", "blg_1f_ylw" );
	
/*QUAKED trigger_multiple_bcs_tfstealth_building_1stfloor_yellow (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_1stfloor_yellow", "blg_1f_ylw" );


/*QUAKED trigger_multiple_bcs_us_building_2ndfloor_window_arched (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_2ndfloor_window_arched", "blg_1f_wndw_arch" );

/*QUAKED trigger_multiple_bcs_taskforce_building_2ndfloor_window_arched (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_2ndfloor_window_arched", "blg_1f_wndw_arch" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_2ndfloor_window_arched (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2ndfloor_window_arched", "blg_1f_wndw_arch" );



/*QUAKED trigger_multiple_bcs_us_building_2ndfloor_balcony (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_2ndfloor_balcony", "blg_2f_blc" );

/*QUAKED trigger_multiple_bcs_taskforce_building_2ndfloor_balcony (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_2ndfloor_balcony", "blg_2f_blc" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_2ndfloor_balcony (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2ndfloor_balcony", "blg_2f_blc" );



/*QUAKED trigger_multiple_bcs_us_building_2ndfloor_balcony_brick (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_2ndfloor_balcony_brick", "blg_2f_blc_brk" );

/*QUAKED trigger_multiple_bcs_taskforce_building_2ndfloor_balcony_brick (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_2ndfloor_balcony_brick", "blg_2f_blc_brk" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_2ndfloor_balcony_brick (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2ndfloor_balcony_brick", "blg_2f_blc_brk" );



/*QUAKED trigger_multiple_bcs_us_building_2ndfloor_balcony_south (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_2ndfloor_balcony_south", "blg_2f_s" );

/*QUAKED trigger_multiple_bcs_taskforce_building_2ndfloor_balcony_south (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_2ndfloor_balcony_south", "blg_2f_s" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_2ndfloor_balcony_south (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2ndfloor_balcony_south", "blg_2f_s" );



/*QUAKED trigger_multiple_bcs_us_building_2ndfloor_balcony_behindmetalsheets (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_2ndfloor_balcony_behindmetalsheets", "blg_2f_mtlshts" );

/*QUAKED trigger_multiple_bcs_taskforce_building_2ndfloor_balcony_behindmetalsheets (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_2ndfloor_balcony_behindmetalsheets", "blg_2f_mtlshts" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_2ndfloor_balcony_behindmetalsheets (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2ndfloor_balcony_behindmetalsheets", "blg_2f_mtlshts" );



/*QUAKED trigger_multiple_bcs_us_building_2ndfloor_balcony_behindsandbags (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_2ndfloor_balcony_behindsandbags", "blg_2f_sndbgs" );

/*QUAKED trigger_multiple_bcs_taskforce_building_2ndfloor_balcony_behindsandbags (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_2ndfloor_balcony_behindsandbags", "blg_2f_sndbgs" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_2ndfloor_balcony_behindsandbags (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2ndfloor_balcony_behindsandbags", "blg_2f_sndbgs" );



/*QUAKED trigger_multiple_bcs_us_building_2ndfloor_balcony_corrugatedmetal (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_2ndfloor_balcony_corrugatedmetal", "blg_2f_crgmtl" );

/*QUAKED trigger_multiple_bcs_taskforce_building_2ndfloor_balcony_corrugatedmetal (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_2ndfloor_balcony_corrugatedmetal", "blg_2f_crgmtl" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_2ndfloor_balcony_corrugatedmetal (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2ndfloor_balcony_corrugatedmetal", "blg_2f_crgmtl" );



/*QUAKED trigger_multiple_bcs_us_building_1story_grey (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_1story_grey", "blg_1s_gry" );

/*QUAKED trigger_multiple_bcs_taskforce_building_1story_grey (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_1story_grey", "blg_1s_gry" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_1story_grey (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_1story_grey", "blg_1s_gry" );



/*QUAKED trigger_multiple_bcs_us_building_2story_roof (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_2story_roof", "blg_2s_rf" );

/*QUAKED trigger_multiple_bcs_taskforce_building_2story_roof (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_2story_roof", "blg_2s_rf" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_2story_roof (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2story_roof", "blg_2s_rf" );



/*QUAKED trigger_multiple_bcs_us_building_2story_roof_leftmost (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_2story_roof_leftmost", "blg_2s_rf_left" );

/*QUAKED trigger_multiple_bcs_taskforce_building_2story_roof_leftmost (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_2story_roof_leftmost", "blg_2s_rf_left" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_2story_roof_leftmost (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2story_roof_leftmost", "blg_2s_rf_left" );



/*QUAKED trigger_multiple_bcs_us_building_2story_yellow_roof (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_2story_yellow_roof", "blg_2s_ylw_rf" );

/*QUAKED trigger_multiple_bcs_taskforce_building_2story_yellow_roof (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_2story_yellow_roof", "blg_2s_ylw_rf" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_2story_yellow_roof (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2story_yellow_roof", "blg_2s_ylw_rf" );



/*QUAKED trigger_multiple_bcs_us_building_2story_white_roof (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_2story_white_roof", "blg_2s_wht_rf" );

/*QUAKED trigger_multiple_bcs_taskforce_building_2story_white_roof (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_2story_white_roof", "blg_2s_wht_rf" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_2story_white_roof (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2story_white_roof", "blg_2s_wht_rf" );



/*QUAKED trigger_multiple_bcs_us_building_inside_frontdoor (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_frontdoor", "blg_ins_door_frnt" );

/*QUAKED trigger_multiple_bcs_taskforce_building_inside_frontdoor (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_inside_frontdoor", "blg_ins_door_frnt" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_inside_frontdoor (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_inside_frontdoor", "blg_ins_door_frnt" );



/*QUAKED trigger_multiple_bcs_us_building_inside_backdoor (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_backdoor", "blg_ins_door_bck" );

/*QUAKED trigger_multiple_bcs_taskforce_building_inside_backdoor (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_inside_backdoor", "blg_ins_door_bck" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_inside_backdoor (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_inside_backdoor", "blg_ins_door_bck" );



/*QUAKED trigger_multiple_bcs_us_building_inside_stairs (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_stairs", "blg_ins_stairs" );

/*QUAKED trigger_multiple_bcs_taskforce_building_inside_stairs (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_inside_stairs", "blg_ins_stairs" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_inside_stairs (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_inside_stairs", "blg_ins_stairs" );



/*QUAKED trigger_multiple_bcs_us_building_inside_bathroom (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_bathroom", "blg_ins_bthrm" );

/*QUAKED trigger_multiple_bcs_taskforce_building_inside_bathroom (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_inside_bathroom", "blg_ins_bthrm" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_inside_bathroom (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_inside_bathroom", "blg_ins_bthrm" );



/*QUAKED trigger_multiple_bcs_us_building_inside_livingroom (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_livingroom", "blg_ins_lvgrm" );

/*QUAKED trigger_multiple_bcs_taskforce_building_inside_livingroom (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_inside_livingroom", "blg_ins_lvgrm" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_inside_livingroom (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_inside_livingroom", "blg_ins_lvgrm" );



/*QUAKED trigger_multiple_bcs_us_building_inside_upstairs (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_upstairs", "blg_ins_upstrs" );

/*QUAKED trigger_multiple_bcs_taskforce_building_inside_upstairs (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_inside_upstairs", "blg_ins_upstrs" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_inside_upstairs (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_inside_upstairs", "blg_ins_upstrs" );



/*QUAKED trigger_multiple_bcs_us_building_inside_garage (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_garage", "blg_ins_grge" );

/*QUAKED trigger_multiple_bcs_taskforce_building_inside_garage (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_inside_garage", "blg_ins_grge" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_inside_garage (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_inside_garage", "blg_ins_grge" );



/*QUAKED trigger_multiple_bcs_us_building_inside_basement (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_basement", "blg_ins_bsmt" );

/*QUAKED trigger_multiple_bcs_taskforce_building_inside_basement (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_inside_basement", "blg_ins_bsmt" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_inside_basement (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_inside_basement", "blg_ins_bsmt" );



/*QUAKED trigger_multiple_bcs_us_building_inside_balcony (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_balcony", "blg_ins_balc" );

/*QUAKED trigger_multiple_bcs_taskforce_building_inside_balcony (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_inside_balcony", "blg_ins_balc" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_inside_balcony (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_inside_balcony", "blg_ins_balc" );



/*QUAKED trigger_multiple_bcs_us_building_inside_cubicles (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_cubicles", "blg_ins_cubes" );

/*QUAKED trigger_multiple_bcs_taskforce_building_inside_cubicles (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_inside_cubicles", "blg_ins_cubes" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_inside_cubicles (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_inside_cubicles", "blg_ins_cubes" );



/*QUAKED trigger_multiple_bcs_us_building_inside_office_eastcorner (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_office_eastcorner", "blg_ins_offce_cnr_e" );

/*QUAKED trigger_multiple_bcs_taskforce_building_inside_office_eastcorner (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_inside_office_eastcorner", "blg_ins_offce_cnr_e" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_inside_office_eastcorner (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_inside_office_eastcorner", "blg_ins_offce_cnr_e" );



/*QUAKED trigger_multiple_bcs_us_building_shed (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_shed", "blg_shed" );

/*QUAKED trigger_multiple_bcs_taskforce_building_shed (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_shed", "blg_shed" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_shed (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_shed", "blg_shed" );
	


/*QUAKED trigger_multiple_bcs_us_building_roof (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_roof", "blg_shed" );

/*QUAKED trigger_multiple_bcs_taskforce_building_roof (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_roof", "blg_roof" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_roof (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_roof", "blg_roof" );


// ----------- LANDMARKS -----------

/*QUAKED trigger_multiple_bcs_us_landmark_desk_large (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_desk_large", "lm_dsk_lg" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_desk_large (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_desk_large", "lm_dsk_lg" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_desk_large (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_desk_large", "lm_dsk_lg" );



/*QUAKED trigger_multiple_bcs_us_landmark_desks_stacked (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_desks_stacked", "lm_dsk_stck" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_desks_stacked (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_desks_stacked", "lm_dsk_stck" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_desks_stacked (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_desks_stacked", "lm_dsk_stck" );



/*QUAKED trigger_multiple_bcs_us_landmark_ammocrates_stacked (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_ammocrates_stacked", "lm_amcrt_stck" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_ammocrates_stacked (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_ammocrates_stacked", "lm_amcrt_stck" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_ammocrates_stacked (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_ammocrates_stacked", "lm_amcrt_stck" );



/*QUAKED trigger_multiple_bcs_us_landmark_crates_stacked (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_crates_stacked", "lm_crt_stck" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_crates_stacked (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_crates_stacked", "lm_crt_stck" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_crates_stacked (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_crates_stacked", "lm_crt_stck" );



/*QUAKED trigger_multiple_bcs_us_landmark_fuelcontainer (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_fuelcontainer", "lm_fuelcont" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_fuelcontainer (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_fuelcontainer", "lm_fuelcont" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_fuelcontainer (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_fuelcontainer", "lm_fuelcont" );



/*QUAKED trigger_multiple_bcs_us_landmark_fuelcontainers (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_fuelcontainers", "lm_fuelconts" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_fuelcontainers (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_fuelcontainers", "lm_fuelconts" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_fuelcontainers (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_fuelcontainers", "lm_fuelconts" );



/*QUAKED trigger_multiple_bcs_us_landmark_garbagecans (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_garbagecans", "lm_gbgcns" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_garbagecans (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_garbagecans", "lm_gbgcns" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_garbagecans (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_garbagecans", "lm_gbgcns" );



/*QUAKED trigger_multiple_bcs_us_landmark_barrels (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_barrels", "lm_brls" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_barrels (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_barrels", "lm_brls" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_barrels (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_barrels", "lm_brls" );


/*QUAKED trigger_multiple_bcs_us_landmark_dumpster (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_dumpster", "lm_dpstr" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_dumpster (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_dumpster", "lm_dpstr" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_dumpster (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_dumpster", "lm_dpstr" );



/*QUAKED trigger_multiple_bcs_us_landmark_driveway (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_driveway", "lm_drvwy" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_driveway (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_driveway", "lm_drvwy" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_driveway (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_driveway", "lm_drvwy" );



/*QUAKED trigger_multiple_bcs_us_landmark_intersection_threeway (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_intersection_threeway", "lm_intsec_3w" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_intersection_threeway (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_intersection_threeway", "lm_intsec_3w" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_intersection_threeway (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_intersection_threeway", "lm_intsec_3w" );



/*QUAKED trigger_multiple_bcs_us_landmark_phonebooth (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_phonebooth", "lm_phnbth" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_phonebooth (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_phonebooth", "lm_phnbth" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_phonebooth (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_phonebooth", "lm_phnbth" );



/*QUAKED trigger_multiple_bcs_us_landmark_vendingmachine (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_vendingmachine", "lm_vendmach" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_vendingmachine (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_vendingmachine", "lm_vendmach" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_vendingmachine (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_vendingmachine", "lm_vendmach" );



/*QUAKED trigger_multiple_bcs_us_landmark_icemachine (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_icemachine", "lm_icemach" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_icemachine (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_icemachine", "lm_icemach" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_icemachine (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_icemachine", "lm_icemach" );



/*QUAKED trigger_multiple_bcs_us_landmark_newspaperbox (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_newspaperbox", "lm_newsbox" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_newspaperbox (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_newspaperbox", "lm_newsbox" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_newspaperbox (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_newspaperbox", "lm_newsbox" );



/*QUAKED trigger_multiple_bcs_us_landmark_sandbags (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_sandbags", "lm_sndbgs" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_sandbags (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_sandbags", "lm_sndbgs" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_sandbags (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_sandbags", "lm_sndbgs" );



/*QUAKED trigger_multiple_bcs_us_landmark_barricade_concrete (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_barricade_concrete", "lm_barr_conc" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_barricade_concrete (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_barricade_concrete", "lm_barr_conc" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_barricade_concrete (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_barricade_concrete", "lm_barr_conc" );



/*QUAKED trigger_multiple_bcs_us_landmark_hescobarrier (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_hescobarrier", "lm_hescobarr" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_hescobarrier (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_hescobarrier", "lm_hescobarr" );

/*QUAKED trigger_multiple_bcs_tfstealth_landmark_hescobarrier (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_hescobarrier", "lm_hescobarr" );


// ----------- VEHICLES -----------

/*QUAKED trigger_multiple_bcs_us_vehicle_humvee_parked (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_humvee_parked", "vh_hmv_pkd" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_humvee_parked (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_humvee_parked", "vh_hmv_pkd" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_humvee_parked (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_humvee_parked", "vh_hmv_pkd" );



/*QUAKED trigger_multiple_bcs_us_vehicle_humvee_parked_left (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_humvee_parked_left", "vh_hmv_pkd_l" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_humvee_parked_left (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_humvee_parked_left", "vh_hmv_pkd_l" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_humvee_parked_left (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_humvee_parked_left", "vh_hmv_pkd_l" );



/*QUAKED trigger_multiple_bcs_us_vehicle_humvee_parked_right (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_humvee_parked_right", "vh_hmv_pkd_r" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_humvee_parked_right (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_humvee_parked_right", "vh_hmv_pkd_r" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_humvee_parked_right (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_humvee_parked_right", "vh_hmv_pkd_r" );



/*QUAKED trigger_multiple_bcs_us_vehicle_car_taxi (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_car_taxi", "vh_car_taxi" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_car_taxi (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_car_taxi", "vh_car_taxi" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_car_taxi (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_car_taxi", "vh_car_taxi" );



/*QUAKED trigger_multiple_bcs_us_vehicle_car_black (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_car_black", "vh_car_blk" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_car_black (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_car_black", "vh_car_blk" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_car_black (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_car_black", "vh_car_blk" );



/*QUAKED trigger_multiple_bcs_us_vehicle_car_grey (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_car_grey", "vh_car_gry" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_car_grey (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_car_grey", "vh_car_gry" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_car_grey (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_car_grey", "vh_car_gry" );
	
	
/*QUAKED trigger_multiple_bcs_us_vehicle_van_white (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_van_white", "vh_van_wht" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_van_white (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_van_white", "vh_van_wht" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_van_white (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_van_white", "vh_van_wht" );


/*QUAKED trigger_multiple_bcs_us_vehicle_car_hatchback_blue (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_car_hatchback_blue", "vh_car_hb_blu" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_car_hatchback_blue (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_car_hatchback_blue", "vh_car_hb_blu" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_car_hatchback_blue (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_car_hatchback_blue", "vh_car_hb_blu" );



/*QUAKED trigger_multiple_bcs_us_vehicle_car_hatchback_green (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_car_hatchback_green", "vh_car_hb_grn" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_car_hatchback_green (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_car_hatchback_green", "vh_car_hb_grn" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_car_hatchback_green (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_car_hatchback_green", "vh_car_hb_grn" );



/*QUAKED trigger_multiple_bcs_us_vehicle_car_hatchback_black (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_car_hatchback_black", "vh_car_hb_blk" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_car_hatchback_black (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_car_hatchback_black", "vh_car_hb_blk" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_car_hatchback_black (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_car_hatchback_black", "vh_car_hb_blk" );



/*QUAKED trigger_multiple_bcs_us_vehicle_car_stationwagon_yellow (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_car_stationwagon_yellow", "vh_car_sw_ylw" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_car_stationwagon_yellow (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_car_stationwagon_yellow", "vh_car_sw_ylw" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_car_stationwagon_yellow (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_car_stationwagon_yellow", "vh_car_sw_ylw" );



/*QUAKED trigger_multiple_bcs_us_vehicle_car_police (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_car_police", "vh_car_pol" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_car_police (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_car_police", "vh_car_pol" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_car_police (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_car_police", "vh_car_pol" );



/*QUAKED trigger_multiple_bcs_us_vehicle_car_police_destroyed (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_car_police_destroyed", "vh_car_pol_dst" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_car_police_destroyed (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_car_police_destroyed", "vh_car_pol_dst" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_car_police_destroyed (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_car_police_destroyed", "vh_car_pol_dst" );



/*QUAKED trigger_multiple_bcs_us_vehicle_truck_white (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_truck_white", "vh_trk_wht" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_truck_white (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_truck_white", "vh_trk_wht" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_truck_white (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_truck_white", "vh_trk_wht" );



/*QUAKED trigger_multiple_bcs_us_vehicle_truck_white_destroyed (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_truck_white_destroyed", "vh_trk_wht_dst" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_truck_white_destroyed (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_truck_white_destroyed", "vh_trk_wht_dst" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_truck_white_destroyed (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_truck_white_destroyed", "vh_trk_wht_dst" );



/*QUAKED trigger_multiple_bcs_us_vehicle_truck_black (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_truck_black", "vh_trk_blk" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_truck_black (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_truck_black", "vh_trk_blk" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_truck_black (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_truck_black", "vh_trk_blk" );



/*QUAKED trigger_multiple_bcs_us_vehicle_truck_destroyed (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_truck_destroyed", "vh_trk_dst" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_truck_destroyed (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_truck_destroyed", "vh_trk_dst" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_truck_destroyed (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_truck_destroyed", "vh_trk_dst" );



/*QUAKED trigger_multiple_bcs_us_vehicle_suv_black (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_suv_black", "vh_suv_blk" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_suv_black (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_suv_black", "vh_suv_blk" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_suv_black (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_suv_black", "vh_suv_blk" );



/*QUAKED trigger_multiple_bcs_us_vehicle_suv_black_overturned (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_suv_black_overturned", "vh_suv_blk_ovrtnd" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_suv_black_overturned (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_suv_black_overturned", "vh_suv_blk_ovrtnd" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_suv_black_overturned (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_suv_black_overturned", "vh_suv_blk_ovrtnd" );



/*QUAKED trigger_multiple_bcs_us_vehicle_tankertruck (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_tankertruck", "vh_trk_tnk" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_tankertruck (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_tankertruck", "vh_trk_tnk" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_tankertruck (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_tankertruck", "vh_trk_tnk" );



/*QUAKED trigger_multiple_bcs_us_vehicle_uaz (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_uaz", "vh_uaz" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_uaz (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_uaz", "vh_uaz" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_uaz (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_uaz", "vh_uaz" );



/*QUAKED trigger_multiple_bcs_us_vehicle_bus (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_bus", "vh_bus" );

/*QUAKED trigger_multiple_bcs_taskforce_vehicle_bus (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_bus", "vh_bus" );

/*QUAKED trigger_multiple_bcs_tfstealth_vehicle_bus (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_vehicle_bus", "vh_bus" );




//-------------------------
// OILRIG (tfstealth)
//-------------------------
/*QUAKED trigger_multiple_bcs_tfstealth_building_2ndfloor_windows (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2ndfloor_windows", "blg_2f_wndws" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_rappelling_leftside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_rappelling_leftside", "lm_rappel_left" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_stairs_down (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_stairs_down", "lm_stairs_down" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_stairs_up (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_stairs_up", "lm_stairs_up" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_stairs_yellow (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_stairs_yellow", "lm_stairs_ylw" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_catwalk_yellow_small (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_catwalk_yellow_small", "lm_ctwlk_ylw_sml" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_catwalk_yellow_large (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_catwalk_yellow_large", "lm_ctwlk_ylw_lg" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_catwalk_yellow_behindgirderstack (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_catwalk_yellow_behindgirderstack", "lm_ctwlk_ylw_grdr" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_corrugatedmetal (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_corrugatedmetal", "lm_corrgatedmtl" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_dumpster_red_long (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_dumpster_red_long", "lm_dmpstr_red_lng" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_wirespool_large (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_wirespool_large", "lm_wirespl_lg" );



//-------------------------
// GULAG (tfstealth)
//-------------------------
/*QUAKED trigger_multiple_bcs_tfstealth_landmark_lowwall_underbarbedwire (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_lowwall_underbarbedwire", "lm_lowwall_bwire" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_celldoor_endofhall (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_celldoor_endofhall", "lm_celldr_endhl" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_cell_left (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_cell_left", "lm_cell_l" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_cell_right (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_cell_right", "lm_cell_r" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_pipes_behind (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_pipes_behind", "lm_pipes_behind" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_showers_center (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_showers_center", "lm_shwr_cntr" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_showers_SWside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_showers_SWside", "lm_shwr_sw" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_showers_NEside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_showers_NEside", "lm_shwr_ne" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_lockers_center (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_lockers_center", "lm_lckr_cntr" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_lockers_left (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_lockers_left", "lm_lckr_l" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_lockers_right(0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_lockers_right", "lm_lckr_r" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_arches_above(0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_arches_above", "lm_wlkwy_abv_archs" );




//-------------------------
// FAVELA ESCAPE (taskforce)
//-------------------------
/*QUAKED trigger_multiple_bcs_taskforce_building_shack_left (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_shack_left", "blg_shack_left" );


/*QUAKED trigger_multiple_bcs_taskforce_building_icecreamstore_balcony (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_icecreamstore_balcony", "blg_icecrm_balc" );


/*QUAKED trigger_multiple_bcs_taskforce_building_rooftops_ahead(0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_rooftops_ahead", "blg_rftop_ahead" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_market_alleyway_shotgunner (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_market_alleyway_shotgunner", "lm_mrkt_alley_shgn" );

/*QUAKED trigger_multiple_bcs_taskforce_landmark_awning_green_marketcenter (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_awning_green_marketcenter", "lm_awn_grn_mrktcntr" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_awning_redwhitestriped (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_awning_redwhitestriped", "lm_awn_rdwhtstripe" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_vista_bigtree (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_vista_bigtree", "lm_vst_bigtree" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_lowwall_betweentwobldgs_right (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_lowwall_betweentwobldgs_right", "lm_wall_bt2bldgs_r" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_fence_white_atopridge (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_fence_white_atopridge", "lm_fence_wht_ridge" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_refrigerator (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_refrigerator", "lm_fridge" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_tirestack (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_tirestack", "lm_tirestk" );
	
	
/*QUAKED trigger_multiple_bcs_taskforce_vehicle_car_stationwagon_black (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_car_stationwagon_black", "vh_stwag_blk" );


//-------------------------
// ESTATE (taskforce)
//-------------------------
/*QUAKED trigger_multiple_bcs_taskforce_landmark_haybale (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_haybale", "lm_haybale" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_logstack (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_logstack", "lm_logstack" );


/*QUAKED trigger_multiple_bcs_taskforce_vehicle_tractor (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_tractor", "vh_tractor" );



//-------------------------
// CONTINGENCY (taskforce)
//-------------------------
/*QUAKED trigger_multiple_bcs_taskforce_landmark_wall_barbwire (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_wall_barbwire", "lm_wall_barbwire" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_stairs_behindstairs (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_stairs_behindstairs", "lm_stairs_behind" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_refuelingstation (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_refuelingstation", "lm_fuelstation" );


/*QUAKED trigger_multiple_bcs_taskforce_building_hangar_num1 (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_hangar_num1", "blg_hngr_num1" );


/*QUAKED trigger_multiple_bcs_taskforce_building_hangar_num2 (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_hangar_num2", "blg_hngr_num2" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_cargocontainer (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_cargocontainer", "lm_crgocont" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_cargocontainer_2stack (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_cargocontainer_2stack", "lm_crgocont_2stack" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_cargocontainer_3stack (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_cargocontainer_3stack", "lm_crgocont_3stack" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_cargocontainer_4stack (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_cargocontainer_4stack", "lm_crgocont_4stack" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_cargocontainer_between (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_cargocontainer_between", "lm_crgocont_between" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_helipad (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_helipad", "lm_helipad" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_railing (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_railing", "lm_railing" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_wall_concrete_tall (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_wall_concrete_tall", "lm_wall_conc_tall" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_submarine_nextto (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_submarine_nextto", "lm_sub_nextto" );


/*QUAKED trigger_multiple_bcs_taskforce_vehicle_forklift (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_forklift", "vh_forklift" );


/*QUAKED trigger_multiple_bcs_taskforce_vehicle_snowcat (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_vehicle_snowcat", "vh_snowcat" );


/*QUAKED trigger_multiple_bcs_taskforce_landmark_crane_beneath (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_crane_beneath", "lm_crane_beneath" );
	

/*QUAKED trigger_multiple_bcs_taskforce_landmark_stairs_on (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_stairs_on", "lm_stairs_on" );
	
	
/*QUAKED trigger_multiple_bcs_taskforce_landmark_stairs_nextto (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_landmark_stairs_nextto", "lm_stairs_nextto" );




//-------------------------
// AFGHAN CAVES (taskforce)
//-------------------------
/*QUAKED trigger_multiple_bcs_tfstealth_building_guardtower (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_guardtower", "blg_grdtwr" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_cave_center (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_cave_center", "lm_cv_cent" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_cave_center_tv (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_cave_center_tv", "lm_cv_cent_tv" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_cave_center_concretesupport (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_cave_center_concretesupport", "lm_cv_cent_concsup" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_cave_outsidewall (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_cave_outsidewall", "lm_cv_wall_outside" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_cave_insidewall (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_cave_insidewall", "lm_cv_wall_inside" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_tunnel_leadingoutside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_tunnel_leadingoutside", "lm_tun_leadoutside" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_cave_small_left (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_cave_small_left", "lm_cv_small_l" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_cratestack_nearledge (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_cratestack_nearledge", "lm_crtstk_nrldge" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_hescobarrier_nearledge (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_hescobarrier_nearledge", "lm_hesco_nrldge" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_pipes_northside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_pipes_northside", "lm_pipes_nside" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_catwalk (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_catwalk", "lm_catwlk" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_across_chasm (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_across_chasm", "lm_acrosschasm" );


/*QUAKED trigger_multiple_bcs_tfstealth_landmark_SAMlauncher (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_SAMlauncher", "lm_samlnchr" );
	
	
/*QUAKED trigger_multiple_bcs_tfstealth_landmark_hedgehog (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_hedgehog", "lm_hdghog" );



/*QUAKED trigger_multiple_bcs_tfstealth_landmark_cot (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_cot", "lm_cot" );
	
	
	
/*QUAKED trigger_multiple_bcs_tfstealth_landmark_sentrygun (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_landmark_sentrygun", "lm_sentrygun" );



//-------------------------
// INVASION (US)
//-------------------------
/*QUAKED trigger_multiple_bcs_us_building_diner_inside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_diner_inside", "blg_diner_ins" );


/*QUAKED trigger_multiple_bcs_us_building_diner_behindcounter (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_diner_behindcounter", "blg_diner_bhcntr" );


/*QUAKED trigger_multiple_bcs_us_building_burgertown_inside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_burgertown_inside", "blg_bgrtwn_ins" );


/*QUAKED trigger_multiple_bcs_us_building_burgertown_roof (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_burgertown_roof", "blg_bgrtwn_roof" );


/*QUAKED trigger_multiple_bcs_us_building_burgertown_backdoor (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_burgertown_backdoor", "blg_bgrtwn_bkdr" );


/*QUAKED trigger_multiple_bcs_us_building_burgertown_kitchen (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_burgertown_kitchen", "blg_bgrtwn_kchn" );


/*QUAKED trigger_multiple_bcs_us_building_burgertown_diningarea (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_burgertown_diningarea", "blg_bgrtwn_tbls" );
	

/*QUAKED trigger_multiple_bcs_us_building_burgertown_parkinglot (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_burgertown_parkinglot", "blg_bgrtwn_prklt" );


/*QUAKED trigger_multiple_bcs_us_building_crbfinancial_inside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_crbfinancial_inside", "blg_crb_ins" );


/*QUAKED trigger_multiple_bcs_us_building_crbfinancial_nextto (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_crbfinancial_nextto", "blg_crb_nextto" );


/*QUAKED trigger_multiple_bcs_us_building_conveniencestore_nextto (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_conveniencestore_nextto", "blg_cnvstr_nextto" );


/*QUAKED trigger_multiple_bcs_us_building_novastarstation_inside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_novastarstation_inside", "blg_nova_ins" );


/*QUAKED trigger_multiple_bcs_us_landmark_gaspumps_between (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_gaspumps_between", "lm_pmps_btwn" );


/*QUAKED trigger_multiple_bcs_us_vehicle_helicopter_crashed (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_helicopter_crashed", "vh_heli_crsh" );



/*QUAKED trigger_multiple_bcs_us_building_natesrestaurant_nextto (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_natesrestaurant_nextto", "blg_nates_nextto" );
	
	

/*QUAKED trigger_multiple_bcs_us_building_natesrestaurant_inside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_natesrestaurant_inside", "blg_nates_ins" );
	
	

/*QUAKED trigger_multiple_bcs_us_building_natesrestaurant_roof (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_natesrestaurant_roof", "blg_nates_roof" );



/*QUAKED trigger_multiple_bcs_us_building_tacotogo_inside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_tacotogo_inside", "blg_tcotgo_ins" );
	
	

/*QUAKED trigger_multiple_bcs_us_building_tacotogo_nextto (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_tacotogo_nextto", "blg_tcotgo_nextto" );
	
	
	
/*QUAKED trigger_multiple_bcs_us_building_tacotogo_parkinglot (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_tacotogo_parkinglot", "blg_tcotgo_prklt" );
	
	
	
/*QUAKED trigger_multiple_bcs_us_landmark_burgertown_sign (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_burgertown_sign", "lm_bgrtwn_roof" );



/*QUAKED trigger_multiple_bcs_us_vehicle_van_blue (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_van_blue", "vh_van_blue" );

	


//-------------------------
// ARCADIA (US)
//-------------------------
/*QUAKED trigger_multiple_bcs_us_building_apartments_office (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_apartments_office", "blg_apt_office" );


/*QUAKED trigger_multiple_bcs_us_building_apartments_3rdfloor (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_apartments_3rdfloor", "blg_apt_3f" );


/*QUAKED trigger_multiple_bcs_us_building_mansion_grey_frontsteps (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_mansion_grey_frontsteps", "blg_mn_stps" );


/*QUAKED trigger_multiple_bcs_us_building_archway_right (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_archway_right", "blg_arch_right" );


/*QUAKED trigger_multiple_bcs_us_building_archway_left (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_archway_left", "blg_arch_left" );


/*QUAKED trigger_multiple_bcs_us_building_mansion_whitestripe_east (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_mansion_whitestripe_east", "blg_mn_whtstrp_e" );


/*QUAKED trigger_multiple_bcs_us_building_mansion_fountainfrontyard_east (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_mansion_fountainfrontyard_east", "blg_mn_ftn_e" );


/*QUAKED trigger_multiple_bcs_us_building_mansion_lightbrown_west (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_mansion_lightbrown_west", "blg_mn_ltbrwn_w" );


/*QUAKED trigger_multiple_bcs_us_building_mansion_brickwhitetrim_west (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_mansion_brickwhitetrim_west", "blg_mn_bkwtrm_w" );


/*QUAKED trigger_multiple_bcs_us_landmark_median (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_median", "lm_med" );



/*QUAKED trigger_multiple_bcs_us_landmark_parkinglot_eastside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_parkinglot_eastside", "lm_parkinglot_e" );


/*QUAKED trigger_multiple_bcs_us_landmark_sign_arcadia (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_sign_arcadia", "lm_sign_arc" );


/*QUAKED trigger_multiple_bcs_us_landmark_archway_large (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_archway_large", "lm_arch_lg" );


/*QUAKED trigger_multiple_bcs_us_landmark_golfcourse_green (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_golfcourse_green", "lm_golfcourse_green" );


/*QUAKED trigger_multiple_bcs_us_landmark_barricade_police (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_barricade_police", "lm_barr_police" );



/*QUAKED trigger_multiple_bcs_us_landmark_guardhouse (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_guardhouse", "lm_guardhouse" );


/*QUAKED trigger_multiple_bcs_us_landmark_planecrash_tailsection (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_planecrash_tailsection", "lm_plane_tailsec" );


/*QUAKED trigger_multiple_bcs_us_landmark_planecrash_engine (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_planecrash_engine", "lm_plane_engine" );


/*QUAKED trigger_multiple_bcs_us_vehicle_firetruck (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_firetruck", "vh_firetruck" );
	
	
/*QUAKED trigger_multiple_bcs_us_building_house_red_porch (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_house_red_porch", "blg_house_rd_prch" );
	
	
/*QUAKED trigger_multiple_bcs_us_building_house_grey_patio (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_house_grey_patio", "blg_house_gry_ptio" );
	
	
/*QUAKED trigger_multiple_bcs_us_building_inside_pooltable (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_pooltable", "blg_ins_pooltbl" );
	
	
/*QUAKED trigger_multiple_bcs_us_building_inside_minibar (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_minibar", "blg_ins_minibar" );
	
	
/*QUAKED trigger_multiple_bcs_us_building_inside_winecellar (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_winecellar", "blg_ins_winecllr" );
	
	
/*QUAKED trigger_multiple_bcs_us_building_inside_diningroom (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_diningroom", "blg_ins_dngrm" );
	
	
/*QUAKED trigger_multiple_bcs_us_building_inside_kitchen (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_kitchen", "blg_ins_ktchn" );
	
	
/*QUAKED trigger_multiple_bcs_us_landmark_apartments_sign (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_apartments_sign", "lm_apt_sign" );
	
	
/*QUAKED trigger_multiple_bcs_us_landmark_fence_white (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_fence_white", "lm_fence_wht" );
	
	
/*QUAKED trigger_multiple_bcs_us_landmark_wall_stone (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_wall_stone", "lm_wall_stn" );




//-------------------------
// DCBURNING (US)
//-------------------------
/*QUAKED trigger_multiple_bcs_us_building_inside_balcony_south (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_balcony_south", "blg_ins_bal_s" );


/*QUAKED trigger_multiple_bcs_us_building_inside_balcony_farside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_balcony_farside", "blg_ins_bal_far" );
	
	
/*QUAKED trigger_multiple_bcs_us_landmark_copymachine (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_copymachine", "lm_copymach" );



//-------------------------
// DCEMP (US)
//-------------------------
/*QUAKED trigger_multiple_bcs_us_building_inside_windows_rightside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_windows_rightside", "blg_ins_wndws_rside" );
	
	
/*QUAKED trigger_multiple_bcs_us_building_inside_office_glass_right (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_office_glass_right", "blg_ins_off_gls_rside" );
	
	
/*QUAKED trigger_multiple_bcs_us_building_inside_office_glass_left (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_office_glass_left", "blg_ins_off_gls_lside" );
	
	
/*QUAKED trigger_multiple_bcs_us_building_inside_cubicles_middle (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_cubicles_middle", "blg_ins_cubes_mid" );
	
	
/*QUAKED trigger_multiple_bcs_us_building_inside_cubicles_right (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_cubicles_right", "blg_ins_cubes_rside" );
	
	
/*QUAKED trigger_multiple_bcs_us_building_inside_cubicles_left (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_inside_cubicles_left", "blg_ins_cubes_lside" );
	
	
/*QUAKED trigger_multiple_bcs_us_landmark_shelves_middle (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_shelves_middle", "lm_shlvs_mid" );
	
	
/*QUAKED trigger_multiple_bcs_us_landmark_shelves_left (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_shelves_left", "lm_shlvs_lside" );
	
	
/*QUAKED trigger_multiple_bcs_us_landmark_shelves_right (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_shelves_right", "lm_shlvs_rside" );
	
	
/*QUAKED trigger_multiple_bcs_us_vehicle_car_burning (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_car_burning", "vh_car_brng" );
	
	
/*QUAKED trigger_multiple_bcs_us_vehicle_tank (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_vehicle_tank", "vh_tank" );




//-------------------------
// AIRPORT (US)
//-------------------------
/*QUAKED trigger_multiple_bcs_us_building_airport_terminal_2ndfloor (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_airport_terminal_2ndfloor", "blg_airport_term_2f" );


/*QUAKED trigger_multiple_bcs_us_landmark_supportbeams_orange (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_supportbeams_orange", "lm_sprtbms_orange" );


/*QUAKED trigger_multiple_bcs_us_landmark_luggagecart (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_landmark_luggagecart", "lm_lugcrt_long" );



// ------------------------
// -- OLDSTYLE GENERICS --
// - we've got the assets, let's put them to work
// ------------------------
/*QUAKED trigger_multiple_bcs_us_building_door (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_door", "callout_loc_door_report" );

/*QUAKED trigger_multiple_bcs_taskforce_building_door (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_door", "callout_loc_door_report" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_door (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_door", "callout_loc_door_report" );



/*QUAKED trigger_multiple_bcs_us_building_1stfloor (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_1stfloor", "callout_loc_1st_report" );
	
/*QUAKED trigger_multiple_bcs_taskforce_building_1stfloor (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_1stfloor", "callout_loc_1st_report" );
	
/*QUAKED trigger_multiple_bcs_tfstealth_building_1stfloor (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_1stfloor", "callout_loc_1st_report" );



/*QUAKED trigger_multiple_bcs_us_building_1stfloor_door_leftside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_1stfloor_door_leftside", "callout_loc_door_1st_left_report" );
	
/*QUAKED trigger_multiple_bcs_taskforce_building_1stfloor_door_leftside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_1stfloor_door_leftside", "callout_loc_door_1st_left_report" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_1stfloor_door_leftside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_1stfloor_door_leftside", "callout_loc_door_1st_left_report" );



/*QUAKED trigger_multiple_bcs_us_building_1stfloor_door_rightside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_1stfloor_door_rightside", "callout_loc_door_1st_right_report" );

/*QUAKED trigger_multiple_bcs_taskforce_building_1stfloor_door_rightside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_1stfloor_door_rightside", "callout_loc_door_1st_right_report" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_1stfloor_door_rightside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_1stfloor_door_rightside", "callout_loc_door_1st_right_report" );



/*QUAKED trigger_multiple_bcs_us_building_1stfloor_window_leftside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_1stfloor_window_leftside", "callout_loc_wndw_1st_left_report" );

/*QUAKED trigger_multiple_bcs_taskforce_building_1stfloor_window_leftside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_1stfloor_window_leftside", "callout_loc_wndw_1st_left_report" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_1stfloor_window_leftside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_1stfloor_window_leftside", "callout_loc_wndw_1st_left_report" );



/*QUAKED trigger_multiple_bcs_us_building_1stfloor_window_rightside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_1stfloor_window_rightside", "callout_loc_wndw_1st_right_report" );

/*QUAKED trigger_multiple_bcs_taskforce_building_1stfloor_window_rightside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_1stfloor_window_rightside", "callout_loc_wndw_1st_right_report" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_1stfloor_window_rightside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_1stfloor_window_rightside", "callout_loc_wndw_1st_right_report" );



/*QUAKED trigger_multiple_bcs_us_building_2ndfloor (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_2ndfloor", "callout_loc_2nd_report" );

/*QUAKED trigger_multiple_bcs_taskforce_building_2ndfloor (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_2ndfloor", "callout_loc_2nd_report" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_2ndfloor (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2ndfloor", "callout_loc_2nd_report" );



/*QUAKED trigger_multiple_bcs_us_building_2ndfloor_door (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_2ndfloor_door", "callout_loc_door_2nd_report" );

/*QUAKED trigger_multiple_bcs_taskforce_building_2ndfloor_door (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_2ndfloor_door", "callout_loc_door_2nd_report" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_2ndfloor_door (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2ndfloor_door", "callout_loc_door_2nd_report" );



/*QUAKED trigger_multiple_bcs_us_building_2ndfloor_window (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_2ndfloor_window", "callout_loc_wndw_2nd_report" );

/*QUAKED trigger_multiple_bcs_taskforce_building_2ndfloor_window (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_2ndfloor_window", "callout_loc_wndw_2nd_report" );

/*QUAKED trigger_multiple_bcs_tfstealth_building_2ndfloor_window (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2ndfloor_window", "callout_loc_wndw_2nd_report" );


	
/*QUAKED trigger_multiple_bcs_us_building_2ndfloor_window_leftside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_2ndfloor_window_leftside", "callout_loc_wndw_2nd_left_report" );

/*QUAKED trigger_multiple_bcs_taskforce_building_2ndfloor_window_leftside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_2ndfloor_window_leftside", "callout_loc_wndw_2nd_left_report" );
	
/*QUAKED trigger_multiple_bcs_tfstealth_building_2ndfloor_window_leftside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2ndfloor_window_leftside", "callout_loc_wndw_2nd_left_report" );



/*QUAKED trigger_multiple_bcs_us_building_2ndfloor_window_rightside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_us_building_2ndfloor_window_rightside", "callout_loc_wndw_2nd_right_report" );

/*QUAKED trigger_multiple_bcs_taskforce_building_2ndfloor_window_rightside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_taskforce_building_2ndfloor_window_rightside", "callout_loc_wndw_2nd_right_report" );
	
/*QUAKED trigger_multiple_bcs_tfstealth_building_2ndfloor_window_rightside (0 0.25 0.5) ?
defaulttexture="bcs"
*/
	add_bcs_location_mapping( "trigger_multiple_bcs_tfstealth_building_2ndfloor_window_rightside", "callout_loc_wndw_2nd_right_report" );

}
