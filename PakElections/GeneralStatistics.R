#This Script is to extract information from the 2013 elections in Pakistan

#Reading data
Results <- read.csv("Results2013.csv", header = T, stringsAsFactors = F)

#Adding a Province Column
dim(Results)
Province <- character(4554)

Results2 <- cbind(Results, Province)
Results2$Province <- as.factor(Results2$Province)
levels(Results2$Province) <- c("KPK","FATA", "Federal Capital", "Punjab","Sindh","Balochistan")

for (i in 1:35){
        Results2[Results2$Seat == i,7] <- "KPK"}
for (i in 36:47){
        Results2[Results2$Seat == i,7] <- "FATA"}
        
        Results2[Results2$Seat == 48, 7] <- "Federal Capital"
        Results2[Results2$Seat == 49, 7] <- "Federal Capital"
        
for (i in 50:197){
        Results2[Results2$Seat == i,7] <- "Punjab"}
for (i in 198:258){
        Results2[Results2$Seat == i,7] <- "Sindh"}
for (i in 259:272){
        Results2[Results2$Seat == i,7] <- "Balochistan"}
write.csv(Results2, "Results2013_province.csv", row.names = F)
        
#Checking Votes Province-wise
library(dplyr)
library(ggplot2)

R_grp <- group_by(Results2,Province)
VotesbyPro <- summarise(R_grp, Votes = sum(Votes))
VotesbyPro <- as.data.frame(VotesbyPro)
VotesbyPro$Votes <- round(VotesbyPro$Votes/1000000, 2)
VotesbyPro <- as.data.frame(VotesbyPro)
VotesbyPro <- VotesbyPro[order(VotesbyPro$Votes, decreasing = T),]
VotesbyPro$Province <- as.character(VotesbyPro$Province)
VotesbyPro$Province <- factor(VotesbyPro$Province, levels = c('Punjab','Sindh','FATA','Balochistan','KPK','Federal Capital'))

graph <- ggplot(VotesbyPro, aes(Province, Votes)) + geom_col(fill = 'light green', width = 0.3) + ggtitle("VOTER TURNOUT IN EACH PROVINCE") + theme(panel.background = element_rect( fill = 'dark green'), panel.grid = element_blank(), plot.title = element_text(face = 'bold', size = 20, color = 'dark green')) + labs (y = "Votes in mil.") + geom_text(aes(label = Votes), size = 4, hjust = 0.5, vjust = -0.5, col = 'light green')
plot(graph)
dev.off()

#rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = "dark green")
#graph <- barplot(VotesbyPro$Votes, 
#                 main = "Votes by Province", xlab = "Province", ylab = "Voter Turnout in millions", names.arg = VotesByPro$Province, 
#                 cex.axis = 0.8, cex.main =2, cex.lab= 1.5, 
#                 bty = 'n', col = 'light green', border = 'light green', space = 2, ylim = range(0,30),
#                 add = T)
#text(x = graph, y = VotesbyPro$Votes, label = round(VotesbyPro$Votes), pos = 3, cex = 0.8, col = 'light green')

#Checking Votes Party-wise
Results2$Party <- as.factor(Results2$Party)
R_grp <- group_by(Results2, Party)
VotesbyPar <- summarize(R_grp, Votes = sum(Votes))
VotesbyPar <- as.data.frame(VotesbyPar)

#Checking Highest voted Persons
Persons <- data.frame(Name = Results2$Name, Party = Results2$Party, Votes = Results2$Votes)
Persons <- (Persons[order(Persons$Votes, decreasing = T),])[1:10,]

#Checking Highest Voted Cities
Results2$City <- as.factor(Results2$City)
R_grp <- group_by(Results2, City)
VotesbyCity <- summarize(R_grp, Votes = sum(Votes))
VotesbyCity <- as.data.frame(VotesbyCity)
VotesbyCity <- (VotesbyCity[order(VotesbyCity$Votes, decreasing = T),])[1:20,]

#Checking Seats won by Parties
SeatWinners <- aggregate(Votes ~ Seat, Results2, max)
SeatWinners <- merge(SeatWinners, Results2)
PartySeats <- count(SeatWinners, Party, sort = T)
PartySeats <- as.data.frame(PartySeats[1:10,])

#Magnitude of Win
Results2$Seat <- as.factor(Results2$Seat)
R_grp <- group_by(Results2, Seat)
WinRun <- top_n(R_grp,n = 2, wt = Votes)
WinRun <- as.data.frame(WinRun)
R_grp <- group_by(WinRun, Seat)
Diff <- summarize(R_grp ,difference = first(Votes) - last(Votes), Ratio = (first(Votes) - last(Votes))/last(Votes))
Diff <- as.data.frame(Diff)
SeatWinners <- SeatWinners[order(SeatWinners$Seat),]
WinDiff <- merge(Diff, SeatWinners)
WinDiff <- WinDiff[,c(1,2,3,6,9)]
