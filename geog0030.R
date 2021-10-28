library(rgdal)
library(tidyverse)
library(tmap)
library(tmaptools)
library(sf)
library(spdep)
library(rosm)
library(raster)
library(spatstat)
library(sp)
library(spgwr)
library(grid)
library(gridExtra)
library(RColorBrewer)

# Load datasets
broadband <- read.csv("dataset/201805_fixed_oa11_performance_r02.csv")
iuc <- read.csv("dataset/iuc2018.csv")
wifi_points <- read_sf("dataset/wifi/E37000023.shp")
population <- read.csv("dataset/Copy of SAPE21DT10a-mid-2018-coa-unformatted-syoa-estimates-london.csv")
oa <- read_sf("dataset/ESRI/OA_2011_London_gen_MHW.shp")
lsoa <- read_sf("dataset/ESRI/LSOA_2011_London_gen_MHW.shp")

# MAP 1: AREA OF INTEREST
# Subset Islington from OA sf
oa <- subset(oa, oa$LAD11NM == "Islington")
# Load the output area shapefile as spatial polygons data frame
oa_spdf <- readOGR("dataset/ESRI", "OA_2011_London_gen_MHW")
# Subset Islington from the data frame
oa_spdf <- subset(oa_spdf, grepl('Islington', oa_spdf@data$LAD11NM) == TRUE)
# Generate basemap for our OA, crop to its bounding box
osm_basemap <- osm.raster(oa_spdf, crop=TRUE)
# Crop our osm_basemap to the extent of our islington OA
islington_osm_basemap <- crop(osm_basemap, oa_spdf)
# Create map
tm_shape(islington_osm_basemap) + 
  tm_rgb() + 
  tm_shape(oa) + 
  tm_fill(alpha = 0.3, 
          col = "blue") +
  tm_layout(main.title = "Map 1: Islington Open Street Map",
            main.title.fontface = 2, 
            fontfamily = "Helvetica", 
            frame = FALSE,
            legend.outside = TRUE) +
  tm_compass(position = c("right", "bottom")) + 
  tm_scale_bar(position = c("left", "bottom"))

# MAP 2: INTERNET USER CLASSIFICATION AND WIFI HOTSPOTS
# Subset Islington from LSOA sf
lsoa <- subset(lsoa, lsoa$LAD11NM == "Islington")
# Subset Islington data from IUC
iuc <- subset(iuc, grepl("Islington", iuc$LSOA11_NM) == TRUE)
# Recode intoo internet engagement
iuc$new_GRP_LABEL <- ifelse(iuc$GRP_CD == 1, "High",
                            ifelse(iuc$GRP_CD == 2, "High",
                                   ifelse(iuc$GRP_CD == 3, "High",
                                          ifelse(iuc$GRP_CD == 4, "Medium",
                                                 ifelse(iuc$GRP_CD == 5, "Medium",
                                                        ifelse(iuc$GRP_CD == 6, "Medium",
                                                               ifelse(iuc$GRP_CD == 7, "Low",
                                                                      ifelse(iuc$GRP_CD == 8, "Low",
                                                                             ifelse(iuc$GRP_CD == 9, "Low",
                                                                                    ifelse(iuc$GRP_CD == 10, "Low",0))))))))))
# Reorder the newly coded factor variable
iuc$new_GRP_LABEL <- factor(iuc$new_GRP_LABEL, levels = c("Low", "Medium", "High"))
# Merge LSOA and IUC
lsoa_iuc <- left_join(lsoa, iuc, by = c("LSOA11CD" = "LSOA11_CD"))
# Create palatte
palette = c("#fde0dd", "#fa9fb5", "#c51b8a")
# Create map
tm_shape(lsoa_iuc) + 
  tm_polygons("new_GRP_LABEL", title = "Class/Cluster" , pal=palette) +
  tm_layout(main.title = "Map 2: Islington Internet Engagement Level 2018",
            main.title.fontface = 2, 
            fontfamily = "Helvetica",
            legend.outside = TRUE,
            legend.text.size = 0.6,
            legend.position = c("left", "bottom"),
            frame =FALSE) +
  tm_compass(position = c("right", "bottom")) + 
  tm_scale_bar(position = c("left", "bottom"))

# MAP 3: WIFI HOTSPOTS
# Transform Wifi Hotspot sf to british national grid
wifi_points <- st_transform(wifi_points, 27700)
# Clip wifi hotspots sf to islington
wifi_points <- st_intersection(wifi_points, oa)
# Create map
tm_shape(islington_osm_basemap) + 
  tm_rgb() + 
  tm_shape(oa_broadband) +
  tm_fill(alpha = 0.3, 
          col = "blue") +
  tm_shape(wifi_points) +
  tm_dots() +
  tm_layout(main.title = "Map 3: Islington Wifi Hotspots 2015",
            main.title.fontface = 2, 
            fontfamily = "Helvetica") +
  tm_compass(position = c("right", "bottom")) + 
  tm_scale_bar(position = c("left", "bottom"))

