/*
12 June 2018

Project Name: West Bengal Election Analysis

File Name: clean_assembly_constituency

Purpose: Clean the 2011,2016 assembly constituency data. Merge in the 2014 data

Author: PJ Paul

Purpose of the do file (in detail): 

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

	***** 1. User Parameters *****
		* Paul				    1
		* [Name]		        2
		* [Name]				3
	***************************
			
	global DB "/Users/paulpj/GoogleDrive/Personal_Projects/WestBengal_Elections_May2018"
	global processed_data "${DB}/Processed_Data"
	global data_hand_clean "${DB}/Processed_Data/Data_for_Hand_Clean"
	global data_ward "${DB}/Processed_Data/00.Ward_Data_2013_2018"
	global data_map "${DB}/Processed_Data/02.Map_Extracted_Data"
	global data_ac "${DB}/Raw_Data/Election_Data_AC_2011_2016"
	global data_myneta "${DB}/Data/MyNeta_Scrape"
	local ward_merged  "${data_ward}/merged_wards_2013_18.csv"

	cd "${processed_data}/03.Election_Data"



*---------------------------------------------------------------------------------------
* II. Load and clean the 2011-2016 AC election results dataset
*---------------------------------------------------------------------------------------
	
	import delimited using "${data_ac}/WB_Assembly_2011_2016.csv", clear

	keep if year == 2011 | year == 2016 // Drop all by-election results [#Pending]
	clonevar ac_constituency_no = constituency_no

	* Add variable identifying the incumbent party
	gen winner_joint = "."
	*gen winner_2011_AC = "."
	*gen winner_2016_AC = "."

	bysort ac_constituency_no: replace winner_joint = party if position == 1
	separate winner, by(year)

	* For 2011 
	bysort ac_constituency_no: replace winner_2011_AC = party if position == 1 & year == 2011
	sort ac_constituency_no year winner_2011_AC
	by 

	* For 2016
	bysort ac_constituency_no: replace winner_2016_AC = party if position == 1 & year == 2016
	bysort ac_constituency_no(winner_2016_AC): replace winner_2016_AC = winner_2016_AC[_N]

	* Retain needed variables and save dataset
	keep year ac_constituency_no party n_cand vote_share_percentage 
	tempfile ac_2011_16
	save `ac_2011_16'

	*year          month         assembly_no   party         n_cand        turnout_pe~e  vote_share~e  margin_per~e

*---------------------------------------------------------------------------------------
* III. Load and clean the '2014 LS election at AC level' dataset
*---------------------------------------------------------------------------------------

	use "${processed_data}/03.Election_Data/01.WB_2014_LokSabha_AC_Level_Clean.dta", clear 
	drop constituency_no constituency_name
	clonevar ac_constituency_no = Assembly_Constituency_No
	gen n_cand = .
	bysort ac_constituency_no: replace n_cand = _N
	bysort ac_constituency_no: egen total_vote = total(Votes)
	gen vote_share_percentage = (Votes*100)/total_vote
	keep year ac_constituency_no party n_cand vote_share_percentage 
	tempfile ls2014_ac_level
	save `ls2014_ac_level'

*---------------------------------------------------------------------------------------
* IV. Append the two files
*---------------------------------------------------------------------------------------
	use `ac_2011_16', clear
	append using `ls2014_ac_level'

	* Clean and format the appended files
	keep if party == "BJP" | party == "AITC" | ///
		 | party == "CPI" | party == "CPM" | party == "INC" 
	tostring(year), gen(str_year)
	gen party_year = str_year + "_" + party
	duplicates tag ac_constituency_no party_year, gen(party_year_dupe)
	drop if party_year_dupe // Come back and correct these
	*br if party_year_dupe
	drop year str_year party
	reshape wide n_cand vote_share, i(ac_constituency_no) j(party_year) string
	tempfile ac_11_14_16
	save `ac_11_14_16'
*---------------------------------------------------------------------------------------
* V. Merge in the ward-level data
*---------------------------------------------------------------------------------------
	use "${processed_data}/02.Ward_GP_Geo_AC_Merge/merged_ward_ac", clear
	merge m:1 constituency_no using `ac_11_14_16', gen(ward_ac_election_merge)
	/*
		   Result                           # of obs.
    -----------------------------------------
    not matched                            41
        from master                         0  (ward_ac_election_merge==1)
        from using                         41  (ward_ac_election_merge==2)

    matched                            46,468  (ward_ac_election_merge==3)
    -----------------------------------------

	*/
	keep if ward_ac_election_merge == 3
	save "${processed_data}/03.Election_Data/02.ward_ac11_16_ls14_merged.dta", replace





