library(readr)
library(shiny)
library(dplyr)
library(rworldmap)


resi <- read_csv("tidy_residency.csv")

shinyServer(function(input, output) {
        resi2 <- reactive({
                resi %>% filter(year==input$year & type==input$type)
        })
        # Generate the Map 
        output$mPlot <- renderPlot({
                capture.output(
                    resiMap <- joinCountryData2Map(resi2(), 
                                                   nameJoinColumn="country", 
                                                   joinCode="NAME"),
                    file = "NULL"
                )
                mapParams <- mapPolys(resiMap, nameColumnToPlot="permits", mapRegion="world",
                                      missingCountryCol="dark grey",
                                      numCats=50, 
                                      catMethod="fixedWidth",
                                      addLegend=TRUE,
                                      oceanCol="light blue",
                                      mapTitle = "Recidency permits to Denmark")
        })
        output$tbl <- renderTable({
                # calculate sum
                total <- sum(resi2()$permits)
                # calculate percentages, and display table
                resi2() %>% select(country, permits) %>% arrange(desc(permits)) %>%
                        head(10) %>% mutate(pct=round(permits/total*100,2))
        })
})