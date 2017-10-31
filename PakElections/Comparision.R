#This script is for extracting information about PTI's performance in Elections 2013

Results <- read.csv("Results2013_province.csv", stringsAsFactors = F, header = T)
str(Results)

#Extracting Number of candidates who appeared from PTI

PTI <- Results[Results$Party == 'PTI',]
str(PTI)
summary(duplicated(PTI$Seat)) #No duplicates indicate, no two PTI members contested from the same seat

#Extracting Number of candidates who appeared from PMLN

levels(as.factor(Results$Party)) #Checking how is PMLN denoted in Results
PMLN <- Results[Results$Party == 'PML-N',]
#Results$Party[Results$Party == 'PMl-N'] <- "PML-N" #Converting a spelling mistake
#PMLN <- Results[Results$Party == 'PML-N',]
summary(duplicated(PMLN$Seat)) #No duplicates

#Preparing for graph for candidates

library(dplyr)
library(ggplot2)

PTI$Province <- factor(PTI$Province)
PTICounts <- as.data.frame(count(PTI, Province))

PMLN$Province <- factor(PMLN$Province)
PMLNCounts <- as.data.frame(count(PMLN, Province))

Results$Province <- factor(Results$Province)
TotalCounts <- group_by(Results, Province)
TotalCounts <- as.data.frame(summarize(TotalCounts, n_distinct(Seat)))

Counts <- cbind(TotalCounts,PTICounts$n,PMLNCounts$n)
colnames(Counts)<- c("Province","Total","PTI","PMLN")
Counts

Counts$Province <- factor(Counts$Province, levels = c("Punjab","Sindh","KPK","Balochistan","FATA","Federal Capital"))

#Creating Graph
library(reshape2)
dfm <- melt(Counts)
p1 <- ggplot(dfm, aes(x = Province ,y = value, fill = variable)) + geom_bar(stat = 'identity', position = 'dodge', width = 0.5)+ scale_fill_manual("legend",values = c("Total" = 'red',"PTI" = 'dark green',"PMLN" = 'light green')) + geom_text(aes(label = value), position = position_dodge(width = 0.5), vjust = 1, size = 3) + ggtitle("Competing Candidates")+ylab("Seats")
plot(p1)
dev.off()

#Finding Seats won by Parties

Winners <- group_by(Results, Seat) %>% top_n(1, Votes)
dim(Winners)
Winners[(duplicated(Winners$Seat)),] #Seat 38 had no result
Winners <- filter(Winners, Seat != 38) #Removing Seat 38
group_by(Winners, Party) %>% summarize(n())
Winners <- filter(Winners, Party %in% c("PML-N","PPP-P","PTI")) #Choosing top 3 Parties
Winners <- group_by(Winners, Province, Party) %>% summarize(n())
Winners <- as.data.frame(Winners)

#Preparing for graph

Winners$Province <- factor(Winners$Province, levels = c("Punjab","Sindh","KPK","FATA","Balochistan","Federal Capital"))
colnames(Winners) <- c('Province',"Party","Seats")

#Plotting graph

p2 <- ggplot(Winners, aes(x = Province ,y = Seats, fill = Party)) + geom_bar(stat = 'identity', position = 'dodge', width = 0.5)+ scale_fill_manual("legend",values = c("PML-N" = 'red',"PPP-P" = 'dark green',"PTI" = 'light green')) + geom_text(aes(label = Seats), position = position_dodge(width = 0.5), vjust = 1, size = 3) + ggtitle("Seats Won")+ylab("Seats")
plot(p2)
dev.off()

#Cleaning environment
a <- ls()
a <- a[!(a %in% c("Results","Winners"))]
rm(list = a)

#Finding Win Percentage for PTI

#Finding Winners & Runners ups
Win <- group_by(Results,Seat) %>% slice(1)
Run <- group_by(Results,Seat) %>% slice(2)
Win <- as.data.frame(Win)
Run <- as.data.frame(Run)

Diff <- cbind(Win[,-c(1,6)], Run$Party, Run$Votes)   
Diff <- Diff[,c(3,4,5,1,2,6,7)]
colnames(Diff)[4:7] <- c("WinParty","WinVotes","RunParty","RunVotes") 
Diff <- cbind(Diff, Df = Diff$WinVotes - Diff$RunVotes, Margin = ((Diff$WinVotes - Diff$RunVotes)/Diff$RunVotes))
Diff <- cbind(Diff, Percent = Diff$Margin * 100)              
summary(Diff$Percent)

