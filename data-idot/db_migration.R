

##==============================================================================
## MIGRATE IDOT DATA TO SQLITE DATABASE
##
## Created by Parfait Gasana 2019-11-16
##
## This script migrates the imported and processed .rds files into separate 
## tables in an SQLite which is a disk-level database (not server). 
## This database will centralizes all data for users and use the power of 
## relational database engine for indexing, relating, and aggregating data.
##
##==============================================================================

library(RSQLite)

###------------------------------------------------------------------------------
### CREATE DATABASE OR CONNECT TO EXSITING DATABASE
###------------------------------------------------------------------------------
conn <- dbConnect(RSQLite::SQLite(), "data-idot/IL_Crash_Data.db")


###------------------------------------------------------------------------------
### CREATE TABLE SCHEMA IN ADVANCE
###------------------------------------------------------------------------------

### CREATE CRASH TABLE
meta <- sapply(crash, typeof)
fields <- paste(mapply(function(n, d) paste0("    ", n, " ", d, ","), 
               names(meta),
               ifelse(meta == "character", "TEXT", toupper(meta))
          ), collapse="\n")
sql <- paste0("CREATE TABLE crash (\n", fields, "\n    PRIMARY KEY (ICN)\n);\n")
cat(sql)

dbExecute(conn, sql)


### CREATE PEOPLE TABLE
meta <- sapply(people, typeof)
fields <- paste(mapply(function(n, d) paste0("    ", n, " ", d, ","), 
                       names(meta),
                       ifelse(meta == "character", "TEXT", toupper(meta))
          ), collapse="\n")
sql <- paste0("CREATE TABLE people (\n", 
              fields, 
              "\n    FORIEGN KEY ICN REFERENCES crash(ICN) );\n")
cat(sql)

dbExecute(conn, sql)


### CREATE VEHICLE TABLE
meta <- sapply(vehicle, typeof)
fields <- paste(mapply(function(n, d) paste0("    ", n, " ", d, ","), 
                       names(meta),
                       ifelse(meta == "character", "TEXT", toupper(meta))
), collapse="\n")
sql <- paste0("CREATE TABLE vehicle (\n", 
              fields, 
              "\n    FORIEGN KEY ICN REFERENCES crash(ICN) );\n")
cat(sql)

dbExecute(conn, sql)


###------------------------------------------------------------------------------
### PUSH DATA FRAMES INTO DATABASE
###------------------------------------------------------------------------------
crash <- readRDS("data-idot/COMBINED CRASH DATA.Rds")
dbWriteTable(conn, "crash", crash, append=TRUE, overwrite=FALSE)
rm(crash)

people <- readRDS("data-idot/COMBINED PERSON DATA.Rds")
dbWriteTable(conn, "people", people, append=TRUE, overwrite=FALSE)
rm(people)

vehicle <- readRDS("data-idot/COMBINED VEHICLE DATA.Rds")
dbWriteTable(conn, "vehicle", vehicle, append=TRUE, overwrite=FALSE)
rm(vehicle)


# ADD INDEXES
dbExecute(conn, "CREATE INDEX people_icn ON people(ICN);")
dbExecute(conn, "CREATE INDEX vehicle_icn ON vehicle(ICN);")


###------------------------------------------------------------------------------
### SAMPLE QUERIES
###------------------------------------------------------------------------------

# SELECT QUERIES
crash <- dbGetQuery(conn, "SELECT * FROM crash LIMIT 10")
people <- dbGetQuery(conn, "SELECT * FROM people LIMIT 10")
vehicle <- dbGetQuery(conn, "SELECT * FROM vehicle LIMIT 10")

# AGGREGATE QUERIES
sql <- "SELECT 2000 + CrashYear, COUNT(*) AS N, 
                          SUM(NumberOfVehicles) AS Total_Vehicles,
                          SUM(NoInjuries) AS Total_NoInjuries,
                          SUM(AInjuries) AS Total_AInjuries,
                          SUM(BInjuries) AS Total_BInjuries,
                          SUM(CInjuries) AS Total_CInjuries,
                          SUM(TotalFatals) AS Total_Fatals
        FROM crash
        GROUP BY CrashYear"
       
crash_agg <- dbGetQuery(conn, sql)
crash_agg

sql <- "SELECT PersonType, COUNT(*) AS N
        FROM people
        GROUP BY PersonType"

person_agg <- dbGetQuery(conn, sql)
person_agg


sql <- "SELECT VehMake, COUNT(*) AS N
        FROM vehicle
        GROUP BY VehMake
        ORDER BY Count(*) DESC"

vehicle_agg <- dbGetQuery(conn, sql)
vehicle_agg


sql <- "SELECT 2000 + c.CrashYear, c.TotalInjured, c.TotalFatals, c.CrashSeverity,
               p.PersonType, p.AgeAtCrash, p.Gender,
               v.VehYear, v.VehicleMake, v.VehModel
        FROM crash c
        LEFT JOIN people p
            ON c.ICN = p.ICN
        LEFT JOIN vehicle v
            ON c.ICN = v.ICN
        LIMIT 20
       "
merge_df <- dbGetQuery(conn, sql)
merge_df

### DISCONNECT 
dbDisconnect(conn)


###------------------------------------------------------------------------------
### ZIP DATA FOR STORAGE OR TRANSFER
###------------------------------------------------------------------------------
zip(zipfile = '/data-idot/IL_Crash_Data', 
    files = paste0(getwd(), '/data-idot/IL_Crash_Data.db'))






