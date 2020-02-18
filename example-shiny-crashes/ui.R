
library(leaflet)
library(shinydashboard)
library(shinyjs)

##------------------------------------------------------------------------------
## FUNCTIONS FOR IP LOGGING
##------------------------------------------------------------------------------
geneorama::set_project_dir("vision-zero-dashboard")

##------------------------------------------------------------------------------
## UI
##------------------------------------------------------------------------------

ui <- dashboardPage(
  #tags$style(type = "text/css", "html, body {width:100%;height:100%}"),

  dashboardHeader(title="Filter data"),
  
  #This code just allows the sidebar text to collapse when we collapse the sidebar in whole.
  #It references our classes in style.css and some serverside code that allows for the collapse.

  dashboardSidebar(sidebarMenuOutput("Semi_collapsible_sidebar"),
                   tags$script("$(document).on('click', '.sidebar-toggle', function () {
Shiny.onInputChange('SideBar_col_react', Math.random())});"),
                   tags$script("$(document).on('click', '.treeview.active', function () {
$(this).removeClass('active');
$(this).find( 'ul' ).removeClass('menu-open');
$(this).find( 'ul' ).css('display', 'none');

            });")),
  dashboardBody(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "style.css")),
    leafletOutput("map", width = "73%", height = "900px"),
    absolutePanel(id = "input_panel",
                  
                  #started to add the css to change opacity on hover of this absolute Panel
      
                  fixed = TRUE,
                  top = 60, left = "auto", right = 20, 
                  bottom = "auto",
                  width = 330, height = "auto",
                  draggable = TRUE,
                  h1("Vision Zero Example"),
                  h2("Map datasource options:"),
                  radioButtons(inputId = "MapRegions",
                               label = "Map Regions:",
                               selected = "community",
                               choices = c("Census Tracts" = "census",
                                           "Community Areas" = "community"),
                               inline = TRUE,
                               width = NULL),
                  radioButtons(inputId = "MapStatistic",
                               label = "Map Statistic:",
                               selected = "population",
                               choices = c("Income" = "income",
                                           "Population" = "population"),
                               inline = TRUE,
                               width = NULL),
                  h2("Choose year and statistics:"),
                  selectInput(inputId = "SourceYear",
                              label = "Select Year:",
                              choices = 2009:2018,
                              selected = 2018,
                              multiple = FALSE),
                  selectInput(inputId = "SourceSeverity",
                              label = "Highest severity:",
                              choices = c("No Injuries",
                                          "C Injury Crash",
                                          "B Injury Crash",
                                          "A Injury Crash",
                                          "Fatal Crash"),
                              selected = "A Injury Crash",
                              multiple = TRUE),
                  radioButtons(inputId = "SourceStatistic",
                               label = "Source Statistic:",
                               choices = c("belts used",
                                           "highest BAC")),
                  checkboxInput(inputId = "showRadius",
                                label = "Show cell radius circles",
                                value = TRUE),
                  checkboxInput(inputId = "showVehicleMake",
                                label = "Show vehicle make icons",
                                value = FALSE),
                  #h2("Correlation maps:"),
                  #plotOutput("population_plot", width = 600),
                  # plotOutput("population_plot", height = 300, width = 600),
                  # plotOutput("population_plot", height=300,
                  #            click = "plot_click",  # Equiv, to click=clickOpts(id="plot_click")
                  #            hover = hoverOpts(id = "plot_hover", delayType = "throttle"),
                  #            brush = brushOpts(id = "plot_brush")),
                  # plotOutput("income_plot", width = 600,
                  #            click = "plot_click",  # Equiv, to click=clickOpts(id="plot_click")
                  #            hover = hoverOpts(id = "plot_hover", delayType = "throttle"),
                  #            brush = brushOpts(id = "plot_brush"))
                  # tableOutput('ca_summary'),
                  # tableOutput('zonedata_summary_sh')
    )
    
  )
  #dashboardBody(tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "style.css"))),



)


