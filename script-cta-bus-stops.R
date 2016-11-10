# Collecting data on CTA bus stops for all routes

#------------------------------------------------------------------------------------#
# This script is to get the geographic coordinates of all CTA bus stops,
# which will be used to identify Divvy stations that are close by public transit
#------------------------------------------------------------------------------------#
# IMPORTANT NOTE:
# The following script will not run smoothly unless the user has a .Rprofile document
# that contains the information on his or her personal CTA API key.
# The necessary line for the .Rprofile document: is `options(CTAAPIkey = "MYCTAAPIKEY")`
# For privacy concerns, my .Rprofile document is excluded from this repository.
# Please follow the link (http://www.transitchicago.com/developers/bustracker.aspx) to get your own API key.
#------------------------------------------------------------------------------------#


# load libraries
library(tidyverse)
library(stringr)
library(httr)
library(XML)

# objects for bus routes and directions 
rt <- c(1:4, "N5", 6:8, "8A", 9, "X9", 10:12, "J14", 15, 18,
        20:22, 24, 26, 28:31, 34:37, 39, 43, 44, 47:49, "X49", "49B",
        50:52, "52A", 53, "53A", 54, "54A", "54B", 55, "55A", "55N", 56:57, 59,
        60, 62, "62H", 63, "63W", 65:68, 70:81, "81W", 82, 84:85, "85A", 86:88,
        90:97, "X98", 100, 103, 106, 108, 111, "111A", 112, 115, 119,
        120:121, 124:126, 130, 132, 134:136, 143, 146:148, 151:152, 155:157,
        165, 169, 171:172, 192, 201, 205:206)
dir <- c("Eastbound", "Westbound", "Northbound", "Southbound")

# create a function for getting and tidying the data from CTA API
busStop <- function(rt, dir){
  # getting the data
  baseurl <- "http://www.ctabustracker.com/bustime/api/v2/getstops?"
  params <- c("key=", "rt=", "dir=")
  key <- getOption("CTAAPIkey")
  values <- c(key, rt, dir)
  param_values <- map2_chr(params, values, str_c)
  args <- str_c(param_values, collapse = "&")
  request <- str_c(baseurl, args)
  bus <- GET(request)
  
  # tidying up the data
  bus_untidy <- content(bus, as = "parsed") %>%
    xmlTreeParse() %>%
    xmlToList() %>%
    as.data.frame() %>%
    unlist() %>%
    tibble()
  bus_untidy <- cbind(c("stpid", "stpnm", "lat", "lon"), bus_untidy)
  colnames(bus_untidy) <- c("variable", "value")
  nstop <- nrow(bus_untidy)/4
  id <- sort(rep(1:nstop, times = 4))
  bindid <- cbind(rt, dir, id, bus_untidy)
  bus_tidy <- spread(bindid, variable, value) %>%
    select(rt, dir, stpid, stpnm, lon, lat)
  return(bus_tidy)
}


# get a data for the first ten routes
busStopTest <- c()
rt_test <- rt[1:10]
for (i in rt_test){
  for (j in dir){
    tryCatch({
      a <- busStop(i, j)
      busStopTest <- rbind(busStopTest, a)
    }, error=function(e){})
  }
}
head(busStopTest)

# create a df containing only unique bus stops for the first ten routes
busStopOnlyTest <- subset(busStopTest, !duplicated(stpid)) %>%
  select(-rt, -dir) %>%
  arrange(stpid)
head(busStopOnlyTest)


# get a data for all bus routes
busStopAll <- c()
for (i in rt){
  for (j in dir){
    tryCatch({
      a <- busStop(i, j)
      busStopAll <- rbind(busStopAll, a)
    }, error=function(e){})
  }
}


# create a df containing only unique bus stops for all routes
head(busStopAll)
busStopOnlyAll <- subset(busStopAll, !duplicated(stpid)) %>%
  select(-rt, -dir) %>%
  arrange(stpid)

head(busStopOnlyAll)