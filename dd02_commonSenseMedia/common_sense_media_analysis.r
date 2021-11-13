library(tidyverse) # Because I don't know how else
library(ggplot2)   # Plot vizualization
library(hrbrthemes)# Theming goodness
library(patchwork) # Combining graphs
library(ggtext)    # Using HTML in ggplot text
library(gridExtra) # functions to work with pictures
library(grid)


dd <- "dd02_common_sense_media"

# Load data
data <-
  read_csv(
    "https://raw.githubusercontent.com/thedivtagguy/movie-ratings/master/data/movie_data.csv"
  )

data <- data %>%
  mutate(genres = strsplit(as.character(genres), ",")) %>%
  unnest(genres)

# Exploratory Analysis

# Mean difference in the ages that parents recommend and those that kids recommend, based on genre
data %>%
  group_by(genres) %>%
  summarise(difference = (mean(parents_say, na.rm = TRUE) - mean(kids_say, na.rm = TRUE))) %>%
  drop_na() %>%
  ggplot(., aes(x = genres, y = difference)) +
  geom_bar(stat = "identity")
