library(shiny)
library(rCharts)
library(plotly)
library(shinyjs)

shinyUI(
    navbarPage("FX Data Explorer",
        tabPanel("Visualization",
                 sidebarPanel(
                    div(fluidRow(
                        actionButton(inputId = "select_all", label = "Select All Banks",
                        style='padding:4px; width: 125px')
                        )),
                    uiOutput("selectSource"),
                    # div(fluidRow(
                    #     actionButton(inputId = "clear_all", label = "Clear selection", icon = icon("check-square"),
                    #     style='padding:4px; width: 120px')
                    # )),
                    div(id="radioButton", class="radioButton",style = "padding: 10px 0px; margin:10px", fluidRow(
                        radioButtons("askBid",
                                "Type",
                                c("ASK" = "ASK", "BID" = "BID"))
                    )),
                    div(id="slider", class="slider", style="padding: 10px 0px; margin:10px", 
                        fluidRow(
                            sliderInput(inputId = "bins",
                                                label = "Number of Bins:",
                                                min = 1,
                                                max = 10,
                                                value = 6)
                        )
                    ),
                    width=2
                ),
  
                mainPanel(
                    useShinyjs(),
                    tags$head(
                        tags$style(
                            "body {overflow-y: visible;}"
                            )
                            ),
                    tabsetPanel(id = "tabset", 
                        # Line Charts 
                        tabPanel(value=1, p(icon("line-chart"), "Price Charts"),
                            column(10,
                                    h4('Ask or Bid Price', align = "center"),
                                    plotlyOutput("prices"),
                                    HTML('<hr style="border-color: black;">'),
                                    h4('Ask or Bid Size', align = "center"),
                                    plotlyOutput("size"),
                                    HTML('<hr style="border-color: black;">'),
                                    h4('Spread', align = "center"),
                                    plotlyOutput("spread"),
                                    style = "height:1000px; width:1000px"
                            )
                        ),
                        # Histograms
                        tabPanel(value=2, p(icon("bar-chart-o"), "Spread Analysis"),
                            column(10,
                                    h4('Histogram', align = "center"),
                                    plotlyOutput("spreadFreq"),
                                    HTML('<hr style="border-color: black;">'),
                                    h4('Boxplot', align = "center"),
                                    plotlyOutput("spreadBox"),
                                    style = "height:1000px; width:1000px"
                            )
                        ),
                        # Histograms Size
                        tabPanel(value=3, p(icon("bar-chart"), "Volume Analysis"),
                            fluidRow(column(6, align="center",
                                    plotOutput("histAskSize")
                                ),
                                column(6, align="center",
                                    plotOutput("histBidSize")
                                )
                            )
                        ),
                        # Data 
                        tabPanel(value=4, p(icon("table"), "Data"),
                            mainPanel(
                                column(width=12,
                                    includeMarkdown("download.md"),
                                    DT::dataTableOutput("summary", ),
                                    style = "height:1000px; width:1200px"
                                )
                            )
                        )
                    )
                )
            
        ),
        
        tabPanel("About",
            mainPanel(
                includeMarkdown("include.md")
            )
        )
    )
)