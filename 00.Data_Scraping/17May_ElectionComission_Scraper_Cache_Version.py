#!/usr/bin/env python

import os
import sys
import signal
import time
import pandas as pd
from bs4 import BeautifulSoup
import pickle
import logging
import traceback
logging.basicConfig(level=logging.INFO)

# Import WebDriver components
from selenium import webdriver
from selenium.webdriver.support.ui import Select
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import StaleElementReferenceException
from selenium.common.exceptions import TimeoutException
from selenium.common.exceptions import NoSuchElementException


def sigint(signal, frame):
    sys.exit(0)

class Scraper(object):
    
    def __init__(self):
        self.url = 'http://www.wbsec.gov.in/Archive.htm'
        self.driver = webdriver.Firefox()
        #self.driver.implicitly_wait(100)

    #--- Hold-off function
    def hold_off(self, element_id, wait_period):
        
        '''
        Make the webdriver wait for element_id to appear with 
        a timeout limit of wait_period
        '''

        WebDriverWait(self.driver, wait_period).until(
            EC.presence_of_element_located((By.ID, element_id))
            )
        
    #----  District selection---------------------------------
    def get_district_select(self):
        path = '//select[@id="ddldistrict"]'
        WebDriverWait(self.driver, 20).until(
            EC.presence_of_element_located((By.ID, 'ddldistrict'))
            )
        district_select_elem = self.driver.find_element_by_xpath(path)
        district_select = Select(district_select_elem)
        return district_select

    def select_district_option(self, value):
        '''
        Select district value from dropdown. 
        Wait until the block dropdown has loaded before returning.
        '''
        
        path =  '//select[@id="ddlblock"]'
        block_select_elem = self.driver.find_element_by_xpath(path)

        district_select = self.get_district_select()
        district_select.select_by_value(value)

        WebDriverWait(self.driver, 20).until(
            EC.staleness_of(block_select_elem)
            )

        return self.get_district_select()

    #--- Block Selection ------------------------------------------------
    def get_block_select(self):
        path = '//select[@id="ddlblock"]'
        WebDriverWait(self.driver, 20).until(
            EC.presence_of_element_located((By.ID, 'ddlblock'))
            )
        block_select_elem = self.driver.find_element_by_xpath(path)
        block_select = Select(block_select_elem)
        return block_select

    def select_block_option(self, value):
        '''
        Select Block value from dropdown.
        Wait until GP value has loaded before returning.
        '''

        path = '//select[@id="ddlGP"]'
        
        WebDriverWait(self.driver, 20).until(
            EC.presence_of_element_located((By.ID, 'ddlGP'))
            )
        gp_select_elem = self.driver.find_element_by_xpath(path)

        block_select = self.get_block_select()
        block_select.select_by_value(value)

        WebDriverWait(self.driver, 20).until(
            EC.staleness_of(gp_select_elem)
            )

        return self.get_block_select()

    #-- GP Selection -------------------------------------------------------
    def get_gp_select(self):
        path = '//select[@id="ddlGP"]'
        WebDriverWait(self.driver, 40).until(
            EC.presence_of_element_located((By.ID, 'ddlGP'))
            )
        gp_select_elem = self.driver.find_element_by_xpath(path)
        gp_select = Select(gp_select_elem)
        return gp_select

    def select_gp_option(self, value, dowait = True):
        '''
        Select GP value from dropdown.
        Wait until EDate value has loaded before returning.
        '''

        path = '//select[@id="DropDownList1"]'
        
        WebDriverWait(self.driver, 200).until(
            EC.presence_of_element_located((By.ID, 'DropDownList1'))
            )
        
        date_select_elem = self.driver.find_element_by_xpath(path)

        gp_select = self.get_gp_select()
        gp_select.select_by_value(value)

        WebDriverWait(self.driver, 20).until(
            EC.staleness_of(date_select_elem)
            )


        return self.get_gp_select()

    #--Date Selection ---------------------------------------------------------
    def get_date_select(self):
        path = '//select[@id="DropDownList1"]'
        
        WebDriverWait(self.driver, 40).until(
            EC.presence_of_element_located((By.ID, 'DropDownList1'))
            )
        date_select_elem = self.driver.find_element_by_xpath(path)
        date_select = Select(date_select_elem)
        return date_select

    def select_date_option(self, value, dowait = False):
        '''
        Select date value from dropdown.
        Wait for table to get updated.
        '''
        date_select = self.get_date_select()
        date_select.select_by_value(value)
        
        path = '//select[@id="DropDownList1"]'
        table_elem = self.driver.find_element_by_xpath(path)
        time.sleep(2)
        return self.get_date_select()

    #-- Main Scraping code ---------------------------
    def load_page(self):
        self.driver.get(self.url)
        window_before = self.driver.window_handles[0]
        path = "//a[@href='../ContestingCandidates/ShowCandidatesGP.aspx']"
        self.driver.find_element_by_xpath(path).click()
        time.sleep(5)
        window_after = self.driver.window_handles[1]
        self.driver.switch_to_window(window_after)

        # Check that the page has fully loaded
        
        WebDriverWait(self.driver, 20).until(
            EC.presence_of_element_located((By.ID, 'ddldistrict'))
            )

    def scrape(self):
        def districts():
            district_select = self.get_district_select()
            district_select_option_values = [ 
                '%s' % o.get_attribute('value') 
                for o 
                in district_select.options][1:]

            for v in district_select_option_values:
                district_select = self.select_district_option(v)
                yield district_select.first_selected_option.text

        def blocks():
            block_select = self.get_block_select()
            block_select_option_values = [ 
                '%s' % o.get_attribute('value') 
                for o 
                in block_select.options][1:]

            for v in block_select_option_values:
                block_select = self.select_block_option(v)
                yield block_select.first_selected_option.text

        def gps():
            gp_select = self.get_gp_select()
            gp_select_option_values = [ 
                '%s' % o.get_attribute('value') 
                for o 
                in gp_select.options][1:]

            for v in gp_select_option_values:
                gp_select = self.select_gp_option(v)
                yield gp_select.first_selected_option.text

        def dates():
            date_select = self.get_date_select()
            date_select_option_values = [ 
                '%s' % o.get_attribute('value') 
                for o 
                in date_select.options][1:]

            for v in date_select_option_values:
                date_select = self.select_date_option(v)
                yield date_select.first_selected_option.text

        
        def table_extract(district, block, gp, date, entry_id):
            soup_level1 = BeautifulSoup(self.driver.page_source, 'lxml')
            table = soup_level1.find_all('table')[0]
            df = pd.read_html(str(table), skiprows = 7, header = 0)
            try:
                df = df[0]
                df = df.filter(regex = '^((?!Unnamed).)*$', axis = 1)
                   #Negative filtering on string'Unnamed'
                df['District'] = district
                df['Block'] = block
                df['GP'] = gp
                df['date'] = date
                df['Status'] = "Success"
                df['EntryID'] = entry_id
                datalist.append(df)
                #print(df)
            except IndexError:
                ef = pd.DataFrame()
                ef['District'] = district
                ef['Block'] = block
                ef['GP'] = gp
                ef['date'] = date
                ef['Status'] = "Fail"
                ef['EntryID'] = entry_id
                error_list.append(ef)
                #print(ef)

        def result_export(df, filename):
            try:
                result = pd.concat([pd.DataFrame(df[i]) for i in
                                    range(len(df))],ignore_index=True)
                            # if file does not exist write header 
                if not os.path.isfile(filename):
                   result.to_csv(filename,header ='column_names')
                   print("CSV Export overwrite")
                else: # else it exists so append without writing the header
                    result.to_csv(filename, mode = 'a',header=False)
                    print("CSV Export append")
            except:
                traceback.print_exc()
                pass

            
        def timer_fun(counter, start_time):
            elapsed_time = time.time() - start_time
            print("Elapsed seconds: {}".format(elapsed_time))
            print("Counter Iterations: {}".format(counter))
            percent_complete = (counter * 100)/3354 # 3354 GPs in West Bengal
            print("{:0.2f} % complete".format(percent_complete))
            unit_time = elapsed_time/counter
            print("Time per iteration: {:0.2f}".format(unit_time))

        def load_saved_data(): 
            try:
                saved_data = pd.read_csv("scraped_data.csv",
                     usecols = ['EntryID'], header = 0)
            except:
                saved_data = pd.DataFrame()
            return saved_data

        def get_dist_status(district):
            '''
            Load the district status pickled dictionary.
            Return the status of the district passed as argument
            '''
            try:
                dist_status = pickle.load(open("dist_status.pickle", "rb"))
                return dist_status[district]
            except:
                return  0

        def dist_status_write_update(district,status):
            '''
            After all entries in a district have been entered,
            Update the status of the district to 1.
            '''
            try:
                dist_status = pickle.load(open("dist_status.pickle", "rb"))
                dist_status[district] = status
                pickle.dump(dist_status, open("dist_status.pickle", "wb"))
            except (OSError, IOError) as e:
                dist_status = {}
                dist_status[district] = status
                pickle.dump(dist_status, open("dist_status.pickle", "wb"))

        def get_block_status(district, block):
            '''
            Load the district-block status pickled dataframe.
            Return the status of the district-block passed as argument
            '''
            try:
                block_status = pickle.load(open("block_status.pickle", "rb"))
                block_key = district + "-" + block
                return block_status[block_key]
            except:
                return  0

        def block_status_write_update(district,block, status):
            '''
            After all entries in a district have been entered,
            Update the status of the district to 1.
            '''
            try:
                block_status = pickle.load(open("block_status.pickle", "rb"))
                block_key = district + "-" + block
                block_status[block_key] = status
                pickle.dump(block_status, open("block_status.pickle", "wb"))
            except (OSError, IOError) as e:
                block_status = {}
                block_key = district + "-" + block
                block_status[block_key] = status
                pickle.dump(block_status, open("block_status.pickle", "wb"))

        # Call the scraping functions
        
        # Initialize scraping parameters
        datalist = []
        error_list = []
        saved_data = load_saved_data()

        # Launch the scraping run 
        self.load_page()
        start_time = time.time()
        counter = 0

        for district in districts():
            dist_status_get = get_dist_status(district)
            if dist_status_get == 1: 
                print("District:: {} exists fully. Skipping....".format(district))
                continue
            else:
                dist_status_write_update(district,0)
                for block in blocks():
                    block_status_get = get_block_status(district, block)
                    if block_status_get == 1: 
                        print("Block {} in District {} exists fully. Skipping...."
                            .format(block, district))
                        continue
                    if district + "-" + block == "Cooch Behar-MATHABHANGA-II":
                        print("Skipping problem GP in block")
                        block_status_write_update(district,block,1)
                        continue
                        # Comment this if block out out before hitting the issue with UNISHBISHA
                    else:
                        block_status_write_update(district,block, 0)
                        for gp in gps():
                            for date in dates():
                                # Define the counter and ID for each GP/Date combo
                                counter += 1
                                entry_id = district + '-' + block + '-' + gp + '-' + date
                                # Check if GP ID already present, if so skip it
                                if entry_id in saved_data.values:
                                    print("{} exists. Skipped....".format(entry_id))
                                    continue
                                # If EntryID not present, we proceed with the trailing code
                                # Perform scraping on the extracted tables
                                table_extract(district, block, gp, date, entry_id) 
                                print(["Data Added"] + [entry_id])
                                # Export data and run counter after 100 runs
                                if counter % 10  == 0: #Comment this out out at the end to get the last bunch of rows.
                                    result_export(datalist,'2013_scraped_data.csv')
                                    datalist = []
                                    print("Data exported......")
                                    timer_fun(counter, start_time)
                                    if len(error_list) > 0:
                                        result_export(error_list, '2013_error_list.csv')
                                        error_list = []

                        block_status_write_update(district,block,1)
                        print("Block {} in District {} completed....."
                            .format(block, district))
                dist_status_write_update(district,1)
                print("District:: {} completed".format(district))

        try:
            result_export(datalist,'2013_scraped_data.csv')
            # Export all remaining rows even if counter value < 10.
        except:
            pass 
        print("Scraping successfully completed.")
        print("Well Done!")
        time.sleep(5) #Pause for 5 seconds 
        self.driver.quit()
        sys.exit()
                                                 
                        

        #self.driver.quit()
                        
if __name__ == '__main__':
    signal.signal(signal.SIGINT, sigint)
    while True:
        try:
            scraper = Scraper()
            scraper.scrape()
        except Exception as ex:
            logging.info("Caught exception {}".format(ex))
            print(ex)
            traceback.print_exc()
            scraper.driver.quit()


            
        
        
        
        
