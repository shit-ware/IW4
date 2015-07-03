#include common_scripts\utility;
#include maps\_utility;

initCredits( type )
{
	flag_init( "atvi_credits_go" );
	level.linesize = 1.35;
	level.headingsize = 1.75;
	level.linelist = [];
	level.credits_speed = 22.5;
	level.credits_spacing = -120;
	
	set_console_status();
	if( !isdefined( type ) )
		type = "all";
	switch( type )
	{
		case "iw":
			initIWCredits();
			break;
		case "atvi":
			initActivisionCredits();
			break;
		case "all":
			initIWCredits();
			initActivisionCredits();
			break;
	}
}

initIWCredits()
{
	precachestring( &"CREDIT_DEVELOPED_BY" );
	
	initIWCredits_part1();
	initIWCredits_part2();
	initIWCredits_qa();
	initIWCredits_voice();
	initIWCredits_music();
	initIWCredits_music2();
	initIWCredits_spav();
	initIWCredits_add();
	initIWCredits_baby();
}

initIWCredits_part1()
{
	addImageIW( "logo_infinityward", 256, 128, 4.375 );
	addspace();
	
	
// Project Lead
	// JASON WEST
	addTitleNameIW( &"CREDIT_DIRECTED_BY", &"CREDIT_JASON_WEST" );
	addGap();
	
	
// Engineering Leads
	// RICHARD BAKER	
	addTitleNameIW( &"CREDIT_ENGINEERING_LEADS", &"CREDIT_RICHARD_BAKER" );
	// ROBERT FIELD
	addNameIW( &"CREDIT_ROBERT_FIELD" );
	// FRANCESCO GIGLIOTTI
	addNameIW( &"CREDIT_FRANCESCO_GIGLIOTTI" );
	// EARL HAMMON, JR
	addNameIW( &"CREDIT_EARL_HAMMON_JR" );
	addSpaceTitle();
	
// Engineering
	// CHAD BARB
	addTitleNameIW( &"CREDIT_ENGINEERING", &"CREDIT_CHAD_BARB" );
	// ALESSANDRO BARTOLUCCI
	addNameIW( &"CREDIT_ALESSANDRO_BARTOLUCCI" );
	// Simon Cournoyer
	addNameIW( &"CREDIT_Simon_Cournoyer" );
	// JON DAVIS
	addNameIW( &"CREDIT_JON_DAVIS" );
	// JOEL GOMPERT
	addNameIW( &"CREDIT_JOEL_GOMPERT" );
	// JOHN HAGGERTY
	addNameIW( &"CREDIT_JOHN_HAGGERTY" );
	// Chris Lambert
	addNameIW( &"CREDIT_Chris_Lambert" );
	// JON SHIRING
	addNameIW( &"CREDIT_JON_SHIRING" );
	// JIESANG SONG
	addNameIW( &"CREDIT_JIESANG_SONG" );
	// RAYME C VINSON
	addNameIW( &"CREDIT_RAYME_C_VINSON" );
	// ANDREW WANG
	addNameIW( &"CREDIT_ANDREW_WANG" );
	addGap();
	
	
// Design Leads
	// TODD ALDERMAN
	addTitleNameIW( &"CREDIT_DESIGN_LEADS", &"CREDIT_TODD_ALDERMAN" );
	// STEVE FUKUDA
	addNameIW( &"CREDIT_STEVE_FUKUDA" );
	// MACKEY MCCANDLISH
	addNameIW( &"CREDIT_MACKEY_MCCANDLISH" );
	// ZIED RIEKE
	addNameIW( &"CREDIT_ZIED_RIEKE" );
	addSpaceTitle();
	
// Design and Scripting
	// ROGER ABRAHAMSSON
	addTitleNameIW( &"CREDIT_DESIGN_AND_SCRIPTING", &"CREDIT_ROGER_ABRAHAMSSON" );
	// MOHAMMAD ALAVI
	addNameIW( &"CREDIT_MOHAMMAD_ALAVI" );
	// KEITH BELL
	addNameIW( &"CREDIT_KEITH_NED_BELL" );
	// Mike Denny
	addNameIW( &"CREDIT_Mike_Denny" );
	//Christopher Dionne
	addNameIW( &"CREDIT_Christopher_Dionne" );
	// PRESTON GLENN
	addNameIW( &"CREDIT_PRESTON_GLENN" );
	// CHAD GRENIER
	addNameIW( &"CREDIT_CHAD_GRENIER" );
	//Jordan Hirsh
	addNameIW( &"CREDIT_Jordan_Hirsh" );
	// JAKE KEATING
	addNameIW( &"CREDIT_JAKE_KEATING" );
	// JULIAN LUO
	addNameIW( &"CREDIT_JULIAN_LUO" );
	//Jason McCord
	addNameIW( &"CREDIT_Jason_McCord" );
	// BRENT MCLEOD
	addNameIW( &"CREDIT_BRENT_MCLEOD" );
	// JON PORTER
	addNameIW( &"CREDIT_JON_PORTER" );
	// ALEXANDER ROYCEWICZ
	addNameIW( &"CREDIT_ALEXANDER_ROYCEWICZ" );
	//Paul Sandler
	addNameIW( &"CREDIT_Paul_Sandler" );
	// NATHAN SILVERS
	addNameIW( &"CREDIT_NATHAN_SILVERS" );
	//Sean Slayback
	addNameIW( &"CREDIT_Sean_Slayback" );
	// GEOFFREY SMITH
	addNameIW( &"CREDIT_GEOFFREY_SMITH" );
	//Charlie Wiederhold
	addNameIW( &"CREDIT_Charlie_Wiederhold" );
	addGap();
	
	
// Art Director
	// RICHARD KRIEGLER	
	addTitleNameIW( &"CREDIT_ART_DIRECTOR", &"CREDIT_RICHARD_KRIEGLER" );
	addSpaceTitle();
	
// MICHAEL BOON
	// Technical Art Director
	addTitleNameIW( &"CREDIT_TECHNICAL_ART_DIRECT", &"CREDIT_MICHAEL_A_BOON" );
	addSpaceTitle();
	
// Art Leads
	// CHRIStopher CHERUBINI
	addTitleNameIW( &"CREDIT_ART_LEADS", &"CREDIT_CHRISTOPHER_CHERUBIN" );	
	// JOEL EMSLIE
	addNameIW( &"CREDIT_JOEL_EMSLIE" );
	// ROBERT GAINES
	addNameIW( &"CREDIT_ROBERT_GAINES" );
	addSpaceTitle();

// Art
	// BRAD ALLEN
	addTitleNameIW( &"CREDIT_ART", &"CREDIT_BRAD_ALLEN" );
	// PETER CHEN
	addNameIW( &"CREDIT_PETER_CHEN" );
	// William Cho
	addNameIW( &"CREDIT_William_Cho" );
	// Derric Eady
	addNameIW( &"CREDIT_Derric_Eady" );
	// Steven Giesler
	addNameIW( &"CREDIT_Steven_Giesler" );
	// JEFF HEATH
	addNameIW( &"CREDIT_JEFF_HEATH" );
	// David Johnson
	addNameIW( &"CREDIT_David_Johnson" );
	// RYAN LASTIMOSA
	addNameIW( &"CREDIT_RYAN_M_LASTIMOSA" );
	// OSCAR LOPEZ
	addNameIW( &"CREDIT_OSCAR_LOPEZ" );
	// Tim McGrath
	addNameIW( &"CREDIT_Tim_McGrath" );
	// TAEHOON OH
	addNameIW( &"CREDIT_TAEHOON_OH" );
	// SAMI ONUR
	addNameIW( &"CREDIT_SAMI_ONUR" );
	// VELINDA PELAYO
	addNameIW( &"CREDIT_VELINDA_PELAYO" );
	// Serozh Sarkisyan
	addNameIW( &"CREDIT_Serozh_Sarkisyan" );
	// RICHARD SMITH
	addNameIW( &"CREDIT_RICHARD_N_SMITH" );
	// THEERAPOL SRISUPHAN
	addNameIW( &"CREDIT_THEERAPOL_SRISUPHAN" );
	// TODD SUE
	addNameIW( &"CREDIT_TODD_SUE" );
	addGap();
	
	
// Animation Leads
	// MARK GRIGSBY
	addTitleNameIW( &"CREDIT_ANIMATION_LEADS", &"CREDIT_MARK_GRIGSBY" );	
	// PAUL MESSERLY
	addNameIW( &"CREDIT_PAUL_MESSERLY" );
	addSpaceTitle();

// Animation
	//Bruce Ferriz
	addTitleNameIW( &"CREDIT_ANIMATION", &"CREDIT_Bruce_Ferriz" );
	// CHANCE GLASCO
	addNameIW( &"CREDIT_CHANCE_GLASCO" );
	// ZACH VOLKER
	addNameIW( &"CREDIT_ZACH_VOLKER" );
	// LEI YANG
	addNameIW( &"CREDIT_LEI_YANG" );	
	addSpaceTitle();

//Motion Capture Integration
	//MARIO PEREZ
	addTitleNameIW( &"CREDIT_MOTION_CAPTURE_INTEG", &"CREDIT_MARIO_PEREZ" );
	addSpaceTitle();

// Technical Animation Lead
	// ERIC PIERCE
	addTitleNameIW( &"CREDIT_TECHNICAL_ANIMATION_LEAD", &"CREDIT_ERIC_PIERCE" );
	addSpaceTitle();
	
// Technical Animation
	// NEEL KAR
	addTitleNameIW( &"CREDIT_TECHNICAL_ANIMATION", &"CREDIT_NEEL_KAR" );
	// CHENG LOR
	addNameIW( &"CREDIT_CHENG_LOR" );		
	addGap();
	
	
// Audio Lead
	// MARK GANUS
	addTitleNameIW( &"CREDIT_AUDIO_LEAD", &"CREDIT_MARK_GANUS" );
	addSpaceTitle();

// Audio
	// CHRISSY ARYA
	addTitleNameIW( &"CREDIT_AUDIO", &"CREDIT_CHRISSY_ARYA" );
	// STEPHEN MILLER
	addNameIW( &"CREDIT_STEPHEN_MILLER" );
	addGap();
}

