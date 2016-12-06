##---------------------------------------------------------------##
## This script creats the necessary directories to store key     ##
## outputs of the project and runs all the scripts in order so   ##
## that they download, transform, and analyse the data as well   ##
## as visualize the analysis in a presentable format.            ##
##---------------------------------------------------------------##

## clean out any previous work
paths <- c("data", "graphics", "output")

for(path in paths){
  unlink(path, recursive = TRUE)    # delete folder and contents
  dir.create(path)                  # create empty folder
}

## run my scripts
source("fb-00_download-data.R")
source("fb-01_tidy-data1.R")
source("fb-02_tidy-data2.R")
# rmarkdown::render("index.Rmd")
# rmarkdown::render("about.Rmd")