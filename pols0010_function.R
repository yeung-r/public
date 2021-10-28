# Set working directory

# Load spatstat package for Ripley's K function
library(spatstat)
library(sp)
# Load rgdal package for readOGR function
library(rgdal)
# For dbscan and kNNdistplot
library(dbscan)
library(grid)
library(gridExtra)
library(tmap)

epsilon <- function(){
  eps <- (readline("Referring to the plot titled 'K', identify the elbow value: "))
  eps <- as.numeric(eps)
  list(eps=eps)
}

dbscan_map <- function(point.data, col, main.title){
  # Ensure the palette is set as default, with black colour applied to zero value
  palette("default")
  # Create tmap object for the dbscan with specified epsilon
  tm_shape(point.data) + 
    tm_dots(col = col, scale=1.5, palette=palette(), style="cat") +
    tm_layout(main.title = main.title, main.title.size = 1, legend.outside = TRUE, frame=F) +
    tm_compass(position = c("right", "top"), size = 1.5) +
    tm_graticules(n.x=4, n.y=3, col = "gray70", alpha=.4) +
    tm_xlab("Longitude") +
    tm_ylab("Latitude")
}

dbscan_autoeps <- function(point.data, minPts){
  # Extract the x and y coordinates from the spatial points dataframe
  points.coords <- data.frame(point.data@coords[,1:2])
  # Calculate the average of the distances of every point to its k nearest neighbors with nearest neighbour distance function
  kNNdistplot(points.coords, k =  minPts)
  # Referring to the graph generated with KNNdisplot, user determine the epsilon and type it
  input1 <- epsilon()
  list2env(input1, environment())
  # Carry out dbscan
  db1 <- dbscan(points.coords, eps = eps, minPts = minPts)
  #Bind the cluster part of the dbscan into the original spatialpointsdataframe
  point.data$cluster1 <- db1$cluster
  point.data$cluster1 <- as.factor(point.data$cluster1)
  map1 <- dbscan_map(point.data, "cluster1", "DBScan")
  print(map1)
  if (isTRUE(askYesNo("In case the elbow was not clear, would you like to create another dbscan map with another epsilon?"))){
    kNNdistplot(points.coords, k =  minPts)
    input2 <- epsilon()
    list2env(input2, environment())
    db2 <- dbscan(points.coords, eps = eps, minPts = minPts)
    #Bind the cluster part of the dbscan into the original spatialpointsdataframe
    point.data$cluster2 <- db2$cluster
    point.data$cluster2 <- as.factor(point.data$cluster2)
    map2 <- dbscan_map(point.data, "cluster2", "DBScan 2")
    grid.newpage()
    # assigns the cell size of the grid, in this case 2 by 1
    pushViewport(viewport(layout=grid.layout(1,2)))
    # prints a map object into a defined cell   
    print(map1, vp=viewport(layout.pos.col = 1, layout.pos.row =1))
    print(map2, vp=viewport(layout.pos.col = 2, layout.pos.row =1))
    if (askYesNo("Would you like to run a third dbscan with another epsilon value?")==TRUE){
      kNNdistplot(points.coords, k =  minPts)
      input3 <- epsilon()
      list2env(input3, environment())
      db3 <- dbscan(points.coords, eps = eps, minPts = minPts)
      #Bind the cluster part of the dbscan into the original spatialpointsdataframe
      point.data$cluster3 <- db3$cluster
      point.data$cluster3 <- as.factor(point.data$cluster3)
      map3 <- dbscan_map(point.data, "cluster3", "DBScan 3")
      grid.newpage()
      # assigns the cell size of the grid, in this case 2 by 1
      pushViewport(viewport(layout=grid.layout(2,2)))
      # prints a map object into a defined cell   
      print(map1, vp=viewport(layout.pos.col = 1, layout.pos.row =1))
      print(map2, vp=viewport(layout.pos.col = 2, layout.pos.row =1))
      print(map3, vp=viewport(layout.pos.col = 1, layout.pos.row =2))
      if (askYesNo("Would you like to run a fourth dbscan with another epsilon value?")==TRUE){
        kNNdistplot(points.coords, k =  minPts)
        input4 <- epsilon()
        list2env(input4, environment())
        db4 <- dbscan(points.coords, eps = eps, minPts = minPts)
        #Bind the cluster part of the dbscan into the original spatialpointsdataframe
        point.data$cluster4 <- db4$cluster
        point.data$cluster4 <- as.factor(point.data$cluster4)
        map4 <- dbscan_map(point.data, "cluster4", "DBScan 4")
        grid.newpage()
        # assigns the cell size of the grid, in this case 2 by 1
        pushViewport(viewport(layout=grid.layout(2,2)))
        # prints a map object into a defined cell   
        print(map1, vp=viewport(layout.pos.col = 1, layout.pos.row =1))
        print(map2, vp=viewport(layout.pos.col = 2, layout.pos.row =1))
        print(map3, vp=viewport(layout.pos.col = 1, layout.pos.row =2))
        print(map4, vp=viewport(layout.pos.col = 2, layout.pos.row =2))
      }
    }
  }
}

House.Points <- readOGR("worksheet_data/camden", "Camden_house_sales")
dbscan_autoeps(House.Points, 5)

Crime.Data <- read.csv("2020-07/2020-07-metropolitan-street.csv")
police_data<- Crime.Data[grepl('Kensington', Crime.Data$LSOA.name),]
#By using FUN=length we are asking that the aggregate function counts the number of times a crime.ID appears at a location.
crime_count_raw<- aggregate(police_data$Crime.ID, by=list(police_data$Longitude, police_data$Latitude,police_data$LSOA.code,police_data$Crime.type), FUN=length)
#We need to rename our columns (note these are abbreviated from the originals)
names(crime_count_raw)<- c("Long","Lat","LSOA","Crime","Count")
#Subset to antisocial behaviour
crime_count_asb<- crime_count_raw[which(crime_count_raw$Crime=="Anti-social behaviour"),]
#spatial points
crime_count_sp<- SpatialPointsDataFrame(crime_count_asb[,1:2], crime_count_asb, proj4string = CRS("+init=epsg:4326"))
#Reproject into British National Grid - EPSG 27700
crime_count<-spTransform(crime_count_sp, CRS("+init=epsg:27700"))
dbscan_autoeps(crime_count_sp, 5)

Food.Data <- read.csv("Los_Angeles_County_Food_Pantry.csv")
food_count_raw<- aggregate(Food.Data$X., by=list(Food.Data$Longitude, Food.Data$Latitude), FUN=length)
food_count_sp<- SpatialPointsDataFrame(food_count_raw[,1:2], food_count_raw, proj4string = CRS("+init=epsg:3310"))
dbscan_autoeps(food_count_sp, 5)

Bike.Data <- read.csv("Locations_of_Docked_Bikeshare_Stations_by_System_and_Year.csv")
bike_count_sp<- SpatialPointsDataFrame(Bike.Data[,15:16], Bike.Data, proj4string = CRS("+init=epsg:4326"))
dbscan_autoeps(bike_count_sp, 5)
