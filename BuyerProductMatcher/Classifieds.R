#This script is for creating a Buyer-Product matching mechanism for classifieds 

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

#-----------------------------------------------------------------------------------------

#df <- read.csv("motorcycles.csv", stringsAsFactors = F)
#df2 <- read.csv("cars.csv", stringsAsFactors = F)


#Making data usable for Bag-of-Words 
df <- cbind(df, category = rep("motorcycle", nrow(df)))
df <- unique(df)
df$product <- gsub("[[:punct:]]","",df$product)
df$product <- gsub("\\s", " ", df$product)
df$product <- gsub("([[:alpha:]]{2,})(\\d{3,})","\\1 \\2", df$product)

df2 <- cbind(df2, category = rep("car",nrow(df2)))
df2 <- unique(df2)
df2$product <- gsub("[[:punct:]]","",df2$product)
df2$product <- gsub("\\s", " ", df2$product)
df2$product <- gsub("([[:alpha:]]{2,})(\\d{3,})","\\1 \\2", df2$product)

rm(list = ls()[!(ls() %in% c('df','df2'))])

#Loading dependencies for Bag-of-Words
library(qdap)
library (tm)

par(mfrow = c(2,1))

#Exploring if there are differentiating features between motorcycles and cars
text1 <- paste(df$product, sep = "",collapse = " ")
plot(freq_terms(text1))

text2 <- paste(df2$product, sep = "", collapse = " ")
plot(freq_terms(text2))

#Applying Bag-of-Words transformation on motorcycles data
df_source <- VectorSource(df$product)
df_corpus <- VCorpus(df_source)

df_corpus <- tm_map(df_corpus,removeWords, stopwords("en")) #removing common standard english words

df_dtm <- DocumentTermMatrix(df_corpus)
df_dtm

df_m <- as.matrix(df_dtm)
dim(df_m)
df_m[1:5,400:405] #The matrix is pretty sparse, we can reduce sparsity

df_s <- removeSparseTerms(df_dtm, 0.98)
df_s
df_m <- as.matrix(df_s)
dim(df_m)
df_m[1:5,20:25]

#Splitting data into train and test for clustering
df_m.train <- df_m[1:3000,]
df_m.test <- df_m[3001:3355,]

#loading dependencies for clustering
library(class)

#Checking optimum level of clusters for k-means clustering
wss <- numeric(40)
for (i in 2:40) {wss[i] <- sum(kmeans(df_m.train, centers=i)$withinss)}
plot(1:40, wss, type="b", col = 'red', xlab="Number of Clusters", ylab="Within groups sum of squares")
        #best option appears 25. Thats where the plateau starts. Also, for each cluster we will have 120 cases. Each buyer will have 120 best matches. 

#Making clusters and adding labels to data
k.fit <- kmeans(df_m.train,centers = 25)
k.fit$centers
df_m.train <- data.frame(df_m.train,k.fit$cluster)
dim(df_m.train)
colnames(df_m.train)[32] <- "label"
df_m.train$label <- as.factor(df_m.train$label)

#loading dependencies for classifying new data
library(e1071)

#Creating a classifier based on svm
svm.fit <- svm(df_m.train$label ~ ., data = df_m.train)
df_m.test <- data.frame(df_m.test, rep(0, 355))
colnames(df_m.test)[32] <- "label"

#Creating matches for a buyer
preds <- predict(svm.fit, newdata = df_m.test)
preds[1:5]

#Checking recommendations to one buyer
example <- df_m[3003,]
        #Super power 2016
df_m.train[df_m.train$label == 15,]
(df_m.train[df_m.train$label == 15,])

