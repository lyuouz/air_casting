library(shiny)

# Define UI ----
ui <- fluidPage(
  
  titlePanel("AirCasting Data Analysis"),
  
  sidebarLayout(
    sidebarPanel(
      helpText('Customize your analysis using the AirBeam data'),
      dateRangeInput("dates", h4("Choose start and end date"))
      
      ),
  
    
    mainPanel()
  )
      
  
)

# Define server logic ----
server <- function(input, output) {
  
  
  
  
  
  
  
  
  
}

# Run the app ----
shinyApp(ui = ui, server = server)