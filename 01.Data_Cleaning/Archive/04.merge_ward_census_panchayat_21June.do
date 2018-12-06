/*
12 June 2018

Project Name: West Bengal Election Analysis

File Name: merge_ward_census_village

Merge the ward level competition information against the pachayat names extracted from the shapefile.

Author: PJ Paul

Purpose of the do file (in detail): The plan here is to merge the GP names from 
	the ECI portal against their census villages.

Steps:

Before this file: 
1. The data scraped from the WB CEO website containing ward-level competition data
	 was earlier merged and saved into /Processed_Data/00.Ward_Data_2013_2018 folder.
2. We had used the wb_census_2011 shapefile to extract a listing of all panchayat names against the geo ids. This was saved into 
	WestBengal_Elections_May2018/Processed_Data/02.Map_Extracted_Data/wb_census_geo_id.csv'

This do file:
3. The above two files are converted into Gram Panchayat level datasets (from ward-level datasets), and are merged with each other.
4. The GPs which merge perfectly are saved into 
5. The GPs which do not merge are saved into ${data_hand_clean}/00.Ward_Data_Map_Data_Mismatch/non_match.csv"

--------------------------------------------------

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
	global processed_data "${DB}/Processed_Data"
	global data_hand_clean "${DB}/Processed_Data/Data_for_Hand_Clean"
	global data_ward "${DB}/Processed_Data/00.Ward_Data_2013_2018"
	global data_lg "${DB}/Data/LG_Directory_Data"

*---------------------------------------------------------------------------------------
* II. Load and clean the ward competition data
*---------------------------------------------------------------------------------------
	cd "${data_ward}"
	local ward_comp  "${data_ward}/merged_wards_2013_18.csv"
	local panch_data "${DB}/Processed_Data/02.Map_Extraced_Data/wb_census_geo_id.csv"

	* Clean the ward competition data
	import delimited using `ward_comp', clear
	drop v1
	order district block gp 
	gen raw_district = lower(district)
	gen raw_block = lower(block)
	replace raw_block = subinstr(raw_block," ","",.)
	gen raw_gp = lower(gp)

	replace district = lower(district)
	replace block = lower(block)
	replace block = subinstr(block," ","",.)
	replace gp = lower(gp)

		* Clean geographic names 
			drop if district == "darjeeling" // No GPs in Darjeeling.
			replace district = "north twenty four parganas" if district == "north 24-parganas"
			replace district = "south twenty four parganas" if district == "south 24-parganas"
			replace district = "puruliya" if district == "purulia"
			replace district = "maldah" if district == "malda"
			replace district = "koch bihar" if district == "cooch behar"
			replace district = "barddhaman" if district == "burdwan"
			replace district = "hugli" if district == "hooghly"
			replace district = "haora" if district == "howrah"

			replace block = "vishnupur" if block == "bishnupur" & district == "bankura"
			replace block = "hirbandh" if block == "hirbundh" & district == "bankura"
			replace block = "jaypur" if block == "joypur" & district == "bankura"
			replace block = "patrasayer" if block == "patrasayar" & district == "bankura"

			replace block = "faridpurdurgapur" if block == "durgapurfaridpur" & district == "barddhaman"
			replace block = "mangolkote" if block == "mongolkote" & district == "barddhaman"
			replace block = "manteswar" if block == "monteswar" & district == "barddhaman"
			replace block = "ondal" if block == "andal" & district == "barddhaman"

			replace block = "khoyrasol" if block == "khayrashol" & district == "birbhum"
			replace block = "bolpursriniketan" if block == "bolpur-sriniketan" & district == "birbhum"

			replace block = "bansihari" if block == "banshihari" & district == "dakshin dinajpur"
			replace block = "hilli" if block == "hili" & district == "dakshin dinajpur"
			replace block = "kushmundi" if block == "kushmandi" & district == "dakshin dinajpur"

			replace block = "ballyjagachha" if block == "bally-jagachha" & district == "haora"
			replace block = "jagatballavpur" if block == "jagatballabhpur" & district == "haora"

			replace block = "chinsurah-magra" if block == "chinsurah-mogra" & district == "hugli"
			replace block = "pursura" if block == "pursurah" & district == "hugli"
			replace block = "serampuruttarpara" if block == "srirampuruttarpara" & district == "hugli"
			replace block = "arambag" if block == "arambagh" & district == "hugli"

			replace block = "jalpaiguri" if block == "jalpaiguri(sadar)" & district == "jalpaiguri"
			replace block = "kumargram" if block == "kumar-gram" & district == "jalpaiguri"
			replace block = "madarihat" if block == "madaihat-birpara" & district == "jalpaiguri"

			replace block = "mekliganj" if block == "mekhliganj" & district == "koch bihar"

			replace block = "bamangola" if block == "bamongola" & district == "maldah"
			replace block = "chanchal-i" if block == "chanchol-i" & district == "maldah"
			replace block = "chanchal-ii" if block == "chanchol-ii" & district == "maldah"
			replace block = "maldah(old)" if block == "oldmalda" & district == "maldah"

			replace block = "murshidabadjiaganj" if block == "murshidabad-jiaganj" & district == "murshidabad"
			replace block = "nawda" if block == "nowda" & district == "murshidabad"
			replace block = "domkal" if block == "domkol" & district == "murshidabad"

			replace block = "chakdah" if block == "chakdaha" & district == "nadia"
			replace block = "krishnagar-i" if block == "krishnanagar-i" & district == "nadia"
			replace block = "krishnagar-ii" if block == "krishnanagar-ii" & district == "nadia"

			replace block = "bagda" if block == "bagdah" & district == "north twenty four parganas"
			replace block = "barrackpur-i" if block == "barrackpore-i" & district == "north twenty four parganas"
			replace block = "barrackpur-ii" if block == "barrackpore-ii" & district == "north twenty four parganas"

			replace block = "salbani" if block == "salboni" & district == "paschim medinipur"
			replace block = "midnapore" if block == "medinipursadar" & district == "paschim medinipur"
			replace block = "garbeta-i" if block == "garbheta-i" & district == "paschim medinipur"
			replace block = "garbeta-iii" if block == "garhbeta-iii" & district == "paschim medinipur"

			replace block = "panskura" if block == "panskura-i" & district == "purba medinipur"
			replace block = "tamluk" if block == "tamluk-i" & district == "purba medinipur"
			replace block = "potashpur-i" if block == "pataspur-i" & district == "purba medinipur"
			replace block = "potashpur-ii" if block == "pataspur-ii" & district == "purba medinipur"
			replace block = "deshopran(contai-ii)" if block == "deshapran" & district == "purba medinipur"
			replace block = "chandipur(nandigram-iii)" if block == "chandipur" & district == "purba medinipur"

			replace block = "bundwan" if block == "bandwan" & district == "puruliya"
			replace block = "jaipur" if block == "joypur" & district == "puruliya"

			replace block = "jaynagar-i" if block == "joynagar-i" & district == "south twenty four parganas"
			replace block = "jaynagar-ii" if block == "joynagar-ii" & district == "south twenty four parganas"
			replace block = "sagar" if block == "sagore" & district == "south twenty four parganas"
			replace block = "thakurpukurmahestola" if block == "thakurpurkurmaheshtala" & district == "south twenty four parganas"

		* Clean GP names
			replace gp = "andarthole" if district == "bankura" & block == "bankura-i" & gp == "andharthole"
			replace gp = "kalpathar" if district == "bankura" & block == "bankura-i" & gp == "kalapathar"
			replace gp = "beliatore" if district == "bankura" & block == "barjora" & gp == "beliator"
			replace gp = "hat-asuria" if district == "bankura" & block == "barjora" & gp == "hatasuria"
			replace gp = "maliara" if district == "bankura" & block == "barjora" & gp == "maliyara"
			replace gp = "pakhanna" if district == "bankura" & block == "barjora" & gp == "pokhonna"
			replace gp = "sahajora" if district == "bankura" & block == "barjora" & gp == "shaharjora"
			replace gp = "ghosergram" if district == "bankura" & block == "chhatna" & gp == "ghoshergram"
			replace gp = "metyala" if district == "bankura" & block == "chhatna" & gp == "meteyala"
			replace gp = "banashuria" if district == "bankura" & block == "gangajalghati" & gp == "banasuria"
			replace gp = "barshal" if district == "bankura" & block == "gangajalghati" & gp == "barashal"
			replace gp = "bhaktabundh" if district == "bankura" & block == "gangajalghati" & gp == "bhaktabandh"
			replace gp = "pirraboni" if district == "bankura" & block == "gangajalghati" & gp == "piraboni"
			replace gp = "molian" if district == "bankura" & block == "hirbandh" & gp == "maliyan"
			replace gp = "brajarajpur" if district == "bankura" & block == "indpur" & gp == "brojarajpur"
			replace gp = "gourbazar" if district == "bankura" & block == "indpur" & gp == "gaurbazar"
			replace gp = "hatagram" if district == "bankura" & block == "indpur" & gp == "hatgram"
			replace gp = "bheduasole" if district == "bankura" & block == "indpur" & gp == "veduasol"
			replace gp = "mongalpur" if district == "bankura" & block == "indus" & gp == "mangalpur"
			replace gp = "kuchiakole" if district == "bankura" & block == "jaypur" & gp == "kuchiakol"
			replace gp = "moynapur" if district == "bankura" & block == "jaypur" & gp == "maynapur"
			replace gp = "routhkhanda" if district == "bankura" & block == "jaypur" & gp == "rautkhanda"
			replace gp = "dhanara" if district == "bankura" & block == "khatra" & gp == "dhanarah"
			replace gp = "desra-koalpara" if district == "bankura" & block == "kotulpur" & gp == "deshrahkoyalpara"
			replace gp = "lowgram" if district == "bankura" & block == "kotulpur" & gp == "laugram"
			replace gp = "kushtore" if district == "bankura" & block == "mejhia" & gp == "kushtor"
			replace gp = "mejhia" if district == "bankura" & block == "mejhia" & gp == "mejia"
			replace gp = "mednipur" if district == "bankura" & block == "onda" & gp == "medinipur"
			replace gp = "santore" if district == "bankura" & block == "onda" & gp == "santor"
			replace gp = "birsingha" if district == "bankura" & block == "patrasayer" & gp == "beersingha"
			replace gp = "kushadwip" if district == "bankura" & block == "patrasayer" & gp == "kushdwip"
			replace gp = "patrasayer" if district == "bankura" & block == "patrasayer" & gp == "patrasayar"
			replace gp = "mandalkuli" if district == "bankura" & block == "raipur" & gp == "mondalkuli"
			replace gp = "routora" if district == "bankura" & block == "ranibundh" & gp == "rautora"
			replace gp = "bamuntore" if district == "bankura" & block == "saltora" & gp == "bamuntor"
			replace gp = "gargaria" if district == "bankura" & block == "sarenga" & gp == "gargarya"
			replace gp = "mandalgram" if district == "bankura" & block == "simlapal" & gp == "mondalgram"
			replace gp = "parsola" if district == "bankura" & block == "simlapal" & gp == "parswala"
			replace gp = "kochdihi" if district == "bankura" & block == "sonamukhi" & gp == "coochdihi"
			replace gp = "pearbera" if district == "bankura" & block == "sonamukhi" & gp == "piarbera"
			replace gp = "purba-nabasan" if district == "bankura" & block == "sonamukhi" & gp == "purbanabasan"
			replace gp = "satmouli" if district == "bankura" & block == "taldangra" & gp == "satmauli"
			replace gp = "ajodhya" if district == "bankura" & block == "vishnupur" & gp == "ayodhya"
			replace gp = "dwarika-" if district == "bankura" & block == "vishnupur" & gp == "dwarika-gossainpur"
			replace gp = "uliara" if district == "bankura" & block == "vishnupur" & gp == "uliyara"

			replace gp = "loapurkrishnara" if district == "barddhaman" & block == "galsi-i" & gp == "loapurkrishnarampur"
			replace gp = "jargram" if district == "barddhaman" & block == "jamalpur" & gp == "jaugram"
			replace gp = "trilokchandrapu" if district == "barddhaman" & block == "kanksa" & gp == "trilokchandrapur"
			replace gp = "sreekhanda" if district == "barddhaman" & block == "katwa-i" & gp == "srikhanda"
			replace gp = "murgram-" if district == "barddhaman" & block == "ketugram-i" & gp == "murgram-gopalpur"
			replace gp = "jitpur-" if district == "barddhaman" & block == "salanpur" & gp == "jitpur-uttarrampur"
			replace gp = "kulberiabolkund" if district == "barddhaman" & block == "salanpur" & gp == "kulberiabolkunda"
			replace gp = "loapurkrishnara" if district == "barddhaman" & block == "galsi-i" & gp == "loapurkrishnarampur"
			replace gp = "jargram" if district == "barddhaman" & block == "jamalpur" & gp == "jaugram"
			replace gp = "trilokchandrapu" if district == "barddhaman" & block == "kanksa" & gp == "trilokchandrapur"
			replace gp = "sreekhanda" if district == "barddhaman" & block == "katwa-i" & gp == "srikhanda"
			replace gp = "murgram-" if district == "barddhaman" & block == "ketugram-i" & gp == "murgram-gopalpur"
			replace gp = "jitpur-" if district == "barddhaman" & block == "salanpur" & gp == "jitpur-uttarrampur"
			replace gp = "kulberiabolkund" if district == "barddhaman" & block == "salanpur" & gp == "kulberiabolkunda"

			replace gp = "bahiri-" if district == "birbhum" & block == "bolpur-sriniketan" & gp == "bahiri-panchshowa"
			replace gp = "kankalitala" if district == "birbhum" & block == "bolpur-sriniketan" & gp == "kankalitala"
			replace gp = "kasba" if district == "birbhum" & block == "bolpur-sriniketan" & gp == "kasba"
			replace gp = "raipur-supur" if district == "birbhum" & block == "bolpur-sriniketan" & gp == "raipur-supur"
			replace gp = "ruppur" if district == "birbhum" & block == "bolpur-sriniketan" & gp == "ruppur"
			replace gp = "sarpalehana-" if district == "birbhum" & block == "bolpur-sriniketan" & gp == "sarpalehana-albandha"
			replace gp = "sattore" if district == "birbhum" & block == "bolpur-sriniketan" & gp == "sattor"
			replace gp = "sian-muluk" if district == "birbhum" & block == "bolpur-sriniketan" & gp == "sianmuluk"
			replace gp = "singhee" if district == "birbhum" & block == "bolpur-sriniketan" & gp == "singhee"
			replace gp = "laxmi-" if district == "birbhum" & block == "dubrajpur" & gp == "laxmi-narayanpur"

			replace gp = "chandidasnanoo" if district == "birbhum" & block == "nanoor" & gp == "chandidasnanoor"
			replace gp = "nawanagar-" if district == "birbhum" & block == "nanoor" & gp == "nawanagar-kadda"
			replace gp = "bhromorkol" if district == "birbhum" & block == "sainthia" & gp == "bhramorkole"
			replace gp = "horisara" if district == "birbhum" & block == "sainthia" & gp == "harisara"
			replace gp = "panrui" if district == "birbhum" & block == "sainthia" & gp == "pannui"
			replace gp = "sreenidhipur" if district == "birbhum" & block == "sainthia" & gp == "srinidhipur"

			replace gp = "tahangirpur" if district == "dakshin dinajpur" & block == "gangarampur" & gp == "jahangirpur"
			replace gp = "gokarna" if district == "dakshin dinajpur" & block == "harirampur" & gp == "gokarna-i"
			replace gp = "rampara" if district == "dakshin dinajpur" & block == "tapan" & gp == "rampara chenchra"
			replace gp = "binlakrishnabati" if district == "haora" & block == "amta-ii" & gp == "binla krishnabati"
			replace gp = "ghoraberia" if district == "haora" & block == "amta-ii" & gp == "ghoraberia chitnan"
			replace gp = "bantul-" if district == "haora" & block == "bagnan-ii" & gp == "bantul-baidyanathpur"
			replace gp = "mualyanbenapur" if district == "haora" & block == "bagnan-ii" & gp == "mualyan benapur"
			replace gp = "hantal" if district == "haora" & block == "jagatballavpur" & gp == "hantal anantabati"
			replace gp = "dakshinsankrail" if district == "haora" & block == "sankrail" & gp == "dakshin sankrail"
			replace gp = "bhabanipur" if district == "haora" & block == "udaynarayanpur" & gp == "bhabanipur bidhichandrapur"
			replace gp = "garbhabanipur-" if district == "haora" & block == "udaynarayanpur" & gp == "garbhabanipur-sonatala"
			replace gp = "perambuasahabaz" if district == "hugli" & block == "dhaniakhali" & gp == "perambuasahabazar"
			replace gp = "haripalkingkarba" if district == "hugli" & block == "haripal" & gp == "haripalkingkarbati"
			replace gp = "narayanpurbahir" if district == "hugli" & block == "haripal" & gp == "narayanpurbahirkhanda"
			replace gp = "paschimgopinath" if district == "hugli" & block == "haripal" & gp == "paschimgopinathpur"
			replace gp = "itachunakhanya" if district == "hugli" & block == "pandua" & gp == "itachunakhanyan"
			replace gp = "jamnagarmondal" if district == "hugli" & block == "pandua" & gp == "jamgram-mondalai"
			replace gp = "kshirkundi-" if district == "hugli" & block == "pandua" & gp == "kshirkundi-namajgram-niyasa"
			replace gp = "panchagara-" if district == "hugli" & block == "pandua" & gp == "panchagara-toregram"
			replace gp = "rameswarpur-" if district == "hugli" & block == "pandua" & gp == "rameswarpur-gopalnagar"
			replace gp = "bagdangachinam" if district == "hugli" & block == "singur" & gp == "bagdangachinamore"
			replace gp = "baruiparapaltaga" if district == "hugli" & block == "singur" & gp == "baruiparapaltagarh"
			replace gp = "kamarkundugopa" if district == "hugli" & block == "singur" & gp == "kamarkundugopalnagardaluigachha"
			replace gp = "naitamalpaharpu" if district == "hugli" & block == "tarakeswar" & gp == "naitamalpaharpur"
			replace gp = "purba" if district == "jalpaiguri" & block == "alipurduar-i" & gp == "purba kathalbari"
			replace gp = "chaporerpar-i" if district == "jalpaiguri" & block == "alipurduar-ii" & gp == "chaporer par-i"
			replace gp = "chaporerpar-ii" if district == "jalpaiguri" & block == "alipurduar-ii" & gp == "chaporer par-ii"
			replace gp = "baropatia" if district == "jalpaiguri" & block == "jalpaiguri" & gp == "baropatia nutanabos"
			replace gp = "boalmari-" if district == "jalpaiguri" & block == "jalpaiguri" & gp == "boalmari-nandanpur"
			replace gp = "kharija-berubari-" if district == "jalpaiguri" & block == "jalpaiguri" & gp == "kharija-barubari-i"
			replace gp = "nagarberubari" if district == "jalpaiguri" & block == "jalpaiguri" & gp == "nagar berubari"
			replace gp = "southberubari" if district == "jalpaiguri" & block == "jalpaiguri" & gp == "south berubari"
			replace gp = "dalsingpara" if district == "jalpaiguri" & block == "kalchini" & gp == "dalsing para"
			replace gp = "rajabhatkhawa" if district == "jalpaiguri" & block == "kalchini" & gp == "rajabhatkhaoa"
			replace gp = "newland" if district == "jalpaiguri" & block == "kumargram" & gp == "newland kumargram sankos"
			replace gp = "valkabarabisa-i" if district == "jalpaiguri" & block == "kumargram" & gp == "valka barabisa-i"
			replace gp = "valkabarabisa-ii" if district == "jalpaiguri" & block == "kumargram" & gp == "valka barabisa-ii"
			replace gp = "shishujhumra" if district == "jalpaiguri" & block == "madarihat" & gp == "shishujhmra"
			replace gp = "totopara" if district == "jalpaiguri" & block == "madarihat" & gp == "totopara ballalguri"
			replace gp = "matialihat" if district == "jalpaiguri" & block == "matiali" & gp == "matiali hat"
			replace gp = "falmari" if district == "koch bihar" & block == "coochbehar-i" & gp == "falimari"
			replace gp = "marichbari-" if district == "koch bihar" & block == "coochbehar-ii" & gp == "marichbari-kholta"
			replace gp = "takagachh-" if district == "koch bihar" & block == "coochbehar-ii" & gp == "takagachh-rajarhat"
			replace gp = "baraatiabari-i" if district == "koch bihar" & block == "dinhata-i" & gp == "bara atiabari-i"
			replace gp = "baraatiabari-ii" if district == "koch bihar" & block == "dinhata-i" & gp == "bara atiabari-ii"
			replace gp = "barasoulmari" if district == "koch bihar" & block == "dinhata-i" & gp == "boro soulmari"
			replace gp = "dinhatavill-i" if district == "koch bihar" & block == "dinhata-i" & gp == "dinhata gram-i"
			replace gp = "dinhatavill-ii" if district == "koch bihar" & block == "dinhata-i" & gp == "dinhata gram-ii"
			replace gp = "gobrachhara" if district == "koch bihar" & block == "dinhata-ii" & gp == "gobra chhara nayarhat"
			replace gp = "kishamat" if district == "koch bihar" & block == "dinhata-ii" & gp == "kishamat dasgram"
			replace gp = "dakshinbara" if district == "koch bihar" & block == "haldibari" & gp == "dakshin bara-haldibari"
			replace gp = "uttarbara" if district == "koch bihar" & block == "haldibari" & gp == "uttar bara haldibari"
			replace gp = "angarkata-" if district == "koch bihar" & block == "mathabhanga-ii" & gp == "angarkata-pardubi"
			replace gp = "bagdogra-" if district == "koch bihar" & block == "mekliganj" & gp == "bagdogra-fulkadabri"
			replace gp = "brahmottar-" if district == "koch bihar" & block == "sitai" & gp == "brahmottar-chatra"
			replace gp = "gobindapur-" if district == "maldah" & block == "bamangola" & gp == "gobindapur-maheshpur"
			replace gp = "dhangara-" if district == "maldah" & block == "chanchal-ii" & gp == "dhangara-bishanpur"
			replace gp = "harishchandrapu" if district == "maldah" & block == "harishchandrapur-i" & gp == "harishchandrapur"
			replace gp = "bamongram-" if district == "maldah" & block == "kaliachak-i" & gp == "bamongram-mosimpur"
			replace gp = "naoda-jadupur" if district == "maldah" & block == "kaliachak-i" & gp == "nawda-jadupur"
			replace gp = "uttarlakshmipur" if district == "maldah" & block == "kaliachak-ii" & gp == "uttar laxmipur"
			replace gp = "beernagar-i" if district == "maldah" & block == "kaliachak-iii" & gp == "birnagar-i"
			replace gp = "pardeonapur-" if district == "maldah" & block == "kaliachak-iii" & gp == "pardeonapur-sovapur"
			replace gp = "sahabajpur" if district == "maldah" & block == "kaliachak-iii" & gp == "sahabazpur"
			replace gp = "chowki" if district == "maldah" & block == "manikchak" & gp == "chowki mirdadpur"
			replace gp = "dakshin" if district == "maldah" & block == "manikchak" & gp == "dakshin chandipur"
			replace gp = "uttarchandipur" if district == "maldah" & block == "manikchak" & gp == "uttar chandipur"
			replace gp = "hingara" if district == "nadia" & block == "chakdah" & gp == "hingnara"
			replace gp = "betnagobindapur" if district == "nadia" & block == "hanskhali" & gp == "betna gobindapur"
			replace gp = "birohi-i" if district == "nadia" & block == "haringhata" & gp == "berohi-i"
			replace gp = "birohi-ii" if district == "nadia" & block == "haringhata" & gp == "berohi-ii"
			replace gp = "rajarmpur" if district == "nadia" & block == "kaliganj" & gp == "rajarmpur ghoraikhetra"
			replace gp = "hogolberia" if district == "nadia" & block == "karimpur-i" & gp == "hogolbaria"
			replace gp = "dighalkandi" if district == "nadia" & block == "karimpur-ii" & gp == "dighal kandi"
			replace gp = "bhajanghattungi" if district == "nadia" & block == "krishnaganj" & gp == "bhajanghat tungi"
			replace gp = "maitiarybanpur" if district == "nadia" & block == "krishnaganj" & gp == "maitiary banpur"
			replace gp = "taldahmajdia" if district == "nadia" & block == "krishnaganj" & gp == "taldah majdia"
			replace gp = "charmajdia" if district == "nadia" & block == "nabadwip" & gp == "charmajdia charbrahmanagar"
			replace gp = "fakirdanga" if district == "nadia" & block == "nabadwip" & gp == "fakirdanga gholpara"
			replace gp = "majdiapansila" if district == "nadia" & block == "nabadwip" & gp == "majdia pansila"
			replace gp = "nakashipara" if district == "nadia" & block == "nakashipara" & gp == "nakasipara"
			replace gp = "kalinarayanpur" if district == "nadia" & block == "ranaghat-i" & gp == "kalinarayanpur paharpur"
			replace gp = "nawpara" if district == "nadia" & block == "ranaghat-i" & gp == "nawpara masunda"
			replace gp = "jadurhati" if district == "north twenty four parganas" & block == "baduria" & gp == "jadurhati dakshin"
			replace gp = "jadurhatiuttar" if district == "north twenty four parganas" & block == "baduria" & gp == "jadurhati uttar"
			replace gp = "jasikatiatghara" if district == "north twenty four parganas" & block == "baduria" & gp == "jasikati atghara"
			replace gp = "nayabastiamilani" if district == "north twenty four parganas" & block == "baduria" & gp == "nayabastia milani"
			replace gp = "ramchandrapur" if district == "north twenty four parganas" & block == "baduria" & gp == "ramchandrapur uday"
			replace gp = "chhotojagulia" if district == "north twenty four parganas" & block == "barasat-i" & gp == "chhoto jagulia"
			replace gp = "paschim" if district == "north twenty four parganas" & block == "barasat-i" & gp == "paschim khilkapur"
			replace gp = "purbakhilkapur" if district == "north twenty four parganas" & block == "barasat-i" & gp == "purba khilkapur"
			replace gp = "chandigarh-" if district == "north twenty four parganas" & block == "barasat-ii" & gp == "chandigarh-rohanda"
			replace gp = "faltibeliaghata" if district == "north twenty four parganas" & block == "barasat-ii" & gp == "falti beliaghata"
			replace gp = "kemia" if district == "north twenty four parganas" & block == "barasat-ii" & gp == "kemia khamarpara"
			replace gp = "gochhaakharpur" if district == "north twenty four parganas" & block == "basirhat-i" & gp == "gochha akharpur"
			replace gp = "itindapanitore" if district == "north twenty four parganas" & block == "basirhat-i" & gp == "itinda panitore"
			replace gp = "nimdariakodalia" if district == "north twenty four parganas" & block == "basirhat-i" & gp == "nimdaria kodalia"
			replace gp = "sangrampur" if district == "north twenty four parganas" & block == "basirhat-i" & gp == "sangrampur shibhati"
			replace gp = "sankchura" if district == "north twenty four parganas" & block == "basirhat-i" & gp == "sankchura begundi"
			replace gp = "begumpurbibipur" if district == "north twenty four parganas" & block == "basirhat-ii" & gp == "begumpur bibipur"
			replace gp = "ghorarash" if district == "north twenty four parganas" & block == "basirhat-ii" & gp == "ghorarash kulingram"
			replace gp = "shrinagarmetia" if district == "north twenty four parganas" & block == "basirhat-ii" & gp == "shrinagar metia"
			replace gp = "dharampukuria" if district == "north twenty four parganas" & block == "bongaon" & gp == "dharam pukuria"
			replace gp = "hadipurjhikra-i" if district == "north twenty four parganas" & block == "deganga" & gp == "hadipur jhikra-i"
			replace gp = "hadipurjhikra-ii" if district == "north twenty four parganas" & block == "deganga" & gp == "hadipur jhikra-ii"
			replace gp = "machhlandapur-" if district == "north twenty four parganas" & block == "habra-i" & gp == "machhlandapur-ii"
			replace gp = "dighara" if district == "north twenty four parganas" & block == "habra-ii" & gp == "dighara malikberia"
			replace gp = "rajibpurbira" if district == "north twenty four parganas" & block == "habra-ii" & gp == "rajibpur bira"
			replace gp = "sonapukur" if district == "north twenty four parganas" & block == "haroa" & gp == "sonapukur sankarpur"
			replace gp = "barunhat" if district == "north twenty four parganas" & block == "hasnabad" & gp == "barunhat rameswarpur"
			replace gp = "sarberiaagarhati" if district == "north twenty four parganas" & block == "sandeshkhali-i" & gp == "sarberia agarhati"
			replace gp = "sehera" if district == "north twenty four parganas" & block == "sandeshkhali-i" & gp == "sehera radhnagar"
			replace gp = "balti" if district == "north twenty four parganas" & block == "swarupnagar" & gp == "balti nityanandakati"
			replace gp = "bankragokulpur" if district == "north twenty four parganas" & block == "swarupnagar" & gp == "bankra gokulpur"
			replace gp = "bitharihakimpur" if district == "north twenty four parganas" & block == "swarupnagar" & gp == "bithari hakimpur"
			replace gp = "sharapulnirman" if district == "north twenty four parganas" & block == "swarupnagar" & gp == "sharapul nirman"
			replace gp = "swarupnagar" if district == "north twenty four parganas" & block == "swarupnagar" & gp == "swarupnagar banglani"
			replace gp = "tepurmirzapur" if district == "north twenty four parganas" & block == "swarupnagar" & gp == "tepur mirzapur"
			replace gp = "dantan-ii" if district == "paschim medinipur" & block == "dantan-i" & gp == "datan-ii"
			replace gp = "kheputdakshniba" if district == "paschim medinipur" & block == "daspur-ii" & gp == "kheputdakshnibarh"
			replace gp = "jorakeudi-" if district == "paschim medinipur" & block == "keshpur" & gp == "jorakeudi-solidiha"
			replace gp = "benudia" if district == "purba medinipur" & block == "bhagawanpur-i" & gp == "benodia"
			replace gp = "bibhisanpur" if district == "purba medinipur" & block == "bhagawanpur-i" & gp == "bivisanpur"
			replace gp = "simulia" if district == "purba medinipur" & block == "bhagawanpur-i" & gp == "shimulia"
			replace gp = "chaukhali" if district == "purba medinipur" & block == "chandipur(nandigram-iii)" & gp == "chowkhli"
			replace gp = "nandapurbaragh" if district == "purba medinipur" & block == "chandipur(nandigram-iii)" & gp == "nandapurbaraghuni"
			replace gp = "osmanpur" if district == "purba medinipur" & block == "chandipur(nandigram-iii)" & gp == "usmanpur"
			replace gp = "mahisagot" if district == "purba medinipur" & block == "contai-i" & gp == "mahisagote"
			replace gp = "raipur-" if district == "purba medinipur" & block == "contai-i" & gp == "raipur-paschimbarh"
			replace gp = "bhajachaulia" if district == "purba medinipur" & block == "contai-iii" & gp == "brajachauli"
			replace gp = "sarada" if district == "purba medinipur" & block == "deshopran(contai-ii)" & gp == "sarda"
			replace gp = "rishibankimchand" if district == "purba medinipur" & block == "egra-i" & gp == "rishi bankimchandra"
			replace gp = "sahara" if district == "purba medinipur" & block == "egra-i" & gp == "saharha"
			replace gp = "bathuary" if district == "purba medinipur" & block == "egra-ii" & gp == "bathuari"
			replace gp = "vivekananda" if district == "purba medinipur" & block == "egra-ii" & gp == "bibekananda"
			replace gp = "sarbodaya" if district == "purba medinipur" & block == "egra-ii" & gp == "sarbaday"
			replace gp = "birbandar" if district == "purba medinipur" & block == "khejuri-i" & gp == "beerbandar"
			replace gp = "haria" if district == "purba medinipur" & block == "khejuri-i" & gp == "heria"
			replace gp = "lakshi" if district == "purba medinipur" & block == "khejuri-i" & gp == "lakshmi"
			replace gp = "baratala" if district == "purba medinipur" & block == "khejuri-ii" & gp == "bartala"
			replace gp = "nijkasba" if district == "purba medinipur" & block == "khejuri-ii" & gp == "niz kasba"
			replace gp = "khangdihi" if district == "purba medinipur" & block == "kolaghat" & gp == "khanyadihi"
			replace gp = "garhkamalpur" if district == "purba medinipur" & block == "mahisadal" & gp == "garh kamalpur"
			replace gp = "kismatnaikundi" if district == "purba medinipur" & block == "mahisadal" & gp == "kismat naikundi"
			replace gp = "lakshya-i" if district == "purba medinipur" & block == "mahisadal" & gp == "laksha-i"
			replace gp = "lakshya-ii" if district == "purba medinipur" & block == "mahisadal" & gp == "laksha-ii"
			replace gp = "satishsamanta" if district == "purba medinipur" & block == "mahisadal" & gp == "satish samanta"
			replace gp = "moyna-i" if district == "purba medinipur" & block == "moyna" & gp == "mayna-i"
			replace gp = "moyna-ii" if district == "purba medinipur" & block == "moyna" & gp == "mayna-ii"
			replace gp = "byabattarhatpas" if district == "purba medinipur" & block == "nandakumar" & gp == "byabattarhat paschim"
			replace gp = "byabattarhatpur" if district == "purba medinipur" & block == "nandakumar" & gp == "byabattarhat purba"
			replace gp = "dakshinnarikelda" if district == "purba medinipur" & block == "nandakumar" & gp == "dakshin narikelda"
			replace gp = "seoraberiajalpai-i" if district == "purba medinipur" & block == "nandakumar" & gp == "seoraberia jalpai-i"
			replace gp = "seoraberiajalpai-" if district == "purba medinipur" & block == "nandakumar" & gp == "seoraberia jalpai-ii"
			replace gp = "shitalpurpaschim" if district == "purba medinipur" & block == "nandakumar" & gp == "shitalpur paschim"
			replace gp = "kendumarijalpai" if district == "purba medinipur" & block == "nandigram-i" & gp == "kendumari jalpai"
			replace gp = "argoal" if district == "purba medinipur" & block == "potashpur-ii" & gp == "argoyal"
			replace gp = "southkhanda" if district == "purba medinipur" & block == "potashpur-ii" & gp == "south khanda"
			replace gp = "paldhui" if district == "purba medinipur" & block == "ramnagar-ii" & gp == "paldui"
			replace gp = "horkhali" if district == "purba medinipur" & block == "sutahata" & gp == "horekhali"
			replace gp = "bishnubar-i" if district == "purba medinipur" & block == "tamluk" & gp == "bishnubarh-i"
			replace gp = "bishnubar-ii" if district == "purba medinipur" & block == "tamluk" & gp == "bishnubarh-ii"
			replace gp = "uttarsonamui" if district == "purba medinipur" & block == "tamluk" & gp == "uttar sonamui"
			replace gp = "hadalda-" if district == "puruliya" & block == "kashipur" & gp == "hadalda-uparrah"
			replace gp = "rangamati-" if district == "puruliya" & block == "kashipur" & gp == "rangamati-ranjandih"
			replace gp = "baramasya-" if district == "puruliya" & block == "manbazar-i" & gp == "baramasya-ramnagar"
			replace gp = "chandra-" if district == "puruliya" & block == "manbazar-i" & gp == "chandra-pairachali"
			replace gp = "bargoria-" if district == "puruliya" & block == "manbazar-ii" & gp == "bargoria-jamtoria"
			replace gp = "udaypur-" if district == "puruliya" & block == "para" & gp == "udaypur-joynagar"
			replace gp = "bhandarpuara-" if district == "puruliya" & block == "purulia-i" & gp == "bhandarpuara-chipida"
			replace gp = "mangalda-" if district == "puruliya" & block == "raghunathpur-ii" & gp == "mangalda-mautore"
			replace gp = "ramchandrapur-" if district == "puruliya" & block == "santuri" & gp == "ramchandrapur-kotaldi"
			replace gp = "southgaria" if district == "south twenty four parganas" & block == "baruipur" & gp == "south garia"
			replace gp = "ramchandrakhal" if district == "south twenty four parganas" & block == "basanti" & gp == "ramchandrakhali"
			replace gp = "tarda" if district == "south twenty four parganas" & block == "bhangar-i" & gp == "tardaha"
			replace gp = "beenta-i" if district == "south twenty four parganas" & block == "bhangar-ii" & gp == "beonta-i"
			replace gp = "beenta-ii" if district == "south twenty four parganas" & block == "bhangar-ii" & gp == "beonta-ii"
			replace gp = "andharmanik" if district == "south twenty four parganas" & block == "bishnupur-i" & gp == "andhar manik"
			replace gp = "bhandaria" if district == "south twenty four parganas" & block == "bishnupur-i" & gp == "bhandaria kastekumari"
			replace gp = "dakshingauripur" if district == "south twenty four parganas" & block == "bishnupur-i" & gp == "dakshin gauripur chakdhir"
			replace gp = "paschim" if district == "south twenty four parganas" & block == "bishnupur-i" & gp == "paschim bishnupur"
			replace gp = "purbabishnupur" if district == "south twenty four parganas" & block == "bishnupur-i" & gp == "purba bishnupur"
			replace gp = "raskhali" if district == "south twenty four parganas" & block == "bishnupur-i" & gp == "rakhali"
			replace gp = "chak" if district == "south twenty four parganas" & block == "bishnupur-ii" & gp == "chak enayetnagar"
			replace gp = "gobindapur" if district == "south twenty four parganas" & block == "bishnupur-ii" & gp == "gobindapur kalicharanpur"
			replace gp = "patharberia" if district == "south twenty four parganas" & block == "bishnupur-ii" & gp == "patharberia jaychandipur"
			replace gp = "ramkrishnapur" if district == "south twenty four parganas" & block == "bishnupur-ii" & gp == "ramkrishnapur borhanpur"
			replace gp = "uttarraipur" if district == "south twenty four parganas" & block == "budgebudge-i" & gp == "uttar raipur"
			replace gp = "dongariaraipur" if district == "south twenty four parganas" & block == "budgebudge-ii" & gp == "dongaria raipur"
			replace gp = "gajapoyali" if district == "south twenty four parganas" & block == "budgebudge-ii" & gp == "gaja poyali"
			replace gp = "northbawali" if district == "south twenty four parganas" & block == "budgebudge-ii" & gp == "north baoyali"
			replace gp = "southbawali" if district == "south twenty four parganas" & block == "budgebudge-ii" & gp == "south baoyali"
			replace gp = "atharobanki" if district == "south twenty four parganas" & block == "canning-ii" & gp == "atharobandi"
			replace gp = "bolsiddhi" if district == "south twenty four parganas" & block == "diamondharbour-i" & gp == "bolsiddhi kalinagar"
			replace gp = "kanpur" if district == "south twenty four parganas" & block == "diamondharbour-i" & gp == "kanpur dhanaberia"
			replace gp = "bhaduraharidas" if district == "south twenty four parganas" & block == "diamondharbour-ii" & gp == "bhadura haridas"
			replace gp = "kamarpole" if district == "south twenty four parganas" & block == "diamondharbour-ii" & gp == "kamarpol"
			replace gp = "khorda" if district == "south twenty four parganas" & block == "diamondharbour-ii" & gp == "khordo"
			replace gp = "chhota" if district == "south twenty four parganas" & block == "gosaba" & gp == "chhota mollakhali"
			replace gp = "radhanagar-" if district == "south twenty four parganas" & block == "gosaba" & gp == "radhanagar-taranagar"
			replace gp = "dakshinbarasat" if district == "south twenty four parganas" & block == "jaynagar-i" & gp == "dakshin barasat"
			replace gp = "dhosa" if district == "south twenty four parganas" & block == "jaynagar-i" & gp == "dhosa chandaneswar"
			replace gp = "rajapurkorabeg" if district == "south twenty four parganas" & block == "jaynagar-i" & gp == "rajapur korabeg"
			replace gp = "uttardurgapur" if district == "south twenty four parganas" & block == "jaynagar-i" & gp == "uttar durgapur"
			replace gp = "pratapadityanag" if district == "south twenty four parganas" & block == "kakdwip" & gp == "pratapadityanagar"
			replace gp = "rishi" if district == "south twenty four parganas" & block == "kakdwip" & gp == "rishi bankimchandra"
			replace gp = "srisri" if district == "south twenty four parganas" & block == "kakdwip" & gp == "sri sri ramkrishna"
			replace gp = "swami" if district == "south twenty four parganas" & block == "kakdwip" & gp == "swami bibekananda"
			replace gp = "ramnagar-" if district == "south twenty four parganas" & block == "kulpi" & gp == "ramnagar-gazipur"
			replace gp = "deulbaridebipur" if district == "south twenty four parganas" & block == "kultali" & gp == "deulbari debipur"
			replace gp = "gurguria" if district == "south twenty four parganas" & block == "kultali" & gp == "gurguria bhubaneswari"
			replace gp = "kundakhali" if district == "south twenty four parganas" & block == "kultali" & gp == "kundakhali godabar"
			replace gp = "maipith" if district == "south twenty four parganas" & block == "kultali" & gp == "maipith baikunthapur"
			replace gp = "dhamuauttar" if district == "south twenty four parganas" & block == "magrahat-ii" & gp == "dhamua uttar"
			replace gp = "hotormorjada" if district == "south twenty four parganas" & block == "magrahat-ii" & gp == "hotor morjada"
			replace gp = "dakshin" if district == "south twenty four parganas" & block == "mandirbazar" & gp == "dakshin bishnupur"
			replace gp = "abad" if district == "south twenty four parganas" & block == "mathurapur-i" & gp == "abad bhagawanpur"
			replace gp = "dakshin" if district == "south twenty four parganas" & block == "mathurapur-i" & gp == "dakshin lakshminarayanpur"
			replace gp = "krishnachandrap" if district == "south twenty four parganas" & block == "mathurapur-i" & gp == "krishnachandrapur"
			replace gp = "uttar" if district == "south twenty four parganas" & block == "mathurapur-i" & gp == "uttar lakshminarayanpur"
			replace gp = "dighirpar-" if district == "south twenty four parganas" & block == "mathurapur-ii" & gp == "dighirpar-bakultala"
			replace gp = "dakshin" if district == "south twenty four parganas" & block == "patharpratima" & gp == "dakshin gangadharpur"
			replace gp = "gplot" if district == "south twenty four parganas" & block == "patharpratima" & gp == "g plot"
			replace gp = "laksmijanardanp" if district == "south twenty four parganas" & block == "patharpratima" & gp == "laksmijanardanpur"
			replace gp = "srinarayanpur" if district == "south twenty four parganas" & block == "patharpratima" & gp == "srinarayanpur purnachandrapur"
			replace gp = "rasapunja" if district == "south twenty four parganas" & block == "thakurpukurmahestola" & gp == "raspunja"
			replace gp = "bidyanandapur" if district == "uttar dinajpur" & block == "goalpokhar-ii" & gp == "baidyanandapur"
			replace gp = "chakulia" if district == "uttar dinajpur" & block == "goalpokhar-ii" & gp == "chakjullia"
			replace gp = "kamalgaon-sujali" if district == "uttar dinajpur" & block == "islampur" & gp == "kamalagaon-sujali"
			replace gp = "ramganj-ii" if district == "uttar dinajpur" & block == "islampur" & gp == "ranganj-ii"
			replace gp = "bahiri-" if district == "birbhum" & block == "bolpursriniketan" & gp == "bahiri-panchshowa"
			replace gp = "sarpalehana-" if district == "birbhum" & block == "bolpursriniketan" & gp == "sarpalehana-albandha"
			replace gp = "sattore" if district == "birbhum" & block == "bolpursriniketan" & gp == "sattor"
			replace gp = "sian-muluk" if district == "birbhum" & block == "bolpursriniketan" & gp == "sianmuluk"
			replace gp = "chaitanyapur-i" if district == "murshidabad" & block == "beldanga-i" & gp == "chaitannapur-i"
			replace gp = "chaitanyapur-ii" if district == "murshidabad" & block == "beldanga-i" & gp == "chaitannapur-ii"
			replace gp = "andulbaria-i" if district == "murshidabad" & block == "beldanga-ii" & gp == "andulberia-i"
			replace gp = "andulbaria-ii" if district == "murshidabad" & block == "beldanga-ii" & gp == "andulberia-ii"
			replace gp = "niyallispara" if district == "murshidabad" & block == "berhampore" & gp == "niyallispara goaljan"
			replace gp = "rangamati" if district == "murshidabad" & block == "berhampore" & gp == "rangamati chandpara"
			replace gp = "satui" if district == "murshidabad" & block == "berhampore" & gp == "satui chaurigachha"
			replace gp = "airmari" if district == "murshidabad" & block == "lalgola" & gp == "airmari krishnapur"
			replace gp = "barasimul" if district == "murshidabad" & block == "raghunathganj-ii" & gp == "barasimul dayarampur"
			replace gp = "tenkaraipur" if district == "murshidabad" & block == "raninagar-i" & gp == "tenkaraipur balumati"
			replace gp = "dogachhinapara" if district == "murshidabad" & block == "samserganj" & gp == "dogachhi napara"
			replace gp = "gajinagar" if district == "murshidabad" & block == "samserganj" & gp == "gajinagar malancha"
			replace gp = "rasakhowa-i" if district == "uttar dinajpur" & block == "karandighi" & gp == "rasakhow-i"
			replace gp = "rasakhowa-ii" if district == "uttar dinajpur" & block == "karandighi" & gp == "rasakhow-ii"

	* Convert to gp-level dataset
	duplicates drop district block gp, force // Convert into GP level dataset.
	keep district block gp raw_district raw_block raw_gp
	sort district block gp
	gen id = _n
	tempfile gp_level_comp
	save `gp_level_comp'

	* Clean the panchayat name data
	import delimited using `panch_data', clear
	drop if panch_name == "Urban Local Body"
	drop if panch_name == ""
	gen district = lower(district11)
	gen block = lower(sub_dist11)
	replace block = subinstr(block," ","",.)
	gen gp = lower(panch_name)
	replace gp = subinstr(gp," ","",.)

		* Clean geographies
		drop if district == "darjiling" // No GPs in Darjeeling.

	duplicates drop district block gp, force // Convert to gp-level dataset
	tempfile gp_level_map
	save `gp_level_map'

	* Merge the two gp-level datasets
	use `gp_level_comp', clear
	merge 1:1 district block gp using `gp_level_map'
	
		/*
		   Result                           # of obs.
	    -----------------------------------------
	    not matched                           336
	        from master                       193  (_merge==1)
	        from using                        143  (_merge==2)

	    matched                             2,990  (_merge==3)
	    -----------------------------------------
		*/

	preserve
	keep if _merge != 3
	sort district block gp _merge
	keep raw_district raw_block raw_gp district block gp panch_name sub_dist11 _merge
	export delimited using "${data_hand_clean}/00.Ward_Data_Map_Data_Mismatch/non_match.csv", replace
	restore
	keep if _merge == 3
	export delimited using "${processed_data}/03.Ward_Data_Map_Data_Match/EC_gp_Census_gp_Match.csv", replace
/*
	reclink district block gp using `gp_level_map', ///
	 required(district block) gen(myscore) idm(id) idu(westb_id) minscore(0.8)

