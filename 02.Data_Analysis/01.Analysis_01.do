/*
 10 July 2018
 
 Project Name: West Bengal Election Analysis

 File Objective in short: Run a bunch of analyses on the data.
 
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
	global processed_data "${DB}/Processed_Data"
	global data_ward_processed "${data_ward}/Processed_Data"


*---------------------------------------------------------------------------------------
* 2. Data Quality Checks
*---------------------------------------------------------------------------------------
	use "${processed_data}/03.Election_Data/02.ward_ac11_16_ls14_merged.dta", clear
	misstable summarize total_2013 total_2018

	/* 
		                                              +------------------------------
	               |                                | Unique
	      Variable |     Obs=.     Obs>.     Obs<.  | values        Min         Max
	  -------------+--------------------------------+------------------------------
	    total_2013 |     2,585              43,883  |     32          1          60
	    total_2018 |    10,913              35,555  |     21          0          32
	  -----------------------------------------------------------------------------
		2585/46468 wards are missing from the 2013 Ward competition database
		10,913/ 46468 wards are missing from the 2018 Ward competition database.
	*/

*---------------------------------------------------------------------------------------
* 3. Address Missing Data
*---------------------------------------------------------------------------------------
	* 0. Generate Ancillary variables 

	gen missing_2013 = missing(total_2013)
	gen missing_2018 = missing(total_2018)

	bysort district block gp: gen ward_count = _N
	bysort district block gp: egen miss_ward_2013 = total(missing_2013)
	bysort district block gp: egen miss_ward_2018 = total(missing_2018)
	bysort district block gp: gen miss_ward_prop_2013 = miss_ward_2013/ward_count
	bysort district block gp: gen miss_ward_prop_2018 = miss_ward_2018/ward_count

	tempfile temp 
	save `temp'

	* 1. Drop all wards where one of 2013 or 2018 data is missing
	drop if missing_2013 | missing_2018
	count  // 32970
	tempfile drop_miss_ward
	save `drop_miss_ward'


	* 2. Drop all GPs where more than 10% of wards are missing in any one year
	use `temp', clear
	drop if miss_ward_prop_2013 > 0.1 | miss_ward_prop_2018 > 0.1
	count //31,864
	tempfile drop_miss_gp 
	save `drop_miss_gp'



*---------------------------------------------------------------------------------------
* 4. Summarize ward level competition at AC level
*---------------------------------------------------------------------------------------
	*foreach data in drop_miss_ward drop_miss_gp {}
	
 	use `drop_miss_gp', clear

 	* Generate variables relating to competition at ward level
 	foreach year in 2013 2018 {
	 	gen bjp_contest_`year' = bjp_`year' > 0
	 	gen aitc_contest_`year' = aitc_`year' > 0
	 	gen non_aitc_contest_`year' = total_`year' - aitc_`year' 
	 	replace non_aitc_contest_`year' = non_aitc_contest_`year' > 0 & total_`year' != .
		bysort constituency_no: egen mean_ward_bjp_comp_`year' = mean(bjp_contest_`year') 
		bysort constituency_no: egen mean_ward_non_aitc_comp_`year' = mean(non_aitc_contest_`year') 
 	}

 	 foreach year in 2013 2018 {
 	 	local ac_election_year = `year' - 2
	 	gen non_incumb_contest_`year' = 0
	 	replace non_incumb_contest_`year' = 1 if winner`ac_election_year' == "AIFB" & total_`year' - aifb_`year' > 0
	 	replace non_incumb_contest_`year' = 1 if winner`ac_election_year' == "AITC" & total_`year' - aitc_`year' > 0
	 	replace non_incumb_contest_`year' = 1 if winner`ac_election_year' == "BJP" & total_`year' - bjp_`year' > 0
	 	replace non_incumb_contest_`year' = 1 if winner`ac_election_year' == "CPI" & total_`year' - cpi_`year' > 0
	 	replace non_incumb_contest_`year' = 1 if winner`ac_election_year' == "CPM" & total_`year' - cpm_`year' > 0
	 	replace non_incumb_contest_`year' = 1 if winner`ac_election_year' == "INC" & total_`year' - inc_`year' > 0
	 	replace non_incumb_contest_`year' = 1 if winner`ac_election_year' == "RSP" & total_`year' - rsp_`year' > 0
	 	replace non_incumb_contest_`year' = 1 if total_`year'  > 1
	 		// Variable indicating competition from non-incumebnt parties at AC level
 	}


	* Calculate changes in vote-share for AITC, BJP, CPI, CPM, and INC
	 foreach party in AITC BJP CPI CPM INC {
 		gen `party'_growth_11_14 = vote_share_percentage2014_`party' - vote_share_percentage2011_`party'
 		gen `party'_growth_14_16 = vote_share_percentage2016_`party' - vote_share_percentage2014_`party'
 	}

 	tempfile ward_level_vote_comp
	save `ward_level_vote_comp'

	* Convert to AC level dataset
	duplicates drop constituency_no, force
	clonevar const_id = constituency_no
	keep const_id constituency_no *_growth_* ///
		vote_share_percentage* mean_ward_* non_incumb_contest* winner* d_winner*
	tempfile ac_level_vote_comp
	save `ac_level_vote_comp'