initIWCredits_part2()
{	
	
// Written by
	// JESSE STERN
	addTitleNameIW( &"CREDIT_WRITTEN_BY", &"CREDIT_JESSE_STERN" );
	addSpaceTitle();
	
// Additional Writing	
	// STEVE FUKUDA
	addTitleNameIW( &"CREDIT_ADDITIONAL_WRITING", &"CREDIT_STEVE_FUKUDA" );
	addSpaceTitle();
	
// Story by
	// TODD ALDERMAN
	addTitleNameIW( &"CREDIT_STORY_BY", &"CREDIT_TODD_ALDERMAN" );
	// STEVE FUKUDA
	addNameIW( &"CREDIT_STEVE_FUKUDA" );
	// MACKEY MCCANDLISH
	addNameIW( &"CREDIT_MACKEY_MCCANDLISH" );
	// ZIED RIEKE
	addNameIW( &"CREDIT_ZIED_RIEKE" );
	// JESSE STERN
	addNameIW( &"CREDIT_JESSE_STERN" );
	// JASON WEST
	addNameIW( &"CREDIT_JASON_WEST" );
	addSpaceTitle();
	
// Writer's Assistant
	// Aaron Tracy
	addTitleNameIW( &"CREDIT_WRITERS_ASSISTANT", &"CREDIT_Aaron_Tracy" );	
	addGap();	
	
	
// CEO / CFO
	//VINCE ZAMPELLA
	addTitleNameIW( &"CREDIT_CEO_CFO", &"CREDIT_VINCE_ZAMPELLA" );
	addSpaceTitle();
			
// Producer
	// MARK RUBIN
	addTitleNameIW( &"CREDIT_PRODUCER", &"CREDIT_MARK_A_RUBIN" );
	addSpaceTitle();
	
// Associate Producers
	// PETE BLUMEL
	addTitleNameIW( &"CREDIT_ASSOCIATE_PRODUCERS", &"CREDIT_PETE_BLUMEL" );
	// John Wasilczyk
	addNameIW( &"CREDIT_John_Wasilczyk" );
	addSpaceTitle();
			
// Office Manager
	// JANICE TURNER
	addTitleNameIW( &"CREDIT_OFFICE_MANAGER", &"CREDIT_JANICE_LOHR_TURNER" );
	addSpaceTitle();
	
// Human Resources Generalist
	// KRISTIN COTTERELL
	addTitleNameIW( &"CREDIT_HUMAN_RESOURCES_GENE", &"CREDIT_KRISTIN_COTTERELL" );
	addSpaceTitle();

// Executive Assistant
	// Carly Gillis
	addTitleNameIW( &"CREDIT_EXECUTIVE_ASSISTANT", &"CREDIT_CARLY_GILLIS" );
	addNameIW( &"CREDIT_CATHIE_ICHIGE" );	
	addSpaceTitle();
	
// Administrative Assistant
	// Lisa Stone
	addTitleNameIW( &"CREDIT_RECEPTION", &"CREDIT_Lisa_Stone" );
	addSpaceTitle();

// Community Relations Manager
	// ROBERT BOWLING
	addTitleNameIW( &"CREDIT_CREATIVE_STRATEGIST", &"CREDIT_ROBERT_BOWLING" );
	addSpaceTitle();
	
// PR Director, Owned Properties
	// MIKE MANTARRO
	addTitleNameIW( &"CREDIT_PR_DIRECTOR", &"CREDIT_MIKE_MANTARRO" );
	addSpaceTitle();
	
// DIRECTOR OF MARKETING
	// BYRON BEEDE
	addTitleNameIW( &"CREDIT_DIRECTOR_OF_MARKETIN_ATVI", &"CREDIT_BYRON_BEEDE");	
	addSpaceTitle();
	
//PRESIDENT / CCO	
	// JASON WEST  
	addTitleNameIW( &"CREDIT_PRESIDENT_CCO", &"CREDIT_JASON_WEST" );	
	addGap();	
	
// IT Manager
	// BRYAN KUHN
	addTitleNameIW( &"CREDIT_IT_MANAGER", &"CREDIT_BRYAN_KUHN" );
	addSpaceTitle();
	
// System Administrator
	// DREW MCCOY
	addTitleNameIW( &"CREDIT_System_Administrator", &"CREDIT_DREW_MCCOY" );
	addSpaceTitle();
	
//Information Systems Analyst
	// Chris Lai
	addTitleNameIW( &"CREDIT_INFORMATION_SYSTEMS_", &"CREDIT_Chris_Lai" );
	addSpaceTitle();
	
//Unix Systems Architect
	// ROBERT A. DYE
	addTitleNameIW( &"CREDIT_UNIX_SYSTEMS_ARCHITE", &"CREDIT_ROBERT_A_DYE" );
	addGap();


//Concept Art
	addTitleNameIW( &"CREDIT_CONCEPT_ART", &"CREDIT_RICHARD_KRIEGLER" );
	addNameIW( &"CREDIT_BRAD_ALLEN" );
	addNameIW( &"CREDIT_JOEL_EMSLIE" );
	addNameIW( &"CREDIT_RICHARD_N_SMITH" );
	addNameIW( &"CREDIT_NEEL_KAR" );
	addGap();


//extra
	addTitleNameIW( &"CREDIT_BATTLECHATTER_DIALOGUE", &"CREDIT_Sean_Slayback" );
	addSpaceTitle();
	addTitleNameIW( &"CREDIT_ADDITIONAL_MENU_SCRIPT", &"CREDIT_JULIAN_LUO" );
	addNameIW( &"CREDIT_BRENT_MCLEOD" );
	addGap();
}

initIWCredits_qa()
{
	//	Quality Assurance Manager
	// Mike Seal
	addTitleNameIW( &"CREDIT_QUALITY_ASSURANCE_MA", &"CREDIT_Mike_Seal" );
	addSpaceTitle();

//	Quality Assurance Floor Leads
	// Ed Harmer
	addTitleNameIW( &"CREDIT_QUALITY_ASSURANCE_FL", &"CREDIT_Ed_Harmer" );
	// Justin Harris
	addNameIW( &"CREDIT_Justin_Harris" );
	addSpaceTitle();

//	Quality Assurance
	// Mary Benitez
	addTitleNameIW( &"CREDIT_QUALITY_ASSURANCE", &"CREDIT_Mary_Benitez" );	
	// Chelsy Berry
	addNameIW( &"CREDIT_Chelsy_Berry" );	
	// Candice Capen
	addNameIW( &"CREDIT_Candice_Capen" );	
	// Terran Casey
	addNameIW( &"CREDIT_Terran_Casey" );	
	// Michael Penrod
	addNameIW( &"CREDIT_Michael_Penrod" );	
	// Anthony Rubin
	addNameIW( &"CREDIT_Anthony_Rubin" );	
	// Georgeina Schaller
	addNameIW( &"CREDIT_Georgeina_Schaller" );	
	// Chris Shepherd
	addNameIW( &"CREDIT_Chris_Shepherd" );	
	// John Theodore
	addNameIW( &"CREDIT_John_Theodore" );	
	// Daniel Wapner
	addNameIW( &"CREDIT_Daniel_Wapner" );	
	addGap();
}

initIWCredits_music()
{
// Main Themes By
	addTitleNameIW( &"CREDIT_MAIN_THEMES_BY", &"CREDIT_HANS_ZIMMER" );
	addSpaceTitle();	
	
// Music Produced by
	addTitleNameIW( &"CREDIT_MUSIC_PRODUCED_BY", &"CREDIT_HANS_ZIMMER" );	
	addNameIW( &"CREDIT_LORNE_BALFE" );
	addSpaceTitle();
		
// Music Composed By
	addTitleNameIW( &"CREDIT_MUSIC_COMPOSED_BY", &"CREDIT_LORNE_BALFE" );	
	addSpaceTitle();

// Additional Music 
	addTitleNameIW( &"CREDIT_ADDITIONAL_MUSIC_", &"CREDIT_MARK_MANCINA" );	
	addNameIW( &"CREDIT_NICK_PHOENIX" );
	addNameIW( &"CREDIT_THOMAS_BERGERSEN" );
	addNameIW( &"CREDIT_DAVE_METZGER" );	
	addNameIW( &"CREDIT_JACOB_SHEA" );	
	addNameIW( &"CREDIT_NOAH_SOROTA" );	
	addNameIW( &"CREDIT_ATLI_ORVARSSON" );	
	addSpaceTitle();
	
// Additional Arranging and Programming
	addTitleNameIW( &"CREDIT_ADDITIONAL_ARRANGING", &"CREDIT_BART_HENDRICKSON" );	
	addNameIW( &"CREDIT_CLAY_DUNCAN" );	
	addNameIW( &"CREDIT_RYELAND_ALLISON" );	
	addNameIW( &"CREDIT_ANDREW_KAWCZYNSKI" );	
	addNameIW( &"CREDIT_TOM_BRODERICK" );	
	addSpaceTitle();

// Music Editor
	addTitleNameIW( &"CREDIT_MUSIC_EDITOR", &"CREDIT_DAN_PINDER" );	
	addSpaceTitle();	

// Music Production Services 
	addTitleNameIW( &"CREDIT_MUSIC_PRODUCTION_SER", &"CREDIT_STEVEN_KOFSKY" );	
	addSpaceTitle();	

//Music Supervisor                           
	addTitleNameIW( &"CREDIT_MUSIC_SUPERVISOR", &"CREDIT_TOM_BRODERICK" );	
	addSpaceTitle();	

//Score Wrangler                               
	addTitleNameIW( &"CREDIT_SCORE_WRANGLER", &"CREDIT_BOB_BADAMI_2" );	
	addSpaceTitle();	
	
// Soloists - Guitar 
	addTitleNameIW( &"CREDIT_SOLOISTS_GUITAR", &"CREDIT_TOM_BRODERICK" );
	addSpaceTitle();

// Percussion
	addTitleNameIW( &"CREDIT_PERCUSSION", &"CREDIT_SATNAM_RAMGOTRA" );
	addNameIW( &"CREDIT_RYELAND_ALLISON" );
	addSpaceTitle();

// Violin          
	addTitleNameIW( &"CREDIT_VIOLIN", &"CREDIT_NOAH_SOROTA" );
	addSpaceTitle();

// Music Mixed by
	addTitleNameIW( &"CREDIT_MUSIC_MIXED_BY", &"CREDIT_ALAN_MEYERSON" );	
	addSpaceTitle();
	
// Additional Engineering
	addTitleNameIW( &"CREDIT_ADDITIONAL_ENGINEERI", &"CREDIT_KATIA_LEWIN_PALOMO" );
	addNameIW( &"CREDIT_SLAMM_ANDREWS" );
	addNameIW( &"CREDIT_JEFF_BIGGERS" );	
	addSpaceTitle();
	
// Assistant Engineer
	addTitleNameIW( &"CREDIT_ASSISTANT_ENGINEER", &"CREDIT_ADAM_SCHMIDT" );	
	addSpaceTitle();

// Production Coordinator for Hans Zimmer	
	addTitleNameIW( &"CREDIT_PROD_CORD_HANS_ZIMMER", &"CREDIT_ANDREW_ZACK" );	
	addGap();
		
//Music Mixed at REMOTE CONTROL PRODUCTIONS, INC             
	addTitleIW( &"CREDIT_MUSIC_MIXED_ATREMOT" );	
	addGap();
}

