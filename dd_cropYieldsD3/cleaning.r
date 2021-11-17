# Get the Data

# Read in with tidytuesdayR package 
# Install from CRAN via: install.packages("tidytuesdayR")
# This loads the readme and all the datasets for the week of interest

# Either ISO-8601 date or year/week works!

library(tidyverse)

dd <- "dd_cropYieldsD3"
setwd(glue::glue("D:/DailyData/{dd}/"))


tuesdata <- tidytuesdayR::tt_load(2020, week = 36)

key_crop_yields <- tuesdata$key_crop_yields

long_crops <- key_crop_yields %>% 
  pivot_longer(cols = 4:last_col(),
               names_to = "crop", 
               values_to = "crop_production") %>% 
  mutate(crop = str_remove_all(crop, " \\(tonnes per hectare\\)")) %>% 
  set_names(nm = names(.) %>% tolower()) %>% 
  drop_na()


long_crops %>% 
  order_by(crop_production)