###This is the code I use to pull and process the .json data into a useful R format

### Sign up for a census API key: https://api.census.gov/data/key_signup.html
NY_pull <- "http://api.census.gov/data/2010/sf1?get=P0030001,P0130001,P0050003,P0050004,P0050006,P0040003&for=county:*&in=state:36&key=**INSERT API KEY HERE**"

#install.packages("RJSONIO")
require(RJSONIO)
NY_cendata <- fromJSON(NY_pull)


View(NY_cendata)
NY_cendata <-NY_cendata[2:length(NY_cendata)]

NY_cendata.tot <- sapply(NY_cendata,function(x) x[1]) 
NY_cendata.medage <- sapply(NY_cendata,function(x) x[2])
NY_cendata.whi <- sapply(NY_cendata,function(x) x[3])
NY_cendata.blk <- sapply(NY_cendata,function(x) x[4])
NY_cendata.asn <- sapply(NY_cendata,function(x) x[5])
NY_cendata.hsp <- sapply(NY_cendata,function(x) x[6])
NY_cendata.st <- sapply(NY_cendata,function(x) x[7])
NY_cendata.cty <- sapply(NY_cendata,function(x) x[8]) 
NY_df <- data.frame(NY_cendata.st, NY_cendata.cty, as.numeric(NY_cendata.tot),as.numeric(NY_cendata.medage),as.numeric(NY_cendata.whi),
                    as.numeric(NY_cendata.blk),as.numeric(NY_cendata.asn),as.numeric(NY_cendata.hsp)) 
names(NY_df) <- c("state","county","tpop","medage","wpop","bpop","apop","hpop") 
View(NY_df)



###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################
###This is code I used to pull data from google maps for the mid-atlantic region of the country.
require(jsonlite)
require(plyr)
require(dplyr)
require(data.table)

# top_left <- c( -88.056869, 31.154966)
# bottom_right <- c(-79.845006, 24.458610)



mdp_1 <- c(40.910, -77.867)
mdp_2 <- c(37.894, -74.531)

mdp_points <- as.data.frame(merge( seq(floor(mdp_1[2] * 1000 - 30) / 1000, ceiling(mdp_2[2] * 1000 + 30) / 1000, 0.1), 
                                   seq(floor(mdp_2[1] * 1000 - 30) / 1000, ceiling(mdp_1[1] * 1000 + 30) / 1000, 0.1)))

plot(mdp_points)



pull_places <- function(type, keyword, x_var, y_var) {
  all_data <- data.frame()
  for (i in 1:length(x_var)) {
    
    data_pulled <- fromJSON(paste0("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=",
                                   y_var[i], ",", x_var[i], "&key=", "INSRERT API KEY HERE",
                                   "&radius=50000&type=", type, "&keyword=", keyword
    ), flatten = T)
    if (length(data_pulled$results) != 0) {
      all_data <- rbind.fill(all_data, data_pulled$results)
    }
    # nrow(all_data)
    print(i)
  }
  
  all_data <- all_data[ ,!(sapply(all_data, is.list))]
  return(all_data)
}



mdp_police_departments <- pull_places("police", "", mdp_points$x, mdp_points$y )
table(mdp_police_departments$name)
mdp_police_departments2 <-  subset(mdp_police_departments, grepl(paste(c("Sheriff", "Police", "Federal Bureau"), collapse = "|"), name))
mdp_police_departments2 <- mdp_police_departments2[!duplicated(mdp_police_departments2$place_id), ]
head(mdp_police_departments2)
View(mdp_police_departments2)

mdp_fire_stations <- pull_places("fire_station", "", mdp_points$x, mdp_points$y )
table(mdp_fire_stations$name)
mdp_fire_stations2 <- subset(mdp_fire_stations, grepl(paste(c("Fire"), collapse = "|"), name))
mdp_fire_stations2 <- mdp_fire_stations2[!duplicated(mdp_fire_stations2$place_id), ]

mdp_hospital <- pull_places("hospital", "", mdp_points$x, mdp_points$y )
table(mdp_hospital$name)
mdp_hospital2 <- subset(mdp_hospital, grepl(paste(c("doctor"), collapse = "|"), icon) | grepl(paste(c("urgent"), collapse = "|"), name))
mdp_hospital2 <- mdp_hospital2[!duplicated(mdp_hospital2$place_id), ]

mdp_museums <- pull_places("museum", "", mdp_points$x, mdp_points$y)
mdp_museums2 <-  subset(mdp_museums, grepl(paste(c("Museum", "Library", "Heritage", "Historical", "Gallery"), collapse = "|"), name))
mdp_muesums2 <- mdp_museums2[!duplicated(mdp_museums2$place_id), ]

mdp_schools <- pull_places("school", "", mdp_points$x, mdp_points$y )
mdp_schools2 <-  subset(mdp_schools, !grepl(paste(c("Sheriff", "Police", "Federal Bureau"), collapse = "|"), name))
mdp_schools2 <- mdp_schools2[!duplicated(mdp_schools2$place_id), ]

mdp_academys <- pull_places("academy", "", mdp_points$x, mdp_points$y )
mdp_academys2 <-  subset(mdp_academys, !grepl(paste(c("Sheriff", "Police", "Federal Bureau"), collapse = "|"), name))
mdp_academys2 <- mdp_academys2[!duplicated(mdp_academys2$place_id), ]
table(mdp_academys2$name)

all_mdp_google <- rbind.fill(mdp_academys2, mdp_hospital2, mdp_museums2, mdp_police_departments2)
getwd()
fwrite(all_mdp_google,"D:/R-D/Projects/2018/Google Place Download/Working/all_mdp_google.csv")