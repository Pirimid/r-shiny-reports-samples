library(shiny)
library(shinyjs)

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
source("plotData.R", local = TRUE)


# Load data
dt <- fread('data/fx_data.csv')
dt$SOURCE <- sub("*FX", "", as.character(dt$SOURCE))
dt <- dt %>% group_by(SOURCE, FEED_TIME)
dt$SPREAD = dt$ASK_PRICE - dt$BID_PRICE
dt <- dt[!duplicated(dt[,c('FEED_TIME')]),]
source <- sort(unique(dt$SOURCE))


# Shiny server
shinyServer(function(input, output, session) {

    # Define and initialize reactive values
    values <- reactiveValues()
    values$source <- source

    output$selectSource <- renderUI({
        checkboxGroupInput('selectSource', NULL, choices=source, selected=values$source)
    })

    observe({
      validate(need(!is.null(input$tabset), ""))
      if (input$tabset == 2 || input$tabset == 3 || input$tabset == 4) {
          disable("radioButton")
      } else {
          enable("radioButton")
      }

      if (input$tabset == 1 || input$tabset == 2 || input$tabset == 4){
          disable("slider")
      } else {
          enable("slider")
      }
    })

    observeEvent(input$select_all,{
        output$selectSource <- renderUI({
        checkboxGroupInput('selectSource', NULL, choices=source, selected=source)
    })
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
            desc = TRUE
        )
        })

    # Ask or Bid size by bank
    output$size <- renderPlotly({
        plot_size_by_bank(
            dt = filter_size_data(dt.agg() %>% select(SOURCE, FEED_TIME, ASK_SIZE, BID_SIZE), input$askBid),
            dom = "size",
            desc= TRUE
        )
    })

    # Spread by Banks
    output$spread <- renderPlotly({
        plot_spread_by_bank(
            dt = dt.agg() %>% select(SOURCE, FEED_TIME, SPREAD),
            dom = "spread",
            desc= TRUE
        )
    })

    output$summary <- DT::renderDataTable(
        {dataTable()}, options = list(bFilter = FALSE, iDisplayLength = 50))

    # Histogram of size
    output$spreadFreq <- renderPlotly({
        plot_spread_histograms(
            dt = dt.agg() %>% select(SOURCE, FEED_TIME, SPREAD),
            dom = "spreadFreq",
            desc= TRUE
        )
    })

    # Boxplots of size
    output$spreadBox <- renderPlotly({
        plot_spread_boxplot(
            dt = dt.agg() %>% select(SOURCE, FEED_TIME, SPREAD),
            dom = "spreadBox",
            desc= TRUE
        )
    })

    # Histogram of ASK size
    output$histAskSize <- renderPlot ({
            dt = dt.agg() %>% select(SOURCE, FEED_TIME, ASK_SIZE)
            asksize <- dt$ASK_SIZE / 1000000
            asksize <- as.numeric(unlist(asksize))
            bins <- seq(min(asksize), max(asksize), length.out = input$bins + 1)
            plot_hist(asksize, bins, xlab = "Total ASK Size (In millions)",
                    title = "Frequency of ASK Size")
    })

    # Boxplots of size
    output$histBidSize <- renderPlot ({
            dt = dt.agg() %>% select(SOURCE, FEED_TIME, BID_SIZE)
            bidsize <- dt$BID_SIZE / 1000000
            bidsize <- as.numeric(unlist(bidsize))
            bins <- seq(min(bidsize), max(bidsize), length.out = input$bins + 1)
            plot_hist(bidsize, bins, xlab = "Total BID Size (In millions)",
                    title = "Frequency of BID Size")
    })

})