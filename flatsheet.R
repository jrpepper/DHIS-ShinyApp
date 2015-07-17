###Load DHIS Data
library(reshape2)

#load location data
locations <- read.csv("./data/DHIS_2015_Data.csv") #clinic locations and other information about clinics
locations <- subset(locations, select =c(OrgUnit5,Latitude,Longitude)) #get subet of location data
names(locations) <- c("OrgUnit05","lat","long")

#####INDICATORS
#load Indicator data
listIndicators <- c("Antenatal 1st visit before 20 weeks rate",
                    "Antenatal client HIV 1st test positive rate",
                    "Antenatal client HIV re-test rate",
                    "Antenatal client initiated on ART rate",
                    "Cervical cancer screening coverage (annualised)",
                    "Female condom distribution coverage (annualised)",
                    "HIV positive new client initiated on IPT rate",
                    "HIV positive patients screened for TB rate",
                    "HIV testing coverage (annualised)",
                    "Infant 1st PCR test positive around 6 weeks rate",
                    "Infant initiated on CPT around 6 weeks uptake rate",
                    "Infant rapid HIV test around 18 months uptake rate",
                    "Male condom distribution coverage (annualised)",
                    "Sexual assault prophylaxis rate",
                    "TB AFB sputum result turn-around time under 48 hours rate",
                    "Tracer items stock-out rate (fixed clinic/CHC/CDC)",
                    "Xpert TB results turn-around time under 48 hours rate")

indicatorRaw <- read.csv("./data/indicators.csv") #load Indicators
indicatorRaw <- indicatorRaw[,c("OrgUnit05","IndicatorName","yPeriod","mPeriod","NumxFactor","DenominatorValue")] #trim fields from flatsheet
indicatorRaw <- subset(indicatorRaw, indicatorRaw$IndicatorName %in% listIndicators) #cut out indicators we are not interested in


###DATA ELEMENTS
listDataElements <- c("Antenatal 1st visit total",
                      "Antenatal client HIV 1st test positive",
                      "Antenatal client HIV re-test positive",
                      "Antenatal client INITIATED on ART",
                      "Cervical cancer screening 30 years and older",
                      "Female condoms distributed",
                      "HIV test positive client 15-49 years (excl ANC)",
                      "Infant 1st PCR test positive around 6 weeks",
                      "Infant initiated on CPT around 6 weeks",
                      "Infant rapid HIV test positive around 18 months",
                      "Male condoms distributed",
                      "Infant patient under 1 year started on ART - new",
                      "Medical male circumcision performed",
                      "Sexual assault case new",
                      "TB AFB sputum sample sent",
                      "Adult remaining on ART at end of the month - total",
                      "Adult started on ART during this month - naive",
                      "Child under 15 years remaining on ART at end of the month - total",
                      "Child under 15 years started on ART during this month - naive",
                      "HIV positive client initiated on IPT",
                      "HIV positive client screened for TB",
                      "Xpert sputum sample sent",
                      "PHC headcount 5 years and older",
                      "PHC headcount under 5 years",
                      "Any tracer item drug stock out (clinic/CHC/CDC)")#list of the data elements we are interested in keeping

dataElementsRaw <- read.csv("./data/dataElements.csv") #load data elements
dataElementsRaw$DataElementName <- gsub("\x95", "i", dataElementsRaw$DataElementName) #remove umlats over the letter i (in the word "naive")
dataElementsRaw <- dataElementsRaw[,c("OrgUnit05","DataElementName","yPeriod","mPeriod","EntryNumber")] #trim columns from dataElements
dataElementsRaw <- subset(dataElementsRaw, dataElementsRaw$DataElementName %in% listDataElements) #cut out dataElements we are not interested in


dataElement.m <- melt(dataElementsRaw, na.rm=TRUE, id=c("DataElementName","OrgUnit05","yPeriod","mPeriod"))
dataElementTable <- dcast(dataElement.m, OrgUnit05 ~ DataElementName, sum) #sum across all months and years 

###Lists
fullList <- c(listIndicators,listDataElements) #full list of all Indicators and Elements
typeList <- read.csv("./data/typeList.csv") #lists of all types of clinics

####sumData
sumData <- function(startDate, endDate) {
  
  #filter dataElementRaw based on dates
  dataElementFiltered <- filterByDate(dataElementsRaw, startDate, endDate)
  
  #create dataElementTable by melting and casting into table with one column for each Data Element
  dataElement.m <- melt(dataElementFiltered, na.rm=TRUE, id=c("DataElementName","OrgUnit05","yPeriod","mPeriod"))
  dataElementTable <- dcast(dataElement.m, OrgUnit05 ~ DataElementName, sum) #sum across all months and years
  
  #find max of for non-aggregating fields, adult/children REMAINING on ART at end of month
  remainingOnARTTable <- dcast(dataElement.m, OrgUnit05 ~ DataElementName, max) #max across all months and years
  #substituting max values for these field into the datElementTable
  dataElementTable$`Adult remaining on ART at end of the month - total`<- remainingOnARTTable$`Adult remaining on ART at end of the month - total`
  dataElementTable$`Child under 15 years remaining on ART at end of the month - total`<- remainingOnARTTable$`Child under 15 years remaining on ART at end of the month - total`
  
  
  #filter indicatorRaw based on dates
  indicatorFiltered <- filterByDate(indicatorRaw, startDate, endDate)
  
  #create indicatorTable
  indicatorTable <- calculateIndicatorValues(indicatorFiltered) #create indicator Table from filtered data.
  
  #merge the two tables
  mergedTables <- merge(indicatorTable, dataElementTable, all.x=TRUE, all.y=TRUE)
  
  #merge locations into table
  mergedTables <- merge(mergedTables,locations, by="OrgUnit05", all.x=TRUE)
  
  #remove preceding "gp" from clinic names
  mergedTables$OrgUnit05 <- gsub("gp ", "", mergedTables$OrgUnit05)
  row.names(mergedTables) <- mergedTables$OrgUnit05
  
  #remove "Rethabiseng Clinic" from the dataset
  mergedTables <- mergedTables[mergedTables$OrgUnit05!="Rethabiseng Clinic",]
  
  #remove values with no Geospatial data
  mergedTables <- subset(mergedTables, !is.na(mergedTables$lat))
  
  #add clinic type
  typeList <- read.csv("./data/typeList.csv")
  mergedTables <- merge(mergedTables, typeList, all.x=TRUE)
  
  #cleaning data, removing NA
  mergedTables[is.na(mergedTables)] <- 0
  
  #for non-aggregating fields, take averages for number of months
  numMonths <- round(as.numeric((endDate - startDate)/30),0)
  mergedTables[,"Adult remaining on ART at end of the month - total"] <- mergedTables[,"Adult remaining on ART at end of the month - total"]/numMonths
  mergedTables[,"Child under 15 years remaining on ART at end of the month - total"] <- mergedTables[,"Child under 15 years remaining on ART at end of the month - total"]/numMonths
  
  return(mergedTables)
}