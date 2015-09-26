# -*- coding: utf-8 -*-
"""
Created on Sun Sep 20 13:28:15 2015

@author: Michael Crocco
"""

# Import libraries
import urllib
import urllib2
import numpy as np
import pandas as pd
from pandas import DataFrame
import os
import time,sys
os.chdir('d:/Power')

def get_page_content(page):  ## does not read entire page, try "local" version
#    print 1
#    print page
    u = urllib2.urlopen(page)
#    print 2
    html = u.read()
#    print 3
    u.close()
    return html


    
def list_links(page):
    result = []
    search_string = '<h3>Aggregated Price and Demand Data - Historical</h3'
    start_point = page.find(search_string)
    page = page[start_point:]
    while True:
        url, endpos = get_next_link(page)
        if url:
            url = 'http://www.aemo.com.au' + url
            result.append(url)
            page = page[endpos:]
            if url[-4:] == '2015':
#               print result                
                break
        else:
#            print result
            break
    return result
    
def get_next_link(page):
    start_link = page.find('a href=')#, start_point)
    if start_link == -1:
        return None, 0
    start_quote = page.find('"', start_link)
    end_quote = page.find('"', start_quote+1)
    link = page[start_quote+1:end_quote]
#    print link
    pointer = link.find('#')
#    print pointer
    if pointer != -1:
        link = link[:pointer]
    return link, end_quote
    
# download files which appear on sub_pages
def get_download_list(sub_page):
    result = []
    search_string = '<table class="infotable"'
    start_point = sub_page.find(search_string)
    sub_page = sub_page[start_point:]
#    print sub_page
    while True:
        url, endpos = get_next_file(sub_page)
        if url:
            if len(url) > 5:
                result.append(url)
            
            sub_page = sub_page[endpos:]
        else:
            break
    return result
    
def get_next_file(page):
    end_quote = page.find('.csv')
    if end_quote == -1:
        return None, 0
    end_quote += len('.csv')
#    print 'end ' + str(end_quote)
    if end_quote == -1:
        return None, 0
    start_quote = page.rfind('"', 0, end_quote)
#    print 'start ' + str(start_quote)
    
    url = page[start_quote+1:end_quote]

#    print url
    return url, end_quote
    
# script the process
#url = "http://www.aemo.com.au/Electricity/Data/Price-and-Demand/Aggregated-Price-and-Demand-Data-Files"
start_time = time.time()
url = 'file:///d:/Power/Top-Page_Short.htm'
top_page = get_page_content(url)
#print top_page[0:1000]
sub_page_list = list_links(top_page)

# cut down the sub_page_list
sub_page_list = list(set(sub_page_list))
print sub_page_list
#print sub_page_list
#print type(sub_page_list)
download_list = []
for page in sub_page_list:
#    print page#    page = 'http://www.aemo.com.au' + page
    sub_page_content = get_page_content(page)
#    print sub_page_content[0:1000]
    sub_page_list = get_download_list(sub_page_content)
    download_list.append(sub_page_list)
# Flatten the list of lists
download_list = sum(download_list,[])
# ****Download the files****
directory = 'download'
if not os.path.exists(directory):
    os.makedirs(directory)
print download_list[0]

for file_link in download_list:
    file_name = file_link.split('/')[-1]
    print type(file_link)
    print file_link
    print file_name
    if not os.path.exists(file_name):
        u = urllib2.urlopen(file_link)
        f = open(file_name,'wb')
        f.write(u.read())
        u.close
        f.close
end_time = time.time()
minutes = str(int(end_time - start_time) / 60)
seconds = str((end_time - start_time) % 60)
print "Total time to read/write ", str(len(download_list)), \
      " files: ", minutes, " min, ", seconds[:5], " sec"

