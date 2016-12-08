##---------------------------------------------------------------##
## This script creats the necessary directory to store data for  ##
## the current project and runs all the scripts in order so      ##
## that they download, transform, and analyse the data as well   ##
## as visualize the analysis in a presentable format.            ##
##---------------------------------------------------------------##

## clean out any previous work
paths <- c("data")

for(path in paths){
  unlink(path, recursive = TRUE)    # delete folder and contents
  dir.create(path)                  # create empty folder
}

## run my scripts
source("fb-00_download-data.R")
source("fb-01_tidy-data1.R")
source("fb-02_tidy-data2.R")
rmarkdown::render("home.Rmd")
rmarkdown::render("result_p.Rmd")
rmarkdown::render("result_m.Rmd")