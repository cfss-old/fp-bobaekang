# Final project

## Instruction
To reproduce my project, please clone this repo and use the `fp-runfile.R` to run all the scripts. The final result will be a website created using [R Markdown](http://rmarkdown.rstudio.com/rmarkdown_websites.html).

You can see the rendered webpage for this project [here](https://uc-cfss.github.io/fp-bobaekang/).
  
*Attention*: this repo does not contain all the necessary data to reproduce the entire project. You must use the R script in this repo to download the data.

***

## Summary of my project
My project seeks to explore the complementary effect of bike-sharing system (BSS) on the public transit ridership in Chicago using, primarily, Divvy and Chicago Transit Authority (CTA) data. Divvy is the BSS local to the Chicago area and CTA provides public transportation in forms of buses and rails. 

***

## Scripts
A brief explanation on each script files:  

* `fp-runfile.R` runs all scripts to reproduce my project in order.

* `fp-00_download-data.R` downloads data from Divvy and CTA webpages.
  
* `fp-01_tidy-data1.R` combines Divvy and CTA data to add proximity variables (`from_prox`, `from_prox_num`, `to_prox` and `to_prox_num`).
  
* `fp-02_tidy-data2.R` combines Divvy and CTA data to add multi-modality variables (`multimode` and `multimode_num`)
  
* `home.Rmd` is to render a "Home" html page of the project's website
  
* `result_p.Rmd` is to render a "Result: Proximity" html page of the project's website
  
* `result_m.Rmd` is to render a "Result: Multi-modality" html page of the project's website

***

## Packages to install
* `tidyverse` the usual
  
* `stringr` to use `str_c()` function

* `downloadr` to download data
  
* `feather` to save and read `.feather` files
  
* `geosphere` to calculate distance between geographic locations
  
* `ggmap` to obtain Chicago map

* `lubridate` to handle `datetime` data
  
  