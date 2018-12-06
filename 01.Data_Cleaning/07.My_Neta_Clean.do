/*
10 July 2018

Project Name: West Bengal Election Analysis
File Objective in short

Author: PJ Paul

Purpose of the do file (in detail): 
1. Clean the data. collected and merged from MyNeta

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

*---------------------------------------------------------------------------------------
* II. Clean and save the files for each year
*---------------------------------------------------------------------------------------
	local j = 3
	local k = 1
	forvalues x = 2016(-5)2011 {
		use "${processed_data}/04.MyNeta_Data/0`k'.myneta_winner_crime_merged_`x'.dta", replace 
		split totalassets, parse("~") limit(1) gen(clean_total_assets)
		split totalliabilities , parse("~") limit(1) gen(clean_total_liab)

		ds clean_total* 
		foreach var in `r(varlist)'{
			destring `var', replace ignore(",")
		}

		gen clean_net_assets = clean_total_assets1 - clean_total_liab1
		save "${processed_data}/04.MyNeta_Data/0`j'.myneta_winner_crime_clean_`x'.dta"
		local k = `k' + 1
		local j = `j' + 1
	}


	

