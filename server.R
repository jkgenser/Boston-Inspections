#setwd("H:/USER/JGenser/Rats")

library('lubridate')
library('leaflet')
library('stringr')
library('shiny')
library('leaflet')
library('RColorBrewer')
library('dplyr')

##import data
options(stringsAsFactors = FALSE)
df = read.csv("MASTER_food_inspections.csv")

##list of violation types that will appear on the map
violationList <- c(
  'Unhygienic',
  'Unsafe food preparation',
  'Unlicensed pesticide use',
  'Rodents',
  'Cockroaches'
)


###############
#  CLEANING   #
###############


#make comments uppercase
df$Comments = toupper(df$Comments)
#convert dates to POSIXct
df$RESULTDTTM = as.POSIXct(df$RESULTDTTM, format="%m/%d/%Y", tz='UTC')
#create year variable
df$year = as.numeric(year(df$RESULTDTTM))
#drop records before 2008
df = df[df$year>2007,]
#create business id
df$busID <- as.numeric(as.factor(paste(df$BusinessName, df$Latitude, df$Longitude)))
#gen freq variable
df$freq = 1
#grep comments field to slightly modify the ViolDesc variable
df[grep('dropping', df$Comments, ignore.case=TRUE),]$ViolDesc  <- 'Rodents'
df[grep('cockroach', df$Comments, ignore.case=TRUE),]$ViolDesc <- 'Cockroaches'
###############
#  FUNCTIONS  #
###############

##function to truncate the dataset
subsetFunc <- function(df, status, violations, timeframe, search){
  ##period is a string of length representing the time-frame
  df <- filter(df, year >= timeframe[1], year <= timeframe[2])
  df <- df[df$LICSTATUS %in% status & df$ViolDesc %in% violations,]
  set = df %>% group_by(LICSTATUS, BusinessName, Latitude, Longitude, ViolDesc, busID) %>% summarise(freq = sum(freq)) %>% as.data.frame
  return(set)
}

##create color palette only for violation types that will appear on the map
pal <- colorFactor("Spectral", df$ViolDesc[df$ViolDesc %in% violationList])


shinyServer(function(input, output) {
  
  
##create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -71.076460, lat=42.334215, zoom=13.1)
    
  })
  getData <-reactive({
    subsetFunc(df,input$status, input$violations, input$period, input$search)
  })
  
  getDesc <-reactive({
    data = getData()
    getEntry(data)
  })


  observe({
    ##subset the data
    data <- getData()
    
    
    ##size by the frequency
    radius = data$freq *20
    radius2 = data$freq*4
    
    ##plot markers
    if(nrow(data)==0){
      leafletProxy("map") %>% clearShapes() %>% clearMarkers()
    }else{
      
      leafletProxy("map", data = data) %>%
        clearShapes() %>%
        clearMarkers() %>%
        addCircles(data = data, radius=radius, stroke=F, fillOpacity=0.7, 
                         fillColor=pal(data$ViolDesc)) %>%
        addLegend("bottomleft", pal=pal, values=data$ViolDesc, title="Violation Type",
                  layerId="colorLegend")
    }
  })
  
    search <- reactive({
      df <- df[df$LICSTATUS %in% input$status2 & df$ViolDesc %in% input$violations2, ]    
      subset <- df[grep(input$search, df$Comments, ignore.case=TRUE), ]$Comments %>% as.data.frame
      if(nrow(subset) > 100) {
        subset <- subset[sample(nrow(subset), 100, replace=FALSE), ] %>% as.data.frame}
      if (nrow(subset) > 0) {
        subset <- sapply(subset, tolower) }
      return(subset)
    })
    
    output$table <- renderTable({
      return(search())
    }, 
    include.rownames = FALSE,
    include.colnames = FALSE)
    
    output$ui <- renderUI({
      if (nrow(search()) == 0)
        return(em("No data to show"))
      
      tableOutput("table")
    })

})