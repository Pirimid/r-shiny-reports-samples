library(shiny)

# Fix tag("div", list(...)) : could not find function "showOut… 
library(rCharts)
library(plotly)

shinyUI(
    navbarPage("FX Data Explorer",
        tabPanel("Visualization",
                 sidebarPanel(
                    uiOutput("selectSource"),
                    div(fluidRow(
                        actionButton(inputId = "clear_all", label = "Clear selection", icon = icon("check-square"),
                        style='padding:4px; width: 120px')
                    )),
                    div(fluidRow(
                        actionButton(inputId = "select_all", label = "Select all", icon = icon("check-square-o"),
                        style='padding:4px; width: 120px')
                        )),
                    div(style = "padding: 10px 0px; margin:10px", fluidRow(
                        radioButtons("askBid",
                                "Type",
                                c("ASK" = "ASK", "BID" = "BID"))
                    )), width=2
                ),
  
                mainPanel(
                    tags$head(
                        tags$style(
                            "body {overflow-y: visible;}"
                            )
                            ),
                    tabsetPanel( 
                        # Line Charts 
                        tabPanel(p(icon("line-chart"), "Line Charts"),
                            column(10,
                                    h4('Ask or Bid Price', align = "center"),
                                    plotlyOutput("prices"),
                                    br(),
                                    br(),
                                    h4('Ask or Bid Size', align = "center"),
                                    plotlyOutput("size"),
                                    br(),
                                    br(),
                                    h4('Spread', align = "center"),
                                    plotlyOutput("spread"),
                                    style = "height:1000px; width:1000px"
                            )
                        ),
                        # Histograms
                        tabPanel(p(icon("line-chart"), "Histogram Charts"),
                            column(10,
                                    h4('Histogram', align = "center"),
                                    plotlyOutput("sizeFreq"),
                                    # h4('Size Boxplot', align = "center"),
                                    # plotlyOutput("sizeBox"),
                                    style = "height:1000px; width:1000px"
                            )
                        ),
                        # Data 
                        tabPanel(p(icon("table"), "Data"),
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