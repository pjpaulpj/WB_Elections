# Objective: Clean and merge the scraped data for the wards in West Bengal GPs
# Author: PJ Paul pj.paul@idinsight.org
# Date modified: 04 June 2018

# Table of Contents
# I. Settings
# II. Load the files
# III. Clean the ward data and merge them
# IV. Save and export the merged files


#I. Settings
import pandas as pd
import re
import os

## Define the directories
home_dir =
project_dir =
data_dir = 

#II. Load the files
os.chdir('/Users/apple/GoogleDrive/Personal_Projects/WestBengal_Elections_May2018/')

#III. Clean the data
       # Load the datasets
ward_2013 = pd.read_csv('Raw_Data/WB_CEO_Scrape/2013_Wards/2013_scraped_data.csv')
ward_2018 = pd.read_csv('Raw_Data/WB_CEO_Scrape//2018_Wards/2018_scraped_data.csv')

      #Drop the column with serial numbers, date, Status, EntryID
ward_2013 = ward_2013.drop(["Unnamed: 0","date", "Status", "EntryID"], axis = 1)
ward_2018 = ward_2018.drop(["Unnamed: 0","date", "Status", "EntryID"], axis = 1)

      # Rename the colum 'Seat' to ward
ward_2013 = ward_2013.rename(columns = {"Seat":"Ward"})
ward_2018 = ward_2018.rename(columns = {"Seat":"Ward"})

     # Verify and clean ward names
ward_2013.Ward.unique()  #Eyeball the ward names
ward_2018.Ward.unique()  #Eyeball the ward names 

      # Ward names look clean. There are a couple of 'TOTAL' values which need to be removed. Naming convention seems to be Roman Letters/Arabic Numbers . We'll extract the arabic numeral part alone.

      # Remove observations with 'TOTAL' values
ward_2013 = ward_2013[ward_2013['Ward'] != "TOTAL:"]
ward_2018 = ward_2018[ward_2018['Ward'] != "TOTAL:"]

     # Rename the ward with name  '--Select--/1'
ward_2013.Ward[ward_2013.Ward == '--Select--/1'] = 'I/1'

     # Confirm that sum of party columns = Total column
party_columns = ['AIFB', 'AITC', 'BJP', 'BSP', 'CPI', 'CPM', 'INC', 'NCP', 'RSP', 'SUCI', 'JD(U)', 'JD(S)', 'ML(KSC)', 'RJD', 'LJP', 'JMM', 'CPI(ML)LIB', 'IND']

ward_2013['Total_Check'] = ward_2013[party_columns].sum(axis = 1)
ward_2018['Total_Check'] = ward_2018[party_columns].sum(axis = 1)

total_check_2013 = ward_2013['TOTAL'] != ward_2013['Total_Check']
total_check_2018 = ward_2018['TOTAL'] != ward_2018['Total_Check']
#error_2018 = ward_2018[total_check_2018]

    # There are around 800 discrepancies in totals, most of which arise due to the party SP (WB) which is missing from the main roster of candidates. However, the TOTAL variable includes there candiates, and is thus safe to use for analysis.

    # Fill in missing TOTAL values
    
ward_2018.TOTAL.isnull.sum() # 3 missing values
       # Burdwan, Raina-I, Narugram, Ward Vi/6-- Correct Total = 1
       # Paschim Medinipur, Chandrakona-II,Basanchora, Ward XII/12 Correct Total= 1
       # Paschim Medinipur, Ghatal Dist, Dewanchat-II, Ward XIII/13 Correct Total = 2
       
ward_2018.TOTAL[ward_2018.TOTAL.isnull()] = ward_2018.Total_Check[ward_2018.TOTAL.isnull()]

#III. Merge the files
    # Prep files for merge. Change column names etc
ward_2013['Ref_Year'] = 2013
ward_2018['Ref_Year'] = 2018

   # Add year suffix to time specific variable names
   # Define some auxillary variables
time_specific_vars = [ 'AIFB', 'AITC', 'BJP', 'BSP', 'CPI', 'CPM', 'INC', 'NCP', 'RSP', 'SUCI', 'JD(U)', 'JD(S)', 'ML(KSC)', 'RJD', 'LJP', 'JMM', 'CPI(ML)LIB', 'IND', 'TOTAL', 'Ref_Year', 'Total_Check']
edited_vars_2013 = {col:str(col) + '_2013' for col in time_specific_vars}
edited_vars_2018 = {col:str(col) + '_2018' for col in time_specific_vars}
   # Run the rename command
ward_2013.rename(columns = edited_vars_2013, inplace = True)
ward_2018.rename(columns = edited_vars_2018, inplace = True)

  # Merge the files

merged_wards = pd.merge(ward_2013,ward_2018,on = ['District', 'Block', 'GP', 'Ward'], how = 'outer')
   # Might have to port this merge to R/ Stata for diagnostics

  # Export as csv
merged_wards.to_csv('Processed_Data/Ward_Data_2013_2018/merged_wards_2013_18.csv')
