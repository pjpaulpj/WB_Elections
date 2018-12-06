/*
12 June 2018

Project Name: West Bengal Election Analysis

Merge in all the cells from the worksheet containing the Assembly Constituency-wise
break-up of votes in the 2014 Lok Sabha election.

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
	global data_ls_2014 "${DB}/Raw_Data/Election_Data_PC_2009_2014"
	global data_ac "${DB}/Raw_Data/Election_Data_AC_2011_2016"

*---------------------------------------------------------------------------------------
* II. Load and clean the Election Commission data
*---------------------------------------------------------------------------------------
	cd "${data_ls_2014}"
	local ec_data_file = "WB_LS_Results_AC_Level_2014.xlsx"
		// This excel sheet contains the OCRed results from the contents of the folder OCR_Source
		// Basically, the election commission had maintained the Asseembly Constituency level results
		// from the 2014 LS elections in PDF form. These PDFs were OCRed and saved into this excel sheet.

		// However, the PDF files only contain the names of candidates and not their party IDs. To recover party IDs
		// we merge the above excel file with the Lok Sabha dataset from TCPD.

		// What we finally end up with is the AC level data for the 2014 Lok Sabha election.

	local tcpd_file = "WB_LokSabha_2009_2014.csv"

	* Load and Clean the data from Election Commission
	tempfile wb_ls_ac_2014
	save `wb_ls_ac_2014', emptyok

	forvalues k = 1/42 {
		local sheet = "PC`k'"
		import excel using `ec_data_file',  sheet(`sheet') firstrow clear
		drop if Parliamentary_Constituency_No == . & Assembly_Constituency_No == .
		keep Parliamentary* Assembly* Candidate*
		replace Parliamentary_Constituency = Parliamentary_Constituency[1]
		replace Parliamentary_Constituency_No = Parliamentary_Constituency_No[1]
		reshape long Candidate_, ///
			 i(Parliamentary_Constituency Parliamentary_Constituency_No ///
			  Assembly_Constituency_Name Assembly_Constituency_No) ///
			 j(Candidate_No)
		gen Candidate_Raw = ""
		bysort Candidate_No (Assembly_Constituency_No): ///
			 replace Candidate_Raw = Candidate_[_N]
		drop if Assembly_Constituency_No == .
		drop Candidate_No
		rename Candidate_ Votes
		destring(Votes), replace
		append using `wb_ls_ac_2014' 
  		save `"`wb_ls_ac_2014'"', replace 
	}

	replace Candidate_Raw = ustrregexra(Candidate_Raw,"[\n\r\t]"," ")
	gen Candidate_Clean = lower(Candidate_Raw)
	drop if Candidate_Clean == ""

	* Clean candidate names to match the TCPD Dataset
		replace Candidate_Clean = "girindra nath barman" if Candidate_Clean == "girindra nath burman" & Parliamentary_Constituency_No ==1
		replace Candidate_Clean = "hem chandra barman" if Candidate_Clean == "hem chandra burman" & Parliamentary_Constituency_No ==1
		replace Candidate_Clean = "kamal krishna bairagi" if Candidate_Clean == "kamal krishna balragi" & Parliamentary_Constituency_No ==1
		replace Candidate_Clean = "nripen karjee" if Candidate_Clean == "niren karjee" & Parliamentary_Constituency_No ==1
		replace Candidate_Clean = "renuka sinha" if Candidate_Clean == "renuka singh" & Parliamentary_Constituency_No ==1
		replace Candidate_Clean = "birendra bara (oraon)" if Candidate_Clean == "birendra bara oraon" & Parliamentary_Constituency_No ==2
		replace Candidate_Clean = "dr. kapin ch. boro" if Candidate_Clean == "dr kapil ch boro" & Parliamentary_Constituency_No ==2
		replace Candidate_Clean = "paul dexion khariya" if Candidate_Clean == "paul dixon khariya" & Parliamentary_Constituency_No ==2
		replace Candidate_Clean = "kakali majumdar (roy)" if Candidate_Clean == "kakali majundar roy" & Parliamentary_Constituency_No ==4
		replace Candidate_Clean = "mahendra p. lama" if Candidate_Clean == "mahendra p lama" & Parliamentary_Constituency_No ==4
		replace Candidate_Clean = "s.s.ahluwalia" if Candidate_Clean == "ss ahluwalia" & Parliamentary_Constituency_No ==4
		replace Candidate_Clean = "saman pathak (suraj)" if Candidate_Clean == "suman pathak" & Parliamentary_Constituency_No ==4
		replace Candidate_Clean = "pabitra ranjan dasmunshi (satya)" if Candidate_Clean == "pabitra ranjand dasmunshi" & Parliamentary_Constituency_No ==5
		replace Candidate_Clean = "subrata adhikary" if Candidate_Clean == "subarta adhikary" & Parliamentary_Constituency_No ==5
		replace Candidate_Clean = "bimalendu sarkar (bimal)" if regexm(Candidate_Clean, "bimalendu sarkar") & Parliamentary_Constituency_No ==6
		replace Candidate_Clean = "biswapriya roy choudhury" if Candidate_Clean == "biswapriya roychoudhury" & Parliamentary_Constituency_No ==6
		replace Candidate_Clean = "manas chakraborty (ganesh)" if Candidate_Clean == "manas chakraborty" & Parliamentary_Constituency_No ==6
		replace Candidate_Clean = "om prakas mishra" if Candidate_Clean == "omprakas mishra" & Parliamentary_Constituency_No ==6
		replace Candidate_Clean = "bishnupada barman" if Candidate_Clean == "bishnupada narman" & Parliamentary_Constituency_No ==7
		replace Candidate_Clean = "imanuyel hemram (baidya)" if Candidate_Clean == "imanuyel hemram" & Parliamentary_Constituency_No ==7
		replace Candidate_Clean = "soumitra ray" if Candidate_Clean == "soumya ray" & Parliamentary_Constituency_No ==7
		replace Candidate_Clean = "subhash krishna goswami" if Candidate_Clean == "subash krishna goswami" & Parliamentary_Constituency_No ==7
		replace Candidate_Clean = "suren murmu" if Candidate_Clean == "sureen murmu" & Parliamentary_Constituency_No ==7
		replace Candidate_Clean = "md faruque hossain (sahityaratna)" if Candidate_Clean == "md faruque hossain" & Parliamentary_Constituency_No ==8
		replace Candidate_Clean = "monirul islam" if Candidate_Clean == "manirul islam" & Parliamentary_Constituency_No ==9
		replace Candidate_Clean = "md. ginnatulla sk" if Candidate_Clean == "md ginnatulla sk" & Parliamentary_Constituency_No ==9
		replace Candidate_Clean = "md. sahabuddin" if Candidate_Clean == "md shabuddin" & Parliamentary_Constituency_No ==9
		replace Candidate_Clean = "muzaffar hossain" if Candidate_Clean == "muzzaffar hossain" & Parliamentary_Constituency_No ==9
		replace Candidate_Clean = "kushadhwaj bala" if Candidate_Clean == "kushadwaj bala" & Parliamentary_Constituency_No ==10
		replace Candidate_Clean = "md. ezaruddin" if Candidate_Clean == "md ezaruddin" & Parliamentary_Constituency_No ==10
		replace Candidate_Clean = "jitendra nath halder" if Candidate_Clean == "jitendra nath haider" & Parliamentary_Constituency_No ==11
		replace Candidate_Clean = "kamarujjaman khandekar(bakul)" if Candidate_Clean == "kamarujjaman khandekar (bakul)" & Parliamentary_Constituency_No ==11
		replace Candidate_Clean = "md. najmul hoque" if Candidate_Clean == "md. najmul hogue" & Parliamentary_Constituency_No ==11
		replace Candidate_Clean = "molla jaforulla" if Candidate_Clean == "mo lla jaforulla" & Parliamentary_Constituency_No ==12
		replace Candidate_Clean = "nadiyar chand mondal" if Candidate_Clean == "nadivar chand mandal" & Parliamentary_Constituency_No ==13
		replace Candidate_Clean = "dr. mortoza hossain" if Candidate_Clean == "dr.mortoza hossain" & Parliamentary_Constituency_No ==17
		replace Candidate_Clean = "abanindra nath baidya" if Candidate_Clean == "abanindranath baidya" & Parliamentary_Constituency_No ==20
		replace Candidate_Clean = "rabindranath mistri" if Candidate_Clean == "rabindra nath mistri" & Parliamentary_Constituency_No ==20
		replace Candidate_Clean = "abhijit das (bobby)" if Candidate_Clean == "abhijit das" & Parliamentary_Constituency_No ==21
		replace Candidate_Clean = "dr. abul hasnat" if Candidate_Clean == "dr abdul hasnat" & Parliamentary_Constituency_No ==21
		replace Candidate_Clean = "habibur rahaman molla" if Candidate_Clean == "habibur rahman molla" & Parliamentary_Constituency_No ==21
		replace Candidate_Clean = "md. qamruzzaman qamar" if Candidate_Clean == "md qamruzzaman qamar" & Parliamentary_Constituency_No ==21
		replace Candidate_Clean = "dr. asok kumar samanta" if Candidate_Clean == "dr asok kumar samanta" & Parliamentary_Constituency_No ==22
		replace Candidate_Clean = "pintu sanpui" if Candidate_Clean == "pinto sanpui" & Parliamentary_Constituency_No ==22
		replace Candidate_Clean = "k. p. md. sharif" if Candidate_Clean == "k.p.md. sharif" & Parliamentary_Constituency_No ==23
		replace Candidate_Clean = "md. heshamuddin" if Candidate_Clean == "md.heshamuddin" & Parliamentary_Constituency_No ==23
		replace Candidate_Clean = "raveendran. t.p (ravi paloor)" if Candidate_Clean == "raveendran t. p (ravi paloor)" & Parliamentary_Constituency_No ==23
		replace Candidate_Clean = "syed md wasim raza" if Candidate_Clean == "syed md. wasim raza" & Parliamentary_Constituency_No ==23
		replace Candidate_Clean = "kali pada jana" if Candidate_Clean == "kalipada jana" & Parliamentary_Constituency_No ==24
		replace Candidate_Clean = "asit mitra" if Candidate_Clean == "aso mora" & Parliamentary_Constituency_No ==26
		replace Candidate_Clean = "dilip kumar hait" if Candidate_Clean == "diljp kumar hait" & Parliamentary_Constituency_No ==26
		replace Candidate_Clean = "abul qasem" if Candidate_Clean == "haul qasem" & Parliamentary_Constituency_No ==26
		replace Candidate_Clean = "hasan nawaj" if Candidate_Clean == "masan nannaj" & Parliamentary_Constituency_No ==26
		replace Candidate_Clean = "ramesh dhara" if Candidate_Clean == "ramesh ohara" & Parliamentary_Constituency_No ==26
		replace Candidate_Clean = "ranjit kishore mohanty" if Candidate_Clean == "ranjit kishore moharty" & Parliamentary_Constituency_No ==26
		replace Candidate_Clean = "sabir uddin molla" if Candidate_Clean == "sasir uddin molla" & Parliamentary_Constituency_No ==26
		replace Candidate_Clean = "susanta kumar dalui" if Candidate_Clean == "susanta kr. dalui" & Parliamentary_Constituency_No ==26
		replace Candidate_Clean = "bappi lahiri" if Candidate_Clean == "bappi lahari" & Parliamentary_Constituency_No ==27
		replace Candidate_Clean = "sekh ibrahim ali" if Candidate_Clean == "sekh ibrahim all" & Parliamentary_Constituency_No ==30
		replace Candidate_Clean = "ramkrisna sarkar" if Candidate_Clean == "ramkrishna sarkar" & Parliamentary_Constituency_No ==34
		replace Candidate_Clean = "ajit prasad mahata" if Candidate_Clean == "ajit prasad mahato" & Parliamentary_Constituency_No ==35
		replace Candidate_Clean = "dr. mriganka mahato" if Candidate_Clean == "dr mriganka mahato" & Parliamentary_Constituency_No ==35
		replace Candidate_Clean = "monbodh mahato" if Candidate_Clean == "manbodh mahato" & Parliamentary_Constituency_No ==35
		replace Candidate_Clean = "mihir kumar rajwar" if Candidate_Clean == "mihit kr rajwar" & Parliamentary_Constituency_No ==35
		replace Candidate_Clean = "narahari  mahato" if Candidate_Clean == "narahad mahato" & Parliamentary_Constituency_No ==35
		replace Candidate_Clean = "purna chandra tudu" if Candidate_Clean == "puna chandra tudu" & Parliamentary_Constituency_No ==35
		replace Candidate_Clean = "subarna  kumar" if Candidate_Clean == "subarna kumar" & Parliamentary_Constituency_No ==35
		replace Candidate_Clean = "tapan kumar mahato" if Candidate_Clean == "tapan kr mahato" & Parliamentary_Constituency_No ==35
		replace Candidate_Clean = "acharia basudeb" if Candidate_Clean == "acharia basudeb cpi(m)" & Parliamentary_Constituency_No ==36
		replace Candidate_Clean = "banerjee prabir" if Candidate_Clean == "banerjee prabir, jap" & Parliamentary_Constituency_No ==36
		replace Candidate_Clean = "binoy chowdhury" if Candidate_Clean == "binoy chowdhury, bsp" & Parliamentary_Constituency_No ==36
		replace Candidate_Clean = "gour chandra hembram" if Candidate_Clean == "gour chandra hembram, independent" & Parliamentary_Constituency_No ==36
		replace Candidate_Clean = "hulu khetrapal" if Candidate_Clean == "hulu khetrapal, bmp" & Parliamentary_Constituency_No ==36
		replace Candidate_Clean = "kabita singhababu" if Candidate_Clean == "kabita singhababu, suci (c)" & Parliamentary_Constituency_No ==36
		replace Candidate_Clean = "nilmadhab gupta" if Candidate_Clean == "nilmadhab gupta, inc" & Parliamentary_Constituency_No ==36
		replace Candidate_Clean = "panmani besra" if Candidate_Clean == "panmani besra, jdp" & Parliamentary_Constituency_No ==36
		replace Candidate_Clean = "paresh marandi" if Candidate_Clean == "paresh marandi, jmm" & Parliamentary_Constituency_No ==36
		replace Candidate_Clean = "shib sankar ghosh" if Candidate_Clean == "shib sankar ghosh, jvm(p)" & Parliamentary_Constituency_No ==36
		replace Candidate_Clean = "shyamal sikdar" if Candidate_Clean == "shyamal sikdar, independent" & Parliamentary_Constituency_No ==36
		replace Candidate_Clean = "sreemati  dev varma (moon moon sen)" if Candidate_Clean == "sreemati dev varma(moon moon sen), aitc" & Parliamentary_Constituency_No ==36
		replace Candidate_Clean = "subhas kumar sarkar" if Candidate_Clean == "subhas kumar sarkar, bjp" & Parliamentary_Constituency_No ==36
		replace Candidate_Clean = "sudhir kumar murmu" if Candidate_Clean == "sudhir kumar murmu, cpi(ml)(l)" & Parliamentary_Constituency_No ==36
		replace Candidate_Clean = "dinesh lohar" if Candidate_Clean == "dinesh lohar, independent" & Parliamentary_Constituency_No ==37
		replace Candidate_Clean = "jagadananda roy" if Candidate_Clean == "jagadananda roy, bsp" & Parliamentary_Constituency_No ==37
		replace Candidate_Clean = "jayanta mondal" if Candidate_Clean == "jayanta mondal, bjp" & Parliamentary_Constituency_No ==37
		replace Candidate_Clean = "joydeb bauri" if Candidate_Clean == "joy deb bauri, bmp" & Parliamentary_Constituency_No ==37
		replace Candidate_Clean = "khan saumitra" if Candidate_Clean == "khan saumitra aitc" & Parliamentary_Constituency_No ==37
		replace Candidate_Clean = "narayan chandra khan" if Candidate_Clean == "narayan chandra khan, inc" & Parliamentary_Constituency_No ==37
		replace Candidate_Clean = "sadananda mandal" if Candidate_Clean == "sadananda mandal, suci(c)" & Parliamentary_Constituency_No ==37
		replace Candidate_Clean = "susmita bauri" if Candidate_Clean == "susmita bauri, cpi(m)" & Parliamentary_Constituency_No ==37
		replace Candidate_Clean = "tarani roy" if Candidate_Clean == "tarani roy, independent" & Parliamentary_Constituency_No ==37
		replace Candidate_Clean = "chandana majhi" if Candidate_Clean == "chandan a majhi" & Parliamentary_Constituency_No ==38
		replace Candidate_Clean = "iswar chandra das" if Candidate_Clean == "chandra das" & Parliamentary_Constituency_No ==38
		replace Candidate_Clean = "kalicharan sardar" if Candidate_Clean == "kalichar an sardar sahana" & Parliamentary_Constituency_No ==38
		replace Candidate_Clean = "pejush kumar sahana" if Candidate_Clean == "pejush kumar" & Parliamentary_Constituency_No ==38
		replace Candidate_Clean = "dr. dhanapati das" if Candidate_Clean == "dr.dhanapati das" & Parliamentary_Constituency_No ==39
		replace Candidate_Clean = "sk. saidul haque" if Candidate_Clean == "sk. saidul hague" & Parliamentary_Constituency_No ==39
		replace Candidate_Clean = "atul chandra  bouri" if Candidate_Clean == "atul chandr a bour1" & Parliamentary_Constituency_No ==40
		replace Candidate_Clean = "babul supriya baral (babul supriyo)" if Candidate_Clean == "babul supriya baral (babul si ipri vol" & Parliamentary_Constituency_No ==40
		replace Candidate_Clean = "bansa gopal choudhury" if Candidate_Clean == "bansa copal choudhury" & Parliamentary_Constituency_No ==40
		replace Candidate_Clean = "buro murmu" if Candidate_Clean == "bubo murmu" & Parliamentary_Constituency_No ==40
		replace Candidate_Clean = "jarasandha sinha" if Candidate_Clean == "jarasan dha sinha" & Parliamentary_Constituency_No ==40
		replace Candidate_Clean = "md. reyazuddin" if Candidate_Clean == "md. reyazuddi n" & Parliamentary_Constituency_No ==40
		replace Candidate_Clean = "bijoy dolui" if Candidate_Clean == "buoy dolu1" & Parliamentary_Constituency_No ==41
		replace Candidate_Clean = "nurul islam" if Candidate_Clean == "nural islam" & Parliamentary_Constituency_No ==42

	* Save the cleaned election commission dataset
	save `wb_ls_ac_2014', replace

*---------------------------------------------------------------------------------------
* III. Load and Clean the TCPD Data
*---------------------------------------------------------------------------------------
	* Load and clean the TCPD data
	clear 
	import delimited using `tcpd_file', varnames(1)
	keep year constituency_no candidate party constituency_name
	keep if year == 2014 
	gen Parliamentary_Constituency_No = constituency_no
	gen Candidate_Clean = lower(candidate)
	replace Candidate_Clean = "subhas naskar 2" ///
		if year == 2014 & constituency_no == 19 ///
		& Candidate_Clean == "subhas naskar" &	party == "IND"
	drop if Candidate_Clean == "none of the above"
	tempfile tcpd_data_clean
	save `tcpd_data_clean'

*---------------------------------------------------------------------------------------
* IV. Merge and export the merged dataset
*---------------------------------------------------------------------------------------
	* Merge EC data with TCPD data to get party affiliations of candidates
	clear 
	use `wb_ls_ac_2014', clear
	merge m:1 Parliamentary_Constituency_No Candidate_Clean using `tcpd_data_clean'
	drop _merge
	gen Year = 2014
	save "${processed_data}/03.Election_Data/01.WB_2014_LokSabha_AC_Level_Clean.dta", nolabel replace 


