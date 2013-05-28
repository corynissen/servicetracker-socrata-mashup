
# need to load on RJSONIO

#st.number <- "13-00398797" # native foods
#st.number <- "13-00487042" # lou malnatis
#st.number <- "13-00438108" # subway
#st.number <- "13-00425144" # nori sushi
#st.number <- "13-00421366" # arami go can't find manually on socrata
#st.number <- "13-00405201" # butterfly sushi can't find manually on socrata

run <- function(st.number, json=TRUE){
  st_url <- paste0("http://311api.cityofchicago.org/open311/v2/requests/",
                   st.number, ".json")
  st <- tryCatch(fromJSON(st_url)[[1]], error=function(e)e)
  if(inherits(st, "error")){
      msg <- list(error="service tracker number not found")
  }else{
    req.date <- as.Date(substring(st$requested_datetime, 1, 10))
    end.date <- req.date + 25
    soc_url <- paste0("http://data.cityofchicago.org/resource/4ijn-s7e5.csv?$where=inspection_date%20>=%20'",
                      req.date, "T00:00:00'%20and%20inspection_date%20<=%20'", end.date,
                      "T23:59:59'&$order=inspection_date")
    soc <- tryCatch(read.csv(soc_url, stringsAsFactors=F), error=function(e)e)
    if(inherits(soc, "error")){
      msg <- st
    }else{
      names(soc) <- tolower(names(soc))

      # try to get the closest one by lat, lon
      soc$latdiff <- abs(soc$latitude - st$lat)
      soc$londiff <- abs(soc$longitude - st$long)
      soc$totaldiff <- soc$latdiff + soc$londiff
      totalmin <- which.min(soc$totaldiff)

      # match if lat and lon within some delta & address numbers the same
      if(soc$totaldiff[totalmin] < .001){
        candidate <- soc[totalmin,]
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
        msg <- st
        msg$inspection.id <- candidate$inspection.id
        msg$dba.name <- candidate$dba.name
        msg$aka.name <- candidate$aka.name
        msg$license <- candidate$license..
        msg$facility.type <- candidate$facility.type
        msg$risk <- candidate$risk
        msg$inspection.date <- candidate$inspection.date
        msg$inspection.type <- candidate$inspection.type
        msg$results <- candidate$results
        msg$violations <- candidate$violations
      }else{
        msg <- st
      }
    }
  }
  if(tolower(json) %in% c(TRUE, "true", "t")){
    msg <- toJSON(msg)
  }else{
    # add line breaks to make more readable
    msg$violations <- gsub("|", "\n", msg$violations)
    msg <- otable(as.data.frame(cbind(names(msg),msg)))
  }
  as.WebResult(msg, cmd="raw")
}

