##---------------------------------------------------------------##
## This script further transform Divvy and CTA data in order to  ##
## add multi-modal variables, which classify all Divvy trips     ##
## into two different groups; ones likely to be multi-modal and  ##
## the others that are not.                                      ##
##---------------------------------------------------------------##

# Load libraries
library(tidyverse)
library(feather)
library(lubridate)
library(stringr)

# Read in and prepare data for tidying
DivvyData <- read_feather("data/Divvy_clean.feather")
CTAStopTimeLocation <- read_feather("data/CTA_Stop_time_location.feather")
DivvyCTAProx <- read_feather ("data/close_stops.feather")


# Divvy trips that started at stations in proximity with CTA stops  
DivvyData_from_prox <- DivvyData %>%
  select(-stoptime, -to_station_id, -to_station_name,-bikeid, -to_lon, -to_lat, -to_prox, -to_prox_num) %>%
  filter(from_prox == 1)

# Divvy trips that stopped at stations in proximity with CTA stops 
DivvyData_to_prox <- DivvyData %>%
  select(-starttime, -from_station_id, -from_station_name, -bikeid, -from_lon, -from_lat, -from_prox, -from_prox_num) %>%
  filter(to_prox == 1)

# CTA trip times, divided into arrivals and departures
CTAStop_arr <- CTAStopTimeLocation %>%
  select(arrival_time, stop_id)
CTAStop_dep <- CTAStopTimeLocation %>%
  select(departure_time, stop_id)

# CTA arrivals to and departures from CTA stops that are in proximity with Divvy stations 
DivvyCTAProx_yes <- DivvyCTAProx %>%
  filter(proximity == 1)

Arrival <- left_join(DivvyCTAProx_yes, CTAStop_arr) %>% select(-name)
colnames(Arrival) <- c('to_station_id', 'to_prox', 'to_prox_num', 'stop_id', 'stop_name', 'arrival_time')

Departure <- left_join(DivvyCTAProx_yes, CTAStop_dep) %>% select(-name)
colnames(Departure) <- c('from_station_id', 'fro_prox', 'from_prox_num', 'stop_id', 'stop_name', 'depart_time')

# define functions to add multi-modal variables: multimode and multimode_num 
multiFromFunc <- function(fromInput){ # for trips that start in a potentially multi-modal manner
  data <- left_join(fromInput, Departure)
  stop <- as_date(data$starttime)
  dep <- ymd_hms(str_c(as_date(data$starttime), data$depart_time, sep = " "), tz = "America/Chicago")
  data$close <- (3 >= abs(difftime(data$starttime, dep, tz = "America/Chicago", units = c("mins"))))*1
  close_var <- data %>%
    group_by(trip_id) %>%
    summarise(multimode_num = sum(close == 1, na.rm = TRUE))
  close_var$multimode <- as.logical(close_var$multimode_num)*1
  output <- fromInput %>% left_join(close_var)
  return(output)
}

multiToFunc <- function(toInput){ # for trips that end in a potentially multi-modal manner
  data <- left_join(toInput, Arrival)
  stop <- as_date(data$stoptime)
  arr <- ymd_hms(str_c(as_date(data$stoptime), data$arrival_time, sep = " "), tz = "America/Chicago")
  data$close <- (3 >= abs(difftime(data$stoptime, arr, tz = "America/Chicago", units = c("mins"))))*1
  close_var <- data %>%
    group_by(trip_id) %>%
    summarise(multimode_num = sum(close == 1, na.rm = TRUE))
  close_var$multimode <- as.logical(close_var$multimode_num)*1
  output <- toInput %>% left_join(close_var)
  return(output)
}

# random sampling of the Divvy data, n = 10000
toSample <- sample_n(DivvyData_to_prox, 10000)
fromSample <- sample_n(DivvyData_from_prox, 10000)

# add multi-modal variables
toOutput <- multiToFunc(toSample)
fromOutput <- multiFromFunc(fromSample)

# save the results
write_feather(toOutput, "data/to_output.feather")
write_feather(fromOutput, "data/from_output.feather")