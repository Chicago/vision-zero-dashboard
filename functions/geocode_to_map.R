

geocode_to_map <- function(lat, lon, map, map_field_name){
    lat <- as.numeric(lat)
    lon <- as.numeric(lon)
    df <- data.table(lon, lat)
    sp::coordinates(df) <- c("lon", "lat")
    df@proj4string <- map@proj4string
    geo <- sp::over(df, map)
    ret <-  as.character(geo[ , map_field_name])
    return(ret)
}

