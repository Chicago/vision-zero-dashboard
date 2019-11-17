##------------------------------------------------------------------------------
## INITIALIZE
##------------------------------------------------------------------------------

geneorama::set_project_dir("vision-zero-dashboard")

# rm(list=ls())
library(geneorama)
loadinstall_libraries("spdep")
loadinstall_libraries("rgdal")
loadinstall_libraries("rgeos")
loadinstall_libraries("leaflet")
loadinstall_libraries("RColorBrewer")
loadinstall_libraries("sp")
loadinstall_libraries("ggplot2")
loadinstall_libraries("bit64")

sourceDir("functions")
##==============================================================================
## LOAD DATA
##==============================================================================

crash <- readRDS("data-idot/COMBINED CRASH DATA.Rds")
people <- readRDS("data-idot/COMBINED PERSON DATA.Rds")
veh <- readRDS("data-idot/COMBINED VEHICLE DATA.Rds")

## Very good match on ICN!
inin(crash$ICN, veh$ICN)
inin(crash$ICN, people$ICN)
# setkey(crash, ICN)
# setkey(veh, ICN)
# setkey(people, ICN)
nrow(crash)


##==============================================================================
## Crash statistics for app
##==============================================================================

## Some summaries to understand the data
people[ , .N, keyby = SafetyEquipUsed]
crash[ , .N, CrashSeverity]
crash[ , .N, TotalFatals > 0]
crash[ , .N, TotalInjured > 0]
crash[ , .N, AInjuries > 0]
crash[ , .N, BInjuries > 0]
crash[ , .N, CInjuries > 0]

## This truth table shows that CrashSeverity adds no information, although
## 4 cases of injuries were miscoded. Also, you can see that fatalities are 
## counted distintly from injuries. There are definitely fatalities without 
## "injuries".  CrashSeverityCD is "most severe" injury
crash[ , .N, keyby = list(CrashSeverity, CrashSeverityCd, 
                          TotalFatals > 0,
                          AInjuries > 0, BInjuries > 0, CInjuries > 0,
                          TotalInjured > 0)]
## CrashInjurySeverity is the text for the CD code
crash[ , .N, keyby = list(CrashInjurySeverity, CrashSeverityCd)]


##------------------------------------------------------------------------------
## Create seatbelt indicator, then join to crash data
##------------------------------------------------------------------------------
people[ , belts_used := grepl("belt used|belts used", SafetyEquipUsed, ignore.case = T)]
people[ , .N, list(SafetyEquipUsed, keyby = belts_used)]
crash <- merge(x = crash,
               y = people[i = TRUE,
                          j = list(ave_belts_used = mean(belts_used), 
                                   person_record_count = .N),
                          keyby=ICN],
               by = "ICN",
               sort = FALSE, 
               all.x = TRUE)

##------------------------------------------------------------------------------
## Add in drug / alocohol measure
##------------------------------------------------------------------------------
## Examine BAC a bit. 
## According to google over .4 is lethal
## According to google over .08 is a DUI
## According to meta data:
## 00-94	Actual reported BAC result
## 95	    Test refused
## 96	    Test not offered
## 97	    Test performed, results unknown
people[ , .N, keyby = BAC]
people[ , .N, keyby = list(BACTestGiven)]

## The DRAC Code is another way to judge drug / alcohol involvement, but
## many of the results don't make sense. How can you have a .6 and not appear
## intoxicated?
people[ , .N, keyby = DRAC]
people[DRAC == 2 , .N, keyby = BACTestGiven]
people[DRAC != 2 , .N, keyby = BACTestGiven] ## That .09 freq is interesting!

people[ , list(ICN,DRAC)]
people[ , list(any(DRAC %in% c(2,3))),list(ICN)][,.N,V1]

people[ , bac_na_is_zero := ifelse(is.na(BAC) | BAC > 90, 0, BAC)]
people[ , .N, keyby = bac_na_is_zero]

people[ , known_intoxicated := bac_na_is_zero > .08]
people[ , .N, known_intoxicated]
people[ , .N, keyby = list(known_intoxicated, DRAC)]

