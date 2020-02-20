###########################
#### Call Dark Sky API ####
###########################

# ----
## Hypothesis: adverse weather conditions play a significant role in frequency and severity of traffic accidents.
## To test: augment our existing crash data with weather data from DarkSky API
## How: API call for the time (date, time of day) and place (latitude & longitude) of each traffic accident in our data

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
apiCallWriter <- function(lat, lon, time, key = "1234567890abcdefg" ## change this fake key to your own, given from DarkSky.net
                          ){
  call = paste0("https://api.darksky.net/forecast/",
                key, "/",
                lat, ",",
                lon, ",",
                time, "?",
                "exclude=currently,flags")
  return(call)
}

# create function: unix time ----
unixTime <- function(date, time, tz = "America/Chicago", format = "%m/%d/%Y %H:%M:%S"){
  time = format(strptime(time, "%I:%M %p"), format="%H:%M:%S") ## convert to 24hr format
  humanReadableTime = paste(date, time) # space in between
  epochTime = as.numeric(as.POSIXct(humanReadableTime, format = format, tz = tz))
  return(epochTime)
}

# ----
# crash <- readRDS("data-idot/COMBINED CRASH DATA.Rds") %>%
#   select(lat, lon, CrashHour, CrashMonth)
darkskyinput = crash %>%
  select(ICN, CrashID, lat, lon, TimeOfCrash, CrashDate) %>%
  mutate(CrashUnixTime = unixTime(CrashDate, TimeOfCrash))

masterWeather = setNames(data.table(matrix(nrow = 0,
                                           ncol = 24)),
                         c(## City of Chicago crash data columns
                           "ICN",
                           "CrashID",
                           "CrashDate",
                           "TimeOfCrash",
                           
                           ## Feature Engineering for DarkSky columns
                           "CrashUnixTime",
                           "MinutesFromInput",
                           
                           ## relevant DarkSky weather data columns
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

for(i in c(1:nrow(darkskyinput))){ ## you only get 1,000 free calls per day, run on a small subset to test/develop
  call = apiCallWriter(darkskyinput$lat[i], darkskyinput$lon[i], darkskyinput$CrashUnixTime[i])
  print(call)
  sub = apiData(call) %>%
    mutate(TimeFromInput = abs(hourly.data.time - darkskyinput$CrashUnixTime[i]),
           CrashUnixTime = darkskyinput$CrashUnixTime[i],
           TimeOfCrash = darkskyinput$TimeOfCrash[i],
           CrashDate = darkskyinput$CrashDate[i],
           ICN = darkskyinput$ICN[i],
           CrashID = darkskyinput$CrashID[i]) %>%
    ## whatever the day of the epoch time within the location's time zone,
    ## DarkSky API call returns hourly weather data for the entire day.
    ## here, choose only the weather data for hour nearest the crash
    filter(TimeFromInput == min(TimeFromInput)) %>%
    mutate(TimeFromInput = TimeFromInput / 60) %>%
    rename(MinutesFromInput = TimeFromInput) %>%
    select("ICN",
           "CrashID",
           "CrashDate",
           "TimeOfCrash",
           "CrashUnixTime",
           "MinutesFromInput",
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
           "hourly.data.visibility")
  
  masterWeather = rbind(masterWeather, sub)
  }
View(masterWeather)

