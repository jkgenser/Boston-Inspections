setwd("H:/USER/JGenser/Rats")

library('plyr')
library('lubridate')
library('leaflet')
library('stringr')
library('shiny')
options(stringsAsFactors = FALSE)

df = read.csv("food_inspections.csv")


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
  
  colorBy <-input$color
  sizeBy <- input$size
  
  colorData <- df[[colorBy]]
  if (colorBy == "LICSTATUS"){
    pal <- colorBin("Set1", colorData)} else{}
  pal <- colorFactor("Set1",colorData)
  
  
  radius <- df[[sizeBy]] * 2
  
  
  leafletProxy("map",data = df)%>%
    clearMarkers() %>%
    addCircleMarkers(data = df, radius=radius, group = "Circle",
                     stroke=FALSE, fillOpacity=0.8, fillColor="red", popup = as.character(df$BusinessName))
  
})

})