people[ , observed_intoxicated := known_intoxicated | DRAC %in% c(2,3)]
people[ , .N, keyby = list(observed_intoxicated, DRAC)]

crash[ , .N, keyby=person_record_count]

crash <- merge(x = crash,
               y = people[i = TRUE,
                          j = list(any_drugs_or_alcohol = any(observed_intoxicated)),
                          keyby=ICN],
               by = "ICN",
               sort = FALSE,
               all.x = TRUE)
crash[ , .N, keyby = any_drugs_or_alcohol]

##------------------------------------------------------------------------------
## Add in popular vehicle makes
##------------------------------------------------------------------------------
veh[CrashReportUnitNbr==1,.N,VehMake][order(-N)][1:50]
top_22_makes <- veh[CrashReportUnitNbr==1,.N,VehMake][order(-N)][1:22, VehMake]
veh[ , adj_makes := ifelse(VehMake %in% top_22_makes, VehMake, "other")]
veh[ , .N, keyby = adj_makes]
## Some crashes have more than one "unit 1"
veh[ , .N, keyby = list(ICN, adj_makes)][,.N,keyby = N]  


crash <- merge(x = crash, 
               y = veh[ , list(veh_make = adj_makes[1]), ICN], 
               by = "ICN", sort = FALSE, all.x = TRUE)


##==============================================================================
## LOAD MAPS
##==============================================================================

tracts <- readRDS("data-cook-shape/cook_county_census_tract_shapefile.Rds")
comm_areas <- readRDS("data-city-shape/CommunityAreas.Rds")
income <- readRDS("data-acs/acs_income_2016.Rds")
pop <- as.data.table(readRDS("data-acs/acs_population_2016.Rds"))


tracts <- trim_map(tracts, comm_areas)

city_outline <- gUnaryUnion(as(comm_areas, "SpatialPolygons"))

## Add community area to maps
tracts@data$community <- geocode_to_map(lat = tracts@data$INTPTLAT, 
                                        lon = tracts@data$INTPTLON,
                                        map = comm_areas,
                                        map_field_name = "community")

## Add income to tract data 
table(tracts@data$TRACTCE %in% income$tract)
table(income$tract %in% tracts@data$TRACTCE)

## Note: MATCH, BUT DO NOT MERGE!!!
tracts@data$B19013_001E <- income$B19013_001E[match(tracts@data$TRACTCE, income$tract)]
tracts@data$B19013_001E[tracts@data$B19013_001E == -666666666] <- NA


## Note: MATCH, BUT DO NOT MERGE!!!
tracts@data$B01003_001E <- pop$B01003_001E[match(tracts@data$TRACTCE, pop$tract)]

##==============================================================================
## GENERATE ICON DATA
##==============================================================================

icon_data <- fread("data-icons/icons.csv", na.strings = "")
ICON_WIDTH = 10
ICON_HEIGHT = 10
icon_data$file <- generate_icons(w = ICON_WIDTH, h = ICON_HEIGHT, 
                                 colors = icon_data[!is.na(color), color],
                                 pch = icon_data[!is.na(color), pch],
                                 lwd = 1.5)
icon_data$full_file <- file.path(getwd(), icon_data$file)
icon_data$makes <- veh[ , .N, keyby = adj_makes][ , adj_makes]

##==============================================================================
## Fix crash lat / lon, and 
## GEOCODE COMM AREAS
##==============================================================================

# crash[ ,  hist(TSCrashLongitude)]
# crash[TSCrashLongitude < 0,  hist(TSCrashLongitude)]
# crash[TSCrashLongitude > 0,  hist(TSCrashLongitude)]
# 
# crash[ , hist(TSCrashLatitude)]
# crash[TSCrashLatitude != 0 , hist(TSCrashLatitude)]
# 
# crash[TSCrashLongitude > 0, TSCrashLongitude := -TSCrashLongitude]
# 
crash [ , lat := TSCrashLatitude]
crash [ , lon := TSCrashLongitude]