# MAP 4: KDE OF WIFI HOTSPOTS
# Set window as the entirety of Islington
window <- as.owin(oa_broadband$geometry)
# Extract the x and y coordinates of wifi hotspots
wifi_points_xy <- wifi_points %>%
  st_coordinates()
# Create ppp object
wifi_points_ppp <- ppp(x = wifi_points_xy[, 1], y = wifi_points_xy[, 2], window = window)
# Add an offset to our points using the rjitter function
wifi_points_ppp_jitter <- rjitter(wifi_points_ppp, retry = TRUE, nsim = 1, drop = TRUE)
# Create a raster directly from the output of our KDE 300g stands for a 300m bandwidth
kde_300g_raster <- density.ppp(wifi_points_ppp_jitter, sigma = 300, edge = T) %>%
  raster()
# Set the CRS of the `kde_300g_raster` to BNG
crs(kde_300g_raster) <- "+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs "
# Mask (or clip) the raster by the output areas polygon
masked_kde <- raster::mask(kde_300g_raster, oa)
# Creates a bounding box based on the extents of the oa_broadband polygon
bounding_box <- bb(oa_spdf)

# Create map
tm_shape(masked_kde, 
         bbox = bounding_box) + 
  tm_raster(title = "Kernel Desntiy Estimates
Dispersed ---------------- Clustered",
            style = "quantile", 
            n = 100, 
            legend.is.portrait = FALSE,
            palette = "YlGnBu") +
  tm_shape(oa_broadband) + 
  tm_borders(alpha=.3, 
             col = "white") +
  tm_layout(main.title = "Map 4: Masked KDE Raster of Wifi Hotspots
            in Islington 2015",
            main.title.fontface = 2, 
            fontfamily = "Helvetica",
            title.size = 1.2,
            frame = FALSE,
            legend.outside = TRUE,
            legend.position = c("right", "bottom"),
            legend.title.size = 1) +
  tm_compass(position = c("left", "bottom")) + 
  tm_scale_bar(position = c("left", "bottom"))

# MAP 5: BROADBAND AVERAGE DOWNLOAD SPEED
# Merge oa sf and broadband csv
oa_broadband <- left_join(oa, broadband, by = c("OA11CD" = "oa11"))
# Create map
tm_shape(oa_broadband) + 
  tm_polygons("Average.download.speed..Mbit.s.", 
              title = "Average download speed (Mbit/s)",
              border.alpha =0.5) + 
  tm_shape(wifi_points) + 
  tm_dots() + 
  tm_layout(main.title = "Map 5: Islington Broadband 
            Average Download Speed 2018",
            main.title.fontface = 2, 
            fontfamily = "Helvetica",
            frame = FALSE, 
            legend.outside = TRUE,
            legend.position = c("left", "bottom"),
            legend.title.size = 0.8,
            legend.text.size = 0.6) +
  tm_compass(position = c("right", "bottom")) + 
  tm_scale_bar(position = c("left", "bottom"))

# MAP 6: GETIS-ORD HOT AND COLD SPOT MAP OF BROADBAND SPEED
# Remove NA values in oa_broadband sf
oa_broadband <- subset(oa_broadband, is.na(oa_broadband$Average.download.speed..Mbit.s.) == FALSE)
# Creates centroid and joins neighbours within 0 and 300 'units' of the CRS, i.e. metres
ward_neighbours_fd <- dnearneigh(st_geometry(st_centroid(oa_broadband)), 0, 300)
# Creates a neighbours list based on the Fixed Distance neighbour definition
ward_spatial_weights_fd <- ward_neighbours_fd %>%
  nb2listw(., style = "B")
# Run the local Gi* test on our average download speed data with the fd weights
broadband_LGO <- oa_broadband %>%
  pull(Average.download.speed..Mbit.s.) %>%
  as.vector() %>%
  localG(., ward_spatial_weights_fd)
# Join the local Gi* statistic to `oa_broadband` spatial dataframe
oa_broadband <- oa_broadband %>%
  mutate(broadband_LGO_G = as.numeric(broadband_LGO))

