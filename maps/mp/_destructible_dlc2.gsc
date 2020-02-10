main()
{
	level.func[ "precacheMpAnim" ] = ::precacheMpAnim;
	level.func[ "scriptModelPlayAnim" ] = ::scriptModelPlayAnim;
	level.func[ "scriptModelClearAnim" ] = ::scriptModelClearAnim;
	common_scripts\_destructible_dlc2::main();
}