##choices for menu

library('plyr')
library('lubridate')
library('leaflet')
library('stringr')
library('shiny')
library('data.table')
library('leaflet')

##choice for whether status is active or inactive
bstatus <- c(
  'Active' = 'Active',
  'Deleted' = 'Deleted',
  'Inactive' = 'Inactive'
)

##choice for which violations to see
violationType <- c(
  'Rodents, Insects, Animals' = "Insects  Rodents  Animals",
  'Handwashing' = "Adequate Handwashing/Where/When/How",
  'Hygeine' = "Good Hygienic Practices",
  'Sewage and Wastewater' = 'Sewage and Waste Water'
)

shinyUI(navbarPage("Boston Food Inspections", id="nav",
  tabPanel("Interactive map",
           div(class="outer",
               
               tags$head(
               includeCSS("styles.css")
               ),
           leafletOutput("map", width="100%", height = "100%"),
           
           absolutePanel(id ="controls", class ="panel panel-default", fixed=TRUE,
                         draggable=TRUE, top=60, left='auto', right=20, bottom='auto',
                         width=300, height='auto',
                         checkboxGroupInput("status", "Business License Status", bstatus,
                                            selected = "Active"),
                         checkboxGroupInput("violations", "Violation", violationType, 
                                            selected="Insects  Rodents  Animals"),
                         sliderInput('period', h4("Select Time Period"),
                                     min = 2006,
                                     max = 2015,
                                     value = c(2014,2015),
                                     sep="", step=1, ticks=F,animate=T, round=T)
          
                        )
           )
  )
  
))