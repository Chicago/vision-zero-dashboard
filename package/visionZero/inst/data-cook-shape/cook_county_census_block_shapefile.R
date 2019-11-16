

rm(list=ls())

## Make sure that it downloads despite it's misguided efforts to cache
options("tigris_refresh"=TRUE)

## Get census track data
## Note, that because of that little chunk in O'Hare we need DuPage
dupage <- tigris::blocks(state = 17, county = '043')
cook <- tigris::blocks(state = 17, county = '031')
census_blocks <- rbind(dupage, cook)
saveRDS(census_blocks, "data-cook-shape/cook_county_census_block_shapefile.Rds")


