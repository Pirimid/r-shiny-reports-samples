library(shiny)

# Plotting 
library(ggplot2)
library(rCharts)
library(ggvis)
library(plotly)

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
dt$SOURCE <- sub("*FX", "", as.character(dt$SOURCE))
dt <- dt %>% group_by(SOURCE, FEED_TIME)
dt <- dt[!duplicated(dt[,c('FEED_TIME')]),]
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
    
    # Prepare dataset to show summary
    dataTable <- reactive({
        prepare_summary(dt.agg() %>% select(SOURCE, FEED_TIME, ASK_PRICE, BID_PRICE, ASK_SIZE, BID_SIZE, SPREAD, ASK_SPOT, BID_SPOT))
    })

    # Render Plots
    # Ask or bid by Bank
    output$prices <- renderPlotly({
        plot_prices_by_bank(
            dt =  filter_price_data(dt.agg() %>% select(SOURCE, FEED_TIME, ASK_PRICE, BID_PRICE), input$askBid),
            dom = "prices",
            yAxisLabel = "Prices",
            desc = TRUE
        )
        })
    
    # Ask or Bid size by bank
    output$size <- renderPlotly({
        plot_size_by_bank(
            dt = filter_size_data(dt.agg() %>% select(SOURCE, FEED_TIME, ASK_SIZE, BID_SIZE), input$askBid),
            dom = "size",
            yAxisLabel = "Size",
            desc= TRUE
        )
    })

    # Spread by Banks
    output$spread <- renderPlotly({
        plot_spread_by_bank(
            dt = dt.agg() %>% select(SOURCE, FEED_TIME, SPREAD),
            dom = "spread",
            yAxisLabel = "Spread",
            desc= TRUE
        )
    })

    output$summary <- DT::renderDataTable(
        {dataTable()}, options = list(bFilter = FALSE, iDisplayLength = 50))
    
    # Histogram of size
    output$sizeFreq <- renderPlotly({
        plot_size_histograms(
            dt = filter_size_data(dt.agg() %>% select(SOURCE, FEED_TIME, ASK_SIZE, BID_SIZE), input$askBid),
            dom = "sizeFreq",
            yAxisLabel = "Size",
            desc= TRUE
        )
    })

    # # Boxplots of size
    # output$sizeBox <- renderPlotly({
    #     plot_size_boxplot(
    #         dt = filter_size_data(dt.agg() %>% select(SOURCE, FEED_TIME, ASK_SIZE, BID_SIZE), input$askBid),
    #         dom = "sizeBox",
    #         yAxisLabel = "Frequency",
    #         desc= TRUE
    #     )
    # })
     
})