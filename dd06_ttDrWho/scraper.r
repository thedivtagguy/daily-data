library(tidyverse)
library(rvest)
library(glue)
# Make a list of all links and relevant episodes

episode_list <- 9:13

get_episode_lists <- function(episode) {
  episode <- 9
  url <-  glue("http://www.chakoteya.net/DoctorWho/episodes{episode}.html")
  raw_html <- read_html(url)

  url_ <- raw_html %>%
    html_elements("body > table > tbody > tr:nth-child(3) > td:nth-child(2) > table:nth-child(2)") %>%
    html_elements("a") %>%
    html_attr("href")
    
    message(glue::glue("Downloaded all URLS for Doctor {episode}"))
  
  link_ <- raw_html %>%
    html_elements("body > table > tbody > tr:nth-child(3) > td:nth-child(2) > table:nth-child(2)") %>%
    html_nodes("a") %>%
    html_text()
  
    message(glue::glue("Downloaded all links for Doctor {episode}"))
  
  
  transcript_ <- function(episode_url) {
    
    url <- glue::glue("http://www.chakoteya.net/DoctorWho/{episode_url}")
    
    raw_html <- read_html(url)
    
    text_ <- raw_html %>%
      html_elements("body > div > center > table > tbody > tr > td") %>%
      html_text()
      message(glue::glue("Downloaded for script for Doctor {episode}"))
    
    tibble(
      text = text_
    )

  }
  
  transcripts <- url_ %>%
    map_dfr(transcript_)
  

  data.frame(
    link = link_,
    transcript = transcripts
  )
}


scripts <- episode_list %>% map_dfr(get_episode_lists)
