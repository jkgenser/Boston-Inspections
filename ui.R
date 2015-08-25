##choices for menu
vars <- c(
  'Active' = 'LICSTATUS'
)

vars2 <- c(
  'Frequency' = 'freq'
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
           )
  )
))