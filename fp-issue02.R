##---------------------------------------------------------------##
## This script reads Divvy station and CTA stop data into R, in  ##
## order to creat a tidy data frame for Divvy Station data frame ##
## with spatial variable. This is a mini script for the Issue 02 ##
##---------------------------------------------------------------##

library(tidyverse)
library(feather)

# Read the CTA stop file
CTAStops <- read_csv("data/stops.txt")

# Read the Divvy station file
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