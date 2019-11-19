
suppressPackageStartupMessages(library(shinydashboard))
suppressPackageStartupMessages(library(DT))
suppressPackageStartupMessages(library(RSQLite))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(scales))

seabornPalette <- c("#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868",
                    "#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868","#c44e52","#8172b2",
                    "#ccb974","#64b5cd","#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd",
                    "#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868",
                    "#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868","#c44e52","#8172b2",
                    "#ccb974","#64b5cd","#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd",
                    "#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868",
                    "#c44e52","#8172b2","#ccb974","#64b5cd")

###------------------------------------------------------------------------------
### INPUT CHOICES
###------------------------------------------------------------------------------

collision_type_df <- data.frame(CollisionTypeCode = c(1:15),
                                CollisionType = c('Pedestrian', 'Pedalcyclist', 'Train',
                                                  'Animal', 'Overturned', 'Fixed Object',
                                                  'Other Object', 'Other non-collision',
                                                  'Parked Motor vehicle', 'Turning',
                                                  'Rear-end', 'Sideswipe-same direction',
                                                  'Sideswipe-opposite direction',
                                                  'Head-on', 'Angle')
                                )

vehicle_type_df <- data.frame(VehTypeCode = c(1:16,20,99),
                              VehType = c('Passenger car', 'Pickup truck', 'Van/mini-van',
                                          'Bus up to 15 passengers', 'Bus over 15 passengers',
                                          'Truck – single unit', 'Tractor w/semi-trailer',
                                          'Tractor w/o semi-trailer', 'Farm equipment',
                                          'Motorcycle (over 150 cc)', 'Motor driven cycle',
                                          'Snowmobile', 'All-terrain vehicle (ATV)',
                                          'Other vehicle with trailer',
                                          'Sport utility vehicle (SUV)',
                                          'Other', 'Autocycle    Added for 2015', 'Unknown/NA')

                              )

traffic_way_df <- data.frame(ClassOfTrafficwayCode = seq(0, 9),
                             ClassOfTrafficway = c('Unmarked Highway rural',
                                                   'Controlled rural',
                                                   'State numbered rural',
                                                   'County and local roads rural',
                                                   'Toll roads rural',
                                                   'Controlled urban',
                                                   'State numbered urban',
                                                   'Unmarked highway urban',
                                                   'City streets urban',
                                                   'Toll roads urban')
                             )
                               
person_type_df <- data.frame(PersonTypeCode = c(1:7),
                             PersonType = c('Driver', 'Pedestrian', 'Pedalcyclist',
                                            'Equestrian', 'Occupant of non-motorized vehicle',
                                            'Noncontact vehicle', 'Passenger')
                            )
        
crash_severity_df <- data.frame(CrashSeverity = c('Property Damage', 'Injury', 'Fatal'))

driver_condition_df <- data.frame(DriverConditionCode = c(1:12),
                                  DriverCondition = c('Normal', 'Impaired – alcohol',
                                                      'Impaired – drugs', 'Illness',
                                                      'Asleep/fainted', 'Medicated',
                                                      'Had been drinking', 'Fatigued',
                                                      'Other/unknown', 'Other',
                                                      'Emotional (depressed, angry, disturbed)',
                                                      'Removed by EMS')
                                  )


###------------------------------------------------------------------------------
### PREPARED STATEMENTS
###------------------------------------------------------------------------------

collision_sql <- "SELECT COUNT(*) AS N, 
                         SUM(NumberOfVehicles) AS Total_Vehicles,
                         SUM(TotalInjured) AS Total_Injuries,
                         SUM(NoInjuries) AS Total_NoInjuries,
                         SUM(AInjuries) AS Total_AInjuries,
                         SUM(BInjuries) AS Total_BInjuries,
                         SUM(CInjuries) AS Total_CInjuries,
                         SUM(TotalFatals) AS Total_Fatals
                 FROM crash
                 WHERE CityClassCode = 3 
                   AND CollisionTypeCode = ?"

