a <- list.files("data-acs", pattern = ".Rds", full.names = T)
data_acs <-lapply(a, readRDS)


a <- list.files("data-city-shape", pattern = ".Rds", full.names = T)
data_city_shape <-lapply(a, readRDS)



a <- list.files("data-cook-shape", pattern = ".Rds", full.names = T)
data_cook_shape <-lapply(a, readRDS)


a <- list.files("data-idot", pattern = ".Rds", full.names = T)
data_idot <-lapply(a, readRDS)