initIWCredits_voice()
{
	// Voice Talent
	
	addTitleIW( &"CREDIT_CAST_CAST" );
	addSpaceSmall();
	addcastIW( &"CREDIT_Lance_Henriksen", 	&"CREDIT_CAST_GENERAL_SHEPHERD", 	&"CREDIT_CAST_Lance_Henriksen" );
	addcastIW( &"CREDIT_Keith_David", 		&"CREDIT_CAST_SERGEANT_FOLEY",		&"CREDIT_CAST_Keith_David" );
	addcastIW( &"CREDIT_Barry_Pepper", 		&"CREDIT_CAST_CORPORAL_DUNN",		&"CREDIT_CAST_Barry_Pepper" );
	//addcastIW( &"CREDIT_Glen_Morshower", 	&"CREDIT_CAST_OVERLORD",			&"CREDIT_CAST_GLENN_MORSHOWER" );
	addcastIW( &"CREDIT_Kevin_McKidd", 		&"CREDIT_CAST_SOAP_MACTAVISH", 		&"CREDIT_CAST_Kevin_McKidd" );
	addcastIW( &"CREDIT_Roman_Varshavsky", 	&"CREDIT_CAST_MAKAROV",				&"CREDIT_CAST_Roman_Varshavsky" );
	addcastIW( &"CREDIT_CRAIG_FAIRBRASS", 	&"CREDIT_CAST_GHOST",				&"CREDIT_CAST_CRAIG_FAIRBRASS" );
	addcastIW( &"CREDIT_Sven_Holmberg",		&"CREDIT_CAST_NIKOLAI",				&"CREDIT_CAST_Sven_Holmberg" );	
	addcastIW( &"CREDIT_BILLY_MURRAY", 		&"CREDIT_CAST_CAPTAIN_PRICE", 		&"CREDIT_CAST_BILLY_MURRAY" );
	
	addSpace();
	
	addTitleNameIW( &"CREDIT_ADDITIONAL_VOICE_TALENT", &"CREDIT_Gabrielle_Al_Rajhi" );	
	addNameIW( &"CREDIT_Eugene_Alpers" );
	addNameIW( &"CREDIT_Will_Arnett" );
	addNameIW( &"CREDIT_Troy_Baker" );
	addNameIW( &"CREDIT_Brian_Bloom" );
	addNameIW( &"CREDIT_Alex_Bronquette" );
	addNameIW( &"CREDIT_Coy_Clark" );
	addNameIW( &"CREDIT_Michael_Cudlitz" );
	addNameIW( &"CREDIT_Enayat_Delawary" );
	addNameIW( &"CREDIT_Josh_Gilman" );
	addNameIW( &"CREDIT_Daniel_Gamburg" );
	addNameIW( &"CREDIT_Anna_Graves" );
	addNameIW( &"CREDIT_Mark_Grigsby" );
	addNameIW( &"CREDIT_Curtis_Jackson" );
	addNameIW( &"CREDIT_Boris_Kievsky" );
	addNameIW( &"CREDIT_Kristof_Konrad" );
	addNameIW( &"CREDIT_Mauricio_Lange" );
	addNameIW( &"CREDIT_Eugene_Lazareb" );
	addNameIW( &"CREDIT_Matt_Lindquist" );
	addNameIW( &"CREDIT_David_Lodge" );
	addNameIW( &"CREDIT_Graham_McTavish" );
	addNameIW( &"CREDIT_Dave_Mallow" );
	addNameIW( &"CREDIT_Jordan_Marder" );
	addNameIW( &"CREDIT_Matt_Mercer" );
	addNameIW( &"CREDIT_Glen_Morshower" );
	addNameIW( &"CREDIT_Sam_Sako" );
	addNameIW( &"CREDIT_Randy_Stonitsch" );
	addNameIW( &"CREDIT_Fred_Tatasciore" );
	addNameIW( &"CREDIT_Justin_Theroux" );
	addNameIW( &"CREDIT_Kirk_Thornton" );
	addNameIW( &"CREDIT_Fred_Toma" );
	addNameIW( &"CREDIT_Alex_Veadov" );
	addNameIW( &"CREDIT_Jim_Ward" );
	addNameIW( &"CREDIT_Kai_Wulf" );
	addGap();	
}

initIWCredits_spav()
{
// Cinematic movies provided by:
	addTitleIW( &"CREDIT_CINEMATIC_MOVIES_PRO" );	
	addSpaceSmall();
	
	// Spov (Design and Moving Image)
		addSubTitleNameIW( &"CREDIT_SPOVTV", &"CREDIT_Allen_Leitch" );
		addSubNameIW( &"CREDIT_Yugen_Blake" );
		addSubNameIW( &"CREDIT_Miles_Christensen" );
		addSubNameIW( &"CREDIT_Paul_Hunt" );
		addSubNameIW( &"CREDIT_David_Hicks" );
		addSubNameIW( &"CREDIT_Julio_Dean" );
		addSubNameIW( &"CREDIT_Gemma_Thompson" );
		addSubNameIW( &"CREDIT_Rhiwallon_Leadbeater" );
		addSubNameIW( &"CREDIT_Rob_Millington" );
		addSubNameIW( &"CREDIT_Steve_Townrow" );
		addSubNameIW( &"CREDIT_Vincent_Kane" );
		addSpaceTitle();
		
	//Spov Production Babies:
		addSubTitleNameIW( &"CREDIT_SPOV_PROD_BABIES", &"CREDIT_JACOB_HARTLEY_BLAKE" );
		addSubNameIW( &"CREDIT_BEATRICE_VB_L" );
		addSubNameIW( &"CREDIT_ELSPETH_MA_L" );
		addGap();
	
	
// additional art provided by	
	addTitleIW( &"CREDIT_TITLE_SEQUENCE" );	
	addSpaceSmall();
	
	// THE ANT FARM
	addsubTitleIW( &"CREDIT_THE_ANT_FARM" );
	addSpaceTitle();
		
		addSubTitleNameIW( &"CREDIT_PRODUCER", &"CREDIT_SCOTT_CARSON" );
		addSpaceTitle();
		
		addSubTitleNameIW( &"CREDIT_EXECUTIVE_CREATIVE_DIRECTOR", &"CREDIT_ROB_TROY" );
		addSpaceTitle();
		
		addSubTitleNameIW( &"CREDIT_ANT_FARM_PROD_BABIES", &"CREDIT_MARLEY_TROY" );
		addGap();	
}

initIWCredits_music2()
{
	if( getdvar( "ui_char_museum_mode" ) != "credits_black" )
	{	
		addTitleIW( &"CREDIT_CRIME_WAVE" );	
		addNameIW( &"CREDIT_CRIME_WAVE_LINE1" );
		addNameIW( &"CREDIT_CRIME_WAVE_LINE2" );
		addNameIW( &"CREDIT_CRIME_WAVE_LINE3" );
		addNameIW( &"CREDIT_CRIME_WAVE_LINE4" );
		addNameIW( &"CREDIT_CRIME_WAVE_LINE5" );
		addNameIW( &"CREDIT_CRIME_WAVE_LINE6" );
		addNameIW( &"CREDIT_CRIME_WAVE_LINE7" );
		addNameIW( &"CREDIT_CRIME_WAVE_LINE8" );
		addSpace();
		
		addTitleIW( &"CREDIT_SURVIVAL_SKILLS" );	
		addNameIW( &"CREDIT_SURVIVAL_SKILLS_LINE0" );
		addNameIW( &"CREDIT_SURVIVAL_SKILLS_LINE1" );
		addNameIW( &"CREDIT_SURVIVAL_SKILLS_LINE2" );
		addNameIW( &"CREDIT_SURVIVAL_SKILLS_LINE3" );
		addNameIW( &"CREDIT_SURVIVAL_SKILLS_LINE4" );
		addSpace();
		
		addTitleIW( &"CREDIT_DANGER" );	
		addNameIW( &"CREDIT_DANGER_LINE1" );
		addNameIW( &"CREDIT_DANGER_LINE2" );
		addNameIW( &"CREDIT_DANGER_LINE3" );
		addNameIW( &"CREDIT_DANGER_LINE4" );
		addSpace();
		
		addTitleIW( &"CREDIT_NEW_NEW" );	
		addNameIW( &"CREDIT_NEW_NEW_LINE1" );
		addNameIW( &"CREDIT_NEW_NEW_LINE2" );
		addNameIW( &"CREDIT_NEW_NEW_LINE3" );
		addNameIW( &"CREDIT_NEW_NEW_LINE4" );		
		addGap();
	}
	else
	{
		addCenterHeading( &"CREDIT_CRIME_WAVE" );	
		addSpaceSmall();
		addCenterHeading( &"CREDIT_CRIME_WAVE_LINE1" );
		addCenterHeading( &"CREDIT_CRIME_WAVE_LINE2" );
		addCenterHeading( &"CREDIT_CRIME_WAVE_LINE3" );
		addCenterHeading( &"CREDIT_CRIME_WAVE_LINE4" );
		addCenterHeading( &"CREDIT_CRIME_WAVE_LINE5" );
		addCenterHeading( &"CREDIT_CRIME_WAVE_LINE6" );
		addCenterHeading( &"CREDIT_CRIME_WAVE_LINE7" );
		addCenterHeading( &"CREDIT_CRIME_WAVE_LINE8" );
		addSpace();
		
		addCenterHeading( &"CREDIT_SURVIVAL_SKILLS" );	
		addSpaceSmall();
		addCenterHeading( &"CREDIT_SURVIVAL_SKILLS_LINE0" );
		addCenterHeading( &"CREDIT_SURVIVAL_SKILLS_LINE1" );
		addCenterHeading( &"CREDIT_SURVIVAL_SKILLS_LINE2" );
		addCenterHeading( &"CREDIT_SURVIVAL_SKILLS_LINE3" );
		addCenterHeading( &"CREDIT_SURVIVAL_SKILLS_LINE4" );
		addSpace();
		
		addCenterHeading( &"CREDIT_DANGER" );	
		addSpaceSmall();
		addCenterHeading( &"CREDIT_DANGER_LINE1" );
		addCenterHeading( &"CREDIT_DANGER_LINE2" );
		addCenterHeading( &"CREDIT_DANGER_LINE3" );
		addCenterHeading( &"CREDIT_DANGER_LINE4" );
		addSpace();
		
		addCenterHeading( &"CREDIT_NEW_NEW" );	
		addSpaceSmall();
		addCenterHeading( &"CREDIT_NEW_NEW_LINE1" );
		addCenterHeading( &"CREDIT_NEW_NEW_LINE2" );
		addCenterHeading( &"CREDIT_NEW_NEW_LINE3" );
		addCenterHeading( &"CREDIT_NEW_NEW_LINE4" );		
		addGap();
	}
}

