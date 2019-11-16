#########################
### Call Dark Sky API ###
#########################

# ----
## Hypothesis: adverse weather conditions play a significant role in frequency and severity of traffic accidents.
## To test: add weather data from DarkSky API
## How: API call for each time (date & time of day) and place (latitude & longitude) observed in the data

# install libraries ----
install.packages("httr")
#Require the package so you can use it
require("httr")
library(httr)

install.packages("jsonlite")
#Require the package so you can use it
require("jsonlite")
library(jsonlite)

# create function: API to dataframe ----
apiData <- function(call){
  as.data.frame(
    fromJSON(
      content(
        GET(call), "text")
      )
    )
}

# create function: API call writer ----
apiCallWriter <- function(lat, lon, time, key = "9cbfb8d2e1502c2e06cac69d30b1c984"){
  call = paste0("https://api.darksky.net/forecast/",
                key, "/",
                lat, ",",
                lon, ",",
                time, "?",
                "exclude=currently,flags")
  return(call)
}

# create function: unix time ----
unixTime <- function(date, time, tz = "America/Chicago", format = "%m/%d/%Y %H:%M"){
  humanReadableTime = paste(date, time) # space in between
  epochTime = as.numeric(as.POSIXct(humanReadableTime, format = format, tz = tz))
  return(epochTime)
}

# ----
# crash <- readRDS("data-idot/COMBINED CRASH DATA.Rds") %>%
#   select(lat, lon, CrashHour, CrashMonth)
crash2 = crash %>%
  select(lat, lon, CrashHour, CrashMonth, CrashDate, CrashDay) %>%
  mutate(CrashYear = str_sub(CrashDate, -4, -1),
         CrashUnixTime = unixTime(CrashDate, CrashHour))

masterWeather = setNames(data.table(matrix(nrow = 0, ncol = 21)), c("lat", "lon", "CrashUnixTime",
                                                                  ## DarkSky hourly columns
                                                                  "hourly.summary",
                                                                  "hourly.icon",
                                                                  "hourly.data.time",
                                                                  "hourly.data.summary",
                                                                  "hourly.data.icon",
                                                                  "hourly.data.precipIntensity",
                                                                  "hourly.data.precipProbability",
                                                                  "hourly.data.temperature",
                                                                  "hourly.data.apparentTemperature",
                                                                  "hourly.data.dewPoint",
                                                                  "hourly.data.humidity",
                                                                  "hourly.data.pressure",
                                                                  "hourly.data.windSpeed",
                                                                  "hourly.data.windGust",
                                                                  "hourly.data.windBearing",
                                                                  "hourly.data.cloudCover",
                                                                  "hourly.data.uvIndex",
                                                                  "hourly.data.visibility"))
i = 1 ## test out with first row
call = apiCallWriter(crash2$lat[i], crash2$lon[i], crash2$CrashUnixTime[i])
test = apiData(call)

# sample darksky call ----
call = apiCallWriter(lat = 41.90337, lon = -87.68947, time = 1576612000)
test = apiData(call)
## whatever the day of the epoch time within the location's time zone, API call returns that entire day

