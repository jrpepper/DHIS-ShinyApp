# code for custom maps

#list of map names, with codes for R
mapList <- list(
  "Antenatal Care" = c(`ANC early booking (number and rate)` = 'map1',
                       `ANC positivity (number and rate)` = 'map2',
                       `ANC re-test positive yield versus ANC re-test rate` = 'map3',
                       `ANC initiation on ART (number and rate)` = 'map4'),
  "Reproductive Health" = c(`Cervical cancer screening coverage (number and rate)` = 'map5',
                            `Female condom distribution (number and rate)` = 'map6',
                            `Male condom distribution (number and rate)` = 'map13',
                            `MMC performance` = 'map14'),
  "HIV" = c(`HIV+ client initiated on IPT (number and rate)` = 'map7',
            `HIV+ client screened for TB (number and rate)` = 'map8',
            `PLHIV yield versus HCT coverage` = 'map9',
            `Infant PCR positivity yield versus PCR positivity rate` = 'map10',
            `Infants initiated on ART` = 'map11',
            `Infant rapid HIV test yield versus 18 month uptake rate` = 'map12',
            `Adults remaining on ART compared to PHC headcount (>5)` = 'map15',
            `Adults started on ART compared to PHC headcount (>5)` = 'map16',
            `Children remaining on ART compared to PHC headcount (<5)` = 'map17',
            `Children started on ART compared to PHC headcount (<5)` = 'map18'),
  "TB" = c(`Xpert turnaround performance` = 'map22',
           `TB sputum turnaround performance` = 'map20'),
  "Other" = c(`Sexual assault prophylaxis uptake versus reported sexual assaults` = 'map19',
              `Tracer item stockout performance` = 'map21')
)

#create Lookup
mapListLookup <- c("map1","map2","map3","map4","map5","map6","map7","map8","map9","map10",
                   "map11","map12","map13","map14","map15","map16","map17","map18","map19","map20","map21","map22")
mapListLookup <- as.data.frame(mapListLookup)
names(mapListLookup) <- "mapCode"

#these lists 
mapListLookup$size <- c("Antenatal 1st visit total",
                        "Antenatal client HIV 1st test positive",
                        "Antenatal client HIV re-test positive",
                        "Antenatal client INITIATED on ART",
                        "Cervical cancer screening 30 years and older",
                        "Female condoms distributed",
                        "HIV positive client initiated on IPT",
                        "HIV positive client screened for TB",
                        "HIV test positive client 15-49 years (excl ANC)",
                        "Infant 1st PCR test positive around 6 weeks",
                        "Infant patient under 1 year started on ART - new",
                        "Infant rapid HIV test positive around 18 months",
                        "Male condoms distributed",
                        "Medical male circumcision performed",
                        "Adult remaining on ART at end of the month - total",
                        "Adult started on ART during this month - naive",
                        "Child under 15 years remaining on ART at end of the month - total",
                        "Child under 15 years started on ART during this month - naive",
                        "Sexual assault case new",
                        "TB AFB sputum sample sent",
                        "Any tracer item drug stock out (clinic/CHC/CDC)",
                        "Xpert sputum sample sent"
)

mapListLookup$color <- c("Antenatal 1st visit before 20 weeks rate",
                         "Antenatal client HIV 1st test positive rate",
                         "Antenatal client HIV re-test rate",
                         "Antenatal client initiated on ART rate",
                         "Cervical cancer screening coverage (annualised)",
                         "Female condom distribution coverage (annualised)",
                         "HIV positive new client initiated on IPT rate",
                         "HIV positive patients screened for TB rate",
                         "HIV testing coverage (annualised)",
                         "Infant 1st PCR test positive around 6 weeks rate",
                         "Infant 1st PCR test positive around 6 weeks",
                         "Infant rapid HIV test around 18 months uptake rate",
                         "Male condom distribution coverage (annualised)",
                         "Medical male circumcision performed",
                         "PHC headcount 5 years and older",
                         "PHC headcount 5 years and older",
                         "PHC headcount under 5 years",
                         "PHC headcount under 5 years",
                         "Sexual assault prophylaxis rate",
                         "TB AFB sputum result turn-around time under 48 hours rate",
                         "Tracer items stock-out rate (fixed clinic/CHC/CDC)",
                         "Xpert TB results turn-around time under 48 hours rate"
)

mapListLookup$pal <- c("RdYlGn",
                       "YlOrRd",
                       "RdYlGn",
                       "RdYlGn",
                       "RdYlGn",
                       "RdYlGn",
                       "RdYlGn",
                       "YlOrRd",
                       "RdYlGn",
                       "YlOrRd",
                       "YlOrRd",
                       "RdYlGn",
                       "RdYlGn",
                       "RdYlGn",
                       "Blues",
                       "Blues",
                       "Blues",
                       "Blues",
                       "RdYlGn",
                       "RdYlGn",
                       "RdYlGn",
                       "RdYlGn"
)

#get list of hospitals
typeList <- read.csv("./data/typeList.csv") #lists of all types of clinics
typeListUnique <- as.vector(unique(typeList$OUType))

hospitals <- typeListUnique[grep("Hospital",typeListUnique)]
practitioners <- typeListUnique[grep("Practitioner",typeListUnique)]
pharmacies <- typeListUnique[grep("Pharmacy",typeListUnique)]

mapListLookup$hide <- list(
  c(hospitals,practitioners,pharmacies),
  NULL,
  hospitals,
  practitioners,
  hospitals,
  c(hospitals,practitioners,pharmacies),
  NULL,
  NULL,
  c(hospitals,practitioners,pharmacies),
  NULL,
  NULL,
  NULL,
  c(hospitals,practitioners,pharmacies),
  NULL,
  c(pharmacies,practitioners),
  c(pharmacies,practitioners),
  c(pharmacies,practitioners),
  c(pharmacies,practitioners),
  NULL,
  c(pharmacies,practitioners),
  NULL,
  NULL
)