library(shiny)
library(leaflet)
##choices for menu

##choice for whether status is active or inactive
bstatus <- c(
  'Active' = 'Active',
  'Inactive' = 'Inactive'
)

##choice for which violations to see
violationType <- c(
  'Cockroaches' = 'Cockroaches',
  'Rodents' = 'Rodents',
  'Unhygienic' = "Unhygienic",
  'Unsafe food preparation' = 'Unsafe food preparation',
  'Unlicensed pesticide use' ='Unlicensed pesticide use'
)


shinyUI(navbarPage('Boston Food Inspections', id="nav",
  tabPanel("Interactive map",
           div(class="outer",
               
               tags$head(
               includeCSS("styles.css")
               ),
           leafletOutput("map", width="100%", height = "100%"),
           
           absolutePanel(id ="controls", class ="panel panel-default", fixed=TRUE,
                         draggable=TRUE, top=60, left='auto', right=20, bottom='auto',
                         width=300, height='auto',
                         checkboxGroupInput("status", h4("Business License Status"), bstatus,
                                            selected = "Active"),
                         checkboxGroupInput("violations", h4("Violation"), violationType, 
                                            selected="Rodents"),
                         sliderInput('period', h4("Select Time Period"),
                                     min = 2008,
                                     max = 2015,
                                     value = c(2008,2008),
                                     sep="", step=1, ticks=FALSE,animate=animationOptions(loop=T), round=TRUE),
                         tags$script("$(document).ready(function(){
                                      setTimeout(function() {$('.slider-animate-button').click()},15000);
                                     });")
                        )
           )
  ),
  tabPanel("Free text search",
           sidebarLayout(
             sidebarPanel(width = 3, 
                          textInput("search", h4("Type your keywords here"), "cockroach"),
                          code("returns random 100 rows"),
                          br(),
                          br(),
                          checkboxGroupInput("status2", h4("Business License Status"), bstatus,
                                             selected = "Active"),
                          checkboxGroupInput("violations2", h4("Violation"), violationType, 
                                             selected=violationType)
             ),
             mainPanel(
               uiOutput("ui")
             )
           )),
  tabPanel("Discussion",
           img(src = 'comment.png', style='margin-left: 10px'),
           div(style = 'margin-left: 350px; margin-top:-260px',
               includeCSS("styles.css"),
               h4("Motivation"),
               p("This project was created to geographically visualize where food inspection violations are concentrated in the city of Boston. With a more thorough understanding of where these are, local governments can focus their limited resources on communities that need them the most."),
               p("We deliberately removed all business-identifying information. Our goal here is not to target individual restaurants, but rather to channel resources to areas that require more attention."),
               h4("Methodology"),
               p("We first downloaded food inspection data from Boston's online data repository. We then removed all \'Passed\' records in the", em("ViolStatus"), "column from the dataset, as well as the (very few) \'Deleted\' from the", em("LICSTATUS"), "column."),
               p("We used the given latitude and longitudes to build the map. However, many of these were not given although a complete address was. To overcome this, we passed the addresses without coordinates through Google\'s", strong("Geocoding API"), "to resolve the coordinates. For the few records that had neither addresses nor coordinates, we dropped."),
               p("We filtered the dataset for only notable violation types - for example, many were signage or labeling violations and they crowded the results."),
               h4("Sources"),
               p("All data was downloaded from", a("the city of Boston's public data repository.", href="https://data.cityofboston.gov/Health/Food-Establishment-Inspections/qndu-wx8w")),
               h4("Authors"),
               p(a("Jerry Genser", href="http://www.jerrygenser.com")),
               p(a("Alex Petralia", href="http://www.alexpetralia.com")),
               br()
           )
  )
  
))