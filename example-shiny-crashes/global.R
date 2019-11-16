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

sourceDir("functions")
##==============================================================================
## LOAD DATA
##==============================================================================

crash <- readRDS("example-shiny-crashes/dat.Rds")

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
ICON_WIDTH = 15
ICON_HEIGHT = 15
icon_data$file <- generate_icons(w = ICON_WIDTH, h = ICON_HEIGHT, 
                                 colors = icon_data[!is.na(color), color],
                                 pch = icon_data[!is.na(color), pch],
                                 lwd = 1.5)
icon_data$full_file <- file.path(getwd(), icon_data$file)
icon_data$makes <- crash[ , .N, keyby = veh_make][ , veh_make]

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


