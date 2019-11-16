
#' Get data directory
#'
#' @return filepath of data directory
#' @export
#'
get_data_dir <- function(){
  system.file("data-idot",
              package = "visionZero")
}


#' Load crash data
#'
#' @return data.table?
#' @export
#'
load_crash_data <- function(){

  a <- file.path(get_data_dir(),
                 "data",
                 "COMBINED CRASH DATA.Rds")
  readRDS(a)

}


#' Load person data
#'
#' @return data.table?
#' @export
#'
load_person_data <- function(){

  a <- file.path(get_data_dir(),
                 "data",
                 "COMBINED PERSON DATA.Rds")
  readRDS(a)
}


#' Load vehicle data
#'
#' @return data.table?
#' @export
#'
load_vehicle_data <- function(){

  a <- file.path(get_data_dir(),
                 "data",
                 "COMBINED VEHICLE DATA.Rds")
  readRDS(a)

}














#' Load tract data
#'
#' @return data.table?
#' @export
#'
load_tract_data <- function(){

  a <- file.path(system.file("data-cook-shape",
                             package = "visionZero"),
                 "cook_county_census_tract_shapefile.Rds")
  readRDS(a)

}

#' Load CommunityAreas data
#'
#' @return data.table?
#' @export
#'
load_community_areas_data <- function(){

  a <- file.path(system.file("data-cook-shape",
                             package = "visionZero"),
                 "CommunityAreas.Rds")
  readRDS(a)

}

#' Load acs income data
#'
#' @return data.table?
#' @export
#'
load_acs_income_data <- function(){

  a <- file.path(system.file("data-acs",
                             package = "visionZero"),
                 "acs_income_2016.Rds")
  readRDS(a)

}

#' Load acs population data
#'
#' @return data.table?
#' @export
#'
load_acs_population_data <- function(){

  a <- file.path(system.file("data-acs",
                             package = "visionZero"),
                 "acs_population_2016.Rds")
  readRDS(a)

}

