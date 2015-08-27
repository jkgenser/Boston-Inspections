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
  'Inactive' = 'Inactive'
)

##choice for which violations to see
violationType <- c(
  'Handwashing' = "Adequate Handwashing/Where/When/How",
  'Warm Storage' = 'Cold Holding',
  'Not Thoroughly Cooked' = 'Cooking Temperatures',
  'Dishwashing Facilities' = 'Dishwashng Facilities',
  'Hot Holding' = 'Hot Holding',
  'Location  Accessible' = 'Location  Accessible',
  'Pesticide Usage' = 'Pesticide Usage',
  'PHF\'s Properly Thawed' = 'PHF\'s Properly Thawed',
  'Bare Hand Contact' = 'Prevention of Contamination from Hands',
  'Inadequate Reheating Temperature' = 'Reheating',
  'Raw foods stored near cooked foods' = 'Separation  Segregation Cross Contamination',
  'Separation/Sanitizer Criteria' = 'Separation/Sanitizer Criteria',
  'Spoilage Unsafe Food' = 'Spoilage Unsafe Food',
  'Toilet Enclosed Clean' = 'Toilet Enclosed Clean',
  'Washing fruits and veg\'s.' = 'Washing fruits and veg\'s.',
  'Food Contact Surfaces Clean' = 'Food Contact Surfaces Clean',
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
  ),
  tabPanel("Free text search",
           sidebarLayout(
             sidebarPanel(width = 3, 
                          textInput("search", h4("Type your keywords here"), "dropping"),
                          code("returns random 100 rows"),
                          br(),
                          br(),
                          checkboxGroupInput("status2", h4("Business License Status"), bstatus,
                                             selected = "Active"),
                          checkboxGroupInput("violations2", h4("Violation"), violationType, 
                                             selected="Insects  Rodents  Animals")
             ),
             mainPanel(
               uiOutput("ui")
               # tableOutput("table")
             )
           ))
  
))