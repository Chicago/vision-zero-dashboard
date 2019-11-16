

stateplane2latlon <- function(X, Y, metric=TRUE){
    require(sp)
    # latlon <- data.table(longitude = c(1148703.5804669, 1148721.69534794,
    #                                    1148718.58006945, 1148719.92031838,
    #                                    1148722.28519294),
    #                      latitude = c(1938916.16105645, 1938209.79458671,
    #                                   1938315.99708976, 1938270.3270949,
    #                                   1938189.60711051))
    # browser()
    latlon <- data.table(longitude = X, latitude = Y)
    ii <- apply(latlon, 1, function(x) !any(is.na(x)))
    latlon <- latlon[ii]
    coordinates(latlon) <- c("longitude", "latitude")
    if(metric){
        proj4string(latlon) <- CRS("+init=epsg:2790 +units=ft")
    } else {
        proj4string(latlon) <- CRS("+init=epsg:2790 +units=us-ft")
    }
    latlon <- coordinates(spTransform(latlon, CRS("+proj=longlat +datum=WGS84")))
    ret <- data.table(X, Y)
    ret <- ret[ii, latitude := coordinates(latlon)[ , 'latitude']][]
    ret <- ret[ii, longitude := coordinates(latlon)[ , 'longitude']][]
    return(ret)
}

if(FALSE){
    rm(list=ls())
    source("functions/latlon2stateplane.R")
    source("functions/stateplane2latlon.R")
    lon <- c(-87.728428378, -87.728380101, -87.7283888,
             -87.728385057, -87.728378456)
    lat <- c(41.988313918, 41.986375258, 41.986666744,
             41.986541397, 41.986319851)
    spx <- c(1148703.5804669, 1148721.69534794, 1148718.58006945,
             1148719.92031838, 1148722.28519294)
    spy <- c(1938916.16105645, 1938209.79458671, 1938315.99708976,
             1938270.3270949, 1938189.60711051)
    latlon2stateplane(lat, lon, T)
    stateplane2latlon(spx, spy, T)

    latlon2stateplane(lat, lon, F)
    stateplane2latlon(spx, spy, F)

}