##********************************************************
## NOTE TAKING OUT TOO MANY SERIOUS CRASHES AND FATALITIES
## NEEDS TO BE FIXED!!
##********************************************************

## I thought this would fix the lat / lon issue, but the XYs are not translating
## to valid coordinates
# crash <- cbind(crash,
#                crash[ , stateplane2latlon(TSCrashCoordinateX,
#                                           TSCrashCoordinateY)])

crash[ , .N, keyby = list(missing_location = lat==0 | is.na(lat), 
                          CrashInjurySeverity)]
nrow(crash[lat!=0 | !is.na(lat)])
nrow(crash)
crash <- crash[lat!=0 & !is.na(lat)]
# hist(crash$lat)
# hist(crash$lon)
crash[lon>0,lon:=-lon]

# plot(comm_areas)
# points(lat~lon, crash[1:10000])


crash$community <- geocode_to_map(lat = crash$lat,
                                  lon = crash$lon,
                                  map = comm_areas,
                                  map_field_name = "community")
crash$GEOID <- geocode_to_map(lat = crash$lat,
                              lon = crash$lon,
                              map = tracts,
                              map_field_name = "GEOID")
##==============================================================================
## Join population and income data to commmunity areas
##==============================================================================

dt <- as.data.table(tracts)
dt <- dt[i = TRUE,
         j = list(pop = ssum(B01003_001E),
                  inc = round(ssum(B01003_001E * B19013_001E) / ssum(B01003_001E))),
         keyby = community]
comm_areas@data$B01003_001E <- dt$pop[match(comm_areas@data$community, dt$community)]
comm_areas@data$B19013_001E <- dt$inc[match(comm_areas@data$community, dt$community)]
rm(dt)


##==============================================================================
## GENERATE STATIC MAP DATA FOR INCOME MAP
##==============================================================================
pal_inc <- colorQuantile("Greens", NULL, n = 5)
popup_inc <- paste0("Median household income: ", as.character(tracts@data$B19013_001E))
legend_labels_inc <- paste(comma(quantile(tracts$B19013_001E, seq(0,.8,.2), na.rm = TRUE), 0),
                           comma(quantile(tracts$B19013_001E, seq(.2,1,.2), na.rm = TRUE), 0),
                           sep = " - ")
legend_values_inc <- quantile(tracts$B19013_001E, seq(0,1,length.out = 5), na.rm = TRUE)
legend_colors_inc <- pal_inc(quantile(tracts$B19013_001E, seq(0,1,length.out = 5), na.rm = TRUE))

##==============================================================================
## GENERATE STATIC MAP DATA FOR POPULATION MAP
##==============================================================================
pal_pop <- colorQuantile("Blues", NULL, n = 5)
popup_pop <- paste0("Tract population: ", as.character(tracts@data$B01003_001E))

legend_labels_pop <- paste(comma(quantile(tracts$B01003_001E, seq(0,.8,.2), na.rm = TRUE), 0),
                           comma(quantile(tracts$B01003_001E, seq(.2,1,.2), na.rm = TRUE), 0),
                           sep = " - ")
legend_values_pop <- quantile(tracts$B01003_001E, seq(0,1,length.out = 5), na.rm = TRUE)
legend_colors_pop <- pal_pop(quantile(tracts$B01003_001E, seq(0,1,length.out = 5), na.rm = TRUE))

dat <- crash[ ,
             list(belt_group = cut(ave_belts_used, 
                                   breaks = c(0, .25, .75, 1),
                                   include.lowest = TRUE,
                                   labels = c("low", "med", "high")),
                  person_record_count, ave_belts_used, CrashYear,
                  any_drugs_or_alcohol, CrashInjurySeverity,
                  veh_make, GEOID, community, lat, lon)]

saveRDS(dat, "example-shiny-crashes/dat.Rds")

# dat <- readRDS("example-shiny-crashes/dat.Rds")
# 
# dat <- dat[CrashYear == (SourceYear-2000) &
#              CrashInjurySeverity %in% SourceSeverity]
