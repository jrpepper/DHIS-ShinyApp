library(shiny)
library(leaflet)
library(RColorBrewer)
library(CartoDB)
library(plyr)
library(Hmisc)
library(dplyr)

#source local files
source("./customMaps.R")
source("./flatsheet.R")

#navbarPage("DHIS Data Explorer",
shinyUI(
  
  #create navigation menu on the top of the page.
  navbarPage("DHIS Data Explorer", id="nav",
             
             #Main Bubble Map page.
             tabPanel("View Map", icon = icon("map-marker"),
                      #add bootstrap
                      tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.css")),
                      tags$head(tags$link(rel = 'stylesheet', type = 'text/css', href = 'styles.css')),
                      
                      #add custom CSS
                      tags$style(type = "text/css", "html, body {width:100%;height:100%}, .narrow .leaflet-control .leaflet-drag-target {  background-color: white; padding: 10px; max-width: 200px; margin-right: 20px;}"),
                      tags$head(tags$style("#map{height:92vh !important;}")),
                      tags$head(tags$style(".navbar{margin-bottom: 0px !important;}")),
                      tags$head(tags$style(".container-fluid{padding: 0px !important;}")),
                      
                      #leaflet output map
                      leafletOutput("map", height=300),
                      
                      #options panel
                      absolutePanel(top = 90, right = 30, draggable=TRUE,
                                    wellPanel(style = "background-color: #ffffff; width: 350px",
                                              tabsetPanel(type = "tabs",
                                                          
                                                          #Basic Options Tab
                                                          tabPanel('Basic Options', br(),
                                                                   selectInput('mapSelect', 'Choose Map:', choices = mapList),
                                                                   strong("Marker size:", style = "color: #919191;"),br(),textOutput("sizeText"),br(),
                                                                   strong("Marker color:", style = "color: #919191;"),br(),textOutput("colorText")
                                                          ),
                                                          
                                                          #Advanced Options Tab
                                                          tabPanel('Advanced', br(),
                                                                   
                                                                   #select date
                                                                   dateRangeInput('dateRange',
                                                                                  label = 'Date range input: yyyy-mm-dd',
                                                                                  start = Sys.Date() - 365, end = Sys.Date()
                                                                   ),
                                                                   
                                                                   #select marker size
                                                                   selectInput("size", "Size markers based on:",
                                                                               fullList,
                                                                               selected="Antenatal 1st visit total"
                                                                   ),
                                                                   
                                                                   #select marker color
                                                                   selectInput("color", "Color markers based on:",
                                                                               fullList,
                                                                               selected="Antenatal 1st visit before 20 weeks rate"
                                                                   ),
                                                                   
                                                                   #show only these types of sites
                                                                   selectizeInput("show", "Show only these types of sites",
                                                                               as.vector(unique(typeList$OUType)),
                                                                               multiple=TRUE
                                                                   ),
                                                                   
                                                                   #hide these types of sites
                                                                   selectizeInput("hide", "Hide these types of sites",
                                                                                  as.vector(unique(typeList$OUType)),
                                                                                  multiple=TRUE
                                                                   ),
                                                                   
                                                                   #choose color palette
                                                                   selectInput("colors", "Color Scheme",
                                                                               rownames(subset(brewer.pal.info, category %in% c("seq", "div"))),
                                                                               selected = "GnYlRd"
                                                                   ),
                                                                   
                                                                   #show or hide legend, checkbox.
                                                                   checkboxInput("legend", "Show legend", TRUE)
                                                          )
                                              )
                                    )
                      )
                      
             ),
             
             #Multivariate Map. NOTE: only works in browser, doesn't work in R Shiny viewer
             #due to cross-incompatability. This is a server/AJAX issue that is not really fixable.
             #It doesn't affect function of the published map.
             tabPanel("Multivariate Map", icon=icon("bar-chart"),
                      tags$head(tags$style("#multivariateMap{height:90vh !important; width:100%}")),
                      tags$iframe(id="multivariateMap", src="https://jrpepper.github.io/DHIS-data-explorer/")
                      
             ),
             
             #About Panel
             tabPanel("About", icon = icon("question"),
                      
                      #content on left hand side of the page
                      column(8,
                             h1("About"),
                             br(),
                             p("Default is to display data from the past year. To change data range, click on the advanced options tab."),
                             br(),
                             p("Umami Brooklyn Wes Anderson High Life id, Neutra lumbersexual. Sriracha squid iPhone quinoa tote bag. Consequat street art cold-pressed, farm-to-table sed organic nihil. Beard pork belly letterpress mollit, ut High Life et odio viral Schlitz. Etsy fugiat Echo Park enim, crucifix fingerstache pariatur pickled YOLO gentrify voluptate. Carles typewriter veniam shabby chic keytar skateboard deserunt. Velit you probably haven't heard of them whatever incididunt pour-over."),
                             br(),
                             p("Salvia exercitation pickled single-origin coffee tilde. Street art keytar whatever synth narwhal. Wes Anderson bicycle rights bitters yr, authentic Bushwick est gentrify normcore taxidermy meh officia pickled. Tumblr aliqua messenger bag, irure listicle ad trust fund aliquip hella fixie. Bushwick hella shabby chic commodo sunt kitsch. Enim consequat blog master cleanse. Eu paleo bicycle rights Brooklyn, eiusmod readymade fixie irure dreamcatcher.")
                      ),
                      
                      #content on right hand side of the page, currently showing FPD logo.
                      column(4,
                             br(),br(),br(),img(class="img",
                                                src=paste0("http://www.aidsconsortium.org.za/Images/FPD%20LOGO%202008%20hi%20res.png"))
                      )
             )
  )
)