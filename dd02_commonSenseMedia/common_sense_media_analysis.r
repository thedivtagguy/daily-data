library(tidyverse) # Because I don't know how else
library(ggplot2)   # Plot vizualization
library(hrbrthemes)# Theming goodness
library(patchwork) # Combining graphs
library(ggtext)    # Using HTML in ggplot text
library(gridExtra) # functions to work with pictures
library(grid)
library(corpus)
library(extrafont)

font_import("./resources/fonts/grand_royal/")
loadfonts(device = "win", quiet = TRUE) 

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
mean <- data %>%
  group_by(genres) %>%
  summarise(difference = (mean(parents_say, na.rm = TRUE) - mean(kids_say, na.rm = TRUE))) %>%
  drop_na() %>%
  arrange(desc(difference)) %>%
  mutate(genres = reorder(genres, difference)) %>%
  ggplot(., aes(x = difference, y = genres, fill = difference < 0)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = c("#E63946", "#457B9D")) +
  theme_minimal() +
  labs(
    x = "Mean Difference Between Parent Recommended Age <br> and Kids Recommended Age",
    y = "Genres",
    title = "Parents say <span style='font-size:30px;'>16</span>, kids say <span style='font-size:30px;'>12</span>",
    subtitle = "Examining the mean difference in viewing ages <br> recommended by parents versus kids based on genre"
  ) +
  annotate(
    geom = "curve",
    x = -0.02,
    colour = "#8A6552",
    y = 21.5,
    xend = -0.4,
    yend = 18,
    curvature = .3,
    arrow = arrow(length = unit(2, "mm"))
  ) +
  annotate(
    geom = "text",
    x = -0.8,
    y = 17,
    size = 3.5,
    label = "Parents say kids need to be older",
    hjust = "left"
  ) +
  annotate(
    geom = "curve",
    x = 0.02,
    y = 1,
    colour = "#8A6552",
    xend = 0.4,
    yend = 3,
    curvature = .3,
    arrow = arrow(length = unit(2, "mm"))
  ) +
  annotate(
    geom = "text",
    x = 0.15,
    y = 3.8,
    size = 3.5,
    label = "Kids say they need to be older",
    hjust = "left"
  ) +
  
  theme(
    plot.margin = unit(c(1, 2, 1, 2), "cm"),
    plot.title = element_markdown(
      margin = margin(t = 0.2, b = 0.2, unit = "cm"),
      size = 26,
      family = "Grand Royal",
      face = "plain",
      colour = "#4C1E4F"
    ),
    plot.subtitle = element_markdown(margin = margin(b = 1, unit = "cm"), family="Raleway", face = "plain",colour = "#3F2F27"),
    plot.background = element_rect(fill = "#FEE1C7", color = NA),
    axis.line = element_line(colour = "#3F2F27"),
    panel.grid = element_blank(),
    axis.title.x = element_markdown(
      margin = margin(t = 0.5, b = 0.5, unit = "cm"),
      face = "bold",
      colour = "#4C1E4F"
    ),
    axis.title.y = element_markdown(
      margin = margin(t = 0.5, b = 0.5, unit = "cm"),
      face = "bold",
      colour = "#4C1E4F"
    ),
    axis.text.y = element_markdown(colour = "#3F2F27"),
    axis.text.x = element_markdown(colour = "#3F2F27")
  )

# What words are associated with what ratings for language?
language <- data %>%
  group_by(language_rating) %>%
  drop_na() %>%
  summarise(words =
              str_extract_all(str_replace_all(str_to_lower(language_text), '[.,]', ""), '"(.*?)"')) %>%
  unnest(cols = c(words)) %>%
  mutate(words = str_replace_all(words, '"', "")) %>%
  mutate(words = str_replace_all(words, "a--hole", "ass")) %>% 
  mutate(words = str_replace_all(words, "jesus christ", "christ")) %>% 
  na_if("") %>%
  mutate(words = trimws(words, which = "both")) %>%
  drop_na() %>%
  count(language_rating, words, sort = TRUE) %>%
  slice_max(order_by = n, n = 4) %>%
  arrange(desc(language_rating, n)) %>%
  filter(words != "" & language_rating != "0") %>% 
  mutate(words = fct_reorder(words, n))

language_plot <- language %>% 
  ggplot(aes(x = language_rating, y = n, fill = language_rating))+
  geom_point(size = 0, fill = NA, colour = NA)+ 
  geom_text(
    label=paste(toupper(language$words), language$n, sep = " - "),
    nudge_x = 0.1,  
    check_overlap = T,
    size = 3,
    family = "Raleway",
    fontface = "bold",
    colour = "#3F2F27"
    )+
  labs(title = "How bad are words?",
       subtitle = "CSM rates movies on the kind of language they contain. <br> What are the most common words in each ranking?",
       x = "Language rating",
       y = "Number of times mentioned")+
  theme_minimal()+
  theme(
    plot.margin = unit(c(1, 2, 1, 2), "cm"),
    plot.title = element_markdown(
      margin = margin(t = 0.2, b = 0.2, unit = "cm"),
      size = 26,
      family = "Grand Royal",
      face = "plain",
      colour = "#4C1E4F"
    ),
    plot.subtitle = element_markdown(margin = margin(b = 1, unit = "cm"), lineheight = 1.2, family="Raleway", face = "plain",colour = "#3F2F27"),
    plot.background = element_rect(fill = "#FEE1C7", color = NA),
    axis.line = element_line(colour = "#3F2F27"),
    panel.grid = element_blank(),
    axis.title.x = element_markdown(
      margin = margin(t = 0.5, b = 0.5, unit = "cm"),
      face = "bold",
      colour = "#4C1E4F"
    ),
    axis.title.y = element_markdown(
      margin = margin(r = 0.5, l = 0.5, unit = "cm"),
      face = "bold",
      colour = "#4C1E4F"
    ),
    axis.text.y = element_markdown(colour = "#3F2F27", hjust = 3, size = 10, family = "Raleway", face ="bold"),
    axis.text.x = element_markdown(colour = "#3F2F27", size = 15, family = "Raleway", face ="bold", margin = margin(t = 10))
  )

mean + language_plot

### Ratings by genre
data %>% 
  group_by(genres) %>% 
  pivot_longer(c(diversity_rating, language_rating, positive_rating, role_models_rating, violence_rating, sex_rating, language_rating, consumerism_rating, drugs_rating), values_to = "rating", names_to = "category") %>% 
  select(genres, category, rating) %>% 
  ggplot(aes(x = genres, y = rating, fill = category)) + 
  geom_bar(position = "dodge", stat= "identity")

# Save
plot_name <- "common_sense"
ggsave(glue::glue("./{plot_name}.png"), width = 40, height = 20, units = "cm")

