library(shiny)

askbidSelector <- function(id, label) {
    # ns <- NS(id)
    radioButtons(id, label= label, c("ASK"= "ASK", "BID"= "BID"))
    }

selectBins <- function(id, label) {
  sliderInput(inputId= id, label= label, min= 1, max= 10, value= 6)
  }

selectAll <- function(id, label) {
  actionButton(inputId = id, label = label,
                        style='padding:4px; width: 125px')
  }

plotGraphs <- function(id, label) {
  plotlyOutput(id)
 }

plotHist <- function(id, label) {
  plotOutput(id)
 }