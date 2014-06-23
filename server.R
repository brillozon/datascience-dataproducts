library(shiny)
library(quantmod)

options("getSymbols.warning4.0"=FALSE)
symbolList <<- c('QQQ','SPY','WAB','DIG','DUG')
getSymbols(symbolList,env=globalenv())

loadOne <- function(sym) {
  getSymbols(sym,env=globalenv())
}

shinyServer(function(input,output,session) {
  observe({
    input$addsymbol
    s <- isolate(input$newsymbol)
    pattern <- paste('^',s,'$',sep='')
    if(0 == length(grep(pattern,symbolList))) {
      symbolList <<- c(symbolList,s)
      updateSelectInput(session,"activesymbol",
                        choices=symbolList,selected=s)
      loadOne(s)
    }
  })
  output$chart <- renderPlot({
    if(!is.null(input$activesymbol)) {
      oldest <- index(get(input$activesymbol)
                      [,paste(input$activesymbol,'.Close',sep='')]
                      [1])
      youngest <- index(get(input$activesymbol)
                      [,paste(input$activesymbol,'.Close',sep='')]
                      [dim(get(input$activesymbol))[1]])
      first <- input$chartRange[1]
      last <- input$chartRange[2]
      if(oldest > first) {
        first <- oldest
      }
      if(youngest < last) {
        last <- youngest
      }
      updateDateRangeInput(session,"chartRange",start=first,end=last,
                           min=oldest,max=youngest)
      chartSeries(get(input$activesymbol),name=input$activesymbol,
                  subset=paste(input$chartRange[1],input$chartRange[2],sep='::'),
                  theme=chartTheme('wsj'))
    }
  })
  output$periodreturn <- renderText({
    # Range is restricted in the control so we don't have to check here.
    t1 <- input$chartRange[1]
    t2 <- input$chartRange[2]
    days <- t2 - t1

    sym <- input$activesymbol
    prices <- get(sym)[,paste(sym,'.Close',sep='')]

    p1 <- prices[paste(t1,'/',sep='')][1]
    
    lastdates <- index(prices[paste((t2-30),'/',t2,sep='')])
    p2 <- prices[lastdates[length(lastdates)]]
    gain = as.numeric(p2) / as.numeric(p1)

    arr <- log(gain) * 365 / as.numeric(days)
    paste("Annualized return over ",days," days: ",
          format(100 * arr,scientific=F,digits=2),"%",sep='')
  })
})
