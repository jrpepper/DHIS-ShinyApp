#filterByDate function. Input data, start date and end date. Returns filtered Data.
filterByDate <- function(data,startDate,endDate){
  data$monthYear <- paste("1",data$mPeriod,data$yPeriod, sep="") #add monthYear data
  data$monthYear <- as.Date(data$monthYear, "%d%b%Y")
  filteredData <- subset(data, (data$monthYear>=as.Date(startDate) & (data$monthYear<=as.Date(endDate))))
  data <- filteredData[,-length(names(filteredData))]
  return(data)
}