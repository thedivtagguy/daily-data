library(shiny)
library(shiny.tailwind)
library(httr)
library(tidyverse)

# Define UI for application that draws a histogram
ui <-
    div(
        class = "px-4 py-10 max-w-3xl mx-auto sm:px-6 sm:py-12 lg:max-w-4xl lg:py-16 lg:px-8 xl:max-w-6xl",

        # Load Tailwind CSS Just-in-time
        shiny.tailwind::use_tailwind(),

        # Title
        div(
            class = "flex flex-col w-full text-center py-12",
            h1(class = "text-3xl font-extrabold text-black tracking-tight sm:text-4xl md:text-5xl md:leading-[3.5rem]",
               "desidata 📦"),
            h3(class = "text-2xl font-bold text-black tracking-loose sm:text-xl md:text-md", "Select a dataset"),
        ),

        # Inputs
        div(
            class = "block shadow-md py-4 px-4 flex justify-between flex-row",
            div(class = "flex-intiial",
                div(
                    class = "flex-initial py-2 mx-4",
                    textInput("search", "Search for keyword")
                ),),
            div(
                class = "flex flex-row",
                div(
                    class = "flex-initial bg-gray-100 py-2 px-4",
                    selectInput(
                        "categories",
                        "Select datasets within: ",
                        selected = NULL,
                        c("Categories", "Cities", "States")
                    )
                ),
                div(
                    class = "flex-initial bg-gray-100 py-2 px-4",
                    selectInput(
                        "categories",
                        "About: ",
                        selected = NULL,
                        choices = NULL
                    )
                )
            )

        ),

        # Plot
        div(class = "block shadow-md py-4 px-4 mt-4",
            tableOutput("data"))
    )

# Define server logic required to draw a histogram
server <- function(input, output) {

    # Function to take in JSON and return a dataframe
    jsonReader <- function(json_link) {
        json_file <- json_link[[1]]
        x <- jsonlite::fromJSON(json_file) %>%
            as_tibble() %>%
            select(-id) %>%
            unique()
        return(x)
    }


    # ===============================================
    # Get all categories

    req <-
        GET(
            "https://api.github.com/repos/thedivtagguy/desidatasets/git/trees/master?recursive=1"
        )
    stop_for_status(req)
    categoryList <- httr::content(req)$tree %>%
        purrr::map_dfr(., dplyr::bind_cols) %>%
        dplyr::filter(.data$type == "tree") %>%
        dplyr::filter(str_detect(.data$path, 'dd') == FALSE) %>%
        dplyr::select(.data$path, .data$url) %>%
        dplyr::mutate(within = dplyr::case_when(
            grepl('categories', .data$path) ~ 'Categories',
            grepl('states', .data$path) ~ 'States',
            grepl('cities', .data$path) ~ 'Cities',
        ),
        about = str_to_title(gsub("_", " ", gsub(".*/", "", .data$path))),
        ) %>%
        filter(!about == "Categories" & !about == "Cities" & !about == "States") %>%
        select(within, about) %>%
        drop_na()

    # ===============================================
    # Get all the files

    files <-
        httr::GET(
            "https://api.github.com/repos/thedivtagguy/desidatasets/git/trees/master?recursive=1"
        )
    stop_for_status(files)

    # Filter only DESCRIPTION and CSV Files
    fileList <- httr::content(files)$tree %>%
        purrr::map_dfr(., dplyr::bind_cols) %>%
        dplyr::filter(type == "blob") %>%
        dplyr::mutate(
            dataset_category = dplyr::case_when(
                grepl('categories', .data$path) ~ 'Categories',
                grepl('states', .data$path) ~ 'States',
                grepl('cities', .data$path) ~ 'Cities',
            )
        ) %>%
        dplyr::mutate(
            download_url = paste(
                "https://raw.githubusercontent.com/thedivtagguy/desidatasets/master/",
                path,
                sep = ""
            )
        ) %>%
        dplyr::select(-mode, -type, -sha, -size, -url) %>%
        dplyr::mutate(
            file_type = dplyr::case_when(
                grepl('.csv', .data$path) ~ 'CSV',
                grepl('DESCRIPTION', .data$path) ~ 'DESCRIPTION',
                grepl('DICTIONARY', .data$path) ~ 'DICTIONARY'

            ),
            id = str_extract(.data$path, "dd-([^/]+)")
        ) %>%
        dplyr::filter(file_type == 'DESCRIPTION' |
                          file_type == "CSV")


    descriptions <- fileList %>%
        filter(file_type == "DESCRIPTION") %>%
        select(download_url, id) %>%
        group_by(id) %>%
        nest() %>%
        mutate(desc = map(data, jsonReader)) %>%
        select(-data) %>%
        unnest(desc)


}

# Run the application
shinyApp(ui = ui, server = server)
