#setwd("H:/USER/JGenser/Rats")

library('plyr')
library('lubridate')
library('leaflet')
library('stringr')
library('shiny')
library('data.table')
library('leaflet')
library('RColorBrewer')

options(stringsAsFactors = FALSE)

df = read.csv("food_inspections_dev.csv")

###############
#  CLEANING   #
###############

#make comments uppercase
df$Comments = toupper(df$Comments)
#convert dates to POSIXct
df$RESULTDTTM = as.POSIXct(df$RESULTDTTM, format="%m/%d/%Y", tz='UTC')
#create year variable
df$year = as.numeric(year(df$RESULTDTTM))

##function to truncate the dataset
subsetFunc <- function(df, status, violations, timeframe){
  ##period is a string of length representing the time-frame
  df <- df[df$year %between% timeframe,]
  df <- df[df$LICSTATUS %in% status & df$ViolDesc %in% violations,]
  set = count(df, c("LICSTATUS",'BusinessName','Latitude','Longitude', 'ViolDesc'))
  return(set)
}

##create color palette
numColors <- length(levels(as.factor(df$ViolDesc)))
pal <- colorFactor("Set1", df$ViolDesc)

##get entry
# getEntry <- function()

###########
#   DEV   #
###########

# status = 'Active'
# violations =  c("Good Hygienic Practices",
#                 "Adequate Handwashing/Where/When/How",
#                 'Sewage and Waste Water',
#                 "Insects  Rodents  Animals"
#                 )
#                 
# timeframe = c(2008,2015)
# 
# test = subsetFunc(df, status, violations, timeframe)

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

  observe({
    ##subset the data
    data <- subsetFunc(df, input$status, input$violations, input$period)
  
    ##size by the frequency
    radius = data$freq
    
    ##plot markers
    if(nrow(data)==0){
      leafletProxy("map") %>% clearMarkers()
    }else{
      
      leafletProxy("map", data = data) %>%
        clearMarkers() %>%
        addCircleMarkers(data = data, radius=radius, stroke=F, fillOpacity=0.5, 
                         popup = as.character(data$BusinessName), 
                         fillColor=pal(data$ViolDesc)) %>%
        addLegend("bottomleft", pal=pal, values=data$ViolDesc, title="Violation Type",
                  layerId="colorLegend")
    }
  })

})