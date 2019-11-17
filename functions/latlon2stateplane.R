

latlon2stateplane <- function(latitude, longitude, metric=TRUE){
    # xy <- data.table(X = c(-87.728428378, -87.728380101, -87.7283888,
    #                        -87.728385057, -87.728378456),
    #                  Y = c(41.988313918, 41.986375258, 41.986666744,
    #                        41.986541397, 41.986319851))
    # browser()
    
    require(sp)
    xy <- data.table(X = longitude, Y = latitude)
    ii <- apply(xy, 1, function(x) !any(is.na(x)))
    xy <- xy[ii]
    coordinates(xy) <- c("X", "Y")
    proj4string(xy) <- CRS("+proj=longlat +datum=WGS84")
    if(metric){
        xy <- coordinates(spTransform(xy, CRS("+init=epsg:2790 +units=ft")))
    } else {
        xy <- coordinates(spTransform(xy, CRS("+init=epsg:2790 +units=us-ft")))
    }
    ret <- data.table(latitude, longitude)
    ret <- ret[ii, x := coordinates(xy)[ , 'X']][]
    ret <- ret[ii, y := coordinates(xy)[ , 'Y']][]
    return(ret)
}
