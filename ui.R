library(shiny)

shinyUI(fluidPage(
  titlePanel("Charting Prices over Time"),
  sidebarLayout(position="right",
    sidebarPanel(h2("Inputs"),
      dateRangeInput("chartRange",label='Chart Range',
                     start=as.Date(seq(Sys.time(),
                                       by="-4 week",
                                       length.out=2)[2])),
      wellPanel(
        selectInput(inputId="activesymbol",label='Symbol',
                    choices=c('SPY'='SPY','QQQ'='QQQ','WAB'='WAB',
                              'DIG'='DIG','DUG'='DUG'),
                    selected='SPY'),
        textInput("newsymbol","New Symbol:",'PCL'),
        actionButton("addsymbol",'Add')
      ),
      textOutput("periodreturn")),
    mainPanel(plotOutput("chart"),
              h4("Candlestick View"),
              p("This application will calculate the annualized rate of return for a security over a selected period."),
              p("The security can be selected from the drop-down list, or a new security can be added to the drop-down by typing it into the input area, then activating the \"Add\" button."),
              p("The date range can be selected by picking the start date and the end date from the two calendar selectors.  The nearest market day after the selected first date and prior to the selected last date will be used for calculating the returns.  The period over which the return is annualized is the original selected range."),
              p("Security data is obtained from Yahoo Finance, so only those securities available from them can be viewed and returns calcualted.  The calendar range selections are adjusted to allow only dates for which data was provided to be selected.  Only daily OHLC (Open, High, Low, Close) price data is displayed, with the Adjusted closing price used for return calculations.")
              )
  )
))
