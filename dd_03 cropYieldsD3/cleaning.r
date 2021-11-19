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
tractrs <- tuesdata$cereal_yields_vs_tractor_inputs_in_agriculture

land_use <- tuesdata$land_use_vs_yield_change_in_cereal_production
colnames(land_use)

land_use <- land_use %>% 
  rename("cereal_yield_index" = "Cereal yield index") %>% 
  rename("change" = "Change to land area used for cereal production since 1961") %>% 
  rename("population" = "Total population (Gapminder)") %>% 
  rename_all(tolower) %>% 
  drop_na()  



write.csv(land_use, "land_use.csv")

long_crops <- key_crop_yields %>% 
  pivot_longer(cols = 4:last_col(),
               names_to = "crop", 
               values_to = "crop_production") %>% 
  mutate(crop = str_remove_all(crop, " \\(tonnes per hectare\\)")) %>% 
  set_names(nm = names(.) %>% tolower()) %>% 
  drop_na()


long_crops %>% 
  arrange(-crop_production) %>% 
  filter(crop == "Rice")
