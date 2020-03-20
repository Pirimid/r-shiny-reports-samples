library(shiny)

# Plotting 
library(ggplot2)
library(rCharts)
library(ggvis)

# Data processing libraries
library(data.table)
library(reshape2)
library(dplyr)

# Required by includeMarkdown
library(markdown)

# Load helper functions
source("helpers.R", local = TRUE)


# Load data
dt <- fread('data/fx_data.csv')
dt <- dt[duplicated(dt),]
dt <- dt[dt$SOURCE != "JPMCFX"]
source <- sort(unique(dt$SOURCE))

# Shiny server 
shinyServer(function(input, output, session) {
    
    # Define and initialize reactive values
    values <- reactiveValues()
    values$source <- source
    
    output$selectSource <- renderUI({
        checkboxGroupInput('selectSource', 'Banks', choices=source, selected=values$source)
    })
    
    # Add observers on clear and select all buttons
    observe({
        if(input$clear_all == 0) return()
        values$source <- c()
    })
    
    observe({
        if(input$select_all == 0) return()
        values$source <- source
    })

    # Preapre datasets
    dt.agg <- reactive({
        aggregate_by_banks(dt, input$selectSource)
    })
    
    # Render Plots
    # Ask and bid by Bank
    output$bidAsk <- renderPlot({
        plot_bid_ask_by_bank(
            dt = dt.agg() %>% select(SOURCE, FEED_TIME, ASK_PRICE, BID_PRICE),
            dom = "bidAsk",
            yAxisLabel = "Prices",
            desc = TRUE
        )
        })
    
    # Ask and Bid size by bank
    output$bidSizeAskSize <- renderPlot({
        plot_size_by_bank(
            dt = dt.agg() %>% select(SOURCE, FEED_TIME, ASK_SIZE, BID_SIZE),
            dom = "bidSizeAskSize",
            yAxisLabel = "Size of Ask and Bid",
            desc= TRUE
        )
    })
    
})