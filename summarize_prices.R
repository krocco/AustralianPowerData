library(dplyr)

library(data.table)
library(lubridate)

fileList <- list.files(pattern="DATA*.*")

ALL <- lapply(fileList, fread, sep=",")
everything <- data.table(rbindlist(ALL))
rm("ALL")

everything[,SETTLEMENTDATE := substr(SETTLEMENTDATE,1,10)]
everything[,date := ymd(SETTLEMENTDATE)]
everything <- tbl_df(everything)
allData <- 
        everything %>%
        mutate(spend = TOTALDEMAND * RRP) %>%
        mutate(day = as.POSIXct(date)) %>%
        mutate(year = year(date), month = month(date), day = day(date), week = week(date))


regional <- 
        allData %>%
        group_by(date, REGION) %>%
        summarize(price = (sum(spend)/sum(TOTALDEMAND)))


national <-
        allData %>%
        group_by(date) %>%
        summarize(price = (sum(spend)/sum(TOTALDEMAND)))

write.csv(regional, file = "regionalSummary.csv", row.names = FALSE)
write.csv(national, file = "nationalSummary.csv", row.names = FALSE)