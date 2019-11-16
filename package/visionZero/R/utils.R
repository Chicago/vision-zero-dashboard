
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
