trim_map <- function(map1, map2, coord_names = c("INTPTLON", "INTPTLAT")){
    
    map1_centers <- map1@data[ , coord_names]
    map1_centers <- as.data.table(sapply(map1_centers, as.numeric))
    sp::coordinates(map1_centers) <- coord_names
    map1_centers@proj4string <- map2@proj4string
    ret <- map1[!is.na(sp::over(map1_centers, map2))[ , 1], ]
    return(ret)
    
    ## original:
    ## Subset census tract data to chicago 
    # tract_centers <- census_tracts@data[ , c("INTPTLAT", "INTPTLON")]
    # tract_centers <- as.data.table(sapply(tract_centers, as.numeric))
    # sp::coordinates(tract_centers) <- c("INTPTLON", "INTPTLAT")
    # tract_centers@proj4string <- wards@proj4string
    # census_tracts_chi <- census_tracts[!is.na(sp::over(tract_centers, wards))[,1], ]
}
