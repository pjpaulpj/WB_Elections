-- # /*
-- # 25 June 2018

-- # Project Name: West Bengal Election Analysis

-- # File Name: map_db_setup

-- # Objective: Create a POSTGIS spatial database for WB census village map 
-- #				and Assembly Constituency Map

-- # Author: PJ Paul

-- # Purpose of the do file (in detail): 

-- # Steps:

-- # User written packages:

-- # User information: The user will need to change the GoogleDrive path once.

-- # ==================================================================

-- # */

-- # If you have postgres installed, run psql on the terminal, and copy-paste the following commands.
-- or cd into the 01.Data_Cleaning folder, then run i.map_db.sql
-- cd "/Users/apple/GoogleDrive/Personal_Projects/WestBengal_Elections_May2018/Scripts/01.Data_Cleaning"


-- 1. Initialize the database
DROP DATABASE wb_map_db;
CREATE DATABASE wb_map_db;
\c wb_map_db
CREATE EXTENSION postgis;

-- 2. Import WB Census Map 
\cd /Users/apple/GoogleDrive/Personal_Projects/WestBengal_Elections_May2018/Maps/WEST_BENGAL_TOWN_2011
\! shp2pgsql -s 4326 WEST_BENGAL_TOWN_2011.shp wb_census_2011 | psql -h localhost -d wb_map_db

-- 3. Import WB Assembly Constituency Map 
\cd /Users/apple/GoogleDrive/Personal_Projects/WestBengal_Elections_May2018/Maps/WB_AC_Maps
\! shp2pgsql -s 4326 nyu_2451_34382.shp wb_ac_map | psql -h localhost -d wb_map_db

-- 4. Create indices for the above two map tables
CREATE INDEX census_2011_gix ON wb_census_2011 USING GIST (geom);
VACUUM ANALYZE wb_census_2011;

CREATE INDEX wb_ac_gix ON wb_ac_map USING GIST (geom);
VACUUM ANALYZE wb_ac_map;

