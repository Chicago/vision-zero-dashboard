
rm(list=ls())

library(geneorama)
library(leaflet)

source("functions/generate_icons.R")
source("functions/stateplane2latlon.R")

icon_data <- fread("data-icons/icons.csv", na.strings = "")
icon_data

plot100colors(1)
plot100colors(100)

plot(1:23, pch=1:23)


icon_files <- generate_icons(w = 30, h = 30, 
                             colors = icon_data[!is.na(color), color],
                             pch = icon_data[!is.na(color), pch])

dat <- readRDS("data-idot/COMBINED CRASH DATA.Rds")

NAsummary(dat)
dat[, .N, AInjuries]
dat[, .N, RoadAlignment]
samp[, .N, RoadAlignment]

set.seed(1)
samp <- dat[sample(1:nrow(dat), size = 1000)][ , list(longitude = TSCrashLongitude, 
                                                      latitude = TSCrashLatitude, 
                                                      X = TSCrashCoordinateX,
                                                      Y = TSCrashCoordinateY,
                                                      RoadAlignment)]
samp <- cbind(samp[ , list(RoadAlignment)],
              samp[ , stateplane2latlon(X,Y)])
samp <- samp[X>0]

plot(latitude ~ longitude, samp)
plot(Y ~ X, samp)


ii <- 1:length(unique(samp$RoadAlignment))
leaflet() %>%
    addMarkers(data = samp, lng = ~longitude, lat = ~latitude,
               icon = icons(icon_files[ii],
                            iconHeight = 30,
                            iconWidth = 30)) %>%
    addCircles(data = samp, lng = ~longitude, lat = ~latitude)


icon_files <- generate_icons(w = 10, h = 10,
                             colors = icon_data[!is.na(color), color],
                             pch = icon_data[!is.na(color), pch])
leaflet() %>%
    addMarkers(data = samp, lng = ~longitude, lat = ~latitude,
               icon = icons(icon_files[ii],
                            iconHeight = 10,
                            iconWidth = 10))


