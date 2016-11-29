# Download the raw data
# Load library
library(downloader)
library(stringr)

# Download the data
# Divvy data
download(url = "https://s3.amazonaws.com/divvy-data/tripdata/Divvy_Trips_2016_Q1Q2.zip",
         destfile = "data/Divvy_Trips_2016_Q1Q2.zip")

# CTA data: stops and schedule
download(url = "http://www.transitchicago.com/downloads/sch_data/google_transit.zip",
         destfile = "data/google_transit.zip")

# unzip the file
datazip <- list.files("data", pattern = "\\.zip$")

for (zipfile in datazip){
  filepath = str_c("data/", zipfile)
  unzip(filepath, exdir = "data")
}

