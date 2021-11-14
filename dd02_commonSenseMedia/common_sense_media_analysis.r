library(tidyverse) # Because I don't know how else
library(ggplot2)   # Plot vizualization
library(hrbrthemes)# Theming goodness
library(patchwork) # Combining graphs
library(ggtext)    # Using HTML in ggplot text
library(gridExtra) # functions to work with pictures
library(grid)
library(Hmisc)
library(extrafont)

font_import("./resources/fonts/grand_royal/")
loadfonts(device = "win", quiet = TRUE) 

dd <- "dd02_commonSenseMedia"

# Load data
data <-
  read_csv(
    "https://raw.githubusercontent.com/thedivtagguy/movie-ratings/master/data/movie_data.csv"
  )
genders <- read_csv(glue::glue("./{dd}/genre_gender_counts.csv")) %>% 
  pivot_longer(cols = -c(X1), names_to = "genre", values_to = "count")

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
    title = "Parents say <span style='font-size:35px;'>16</span>, kids say <span style='font-size:35px;'>12</span>",
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
      size = 15,
      family = "Grand Royal",
      face = "plain",
      colour = "#4C1E4F"
    ),
    plot.subtitle = element_markdown(margin = margin(b = 1, unit = "cm"), size = 13, lineheight = 1.3, family="Raleway", face = "plain",colour = "#3F2F27"),
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
    axis.text.y = element_markdown(colour = "#3F2F27", size = 12),
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
       subtitle = "CSM rates, from 0 to 5, on the kind of language they use <br> What are the most common words in each ranking?",
       x = "Language rating",
       y = "Number of times mentioned")+
  theme_minimal()+
  theme(
    plot.margin = unit(c(1, 2, 1, 2), "cm"),
    plot.title = element_markdown(
      margin = margin(t = 0.2, b = 0.2, unit = "cm"),
      size = 15,
      family = "Grand Royal",
      face = "plain",
      colour = "#4C1E4F"
    ),
    plot.subtitle = element_markdown(margin = margin(b = 1, unit = "cm"), size = 13, lineheight = 1.3, family="Raleway", face = "plain",colour = "#3F2F27"),
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


### Words in consumerism_text
gender <- genders %>%
  filter(count != 0) %>% 
  mutate(X1 = capitalize(X1)) %>% 
  mutate(X1 = factor(X1, levels = c("Male", "Female"))) %>% 
  ggplot(aes(x = reorder(genre, -count), y = count, fill = X1)) +
  geom_bar(position = "dodge", stat = "identity") +
  geom_text(aes(label = count), vjust = -0.5, colour = "#3F2F27", size = 3, position = position_dodge(.9)) +
  scale_y_continuous(limits = c(0,160), expand = expansion(mult = c(0.002, .1))) +
  scale_fill_manual(values = c("#E63946", "#457B9D")) +
  theme_minimal() +
  labs(
    x = "Genre",
    y = "Count",
    fill = "",
    title = "Who are the role models?",
    subtitle = "CSM also reviews movies on whether or not they have characters who can be positive role models. <br> How does the gender of these role models vary with genre?"
  ) +
  theme(
    plot.title = element_markdown(
      margin = margin(t = 0.2, b = 0.2, unit = "cm"),
      size = 15,
      family = "Grand Royal",
      face = "plain",
      colour = "#4C1E4F",
      hjust = 0.5
    ),
    plot.subtitle = element_markdown(margin = margin(b = 1, unit = "cm"), size = 13, hjust = 0.5, lineheight = 1.3, family="Raleway", face = "plain",colour = "#3F2F27"),
    plot.background = element_rect(fill = "#FEE1C7", color = NA),
    axis.line = element_line(colour = "#3F2F27"),
    panel.grid = element_blank(),
    axis.title.x = element_markdown(
      face = "bold",
      colour = "#4C1E4F"
    ),
    axis.title.y = element_markdown(
      face = "bold",
      colour = "#4C1E4F"
    ),
    legend.position = "bottom",
    plot.caption = element_markdown(colour = "#3F2F27", size = 12),
    axis.text.y = element_markdown(colour = "#3F2F27", size = 15),
    axis.text.x = element_markdown(colour = "#3F2F27", angle = 60, vjust = 0.9, hjust = 0.95, size = 12)
  )

combined <- (mean + language_plot) / gender

combined + plot_annotation(
  title = 'Common Sense Media',
  subtitle = 'Common Sense Media (CSM) uses various scales and categories to review and rate movies, <br> such as based on the kind of positive messages, role models, use of language, amount of violence and so on. <br> We can use this information to visualize things such as...',
  caption = 'Source: Common Sense Media, 2021 <br> <b>Visualization: @thedivtagguy</b>'
) & 
  theme(
    plot.title = element_markdown(
      margin = margin(t = 0.2, b = 0.2, unit = "cm"),
      size = 32,
      family = "Grand Royal",
      face = "plain",
      colour = "#4C1E4F",
      hjust = 0.5
    ),
    plot.margin = unit(c(1,1,1,1), "cm"),
    plot.caption = element_markdown(size = 13, lineheight = 1.5),
    plot.subtitle = element_markdown(margin = margin(t = 0.5, b=0.8, unit = "cm"), size = 20, hjust = 0.5, lineheight = 1.3, family="Raleway", face = "plain",colour = "#3F2F27"),
    plot.background = element_rect(fill = "#FEE1C7", color = NA),
  )
# Save
plot_name <- "common_sense"
ggsave(glue::glue("./{dd}/{plot_name}.png"), width = 48, height = 56, units = "cm")

