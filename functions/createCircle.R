

# https://stackoverflow.com/questions/23071026/drawing-a-circle-with-a-radius-of-a-defined-distance-in-a-map


createCircle <- function(lat, lon, km) {
    ## lat = latitude of the center of the circle in decimal degrees
    ## lon = longitude of the center of the circle in decimal degrees
    ## km = radius of the circle in kilometers
    
    ## Mean Earth radius in kilometers. Change to 3959 for miles instead of km.
    ER <- 6371 
    
    ## Convert lat/lon from degrees to radians
    LatRad <- lat * (pi/180)
    LonRad <- lon * (pi/180)
    
    ## Define angles at which circle will be drawn
    AngDeg <- seq(1:360)      # (degrees) 
    AngRad <- AngDeg*(pi/180) # (radians)
    
    ## Latitude of each point of the circle
    CircleLatRad <- asin(sin(LatRad) * cos(km/ER) + 
                             cos(LatRad) * sin(km/ER) * cos(AngRad))
    
    ## Longitude of each point of the circle
    CircleLonRad <- LonRad + atan2(sin(AngRad) * sin(km/ER) * cos(LatRad),
                                   cos(km/ER) - sin(LatRad) * sin(CircleLatRad))
    
    ## Convert radians back to degrees
    CircleLatDeg <- CircleLatRad*(180/pi)
    CircleLonDeg <- CircleLonRad*(180/pi)
    
    ## Construct return value, and return
    ret <- list(lat = CircleLatDeg,
                lon = CircleLonDeg)
    return(ret)
}
