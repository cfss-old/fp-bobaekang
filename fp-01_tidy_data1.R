##---------------------------------------------------------------##
## This script reads Divvy and CTA data into R and tidy them, in ##
## order to creat a tidy data frame for Divvy trips with spatial ##
## variable, which classifies all trips into four different      ##
## groups, based on stations from and to which each trip was     ##
## made and on whether those stations are in proximity with      ##
## any CTA stop.                                                 ##
##---------------------------------------------------------------##

# Load libraries
library(tidyverse)
library(feather)

## READ AND TRANSFORM THE CTA DATA
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


## READ AND TRANSFORM THE DIVVY DATA
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

# adding a proximity variable to station data
Divvy_m <- cbind(DivvyStation$lon, DivvyStation$lat)
CTA_m <- cbind(CTAStops$stop_lon, CTAStops$stop_lat)
distance_m <- distm(Divvy_m, CTA_m, fun = distHaversine) # a 535 by 11520 matrix for distance

distance150 <- distance_m <= 150 # check if the distance is <=150 meters or approximately 0.1 mile
proximity150 <- (rowSums(distance150) > 0)*1 # a Divvy station is <=150m from any CTA stop, 1; otherwise, 0 
DivvyStation$proximity <- proximity150

index150 <- which(distance_m <= 150, arr.ind = T) # matrix of indices where the distance is <= 150
for (i in range(1, ncol(index150))){ # switching the index number to id numbers
  Divvyindex <- index150[i,1]
  CTAindex <- index150[i,2]
  DivvyId <- DivvyStation$id[Divvyindex]
  CTAId <- CTAStops$stop_id[CTAindex]
  index150[i,1] <- DivvyId
  index150[i,2] <- CTAId
}
colnames(index150) <- c('id', 'stop_id') # matching the column names to those in `DivvyStation` and `CTAStops`
index150 <- index150 %>% as_data_frame()
test <- left_join(DivvyStation, index150)
print(test, n = 30)

# Adding spatial variables: lattitude and longitude of from and to stations
FromStation <- DivvyStation %>%
  select(id, lon, lat, proximity)
colnames(FromStation) <- c("from_station_id", "from_lon", "from_lat", "from_prox")

ToStation <- DivvyStation %>%
  select(id, lon, lat, proximity)
colnames(ToStation) <- c("to_station_id", "to_lon", "to_lat", "to_prox")

DivvyData_from <- left_join(DivvyTrip, FromStation)
DivvyData <- left_join(DivvyData_from, ToStation)

# make starttime and stoptime variables time data
DivvyData$starttime <- as.POSIXct(DivvyData$starttime, format = "%m/%d/%Y %H:%M", tz = "America/Chicago")
DivvyData$stoptime <- as.POSIXct(DivvyData$stoptime, format = "%m/%d/%Y %H:%M", tz = "America/Chicago")
# separate dates and time for starttime and stoptime variables
DivvyData <- DivvyData %>%
  separate(starttime, c("starttime_ymd", "starttime_hms"), " ") %>%
  separate(stoptime, c("stoptime_ymd", "stoptime_hms"), " ")

# Write the outcome into feather file and store
write_feather(DivvyData, "data/Divvy_clean.feather")
write_feather(DivvyStation, "data/Divvy_station.feather")