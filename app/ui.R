library(shiny)
library(rCharts)
library(plotly)
library(shinyjs)

# Load UI components
source("uiComponent.R", local = TRUE)

shinyUI(
    navbarPage("FX Data Explorer",
        tabPanel("Visualization",
                 sidebarPanel(
                    div(fluidRow(
                        selectAll(id="select_all", label="Select All Banks")
                        )),
                    uiOutput("selectSource"),
                    div(id="radioButton", class="radioButton",style = "padding: 10px 0px; margin:10px", fluidRow(
                        askbidSelector("askBid", label="Type")
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
                                    h4('Bid/Ask Over Time Period', align = "center"),
                                    plotGraphs("prices"),
                                    HTML('<hr style="border-color: black;">'),
                                    h4('Bid/Ask Size Over Time Period', align = "center"),
                                    plotGraphs("size"),
                                    HTML('<hr style="border-color: black;">'),
                                    h4('Bid/Ask Spread Over Time Period', align = "center"),
                                    plotGraphs("spread"),
                                    style = "height:1000px; width:1000px"
                            )
                        ),
                        # Histograms
                        tabPanel(value=2, p(icon("bar-chart-o"), "Spread Analysis"),
                            column(10,
                                    h4('Histogram', align = "center"),
                                    plotGraphs("spreadFreq"),
                                    HTML('<hr style="border-color: black;">'),
                                    h4('Boxplot', align = "center"),
                                    plotGraphs("spreadBox"),
                                    style = "height:1000px; width:1000px"
                            )
                        ),
                        # Histograms Size
                        tabPanel(value=3, p(icon("bar-chart"), "Volume Analysis"),
                            fluidRow(column(6, align="center",
                                    plotHist("histAskSize")
                                ),
                                column(6, align="center",
                                    plotHist("histBidSize")
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