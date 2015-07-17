noSpaceData <- all_data
names(noSpaceData) <- gsub(" ", "", names(noSpaceData))
names(noSpaceData) <- gsub(")", "", names(noSpaceData))
names(noSpaceData) <- gsub("(", "", names(noSpaceData), fixed=TRUE)
names(noSpaceData) <- gsub("-", "", names(noSpaceData))
names(noSpaceData) <- gsub("/", "", names(noSpaceData))

x <-names(noSpaceData)[13]
y <- names(noSpaceData)[10]


fun <- as.formula(paste(x," ~ ",y, sep=""))

p <- rPlot(fun, data=noSpaceData, type="point")
#p$xAxis(axisLabel = 'Weight')
#p$chart(size = '#! function(d){return d.phc_headcount_under_5_years} !#')
p$addControls("y", value = y, values = names(noSpaceData))
p$addControls("x", value = x, values = names(noSpaceData))
p$addControls("size", value = "", values = names(noSpaceData))
p$addControls("color", value = "", values = names(noSpaceData))

return(p)
