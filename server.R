library(readr)
library(shiny)
library(dplyr)
library(rworldmap)

# reading tidy version of residency permits2.csv from statistikbanken.dk statistic VAN66
resi <- read_csv("tidy_residency.csv")

shinyServer(function(input, output) {
        resi2 <- reactive({
                resi %>% filter(year==input$year & type==input$type)
        })
        # Generate the rworldmap
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
        # display table with top10
        output$tbl <- renderTable({
                # calculate sum of permits for year and type
                total <- sum(resi2()$permits)
                # calculate percentages and get top10
                resi2() %>% select(country, permits) %>% arrange(desc(permits)) %>%
                        head(10) %>% mutate(pct=round(permits/total*100,2))
        })
})