initIWCredits_add()
{
//	Additional Sound Design, audio implementation and cinematic sound production provided by:
	addTitleIW( &"CREDIT_ADDITIONAL_SOUND_DES1" );
	if( getdvar( "ui_char_museum_mode" ) != "credits_black" )
		addTitleIW( &"CREDIT_ADDITIONAL_SOUND_DES3" );
	else
		addTitleIW( &"CREDIT_ADDITIONAL_SOUND_DES2" );
	addSpaceSmall();
	addSubTitleIW( &"CREDIT_EARBASH_AUDIO_INC" );
	addGap();
		
//Additional Voice Editing/Integration
	addTitleNameIW( &"CREDIT_ADDITIONAL_VOICE_EDI", &"CREDIT_JEREMY_SIMPSON" );
	addNameIW( &"CREDIT_Nakia_Harris" );
	addSpaceTitle();
	
// Additional Art provided by:
	addTitleNameIW( &"CREDIT_ADDITIONAL_ART", &"CREDIT_SHADOWS_IN_DARKNESS" );
	addNameIW( &"CREDIT_VYKARIAN" );
	addGap();


// Voice Recording Facilities in Los Angeles provided by
	addTitleIW( &"CREDIT_VOICE_RECORDING_FACI" );
	addSpaceSmall();

	addSubTitleIW( &"CREDIT_PCB_PRODUCTIONS_ENC" );	
	addSubTitleIW( &"CREDIT_SIDE_UK_LONDON_UK" );
	addSpaceTitle();	

	// Voice Direction/Dialog Engineering
	addSubTitleNameIW( &"CREDIT_VOICE_DIRECTION_DIAL", &"CREDIT_KEITH_AREM" );
	addSpaceTitle();

	// Additional Voice Direction
	addSubTitleNameIW( &"CREDIT_ADDITIONAL_VOICE_DIR", &"CREDIT_Steve_Fukuda" );
	//addSubNameIW( &"CREDIT_Mackey_McCandlish" );
	addGap();


// Sound Effects Recording
	addTitleNameIW( &"CREDIT_SOUND_EFFECTS_RECORD", &"CREDIT_JOHN_PAUL_FASAL" );
	addSpaceTitle();

// Video Editing
	addTitleNameIW( &"CREDIT_VIDEO_EDITING", &"CREDIT_Drew_McCoy" );
	addGap();
	

//Motion Capture provided by Neversoft Entertainment
	addTitleIW( &"CREDIT_MOTION_CAPTURE_PROVI" );
	addSpaceSmall();
	
	//Motion Capture Lead
	addSubTitleNameIW( &"CREDIT_MOTION_CAPTURE_LEAD", &"CREDIT_Kristina_Adelmeyer" );
	addSpaceTitle();
	
	// Motion Capture Technicians
	addSubTitleNameIW( &"CREDIT_MOTION_CAPTURE_TECHN", &"CREDIT_Anet_Hambarsumian" );
	addSubNameIW( &"CREDIT_Justin_Parish" );
	addSubNameIW( &"CREDIT_Sean_Watson" );
	addGap();
	
	
// Stunt Action designed by 87eleven Action Film Co.
	addTitleIW( &"CREDIT_STUNT_ACTION_DESIGNE" );
	addSpaceSmall();
	addTitleIW( &"CREDIT_WWW87ELEVENCOM" );
	addSpaceTitle();
	
	// Stunt Coordinator
	addSubTitleNameIW( &"CREDIT_STUNT_COORDINATOR", &"CREDIT_DANNY_HERNANDEZ" );
	addSpaceTitle();
	
	//Stunts/Motion Capture Actors
	addSubTitleNameIW( &"CREDIT_STUNTS_MOTION_CAPTUR", &"CREDIT_CLAYTON_BARBER" );
	addSubNameIW( &"CREDIT_Danny_Hernandez" );
	addSubNameIW( &"CREDIT_Allen_Jo" );
	addSubNameIW( &"CREDIT_Ralf_Koch" );
	addSubNameIW( &"CREDIT_Kenny_Richards" );
	addSubNameIW( &"CREDIT_Jackson_Spidell" );
	addSubNameIW( &"CREDIT_Jake_Swallow" );
	addSubNameIW( &"CREDIT_Don_Theerathada" );
	addSubNameIW( &"CREDIT_Justin_Williams" );
	addSubNameIW( &"CREDIT_Kofi_Yiadom" );
	addGap();
	
	
// Additional Design
	addTitleNameIW( &"CREDIT_ADDITIONAL_DESIGN", &"CREDIT_STEVE_MASSEY" );
	addSpaceTitle();

// Additional Art
	addTitleNameIW( &"CREDIT_ADDITIONAL_ART", &"CREDIT_JOE_SIMANELLO" );
	addGap();
	

// Military Technical Advisors
	// LT COL HANK KEIRSEY US ARMY (RET.)
	addTitleNameIW( &"CREDIT_MILITARY_TECHNICAL_A", &"CREDIT_LT_COL_HANK_KEIRSEY_" );
	// EMILIO CUESTA USMC
	addNameIW( &"CREDIT_EMILIO_CUESTA_USMC" );
	addGap();
	
	
// Weapons provided by
	addTitleNameIW( &"CREDIT_WEAPONS_PROVIDED_BY", &"CREDIT_INDEPENDENT_STUDIO_S" );
	addSpaceTitle();

// Armorer
	addTitleNameIW( &"CREDIT_ARMORER", &"CREDIT_LARRY_ZANOFF" );
	addGap();	
	
// Translations
	addTitleNameIW( &"CREDIT_TRANSLATIONS", &"CREDIT_GABRIELLE_AL_RAJHI" );
	addNameIW( &"CREDIT_ALEXANDRE_BRONQUETE" );
	addNameIW( &"CREDIT_ANTONINA_THOMPSON" );
	addNameIW( &"CREDIT_LEONELA_B_WAHRICK" );
	addGap();


// PREDATOR IS A U.S. REGISTERED TRADEMARK OF GENERAL ATOMICS AERONAUTICAL SYSTEMS, INC.
	addTitleIW( &"CREDIT_PREDATOR_IS_A_US_REG" );
	addTitleIW( &"CREDIT_PREDATOR_IS_A_US_REG2" );
	addSpace();

// SATELLITE IMAGERY PROVIDED BY GEOEYE. (WWW.GEOEYE.COM)"	
	addTitleIW( &"CREDIT_SATELLITE_IMAGERY_PR" );
	addTitleIW( &"CREDIT_SATELLITE_IMAGERY_PR2" );
	addgap();	
}

initIWCredits_baby()
{
// Production Babies
	addTitleIW( &"CREDIT_PRODUCTION_BABIES" );
	addSpaceSmall();
	addSubTitleIW( &"CREDIT_BABY_MARLEY_BLUMEL_A" );
	addSubTitleIW( &"CREDIT_BABY_HENRY_MICHAEL_B" );
	addSubTitleIW( &"CREDIT_BABY_CORALINE_BOWLIN" );
	addSubTitleIW( &"CREDIT_BABY_GREG_MCCOY_AND_" );
	addSubTitleIW( &"CREDIT_BABY_AUDREY_MCLEOD_A" );
	addSubTitleIW( &"CREDIT_BABY_SHANNON_SEOYEON" );
	addSubTitleIW( &"CREDIT_BABY_MARLEE_HENDRIX_" );
	addSubTitleIW( &"CREDIT_BABY_EMILY_JOYCE_POR" );
	addSubTitleIW( &"CREDIT_BABY_COOPER_RIEKE_AN" );
	addSubTitleIW( &"CREDIT_BABY_LUKE_SMITH_AND_" );
	addSubTitleIW( &"CREDIT_BABY_SONG_EJOOK_AND_" );
	addSubTitleIW( &"CREDIT_BABY_HUDSON_GEOFF_VO" );
	addGap();
	
//INFINITY WARD SPECIAL THANKS	
	addTitleIW( &"CREDIT_INFINITY_WARD_SPECIA" );
	addSpaceSmall();
	addSubTitleIW( &"CREDIT_LAWRENCE_GREEN" );
	addSubTitleIW( &"CREDIT_BENJAMIN_HECKENDORN" );
	addSubTitleIW( &"CREDIT_JOSHUA_LACROSS" );
	addSubTitleIW( &"CREDIT_NAVY_SEALS" );
	addGap();
}

addLeftTitle( title, textscale )
{
	precacheString( title );

	if ( !isdefined( textscale ) )
		textscale = level.linesize;

	temp = spawnstruct();
	temp.type = "lefttitle";
	temp.title = title;
	temp.textscale = textscale;

	level.linelist[ level.linelist.size ] = temp;
}

addLeftName( name, textscale )
{
	precacheString( name );

	if ( !isdefined( textscale ) )
		textscale = level.linesize;

	temp = spawnstruct();
	temp.type = "leftname";
	temp.name = name;
	temp.textscale = textscale;

	level.linelist[ level.linelist.size ] = temp;
}

addSubLeftTitle( title, textscale )
{
	addLeftName( title, textscale );
}

addSubLeftName( name, textscale )
{
	precacheString( name );

	if ( !isdefined( textscale ) )
		textscale = level.linesize;

	temp = spawnstruct();
	temp.type = "subleftname";
	temp.name = name;
	temp.textscale = textscale;

	level.linelist[ level.linelist.size ] = temp;
}

addRightTitle( title, textscale )
{
	precacheString( title );

	if ( !isdefined( textscale ) )
		textscale = level.linesize;

	temp = spawnstruct();
	temp.type = "righttitle";
	temp.title = title;
	temp.textscale = textscale;

	level.linelist[ level.linelist.size ] = temp;
}

addRightName( name, textscale )
{
	precacheString( name );

	if ( !isdefined( textscale ) )
		textscale = level.linesize;

	temp = spawnstruct();
	temp.type = "rightname";
	temp.name = name;
	temp.textscale = textscale;

	level.linelist[ level.linelist.size ] = temp;
}

addCenterHeading( heading, textscale )
{
	precacheString( heading );

	if ( !isdefined( textscale ) )
		textscale = level.linesize;

	temp = spawnstruct();
	temp.type = "centerheading";
	temp.heading = heading;
	temp.textscale = textscale;

	level.linelist[ level.linelist.size ] = temp;
}

addCastName( name, title, textscale )
{
	precacheString( title );
	precacheString( name );

	if ( !isdefined( textscale ) )
		textscale = level.linesize;

	temp = spawnstruct();
	temp.type = "castname";
	temp.title = title;
	temp.name = name;
	temp.textscale = textscale;

	level.linelist[ level.linelist.size ] = temp;
}

addCenterName( name, textscale )
{
	precacheString( name );

	if ( !isdefined( textscale ) )
		textscale = level.linesize;

	temp = spawnstruct();
	temp.type = "centername";
	temp.name = name;
	temp.textscale = textscale;

	level.linelist[ level.linelist.size ] = temp;
}

addCenterNameDouble( name1, name2, textscale )
{
	precacheString( name1 );
	precacheString( name2 );

	if ( !isdefined( textscale ) )
		textscale = level.linesize;

	temp = spawnstruct();
	temp.type = "centernamedouble";
	temp.name1 = name1;
	temp.name2 = name2;
	temp.textscale = textscale;

	level.linelist[ level.linelist.size ] = temp;
}

addCenterDual( title, name, textscale )
{
	precacheString( title );
	precacheString( name );

	if ( !isdefined( textscale ) )
		textscale = level.linesize;

	temp = spawnstruct();
	temp.type = "centerdual";
	temp.title = title;
	temp.name = name;
	temp.textscale = textscale;

	level.linelist[ level.linelist.size ] = temp;
}

