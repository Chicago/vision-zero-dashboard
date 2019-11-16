


# install.packages("censusapi")
library(censusapi)
library(geneorama)
library(data.table)
library(yaml)

## Saved census key in a config file, 
## you could use readLines or something else to read it
## you can apply for a census key here, click on the "apply for key" blueish button
## https://www.census.gov/data/developers/guidance/api-user-guide.html
censuskey <- yaml::read_yaml("config.yaml")$census_key

# ccgeo <- tracts(state = '17', county = c('031'), cb = T) ## cb=T means smaller file

Sys.setenv(CENSUS_KEY = censuskey)
Sys.getenv("CENSUS_KEY")

tigris::lookup_code(state = "Illinois", county = "Cook")
acs_income <- getCensus(name = "acs/acs5", vintage = 2016,
                        vars = c("NAME", "group(B19013)"),
                        regionin="state:17+county:031",
                        region = "tract:*")
acs_income <- as.data.table(acs_income)
str(acs_income)


saveRDS(acs_income, "data-acs/acs_income_2016.Rds")
# df <- readRDS("data-acs/acs_income.Rds")
# rownames(df)
# str(df)

