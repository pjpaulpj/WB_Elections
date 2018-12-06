/*
12 June 2018

Project Name: West Bengal Election Analysis

File Name: merge_ward_census_village

Merge the ward level competition information against the census village
	data. The idea is to attach the census 

Author: PJ Paul

Purpose of the do file (in detail): The plan here is to merge the GP names from 
	the ECI portal against their census villages.

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
			
	global DB "/Users/apple//GoogleDrive/Personal_Projects/WestBengal_Elections_May2018"
	global data_ward "${DB}/Data/Ward_Data_2013_2018"
	global data_lg "${DB}/Data/LG_Directory_Data"

*---------------------------------------------------------------------------------------
* II. Load and clean the ward competition data
*---------------------------------------------------------------------------------------
	cd "${data_ward}"
	local ward_comp  "${data_ward}/merged_wards_2013_18.csv"
	local panch_data "${DB}/Data/Map_Extraced_Data/wb_census_geo_id.csv"

	import delimited using `ward_comp', clear
	drop v1
	order district block gp 
	replace district = lower(district)
	replace block = lower(block)
	replace block = subinstr(block," ","",.)
	replace gp = lower(gp)
	duplicates drop district block gp, force // Convert into GP level dataset.

	* Clean values of geographic variables in the ward data
		* Clean district names
		replace district = "24 paraganas north" if district == "north 24-parganas"
		replace district = "24 paraganas south" if district == "south 24-parganas"
		replace district = "coochbehar" if district == "cooch behar"
		replace district = "dinajpur dakshin" if district == "dakshin dinajpur"  
		replace district = "dinajpur uttar" if district == "uttar dinajpur" 
		replace district = "maldah" if district == "malda"
		replace district = "medinipur west" if district == "paschim medinipur"
		replace district = "medinipur east" if district == "purba medinipur"
		replace district = "alipurduar"  if ///
			(district == "jalpaiguri" & block == "kumar-gram")
		replace district = "alipurduar"  if ///
			(district == "jalpaiguri" & block == "kalchini")
		replace district = "alipurduar"  if ///
			(district == "jalpaiguri" & block == "alipurduar-i")
		replace district = "alipurduar"  if ///
			(district == "jalpaiguri" & block == "alipurduar-ii")
		replace district = "alipurduar"  if ///
			(district == "jalpaiguri" & block == "falakata")
		replace district = "alipurduar"  if ///
			(district == "jalpaiguri" & block == "madaihat-birpara")


			// Not present in this round of elections
		* Clean block names
		replace block = "garbetai" if block == "garbhetai" & district == "medinipur west" 
		replace block = "salbani" if block == "salboni" & district == "medinipur west"
		replace block = "kumargram" if block == "kumar-gram" & district == "alipurduar"
		replace block = "madarihat" if block == "madaihat-birpara" & district == "alipurduar"

	tempfile ward_gp_data 
	save `ward_gp_data'

	import delimited using "${data_lg}/gp_census_village_merge.csv", clear 
	gen district = lower(districtname)
	gen block = lower(subdistrictname)
	replace block = subinstr(block," ","",.)
	gen gp = lower(localbodynameinenglish)
	replace gp = subinstr(gp," ","",.)

	* Clean goeography names
		* Clean districts
		replace district = "burdwan" if district == "purba bardhaman" | district == "paschim bardhaman"
		drop if district == "kalimpong" | district == "darjeeling" // Separate elections for these two.
		replace district = "medinipur west" if district == "jhargram" 
			// Ward data does not reflect the separation of Jhagram from West Medinipur district
		* Clean block names
		replace block = "panskura-i" if block == "panskura" & district == "medinipur east"
		replace block = "tamluk-i" if block == "tamluk" & district == "medinipur east"
		replace block = "pataspur-i" if block == "potashpur-i" & district == "medinipur east"
		replace block = "pataspur-ii" if block == "potashpur-ii" & district == "medinipur east"
		replace block = "deshapran" if block == "deshopran" & district == "medinipur east"

		replace block = "hirbundh" if block == "hirbandh" & district == "bankura"
		replace block = "joypur" if block == "jaypur" & district == "bankura"
		replace block = "patrasayar" if block == "patrasayer" & district == "bankura"

	tempfile lb_gp_data
	save `lb_gp_data'

	use `ward_gp_data', clear 
	merge 1:m district block gp using `lb_gp_data'



	