#source local files
source("./customMaps.R")
source("./filterByDate.R")
source("./calculateIndicatorValues.R")
source("./flatsheet.R")



#load Shiny Server
shinyServer(function(input, output, session) {
  
  #set up all_data as a "reactive" variable, meaning it updates as needed.
  all_data <- reactive({
    #set filteredData variable by aggregating all data using the function sumData
    #(which can be found in the file flatsheet.R)
    filteredData <- sumData(as.Date(input$dateRange[1]), as.Date(input$dateRange[2]))
  
    #if the user defines a variable for input "hide", remove those types of sites from the data.
    if(length(input$hide)>0){
      filteredData <- subset(filteredData, !(filteredData$OUType %in% input$hide))
    }
    
    #if the user defines a variable for input "show", return only those types of sites
    if(length(input$show)>0){
      filteredData <- subset(filteredData, filteredData$OUType %in% input$show)
    }
    
    #return variable filteredData
    filteredData
    
  }) 
  
  #create reactive colorVariable, which updates the color palette based on a user-defined metric
  colorVariable <- reactive({
    all_data()[[input$color]]
  })
  
  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.
  colorpal <- reactive({
    colorNumeric(input$colors, colorVariable())
  })
  
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(all_data()) %>% addTiles(urlTemplate = "https://api.tiles.mapbox.com/v4/joshpepper.mn8db625/{z}/{x}/{y}.png?access_token=pk.eyJ1Ijoid2tydWdlciIsImEiOiIyY2NhYzEzZWYwYWNiOTllYjY4YTUyNzI2NDgzMTFkMyJ9.U2ScCAatpzYWHi1_aGmnMA") %>%
      fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat))
  })
  
  
  observe({
    mapSelect <- input$mapSelect #set variable for which map to display
    setSize <- mapListLookup[mapListLookup$mapCode==mapSelect,"size"] #lookup the variable for setting the size of markers
    setColor <- mapListLookup[mapListLookup$mapCode==mapSelect,"color"] #lookup the variable for setting the color of markers
    setPal <- mapListLookup[mapListLookup$mapCode==mapSelect,"pal"] #lookup the variable for setting the color palette
    setHide <- mapListLookup[mapListLookup$mapCode==mapSelect,"hide"][[1]] #lookup the list of site types to hide
    
    updateSelectInput(session, "size", selected=setSize) #update the choice for "size" in the UI, when a map is selected
    updateSelectInput(session, "color", selected=setColor) #update the choice for "color" in the UI, when a map is selected
    updateSelectInput(session, "colors", selected=setPal) #update the choice for "colors" in the UI, when a map is selected
    
    if(is.null(setHide)) #if the user has NOT selected any clinics to hide...
    {
      updateSelectizeInput(session, "hide", selected="")#...set UI variable "hide" equal to NULL
    }
    else{
      updateSelectizeInput(session, "hide", selected=setHide) #...set UI variable "hide" equal to the types of sites to hide.
    }
    
  })
  
  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
    pal <- colorpal() #set the variable pal equal to the reactive variable colorpal.
    sizeBy <- input$size
    colorBy <- input$color
    minRadius <- 500 #this is the minimum radius size. All markers below this value will be resized to the minRadius
    radius <- all_data()[,input$size]/max(all_data()[,input$size]) * 5000 #calculate radius, normalizing by largest value.
    radius[radius<minRadius] <- minRadius #find markers with marker size below minRadius and increase the radius size
    
    #set the content to be displayed in the popups of the markers.
    if(sizeBy==colorBy){ #if the two variables are the same, don't repeat the information in the popup twice.
      pasteContent <- paste("<strong>",all_data()[,"OrgUnit05"],"</strong><br>", sizeBy,": ",round(all_data()[,sizeBy],1), sep="")
      
    } else{
      pasteContent <- paste("<strong>",all_data()[,"OrgUnit05"],"</strong><br>", sizeBy,": ",round(all_data()[,sizeBy],1),"<br>",colorBy,": ",round(all_data()[,colorBy],1), sep="")
    }
    
    #update markers with new variables, whenever anything changes.
    leafletProxy("map", data = all_data()) %>%
      clearShapes() %>%
      addCircles(radius = radius, weight = 1, color = "#777777",
                 fillColor = ~pal(all_data()[,colorBy]), fillOpacity = 0.7, popup = ~pasteContent
      )
  })
  
  #create text outputs to be displayed on the "Basic" options tab.
  output$sizeText <- renderText({ 
    paste(input$size)
  })
  output$colorText <- renderText({ 
    paste(input$color)
  })
  
  # Use a separate observer to recreate the legend as needed.
  observe({
    proxy <- leafletProxy("map", data = all_data())
    
    # Remove any existing legend, and only if the legend is
    # enabled, create a new one.
    proxy %>% clearControls()
    if (input$legend) {
      pal <- colorpal()
      sizeBy <- input$size
      colorBy <- input$color
      sizeRange <- all_data()[[colorBy]]
      proxy %>% addLegend(position = "bottomleft",
                          pal = pal, values = sizeRange,
                          #className = "narrow",
                          title = input$color
      )
    }
  })
  
  
  
})