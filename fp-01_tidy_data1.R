##---------------------------------------------------------------##
## This script performs three tasks:                             ##
## 1. reading and transforming the CTA data to generate a data   ##
## that contains information on both time and location for CTA   ##
## stops.                                                        ##
## 2. reading and transforming the Divvy data to generate 1)     ##
## a tidy Divvy trip data with spatial and proximity variables   ## 
## and 2) a tidy Divvy station data with proximity variables.    ##
## 3. creating a data that links the Divvy stations to close-by  ## 
## CTA stops.                                                    ##
##---------------------------------------------------------------##

# Load libraries
library(tidyverse)
library(feather)
library(geosphere)

## 1, READ AND TRANSFORM THE CTA DATA
## The following codes reads two CTA dataset concerning public transit stops and combine them
# load and join the data
CTAStops <- read_csv("data/stops.txt")
CTAStopTimes <- read_csv("data/stop_times.txt")

CTAStopTimeLocation <- left_join(CTAStopTimes, CTAStops, by = "stop_id")
# drop less meaningful variables
CTAStopTimeLocation <- CTAStopTimeLocation %>%
  select(-stop_sequence, -stop_headsign, -shape_dist_traveled, -stop_code, -stop_desc, -wheelchair_boarding)

# Write the outcome into feather file and store
write_feather(CTAStopTimeLocation, "data/CTA_Stop_time_location.feather")


## 2. READ AND TRANSFORM THE DIVVY DATA
## The following codes read and join two Divvy dataset on 1) Divvy trips and 2) locations of Divvy stations. 
# Create a vector of the names of Divvy trip files 
DivvyAllFiles <- list.files("data/Divvy_Trips_2016_Q1Q2", pattern = "\\.csv$", full.names = TRUE)
DivvyTripFiles <- DivvyAllFiles[2:5]

# Use map function to read all four trip files and bind them
DivvyTrip <- DivvyTripFiles %>%
  map(read_csv) %>%
  bind_rows()

# Read the station file
DivvyStation <- read_csv("data/Divvy_Trips_2016_Q1Q2/Divvy_Stations_2016_Q1Q2.csv")
colnames(DivvyStation) <- c("id", "name", "lat", "lon", "dpcapacity", "online_date")

# adding two proximity variables to station data
Divvy_m <- cbind(DivvyStation$lon, DivvyStation$lat)
CTA_m <- cbind(CTAStops$stop_lon, CTAStops$stop_lat)
distance_m <- distm(Divvy_m, CTA_m, fun = distHaversine) # a 535 by 11520 matrix for distance

distance50 <- distance_m <= 50 # check if the distance is <=50 meters or approximately 0.1 mile
proximity50_1 <- (rowSums(distance50) > 0)*1 # binary; a Divvy station is <=50m from any CTA stop, 1; otherwise, 0 
DivvyStation$proximity <- as.integer(proximity50_1)
proximity50_2 <- rowSums(distance50) # non-binary; number of close CTA stops
DivvyStation$prox_num <- as.integer(proximity50_2)

# Adding spatial (i.e., latitude and longitude) and proximity variables
FromStation <- DivvyStation %>%
  select(id, lon, lat, proximity, prox_num)
colnames(FromStation) <- c("from_station_id", "from_lon", "from_lat", "from_prox", "from_prox_num")

ToStation <- DivvyStation %>%
  select(id, lon, lat, proximity, prox_num)
colnames(ToStation) <- c("to_station_id", "to_lon", "to_lat", "to_prox", "to_prox_num")

DivvyData_from <- left_join(DivvyTrip, FromStation)
DivvyData <- left_join(DivvyData_from, ToStation)

# make starttime and stoptime variables time data
DivvyData$starttime <- as.POSIXct(DivvyData$starttime, format = "%m/%d/%Y %H:%M", tz = "America/Chicago")
DivvyData$stoptime <- as.POSIXct(DivvyData$stoptime, format = "%m/%d/%Y %H:%M", tz = "America/Chicago")

# Write the outcome into feather file and store
write_feather(DivvyData, "data/Divvy_clean.feather")
write_feather(DivvyStation, "data/Divvy_station.feather")


## 3. CREATE A DATA FRAME LINKING DIVVY STATIONS AND CLOSE CTA STOPS
index50 <- as_data_frame(which(distance50 == TRUE, arr.ind = T)) # matrix of indices where the distance is <= 50
index50 <- index50[order(index50$row, index50$col),]
colnames(index50) <- c('Divvyindex', 'CTAindex')

DivvyStation$Divvyindex <- sequence(nrow(DivvyStation))
CTAStops$CTAindex <- sequence(nrow(CTAStops))
CTAindex <- CTAStops %>% select(stop_id, stop_name, CTAindex)

DivvyCTAProx <- DivvyStation %>%
  left_join(index50) %>%
  left_join(CTAindex) %>%
  select(id, name, proximity, prox_num, stop_id, stop_name)

# write the outcome into feather file and store
write_feather(DivvyCTAProx, "data/close_stops.feather")