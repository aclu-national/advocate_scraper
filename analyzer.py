import pandas as pd
from bs4 import BeautifulSoup
import requests
import time
articles = pd.read_csv("articles_by_year.csv")

start_time = time.time()
crime_soups = list()

for url in articles["Article"][1:10]:
  session = requests.Session()
  page = session.get(url)
  soup = BeautifulSoup(page.content, 'html.parser')
  crime_soups.append(soup)
end_time = time.time()

execution_time = end_time - start_time
execution_time

import concurrent.futures
import requests
from bs4 import BeautifulSoup

def fetch_page(url):
    session = requests.Session()
    page = session.get(url)
    soup = BeautifulSoup(page.content, 'html.parser')
    return soup

# Define the list of URLs
urls = articles["Article"][1:10]

# Initialize a list to store the results
crime_soups = []

# Define the maximum number of concurrent workers
MAX_WORKERS = 5  # You can adjust this based on your system resources

start_time = time.time()

# Use ThreadPoolExecutor for concurrency
with concurrent.futures.ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
    # Submit tasks for each URL
    future_to_url = {executor.submit(fetch_page, url): url for url in urls}

    # Retrieve results as they are completed
    for future in concurrent.futures.as_completed(future_to_url):
        url = future_to_url[future]
        try:
            soup = future.result()
            crime_soups.append(soup)
        except Exception as e:
            print(f"Error fetching URL {url}: {e}")
            
end_time = time.time()

execution_time = end_time - start_time