addCenterTriple( name1, name2, name3, textscale )
{
	precacheString( name1 );
	precacheString( name2 );
	precacheString( name3 );

	if ( !isdefined( textscale ) )
		textscale = level.linesize;

	temp = spawnstruct();
	temp.type = "centertriple";
	temp.name1 = name1;
	temp.name2 = name2;
	temp.name3 = name3;
	temp.textscale = textscale;

	level.linelist[ level.linelist.size ] = temp;
}

addSpace()
{
	temp = spawnstruct();
	temp.type = "space";

	level.linelist[ level.linelist.size ] = temp;
}

addSpaceSmall()
{
	temp = spawnstruct();
	temp.type = "spacesmall";

	level.linelist[ level.linelist.size ] = temp;
}

addCenterImage( image, width, height, delay )
{
	precacheShader( image );

	temp = spawnstruct();
	temp.type = "centerimage";
	temp.image = image;
	temp.width = width;
	temp.height = height;
	temp.sort = 2;

	if ( isdefined( delay ) )
		temp.delay = delay;

	level.linelist[ level.linelist.size ] = temp;
}

addLeftImage( image, width, height, delay )
{
	precacheShader( image );

	temp = spawnstruct();
	temp.type = "leftimage";
	temp.image = image;
	temp.width = width;
	temp.height = height;
	temp.sort = 2;

	if ( isdefined( delay ) )
		temp.delay = delay;

	level.linelist[ level.linelist.size ] = temp;
}

playCredits()
{
	VisionSetNaked( "", 0 );
	
	mode =  getdvar( "ui_char_museum_mode" );
	
	if( isdefined( mode ) && mode == "credits_1" )
	{
		hudelem = NewHudElem();
		hudelem.x = 0;
		hudelem.y = 0;
		hudelem.alignX = "center";
		hudelem.alignY = "middle";
		hudelem.horzAlign = "center";
		hudelem.vertAlign = "middle";
		hudelem.sort = 3;
		hudelem.foreground = true;
		hudelem SetText( &"CREDIT_DEVELOPED_BY" );
	//	hudelem.alpha = 0;
	//	hudelem FadeOverTime( 0.2 );
		hudelem.alpha = 1;
	
		hudelem.hidewheninmenu = false;
		hudelem.fontScale = 1.7;// was 1.6 and 2.4, larger font change
		hudelem.color = ( 0.8, 1.0, 0.8 );
		hudelem.font = "objective";
		hudelem.glowColor = ( 0.3, 0.6, 0.3 );
		hudelem.glowAlpha = 1;
		duration = 3000;
		hudelem SetPulseFX( 0, duration, 700 );// something, decay start, decay duration
		
		wait 3;
		hudelem delaycall( 1, ::destroy );
		wait 0.5;
	}	
	
	for ( i = 0; i < level.linelist.size; i++ )
	{
		delay = 0.5;// 0.4
		type = level.linelist[ i ].type;

		if ( type == "centerimage" )
		{
			if( isdefined( mode ) && mode != "credits_black" )
				flag_wait( "atvi_credits_go" );
				
			image = level.linelist[ i ].image;
			width = level.linelist[ i ].width;
			height = level.linelist[ i ].height;

			temp = newHudElem();
			temp SetShader( image, width, height );
			temp.alignX = "center";
			temp.horzAlign = "center";
			temp.x = 0;
			temp.y = 480;
			temp.sort = 2;
			temp.foreground = true;

			temp thread delayDestroy( level.credits_speed );
			temp moveOverTime( level.credits_speed );
			temp.y = level.credits_spacing;

			if ( isdefined( level.linelist[ i ].delay ) )
				delay = level.linelist[ i ].delay;
			else
				delay = ( ( 0.037 * height ) );
				//delay = ( ( 0.0296 * height ) );
		}
		else if ( type == "leftimage" )
		{
			image = level.linelist[ i ].image;
			width = level.linelist[ i ].width;
			height = level.linelist[ i ].height;

			temp = newHudElem();
			temp SetShader( image, width, height );
			temp.alignX = "center";
			temp.horzAlign = "left";
			temp.x = 128;
			temp.y = 480;
			temp.sort = 2;
			temp.foreground = true;

			temp thread delayDestroy( level.credits_speed );
			temp moveOverTime( level.credits_speed );
			temp.y = level.credits_spacing;

			delay = ( ( 0.037 * height ) );
			//delay = ( ( 0.0296 * height ) );
		}
		else if ( type == "lefttitle" )
		{
			title = level.linelist[ i ].title;
			textscale = level.linelist[ i ].textscale;

			temp = newHudElem();
			temp setText( title );
			temp.alignX = "left";
			temp.horzAlign = "left";
			temp.x = 28;
			temp.y = 480;

			if ( !level.console )
				temp.font = "default";
			else
				temp.font = "small";

			temp.fontScale = textscale;
			temp.sort = 2;
			temp.glowColor = ( 0.3, 0.6, 0.3 );
			temp.glowAlpha = 1;

			temp thread delayDestroy( level.credits_speed );
			temp moveOverTime( level.credits_speed );
			temp.y = level.credits_spacing;		
			
			temp thread pulse_fx();
		}
		else if ( type == "leftname" )
		{
			name = level.linelist[ i ].name;
			textscale = level.linelist[ i ].textscale;

			temp = newHudElem();
			temp setText( name );
			temp.alignX = "left";
			temp.horzAlign = "left";
			temp.x = 60;
			temp.y = 480;

			if ( !level.console )
				temp.font = "default";
			else
				temp.font = "small";

			temp.fontScale = textscale;
			temp.sort = 2;
			temp.glowColor = ( 0.3, 0.6, 0.3 );
			temp.glowAlpha = 1;

			temp thread delayDestroy( level.credits_speed );
			temp moveOverTime( level.credits_speed );
			temp.y = level.credits_spacing;
			
			temp thread pulse_fx();
		}
		else if ( type == "castname" )
		{
			title = level.linelist[ i ].title;
			name = level.linelist[ i ].name;
			textscale = level.linelist[ i ].textscale;
			
			temp1 = newHudElem();
			temp1 setText( title );
			temp1.alignX = "left";
			temp1.horzAlign = "left";
			temp1.x = 60;
			temp1.y = 480;

			if ( !level.console )
				temp1.font = "default";
			else
				temp1.font = "small";

			temp1.fontScale = textscale;
			temp1.sort = 2;
			temp1.glowColor = ( 0.3, 0.6, 0.3 );
			temp1.glowAlpha = 1;
			

			temp2 = newHudElem();
			temp2 setText( name );
			temp2.alignX = "right";
			temp2.horzAlign = "left";
			temp2.x = 275;
			temp2.y = 480;

			if ( !level.console )
				temp2.font = "default";
			else
				temp2.font = "small";

			temp2.fontScale = textscale;
			temp2.sort = 2;
			temp2.glowColor = ( 0.3, 0.6, 0.3 );
			temp2.glowAlpha = 1;
			
			

			temp1 thread delayDestroy( level.credits_speed );
			temp1 moveOverTime( level.credits_speed );
			temp1.y = level.credits_spacing;

			temp2 thread delayDestroy( level.credits_speed );
			temp2 moveOverTime( level.credits_speed );
			temp2.y = level.credits_spacing;
			
			temp1 thread pulse_fx();
			temp2 thread pulse_fx();
		}
		else if ( type == "subleftname" )
		{
			name = level.linelist[ i ].name;
			textscale = level.linelist[ i ].textscale;

			temp = newHudElem();
			temp setText( name );
			temp.alignX = "left";
			temp.horzAlign = "left";
			temp.x = 92;
			temp.y = 480;

			if ( !level.console )
				temp.font = "default";
			else
				temp.font = "small";

			temp.fontScale = textscale;
			temp.sort = 2;
			temp.glowColor = ( 0.3, 0.6, 0.3 );
			temp.glowAlpha = 1;

			temp thread delayDestroy( level.credits_speed );
			temp moveOverTime( level.credits_speed );
			temp.y = level.credits_spacing;
			
			temp thread pulse_fx();
		}
		else if ( type == "righttitle" )
		{
			title = level.linelist[ i ].title;
			textscale = level.linelist[ i ].textscale;

			temp = newHudElem();
			temp setText( title );
			temp.alignX = "left";
			temp.horzAlign = "right";
			temp.x = -132;
			temp.y = 480;

			if ( !level.console )
				temp.font = "default";
			else
				temp.font = "small";

			temp.fontScale = textscale;
			temp.sort = 2;
			temp.glowColor = ( 0.3, 0.6, 0.3 );
			temp.glowAlpha = 1;

			temp thread delayDestroy( level.credits_speed );
			temp moveOverTime( level.credits_speed );
			temp.y = level.credits_spacing;
			
			//temp thread pulse_fx();
		}
		else if ( type == "rightname" )
		{
			name = level.linelist[ i ].name;
			textscale = level.linelist[ i ].textscale;

			temp = newHudElem();
			temp setText( name );
			temp.alignX = "left";
			temp.horzAlign = "right";
			temp.x = -100;
			temp.y = 480;

			if ( !level.console )
				temp.font = "default";
			else
				temp.font = "small";

			temp.fontScale = textscale;
			temp.sort = 2;
			temp.glowColor = ( 0.3, 0.6, 0.3 );
			temp.glowAlpha = 1;

			temp thread delayDestroy( level.credits_speed );
			temp moveOverTime( level.credits_speed );
			temp.y = level.credits_spacing;
			
			//temp thread pulse_fx();
		}
		else if ( type == "centerheading" )
		{
			heading = level.linelist[ i ].heading;
			textscale = level.linelist[ i ].textscale;

			temp = newHudElem();
			temp setText( heading );
			temp.alignX = "center";
			temp.horzAlign = "center";
			temp.x = 0;
			temp.y = 480;

			if ( !level.console )
				temp.font = "default";
			else
				temp.font = "small";

			temp.fontScale = textscale;
			temp.sort = 2;
			temp.glowColor = ( 0.3, 0.6, 0.3 );
			temp.glowAlpha = 1;

			temp thread delayDestroy( level.credits_speed );
			temp moveOverTime( level.credits_speed );
			temp.y = level.credits_spacing;
			
			//temp thread pulse_fx();
		}
		else if ( type == "centerdual" )
		{
			title = level.linelist[ i ].title;
			name = level.linelist[ i ].name;
			textscale = level.linelist[ i ].textscale;

			temp1 = newHudElem();
			temp1 setText( title );
			temp1.alignX = "right";
			temp1.horzAlign = "center";
			temp1.x = -8;
			temp1.y = 480;

			if ( !level.console )
				temp1.font = "default";
			else
				temp1.font = "small";

			temp1.fontScale = textscale;
			temp1.sort = 2;
			temp1.glowColor = ( 0.3, 0.6, 0.3 );
			temp1.glowAlpha = 1;

			temp2 = newHudElem();
			temp2 setText( name );
			temp2.alignX = "left";
			temp2.horzAlign = "center";
			temp2.x = 8;
			temp2.y = 480;

			if ( !level.console )
				temp2.font = "default";
			else
				temp2.font = "small";

			temp2.fontScale = textscale;
			temp2.sort = 2;
			temp2.glowColor = ( 0.3, 0.6, 0.3 );
			temp2.glowAlpha = 1;

			temp1 thread delayDestroy( level.credits_speed );
			temp1 moveOverTime( level.credits_speed );
			temp1.y = level.credits_spacing;

			temp2 thread delayDestroy( level.credits_speed );
			temp2 moveOverTime( level.credits_speed );
			temp2.y = level.credits_spacing;
			
			//temp1 thread pulse_fx();
			//temp2 thread pulse_fx();
		}
		else if ( type == "centertriple" )
		{
			name1 = level.linelist[ i ].name1;
			name2 = level.linelist[ i ].name2;
			name3 = level.linelist[ i ].name3;
			textscale = level.linelist[ i ].textscale;

			temp1 = newHudElem();
			temp1 setText( name1 );
			temp1.alignX = "center";
			temp1.horzAlign = "center";
			temp1.x = -160;
			temp1.y = 480;

			if ( !level.console )
				temp1.font = "default";
			else
				temp1.font = "small";

			temp1.fontScale = textscale;
			temp1.sort = 2;
			temp1.glowColor = ( 0.3, 0.6, 0.3 );
			temp1.glowAlpha = 1;

			temp2 = newHudElem();
			temp2 setText( name2 );
			temp2.alignX = "center";
			temp2.horzAlign = "center";
			temp2.x = 0;
			temp2.y = 480;

			if ( !level.console )
				temp2.font = "default";
			else
				temp2.font = "small";

			temp2.fontScale = textscale;
			temp2.sort = 2;
			temp2.glowColor = ( 0.3, 0.6, 0.3 );
			temp2.glowAlpha = 1;

			temp3 = newHudElem();
			temp3 setText( name3 );
			temp3.alignX = "center";
			temp3.horzAlign = "center";
			temp3.x = 160;
			temp3.y = 480;

			if ( !level.console )
				temp3.font = "default";
			else
				temp3.font = "small";

			temp3.fontScale = textscale;
			temp3.sort = 2;
			temp3.glowColor = ( 0.3, 0.6, 0.3 );
			temp3.glowAlpha = 1;

			temp1 thread delayDestroy( level.credits_speed );
			temp1 moveOverTime( level.credits_speed );
			temp1.y = level.credits_spacing;

			temp2 thread delayDestroy( level.credits_speed );
			temp2 moveOverTime( level.credits_speed );
			temp2.y = level.credits_spacing;

			temp3 thread delayDestroy( level.credits_speed );
			temp3 moveOverTime( level.credits_speed );
			temp3.y = level.credits_spacing;
			
			//temp1 thread pulse_fx();
			//temp2 thread pulse_fx();
			//temp3 thread pulse_fx();			
		}
		else if ( type == "centername" )
		{
			name = level.linelist[ i ].name;
			textscale = level.linelist[ i ].textscale;

			temp = newHudElem();
			temp setText( name );
			temp.alignX = "left";
			temp.horzAlign = "center";
			temp.x = 8;
			temp.y = 480;

			if ( !level.console )
				temp.font = "default";
			else
				temp.font = "small";

			temp.fontScale = textscale;
			temp.sort = 2;
			temp.glowColor = ( 0.3, 0.6, 0.3 );
			temp.glowAlpha = 1;

			temp thread delayDestroy( level.credits_speed );
			temp moveOverTime( level.credits_speed );
			temp.y = level.credits_spacing;
			
			//temp thread pulse_fx();
		}
		else if ( type == "centernamedouble" )
		{
			name1 = level.linelist[ i ].name1;
			name2 = level.linelist[ i ].name2;
			textscale = level.linelist[ i ].textscale;

			temp1 = newHudElem();
			temp1 setText( name1 );
			temp1.alignX = "center";
			temp1.horzAlign = "center";
			temp1.x = -80;
			temp1.y = 480;

			if ( !level.console )
				temp1.font = "default";
			else
				temp1.font = "small";

			temp1.fontScale = textscale;
			temp1.sort = 2;
			temp1.glowColor = ( 0.3, 0.6, 0.3 );
			temp1.glowAlpha = 1;

			temp2 = newHudElem();
			temp2 setText( name2 );
			temp2.alignX = "center";
			temp2.horzAlign = "center";
			temp2.x = 80;
			temp2.y = 480;

			if ( !level.console )
				temp2.font = "default";
			else
				temp2.font = "small";

			temp2.fontScale = textscale;
			temp2.sort = 2;
			temp2.glowColor = ( 0.3, 0.6, 0.3 );
			temp2.glowAlpha = 1;

			temp1 thread delayDestroy( level.credits_speed );
			temp1 moveOverTime( level.credits_speed );
			temp1.y = level.credits_spacing;

			temp2 thread delayDestroy( level.credits_speed );
			temp2 moveOverTime( level.credits_speed );
			temp2.y = level.credits_spacing;
			
			//temp1 thread pulse_fx();
			//temp2 thread pulse_fx();
		}
		else if ( type == "spacesmall" )
			delay = 0.1875;// 0.15
		else
			assert( type == "space" );

		//wait 0.65;
		wait delay * ( level.credits_speed/ 22.5 );
	}

}

