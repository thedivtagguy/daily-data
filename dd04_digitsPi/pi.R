library(tidyverse)
library(glue)

setwd("D:/DailyData/")
dd <- "dd04_digitsPi"

pi <- read.csv(glue("./{dd}/pi.csv")) %>% 
  tibble::rowid_to_column(., "position")

write.csv(pi, "pi_updated.csv")
