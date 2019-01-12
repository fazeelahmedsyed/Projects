#Loading dependencies
library(RCurl)
library(rvest)

#Setting a few options for smooth Curl Operations
options(HTTPUserAgent = "Mozilla/5.0 (Linux; U; Android 2.2.1; en-us; ADR6400L 4G Build/FRG83D)")
cert <- system.file("CurlSSL", "cacert.pem", package = "RCurl")

#Collecting Data on motorcycles
df = data.frame()
for (i in 2:90){
  
  address <- paste("https://www.olx.com.pk/motorcycles/?page=",i, sep = "")
  
  rawdata <- getURL(address,cainfo = cert)
  
  gob <- read_html(rawdata)
  product <- html_nodes(gob, xpath = "//h3/a/span") %>% html_text()
  value <- html_nodes(gob, "strong") %>% html_text()
  
  #Data cleaning in the loop structure
  value <- gsub("\t", "", value)
  value <- gsub("\n", "", value)
  value <- value[grep("Rs", value)]
  value <- gsub("Rs ", "", value)
  value <- gsub(",","", value)
  value <- as.numeric(value)
  
  combined <- data.frame(product,value)
  df <- rbind(df,combined)
  Sys.sleep(5) #Good practice when scraping
}

write.csv(df, 'motorcycles.csv', row.names = F)

#Colecting data on cars (didnt use it at the end)
df2 = data.frame()
for (i in 2:90){
  
  address <- paste("https://www.olx.com.pk/cars/?page=",i, sep = "")
  
  rawdata <- getURL(address,cainfo = cert)
  
  gob <- read_html(rawdata)
  product <- html_nodes(gob, xpath = "//h3/a/span") %>% html_text()
  value <- html_nodes(gob, "strong") %>% html_text()
  value <- gsub("\t", "", value)
  value <- gsub("\n", "", value)
  value <- value[grep("Rs", value)]
  value <- gsub("Rs ", "", value)
  value <- gsub(",","", value)
  value <- as.numeric(value)
  
  combined <- data.frame(product,value)
  df2 <- rbind(df2,combined)
  Sys.sleep(5)
}

write.csv(df2, 'cars.csv', row.names = F)