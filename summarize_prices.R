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
        mutate(year = year(date), 
               month = month(date),
               week = week(date),
               day = day(date)) %>%
        mutate(week = paste(as.character(year),as.character(week),sep="-"),
               month = paste(as.character(year),as.character(month),sep="-"))

regional <- 
        allData %>%
        group_by(date, REGION) %>%
        summarize(price = (sum(spend)/sum(TOTALDEMAND)))


national <-
        allData %>%
        group_by(date) %>%
        summarize(price = (sum(spend)/sum(TOTALDEMAND)))

national_monthly <-
        allData %>%
        group_by(month) %>%
        summarize(price = (sum(spend)/sum(TOTALDEMAND)))

national_weekly <-
        allData %>%
        group_by(week) %>%
        summarize(price = sum(spend)/sum(TOTALDEMAND))

write.csv(regional, file = "regionalSummary.csv", row.names = FALSE)
write.csv(national, file = "nationalSummary.csv", row.names = FALSE)
write.csv(national_monthly, file = "nat_monthlySummary.csv", row.names = FALSE)
write.csv(national_weekly, file = "nat_weeklySummary.csv", row.names = FALSE)

qplot(week, price, data=national_weekly, geom="point", ylim = c(0,100))

ggsave("weekly_zoomed.png", width = 6, height = 4, dpi=200)