delayDestroy( duration )
{
	wait duration;
	self destroy();
}

pulse_fx()
{
	self.alpha = 0;
	wait level.credits_speed * .08;
	
	self FadeOverTime( 0.2 );
	self.alpha = 1;
	self SetPulseFX( 50, int( level.credits_speed * .6 * 1000 ), 500 );	
}

addSubLeftTitleNameSpace( title, name )
{
	addSubLeftTitle( title );
	addSpaceSmall();
	addSubLeftName( name );
	addSpace();
}

addLeftTitleNameSpace( title, name )
{
	addLeftTitle( title );
	addSpaceSmall();
	addLeftName( name );
	addSpace();
}

addLeftTitleName( title, name )
{
	addLeftTitle( title );
	addSpaceSmall();
	addLeftName( name );
}
	
addSubLeftTitleName( title, name )
{
	addSubLeftTitle( title );
	addSpaceSmall();
	addSubLeftName( name );
}	

addLeftNameName( name1, name2 )
{
	addLeftName( name1 );
	addLeftName( name2 );
}

addSubLeftNameName( name1, name2 )
{
	addSubLeftName( name1 );
	addSubLeftName( name2 );
}

addSubLeftNameNameName( name1, name2, name3 )
{
	addSubLeftName( name1 );
	addSubLeftName( name2 );
	addSubLeftName( name3 );
}

addImageIW( image, width, height, delay )
{
	if ( getdvar( "ui_char_museum_mode" ) != "credits_black" )
		addLeftImage( image, width, height, delay );
	else
		addCenterImage( image, width, height, delay );
}

addTitleIW( title )
{
	if ( getdvar( "ui_char_museum_mode" ) != "credits_black" )
		addLeftTitle( title );
	else
		addCenterHeading( title );
}

addSubTitleIW( title )
{
	if ( getdvar( "ui_char_museum_mode" ) != "credits_black" )
		addSubLeftTitle( title );
	else
		addCenterHeading( title );
}

addTitleNameIW( title, name )
{	
	if ( getdvar( "ui_char_museum_mode" ) != "credits_black" )
	{
		addLeftTitle( title );
		addSpaceSmall();
		addLeftName( name );
	}
	else
		addCenterDual( title, name );
}

addSubTitleNameIW( title, name )
{
	if ( getdvar( "ui_char_museum_mode" ) != "credits_black" )
	{
		addSubLeftTitle( title );
		addSpaceSmall();
		addSubLeftName( name );
	}
	else
		addCenterDual( title, name );
}

addcastIW( name, title, combo )
{
	if ( getdvar( "ui_char_museum_mode" ) != "credits_black" )
		addCastName( name, title );
	else
		addCenterHeading( name );
}

addNameIW( name )
{
	if ( getdvar( "ui_char_museum_mode" ) != "credits_black" )
		addLeftName( name );
	else
		addCenterName( name );
}

addSubNameIW( name )
{
	if ( getdvar( "ui_char_museum_mode" ) != "credits_black" )
		addSubLeftName( name );
	else
		addCenterName( name );
}

addSpaceTitle()
{
	if ( getdvar( "ui_char_museum_mode" ) != "credits_black" )
		addSpace();
	else	
		addSpaceSmall();
}

addGap()
{
	addSpace();
	addSpace();
}


initActivisionCredits()
{
	initATVICredits_atvi();
	initATVICredits_pr();
	initATVICredits_europe();
	initATVICredits_central_tech();
	initATVICredits_blade();
	initATVICredits_demonware();
	initATVICredits_global();
	initATVICredits_business();
	initATVICredits_qa1();
	initATVICredits_qa2();
	initATVICredits_qa3();
	initATVICredits_qa4();
	initATVICredits_end();
}

initATVICredits_atvi()
{
	addCenterImage( "logo_activision", 256, 128, 3.875 );// 3.1
	addSpace();
	addSpace();
			
	// Production
	addCenterHeading( &"CREDIT_PRODUCTION" );
	addSpaceSmall();
	// Producer
	// CHRIS WILLIAMS
	addCenterDual( &"CREDIT_PRODUCER", &"CREDIT_CHRIS_WILLIAMS" );
	addSpaceSmall();
	// Associate Producers
	// VINCENT FENNEL
	addCenterDual( &"CREDIT_ASSOCIATE_PRODUCERS", &"CREDIT_VINCENT_FENNEL" );
	// TAYLOR LIVINGSTON
	addCenterName( &"CREDIT_TAYLOR_LIVINGSTON" );
	// DEREK RACCA
	addCenterName( &"CREDIT_DEREK_RACCA" );
	addSpaceSmall();
	// Production Coordinator
	// ADRIENNE ARRASMITH
	addCenterDual( &"CREDIT_PRODUCTION_COORDINAT", &"CREDIT_ADRIENNE_ARRASMITH" );
	addSpaceSmall();
	
	// Additional Production
	//RHETT CHASSEREAU
	addCenterDual( &"CREDIT_ADDITIONAL_PRODUCTIO", &"CREDIT_RHETT_CHASSEREAU");
	addSpaceSmall();
	// Senior Executive Producer
	// MARCUS IREMONGER
	addCenterDual( &"CREDIT_SENIOR_EXECUTIVE_PRO", &"CREDIT_MARCUS_IREMONGER" );
	addSpaceSmall();
	// Vice President, Production
	// STEVE ACKRICH
	addCenterDual( &"CREDIT_HEAD_OF_PRODUCTION", &"CREDIT_STEVE_ACKRICH" );
	addGap();
}
	
initATVICredits_pr()
{		
	// Public Relations
	addCenterHeading( &"CREDIT_PUBLIC_RELATIONS" );
	addSpaceSmall();
	// Director, Owned Properties
	// MIKE MANTARRO
	addCenterDual( &"CREDIT_DIRECTOR_OWNED_PROPE", &"CREDIT_MIKE_MANTARRO" );
	addSpaceSmall();
	// PR Manager	
	// JOHN RAFACZ
	addCenterDual( &"CREDIT_PR_MANAGER", &"CREDIT_JOHN_RAFACZ" );
	addSpaceSmall();
	// Junior Publicist
	// MONICA PONTRELLI
	addCenterDual( &"CREDIT_JUNIOR_PUBLICIST", &"CREDIT_MONICA_PONTRELLI" );
	// JOSHUA SELINGER
	addCenterName( &"CREDIT_JOSHUA_SELINGER");
	addSpaceSmall();
	//European PR Director
	// NICK GRANGE
	addCenterDual( &"CREDIT_EUROPEAN_PR_DIRECTOR", &"CREDIT_NICK_GRANGE");

	addGap();
}