year_sql <- "SELECT COUNT(*) AS N, 
                    SUM(NumberOfVehicles) AS Total_Vehicles,
                    SUM(TotalInjured) AS Total_Injuries,
                    SUM(NoInjuries) AS Total_NoInjuries,
                    SUM(AInjuries) AS Total_AInjuries,
                    SUM(BInjuries) AS Total_BInjuries,
                    SUM(CInjuries) AS Total_CInjuries,
                    SUM(TotalFatals) AS Total_Fatals
             FROM crash
             WHERE CityClassCode = 3 
               AND (CrashYear + 2000) = ?"

traffic_sql <- "SELECT COUNT(*) AS N, 
                    SUM(NumberOfVehicles) AS Total_Vehicles,
                    SUM(TotalInjured) AS Total_Injuries,
                    SUM(NoInjuries) AS Total_NoInjuries,
                    SUM(AInjuries) AS Total_AInjuries,
                    SUM(BInjuries) AS Total_BInjuries,
                    SUM(CInjuries) AS Total_CInjuries,
                    SUM(TotalFatals) AS Total_Fatals
             FROM crash
             WHERE CityClassCode = 3 
               AND ClassOfTrafficwayCode = ?"

person_sql <- "SELECT COUNT(*) AS N, 
                    SUM(c.NumberOfVehicles) AS Total_Vehicles,
                    SUM(c.TotalInjured) AS Total_Injuries,
                    SUM(c.NoInjuries) AS Total_NoInjuries,
                    SUM(c.AInjuries) AS Total_AInjuries,
                    SUM(c.BInjuries) AS Total_BInjuries,
                    SUM(c.CInjuries) AS Total_CInjuries,
                    SUM(c.TotalFatals) AS Total_Fatals
             FROM crash c
             LEFT JOIN people p
                    ON c.ICN = p.ICN
             WHERE c.CityClassCode = 3 
               AND p.PersonTypeCode = ?"

driver_sql <- "SELECT COUNT(*) AS N, 
                    SUM(c.NumberOfVehicles) AS Total_Vehicles,
                    SUM(c.TotalInjured) AS Total_Injuries,
                    SUM(c.NoInjuries) AS Total_NoInjuries,
                    SUM(c.AInjuries) AS Total_AInjuries,
                    SUM(c.BInjuries) AS Total_BInjuries,
                    SUM(c.CInjuries) AS Total_CInjuries,
                    SUM(c.TotalFatals) AS Total_Fatals
             FROM crash c
             LEFT JOIN people p
                    ON c.ICN = p.ICN
             WHERE c.CityClassCode = 3 
               AND p.DRAC = ?"

severity_sql <- "SELECT COUNT(*) AS N, 
                        SUM(NumberOfVehicles) AS Total_Vehicles,
                        SUM(TotalInjured) AS Total_Injuries,
                        SUM(NoInjuries) AS Total_NoInjuries,
                        SUM(AInjuries) AS Total_AInjuries,
                        SUM(BInjuries) AS Total_BInjuries,
                        SUM(CInjuries) AS Total_CInjuries,
                        SUM(TotalFatals) AS Total_Fatals
                FROM crash
                WHERE CityClassCode = 3 
                  AND CrashSeverity = ?"


###------------------------------------------------------------------------------
### UI BUILD
###------------------------------------------------------------------------------

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("What?", tabName = "what_tab", icon = icon("dashboard")),
    menuItem("When?", tabName = "when_tab", icon = icon("dashboard")), 
    menuItem("Where?", tabName = "where_tab", icon = icon("dashboard")), 
    menuItem("Who?", tabName = "who_tab", icon = icon("dashboard")), 
    menuItem("Why?", tabName = "why_tab", icon = icon("dashboard")),
    menuItem("How?", tabName = "how_tab", icon = icon("dashboard")),
    badgeColor = "green"
  )
)

