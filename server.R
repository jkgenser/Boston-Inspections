#setwd("H:/USER/JGenser/Rats")

#library('plyr')
library('lubridate')
library('leaflet')
library('stringr')
library('shiny')
#library('data.table')
library('leaflet')
library('RColorBrewer')
library('dplyr')

options(stringsAsFactors = FALSE)

df = read.csv("MASTER_food_inspections.csv")


###############
#  CLEANING   #
###############

#make comments uppercase
df$Comments = toupper(df$Comments)
#convert dates to POSIXct
df$RESULTDTTM = as.POSIXct(df$RESULTDTTM, format="%m/%d/%Y", tz='UTC')
#create year variable
df$year = as.numeric(year(df$RESULTDTTM))
#create business id
df$busID <- as.numeric(as.factor(paste(df$BusinessName, df$Latitude, df$Longitude)))
#gen freq variable
df$freq = 1

###############
#  FUNCTIONS  #
###############

##function to truncate the dataset
subsetFunc <- function(df, status, violations, timeframe){
  ##period is a string of length representing the time-frame
  df <- filter(df, year >= timeframe[1], year <= timeframe[2])
  df <- df[df$LICSTATUS %in% status & df$ViolDesc %in% violations,]
  set = df %>% group_by(LICSTATUS, BusinessName, Latitude, Longitude, ViolDesc, busID) %>% summarise(freq = sum(freq)) %>% as.data.frame
  return(set)
}

##create color palette
numColors <- length(levels(as.factor(df$ViolDesc)))
pal <- colorFactor("Set1", df$ViolDesc)

 
###########
#   DEV   #
###########
# 


###########
#   DEV   #
###########


shinyServer(function(input, output) {
  
  
##create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -71.083, lat=42.353, zoom=13)
    
  })
  getData <-reactive({
    subsetFunc(df,input$status, input$violations, input$period)
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
        addCircles(data = data, radius=radius, stroke=F, fillOpacity=0.3, 
                         fillColor=pal(data$ViolDesc)) %>%
        addLegend("bottomleft", pal=pal, values=data$ViolDesc, title="Violation Type",
                  layerId="colorLegend")
    }
  })
  
  
  search <- reactive({
    df <- df[df$LICSTATUS %in% input$status2 & df$ViolDesc %in% input$violations2, ]    
    subset <- df[grep(input$search, df$Comments, ignore.case=TRUE), ]$Comments %>% as.data.frame
    t <- subset[sample(nrow(subset), 100, replace=TRUE), ] %>% as.data.frame
    t <- sapply(t, tolower)
    if(nrow(t)>0) {return(t)}
  })
  
  output$table <- renderTable({
    return(search())
  }, 
  include.rownames = FALSE,
  include.colnames = FALSE)
  
  output$ui <- renderUI({
    if (nrow(search()) == 0) {
      return(em("No data to show")) }
    
    tableOutput("table")
  })

})