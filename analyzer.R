library(tidyverse)
library(janitor)
library(rvest)
library(htm2txt)
library(purrr)


df <- read_csv("articles_by_year.csv") %>%
  clean_names()

news_categories <- df %>%
  filter(str_detect(article, "https://www.nola.com/news")) %>%
  mutate(
    stem = str_extract(article, "(?<=news/)[^/]+")
  ) %>%
  tabyl(stem) %>%
  arrange(desc(n)) %>%
  filter(n > 500) %>%
  pull(stem)

df <- df %>%
  filter(str_detect(article, "https://www.nola.com/news")) %>%
  mutate(
    stem = str_extract(article, "(?<=news/)[^/]+"),
    category = ifelse(stem %in% news_categories, stem, "other")
  ) %>%
  select(-stem)

df %>%
  filter(str_detect(article, "https://www.nola.com/news")) %>%
  nrow()

df %>%
  filter(str_detect(article, "https://www.nola.com/news"),
         category == "crime_police") %>%
  nrow()
  
  
df %>%  
  tabyl(year, category)


df %>%
  filter(str_detect(article, "https://www.nola.com/news")) %>%
  mutate(
    pd_or_crime = str_detect(article, "murder")
  ) %>%
  tabyl(year, pd_or_crime)

df %>%
  mutate(title = )

df2 <- df %>%
  filter(category == "crime_police") %>%
  mutate(article_title = str_replace_all(str_replace(str_replace(article, ".*crime_police/", ""), "/article.*", ""), "-", " ")
  )

html <- read_html(df2$article[156])

html_text(html_nodes(html, 'p,h1,h2,h3'))

article_list <- df2$article[10:100]
article_list

html_list <- map(article_list, read_html, encoding = "windows-874")



html_text(html_nodes(html_list[[1]], 'p,h1,h2,h3'))



















# Load required libraries
library(httr)
library(rvest)
library(purrr)

# Function to scrape HTML content with error handling and timeouts
safe_read_html <- function(url) {
  tryCatch({
    # Add headers to mimic a browser request
    headers <- c(
      "User-Agent" = sample(c(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:93.0) Gecko/20100101 Firefox/93.0",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:92.0) Gecko/20100101 Firefox/92.0"
      ), 1)
    )
    
    # Set a timeout for the request (in seconds)
    timeout <- 10
    
    # Make the request
    response <- httr::GET(url, httr::add_headers(headers), timeout(timeout))
    
    # Check if the request was successful
    if (httr::http_error(response)) {
      stop(paste("HTTP error", httr::status_code(response)))
    }
    
    # Read the HTML content
    html_content <- rvest::read_html(httr::content(response, as = "text", encoding = "UTF-8"))
    
    return(html_content)
  }, error = function(e) {
    message("Error occurred: ", conditionMessage(e))
    return(NULL)
  })
}

# Check if 'df2' exists and it contains the 'article' column
if (exists("df2") && "article" %in% names(df2)) {
  # Extract articles from df2 if it has the article column
  article_list <- df2$article
  
  # Check if article_list is not empty
  if (length(article_list) > 0) {
    # Scrape HTML content from each article URL
    html_list <- map(article_list, safe_read_html)
    
    # Filter out any NULL values (where scraping failed)
    html_list <- html_list[!sapply(html_list, is.null)]
    
    # Check if any HTML content was successfully scraped
    if (length(html_list) > 0) {
      # Your further processing code here
      # For example:
      # Do something with html_list
      print(html_list)
    } else {
      warning("No valid HTML content could be fetched.")
    }
  } else {
    warning("Article list is empty.")
  }
} else {
  warning("Data frame df2 or article column does not exist.")
}