body <- dashboardBody(
  tabItems(
    tabItem(tabName = "what_tab",
            h2("What types of collisions?"),
            selectInput(inputId = "collision_type", label = "Collision Type",
                        choices = setNames(collision_type_df$CollisionTypeCode,
                                           collision_type_df$CollisionType), 
                        selected = 1
                        ),
            actionButton("what_tab_submit", "Submit"),
            br(),
            h3("Table"),
            DT::dataTableOutput("what_tab_table"),
            br(),
            h3("Graph"),
            plotOutput("what_tab_plot")
    ),
    
    tabItem(tabName = "when_tab",
            h2("When did crashes occur?"),
            selectInput("crash_year", NULL,
                        setNames(c(2009:2018),
                                 c(2009:2018)), selected = 2018
                        ),
            actionButton("when_tab_submit", "Submit"),
            br(),
            h3("Table"),
            DT::dataTableOutput("when_tab_table"),
            br(),
            h3("Graph"),
            plotOutput("when_tab_plot")
    ),
    
    tabItem(tabName = "where_tab",
            h2("Where did crashes occur?"),
            selectInput("traffic_way", NULL,
                        setNames(traffic_way_df$ClassOfTrafficwayCode,
                                 traffic_way_df$ClassOfTrafficway), selected = 8
                        ),
            actionButton("where_tab_submit", "Submit"),
            br(),
            h3("Table"),
            DT::dataTableOutput("where_tab_table"),
            br(),
            h3("Graph"),
            plotOutput("where_tab_plot")
    ),
    
    tabItem(tabName = "who_tab",
            h2("Who was involved in crashes?"),
            selectInput("person_type", NULL,
                        setNames(person_type_df$PersonTypeCode,
                                 person_type_df$PersonType), selected = 1
                        ),
            actionButton("who_tab_submit", "Submit"),
            br(),
            h3("Table"),
            DT::dataTableOutput("who_tab_table"),
            br(),
            h3("Graph"),
            plotOutput("who_tab_plot")
    ),
    
    tabItem(tabName = "why_tab",
            h2("Why did crashes occur?"),
            selectInput("driver_condition", NULL,
                        setNames(driver_condition_df$DriverConditionCode,
                                 driver_condition_df$DriverCondition), selected = 1
                        ),
            actionButton("why_tab_submit", "Submit"),
            br(),
            h3("Table"),
            DT::dataTableOutput("why_tab_table"),
            br(),
            h3("Graph"),
            plotOutput("why_tab_plot")
    ),
    
    tabItem(tabName = "how_tab",
            h2("How severe were crashes?"),
            selectInput("crash_severity", NULL,
                        crash_severity_df$CrashSeverity, selected = "Property Damage"
            ),
            actionButton("how_tab_submit", "Submit"),
            br(),
            h3("Table"),
            DT::dataTableOutput("how_tab_table"),
            br(),
            h3("Graph"),
            plotOutput("how_tab_plot")
    )
  ),
  style = "font-family: Arial;",
  tags$head( 
    tags$style(HTML(".main-sidebar { font-family: Arial; font-size: 16px; }
                     h2, h3 { font-family: Arial; font-size: 24px; }"))
  )
)

ui <- dashboardPage(
  dashboardHeader(title = "Chicago Crash Data"),
  sidebar,
  body
)


###------------------------------------------------------------------------------
### SERVER FUNCTIONS
###------------------------------------------------------------------------------

server <- function(input, output) {

  collision_type_input <- reactive({ input$collision_type }) 
  crash_year_input <- reactive({ input$crash_year  })
  traffic_way_input <- reactive({ input$traffic_way })
  person_type_input <- reactive({ input$person_type })
  driver_condition_input <- reactive({ input$driver_condition })
  severity_input <- reactive({ input$crash_severity })
  
  db_data <- function(sql, param) {
    conn <- dbConnect(RSQLite::SQLite(), "data-idot/IL_Crash_Data.db")
    agg <- withProgress(expr = { dbGetQuery(conn, sql, params = list(param)) }, 
                        message = "Loading... Please wait")
    dbDisconnect(conn)
    
    rdf <- within(reshape(agg, varying = names(agg), times = names(agg),
                          v.names = "Value", timevar = "Metric",
                          new.row.names = 1:1E5, direction = "long"),
                  rm(id))
    
    return(rdf)
  }
  
  graph_data <- function(df, graph_title) {
    tryCatch({
      ggplot(df, aes(x=Metric, y=Value, fill=Metric)) +
        geom_col(position = "dodge") +
        scale_fill_manual(values = seabornPalette) +
        scale_y_continuous(expand = c(0, 0), label=comma) +
        labs(title=graph_title) +
        guides(fill=FALSE) + 
        theme(plot.title = element_text(hjust=0.5, size=24),
              text = element_text(size=20))
    }, warning = function(w) {
      print(w)
    })
  }
  
  observeEvent(input$what_tab_submit, {
    i_type <- collision_type_input()
    rdf <- db_data(collision_sql, as.integer(i_type))
    plt <- graph_data(rdf, 
                      paste("Total Counts of", 
                            subset(collision_type_df, 
                                   CollisionTypeCode == i_type)$CollisionType, 
                            "Collision Types"))
    
    output$what_tab_table <- DT::renderDataTable({
      DT::datatable(rdf, escape = FALSE)
    })
    
    output$what_tab_plot <- renderPlot({
      plt
    })
  })
  
  observeEvent(input$when_tab_submit, {
    i_type <- crash_year_input()
    rdf <- db_data(year_sql, as.integer(i_type))
    plt <- graph_data(rdf, 
                      paste("Total Counts of", 
                            i_type, 
                            "Crashes"))
    
    output$when_tab_table <- DT::renderDataTable({
      DT::datatable(rdf, escape = FALSE)
    })
    
    output$when_tab_plot <- renderPlot({
      plt
    })
  })
  
  observeEvent(input$where_tab_submit, {
    i_type <- traffic_way_input()
    rdf <- db_data(traffic_sql, as.integer(i_type))
    plt <- graph_data(rdf, 
                      paste("Total Counts of", 
                            subset(traffic_way_df, 
                                   ClassOfTrafficwayCode == i_type)$ClassOfTrafficway, 
                            "Crashes"))
    
    output$where_tab_table <- DT::renderDataTable({
      DT::datatable(rdf, escape = FALSE)
    })
    
    output$where_tab_plot <- renderPlot({
      plt
    })
  })
  
  observeEvent(input$who_tab_submit, {
    i_type <- person_type_input()
    rdf <- db_data(person_sql, as.integer(i_type))
    plt <- graph_data(rdf, 
                      paste("Total Counts of Crashes Involving", 
                            subset(person_type_df, 
                                   PersonTypeCode == i_type)$PersonType, 
                            "Person(s)"))
    
    output$who_tab_table <- DT::renderDataTable({
      DT::datatable(rdf, escape = FALSE)
    })
    
    output$who_tab_plot <- renderPlot({
      plt
    })
  })
  
  observeEvent(input$why_tab_submit, {
    i_type <- driver_condition_input()
    rdf <- db_data(driver_sql, as.integer(i_type))
    plt <- graph_data(rdf, 
                      paste("Total Counts of Crashes with", 
                            subset(driver_condition_df, 
                                   DriverConditionCode == i_type)$DriverCondition, 
                            "Driver Condition"))
    
    output$why_tab_table <- DT::renderDataTable({
      DT::datatable(rdf, escape = FALSE)
    })
    
    output$why_tab_plot <- renderPlot({
      plt
    })
  })
  
  observeEvent(input$how_tab_submit, {
    i_type <- severity_input()
    rdf <- db_data(severity_sql, i_type)
    plt <- graph_data(rdf, 
                      paste("Total Counts of", 
                            i_type, 
                            "Crash Severity"))
    
    output$how_tab_table <- DT::renderDataTable({
      DT::datatable(rdf, escape = FALSE)
    })
    
    output$how_tab_plot <- renderPlot({
      plt
    })
  })
}



shinyApp(ui, server)

