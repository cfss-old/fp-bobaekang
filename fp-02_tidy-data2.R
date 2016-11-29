##---------------------------------------------------------------##
## This script further transform Divvy and CTA data in order to  ##
## add the temperal variable, which classifies all Divvy trips   ##
## into two different groups; ones likely to be multi-modal and  ##
## the others that are not.                                      ##
##---------------------------------------------------------------##

# Load libraries
library(tidyverse)
library(feather)
library(lubridate)

# Read in and prepare data for tidying
DivvyData <- read_feather("data/Divvy_clean.feather")
CTAStopTimeLocation <- read_feather("data/CTA_Stop_time_location.feather")

# Divvy trips that started at stations in proximity with CTA stops  
DivvyData_from_prox <- DivvyData %>%
  select(-stoptime_ymd, -stoptime_hms, -to_station_id, -to_station_name, -to_lon, -to_lat, -to_prox) %>%
  filter(from_prox == 1)
DivvyData_from_prox$starttime_ymd <- ymd(DivvyData_from_prox$starttime_ymd)
DivvyData_from_prox$starttime_hms <- hms(DivvyData_from_prox$starttime_hms)

# Divvy trips that stopped at stations in proximity with CTA stops 
DivvyData_to_prox <- DivvyData %>%
  select(-starttime_ymd, -starttime_hms, -from_station_id, -from_station_name, -from_lon, -from_lat, -from_prox) %>%
  filter(to_prox == 1)
DivvyData_to_prox$stoptime_ymd <- ymd(DivvyData_to_prox$stoptime_ymd)
DivvyData_to_prox$stoptime_hms <- hms(DivvyData_to_prox$stoptime_hms)

# CTA trip times, divided into arrivals and departures
CTAStop_arr <- CTAStopTimeLocation %>%
  select(-departure_time)
CTAStop_arr$arrival_time <- hms(CTAStop_arr$arrival_time) 
CTAStop_dep <- CTAStopTimeLocation %>%
  select(-arrival_time)
CTAStop_dep$departure_time <- hms(CTAStop_dep$departure_time)