#This script is for extracting Pakistan election data

library(RCurl)
library(rvest)

options(HTTPUserAgent = "Mozilla/5.0 (Linux; U; Android 2.2.1; en-us; ADR6400L 4G Build/FRG83D)")
cert <- system.file("CurlSSL", "cacert.pem", package = "RCurl")

results <- data.frame(Name = character(0), Party = character(0), Votes= numeric(0), Seat = numeric(0), City = character(0), Year = numeric(0))

for(year in c(1988,1990)){
        for (seat in 1:207){

                link <- paste("http://www.electionpakistani.com/ge", year, "/NA-", seat, ".htm", sep ="")
                rawdata <- getURL(link, cainfo = cert)
                
                gob <- read_html(rawdata)
                
                city <- html_nodes(gob, xpath = "//h3/font/text()")
                city <- gsub(".*NA-\\d{1,3} ","", city)
                city <- gsub(" G.E.*","",city)
                city <- gsub(" Election.*","",city)
                city <- gsub(" General.*","", city)
                
                #table <- html_nodes(gob, xpath = "//h3/following-sibling::table")
                table <- html_nodes(gob, xpath = "//table[@id = 'AutoNumber1']")
                table <- html_table(table) %>% .[[1]] %>% .[-1,]
                table[,1] <- gsub(" \n","", table[,1])
                table[,1] <- gsub("\t","", table[,1])
                table[,1] <- gsub("\\h{2,10}", "", table[,1], perl = T)
                table <- cbind(table, rep(seat, nrow(table)), rep(city,nrow(table)), rep(year,nrow(table)))
                
                results <- rbind(results, table)
                Sys.sleep(3)
        }
}

colnames(results) <- c("Name", "Party", "Votes", "Seat","City","Year")

#write.csv(results, file = "Results1988.csv", row.names = F)
#write.csv(results,file = "Results1990.csv", row.names = F)

for(year in c(2002,2008)){
        for (seat in 1:272){
                
                link <- paste("http://www.electionpakistani.com/ge", year, "/NA-", seat, ".htm", sep ="")
                rawdata <- getURL(link, cainfo = cert)
                
                gob <- read_html(rawdata)
                
                city <- html_nodes(gob, xpath = "//h3/font/text()")
                city <- gsub(".*NA-\\d{1,3} ","", city)
                city <- gsub(" G.E.*","",city)
                city <- gsub(" Election.*","",city)
                city <- gsub(" General.*","", city)
                city <- gsub("^ ","", city)
                
                #table <- html_nodes(gob, xpath = "//h3/following-sibling::table")
                table <- html_nodes(gob, xpath = "//table[@id = 'AutoNumber1']")
                table <- html_table(table) %>% .[[1]] %>% .[-1,]
                #for seat = 123 year = 2008
                #table <- table[,-3]
                #colnames(table)[3] <- "X3" 
                table[,1] <- gsub(".\n","", table[,1])
                table[,1] <- gsub("\t","", table[,1])
                table[,1] <- gsub("\r","", table[,1])
                table[,1] <- gsub("\\h{2,10}$", "", table[,1], perl = T)
                table[,1] <- gsub("\\h{2,10}", "\\h", table[,1], perl = T)
                table <- cbind(table, rep(seat, nrow(table)), rep(city,nrow(table)), rep(year,nrow(table)))
                
                results <- rbind(results, table)
                Sys.sleep(3)
        }
}

colnames(results) <- c("Name", "Party", "Votes", "Seat","City","Year")

#write.csv(results, file = "Results2002.csv", row.names = F)
#write.csv(results, file = "Results2008.csv", row.names = F)

year <- 2013

for (seat in 142:272){
        
        link <- paste("http://www.electionpakistani.com/ge", year, "/NA-", seat, ".htm", sep ="")
        rawdata <- getURL(link, cainfo = cert)
        
        gob <- read_html(rawdata)
        
        city <- html_nodes(gob, xpath = "//h3/font/text()")
        city <- as.character(city)
        city <- paste(city, collapse = "")
        city <- gsub(".*NA\\d{1,3} ","", city)
        city <- gsub(".*NA-\\d{1,3} ","", city)
        city <- gsub(" G.E.*","",city)
        city <- gsub(" Election","",city)
        city <- gsub(" General.*","", city)
        city <- gsub(" \\d{4}$","",city)
        city <- gsub("^ ","", city)
        
        table <- html_nodes(gob, xpath = "//h3/following-sibling::table")
        #for seat 38 >>>> table <- html_nodes(gob, xpath = "//table[@id = 'AutoNumber1']")
        #for seat 141 >>>> table <- html_nodes(gob, xpath = "//h2/following-sibling::table")
        #for seat 141>>>>>table <- html_table((table[2])) %>% .[[1]] %>% .[-1,]
        table <- html_table((table)) %>% .[[1]] %>% .[-1,]
        table[,1] <- gsub(".\n","", table[,1])
        table[,1] <- gsub("\t","", table[,1])
        table[,1] <- gsub("\r","", table[,1])
        table[,1] <- gsub("\\h{2,10}$", "", table[,1], perl = T)
        table[,1] <- gsub("\\h{2,10}", "\\h", table[,1], perl = T)
        table <- cbind(table, rep(seat, nrow(table)), rep(city,nrow(table)), rep(year,nrow(table)))
        
        results <- rbind(results, table)
        Sys.sleep(3)
}
