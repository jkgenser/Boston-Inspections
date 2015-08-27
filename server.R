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

#df = read.csv("MASTER_food_inspections.csv")


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

#create function that retrieves value to be printed for popup
getEntry <- function(df){
  output <- df %>% select(busID, Latitude, Longitude) %>% unique()
  row.names(output) <- NULL
  #row.names() <- 1:nrow(output)
  for (i in 1:nrow(df)){
    busID = df[i,6]
    subData = df[df$busID == busID,]
    violSum=NULL
    for (j in 1:nrow(subData)){
      violSum = violSum %>% paste0(sprintf("%s: %s", subData[j,5], subData[j,7]),'\n')
    }
  output[i,4] <- paste0(busName, ':\n', violSum, collapse='\n')
  #cat(descriptions[i,4])
  
  }
  return(output)
}

 
###########
#   DEV   #
###########
# 
status = 'Active'
violations =  c("Good Hygienic Practices",
                "Adequate Handwashing/Where/When/How",
                'Sewage and Waste Water',
                "Insects  Rodents  Animals"
                )
                
timeframe = c(2010,2015)
# 
test = subsetFunc(df, status, violations, timeframe)
# 
# 
# newID <- 10
# 
# 
# as.character(test2)
# display <- as.character(
#             paste(test2[1,2],
#             test2[5],
#             test2[6])
#            )
# 
#######take data and return a vector of busIDs and violation summaries
# descriptions = test %>% select(busID, Latitude, Longitude) %>% unique
# row.names(descriptions) <- NULL
# row.names(descriptions) = 1:nrow(descriptions)
# for (i in 1:nrow(test)){
#   print(i)
#   busID = test[i,6]
#   subData = test[test$busID == busID,]
#   busName = subData[1,2] %>% as.character
#   print(busName)
#   violSum=NULL
#   for(j in 1:nrow(subData)){
#     violSum = violSum %>% paste0(sprintf("%s: %s", subData[j,5], subData[j,7]),"\n")
#     print(violSum)
#   }
#   descriptions[i,4] <- paste0(busName, ":\n", violSum)
#   cat(descriptions[i,4])
# }

# 
# str = NULL
# for (i in 1:nrow(test)){
#   busID = test[i,6]
#   sub = df[df$busID == busID,] %>% as.data.frame
#   busName = subset[1,2] %>% as.character
#   summ=NULL
#     for (i in 1:nrow(sub)){
#     summ = summ %>% append(sprintf("%s: %s", sub[j,5], sub[j,7]))
#     # busName = busName %>% append(c("\n", summ))
#     }
#   busName = busName %>% paste0(summ,collapse="\n")
#   str = str %>% paste0(busName,collapse="\n")
# }
# 
# for (i in 1:nrow(test)){
#   print(test[i,7])
# }
# 
# busName = test2[1,2] %>% as.character
# violString = NULL
# countString = NULL
# summ=NULL
# for (j in 1:nrow(test2)) {
#  summ = summ %>% c(sprintf("%s: %s\n", test2[j,5], test2[j,7]))
#  
# }
# busName = busName %>% c("\n",summ)
# z = print(paste0(busName,collapse="\n"))
# 
# 
# 
# for (j in 1:nrow(test2)) {
# violString = violString %>% append(test2[j,5])
# countString = countString %>% append(test2[j,7])
# }
# 
# show = NULL
# for (i in length(violString)){
#   show = show %>%append(sprintf("%s: %s", violString[i], countString[i]))  
# }
# 
# 
# 
# # y <- paste(busName, test[i,5], test2[i,6])
# # sprintf("%s: %s",test2[i,5], test2[i,6])
# 
# 
# result <- as.character(
#   paste0()
# )

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

})