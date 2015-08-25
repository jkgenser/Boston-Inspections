##choices for menu

##choice for whether status is active or inactive
vars <- c(
  'Active' = 'Active',
  'Deleted' = 'Deleted',
  'Inactive' = 'Inactive'
)

##choice for which violations to see
vars2 <- c(
  'Rodents, Insects, Animals' = "Insects  Rodents  Animals",
  'Handwashing' = "Adequate Handwashing/Where/When/How",
  'Hygeine' = "Good Hygienic Practices",
  'Sewage and Wastewater' = 'Sewage and Waste Water'
)


shinyUI(fluidPage(
  tabPanel("Interactive map",
           leafletOutput("map", width=1080, height = 720),
           
           absolutePanel(id = "controls", class ="panel panel-default", fixed=TRUE,
                         draggable=TRUE, top=60, left='auto', right=20, bottom='auto',
                         width=220, height='auto',
                         checkboxInput("cluster", "Add Cluster"),
                         selectInput("color", "Color", vars),
                         selectInput("size", "Size", vars2, selected="freq")
           ),
           
  tabPanel("Bar graph",
           br(),
           div(
             p("test"),
             p("test2")
            )
  )
))