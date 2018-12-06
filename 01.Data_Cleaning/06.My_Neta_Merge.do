/*
10 July 2018

Project Name: West Bengal Election Analysis
File Objective in short

Author: PJ Paul

Purpose of the do file (in detail): 
1. Merge in the candidate data and winner data scraped from Myneta Website.

Steps:

User written packages:

User information: The user will need to change the Dropbox path once.

		==================================================================

*/


*---------------------------------------------------------------------------------------
*I Settings
*---------------------------------------------------------------------------------------
	clear
	postutil clear
	set more off 
	pause on

			
	global DB "/Users/paulpj//GoogleDrive/Personal_Projects/WestBengal_Elections_May2018"
	global data_myneta "${DB}/Raw_Data/MyNeta_Scrape"
	global processed_data "${DB}/Processed_Data"

	local can_2011 "${data_myneta}/candidates_2011.csv"
	local can_2016 "${data_myneta}/candidates_2016.csv"
	local const_2011 "${data_myneta}/const_2011.csv"
	local const_2016 "${data_myneta}/const_2016.csv"
	local winners_2011 "${data_myneta}/winners_2011.csv"
	local winners_2016 "${data_myneta}/winners_2016.csv"

	cd "${data_myneta}"

*---------------------------------------------------------------------------------------
* II. Merge  in the files for each year
*---------------------------------------------------------------------------------------
	* 2016 

		import delimited using `can_2016', varnames(1) clear // Load the candidate details
		clonevar candidate_name = name
		replace candidate_name = strtrim(candidate_name)
		clonevar party = partycode
		duplicates tag const_id candidate_name, gen(dupe)
		replace candidate_name = candidate_name + "_" + party if dupe != 0 & party == "IND"
		drop dupe
		tempfile can_2016
		save `can_2016'

		import delimited using `winners_2016', varnames(1) clear
		clonevar candidate_name = candidate
		replace candidate_name = strtrim(candidate_name)
		clonevar const_id = sno
		clonevar const_name = constituency
		replace const_name = strtrim(const_name)
		tempfile winners_2016
		keep const_name candidate_name
		save `winners_2016'

		import delimited using `const_2016', varnames(1) clear
		replace const_name = strtrim(const_name)
		tempfile const_2016
		save `const_2016'

		use `can_2016', clear 
		merge m:1 const_id using `const_2016'
		drop _merge
		replace const_name = strtrim(const_name)
		merge 1:1 const_name candidate_name using `winners_2016', gen(merge_winners)
		gen winner = merge_winners == 3
		drop merge_winners
		clonevar ac_const_id = const_id

		* Save the output file
		save "${processed_data}/04.MyNeta_Data/01.myneta_winner_crime_merged_2016.dta", replace 

	* 2011

		import delimited using `can_2011', varnames(1) clear // Load the candidate details
		clonevar candidate_name = name
		replace candidate_name = strtrim(candidate_name)
		clonevar party = partycode
		duplicates tag const_id candidate_name, gen(dupe)
		replace candidate_name = candidate_name + "_" + party if dupe != 0 & party == "IND"
		drop dupe
		tempfile can_2011
		save `can_2011'

		import delimited using `winners_2011', varnames(1) clear
		clonevar candidate_name = candidate
		replace candidate_name = strtrim(candidate_name)
		clonevar const_id = sno
		clonevar const_name = constituency
		replace const_name = strtrim(const_name)
		tempfile winners_2011
		keep const_name candidate_name
		save `winners_2011'

		import delimited using `const_2011', varnames(1) clear
		replace const_name = strtrim(const_name)
		tempfile const_2011
		save `const_2011'

		use `can_2011', clear 
		merge m:1 const_id using `const_2011'
		drop _merge
		replace const_name = strtrim(const_name)
		merge 1:1 const_name candidate_name using `winners_2011', gen(merge_winners)
		gen winner = merge_winners == 3
		drop merge_winners
		clonevar ac_const_id = const_id

		* Save the output file
		save "${processed_data}/04.MyNeta_Data/02.myneta_winner_crime_merged_2011.dta", replace 

