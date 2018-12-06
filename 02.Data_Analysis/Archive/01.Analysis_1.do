/*
 10 July 2018
 
 Project Name: West Bengal Election Analysis
 File Objective in short
 
 Author: PJ Paul
 
 Purpose of the do file (in detail): 
 
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

	***** 1. User Parameters *****
		* Paul				    1
		* [Name]		        2
		* [Name]				3
	***************************
			
	global DB "/Users/paulpj/GoogleDrive/Personal_Projects/WestBengal_Elections_May2018"
	global data_ward "${DB}/Data/Ward_Data_2013_2018"
	global data_ward_processed "${data_ward}/Processed_Data"
	global data_ac "${DB}/Data/Election_Data_AC_2011_2016"
	global data_ac_processed  "${data_ac}/Processed_Data"
	global data_myneta "${DB}/Data/MyNeta_Scrape"
	global data_myneta_processed "${data_myneta}/Processed_Data"

*---------------------------------------------------------------------------------------
* 2. Summarize ward level competition at AC level
*---------------------------------------------------------------------------------------
 	use ${data_ward_processed}/ward_ac_ls14_merged, clear
 	gen bjp_contest = bjp_2018 > 0
 	gen any_contest_2018 = total_2018 - aitc_2018 
 	replace any_contest = any_contest > 0 & total_2018 != .
	bysort constituency_no: egen mean_ward_bjp_comp = mean(bjp_contest) 
	bysort constituency_no: egen mean_ward_any_comp = mean(any_contest) 
	gen aitc_growth_1 = vote_share_percentage2014_AITC - vote_share_percentage2011_AITC 
	gen aitc_growth_2 = vote_share_percentage2016_AITC - vote_share_percentage2014_AITC
	gen bjp_growth_1 = vote_share_percentage2014_BJP - vote_share_percentage2011_BJP
	gen bjp_growth_2 = vote_share_percentage2016_BJP - vote_share_percentage2014_BJP
	duplicates drop constituency_no, force
	clonevar const_id = constituency_no
	keep const_id constituency_no aitc_growth_1 aitc_growth_2 bjp_growth_1 bjp_growth_2 ///
		vote_share_percentage* mean_ward_any_comp mean_ward_bjp_comp
	tempfile ac_level_vote_comp
	save `ac_level_vote_comp'
	export delimited using "${data_ac_processed}/ac_level_vote_comp", replace

*---------------------------------------------------------------------------------------
* 3. Summarise AC level candidate features and criminality.
*---------------------------------------------------------------------------------------
	use ${data_myneta_processed}/myneta_winner_crime_merged_2016, clear 
	bysort const_id: gen n_candidates = _N
	bysort const_id: egen n_any_criminals = total(criminalcases == "Yes")
	bysort const_id: egen n_serious_criminals = total(seriousipccounts > 0)
	drop if winner != 1
	gen aitc_winner = party == "AITC"
	gen bjp_winner = party == "BJP"
	gen winner_any_criminal = criminalcases == "Yes"
	gen winner_serious_criminal = seriousipccounts > 0
	gen aitc_winner_criminal = aitc_winner * winner_any_criminal 
	gen aitc_winner_serious_criminal = aitc_winner * winner_serious_criminal 
	keep const_id const_name year n_any_criminals n_candidates ///
		 n_serious_criminals winner_any_criminal winner_serious_criminal ///
		 bjp_winner aitc_winner aitc_winner_criminal aitc_winner_serious_criminal
	tempfile myneta_ac_summary
	save `myneta_ac_summary'
	save ${data_myneta_processed}/myneta_ac_summary, replace 

*---------------------------------------------------------------------------------------
* 4. Combine AC Level Vote summary and Myneta summary
*---------------------------------------------------------------------------------------
	use `ac_level_vote_comp', clear
	merge 1:1 const_id using `myneta_ac_summary'
	keep if _merge == 3

	reg mean_ward_any_comp aitc_winner aitc_winner_criminal aitc_winner_serious_criminal

*---------------------------------------------------------------------------------------
* 5. Ward-level analysis
*---------------------------------------------------------------------------------------
	use ${data_ward_processed}/ward_ac_ls14_merged, clear
	duplicates drop district block gp ward, force
 	gen bjp_contest = bjp_2018 > 0
 	gen any_contest_2018 = total_2018 - aitc_2018 
 	gen any_contest_2013 = total_2013 - aitc_2013
 	replace any_contest_2018 = any_contest_2018 > 0 & total_2018 != . 
 		// Set missing values of any_contest_2018 to zero
 	replace any_contest_2013 = any_contest_2013 > 0 & total_2013 != .
 		// Set missing values of any_contest_2013 to zero
 	gen aitc_growth_1 = vote_share_percentage2014_AITC - vote_share_percentage2011_AITC 
	gen aitc_growth_2 = vote_share_percentage2016_AITC - vote_share_percentage2014_AITC
	gen bjp_growth_1 = vote_share_percentage2014_BJP - vote_share_percentage2011_BJP
	gen bjp_growth_2 = vote_share_percentage2016_BJP - vote_share_percentage2014_BJP
 	clonevar const_id = constituency_no
 	egen cluster = group(district block gp)
 	merge m:1 const_id using `myneta_ac_summary', gen(merge_ward_myneta)
	keep if merge_ward_myneta == 3

	tabstat any_contest_2018, by(aitc_winner_criminal)
	xi: logistic any_contest_2018 aitc_winner_criminal winner_any_criminal aitc_winner ///
	 any_contest_2013  bjp_growth_1  bjp_growth_2 aitc_growth_1  aitc_growth_2 i.district , vce(cluster cluster)
	xi: areg any_contest_2018 aitc_winner_criminal winner_any_criminal aitc_winner ///
		 any_contest_2013  bjp_growth_1  bjp_growth_2 aitc_growth_1  aitc_growth_2, absorb(district ) vce(cluster cluster)

	xi: logistic any_contest_2018 aitc_winner_criminal winner_any_criminal aitc_winner ///
	 bjp_growth_1  bjp_growth_2 aitc_growth_1  aitc_growth_2 i.district , vce(cluster cluster)
	xi: areg any_contest_2018 aitc_winner_criminal winner_any_criminal aitc_winner ///
		bjp_growth_1  bjp_growth_2 aitc_growth_1  aitc_growth_2, absorb(district ) vce(cluster cluster)


