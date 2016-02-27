library(readr)
library(tidyr)
library(dplyr)
library(rworldmap)

# from www.statistikbanken.dk - VAN66:residence_permits (year 2006-2015) by citizenship 
# downloaded as matrix-csv
residency <- read_csv2("residency permits2.csv", col_names = FALSE)
str(residency)
# fix the colnames
colnames(residency) <- c("type", "country", "y2006", "y2007", "y2008", "y2009", "y2010",
                         "y2011", "y2012", "y2013", "y2014", "y2015")
# group the residency types to fewer types
levels(as.factor(residency$type))
residency$type[grep("^Asylum", residency$type)] <- "Asylum"
residency$type[grep("^EU", residency$type)] <- "EU"
residency$type[grep("^Family", residency$type)] <- "Family"
residency$type[grep("^Other", residency$type)] <- "Other"
residency$type[grep("^Study", residency$type)] <- "Study"
residency$type <- as.factor(residency$type)

#gather and clean the data
residency2 <- residency %>%
        gather(year, n, y2006:y2015) %>% 
        mutate(year = as.integer(gsub("y", "", year))) %>% 
        group_by(country, type, year) %>%
        summarize(permits=sum(n))

# find the countries that are mismatch between statistikbanken and rworldmap
countries <- unique(residency2$country)
# getMap()$NAME has the country names that rworldmap uses
countries.error <- countries[!(countries %in% getMap()$NAME)]


# fix the ones with data
countries.tofix <- residency2 %>%  group_by(country) %>% summarise(sum=sum(permits)) %>%
    filter(country %in% countries.error & sum > 0) %>% arrange(desc(sum)) %>% 
    select(country, sum)

# 26 needs fixing, only the ones with significant amout of permits gets fixed
# also one of the biggest groups Stateless is hard to point, most of these are usualy palestines
# residency2$country[grep("^Bosnia and Herzegovina", residency2$country)] <- "Bosnia and Herz."
residency2$country[grep("^Central African Republic", residency2$country)] <- "Central African Rep."
residency2$country[grep("^Congo, Democratic", residency2$country)] <- "Congo (Kinshasa)"
residency2$country[grep("^Congo, Republic", residency2$country)] <- "Congo (Brazzaville)"
#residency2$country[grep("^Czech", residency2$country)] <- "Czech Rep."
residency2$country[grep("^Domican Republic", residency2$country)] <- "Domican Rep."
residency2$country[grep("^Gambia, The", residency2$country)] <- "Gambia"
residency2$country[grep("^Guinea-Bissau", residency2$country)] <- "Guinea Bissau"
# residency2$country[grep("^North Korea", residency2$country)] <- "N. Korea"
# sorry Montenegro
residency2$country[grep("^Serbia and Montenegro", residency2$country)] <- "Serbia"
# residency2$country[grep("^South Korea", residency2$country)] <- "S. Korea"
residency2$country[grep("^USA", residency2$country)] <- "United States"
# there seems to be a further step in rworldmap in handling country names. so for example it
# can handle both United States and USA as the same.
# there is also trouble mapping north and south korea
# with some trial and error some fixings are done, other commentated

write_csv(residency2, "tidy_residency.csv")