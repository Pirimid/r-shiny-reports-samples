library(shiny)

# Fix tag("div", list(...)) : could not find function "showOut… 
library(rCharts)
library(plotly)

shinyUI(
    navbarPage("FX Data Explorer",
        tabPanel("Visualization",
                 sidebarPanel(
                    uiOutput("selectSource"),
                    actionButton(inputId = "clear_all", label = "Clear selection", icon = icon("check-square")),
                    actionButton(inputId = "select_all", label = "Select all", icon = icon("check-square-o"))
                ),
  
                mainPanel(
                    tabsetPanel(
                        
                        # Data by 
                        tabPanel(p(icon("line-chart"), "By Currency"),
                            column(3,
                                wellPanel(
                                    radioButtons(
                                        "askBid",
                                        "Type",
                                        c("ASK" = "ASK", "BID" = "BID"))
                                )
                            ),
                            column(7,
                                    h4('Ask or Bid Price', align = "center"),
                                    plotlyOutput("prices"),
                                    h4('Ask or Bid Size', align = "center"),
                                    plotlyOutput("size"),
                                    h4('Spread', align = "center"),
                                    plotlyOutput("spread")
                            )
                        ),
                        # Data 
                        tabPanel(p(icon("table"), "Data"),
                            mainPanel(
                                includeMarkdown("download.md"),
                                DT::dataTableOutput("summary")
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