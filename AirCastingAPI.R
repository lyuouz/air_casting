
#####
## By Chris C. Lim
## API Aircasting: Real-Time PM2.5
#####

library(httr)
library(jsonlite)
library(rjson)
library(data.table)

real <- c("http://aircasting.org/api/realtime/sessions.json?page=0&page_size=500&q[measurements]=true&q[time_from]=0&q[time_to]=2552648500&q[usernames]=NYCEJA")

tt <- jsonlite::fromJSON(real)
t <- tt$streams$'AirBeam2-PM2.5'
t <- data.table(t)
ID <- t[!is.na(t$id)]$id

name <- data.frame(tt$title,t$id)
name <- name[!is.na(name$t.id),]
colnames(name) <- c("title", "id")

dt <- list()
for (i in 1:length(ID)) {
  sess <- paste0("http://aircasting.org/api/realtime/stream_measurements.json/?end_date=2281550369000&start_date=0&stream_ids[]=",ID[i])
  s1 <- jsonlite::fromJSON(sess)
  s1 <- data.table(s1)
  s1$ID <- ID[i]
  dt[[i]] <- data.table(s1)
}

library(plyr)
df <- ldply(dt, data.frame)
