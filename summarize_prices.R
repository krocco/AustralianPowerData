library(dplyr)

library(data.table)
library(lubridate)
setwd('d:/Power')
fileList <- list.files(pattern="DATA*.*")
print(fileList)
locations = c("NSW","QLD","SA","SNOWY","VIC","TAS")
NSW <- fileList[grep("NSW", fileList)]
QLD <- fileList[grep("QLD", fileList)]
SA <- fileList[grep("SA", fileList)]
SNOWY <- fileList[grep("SNOWY", fileList)]
VIC <- fileList[grep("VIC", fileList)]
TAS <- fileList[grep("TAS", fileList)]

temporary <- lapply(NSW, fread, sep=",")
nsw <- data.table(rbindlist(temporary))
nsw[,SETTLEMENTDATE:=substr(SETTLEMENTDATE,1,10)]
nsw[,DATE:= ymd(SETTLEMENTDATE)]
nsw <- tbl_df(nsw)
nsw <- mutate(nsw, SPEND = TOTALDEMAND*RRP)
#nsw <- mutate(nsw, DAY = as.numeric(as.POSIXct(DATE)))
#nsw <- mutate(nsw, year = year(DATE), month = month(DATE), day = day(DATE))  #works
nsw_grouped <- group_by(nsw, DATE)
nsw_summary <- summarize(nsw_grouped, Price = (sum(SPEND)/sum(TOTALDEMAND)))