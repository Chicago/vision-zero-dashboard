app_server <- function(input, output, session) {

  comm_areas <- load_community_areas_data()

  city_outline <- g_union(comm_areas)



  output$map <- renderLeaflet({

    leaflet() %>%
      # mymap <- leaflet() %>%
      addProviderTiles("Stamen.TonerHybrid") %>%
      addPolygons(data = city_outline, fill = FALSE, color = "black", weight = 2) %>%
      fitBounds(-87.94011, 41.64454, -87.52414, 42.02304)
  })





}
