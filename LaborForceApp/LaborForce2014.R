
LF <- read.csv('LaborForce2014.csv')
str(LF)
summary(LF)

#removing columns with only NA's
LF <- LF[,-c(1,2,4:9,12:14,17,19,21:28,32:36, 38:45)]
str(LF)

#Checking available indicators

(LF[,LF$Province == ""])$Region.Type ##Indicators are available for Both country wide and Provinces
summary(LF$Indicators) ##There are 8 broad indicators available
summary(LF$Description) ##Indicators are subdivided into further categories based on labor type or age group
length(LF[LF$Sub.Category != "",]$Description) ##2770 available indicators based on labor type
length(LF$Age[LF$Age != ""]) ## Age data is available for almost all the data (13270 vs 2016 for which age group not available)
summary(LF[LF$Age == "",]$Sub.Category)##Data of 'exact' labor types is only available for 2016 participant institutions for which Age is not available
summary(LF[LF$Age != "",]$Sub.Category)##Data of labor types is of two types itself: 1. exact trade 2. Civilian LF/Employed/Not in Civilian LF (for this group, age is available)
for (i in levels(LF$Indicators)){obj <- summary(LF[LF$Indicators == i,]$Description); print(i); print(obj[obj != 0])} #Checking further classifications of indicators

#Changes for indctr
summary(LF$Indicators)
levels(LF$Indicators) <- c("Education Attainment",                                        
                   "Household Population",                                        
                   "Illiterate Population",                                       
                   "Literacy Rate",                                               
                   "Underemployed Population",                              
                   "Unemployed Population",                                 
                   "Unemployed Population With Previous Experience of Work")
summary(LF$Indicators)

#Changes for desc
summary(LF$Description)
levels(LF$Description) <- c("Education level by Age Group",                                                                         
                            "Education level by Nature of Labour Force Activity",                                                   
                            "Illiterate Population by Age Group",                                                                   
                            "Illiterate Population by Nature of Labour Force Activity",                                             
                            "Illiterate Underemployed Population",                                                                  
                            "Illiterate Unemployed Population by Age Group",                                                        
                            "Illiterate Unemployed Population with previous Experience of Work by Major Occupation Groups",         
                            "Literacy Rate by Age Group",                                                                           
                            "Literacy Rate by Nature of Labour Force Activity",                                                     
                            "Literate Underemployed Population",                                                                    
                            "Literate Unemployed Population by Age Group",                                                          
                            "Literate Unemployed Population with previous Experience of Work by Major Occupation Groups",           
                            "Percentage of Literate Population (10 years & above)",                                                 
                            "Percentage of Literate Population (5 years & above)",                                                  
                            "Percentage of Total Household Population",                                                             
                            "Percentage of Total Underemployed Population who worked < 35 hours during Reference Week",     
                            "Percentage of Total Unemployed Population",                                                            
                            "Percentage of Total Unemployed Population with previous Experience of Work by Major Occupation Groups",
                            "Underemployed Population by Education Levels",                                                         
                            "Unemployed Population by Education Levels")

#Changes for prvnce
LF <- LF[,-4] #Removing Region.Type
summary(LF$Province)
levels(LF$Province) <- c('Country-Wide', 'Balochistan','KPK', 'Punjab','Sindh')

#Changes for lbgrp
colnames(LF)[colnames(LF) == 'Sub.Category'] <- 'Labour.Group'
levels(LF$Labour.Group)[1] <- 'Unknown'

#Changes for edulvl
LF <- LF[,-6]
colnames(LF)[colnames(LF) == 'Institution.Level'] <- 'Education.Level.or.Type'
levels(LF$`Education Level or Type`) <- c("Not Available","Formal","Higher Secondary","Incomplete Degree","Incomplete Higher Secondary","Incomplete Middle","Incomplete Pre-Primary","Incomplete Primary","Incomplete Secondary","Non-formal","Pre-Secondary","Secondary","Undergraduate; Graduate & Postgraduate")

#Changes for rrub
colnames(LF)[colnames(LF) == 'Area'] <- 'Rural.Urban'

#Changes for gndr
levels(LF$Gender)[1] <- 'Did not Provide'

#Changes for age
levels(LF$Age)[1] <- 'Not Available'
LF$Age <- as.factor(as.character(LF$Age))
levels(LF$Age) = levels(LF$Age)[c(11,10,2,1,3:9,12:16,17)]

#Writing File
write.csv(LF, 'LF2014.csv', row.names = F)


#Creating Data insights from available indicators

##Unemployed people
summary(LF[LF$Indicators == 'Total unemployed population',])
df <- aggregate(Value ~ Province, data = LF , FUN = mean)
levels(df$Province)[1] = 'Pakistan'
barplotter <- function(data, x, y, stats, pal, title, ylab, xlab){
  dev.off()
  plot <- ggplot(data, aes(x,y, fill = x)) +
          geom_bar(stat= stats, width = 0.5) +
          labs(title = title, y = ylab) +
          geom_text(aes(label = round(y, 2)), vjust = -1) +
          theme (panel.grid = element_blank(), panel.background = element_blank(), axis.line = element_line(color = 'black')) +
          scale_fill_brewer(palette = pal)
  return(plot)
}

dev.off()
df
