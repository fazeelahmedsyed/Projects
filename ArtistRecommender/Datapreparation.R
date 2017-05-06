#downloading file
download.file("http://mtg.upf.edu/static/datasets/last.fm/lastfm-dataset-360K.tar.gz", destfile = "lastfm-dataset-360K")

#Checking the file

untar("lastfm-dataset-360K.tar.gz", list = T, compressed = T)
        #There are four files in the tar file, unzipping now 
untar("lastfm-dataset-360K.tar.gz", compressed = T)

#Reading Artist plays file, keeping rows max to 400,000 to conserve memory

artistplays <- read.csv("~/Projects/ArtistRecommender/lastfm-dataset-360K/usersha1-artmbid-artname-plays.tsv", sep = "\t", stringsAsFactors = F, header=F, quote = "", fill =T, nrows = 400000) 

#Providing column names

colnames(artistplays) <- c("UserID","ArtistID","ArtistName","Plays")

#Removing Empty entries
selector <- grep("^$",artistplays$ArtistID)
artistplays <- artistplays[-selector,]

#Checking strength of data for recommender

artistplays$UserID <- as.factor(artistplays$UserID)
artistplays$ArtistID <- as.factor(artistplays$ArtistID)
length(levels(artistplays$UserID))
        #There are 8181 unique Users in the dataset making it usable
length(levels(artistplays$ArtistID))
        #There is information on 44817 different artists. Enough to train our recommender.

#Creating a separate dataframe for Artists

artistnames <- data.frame(artistplays$ArtistID, artistplays$ArtistName)
colnames(artistnames) <- c("ArtistID", "ArtistName")
artistnames <- artistnames[!(duplicated(artistnames$ArtistID)),]

#Making artist plays Recommender-ready

artistplays <- artistplays[,c(1,2,4)]
        #Recommender only takes 3 columns as input on Microsoft Azure ML Studio
dc <- paste(artistplays$UserID, artistplays$ArtistID, sep = "_")
summary(duplicated(dc))
        #Recommender does not accept more than one rating for each artist for each user         
index <- 1:400000
selector <- c(index[duplicated(dc)],index[duplicated(dc, fromLast = T)])
artistplays <- artistplays[-selector,]
        #Removing 12 observations from 394,000+ will not make much difference on data's predictive ability, but will make possible training in ML studio
Plays <- artistplays$Plays
head(sort(Plays),10)
tail(sort(Plays),10)
        #Plays has 2 outliers at least
selector <- index[Plays>63000]
artistplays <- artistplays[-selector,]
        #Outliers removed
100/max(artistplays$Plays)
        #ML Studio Recommender only accepts Ratings Ranged from 1 to 100 (preferably 1-20) so we scale
options(digits = 6)
artistplays$Plays <- artistplays$Plays*0.0016114 
artistplays$Plays <- formatC(artistplays$Plays, digits = 6, format = 'f')
selector <- grep("0$", artistplays$Plays)
artistplays$Plays <- as.numeric(artistplays$Plays)
artistplays$Plays[selector] <- artistplays$Plays[selector]-0.000005
artistplays$Plays <- formatC(artistplays$Plays, digits = 6, format = 'f')

        #Ml Studio Recommender does not support floating points and also clips all trailers after 6 digits
        #0.000004 is added to keep all values significant at digits = 6

#Reading User profiles now

userinfo <- read.csv("~/Projects/ArtistRecommender/lastfm-dataset-360K/usersha1-profile.tsv", sep = "\t", stringsAsFactors = F, header = F, quote = "", fill = T)

#Providing column names

colnames(userinfo) <- c("UserID","Gender","Age","Country","Signup")

#Checking which Users are in our artistplays data set

selector <- match(artistplays$UserID,userinfo$UserID)
selector <- unique(selector)
        #The users in Artist Plays were arranged in order of user profile, therefore we select the first 8181 rows from userinfo

#Selecting user attribute table

userinfo <- userinfo[selector,]

#Saving all tables for use on Recommender Training

write.table(artistplays, "Lastfm-User-Artist-Plays.csv", sep = ",", row.names = F)
write.table(artistnames, "Lastfm-Artistfeatures.csv", sep = ",", row.names = F)
write.table(userinfo, "Lastfm-Userfeatures.csv", sep = ",", row.names = F)
