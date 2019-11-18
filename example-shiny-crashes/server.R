library(shiny)
library(leaflet)
library(RColorBrewer)

library(geneorama)

library(rgdal) #for reading/writing geo files
library(rgeos) #for simplification
library(sp)
library(mapview)


##------------------------------------------------------------------------------
## Load data
##------------------------------------------------------------------------------
geneorama::set_project_dir("vision-zero-dashboard")
sourceDir("functions")

## Emulate app environment
# rm(list=ls())
# source("app1/global.R")



server <- function(input, output, session) {
    
    ##--------------------------------------------------------------------------
    ## GENERATE TABLE USED IN PLOTS
    ##--------------------------------------------------------------------------
    
    summary_table <- reactive({
        
        ## 1. Calculate region population and income statistics
        ## 2. Calculate region installation count
        ## 3. join statistics with count
        
        # rm(list=ls())
        # source("app1/global.R")
        # SourceYear <- 2018
        # SourceSeverity <- c("A Injury Crash", "Fatal Crash")
        # SourceStatistic <- "highest BAC"
        # MapRegions <- "community"
        # MapRegions <- "census"
        
        SourceYear <- input$SourceYear
        MapRegions <- input$MapRegions
        SourceSeverity <- input$SourceSeverity
        SourceStatistic <- input$SourceStatistic
        
        stats <- switch(MapRegions,
                        census = {
                            dt <- as.data.table(tracts)
                            dt[i = TRUE,
                               j = list(pop = as.integer(B01003_001E), 
                                        inc = as.integer(B19013_001E)),
                               keyby = GEOID]},
                        community = {
                            dt <- as.data.table(comm_areas)
                            dt[i = TRUE,
                               j = list(pop = as.integer(ssum(B01003_001E)), 
                                        inc = as.integer(ssum(B01003_001E * B19013_001E) / ssum(B01003_001E))), 
                               keyby = community]})
        
        dcast <- function(...) data.table::dcast(..., fun.aggregate = length)
        
        dat <- crash[CrashYear == (as.integer(SourceYear)-2000) &
                         CrashInjurySeverity %in% SourceSeverity]

        # dat[!is.na(ave_belts_used),list(.N, min(ave_belts_used), max(ave_belts_used)), keyby = list(belt_group)]
        tab_comm <- switch(
            SourceStatistic,
            `belts used` = dcast(formula = community ~ belt_group, data = dat, value.var = "belt_group"),
            `highest BAC` = dcast(formula = community ~ any_drugs_or_alcohol, data = dat, value.var = "any_drugs_or_alcohol"))
        tab_tracts <- switch(
            SourceStatistic,
            `belts used` = dcast(formula = GEOID ~ belt_group, data = dat, value.var = "belt_group"),
            `highest BAC` = dcast(formula = GEOID ~ any_drugs_or_alcohol, data = dat, value.var = "any_drugs_or_alcohol"))
        tab <- switch(MapRegions,
                      community = tab_comm,
                      census = tab_tracts)
        # oldnames <- icon_data[[SourceStatistic]][match(colnames(tab), icon_data[[SourceStatistic]])]
        # newnames <- icon_data[["name"]][match(colnames(tab), icon_data[[SourceStatistic]])]
        # setnames(tab, na.omit(oldnames), na.omit(newnames))
        
        tab <- merge(stats, tab)
        
        return(tab)
    })
    
    output$ca_summary <- renderTable({
        tab <- summary_table()
        return(tab)
    })
    
    ##--------------------------------------------------------------------------
    ## INCOME PLOT
    ##--------------------------------------------------------------------------
    
    output$income_plot <- renderPlot({
        
        SourceYear <- input$SourceYear
        MapRegions <- input$MapRegions
        
        tab <- summary_table()
        
        flat <- switch(MapRegions,
                       community = melt(tab, id.vars = c("community", "pop", "inc"),
                                        variable.name = "statistic", value.name = "N"),
                       census = melt(tab, id.vars = c("GEOID", "pop", "inc"),
                                     variable.name = "statistic", value.name = "N")
        )
        flat <- flat[N!=0]
        flat <- flat[!is.na(inc)]
        
        ggplot(flat) +
            aes(x = inc, y = N, colour = statistic) +
            geom_point() +
            geom_smooth(span = .3, method = lm, se=F) +
            # geom_smooth(method = lm, formula = y ~ splines::bs(x, 5), se = F) +
            xlab("Income") +
            # scale_x_log10() + scale_y_log10() +
            ylab(paste("Count based on ", SourceYear)) +
            theme(plot.title = element_text(size = 20)) +
            # expand_limits(x=c(10000, 105000)) +
            labs(title = paste0("Correlation plot for Income (by ", titlecase(MapRegions), ")\n") )
    })
    
    ##--------------------------------------------------------------------------
    ## POPULATION PLOT
    ##--------------------------------------------------------------------------
    
    output$population_plot <- renderPlot({

        SourceYear <- input$SourceYear
        MapRegions <- input$MapRegions
        
        tab <- summary_table()
        
        flat <- switch(MapRegions,
                       community = melt(tab, id.vars = c("community", "pop", "inc"),
                                        variable.name = "statistic", value.name = "N"),
                       census = melt(tab, id.vars = c("GEOID", "pop", "inc"),
                                     variable.name = "statistic", value.name = "N")
        )
        flat <- flat[N!=0]
        flat <- flat[!is.na(inc)]
        
        ggplot(flat) +
            aes(x = pop, y = N, colour = statistic) +
            geom_point() +
            geom_smooth(span = .3, method = lm, se=F) +
            # geom_smooth(method = lm, formula = y ~ splines::bs(x, 5), se = F) +
            xlab("Population") + 
            ylab(paste("Count based on ", SourceYear)) +
            theme(plot.title = element_text(size = 20)) +
            # scale_x_log10() + scale_y_log10() +
            labs(title = paste0("Corellation plot for Population (by ", titlecase(MapRegions), ")\n") )
    })
    
    ##--------------------------------------------------------------------------
    ## BASIC LEAFLET MAP
    ##--------------------------------------------------------------------------
    
    #I changed these to make the map reactive so we can call it for download later.
    
    map_reactive <- reactive({
        
        leaflet() %>%
            # mymap <- leaflet() %>%
            addProviderTiles("Stamen.TonerHybrid") %>% 
            addPolygons(data = city_outline, fill = FALSE, color = "black", weight = 2) %>%
            fitBounds(-87.94011, 41.64454, -87.52414, 42.02304)
        
    })
    
    
    output$map <- renderLeaflet({
        
        map_reactive()

    })
    
    ##--------------------------------------------------------------------------
    ## DECORATE LEAFLET MAP
    ## ADD POLYGONS FOR  CENSUS TRACT | COMMUNITY AREA
    ##                   INCOME       | POPULATION
    ##--------------------------------------------------------------------------
    
    observe({
        MapRegions <- input$MapRegions # "census" or "community"
        MapStatistic <- input$MapStatistic # "income" or "population"
        
        case <- paste0(MapRegions, "_", MapStatistic)
        
        leafletProxy("map") %>%
            clearShapes() %>%
            clearControls() %>%
            addPolylines(data = city_outline, weight=2, fill=FALSE, color="black", opacity=1)
        
        switch(case,
               census_income = {
                   leafletProxy("map") %>%
                       addPolygons(data = tracts,
                                   fillColor = ~ pal_inc(tracts@data$B19013_001E),
                                   fillOpacity = 0.7, weight = 0.5,
                                   label = ~NAMELSAD)},
               census_population = {
                   leafletProxy("map") %>%
                       addPolygons(data = tracts,
                                   fillColor = ~ pal_pop(tracts@data$B01003_001E),
                                   fillOpacity = 0.7, weight = 0.5,
                                   label = ~NAMELSAD)},
               community_income = {
                   leafletProxy("map") %>%
                       addPolygons(data = comm_areas,
                                   fillColor = ~ pal_inc(comm_areas@data$B19013_001E),
                                   fillOpacity = 0.7, weight = 1.5,
                                   color = "black",
                                   label = ~community)},
               community_population = {
                   leafletProxy("map") %>%
                       addPolygons(data = comm_areas,
                                   fillColor = ~ pal_pop(comm_areas@data$B01003_001E),
                                   fillOpacity = 0.7, weight = 1.5,
                                   color = "black",
                                   label = ~community)})
    
        ## LEGEND FOR INCOME OR POPULATION
        
        switch(MapStatistic,
               income = {
                   leafletProxy("map") %>%
                       addLegend(colors = legend_colors_inc,  
                                 values = legend_values_inc, 
                                 labels = legend_labels_inc,
                                 position = "bottomright", 
                                 title = "Income Levels")},
               population = {
                   leafletProxy("map") %>%
                       addLegend(colors = legend_colors_pop,  
                                 values = legend_values_pop, 
                                 labels = legend_labels_pop,
                                 position = "bottomright", 
                                 title = "Population Levels")})
    })
    
    ##--------------------------------------------------------------------------
    ## GENERATE DATA
    ##     PLOT CIRCLES
    ##     PLOT SYMBOLS
    ##--------------------------------------------------------------------------
    
    observe({
        
        cat("create icon data\n")
        # browser()

        MapRegions <- input$MapRegions # "census" or "community"
        MapStatistic <- input$MapStatistic # "income" or "population"
        SourceSeverity <- input$SourceSeverity
        SourceStatistic <- input$SourceStatistic
        
        SourceYear <- input$SourceYear
        showVehicleMake <- input$showVehicleMake
        showRadius <- input$showRadius
        
        dat <- crash[CrashYear == (as.integer(SourceYear) - 2000) &
                         CrashInjurySeverity %in% SourceSeverity]

        switch(
            SourceStatistic,
            `belts used` = {
                dat <- cbind(dat, dat[ , list(latitude=lat, longitude=lon, statistic = belt_group)])
                dat$icon_file <- icon_data[match(dat$veh_make, icon_data$makes), file]
                dat$icon_full_file <- icon_data[match(dat$veh_make, icon_data$makes), full_file]
                icon_legend_data <- icon_data
            },
            `highest BAC` = {
                dat <- cbind(dat, dat[ , list(latitude=lat, longitude=lon, statistic = any_drugs_or_alcohol)])
                dat$icon_file <- icon_data[match(dat$veh_make, icon_data$makes), file]
                dat$icon_full_file <- icon_data[match(dat$veh_make, icon_data$makes), full_file]
                icon_legend_data <- icon_data
            })
        
        icon_legend <- paste0("<img %s", basename(icon_legend_data$file), '>',
                              icon_legend_data$name, 
                              sep = "", collapse = "<br/>")
        icon_legend <- gsub("%s", "src=http://geneorama.com/code/icons/", icon_legend)
        
        # leaflet() %>%
        #     addMarkers(data=data.table(a=1,b=1), lng = ~a, lat = ~b,
        #                icon = icons(~"data/icons/2.png", iconHeight = 10,iconWidth = 10)) %>%
        #     addControl(html = icon_legend, layerId = "icon_legend", position = "bottomright")
        
        new_markers <<- as.character(1:nrow(dat))
        if(!exists("old_markers")) old_markers <<- new_markers
        if(showRadius){
            leafletProxy("map") %>%
                clearMarkers() %>%
                removeShape(layerId = old_markers) %>%
                addCircles(data = dat, lng = dat$longitude, lat = dat$latitude, 
                           layerId = new_markers,
                           label = ~statistic,
                           # radius = 152.4, ## 152.4 meters is 500 feet
                           radius = ~person_record_count*15.24, ## 152.4 meters is 500 feet
                           stroke = TRUE, color = "black", weight = .8, opacity = 1,
                           fillColor = "orange", fillOpacity = 0.5)
        } else {
            leafletProxy("map") %>%
                clearMarkers() %>%
                removeShape(layerId = old_markers)
        }
        old_markers <<- new_markers
        
        if(showVehicleMake){
            leafletProxy("map") %>%
                addMarkers(data = dat, lng = ~longitude, lat = ~latitude, label = ~veh_make,
                           icon = icons(~icon_file,
                                        iconHeight = ICON_HEIGHT,
                                        iconWidth = ICON_WIDTH)) %>%
                addControl(html = icon_legend, 
                           layerId = "icon_legend",
                           position = "bottomright")
        } else {
            leafletProxy("map") %>%
                clearMarkers() %>%
                removeControl(layerId = "icon_legend")
        }
    })
    
    #Adding a collapsible sidebar to add data filters to this application 
    
    vals <- reactiveValues()
    vals$collapsed = FALSE
    observeEvent(input$SideBar_col_react,
                 {
                     vals$collapsed=!vals$collapsed
                 }
    )
    
    #To get the download to include datapoints, we need to create a reactive map object with the 
    # same properties as our output map above
    
    map_reactive_download <- reactive({
        
        case <- paste0(input$MapRegions, "_", input$MapStatistic)

        map_zoom <- map_reactive() %>%
            setView(lng = input$map_center$lng,  
                 lat = input$map_center$lat,
                 zoom = input$map_zoom) %>%
            addPolylines(data = city_outline, weight=2, fill=FALSE, color="black", opacity=1)
        
        
        
        switch(case,
               census_income = {
                   map_fill <- map_zoom %>%
                       addPolygons(data = tracts,
                                   fillColor = ~ pal_inc(tracts@data$B19013_001E),
                                   fillOpacity = 0.7, weight = 0.5,
                                   label = ~NAMELSAD)},
               census_population = {
                   map_fill <- map_zoom %>%
                       addPolygons(data = tracts,
                                   fillColor = ~ pal_pop(tracts@data$B01003_001E),
                                   fillOpacity = 0.7, weight = 0.5,
                                   label = ~NAMELSAD)},
               community_income = {
                   map_fill <- map_zoom %>%
                       addPolygons(data = comm_areas,
                                   fillColor = ~ pal_inc(comm_areas@data$B19013_001E),
                                   fillOpacity = 0.7, weight = 1.5,
                                   color = "black",
                                   label = ~community)},
               community_population = {
                   map_fill <- map_zoom %>%
                       addPolygons(data = comm_areas,
                                   fillColor = ~ pal_pop(comm_areas@data$B01003_001E),
                                   fillOpacity = 0.7, weight = 1.5,
                                   color = "black",
                                   label = ~community)})
        
        switch(input$MapStatistic,
               income = {
                   map_leg <- map_fill %>%
                       addLegend(colors = legend_colors_inc,  
                                 values = legend_values_inc, 
                                 labels = legend_labels_inc,
                                 position = "bottomright", 
                                 title = "Income Levels")},
               population = {
                   map_leg <- map_fill %>%
                       addLegend(colors = legend_colors_pop,  
                                 values = legend_values_pop, 
                                 labels = legend_labels_pop,
                                 position = "bottomright", 
                                 title = "Population Levels")})
        
        #return(map_leg)
        
        
        
        MapRegions <- input$MapRegions # "census" or "community"
        MapStatistic <- input$MapStatistic # "income" or "population"
        SourceSeverity <- input$SourceSeverity
        SourceStatistic <- input$SourceStatistic
        
        SourceYear <- input$SourceYear
        showVehicleMake <- input$showVehicleMake
        showRadius <- input$showRadius
        
        dat <- crash[CrashYear == (as.integer(SourceYear) - 2000) &
                         CrashInjurySeverity %in% SourceSeverity]
        
        switch(
            SourceStatistic,
            `belts used` = {
                dat <- cbind(dat, dat[ , list(latitude=lat, longitude=lon, statistic = belt_group)])
                dat$icon_file <- icon_data[match(dat$veh_make, icon_data$makes), file]
                dat$icon_full_file <- icon_data[match(dat$veh_make, icon_data$makes), full_file]
                icon_legend_data <- icon_data
            },
            `highest BAC` = {
                dat <- cbind(dat, dat[ , list(latitude=lat, longitude=lon, statistic = any_drugs_or_alcohol)])
                dat$icon_file <- icon_data[match(dat$veh_make, icon_data$makes), file]
                dat$icon_full_file <- icon_data[match(dat$veh_make, icon_data$makes), full_file]
                icon_legend_data <- icon_data
            })
        
        icon_legend <- paste0("<img %s", basename(icon_legend_data$file), '>',
                              icon_legend_data$name, 
                              sep = "", collapse = "<br/>")
        icon_legend <- gsub("%s", "src=http://geneorama.com/code/icons/", icon_legend)
        
        # leaflet() %>%
        #     addMarkers(data=data.table(a=1,b=1), lng = ~a, lat = ~b,
        #                icon = icons(~"data/icons/2.png", iconHeight = 10,iconWidth = 10)) %>%
        #     addControl(html = icon_legend, layerId = "icon_legend", position = "bottomright")
        
        new_markers <<- as.character(1:nrow(dat))
        if(!exists("old_markers")) old_markers <<- new_markers
        if(showRadius){
            map_markers <- map_leg %>%
                clearMarkers() %>%
                removeShape(layerId = old_markers) %>%
                addCircles(data = dat, lng = dat$longitude, lat = dat$latitude, 
                           layerId = new_markers,
                           label = ~statistic,
                           # radius = 152.4, ## 152.4 meters is 500 feet
                           radius = ~person_record_count*15.24, ## 152.4 meters is 500 feet
                           stroke = TRUE, color = "black", weight = .8, opacity = 1,
                           fillColor = "orange", fillOpacity = 0.5)
        } else {
            map_markers <- map_leg %>%
                clearMarkers() %>%
                removeShape(layerId = old_markers)
        }
        old_markers <<- new_markers
        
        if(showVehicleMake){
            map_markers_2 <- map_markers %>%
                addMarkers(data = dat, lng = ~longitude, lat = ~latitude, label = ~veh_make,
                           icon = icons(~icon_file,
                                        iconHeight = ICON_HEIGHT,
                                        iconWidth = ICON_WIDTH)) %>%
                addControl(html = icon_legend, 
                           layerId = "icon_legend",
                           position = "bottomright")
        } else {
            map_markers_2 <- map_markers %>%
                clearMarkers() %>%
                removeControl(layerId = "icon_legend")
        }
        
        return(map_markers_2)

    })
    
    #This code is just a messy example of an additional collapseable sidebar with a download button
    # and potential inputs for someone to filter data
    
    output$Semi_collapsible_sidebar<-renderMenu({
        if (vals$collapsed)
            sidebarMenu(
                menuItem(NULL, tabName = "filter_1", icon = icon("dashboard")),
                menuItem(NULL, icon = icon("th"), tabName = "filter_2",
                         badgeColor = "green")
                #downloadButton( outputId = "dl"))
            )
        else
            sidebarMenu(
                menuItem("Filter date", tabName = "filter_1", icon = icon("dashboard")),
                menuItem("Filter demographics", icon = icon("th"), tabName = "filter_2",
                         badgeColor = "green"),
                br(),
                downloadButton(outputId = "dl", label = "Download Viz"),
                class = "download_this")
    })
    
    output$dl <- downloadHandler(
        filename = paste0(Sys.Date(),
                          "_customLeafletmap", 
                          ".png"
        ), 
        content = function(file) {
            
            mapshot(x = map_reactive_download(), 
                    file = file,
                    cliprect = "viewport", 
                    selfcontained = FALSE)
            
        }

    )
}

