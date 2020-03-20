library(ggplot2)

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

#' Prepare plots of Bid and Ask
#'
#' @param dt data.table
#' @param dom
#' @param yAxisLabel
#' @param desc
#' @return plot
#' 
plot_bid_ask_by_bank <- function(dt, dom, yAxisLabel, desc = FALSE) {
    molted = melt(dt, id=c("FEED_TIME", "SOURCE")) %>% arrange(FEED_TIME, if (desc) { desc(variable) } else { variable })
    molted$variable <- as.character(molted$variable)
    molted$SOURCE <- as.character(molted$SOURCE)
    molted$FEED_TIME <- as.POSIXct(molted$FEED_TIME, format="%Y/%m/%d %H:%M:%S")

    bidAsk <- ggplot(data=molted,
             aes(x=FEED_TIME, y=value, colour=SOURCE, group=SOURCE)) + geom_line(aes(group=factor(SOURCE)),size=2) + 
              xlab("Date") + ylab("Prices") + theme(axis.text.y  = element_text(size=20),
                                              axis.title.y  = element_text(size=28),
                                              axis.text.x  = element_text(size=20, angle=45, hjust=1),
                                              axis.title.x  = element_text(size=26))
    bidAsk
    }

#' Prepare plot of size of ask and bid by bank
#'
#' @param dt data.table
#' @param dom
#' @param yAxisLabel
#' @param desc
#' @return plot

plot_size_by_bank <- function(dt, dom, yAxisLabel, desc = FALSE) {
    molted = melt(dt, id=c("FEED_TIME", "SOURCE")) %>% arrange(FEED_TIME, if (desc) { desc(variable) } else { variable })
    molted$variable <- as.character(molted$variable)
    molted$SOURCE <- as.character(molted$SOURCE)
    molted$FEED_TIME <- as.POSIXct(molted$FEED_TIME, format="%Y/%m/%d %H:%M:%S")

    bidSizeAskSize <- ggplot(data=molted,
             aes(x=FEED_TIME, y=value / 1000000, colour=SOURCE, group=SOURCE)) + geom_line(aes(group=factor(SOURCE)),size=2) + 
              xlab("Date") + ylab("Size (In million)") + theme(axis.text.y  = element_text(size=20),
                                              axis.title.y  = element_text(size=28),
                                              axis.text.x  = element_text(size=20, angle=45, hjust=1),
                                              axis.title.x  = element_text(size=26))
    bidSizeAskSize
    }

#' Prepare plot of size of ask and bid by bank
#'
#' @param dt data.table
#' @param dom
#' @param yAxisLabel
#' @param desc
#' @return plot

plot_spread_by_bank <- function(dt, dom, yAxisLabel, desc = FALSE) {
    molted = melt(dt, id=c("FEED_TIME", "SOURCE")) %>% arrange(FEED_TIME, if (desc) { desc(variable) } else { variable })
    molted$variable <- as.character(molted$variable)
    molted$SOURCE <- as.character(molted$SOURCE)
    molted$FEED_TIME <- as.POSIXct(molted$FEED_TIME, format="%Y/%m/%d %H:%M:%S")

    spread <- ggplot(data=molted,
             aes(x=FEED_TIME, y=value, colour=SOURCE, group=SOURCE)) + geom_line(aes(group=factor(SOURCE)),size=2) + 
              xlab("Date") + ylab("Spread") + theme(axis.text.y  = element_text(size=20),
                                              axis.title.y  = element_text(size=28),
                                              axis.text.x  = element_text(size=20, angle=45, hjust=1),
                                              axis.title.x  = element_text(size=26))
    spread
    }

#' Prepare dataset for downloads
#'
#' @param dt data.table
#' @return data.table
prepare_downolads <- function(dt, selectSource) {
    banks <- data.table(SOURCE=sort(unique(dt$SOURCE)))
    aggregated <- dt %>% group_by(SOURCE) 
    data <- left_join(banks,  aggregated, by= "SOURCE") %>% filter(SOURCE==selectSource)
    data
}