# Set colour palette
GIColours <- rev(brewer.pal(8, "RdBu"))
# Create map
tm_shape(oa_broadband) + 
  tm_polygons("broadband_LGO_G", 
              style = "pretty", 
              palette = GIColours,
              midpoint = 0, 
              title = "Local Gi* statistic") + 
  tm_layout(main.title = "Map 6:Hot/Cold Spot Map of broadband 
            avergage download speed in Islington 2018", 
            main.title.fontface = 2, 
            fontfamily = "Helvetica", 
            legend.outside = TRUE, 
            legend.position = c("left","bottom"),
            legend.title.size = 1, 
            frame = FALSE,) + 
  tm_compass(type = "arrow", 
             position = c("right", "bottom")) + 
  tm_scale_bar(position = c("left", "bottom"))

# MAP 7,8,9: GWR ON BROADBAND SPEED AND POPULATION
# Extract the needed columns and remove the top four rows of popoulation dataframe
population <- population[-1:-4,1:3]
# Rename population dataframe columns
names(population) <- c("OA11CD", "LSOA11CD", "pop")
# Make the population column numeric
population$pop <- as.numeric(population$pop)
# Merge oa spdf with population and broadband dataframe
oa_spdf_broadband <- merge(oa_spdf, population, by = "OA11CD")
oa_spdf_broadband <- merge(oa_spdf_broadband, broadband, by.x = "OA11CD", by.y = "oa11", na.rm=TRUE)
# Remove the rows with NA value in oa_broadband spdf
oa_spdf_broadband <- subset(oa_spdf_broadband, is.na(oa_spdf_broadband@data$Average.download.speed..Mbit.s..x) == FALSE)

# Create map
palette7 = c("#edf8fb", "#b2e2e2", "#66c2a4", "#2ca25f", "#006d2c")

tm_shape(oa_spdf_broadband) +
  tm_polygons("pop",
              border.alpha=0.3,
              title = "Population",
              palette = palette7) +
  tm_layout(main.title = "Map 7: Islington Population Estimates 2018",
            main.title.fontface = 2, 
            fontfamily = "Helvetica", 
            frame = FALSE,
            legend.outside = TRUE,
            legend.position = c("left", "bottom")) +
  tm_compass(position = c("right", "bottom")) + 
  tm_scale_bar(position = c("left", "bottom"))

# Calculate kernel bandwidth
GWRbandwidth <- gwr.sel(Average.download.speed..Mbit.s..x ~ pop, data=oa_spdf_broadband,adapt=T)
# Run the gwr model
gwr.model = gwr(Average.download.speed..Mbit.s..x ~ pop, data = oa_spdf_broadband, adapt=GWRbandwidth, hatmatrix=TRUE, se.fit=TRUE) 

# Create a results dataframe for the gwr outcome
results <-as.data.frame(gwr.model$SDF)
# Rename the coefficient column to avoid duplication of column names
names(results)[names(results) == "pop"] <- "oa_broadband.pop"
# Bind the gwr results into oa_broadband spdf
gwr.map<- oa_spdf_broadband
gwr.map@data <- cbind(oa_spdf_broadband@data, as.matrix(results))

# Create map 8
map1 <- tm_shape(gwr.map) + 
  tm_polygons("oa_broadband.pop", 
          n = 5, 
          style = "quantile", 
          title = "Coefficient",
          border.alpha =.3) + 
  tm_layout(main.title = "Map 8: GWR Coefficient",
            main.title.fontface = 2, 
            fontfamily = "Helvetica", 
            frame = FALSE, 
            legend.text.size = 0.5, 
            legend.title.size = 0.6,
            title.size=2,
            legend.outside = TRUE,
            legend.position = c("right", "bottom")) +
  tm_compass(position = c("left", "bottom")) + 
  tm_scale_bar(position = c("left", "bottom"))
# Create map 9
map2 <- tm_shape(gwr.map) +
  tm_polygons("localR2", 
              border.alpha=.3,
              title = "Local R2",) +
  tm_layout(main.title = "Map 9: GWR Local R2",
            main.title.fontface = 2, 
            fontfamily = "Helvetica", 
            frame = FALSE,
            legend.text.size = 0.5, 
            legend.title.size = 0.6,
            title.size=2,
            legend.outside = TRUE,
            legend.position = c("right", "bottom")) +
  tm_compass(position = c("left", "bottom")) + 
  tm_scale_bar(position = c("left", "bottom"))

# Create a clear grid
grid.newpage()
# Assign the cell size of the grid, in this case 1 by 2
pushViewport(viewport(layout=grid.layout(1,2)))
# Print map objects into defined cells
print(map1, vp=viewport(layout.pos.col = 1, layout.pos.row =1))
print(map2, vp=viewport(layout.pos.col = 2, layout.pos.row =1))
