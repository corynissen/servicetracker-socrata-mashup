

#st.number <- "13-00398797" # native foods
#st.number <- "13-00487042" # lou malnatis
#st.number <- "13-00438108" # subway
#st.number <- "13-00425144" # nori sushi
#st.number <- "13-00421366" # arami go can't find manually on socrata
#st.number <- "13-00405201" # butterfly sushi can't find manually on socrata

run <- function(st.number){
  st_url <- paste0("http://311api.cityofchicago.org/open311/v2/requests/",
                   st.number, ".json")
  st <- fromJSON(st_url)[[1]]

  # because the socrata api is fucking awful, let's just loop through and request a couple
  # weeks of data one date at a time...
  req.date <- as.Date(substring(st$requested_datetime, 1, 10))
  dates <- req.date + seq(0:14)
  soc <- NULL
  for(date in as.character(dates)){
      soc_url <- paste0("http://data.cityofchicago.org/resource/4ijn-s7e5.csv?Inspection%20Date=", date, "T00:00:00")
      soc <- rbind(soc, read.csv(soc_url, stringsAsFactors=F))
  }
  names(soc) <- tolower(names(soc))

  # try to get the closest one by lat, lon
  soc$latdiff <- abs(soc$latitude - st$lat)
  soc$londiff <- abs(soc$longitude - st$long)
  latmin <- which.min(soc$latdiff)
  lonmin <- which.min(soc$londiff)

 # match if lat and lon within some delta & address numbers the same
  if(soc$latdiff[latmin] < .001 & soc$londiff[lonmin] < .001){
    candidate <- soc[latmin,]
  }

  # must match numeric part of address to be legit
  # take only the number portion of the substring from the beginning of the
  # address to the first space. This should be the house number
  st.num <- gsub("[^0-9]", "", substring(st$address, 1, regexpr(" ", st$address)))
  cand.num <-gsub("[^0-9]", "", substring(candidate$address, 1, regexpr(" ", candidate$address)))
  # cand.num not always just one number, do a grep instead of ==
  # cand.num not always right, take it if it's within +/- 10
  within.10 <- as.numeric(st.num) > as.numeric(cand.num) -10 &
               as.numeric(st.num) < as.numeric(cand.num) + 10
  if(grepl(st.num, cand.num) | within.10){
    # we have a match
    # add in stuff to the service tracker json (st) that we can get from the
    # data portal
    new <- st
    new$inspection.id <- candidate$inspection.id
    new$dba.name <- candidate$dba.name
    new$aka.name <- candidate$aka.name
    new$license <- candidate$license..
    new$facility.type <- candidate$facility.type
    new$risk <- candidate$risk
    new$inspection.date <- candidate$inspection.date
    new$inspection.type <- candidate$inspection.type
    new$results <- candidate$results
    new$violations <- candidate$violations
  }else{
    new <- st
  }
  return(new)
}
