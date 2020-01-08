
## Check if you have data.table, and install if needed
## You'll also need bit64 because of a weird issue with the ICN being 
## intrepreted as a large integer 

if(!"data.table" %in% rownames(installed.packages())){
  install.packages("data.table")
  install.packages("bit64")
}

## Load the libraries you need
library(data.table)
library(bit64)

##==============================================================================
## Write crash data to CSV
##==============================================================================

## Read in crash data
crash <- readRDS("data-idot/COMBINED CRASH DATA.Rds")

## Write to csv
fwrite(crash, "data-idot/COMBINED CRASH DATA.csv")

## Little tests to see if it looks right
readLines("data-idot/COMBINED CRASH DATA.csv", n = 10)
fread("data-idot/COMBINED CRASH DATA.csv", nrows = 10)

##==============================================================================
## Write person data to CSV
##==============================================================================

## Read in data
person <- readRDS("data-idot/COMBINED PERSON DATA.Rds")

## Write to csv
fwrite(person, "data-idot/COMBINED PERSON DATA.csv")

##==============================================================================
## Write vehicle data to CSV
##==============================================================================

## Read in data
vehicle <- readRDS("data-idot/COMBINED VEHICLE DATA.Rds")

## Write to csv
fwrite(vehicle, "data-idot/COMBINED VEHICLE DATA.csv")


