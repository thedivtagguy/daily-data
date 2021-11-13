# Load Libraries

##################################################################################
#                                                                                #
# Theme forked from https://twitter.com/issa_madjid/status/1458199645801357318   #
# by Issa Madjid                                                                 #
# Github: https://github.com/AbdoulMa/TidyTuesday/tree/main/2021_w46             #
#                                                                                #
##################################################################################

library(tidyverse) # Because I don't know how else
library(ggplot2)   # Plot vizualization
library(hrbrthemes)# Theming goodness
library(patchwork) # Combining graphs
library(ggtext)    # Using HTML in ggplot text
library(gridExtra) # functions to work with pictures
library(grid)

setwd("D:/DailyData")
dd <- "dd01_kharifAndRabiCrops"
# Load in the data
data <-
  read_csv(
    "./dd01_kharifAndRabiCrops/seasonwise_of_grains.csv",
    col_names = TRUE
  )

# Remove everything after - since we're keeping only the first year.
data$Year <- gsub("\\-.*", "", data$Year)


# Define the Units
area_unit <- "Million Hectares"
production_unit <- "Million Tonnes"
yield_unit <- "Kg/Hectare"

# Create graph to see the yields
yield <- data %>% 
  filter(Type != "Total") %>%  
  mutate(Type = glue::glue("Yield of <b>{Type}</b> Crops")) %>% 
  # Color the tiles by the yield amount
  ggplot(aes(Year, Type, fill = Yield)) +
  geom_tile() +
  labs(title = "Kharif & Rabi Crops",
       subtitle = "Between 1966 and 2016, we see <br> that the yield has been increasing <br> over the years...") +
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
    plot.title =  element_text(size = rel(2), hjust = .5,  face = "bold", margin = margin(t = 10, b = 15)),
    # element_markdown is from ggtext, this is what formats the HTML into the final rendered text
    plot.subtitle =  element_markdown(size = rel(1), hjust = .5, face = "bold", margin = margin(b = 15)),
    legend.title = element_text( vjust = 0.8, face = "bold", size = 8),
    legend.text = element_text( size = 6.5),
    plot.background = element_rect(fill = "#111111", color = NA),
    panel.spacing.x  = unit(3, "cm"),
    panel.background = element_blank(),
    panel.spacing.y  = unit(5, "cm"),
    axis.text.x = element_markdown(size = 8, color = "white"),
    strip.text = element_markdown(color = "white"),
    legend.position = "top"
  ) + 
  labs(x = NULL, y = NULL,
       fill = glue::glue("Yield ({yield_unit})"))

# Do the same thing but for area
area <- data %>% filter(Type != "Total") %>% 
  mutate(Type = glue::glue("Area under <b>{Type}</b> Crops")) %>% 
  ggplot(aes(Year, Type, fill = Area)) +
  geom_tile() +
  labs(subtitle = glue::glue("...but the area in use remains <br> more or less the same...")) +
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
    plot.title =  element_text(size = rel(2.5), hjust = .5,  face = "bold", margin = margin(t = 10, b = 15)),
    plot.subtitle =  element_markdown(size = rel(1), hjust = .5, face ="bold", margin = margin(b = 15)),
    legend.title = element_text( vjust = 0.8, face = "bold", size = 8),
    legend.text = element_text( size = 6.5),
    plot.background = element_rect(fill = "#111111", color = NA),
    panel.spacing.x  = unit(3, "cm"),
    panel.spacing.y  = unit(5, "cm"),
    panel.background = element_blank(),
    axis.text.x = element_text(size = 8, color = "white"),
    strip.text = element_markdown(color = "white"),
    legend.position = "top"
  ) + 
  labs(x = NULL, y = NULL,
       fill = glue::glue("Area ({area_unit})"))




## Plot small barplots for yield by area
yield_area_year <- data %>% 
  filter(Type != "Total") %>% 
  arrange(Year) %>% 
  mutate(Type = glue::glue("<span style='font-size:15px;'><b>{Type} Crops</b></span>")) %>% 
  mutate(Year = factor(Year)) %>% 
  ggplot(aes(x = Year, y = Yield, size=Area )) + 
  geom_point(alpha=0.3, colour = "#f768a1") +
  scale_size(range = c(1, 10), name=glue::glue("Area ({area_unit})")) +
  scale_x_discrete(expand=c(0,0),
                   breaks=c("1966","1976","1986","1996","2006","2016"))+
  theme_minimal() +
  facet_wrap(~Type, scales = "free") +
  guides(colour  = FALSE)+
  labs(
    subtitle = "...which means we're producing more than ever before <br> in the same amount of area! <br> &nbsp;"
  )+
  theme(
    text = element_text(color = "white"),
    panel.grid = element_blank(),
    plot.margin = unit(c(1,2,1,2), "cm"),
    plot.title =  element_text(size = rel(2), hjust = .5,  face = "bold", margin = margin(t = 10, b = 15)),
    # element_markdown is from ggtext, this is what formats the HTML into the final rendered text
    plot.subtitle =  element_markdown(size = rel(1), hjust = .5, vjust= 0.4, face = "bold", margin = margin(b = 15)),
    legend.title = element_text(family = "Arsenica Trial Bold", vjust = 0.5, face = "bold", size = 9),
    
    legend.text = element_text( size = 8.5),
    plot.background = element_rect(fill = "#111111", color = NA),
    panel.spacing.x  = unit(3, "cm"),
    panel.background = element_blank(),
    panel.spacing.y  = unit(5, "cm"),
    axis.text.x = element_markdown(size = 8, color = "white"),
    axis.line = element_line(color = "gray30"),
    axis.ticks = element_line(color = "gray50"),
    axis.text.y = element_markdown(color = "white"),
    strip.text = element_markdown(color = "white"),
    axis.title.y = element_text(margin = margin(r =10), size = 10),
    legend.position = "bottom",
    plot.caption = element_markdown(color = "white", margin = margin(t = 10, b = 2))
    
  ) + 
  labs(x = NULL, y = glue::glue("Yield ({yield_unit})"),
       caption = glue::glue("Source: Agricultural at a Glance, GOI, 2019 <br>Vizualization: @thedivtagguy")) 

yield / area / yield_area_year



# Save
plot_name <- "kharif_rabi"
ggsave(glue::glue("./{dd}/{plot_name}.png"), width = 20, height = 30, units = "cm")

