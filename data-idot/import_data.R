
##==============================================================================
## IMPORT IDOT DATA
##
## Gene Leynes 11/12/2019
## This assumes that the user has downloaded and extracted the IDOT data.  Each
## year is in a separate folder.  The files containing header information were
## copied into text files, reduced, and parsed (using Excel).  The final format
## has the following columns: number, field name, field type, description.
##
## Manually corrected an error on line 22475 of the 2012 Crash data
## Manually corrected an error on line 9563 of the 2014 Crash data
##
## I also used the geneorama package for NAsummary, and clipboard convenience 
## funcitons.  Geneorama is not necessary, but can be obtained by running:
## devtools::install_github("geneorama/geneorama")
##==============================================================================


##------------------------------------------------------------------------------
## Initalize
##------------------------------------------------------------------------------

rm(list=ls())

library(data.table)
library(geneorama)

##------------------------------------------------------------------------------
## Get file lists
##------------------------------------------------------------------------------

## List files
f <- list.files("data-idot", full.names = T, recursive = T)

## Grep for file patterns
fp <- grep("PersonExtract", f, value = T)
fv <- grep("VehicleExtract", f, value = T)
fc <- grep("CrashExtract", f, value = T)

##------------------------------------------------------------------------------
## Rewrite files without comma separators, this gets around an issue with 
## non escaped quotes in the files. 
##------------------------------------------------------------------------------

for(f in fc){
    txt <- readLines(f)
    ## Replace comma separators with pipes
    txt <- gsub("\",\"", "|", txt)
    ## Replace leading and trailing quotes with ""
    txt <- gsub("\"$|^\"", "", txt)
    ## Write file
    cat(txt, file = f, sep = "\n")
}
for(f in fp){
    txt <- readLines(f)
    ## Replace comma separators with pipes
    txt <- gsub("\",\"", "|", txt)
    ## Replace leading and trailing quotes with ""
    txt <- gsub("\"$|^\"", "", txt)
    ## Write file
    cat(txt, file = f, sep = "\n")
}
for(f in fv){
    txt <- readLines(f)
    ## Replace comma separators with pipes
    txt <- gsub("\",\"", "|", txt)
    ## Replace leading and trailing quotes with ""
    txt <- gsub("\"$|^\"", "", txt)
    ## Write file
    cat(txt, file = f, sep = "\n")
}


##------------------------------------------------------------------------------
## Read data into a lists, and check the lists
##------------------------------------------------------------------------------

datc <- lapply(fc, fread, header = FALSE, sep = "|", quote = "")
datp <- lapply(fp, fread, header = FALSE, sep = "|", quote = "")
datv <- lapply(fv, fread, header = FALSE, sep = "|", quote = "")

## Check rows actually in the files
# sapply(fc, function(x) system(sprintf("wc %s", x)))
# sapply(fp, function(x) system(sprintf("wc %s", x)))
# sapply(fv, function(x) system(sprintf("wc %s", x)))
## Should match this:
sapply(datc, dim)
sapply(datp, dim)
sapply(datv, dim)

sum(sapply(datc, nrow))
sum(sapply(datp, nrow))
sum(sapply(datv, nrow))

##------------------------------------------------------------------------------
## Crash
##------------------------------------------------------------------------------

hc <- fread("data-idot/basic metadata crash.csv")
hc <- hc[ , -"desc"]
hc

for(i in 1:length(datc)){
    if(ncol(datc[[i]])==73){
        datc[[i]]$DidCrashOccurInWorkZone <- NA_character_
        datc[[i]]$WorkZoneType <- NA_character_
        datc[[i]]$WereWorkersPresent <- NA_character_
        datc[[i]]$WorkZone <- NA_character_
    }
    colnames(datc[[i]]) <- hc$field
}

datc <- rbindlist(datc)
datc

saveRDS(datc, "data-idot/COMBINED CRASH DATA.Rds")

##------------------------------------------------------------------------------
## Person
##------------------------------------------------------------------------------

hp <- fread("data-idot/basic metadata person.csv")
hp <- hp[,-"desc"]
hp

## Pre 2013 and post 2013 fields
hp[-c(2,34), name]
hp[, name]

sapply(datp, dim)

for(i in 1:length(datp)) {
    if(ncol(datp[[i]])==32){
        setnames(datp[[i]], hp[-c(2,34), name])
        datp[[i]]$CellPhoneUse <- NA_character_
        datp[[i]]$CrashID <- NA_integer_
        setcolorder(datp[[i]], hp[,name])
    } else {
        setnames(datp[[i]], hp[ , name])
    }
}

datp <- rbindlist(datp)
saveRDS(datp, "data-idot/COMBINED PERSON DATA.Rds")

##------------------------------------------------------------------------------
## Vehicle
##------------------------------------------------------------------------------

hv <- fread("data-idot/basic metadata vehicle.csv")
hv <- hv[,-"desc"]
hv

## Pre 2013 post 2013:
hv[-c(2,41), name]
hv[, name]

# sapply(datv, dim)
# fv[c(1,3,9)]
# sapply(datv[c(1,3,9)], head)
# clipper(head(datv[[1]]))

datv[[1]][ , .N, list(V29==V30)]
datv[[2]][ , .N, list(V29==V30)]

datv[[1]][ , V29 := NULL]
datv[[2]][ , V29 := NULL]

sapply(datv, dim)

fv
datv[[3]][ , .N, keyby = list(V14, V29)]
datv[[3]][ , .N, keyby = list(V15, V30)]
datv[[4]][ , .N, keyby = list(V15, V30)]

datv[[9]][ , .N, keyby = list(V15, V30)]
datv[[9]][ , .N, keyby = list(V16, V31)]

for(i in 1:length(datv)) {
    if(ncol(datv[[i]])==39){
        print(i)
        setnames(datv[[i]], hv[-c(2,41), name])
        datv[[i]]$CrashID <- NA_integer_
        datv[[i]]$ExceedingSpeedLimit <- NA_character_
        setcolorder(datv[[i]], hv[,name])
    } else {
        setnames(datv[[i]], hv[, name])
    }
}

datv <- rbindlist(datv)
saveRDS(datv, "data-idot/COMBINED VEHICLE DATA.Rds")

