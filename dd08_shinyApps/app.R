library(shiny)
library(shiny.tailwind)
library(httr)
library(tidyverse)

# Define UI for application that draws a histogram
ui <- div(class="px-4 py-10 max-w-3xl mx-auto sm:px-6 sm:py-12 lg:max-w-4xl lg:py-16 lg:px-8 xl:max-w-6xl",

          # Load Tailwind CSS Just-in-time
          shiny.tailwind::use_tailwind(),

          # Title
          div(class = "flex flex-col w-full text-center py-12",
              h1(class = "text-3xl font-extrabold text-black tracking-tight sm:text-4xl md:text-5xl md:leading-[3.5rem]",
                 "desidata 📦"
              ),
              h3(class="text-2xl font-bold text-black tracking-loose sm:text-xl md:text-md", "Select a dataset"),
          ),

          # Inputs
          div(class = "block shadow-md py-4 px-4 flex justify-between flex-row",
              div(class="flex-intiial",
                  div(class = "flex-initial py-2 mx-4",
                      textInput("search", "Search for keyword")
                  ),
                  ),
              div(class="flex flex-row",
              div(class = "flex-initial bg-gray-100 py-2 px-4",
                  selectInput("categories", "Select datasets within: ", selected = NULL, c("Categories", "Cities", "States"))),
              div(class = "flex-initial bg-gray-100 py-2 px-4",
                  selectInput("categories", "About: ", selected = NULL, choices = NULL )))

          ),

          # Plot
          div(class = "block shadow-md py-4 px-4 mt-4",
              tableOutput("data")
          )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = 1)

        # draw the histogram with the specified number of bins
        hist(x,
             breaks = bins,
             col = 'darkgray', border = 'white')
    })

    # Get all categories
    req <- GET("https://api.github.com/repos/thedivtagguy/desidatasets/git/trees/master?recursive=1")
    stop_for_status(req)
    categoryList <- httr::content(req)$tree %>%
        purrr::map_dfr(.,dplyr::bind_cols) %>%
        dplyr::filter(.data$type == "tree") %>%
        dplyr::select(.data$path, .data$url) %>%
        dplyr::mutate(
            type = dplyr::case_when(
                grepl('categories', .data$path) ~ 'Categories',
                grepl('states', .data$path) ~ 'States',
                grepl('cities', .data$path) ~ 'Cities',
            )
        ) %>%
        dplyr::slice(-1)

    # Get all the files
    files <- GET("https://api.github.com/repos/thedivtagguy/desidatasets/git/trees/master?recursive=1")
    stop_for_status(files)
    fileList <- httr::content(files)$tree %>%
        purrr::map_dfr(.,dplyr::bind_cols) %>%
        dplyr::filter(type == "blob") %>%
        dplyr::mutate(
            fileCategory = dplyr::case_when(
                grepl('categories', .data$path) ~ 'Categories',
                grepl('states', .data$path) ~ 'States',
                grepl('cities', .data$path) ~ 'Cities',
            )
        ) %>%
        dplyr::mutate(
            download_url = paste("https://raw.githubusercontent.com/thedivtagguy/desidatasets/master/", path, sep = "")
        ) %>%
        tidyr::drop_na() %>%
        dplyr::select(-mode, -type, -sha, -size, -url) %>%
        dplyr::slice(-1)


    output$data <- renderTable({
        req(input$ordernumber)
        customer() %>%
            filter(ORDERNUMBER == input$ordernumber) %>%
            select(QUANTITYORDERED, PRICEEACH, PRODUCTCODE)
    })


}

# Run the application
shinyApp(ui = ui, server = server)
