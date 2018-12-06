##!/usr/bin/env python


# Section 1: Settings
import os
from urllib.request import urlopen
from bs4 import BeautifulSoup as bs
import re
import pandas as pd


# Section 2: Helper Functions

#beautiful soup
def soup_url(url):
    page = urlopen(url)
    soup = bs(page, "lxml")
    return soup


# Section 3: Define main scraper functions

# Scrape Constituency Listing

def const_id_listing(year):
    url_const = "http://www.myneta.info/westbengal{:d}/".format(year)
    soup_const = soup_url(url_const)
    table = soup_const.find_all('table')[2]

    # Specify regular expression to extract constituency ID
    re_const = re.compile(r'=([0-9]+)$')

    #Scrape constituency IDs
    const_table = []
    for div in table.findAll('div',attrs={'class':'items'}):
        href = div.find('a')['href']
        const_name = div.find('a').contents[0]    
        const_id = int(re_const.findall(href)[0])
        const_table.append((const_id, const_name))

    const_df = pd.DataFrame(const_table, columns=('Const_ID', 'Const_Name'))

    const_df = const_df.sort_values(by = 'Const_ID')

    return const_df
    

# Scrape Candidate Comparison Chart

def cand_compare(year,id,listname):
    url = "http://www.myneta.info/westbengal{:d}/comparisonchart.php?constituency_id={:d}".format(year, id)
    soup_compare = soup_url(url)
    comp_table =  soup_compare.find_all('table')[0]
    df = pd.read_html(str(comp_table),  header = 0)
    df = df[0]
    df['Const_ID'] = id
    df['Year'] = year
    listname.append(df)

# Scrape winners

def const_winner(year):
    url = "http://www.myneta.info/westbengal{:d}/index.php?action=summary&subAction=winner_analyzed".format(year)
    soup_winner = soup_url(url)
    comp_table =  soup_winner.find_all('table')[2]
    df = pd.read_html(str(comp_table),skiprows=3,  header = 0)
    df = df[0]
    df['Year'] = year
    return df


# Section 4: Initialize and run scraper functions
    
const_2011 =  const_id_listing(2011)
const_2016 =  const_id_listing(2016)

candidates_2011 = []
for id in const_2011['Const_ID']:
    cand_compare(2011,id,candidates_2011)
    print("2011 Const ID {} completed.".format(id))

    
candidates_2016 = []
for id in const_2016['Const_ID']:
    cand_compare(2016,id,candidates_2016)
    print("2016 Const ID {} completed.".format(id))


winners_2011 = const_winner(2011)
winners_2016 = const_winner(2016)


# Section 5: Export dfs to csv
dir_path = "/Users/apple/GoogleDrive/Personal_Projects/WestBengal_Elections_May2018/Data/MyNeta_Scrape/"
os.chdir(dir_path)

def result_export(df, filename):
    '''
    Function to concatenate multiple lists into a common Pandas df
    '''
    
    result = pd.concat([pd.DataFrame(df[i]) for i in
                            range(len(df))],ignore_index=True)
    result.to_csv(filename,header ='column_names')

# Export constituency codes
const_2011.to_csv('const_2011.csv')
const_2016.to_csv('const_2016.csv')

# Export Candidate comparison charts
result_export(candidates_2011, 'candidates_2011.csv')
result_export(candidates_2016, 'candidates_2016.csv')

#Export winner details
winners_2011.to_csv('winners_2011.csv')
winners_2016.to_csv('winners_2016.csv')


