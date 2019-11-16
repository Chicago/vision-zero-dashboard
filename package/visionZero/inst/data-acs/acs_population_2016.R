


# install.packages("censusapi")
library(censusapi)
library(geneorama)
library(data.table)


# ccgeo <- tracts(state = '17', county = c('031'), cb = T) ## cb=T means smaller file

Sys.setenv(CENSUS_KEY="60179a2964868d80e37ab0d49e88e654dedf0bc5")
Sys.getenv("CENSUS_KEY")

tigris::lookup_code(state = "Illinois", county = "Cook")
acs_population <- getCensus(name = "acs/acs5", vintage = 2016,
                            vars = c("NAME", "group(B01003)"),
                            regionin="state:17+county:031",
                            region = "tract:*")
acs_population <- as.data.table(acs_population)
str(acs_population)


saveRDS(acs_income, "data/acs_population_2016.Rds")
# df <- readRDS("data/acs_income.Rds")
# rownames(df)
# str(df)