initATVICredits_europe()
{		
	// Production Services - Europe
	addCenterHeading( &"CREDIT_PRODUCTION_SERVICES_");
	addSpaceSmall();
	// Senior Director of Production Services - Europe
	// BARRY KEHOE
	addCenterDual( &"CREDIT_SENIOR_DIRECTOR_OF_P", &"CREDIT_BARRY_KEHOE" );
	addSpaceSmall();
	// Localization Manager
	// FIONA EBBS
	addCenterDual( &"CREDIT_LOCALISATION_MANAGER", &"CREDIT_FIONA_EBBS" );		
	addSpaceSmall();
	// Senior Localization Project Manager
	// ANNETTE LEE
	addCenterDual( &"CREDIT_SENIOR_LOCALIZATION_", &"CREDIT_ANNETTE_LEE" );				
	addSpaceSmall();
	// Localization Project Manager
	// JACK O'HARA
	addCenterDual( &"CREDIT_LOCALISATION_PROJECT", &"CREDIT_JACK_OHARA" );		
	addSpaceSmall();			
	// Localization QA Manager
	// DAVID HICKEY
	addCenterDual( &"CREDIT_LOCALISATION_QA_MANA", &"CREDIT_DAVID_HICKEY" );			
	addSpaceSmall();
	
	// Localization Assistant QA Manager
	// YVONNE COSTELLO		
	addCenterDual( &"CREDIT_LOCALISATION_ASSISTA", &"CREDIT_YVONNE_COSTELLO" );		
	addGap();
	
	
	//Localization QA Testers
	addCenterHeading( &"CREDIT_LOCALIZATION_QA_TEST");	
	addSpaceSmall();			
	// LUIS HERNANDEZ DALMAU 
	// VINCENZO FERRARA
	addCenterNameDouble( &"CREDIT_LUIS_HERNANDEZ_DALMA", &"CREDIT_VINCENZO_FERRARA_" );	
	// LARA SOLA GALLEGO
	// JEREMY LEVI		
	addCenterNameDouble( &"CREDIT_LARA_SOLA_GALLEGO", &"CREDIT_JEREMY_LEVI_" );		
	// SEBASTIEN MAZZERBO 
	// DARIO MILONE		
	addCenterNameDouble( &"CREDIT_SEBASTIEN_MAZZERBO_", &"CREDIT_DARIO_MILONE_" );	
	// KERILL MEIER O’BRIEN
	// MARCELL WITEK			
	addCenterNameDouble( &"CREDIT_KERILL_MEIER_OBRIEN", &"CREDIT_MARCELL_WITEK_" );				
	addSpace();
	
	//IT Network Technician
	// FERGUS LINDSAY 
	addCenterDual( &"CREDIT_IT_NETWORK_TECHNICIA", &"CREDIT_FERGUS_LINDSAY_" );	
	addGap();
	
	
	// LOCALIZATION TOOLS & SUPPORT PROVIDED BY STEPHANIE DEMING & XLOC INC.
	addCenterHeading( &"CREDIT_LOCALIZATION_TOOLS_");				
	addGap();
}

initATVICredits_central_tech()
{
	// Central Technology					
	addCenterHeading( &"CREDIT_CENTRAL_TECHNOLOGY");
	addSpaceSmall();

	// VP Art Production
	// ALESSANDRO TENTO
	addCenterDual( &"CREDIT_VP_ART_PRODUCTION", &"CREDIT_ALESSANDRO_TENTO_");
	addSpace();	
	
	addCenterHeading( &"CREDIT_ENGINEERING" );
	addSpaceSmall();
	// VP of Online
	// JOHN BOJORQUEZ
	addCenterDual( &"CREDIT_VP_OF_ONLINE_", &"CREDIT_JOHN_BOJORQUEZ");		
	addSpaceSmall();	
	// Managing Director, Demonware
	// PAT GRIFFITH
	addCenterDual( &"CREDIT_MANAGING_DIRECTOR_DE", &"CREDIT_PAT_GRIFFITH_");	
	addSpaceSmall();
	// Technical Director
	// WADE BRAINERD
	addCenterDual( &"CREDIT_TECHNICAL_DIRECTOR", &"CREDIT_WADE_BRAINERD_");
	addSpace();
	
	// Studio Central - Outsourcing	
	addCenterHeading( &"CREDIT_STUDIO_CENTRAL_OUT");				
	addSpaceSmall();	
	// Director Art Production
	// RICCARD LINDE
	addCenterDual( &"CREDIT_DIRECTOR_ART_PRODUCT", &"CREDIT_RICCARD_LINDE");	
	addSpaceSmall();
			
	// BERNARDO ANTONIAZZI
	addCenterDual( &"CREDIT_TECHNICAL_ART_DIRECT", &"CREDIT_BERNARDO_ANTONIAZZI");	
	addCenterName( &"CREDIT_MITCH_BOWLER");	
	addSpaceSmall();
	
	// Production Manager
	// Michael Restifo
	addCenterDual( &"CREDIT_PRODUCTION_MANAGER", &"CREDIT_MICHAEL_RESTIFO");				
	addSpaceSmall();
	// CHRISTOPHER CODDING	
	addCenterDual( &"CREDIT_PRODUCTION_COORDINAT", &"CREDIT_CHRISTOPHER_CODDING");				
	addGap();
}

initATVICredits_blade()
{
	// Blade Games World, Inc.
	addCenterDual( &"CREDIT_ADDITIONAL_ART", &"CREDIT_BLADE_GAMES_WORLD_IN" );	
	addGap();
}		

initATVICredits_demonware()
{
	// Demonware
	addCenterHeading( &"CREDIT_DEMONWARE");	
	addSpaceSmall();
	addCenterNameDouble( &"CREDIT_MICHAEL_COLLINS", &"CREDIT_PAUL_FROESE");	
	addCenterNameDouble( &"CREDIT_JOHN_KIRK", &"CREDIT_EMMANUEL_STONE");
	addCenterNameDouble( &"CREDIT_JASON_WEI", "");
	addGap();
}

initATVICredits_global()
{		
	// GLOBAL BRAND MANAGEMENT
	addCenterHeading( &"CREDIT_GLOBAL_BRAND_MANAGEM");
	addSpaceSmall();
	// DIRECTOR OF MARKETING
	// ROB KOSTICH
	addCenterDual( &"CREDIT_VICE_PRESIDENT_OF_MA", &"CREDIT_ROB_KOSTICH");		
	addSpaceSmall();
	// DIRECTOR OF MARKETING
	// BYRON BEEDE
	addCenterDual( &"CREDIT_DIRECTOR_OF_MARKETIN", &"CREDIT_BYRON_BEEDE");	
	addSpaceSmall();
	// GLOBAL BRAND MANAGER
	// GEOFF_CARROLL	
	addCenterDual( &"CREDIT_GLOBAL_BRAND_MANAGER", &"CREDIT_GEOFF_CARROLL");			
	addSpaceSmall();
	// ASSOCIATE BRAND MANAGERS
	// JOE KORSMO
	addCenterDual( &"CREDIT_ASSOCIATE_BRAND_MANA", &"CREDIT_JOE_KORSMO");	
	// MIKE SCHAEFER
	addCenterName( &"CREDIT_MIKE_SCHAEFER");	
	// DAVID WANG		
	addCenterName( &"CREDIT_DAVID_WANG");		
	addGap();
	
	
	// Art Services
	addCenterHeading( &"CREDIT_ART_SERVICES");	
	addSpaceSmall();
	// Art Services Lead
	// Chris Reinhart
	addCenterDual( &"CREDIT_ART_SERVICES_LEAD", &"CREDIT_CHRIS_REINHART");					
	addGap();	
}

initATVICredits_business()
{
	// Business and Legal Affairs		
	addCenterHeading( &"CREDIT_BUSINESS_AND_LEGAL_A");
	addSpaceSmall();
	// GREG DEUTSCH
	// JANE ELMS			
	addCenterNameDouble( &"CREDIT_GREG_DEUTSCH", &"CREDIT_JANE_ELMS");	
	// KAP KANG
	// KATE OGOSTA					
	addCenterNameDouble( &"CREDIT_KATE_OGOSTA_", &"CREDIT_AMANDA_OKEEFE");	
	// AMANDA O'KEEFE			
	// TRAVIS STANSBURY
	addCenterNameDouble( &"CREDIT_TRAVIS_STANSBURY", &"CREDIT_PHIL_TERZIAN");				
	// PHIL TERZIAN
	//MARY TUCK
	addCenterNameDouble( &"CREDIT_MARY_TUCK", "");		
	addGap();
		
		
	// Talent and Audio Management Group
	addCenterHeading( &"CREDIT_TALENT_AND_AUDIO_MAN");
	addSpaceSmall();
	// Talent Acquisition Manager
	// MARCHELE HARDIN
	addCenterDual( &"CREDIT_TALENT_ACQUISITION_M", &"CREDIT_MARCHELE_HARDIN");	
	addSpaceSmall();
	// Talent Associate
	// NOAH SARID
	addCenterDual( &"CREDIT_TALENT_ASSOCIATE", &"CREDIT_NOAH_SARID");					
	addSpaceSmall();
	// Talent Coordinator
	// STEFANI JONES
	addCenterDual( &"CREDIT_TALENT_COORDINATOR", &"CREDIT_STEFANI_JONES");								
	addGap();	
	
	
	addCenterHeading( &"CREDIT_FINANCE");
	addSpaceSmall();
	// VP of Studio Finance and Royalties
	// RAJ SAIN
	addCenterDual( &"CREDIT_VP_OF_STUDIO_FINANCE", &"CREDIT_RAJ_SAIN");	
	addSpaceSmall();
	// Finance Manager
	// CLINTON ALLEN
	addCenterDual( &"CREDIT_FINANCE_MANAGER", &"CREDIT_CLINTON_ALLEN");	
	addCenterName( &"CREDIT_HARJINDER_SINGH");
	addSpaceSmall();	
	// Sr. Financial Analyst
	// JASON JORDAN
	addCenterDual( &"CREDIT_SR_FINANCIAL_ANALYST", &"CREDIT_JASON_JORDAN");								
	addSpaceSmall();	
	// Finance Analyst
	// ADRIAN GOMEZ	
	addCenterDual( &"CREDIT_FINANCE_ANALYST", &"CREDIT_ADRIAN_GOMEZ");	
//	addCenterName( &"CREDIT_JASON_JORDAN");		
	addCenterName( &"CREDIT_FRANSISCA_TAN");		
	addGap();
	
		
	// Activision Special Thanks
	addCenterHeading( &"CREDIT_ACTIVISION_SPECIAL_T");	
	addSpaceSmall();
	addCenterHeading( &"CREDIT_MIKE_GRIFFITH_BRIAN_");		
	addGap();
}	
	
