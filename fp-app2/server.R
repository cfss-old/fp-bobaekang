# load packages
library(shiny)
library(DT)
library(tidyverse)
library(stringr)
library(feather)

# Read the data
toOutput <- read_feather("to_output.feather")

# add month variable, select only variables that matter here
appInput <- toOutput %>%
  mutate(month = format(toOutput$stoptime, "%b")) %>%
  select(usertype, gender, birthyear, month, multimode, tripduration)

shinyServer(function(input, output) {
  filtered <- reactive({
    appInput %>%
      filter(
        usertype == input$usertypeInput,
        month == input$monthInput,
        multimode == input$modeInput
      )
  })
  
  output$results <- renderDataTable({
    filtered <- appInput %>%
      filter(
        usertype == input$usertypeInput,
        month == input$monthInput,
        multimode == input$modeInput
      )
    filtered()
  })
  
  output$resultsnum <- renderText({
    if (is.null(nrow(filtered()))) {
      return()
    } else if (nrow(filtered()) == 0){
      return("We found nothing... Try other options!")
    } else if (nrow(filtered()) == 1) {
      return("We found 1 trip matching your choices!")
    } else {
      str_c("We found ", nrow(filtered()), " trips matching your choices!")
    } 
  })
  
  output$coolplot <- renderPlot({
    ggplot() +
      geom_freqpoly(data = filtered(),
                 aes(x = tripduration),
                 color = "blue") +
      ggtitle("Search Result") +
      theme_bw()
  })
    
  output$downloadData <- downloadHandler(
    filename = function(){
      paste("Divvy-Multimodal-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(filtered(), file)
    }
  )
}
)