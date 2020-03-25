library(ggplot2)
# Data processing libraries
library(reshape2)
library(dplyr)
library(qwraps2)

#' Aggregate dataset by Banks
#' 
#' @param dt data.table
#' @param banks character vector
#' @return data.table
#'
aggregate_by_banks <- function(dt, selectSource) {
    banks <- data.table(SOURCE=sort(unique(dt$SOURCE)))
    aggregated <- dt %>% group_by(SOURCE) 
    data <- left_join(banks,  aggregated, by= "SOURCE") %>% filter(SOURCE==selectSource)
    data
}

#' Add ASK or BID price based on category
#'
#' @param dt data.table
#' @param category character
#' @return data.table
#'
filter_price_data <- function(dt, category) {
    cat <- paste(category, "PRICE", sep="_")
    dt <- dt %>% select(SOURCE, FEED_TIME, all_of(cat))
}

#' Add ASK or BID size based on category
#'
#' @param dt data.table
#' @param category character
#' @return data.table
#'
filter_size_data <- function(dt, category) {
    cat <- paste(category, "SIZE", sep="_")
    dt <- dt %>% select(SOURCE, FEED_TIME, all_of(cat))
}

#' Prepare plots of Bid and Ask
#'
#' @param dt data.table
#' @param dom
#' @param yAxisLabel
#' @param desc
#' @return plot
#' 
plot_prices_by_bank <- function(dt, dom, yAxisLabel, desc = FALSE) {
    molted = melt(dt, id=c("FEED_TIME", "SOURCE"), value.name = "Price") %>% arrange(FEED_TIME, if (desc) { desc(variable) } else { variable })
    molted$variable <- as.character(molted$variable)
    molted$SOURCE <- as.character(molted$SOURCE)
    molted$FEED_TIME <- as.POSIXct(molted$FEED_TIME, format="%H:%M:%S")

    bidAsk <- ggplot(data=molted,
             aes(x=FEED_TIME, y=Price, colour=SOURCE)) + geom_line() + 
              xlab("Date") + ylab("Prices") + theme(legend.title = element_blank(),
                                            axis.text.y  = element_text(size=12),
                                            axis.title.y  = element_text(size=12),
                                            axis.text.x  = element_text(size=12, angle=45, hjust=1),
                                            axis.title.x  = element_text(size=12),)
    bidAsk <- ggplotly(bidAsk) %>% add_annotations( text="Banks", xref="paper", yref="paper",
                  x=1.02, xanchor="left",
                  y=0.8, yanchor="bottom",    # Same y as legend below
                  legendtitle=TRUE, showarrow=FALSE ) %>% layout( legend=list(y=0.8, yanchor="top" ) )
    }

#' Prepare plot of size of ask or bid by bank
#'
#' @param dt data.table
#' @param dom
#' @param yAxisLabel
#' @param desc
#' @return plot

plot_size_by_bank <- function(dt, dom, yAxisLabel, desc = FALSE) {
    molted = melt(dt, id=c("FEED_TIME", "SOURCE"), value.name = "Size") %>% arrange(FEED_TIME, if (desc) { desc(variable) } else { variable })
    molted$variable <- as.character(molted$variable)
    molted$SOURCE <- as.character(molted$SOURCE)
    molted$FEED_TIME <- as.POSIXct(molted$FEED_TIME, format="%H:%M:%S") 
    molted$Size = molted$Size / 1000000.0

    bidSizeAskSize <- ggplot(data=molted,
             aes(x=FEED_TIME, y=Size, colour=SOURCE)) + geom_line() + 
              xlab("Date") + ylab("Size (In millions)") + theme(legend.title = element_blank(),
                                            axis.text.y  = element_text(size=12),
                                            axis.title.y  = element_text(size=12),
                                            axis.text.x  = element_text(size=12, angle=45, hjust=1),
                                            axis.title.x  = element_text(size=12))
    bidSizeAskSize <- ggplotly(bidSizeAskSize) %>% add_annotations( 
                text="Banks", xref="paper", yref="paper",
                x=1.02, xanchor="left",
                y=0.8, yanchor="bottom",    # Same y as legend below
                legendtitle=TRUE, showarrow=FALSE ) %>% layout( legend=list(y=0.8, yanchor="top" ) )
    }

#' Prepare plot spread
#'
#' @param dt data.table
#' @param dom
#' @param yAxisLabel
#' @param desc
#' @return plot

