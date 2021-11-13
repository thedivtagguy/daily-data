library(tidyverse) # Because I don't know how else
library(ggplot2)   # Plot vizualization
library(hrbrthemes)# Theming goodness
library(patchwork) # Combining graphs
library(ggtext)    # Using HTML in ggplot text
library(gridExtra) # functions to work with pictures
library(grid)
library(corpus)

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
  arrange(desc(difference)) %>%
  mutate(genres = reorder(genres, difference)) %>%
  ggplot(., aes(x = difference, y = genres, fill = difference < 0)) +
  geom_col(show.legend = FALSE) +
  theme_minimal() +
  labs(
    x = "Mean Difference Between Parent Recommended Age <br> and Kids Recommended Age",
    y = "Genres",
    title = "Parents say 16, Kids say 12...",
    subtitle = "Examining the mean difference in viewing ages <br> recommended by parents versus kids based on genre"
  ) +
  annotate(
    geom = "curve", x = -0.02, y = 21.5, xend = -0.4, yend = 18, 
    curvature = .3, arrow = arrow(length = unit(2, "mm"))
  ) +
  annotate(geom = "text", x = -0.7, y = 17, size = 3.5, label = "Parents say kids need to be older", hjust = "left") +
  annotate(
    geom = "curve", x = 0.02, y = 1, xend = 0.4, yend = 3, 
    curvature = .3, arrow = arrow(length = unit(2, "mm"))
  ) +
  annotate(geom = "text", x = 0.15, y = 3.8, size = 3.5, label = "Kids say they need to be older", hjust = "left") +
  
  theme(
    plot.title = element_markdown(margin = margin(t = 0.2, b = 0.2, unit = "cm")),
    plot.subtitle = element_markdown(margin = margin(b = 0.5, unit = "cm")),
    plot.background = element_rect(fill = "#FEE1C7"),
    axis.title.x = element_markdown(margin = margin(t = 0.5, b = 0.5, unit = "cm" ))
    ) 

# What words are associated with what ratings for language?
data %>%
  group_by(language_rating) %>%
  drop_na() %>%
  summarise(words = 
    str_extract_all(
    str_replace_all(
      str_to_lower(language_text), '[.,]', ""), '"(.*?)"'
  )) %>%
  unnest(cols = c(words)) %>% 
  mutate(words = str_replace_all(words, '"',"")) %>%
  na_if("") %>% 
  mutate(words = trimws(words, which = "both")) %>% 
  drop_na() %>%
  count(language_rating, words, sort = TRUE) %>%
  slice_max(order_by = n, n = 4) %>%
  arrange(desc(language_rating, n)) %>% 
  filter(words != "" & language_rating != "0") %>% 
  ggplot(aes())
  
