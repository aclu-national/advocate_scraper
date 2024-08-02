import requests
import xml.etree.ElementTree as ET
import csv

base_url = "https://www.nola.com/tncms/sitemap/editorial.xml?year="

all_articles_by_year = {}

for year in range(2016, 2024):
    url = base_url + str(year)
    response = requests.get(url)
    xml_content = response.text
    root = ET.fromstring(xml_content)
    
    links = [element.text for element in root.findall('.//{http://www.sitemaps.org/schemas/sitemap/0.9}loc')]
    
    articles_year = []
    
    for link in links:
        response = requests.get(link)
        xml_content = response.text
        root = ET.fromstring(xml_content)
        articles_year.extend([element.text for element in root.findall('.//{http://www.sitemaps.org/schemas/sitemap/0.9}loc')])
    
    all_articles_by_year[year] = articles_year


with open('articles_by_year.csv', mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['Year', 'Article'])
    for year, articles in all_articles_by_year.items():
        for article in articles:
            writer.writerow([year, article])
