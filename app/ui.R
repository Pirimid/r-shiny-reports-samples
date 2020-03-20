library(shiny)

# Fix tag("div", list(...)) : could not find function "showOut… 
library(rCharts)

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
                        tabPanel(p(icon("table"), "By Currency"),
                            column(3,
                                wellPanel(
                                    radioButtons(
                                        "byCurrency",
                                        "Currency Pair:",
                                        c("All" = "all", "USDMXN" = "USDMXN"))
                                )
                            ),
                            column(7,
                                    p(icon("line-chart"), "By Bank"),
                                    h4('Bid and Ask', align = "center"),
                                    plotOutput("bidAsk"),
                                    h4('Bid Size and Ask Size', align = "center"),
                                    plotOutput("bidSizeAskSize"),
                                    h4('Spread', align = "center"),
                                    plotOutput("spread")
                            )
                        ),
                        # Data 
                        tabPanel(p(icon("table"), "Data"),
                            mainPanel(
                                includeMarkdown("download.md")
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