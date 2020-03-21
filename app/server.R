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
dt <- dt %>% group_by(SOURCE, FEED_TIME)
dt <- dt[!duplicated(dt[,c('FEED_TIME')]),]
# dt <- dt[dt$SOURCE != "JPMCFX"]
source <- sort(unique(dt$SOURCE))
dt$SPREAD = dt$ASK_PRICE - dt$BID_PRICE


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
    output$Ask <- renderPlot({
        plot_ask_by_bank(
            dt = dt.agg() %>% select(SOURCE, FEED_TIME, ASK_PRICE),
            dom = "Ask",
            yAxisLabel = "Prices",
            desc = TRUE
        )
        })
    
    # Ask and Bid size by bank
    output$Bid <- renderPlot({
        plot_bid_by_bank(
            dt = dt.agg() %>% select(SOURCE, FEED_TIME, BID_PRICE),
            dom = "Bid",
            yAxisLabel = "Price",
            desc= TRUE
        )
    })

    output$spread <- renderPlot({
        plot_spread_by_bank(
            dt = dt.agg() %>% select(SOURCE, FEED_TIME, SPREAD),
            dom = "spread",
            yAxisLabel = "Spread",
            desc= TRUE
        )
    })
    
})