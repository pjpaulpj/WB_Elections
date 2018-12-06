/*
19 June 2018

Project Name: West Bengal Election Analysis

Name: LG Directory Clean

Author: PJ Paul

Purpose of the do file (in detail): Clean up the csv files downloaded from the lg directory
		website.

Steps:

User written packages:

User information: The user will need to change the GoogleDrive path once.

==================================================================

*/


*---------------------------------------------------------------------------------------
*I Settings
*---------------------------------------------------------------------------------------
	clear
	postutil clear
	set more off 
	pause on
		
	global DB "/Users/apple//GoogleDrive/Personal_Projects/WestBengal_Elections_May2018"
	global data_lg "${DB}/Data/LG_Directory_Data"

*---------------------------------------------------------------------------------------
* II. Load and clean the Local Govt Directory Data
*---------------------------------------------------------------------------------------
	cd "${data_lg}"
	local lb_census = "LocalbodyMappingtoCensusLandregionCode2018_06_03_18_54_54_698.csv"
	local lb_const = "parlimentConstituencyAndAssemblyConstituency2018_06_03_18_57_06_367.csv"
	local lb_pri = "priLbSpecificState.csv"

	import delimited using `lb_census', delimiter(";") clear
	tempfile lb_census_data
	save `lb_census_data'

	import delimited using `lb_const', delimiter(";") clear 
	tempfile lb_const_data
	save `lb_const_data'

	import delimited using `lb_pri', delimiter(";") clear 
	tempfile lb_pri_data
	save `lb_pri_data'
	keep if localbodytypename == "Village Panchayat"
	tempfile lb_gp_data
	save `lb_gp_data'

	use `lb_census_data', clear
	merge m:1 localbodycode using `lb_gp_data'
	keep if _merge == 3
	drop _merge
	replace villagecensuscode2011 = villagecode if villagecensuscode2011 == 0
	export delimited using "gp_census_village_merge.csv", replace

	/* gp_census_village_merge matches gps against their census village components. 

		In the gp_census_village_merge file most of the census villages are 
		uniquely mapped to a local body. In some cases, the local bodies are split
		across multiple census villages.

		. unique villagecensuscode2011 
		Number of unique values of villagecensuscode2011 is  40939
		Number of records is  41356

		. unique localbodycode 
		Number of unique values of localbodycode is  3339
		Number of records is  41356

		. unique localbodycode villagecensuscode2011 
		Number of unique values of localbodycode villagecensuscode2011 is  41356
		Number of records is  41356

	*/


	