plot_spread_by_bank <- function(dt, dom, yAxisLabel, desc = FALSE) {
    molted = melt(dt, id=c("FEED_TIME", "SOURCE"), value.name = "Spread") %>% arrange(FEED_TIME, if (desc) { desc(variable) } else { variable })
    molted$variable <- as.character(molted$variable)
    molted$SOURCE <- as.character(molted$SOURCE)
    molted$FEED_TIME <- as.POSIXct(molted$FEED_TIME, format="%H:%M:%S")

    spread <- ggplot(data=molted,
             aes(x=FEED_TIME, y=Spread, colour=SOURCE)) + geom_line() + 
              xlab("Date") + ylab("Spread") + theme(legend.title = element_blank(),
                                            axis.text.y  = element_text(size=12),
                                            axis.title.y  = element_text(size=12),
                                            axis.text.x  = element_text(size=12, angle=45, hjust=1),
                                            axis.title.x  = element_text(size=12))
    spread <- ggplotly(spread) %>% add_annotations( text="Banks", xref="paper", yref="paper",
                x=1.02, xanchor="left",
                y=0.8, yanchor="bottom",    # Same y as legend below
                legendtitle=TRUE, showarrow=FALSE ) %>% layout( legend=list(y=0.8, yanchor="top" ) )
    }

#' Prepare dataset for showcase
#'
#' @param dt data.table
#' @return data.table
prepare_summary <- function(dt) {
    banks <- data.table(SOURCE=sort(unique(dt$SOURCE)))
    aggregated <- dt %>% group_by(SOURCE) 
    # summarise(aggregated, )
    data <- left_join(banks,  aggregated, by= "SOURCE")
    # sapply(data, summary)
    data
}

#' Prepare frequency plot
#'
#' @param dt data.table
#' @param dom
#' @param yAxisLabel
#' @param desc
#' @return plot

plot_spread_histograms <- function(dt, dom, yAxisLabel, desc = FALSE) {
    molted = melt(dt, id=c("FEED_TIME", "SOURCE"), value.name = "Spread") %>% arrange(FEED_TIME, if (desc) { desc(variable) } else { variable })
    molted$variable <- as.character(molted$variable)
    molted$SOURCE <- as.character(molted$SOURCE)
    molted$FEED_TIME <- as.POSIXct(molted$FEED_TIME, format="%H:%M:%S") 

    bar_width <- 5
    histSize <- ggplot(data=molted,
            aes(x=FEED_TIME, y=Spread, colour=SOURCE)) + 
            geom_bar(position="identity", stat="identity", width=bar_width) + 
            xlab("Date") + ylab("Spread") + theme(legend.title = element_blank(),
                                            axis.text.y  = element_text(size=12),
                                            axis.title.y  = element_text(size=12),
                                            axis.text.x  = element_text(size=12, angle=45, hjust=1),
                                            axis.title.x  = element_text(size=12))
    histSize <- ggplotly(histSize) %>% add_annotations( 
                text="Banks", xref="paper", yref="paper",
                x=1.02, xanchor="left",
                y=0.8, yanchor="bottom",    # Same y as legend below
                legendtitle=TRUE, showarrow=FALSE ) %>% layout( legend=list(y=0.8, yanchor="top" ) )
    }

#' Prepare box plot
#'
#' @param dt data.table
#' @param dom
#' @param yAxisLabel
#' @param desc
#' @return plot

plot_spread_boxplot <- function(dt, dom, yAxisLabel, desc = FALSE) {
    molted = melt(dt, id=c("FEED_TIME", "SOURCE"), value.name = "Spread") %>% arrange(FEED_TIME, if (desc) { desc(variable) } else { variable })
    molted$variable <- as.character(molted$variable)
    molted$SOURCE <- as.character(molted$SOURCE)
    molted$FEED_TIME <- as.POSIXct(molted$FEED_TIME, format="%H:%M:%S") 

    p <- ggplot(data=molted, aes(x=factor(SOURCE), y=Spread, colour=SOURCE))

    boxPlot <- p + geom_boxplot(notch = TRUE) +  ylab("Spread") + 
            xlab("BANKS") +  theme(legend.title = element_blank(),
                                            axis.text.y  = element_text(size=12),
                                            axis.title.y  = element_text(size=12),
                                            axis.text.x  = element_text(size=12, angle=45, hjust=1),
                                            axis.title.x  = element_text(size=12))
    boxPlot <- ggplotly(boxPlot) %>% add_annotations( 
                text="Banks", xref="paper", yref="paper",
                x=1.02, xanchor="left",
                y=0.8, yanchor="bottom",    # Same y as legend below
                legendtitle=TRUE, showarrow=FALSE ) %>% layout( legend=list(y=0.8, yanchor="top" ) )
    }