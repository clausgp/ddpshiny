library(shiny)

shinyUI(fluidPage(
        headerPanel("Immigration to Denmark"),
        fluidRow(
                column(width=12,
                       p("Residency permits to Denmark shown as choropleth in rworldmap.
                         Select year and type of permit to examine."),
                       p("The choropleth will color the map, so the countries with the most
                         permits will be red and the ones with very few or 0 white."),
                       p("Link to the code can be found in the presentation ",
                        a("here",href="http://clausgp.github.io/ddpslidify")))
        ),
        fluidRow(
                column(width=12,
                       #plotOutput("mPlot"))
                        plotOutput("mPlot", height="520px", width="820px"))
        ),
        fluidRow(
                column(width=4,
                       selectInput(inputId="year",
                                   label="Select year",
                                   choices=c(2015,2014,2013,2012,2011,2010,2009,2008,2007,2006),
                                   selected=2015
                       ),
                       selectInput(inputId="type",
                                   label="Select type of residence",
                                   choices=c("Asylum", "EU", "Family", "Study", "Work", "Other"),
                                   selected="Work"
                       )
                ),
                column(width=8,
                       p("Countries with the most permits of the chosen type and year"),
                       tableOutput("tbl")
                )
        )
)
)
