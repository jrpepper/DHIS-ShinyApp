calculateIndicatorValues <- function(indicators) {
  #clean up indicators data, removing NaN
  indicators[is.nan(indicators$NumxFactor),"NumxFactor"] <- 0
  indicators[is.nan(indicators$DenominatorValue),"DenominatorValue"] <- 0
  
  #melt and recast indicators data, returning a table with all clinics and summarized Values.
  indicators.m <- melt(indicators, id=c("OrgUnit05","yPeriod","mPeriod","IndicatorName"))
  indicators.m[is.na(indicators.m$value),"value"] <- 0
  indicators.c <- dcast(indicators.m, OrgUnit05 + IndicatorName ~ variable, sum)
  indicators.c$Value <- indicators.c$NumxFactor / indicators.c$DenominatorValue  #calculate indicator percentages
  indicators.c <- indicators.c[,c("OrgUnit05","IndicatorName","Value")]
  
  #cleaning data, removing NaN, NA and Inf
  indicators.c[is.na(indicators.c$Value),"Value"] <- 0
  indicators.c[is.nan(indicators.c$Value),"Value"] <- 0
  indicators.c[is.infinite(indicators.c$Value),"Value"] <- 0
  
  #casting into table with clinic name as first column and one column for each indicator
  indicators.m2 <- melt(indicators.c, id=c("OrgUnit05","IndicatorName"))
  indicators.c2 <- dcast(indicators.m2, OrgUnit05 ~ IndicatorName, sum)

  return(indicators.c2)
}