*---------------------------------------------------------------------------------------
* 5. Summarize AC level candidate features and criminality.
*---------------------------------------------------------------------------------------

	use "${processed_data}/03.Election_Data/02.ward_ac11_16_ls14_merged.dta", clear
	clonevar const_id = ac_constituency_no
	duplicates drop const_id, force
	keep const_id winner* d_winner*
	tempfile ac_ls_data
	save `ac_ls_data'

	use "${processed_data}/04.MyNeta_Data/03.myneta_winner_crime_clean_2016.dta", clear 
	tempfile myneta_2016 
	merge m:1 const_id using `ac_ls_data'
	drop _merge
	save `myneta_2016'

	use "${processed_data}/04.MyNeta_Data/04.myneta_winner_crime_clean_2011.dta", clear 
	tempfile myneta_2011
	merge m:1 const_id using `ac_ls_data'
	drop _merge
	save `myneta_2011'


	foreach year in 2011 2016 {
		use `myneta_`year''
		bysort const_id: gen n_candidates`year' = _N
		bysort const_id: egen n_any_criminals`year' = total(criminalcases == "Yes")
		bysort const_id: egen n_serious_criminals`year' = total(seriousipccounts > 0)
		bysort const_id: egen total_winners`year' = total(winner)
		drop v1 name age gender
		drop if winner != 1 & total_winners`year' != 0
		duplicates drop const_id if total_winners`year' == 0, force 
			// There are a few ACs where the MyNeta database does not contain details of the winning candidate.
		gen winner_party`year' = party if total_winners`year' != 0
		gen winner_any_criminal`year' = criminalcases == "Yes" if total_winners`year' != 0
		gen winner_serious_criminal`year' = seriousipccounts > 0 if total_winners`year' != 0
		keep const_id const_name year n_any_criminals`year' n_candidates`year' d_winner* ///
			 n_serious_criminals`year' winner_any_criminal`year' winner_serious_criminal`year' total_winners`year'
		tempfile myneta_ac_summary`year'
		save `myneta_ac_summary`year''
	}
	
	merge 1:1 const_id using `myneta_ac_summary2011'
	drop _merge

	tempfile myneta_ac_summary_2011_16
	save `myneta_ac_summary_2011_16'
	*save ${data_myneta_processed}/myneta_ac_summary, replace 

*---------------------------------------------------------------------------------------
* 6. Combine AC Level Vote summary and Myneta summary
*---------------------------------------------------------------------------------------

	use `ac_level_vote_comp', clear
	merge 1:1 const_id using `myneta_ac_summary_2011_16'
	keep if _merge == 3

	bysort winner_serious_criminal2016:tabstat non_incumb_contest_2018 , by(winner2016) stat(mean sd N)

*---------------------------------------------------------------------------------------
* 7. Ward-level analysis
*---------------------------------------------------------------------------------------

	use `ward_level_vote_comp', clear
	clonevar const_id = ac_constituency_no
	clonevar cluster = gp_id
 	merge m:1 const_id using `myneta_ac_summary_2011_16', gen(merge_ward_myneta)
	keep if merge_ward_myneta == 3
	duplicates drop district block gp ward, force
	tempfile ward_myneta_merge
	save `ward_myneta_merge'

	*1. Summarize Competition between 2013 and 2018 
		use `ward_level_vote_comp', clear
		duplicates drop district block gp ward, force
		keep district block gp ward aifb_2013-total_2013 aifb_2018-total_2018
		reshape long aifb aitc bjp bsp cpi cpm inc ncp rsp suci jdu jds mlksc rjd ljp jmm cpimllib ind total, ///
			 i(district block gp ward) j(year) string
		destring year, replace ignore("_")

			* Generate a matrix containing number of wards
		count if year == 2013
		local 2013_count = `r(N)'
		count if year == 2018
		local 2018_count = `r(N)'
		mat count_mat = [`2013_count', `2018_count']
		mat rownames count_mat = "N"

			* Generate a matrix with ward-level average competition for two years
		tabstat aifb-total, by(year) nototal save format(%9.3f)
		mat parties_2013 = r(Stat1)
		mat rownames parties_2013 = "% wards contesting 2013"
		mat parties_2013 = parties_2013'
		mat parties_2018 = r(Stat2)
		mat rownames parties_2018 = "% wards contesting 2018"
		mat parties_2018 = parties_2018'
		mat_capp joint_2013_18 : parties_2013 parties_2018, miss(.)
		mat joint_2013_18 = joint_2013_18\count_mat

			*Export to Excel.
		putexcel clear
		putexcel set WB_Results.xlsx, sheet("2013_18_Summary", replace) modify
		putexcel A1 = matrix(joint_2013_18), names nformat(number_d2)

	*2. Summarize link between incumbency, criminality, and ward-level competition
		


*---------------------------------------------------------------------------------------
* 8. Regression Analysis
*---------------------------------------------------------------------------------------
	

	table winner2016 winner_serious_criminal2016, c(mean non_incumb_contest_2018 sum d_winner2016)
	logistic c.non_incumb_contest_2018 i.d_winner2016 i.d_winner2016#i.winner_serious_criminal2016, vce(cluster cluster)

	areg c.non_incumb_contest_2018 i.d_winner2016  i.d_winner2011 i.d_winner2011#i.winner_serious_criminal2011 i.d_winner2016#i.winner_serious_criminal2016 c.non_incumb_contest_2013, absorb(district ) vce(cluster cluster)
	areg c.non_incumb_contest_2013 i.d_winner2011   i.d_winner2011#i.winner_serious_criminal2011 , absorb(district ) vce(cluster cluster)
	xi: logistic any_contest_2018 aitc_winner_criminal winner_any_criminal aitc_winner ///
	 bjp_growth_1  bjp_growth_2 aitc_growth_1  aitc_growth_2 i.district , vce(cluster cluster)
	xi: areg any_contest_2018 aitc_winner_criminal winner_any_criminal aitc_winner ///
		bjp_growth_1  bjp_growth_2 aitc_growth_1  aitc_growth_2, absorb(district ) vce(cluster cluster)


	foreach data in blah blah2 {
		dis "`data'"
	}



