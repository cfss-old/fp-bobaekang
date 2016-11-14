# Read and transform the raw data
# Load libraries
library(tidyverse)
library(feather)

## Divvy data
# Load and join all the data files 
# Create a vector of the names of Divvy trip files 
DivvyAllFiles <- list.files("data/Divvy_Trips_2016_Q1Q2", pattern = "\\.csv$", full.names = TRUE)
DivvyTripFiles <- DivvyAllFiles[2:5]

# Use map function to read all four trip files and bind them
DivvyTrip <- DivvyTripFiles %>%
  map(read_csv) %>%
  bind_rows()

# Read the station file
DivvyStation <- read_csv("data/Divvy_Trips_2016_Q1Q2/Divvy_Stations_2016_Q1Q2.csv")


# Adding spatial variables: lattitude and longitude of from and to stations
FromStation <- DivvyStation %>%
  select(id, latitude, longitude)
colnames(FromStation) <- c("from_station_id", "from_lat", "from_lon")

ToStation <- DivvyStation %>%
  select(id, latitude, longitude)
colnames(ToStation) <- c("to_station_id", "to_lat", "to_lon")

DivvyData_from <- left_join(DivvyTrip, FromStation)
DivvyData <- left_join(DivvyData_from, ToStation)


# make starttime and stoptime variables time data
DivvyData$starttime <- as.POSIXct(DivvyData$starttime, format = "%m/%d/%Y %H:%M", tz = "America/Chicago")
DivvyData$stoptime <- as.POSIXct(DivvyData$stoptime, format = "%m/%d/%Y %H:%M", tz = "America/Chicago")

# check the result
head(DivvyData)

## CTA data
## The following codes reads two CTA dataset concerning public transit stops and combine them
# load and join the data
CTAStops <- read_csv("data/stops.txt")
CTAStopTimes <- read_csv("data/stop_times.txt")

CTAStopTimeLocation <- left_join(CTAStopTimes, CTAStops, by = "stop_id")
CTAStopTimeLocation <- CTAStopTimeLocation %>%
  select(-stop_sequence, -stop_headsign, -shape_dist_traveled, -stop_code, -stop_desc, -wheelchair_boarding) %>%
  str()

# Write the data to file
write_feather(DivvyData, "data/Divvy_clean.feather")
write_feather(DivvyStation, "data/Divvy_station.feather")
write_feather(CTAStopTimeLocation, "data/CTA_Stop_time_location.feather")