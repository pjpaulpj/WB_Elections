-- # /*
-- # 12 June 2018

-- # Project Name: West Bengal Election Analysis

-- # File Name: merge_census_village_AC_map

-- # Objective: Merge the Census villages to extract the assembly constituencies they fall under.

-- # Author: PJ Paul

-- # Purpose of the file (in detail): 

-- # Steps:

-- # User written packages:

-- # User information: The user will need to change the GoogleDrive path once.

-- # ==================================================================

-- # */

--- To run this file, cd into the folder where this file is stored, enter psql and then run i.map_data_extraction.sql
--- cd "/Users/apple/GoogleDrive/Personal_Projects/WestBengal_Elections_May2018/Scripts/01.Data_Cleaning"
--- i.map_data_extraction.sql

\c wb_map_db

-- 0. Extract Panchayat names
CREATE TEMP VIEW v1 AS 
	select westb_id, panch_name, sub_dist11, district11, state_ut, census2011, level_11, name_11
	from wb_census_2011;
\copy (select * from v1 ) TO '/Users/apple/GoogleDrive/Personal_Projects/WestBengal_Elections_May2018/Processed_Data/01.Map_Extracted_Data/wb_census_geo_id.csv' CSV HEADER

-- 1. Spatial join census villages and Assembly constituencies on centroid of census village

SELECT AddGeometryColumn ('wb_census_2011','census_centroid',4326,'POINT',2);
UPDATE wb_census_2011 SET census_centroid = ST_Centroid(wb_census_2011.geom);

CREATE TABLE village_ac_map AS
SELECT census.westb_id, census.panch_name, census.sub_dist11, 
		census.district11, census.state_ut, census.census2011,
		census.level_11, census.name_11, 
		ac_map.wb_id, ac_map.ac_no, ac_map.ac_name
FROM wb_census_2011 AS census, wb_ac_map AS ac_map 
WHERE ST_Contains(ac_map.geom, census.census_centroid);

\copy (select * from village_ac_map) TO '/Users/apple/GoogleDrive/Personal_Projects/WestBengal_Elections_May2018/Processed_Data/01.Map_Extracted_Data/census_village_centroid_ac_match.csv' CSV HEADER

-- 2. Spatial join census villages and Assembly constituencies on area of overlap of census village
CREATE TABLE village_area_ac_map AS
SELECT DISTINCT ON (census.westb_id) 
	census.westb_id, census.panch_name, census.sub_dist11, census.district11,
	ac_map.wb_id, ac_map.ac_no, ac_map.ac_name
FROM 
    wb_census_2011 AS census, wb_ac_map AS ac_map 
WHERE ST_Intersects(ac_map.geom, census.geom)
ORDER BY census.westb_id, ST_Area(ST_Intersection(ac_map.geom, census.geom)) DESC;

\copy (select * from village_area_ac_map) TO '/Users/apple/GoogleDrive/Personal_Projects/WestBengal_Elections_May2018/Processed_Data/01.Map_Extracted_Data/census_village_area_ac_match.csv' CSV HEADER

