# load packages
library(shiny)
library(DT)
library(tidyverse)
library(stringr)
library(feather)
library(ggmap)
library(mapproj)

# Read the data
toOutput <- read_feather("to_output.feather")

# add month variable, select only variables that matter here
appInput <- toOutput %>%
  mutate(month = format(toOutput$stoptime, "%b")) %>%
  select(usertype, month, multimode, to_station_name, to_lon, to_lat)

# chicago map
ChicagoMap <- ggmap(
  get_googlemap(
    center = c(lon = -87.68, lat = 41.91),
    zoom = 11)
)


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
    if (is.null(filtered())) {
      ChicagoMap
    }
    ChicagoMap +
      geom_point(data = filtered(),
                 aes(x = to_lon, y = to_lat),
                     color = 'blue',
                     alpha = .3,
                     size = 3) +
      ggtitle("Search Result") +
      xlab("Longitude") +
      ylab("Latitude")
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