initATVICredits_qa1()
{		
	addCenterHeading( &"CREDIT_QUALITY_ASSURANCE_ATVI");	
	addSpaceSmall();
	// VP Quality Assurance/Customer Service
	// PAUL STERNGOLD
	addCenterDual( &"CREDIT_VP_QUALITY_ASSURANCE", &"CREDIT_PAUL_STERNGOLD");
	addSpace();
	
	// QA Project Lead
	//	Sean Berrett	
	addCenterDual( &"CREDIT_QUALITY_ASSURANCE_LEAD_ATVI", &"CREDIT_SEAN_BERRETT");	
	addSpaceSmall();
	// QA Floor Lead
	// Jay Menconi
	addCenterDual( &"CREDIT_QA_FLOOR_LEAD", &"CREDIT_JAY_MENCONI");		
	addSpaceSmall();	
	addCenterDual( &"CREDIT_QA_SENIOR_PROJECT_LE", &"CREDIT_HENRY_P_VILLANUEVA");	
	addSpaceSmall();
	addCenterDual( &"CREDIT_QA_MANAGER", &"CREDIT_GLENN_VISTANTE");	
	addSpaceSmall();		
	// Project Lead
	addCenterDual( &"CREDIT_PROJECT_LEAD", &"CREDIT_ERIK_MELEN_");	
	addSpace();
	
	// QA Testers
	addCenterHeading( &"CREDIT_QA_TESTERS");	
	addSpaceSmall();	
	addCenterTriple( &"CREDIT_CHAD_SCHMIDT_", &"CREDIT_ADAM_SMITH_", &"CREDIT_DAVION_FARRIS_");						
	addCenterTriple( &"CREDIT_JOHN_GOLDSWORTHY_", &"CREDIT_NATE_KINNEY_", &"CREDIT_RYAN_TRONDSEN_");
	addCenterTriple( &"CREDIT_TARIKH_BROWN_", &"CREDIT_PETE_ROMULO_PEDROZ", &"CREDIT_CHARLES_DAVIS_");	
	addCenterTriple( &"CREDIT_GABE_NOTO_", &"CREDIT_ULYSSES_HOLGUIN_", &"CREDIT_JOHN_ESTIOKO_");				
	addCenterTriple( &"CREDIT_XIAOHU_ALCOCER_", &"CREDIT_KEVIN_CHESTER_", &"CREDIT_DANIEL_HERSCHER_");
	addCenterTriple( &"CREDIT_LEVETT_WASHINGTON_", &"CREDIT_BRIAN_BAKER", &"CREDIT_MARK_RUZICKA");
	addCenterTriple( &"CREDIT_MATT_WELLMAN_", &"CREDIT_ANTHONY_MORENO_", &"CREDIT_CORY_FURLOW_");
	addCenterTriple( &"CREDIT_BRIAN_POST_", &"CREDIT_ANDREW_GRASS_", &"CREDIT_QUENTIN_TREMAYNE_C");
	addCenterTriple( &"CREDIT_ANDREW_GULOTTA_", &"CREDIT_RICH_BERNOT_", &"CREDIT_TABARI_JEFFRIES_");
	addCenterTriple( &"CREDIT_MICHAEL_MONTOYA_", &"CREDIT_CRAIG_NELSON_", &"CREDIT_BRANDON_ARONSON_");
	addCenterTriple( &"CREDIT_GREG_SANDS_", &"CREDIT_CARLOS_MORAN_", &"CREDIT_SEAN_MOLINE_");
	addCenterTriple( &"CREDIT_LOU_STUDDERT_", &"CREDIT_ROBERT_CHAPLAN_", &"CREDIT_JOSE_VEGA_");
	addCenterTriple( &"CREDIT_MIKE_ARDEN_", &"CREDIT_JOE_CHAVEZ_", &"CREDIT_BRADON_MILLER_");
	addGap();	
}

initATVICredits_qa2()
{				
	// Director, QA
	// CHRISTOPHER WILSON
	addCenterDual( &"CREDIT_DIRECTOR_QA", &"CREDIT_CHRISTOPHER_WILSON");		
	addSpaceSmall();
	// QA CRG Project Lead
	// MATT RYAN
	addCenterDual( &"CREDIT_QA_CRG_PROJECT_LEAD", &"CREDIT_MATT_RYAN");		
	addSpaceSmall();
	// QA CRG Floor Lead
	// JONATHAN MACK
	addCenterDual( &"CREDIT_QA_CRGFLOOR_LEAD", &"CREDIT_JONATHAN_MACK");		
	addSpaceSmall();
	// QA CRG Testers
	// CHRISTIAN VASCO
	addCenterDual( &"CREDIT_QA_CRG_TESTERS", &"CREDIT_CHRISTIAN_VASCO");		
	addSpace();
	
	// QA Network Lab
	addCenterHeading( &"CREDIT_QA_NETWORK_LAB");		
	addSpaceSmall();
	// Manager, QA Operations
	// CHRIS KEIM
	addCenterDual( &"CREDIT_MANAGER_QA_OPERATION", &"CREDIT_CHRIS_KEIM");		
	addSpaceSmall();	
	// QA Network Lab Project Leads
	// JESSIE JONES
	// LEONARD RODRIGUEZ			
	addCenterDual( &"CREDIT_QA_NETWORK_LAB_PROJE", &"CREDIT_JESSIE_JONES");	
	addCenterName( &"CREDIT_LEONARD_RODRIGUEZ");			
	addSpaceSmall();
	// QA Network Lab Tester
	// BRYAN CHICE
	addCenterDual( &"CREDIT_QA_NETWORK_LAB_TESTE", &"CREDIT_BRYAN_CHICE");	
	addSpace();
			
	addCenterHeading( &"CREDIT_QA_COMPATABILITY_LAB");	
	addSpaceSmall();
	addCenterDual( &"CREDIT_QACL_LAB_PROJECT_LE", &"CREDIT_ROBERT_FENOGLIO");	
	addCenterName( &"CREDIT_FARID_KAZIMI");												
	addCenterName( &"CREDIT_AUSTIN_KIENZLE");		
	addSpaceSmall();	
	addCenterDual( &"CREDIT_QACL_LAB_TESTERS", &"CREDIT_ALBERT_LEE");	
	addCenterName( &"CREDIT_WILLIAM_WHALEY");	
	addSpace();
}		

initATVICredits_qa3()
{		
	//QA AUDIO VISUAL LAB
	addCenterHeading( &"CREDIT_QA_AV_LAB");	
	addSpaceSmall();
	
	//QA AV Lab Senior Project Lead
	//Victor Durling
	addCenterDual( &"CREDIT_QA_AV_LAB_SR_PR_LEAD", &"CREDIT_VICTOR_DURLING");	
	addSpaceSmall();
	
	//QA AV Lab Senior Tester
	//Cliff Hooper
	addCenterDual( &"CREDIT_QA_AV_LAB_SR_TESTER", &"CREDIT_CLIFF_HOOPER");	
	addSpaceSmall();
	
	
	//QA AV Lab Testers
	//Delven Rutledge
	//Ryan Visteen
	addCenterDual( &"CREDIT_QA_AV_LAB_TESTERS", &"CREDIT_DELVEN_RUTLEDGE");
	addCenterName( &"CREDIT_RYAN_VISTEEN");			
	addSpace();

	// QA Mastering Lab
	addCenterHeading( &"CREDIT_QA_MASTERING_LAB");	
	addSpaceSmall();
			
	// Mastering Lab Supervisor
	// JOHN DONNELLY
	addCenterDual( &"CREDIT_MASTERING_LAB_SUPERV", &"CREDIT_JOHN_DONNELLY");	
	addSpaceSmall();
	
	// Lead Mastering Lab Technician
	// SEAN KIM
	addCenterDual( &"CREDIT_LEAD_MASTERING_LAB_T", &"CREDIT_SEAN_KIM");	
	addSpaceSmall();
	
	// Senior Mastering Lab Technician
	// DANNY FENG			
	addCenterDual( &"CREDIT_SENIOR_MASTERING_LAB", &"CREDIT_DANNY_FENG_");								
	addSpace();
	
	// Mastering Lab Technicians
	addCenterHeading( &"CREDIT_MASTERING_LAB_TECHNI");	
	addSpaceSmall();		
	addCenterTriple( &"CREDIT_TYREE_DERAMUS", &"CREDIT_JOSE_HERNANDEZ", &"CREDIT_KAI_HSU");	
	addCenterTriple( &"CREDIT_RODRIGO_MAGANA", &"CREDIT_STEVEN_RODRIGUEZ", &"CREDIT_LEEJAY_RONQUILLO");
	addCenterTriple( &"CREDIT_ORBEL_SHAKHMALIAN", &"CREDIT_GARY_WASHINGTON", &"");
	addSpace();
}		

initATVICredits_qa4()
{
	// Customer Support
	addCenterHeading( &"CREDIT_CUSTOMER_SUPPORT");						
	addSpaceSmall();
	// Customer Support Managers
	// Gary Bolduc
	// Michael Hill
	addCenterDual( &"CREDIT_CUSTOMER_SUPPORT_MAN", &"CREDIT_GARY_BOLDUC");							
	addCenterName( &"CREDIT_MICHAEL_HILL");		
	addGap();	
}	

initATVICredits_end()
{
	// Manual designed by Ignited Minds, LLC
	addCenterDual( &"CREDIT_MANUAL_DESIGN", &"CREDIT_IGNITED_MINDS_LLC");	
	addGap();		
	
	
	// Packaging Design by Hamagami/Carroll, Inc.
	addCenterDual( &"CREDIT_PACKAGING_DESIGN_BY", &"CREDIT_RICHARD_KRIEGLER");	
	addCenterName( &"CREDIT_HAMAGAMI");												
	addGap();
	
	
	// Fonts licensed from Monotype 
	// T26
	addCenterDual( &"CREDIT_FONTS_LICENSED_FROM", &"CREDIT_MONOTYPE");					
	addCenterName( &"CREDIT_T26");		
	addGap();
	

	// Uses Bink Video. Copyright © 1997-2007 by RAD Game Tools, Inc.
	addCenterHeading( &"CREDIT_USES_BINK_VIDEO_COPYRIGHT" );
	addSpace();
		
	// Uses Miles Sound System. Copyright © 1991-2007 by RAD Game Tools, Inc.
	addCenterHeading( &"CREDIT_USES_MILES_SOUND_SYSTEM" );// PC and 360 only
	addGap();
	addGap();
	addGap();
	
	
	// The characters and events depicted in this game are fictitious.
	addCenterHeading( &"CREDIT_THE_CHARACTERS_AND_EVENTS1" );
	// Any similarity to actual persons, living or dead, is purely coincidental.
	addCenterHeading( &"CREDIT_THE_CHARACTERS_AND_EVENTS2" );

}