PTIWins <- Diff[Diff$WinParty == "PTI",]
PTIRuns <- Diff[Diff$RunParty == "PTI",]

WinPercent <- cut(PTIWins$Percent, breaks = c(0,25,50,75,100,Inf), include.lowest = T, labels = c("<25%","<50%","<75%","<100%",">100%"))
RunPercent <- cut(PTIRuns$Percent, breaks = c(0,25,50,75,100,Inf), include.lowest = T, labels = c("<25%","<50%","<75%","<100%",">100%"))

PTIWins <- cbind(PTIWins, WinPercent)
PTIRuns <- cbind(PTIRuns, RunPercent)

#Creating Graphs
p4 <- ggplot(PTIWins, aes(x = WinPercent)) + geom_bar(stat = 'count', width = 0.4, fill = 'dark green') + geom_text(stat = 'count', aes(label =..count.. ), vjust = 1, size = 3, col = 'light green') + ggtitle("PTI Win Margin")+ylab("Seats")
plot(p4)
dev.off()

p5 <- ggplot(PTIRuns, aes(x = RunPercent)) + geom_bar(stat = 'count', width = 0.4, fill = 'light green') + geom_text(stat = 'count', aes(label =..count.. ), vjust = 1, size = 3, col = 'red') + ggtitle("PTI Runners Up Margin")+ylab("Seats")
plot(p5)
dev.off()

RunMargin <- cut(PTIRuns$Df/1000, breaks = c(0,33,66,99,133,166), include.lowest = T, labels = c("<33K","<66K","<99K","<133K","<166K"))
PTIRuns <- cbind(PTIRuns, RunMargin)

p6 <- ggplot(PTIRuns, aes(x = RunMargin)) + geom_bar(stat = 'count', width = 0.4, fill = 'light green') + geom_text(stat = 'count', aes(label =..count.. ), vjust = 1, size = 3, col = 'red') + ggtitle("PTI Runners Up Margin")+ylab("Seats") + xlab("Runners Up Losing Margin in 1000s")
plot(p6)
dev.off()

#Finding PMLNs Performance

PMLNWins <- Diff[Diff$WinParty == "PML-N",]
PMLNRuns <- Diff[Diff$RunParty == "PML-N",]

WinPercent <- cut(PMLNWins$Percent, breaks = c(0,25,50,75,100,Inf), include.lowest = T, labels = c("<25%","<50%","<75%","<100%",">100%"))
RunPercent <- cut(PMLNRuns$Percent, breaks = c(0,25,50,75,100,Inf), include.lowest = T, labels = c("<25%","<50%","<75%","<100%",">100%"))

PMLNWins <- cbind(PMLNWins, WinPercent)
PMLNRuns <- cbind(PMLNRuns, RunPercent)

#Creating Graphs
p7 <- ggplot(PMLNWins, aes(x = WinPercent)) + geom_bar(stat = 'count', width = 0.4, fill = 'dark green') + geom_text(stat = 'count', aes(label =..count.. ), vjust = 1, size = 3, col = 'white') + ggtitle("PMLN Win Margin")+ylab("Seats")
plot(p7)
dev.off()

p8 <- ggplot(PMLNRuns, aes(x = RunPercent)) + geom_bar(stat = 'count', width = 0.4, fill = 'light green') + geom_text(stat = 'count', aes(label =..count.. ), vjust = 1, size = 3, col = 'dark green') + ggtitle("PMLN Runners Up Margin")+ylab("Seats")
plot(p8)
dev.off()

RunMargin <- cut(PMLNRuns$Df/1000, breaks = c(0,33,66,99,133,166), include.lowest = T, labels = c("<33K","<66K","<99K","<133K","<166K"))
PMLNRuns <- cbind(PMLNRuns, RunMargin)

p9 <- ggplot(PMLNRuns, aes(x = RunMargin)) + geom_bar(stat = 'count', width = 0.4, fill = 'light green') + geom_text(stat = 'count', aes(label =..count.. ), vjust = 1, size = 3, col = 'dark green') + ggtitle("PMLN Runners Up Margin")+ylab("Seats") + xlab("Runners Up Losing Margin in 1000s")
plot(p9)
dev.off()

#Storing as data
write.csv(PTIWins, "PTIWins.csv", row.names = F)
write.csv(PTIRuns, "PTIRuns.csv", row.names = F)

