# Load Libraries
library(tidyverse) # Because I don't know how else
library(ggplot2)   # Plot vizualization
library(hrbrthemes)# Theming goodness
library(patchwork) # Combining graphs
library(ggtext)    # Using HTML in ggplot text

# Load in the data
data <-
  read_csv(
    "/dd01_kharifAndRabiCrops/seasonwise_of_grains.csv",
    col_names = TRUE
  )

# Remove everything after - since we're keeping only the first year.
data$Year <- gsub("\\-.*", "", data$Year)

# Create graph to see the yields
yield <- data %>% 
  filter(Type != "Total") %>% 
  # Color the tiles by the yield amount
  ggplot(aes(Year, Type, fill = Yield)) +
  geom_tile() +
  labs(title = "Kharif & Rabi Yields",
       subtitle = "With data of crop yields between 1966 and 2016, <br> we see that the amount of yield has been increasing over the years...") +
  # Scales free gives each heatmap its own frame, instead of combining them together
  facet_wrap( ~ Type, scales = "free")+ 
  # We have too many years, lets make it cleaner
  scale_x_discrete(expand=c(0,0),
                   breaks=c("1966","1976","1986","1996","2006","2016"))+
  scale_fill_distiller(palette = "RdPu") + 
  theme_minimal() + 
  theme(
    text = element_text(color = "white"),
    panel.grid = element_blank(),
    plot.margin = unit(c(1,2,1,2), "cm"),
    axis.text = element_blank(),
    plot.title =  element_text(size = rel(2.5), hjust = .5, family = "Gotham Black", face = "bold", margin = margin(t = 10, b = 15)),
    # element_markdown is from ggtext, this is what formats the HTML into the final rendered text
    plot.subtitle =  element_markdown(size = rel(1.25), hjust = .5,family = "Mercury", face = "bold.italic", margin = margin(b = 15)),
    legend.title = element_text(family = "Gotham Medium", face = "bold", size = 12),
    legend.text = element_text(family = "Gotham Medium", size = 6.5),
    plot.background = element_rect(fill = "#111111", color = NA),
    panel.spacing.x  = unit(3, "cm"),
    panel.spacing.y  = unit(5, "cm"),
    axis.text.x = element_text(size = 8, color = "white"),
    strip.text = element_text(color = "white"),
    legend.position = "top"
  ) + 
  labs(x = NULL, y = NULL)

# Do the same thing but for area
area <- data %>% filter(Type != "Total") %>% 
  ggplot(aes(Year, Type, fill = Area)) +
  geom_tile() +
  labs(subtitle = glue::glue("But the area in which it is cultivated remains <br> more or less the same...")) +
  facet_wrap( ~ Type, scales = "free")+ 
  scale_x_discrete(expand=c(0,0),
                   breaks=c("1966","1976","1986","1996","2006","2016"))+
  scale_fill_distiller(palette = "RdPu") + 
  theme_minimal() + 
  theme(
    text = element_text(color = "white"),
    panel.grid = element_blank(),
    plot.margin = unit(c(1,2,1,2), "cm"),
    axis.text = element_blank(),
    plot.title =  element_text(size = rel(2.5), hjust = .5, family = "Gotham Black", face = "bold", margin = margin(t = 10, b = 15)),
    plot.subtitle =  element_markdown(size = rel(1.25), hjust = .5,family = "Mercury", face = "bold.italic", margin = margin(b = 15)),
    legend.title = element_text(family = "Gotham Medium", face = "bold", size = 12),
    legend.text = element_text(family = "Gotham Medium", size = 6.5),
    plot.background = element_rect(fill = "#111111", color = NA),
    panel.spacing.x  = unit(3, "cm"),
    panel.spacing.y  = unit(5, "cm"),
    axis.text.x = element_text(size = 8, color = "white"),
    strip.text = element_text(color = "white"),
    legend.position = "top"
  ) + 
  labs(x = NULL, y = NULL)

# Combine them together
yield /  area
