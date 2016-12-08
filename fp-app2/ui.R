
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinythemes)
library(DT)

fluidPage(
  # Application theme
  theme = shinytheme("readable"),

  # Application title
  titlePanel("Trips to stations in proximity with CTA stops"),
  
  # Sidebar
  sidebarLayout(
    sidebarPanel(
      radioButtons("usertypeInput", "User type",
                   choices = c("Subscriber", "Customer"),
                   selected = "Subscriber"),
      selectInput("monthInput", "Month",
                  choices = c("Jan", "Feb", "Mar", "Apr", "May", "Jun"),
                  selected = "Jan"),
      radioButtons("modeInput", "Potential Multi-modality",
                   choices = c(0, 1),
                   selected = 0)
    ),
    
    # Show a table
    mainPanel(
      tags$h3(textOutput("resultsnum")),
      tags$h5(downloadLink('downloadData', 'Click here to download the result!')),
      plotOutput("coolplot"),
      dataTableOutput("results")
    )
  )
)
