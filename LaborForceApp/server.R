library(ggplot2)
function(input,output){
        #Extracting the datafile
        LF <- read.csv('LF2014.csv', header = T)
        
        #TabPanel 1
                output$instruction <- renderText('Use the dropdown menus to select the indicator interested in.')
                
                #Creating Selectors
                output$Slct_Desc <- renderUI({tagList(selectInput('desc', 'Select one of the available statistics',choices = names(summary(LF$Description[LF$Indicators == input$indctr])[summary(LF$Description[LF$Indicators == input$indctr]) != 0])))})
                output$Slct_Lbrgrp <- renderUI({tagList(selectInput('lbrgrp', 'For which Labour Group?',choices = names(summary(LF$Labour.Group[LF$Description == input$desc & LF$Indicators == input$indctr])[summary(LF$Labour.Group[LF$Description == input$desc & LF$Indicators == input$indctr]) != 0])))})
                output$Slct_Edulvl <- renderUI({tagList(selectInput('edulvl', 'For which level of Education of Individuals? (also formal or non-formal)',choices = names(summary(LF$Education.Level.or.Type[LF$Labour.Group == input$lbrgrp & LF$Description == input$desc & LF$Indicators == input$indctr])[summary(LF$Education.Level.or.Type[LF$Labour.Group == input$lbrgrp & LF$Description == input$desc & LF$Indicators == input$indctr]) != 0])))})
                output$Slct_Rrub <- renderUI({tagList(selectInput('rrub', 'For Urban population or for Rural?', choices = names(summary(LF$Rural.Urban[LF$Education.Level.or.Type == input$edulvl & LF$Labour.Group == input$lbrgrp & LF$Description == input$desc & LF$Indicators == input$indctr])[summary(LF$Rural.Urban[LF$Education.Level.or.Type == input$edulvl & LF$Labour.Group == input$lbrgrp & LF$Description == input$desc & LF$Indicators == input$indctr]) != 0])))})
                output$Slct_Gndr <- renderUI({tagList(selectInput('gndr', 'Which Gender?',choices = names(summary(LF$Gender[LF$Rural.Urban == input$rrub & LF$Education.Level.or.Type == input$edulvl & LF$Labour.Group == input$lbrgrp & LF$Description == input$desc & LF$Indicators == input$indctr])[summary(LF$Gender[LF$Rural.Urban == input$rrub & LF$Education.Level.or.Type == input$edulvl & LF$Labour.Group == input$lbrgrp & LF$Description == input$desc & LF$Indicators == input$indctr]) != 0])))})
                output$Slct_Age <- renderUI({tagList(selectInput('age', 'Which Age Range?',choices = names(summary(LF$Age[LF$Gender == input$gndr & LF$Rural.Urban == input$rrub & LF$Education.Level.or.Type == input$edulvl & LF$Labour.Group == input$lbrgrp & LF$Description == input$desc & LF$Indicators == input$indctr])[summary(LF$Age[LF$Gender == input$gndr & LF$Rural.Urban == input$rrub & LF$Education.Level.or.Type == input$edulvl & LF$Labour.Group == input$lbrgrp & LF$Description == input$desc & LF$Indicators == input$indctr]) != 0])))})
                
                #Creating Data extracting algo
                subset_df <- reactive({data_inner <- subset(LF, Indicators == input$indctr & Description == input$desc & Province == input$prvnce & Labour.Group == input$lbrgrp & Education.Level.or.Type == input$edulvl & Rural.Urban == input$rrub & Gender == input$gndr & Age == input$age)
                return(data_inner)}) 
                subset_meanval <- reactive({ mean(subset_df()[,'Value'])})
                output$txtval <- renderText('Mean Value:')
                output$meanval <- renderText({paste(round(subset_meanval(),2),'%', sep = '')})
                
        #TabPanel 2
                #For A Variable over a Group
                
                #Creating selector for description
                output$Slct_Desc2 <- renderUI({tagList(selectInput('desc2', 'Select one of the available statistics',choices = names(summary(LF$Description[LF$Indicators == input$indctr2])[summary(LF$Description[LF$Indicators == input$indctr2]) != 0])))})
                
                #Creating selectors based on description
                output$Slct_Lbrgrp2 <- renderUI({tagList(selectInput('lbrgrp2', 'For which Labour Group?', choices = names(summary(LF$Labour.Group[LF$Description == input$desc2 & LF$Indicators == input$indctr2])[summary(LF$Labour.Group[LF$Description == input$desc2 & LF$Indicators == input$indctr2]) != 0])))})
                output$Slct_Edulvl2 <- renderUI({tagList(checkboxGroupInput('edulvl2', 'For which Education Level of Labour?', choices = names(summary(LF$Education.Level.or.Type[LF$Labour.Group == input$lbrgrp2 & LF$Description == input$desc2 & LF$Indicators == input$indctr2])[summary(LF$Education.Level.or.Type[LF$Labour.Group == input$lbrgrp2 & LF$Description == input$desc2 & LF$Indicators == input$indctr2]) != 0])))})
                output$Slct_Edulvl2_2 <- renderUI({tagList(checkboxGroupInput('edulvl2_2', 'For which Education Level of Labour?', choices = c("Formal","Higher Secondary","Incomplete Degree","Incomplete Higher Secondary","Incomplete Middle","Incomplete Pre-Primary","Incomplete Primary","Incomplete Secondary","Non-formal","Not Available","Pre-Secondary","Secondary","Undergraduate; Graduate & Postgraduate")))})
                #output$Slct_Rrub2 <- renderUI({tagList(selectInput('rrub2', 'For Urban population or for Rural?', choices = names(summary(LF$Rural.Urban[LF$Description == input$desc2 & LF$Indicators == input$indctr2])[summary(LF$Rural.Urban[LF$Description == input$desc2 & LF$Indicators == input$indctr2]) != 0])))})
                #output$Slct_Gndr2 <- renderUI({tagList(selectInput('gndr2', 'Which Gender?',choices = names(summary(LF$Gender[LF$Description == input$desc2 & LF$Indicators == input$indctr2])[summary(LF$Gender[LF$Description == input$desc2 & LF$Indicators == input$indctr2]) != 0])))})
                #output$Slct_Age2 <- renderUI({tagList(selectInput('age2', 'Which Age Range?',choices = names(summary(LF$Age[LF$Description == input$desc2 & LF$Indicators == input$indctr2])[summary(LF$Age[LF$Description == input$desc2 & LF$Indicators == input$indctr2]) != 0])))})
                
                #Creating subset selection algo
                sub_r <- reactive({
                        if(input$sbst == 'Yes'){
                                if(input$Lbrgrp2 & !input$Edulvl2){sub <- subset(LF, Indicators == input$indctr2 & Description == input$desc2 & Labour.Group == input$lbrgrp2)
                                } else if(input$Lbrgrp2 & input$Edulvl2){sub <- subset(LF, Indicators == input$indctr2 & Description == input$desc2 & Labour.Group == input$lbrgrp2 & Education.Level.or.Type %in% input$edulvl2)
                                } else {sub <- subset(LF, Indicators == input$indctr2 & Description == input$desc2 & Education.Level.or.Type %in% input$edulvl2_2)}
                        } else {
                                sub <- subset(LF, Indicators == input$indctr2 & Description == input$desc2)}
                        return(sub)
                })
                
                #Creating plot
                plot_r <- reactive({
                        sb <- sub_r()[,c(input$fctr,'Value')]
                        my_mean = aggregate(sb$Value, by = list(sb[,c(input$fctr)]), mean); colnames(my_mean) = c(input$fctr,'mean')
                        my_sd = aggregate(sb$Value, by = list(sb[,c(input$fctr)]), sd); colnames(my_sd) = c(input$fctr,'sd')
                        my_info = merge(my_mean, my_sd, by.x = 1, by.y = 1)
                        
                        plot <- ggplot(data = sb) +
                                geom_violin(aes(x = sb[,c(input$fctr)], y = Value, fill = Value), colour = rgb(255, 179, 219, maxColorValue = 255))+
                                geom_point(aes(x = sb[,c(input$fctr)], y = Value), colour = rgb(255, 179, 219, maxColorValue = 255), size = 4) +
                                geom_point(data = my_info, aes(x = my_info[,c(input$fctr)], y = mean), colour = rgb(255,20,147, maxColorValue = 255), size = 8) +
                                geom_errorbar(data = my_info, aes(x = my_info[,c(input$fctr)], ymin = mean - sd, ymax = mean + sd), colour = rgb(179,9,92, maxColorValue = 255), width = 0.7, size = 1, linetype = 1)+
                                geom_text(data = my_info, aes(x = my_info[,c(input$fctr)], y = mean, label = round(mean,2)), hjust = 2, vjust = 0, size = 3)+
                                xlab(paste(input$desc2,"shown over",input$fctr))      
                        
                        return(plot)})
                
                output$fctrplot <- renderPlot(plot_r())
                
                #For Two Variables over a Group
                
                #Creating selector for description1
                output$Slct_Desc2_TV1 <- renderUI({tagList(selectInput('desc2_TV1', 'Select Corresponding Statistic',choices = names(summary(LF$Description[LF$Indicators == input$indctr2_TV1])[summary(LF$Description[LF$Indicators == input$indctr2_TV1]) != 0])))})
                
                #Creating selector for description2
                output$Slct_Desc2_TV2 <- renderUI({tagList(selectInput('desc2_TV2', 'Select Corresponding Statistic',choices = names(summary(LF$Description[LF$Indicators == input$indctr2_TV2])[summary(LF$Description[LF$Indicators == input$indctr2_TV2]) != 0])))})
                
                #Creating initial subsets and check
                subTV_r <- reactive({sub <- subset(LF, Indicators == input$indctr2_TV1 & Description == input$desc2_TV1); return(sub)})
                sub2TV_r <- reactive({sub2 <- subset(LF, Indicators == input$indctr2_TV2 & Description == input$desc2_TV2); return(sub2)})  
                common_r <- reactive({
                        koko <- names(summary(subTV_r()[,c(input$fctrTV)]))[summary(subTV_r()[,c(input$fctrTV)]) != 0]
                        loco <- names(summary(sub2TV_r()[,c(input$fctrTV)]))[summary(sub2TV_r()[,c(input$fctrTV)]) != 0]
                        common <- intersect(koko,loco)
                        return(common)})  
                dfTV_r <- reactive({
                        validate(need(length(common_r()) != 0, "Please select different values, the selected inputs do not have any common set"))
                        sbTV <- (subTV_r()[subTV_r()[,c(input$fctrTV)] %in% common_r(),])[,c(input$fctrTV,'Value', 'Description')] 
                        sb2TV <- (sub2TV_r()[sub2TV_r()[,c(input$fctrTV)] %in% common_r(),])[,c(input$fctrTV,'Value', 'Description')]
                        dfTV <- rbind(sbTV,sb2TV)
                        dfTV[,c(input$fctrTV)] <- as.factor(as.character(dfTV[,c(input$fctrTV)])) 
                        dfTV$Description <- as.factor(as.character(dfTV$Description))
                        return(dfTV)})
                
                #Creating plot
                titleText <- reactive({if (input$fctrTV == 'Education.Level.or.Type'){title <- "Distribution over Education Levels"}
                        else if(input$fctrTV == 'Rural.Urban'){title <- "Distribution over Rural/Urban"}
                        else if(input$fctrTV == 'Labour.Group'){title <- "Distribution over Labour Group Types"}
                        else {title <- paste("Distribution over", input$fctrTV)}
                        return(title)})
                boxcolors_r <- reactive({c(rgb(255, 179, 219, maxColorValue = 255),rgb(255, 0, 132, maxColorValue = 255))})
                formulaText <- reactive({paste("Value ~ Description*",input$fctrTV, sep = "")})
                boxTV_r <- reactive({boxplot(as.formula(formulaText()),data = dfTV_r(),boxwex = 0.4,main = titleText(),ylab = 'Percentage Value',col = boxcolors_r(),xaxt = 'n',frame.plot = F,outline = F,add = F,border = rgb(179,9,92, maxColorValue = 255),boxlwd = 1)})
                output$TVplot <- renderPlot({boxTV_r()
                        legend('topleft',legend = c(input$desc2_TV1,input$desc2_TV2),col = boxcolors_r(),pch = 15,bty = 'n',pt.cex = 2.5,cex = 0.8,horiz = F,inset = c(0.05,0.05))
                        if (input$indctr2_TV1 == input$indctr2_TV2 & input$desc2_TV1 == input$desc2_TV2){
                                axis(1, at = seq(1,length(common_r())), labels = common_r() , tick=FALSE , cex=0.3)
                                text(x=seq(1:length(common_r())), y = ((boxTV_r()[['stats']])[3,]+0.5), labels = formatC(round((boxTV_r()[['stats']])[3,],2), format = 'f', digits = 2), cex = 1)
                        }else{
                                axis(1, at = seq(1.5,length(common_r())*2-0.5,2), labels = common_r() , tick=FALSE , cex=0.3)
                                text(x=seq(1:(length(common_r())*2)), y = ((boxTV_r()[['stats']])[3,]+0.5), labels = formatC(round((boxTV_r()[['stats']])[3,],2), format = 'f', digits = 2), cex = 1)
                        }}) 
                #For Individual Variables
                
                #Creating selector for Description
                output$Slct_Desc2_OV <- renderUI({tagList(selectInput('desc2_OV', 'Select one of the available statistics',choices = names(summary(LF$Description[LF$Indicators == input$indctr2_OV])[summary(LF$Description[LF$Indicators == input$indctr2_OV]) != 0])))})
                
                #Creating subset
                subOV_r <- reactive({(subset(LF, LF$Indicators == input$indctr2_OV & LF$Description == input$desc2_OV))[,c('Description','Value')]})
                
                #Creating plot
                output$OVplot <- renderPlot({
                        if(input$pltstyl == 'Violin Plot'){ pluto <-ggplot(subOV_r(),aes(Description,Value))+
                                geom_violin(aes(fill = Value), fill = rgb(255, 0, 132, maxColorValue = 255), col = rgb(255,0,132,maxColorValue = 255))+
                                stat_summary(fun.y = mean, geom = 'point', shape = 23, size = 3, col = rgb(255, 179, 219, maxColorValue = 255))+
                                stat_summary(fun.y = mean, geom = 'text', label = paste("Mean =",round(mean(subOV_r()[,c('Value')]),2)), position = position_nudge(x=0.05, y=5))}
                        else if(input$pltstyl == 'Histogram'){
                                clr <- c(rgb(249, 26, 145, maxColorValue = 255),rgb(243, 32, 145,maxColorValue = 255),rgb(237, 38, 144,maxColorValue = 255),rgb(232, 44, 144,maxColorValue = 255),rgb(226, 50, 144,maxColorValue = 255),rgb(220, 56, 143,maxColorValue = 255),rgb(214, 61, 143,maxColorValue = 255),rgb(208, 67, 142,maxColorValue = 255),rgb(202, 73, 142,maxColorValue = 255),rgb(196, 79, 142,maxColorValue = 255),rgb(190, 85, 141,maxColorValue = 255),rgb(185, 91, 141,maxColorValue = 255),rgb(179, 97, 140,maxColorValue = 255),rgb(173, 103, 140,maxColorValue = 255),rgb(167, 108, 140,maxColorValue = 255),rgb(161, 114, 139,maxColorValue = 255),rgb(155, 120, 139,maxColorValue = 255),rgb(149, 126, 138,maxColorValue = 255),rgb(144, 132, 138,maxColorValue = 255),rgb(138, 138, 138,maxColorValue = 255))
                                pluto <- ggplot(subOV_r(), aes(x = Value))+
                                        geom_histogram(binwidth = 0.5 , aes(fill = ..count..))+
                                        scale_y_continuous(name = 'Count')+
                                        scale_fill_continuous("Count", high = rgb(249,26,145, maxColorValue = 255), low = rgb(190,85,141, maxColorValue = 255))
                                
                        }
                        return(pluto)})
        #TabPanel 3
                output$abt <- renderText("LabourApp is an app that provides summarized, easy-to-understand results for the Labour Force Survey conducted by Pakistan Bureau of Statistics in 2014-15.")
                output$abt2 <- renderText("The data used contains information on the following variables:")
                dfabt1_r <- reactive({data.frame(Variables = c('Provice','Rural Urban Classification of Area','Education Levels of the surveyed Labour Force','Labour Group','Gender'))})
                output$dfabt1 <- renderDataTable(dfabt1_r(), options = list(dom = 't'))
                output$abt3 <- renderText("Percentage Values for the following Indicators are available:")
                dfabt2_r <- reactive({ abtmkr <- data.frame()
                                        lvls <- levels(LF$Indicators)
                                        for (i in 1:length(lvls)){
                                                des <- names((summary(LF$Description[LF$Indicators == lvls[i]]))[summary(LF$Description[LF$Indicators == lvls[i]]) != 0])
                                                ind <- c(lvls[i],rep(" ", length(des)-1))
                                                tb <- data.frame(Indicator = ind, Variables = des)
                                                abtmkr <- rbind(abtmkr,tb)}
                                        return(abtmkr)})
                output$dfabt2 <- renderDataTable(dfabt2_r(), options = list(dom = 't'))
                output$abt4 <- renderText("Feel free to download the trimmed download file.")
                output$SourceFile <- downloadHandler( filename = "LabourForce2014_trimmed.csv", content = function(file){ write.csv(LF, file, row.names = F)})
}