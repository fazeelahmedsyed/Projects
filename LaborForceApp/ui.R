fluidPage(
        tabsetPanel(
                tabPanel('Find Indicator',
                         sidebarLayout(
                                 sidebarPanel(
                                         br(),
                                         textOutput('instruction'),
                                         tags$body(tags$style("#instruction{color:#FF1493; font-size: 18px ;font-family: Trebuchet MS, Helvetica, sans-serif;}")),
                                         br(),
                                         tags$style(type = 'text/css',".selectize-input{font-family: Trebuchet MS, Helvetica, sans-serif;} .selectize-dropdown {font-family: Trebuchet MS, Helvetica, sans-serif;}"),
                                         tags$style(type = 'text/css',".control-label{font-family: Trebuchet MS, Helvetica, sans-serif; font-size: 14;}"),
                                         selectInput(inputId = 'indctr', label = 'Which broad indicator are you interested in?', choices = c("Education Attainment","Household Population","Illiterate Population","Literacy Rate","Underemployed Population","Unemployed Population","Unemployed Population With Previous Experience of Work")),
                                         uiOutput('Slct_Desc'),
                                         selectInput(inputId = 'prvnce', label = 'Do you want country-wide statistics or for one Province?', choices = c("Country-Wide","Balochistan","KPK","Punjab","Sindh")),
                                         uiOutput('Slct_Lbrgrp'),
                                         uiOutput('Slct_Edulvl'),
                                         uiOutput('Slct_Rrub'),
                                         uiOutput('Slct_Gndr'),
                                         uiOutput('Slct_Age'),
                                         width = 4
                                 ),
                                 mainPanel(
                                         br(),
                                         br(),
                                         fluidRow(column(4, offset = 3, 
                                                         textOutput('txtval'),
                                                         tags$body(tags$style("#txtval{font-size: 72px;font-family: Trebuchet MS, Helvetica, sans-serif;}")))),
                                         fluidRow(column(4, offset = 3, 
                                                         textOutput('meanval'),
                                                         tags$body(tags$style("#meanval{color:#FF1493 ;font-size: 150px;font-family: Trebuchet MS, Helvetica, sans-serif;}"))))
                                 )
                         )
                ),
                tabPanel('Graphical Analysis',
                         br(),
                         selectInput(inputId = 'plttyp', label = 'What kind of Graphical Analysis are you interested in?', choices = c('Individual Variables','Individual Variables over a Group', 'Two variables over a Group')),
                         conditionalPanel(condition = "input.plttyp == 'Individual Variables over a Group'",
                                          selectInput(inputId = 'indctr2', label = 'Which broad indicator are you interested in?', choices = c("Education Attainment","Household Population","Illiterate Population","Literacy Rate","Underemployed Population","Unemployed Population","Unemployed Population With Previous Experience of Work")),
                                          uiOutput('Slct_Desc2'),
                                          selectInput(inputId = 'sbst', label = 'Do you wish to subset the data?', choices = c('Yes', 'No'), selected = 'No'),
                                          conditionalPanel(condition = "input.sbst == 'Yes'",
                                                           checkboxInput(inputId = 'Lbrgrp2', label = 'According to Labour Group'),
                                                           checkboxInput(inputId = 'Edulvl2', label = 'According to Educational Levels')
                                                           #checkboxInput(inputId = 'Rrub2', label = 'According to Rural Urban Division'),
                                                           #checkboxInput(inputId = 'Gndr2', label = 'According to Gender'),
                                                           #checkboxInput(inputId = 'Age2', label = 'According to Age')
                                                           
                                          ),
                                          conditionalPanel(condition = "input.Lbrgrp2", uiOutput('Slct_Lbrgrp2')),
                                          conditionalPanel(condition = "input.Edulvl2 & input.Lbrgrp2", uiOutput('Slct_Edulvl2')),
                                          conditionalPanel(condition = "input.Edulvl2 & !input.Lbrgrp2", uiOutput('Slct_Edulvl2_2')),
                                          #conditionalPanel(condition = "input.Rrub2", uiOutput('Slct_Rrub2')),
                                          #conditionalPanel(condition = "input.Gndr2", uiOutput('Slct_Gndr2')),
                                          #conditionalPanel(condition = "input.Age2", uiOutput('Slct_Age2')),
                                          selectInput(inputId = 'fctr', label = 'Over which Group should the Variable be analyzed?', choices = c('Gender' = 'Gender', 'Education Levels' = 'Education.Level.or.Type', 'Province' = 'Province', 'Rural//Urban' = 'Rural.Urban', 'Labour Group' = 'Labour.Group', 'Age' = 'Age')),
                                          plotOutput('fctrplot')
                         ),
                         conditionalPanel(condition = "input.plttyp == 'Two variables over a Group'",
                                          selectInput(inputId = 'indctr2_TV1', label = 'Choose the First broad indicator:', choices = c("Education Attainment","Household Population","Illiterate Population","Literacy Rate","Underemployed Population","Unemployed Population","Unemployed Population With Previous Experience of Work")),
                                          uiOutput('Slct_Desc2_TV1'),
                                          selectInput(inputId = 'indctr2_TV2', label = 'Choose the Second broad indicator:', choices = c("Education Attainment","Household Population","Illiterate Population","Literacy Rate","Underemployed Population","Unemployed Population","Unemployed Population With Previous Experience of Work")),
                                          uiOutput('Slct_Desc2_TV2'),
                                          selectInput(inputId = 'fctrTV', label = 'Over which Group should the Variable be analyzed?', choices = c('Gender' = 'Gender', 'Education Levels' = 'Education.Level.or.Type', 'Province' = 'Province', 'Rural//Urban' = 'Rural.Urban', 'Labour Group' = 'Labour.Group', 'Age' = 'Age')),
                                          textOutput('toto'),
                                          plotOutput('TVplot')
                         ),
                         conditionalPanel(condition = "input.plttyp == 'Individual Variables'",
                                          selectInput(inputId = 'indctr2_OV', label = 'Which broad indicator are you interested in?', choices = c("Education Attainment","Household Population","Illiterate Population","Literacy Rate","Underemployed Population","Unemployed Population","Unemployed Population With Previous Experience of Work")),
                                          uiOutput('Slct_Desc2_OV'),
                                          selectInput(inputId = 'pltstyl', 'Which Plot do you wish to see?', choices = c('Histogram','Violin Plot')),
                                          plotOutput('OVplot')
                         )
                ),
                tabPanel('About',
                         br(),
                         textOutput('abt'),
                         tags$style("#abt{color:#FF1493; font-size: 16px ;font-family: Trebuchet MS, Helvetica, sans-serif; white-space: pre-wrap;}"),
                         br(),
                         textOutput('abt2'),
                         tags$style("#abt2{color:#FF1493; font-size: 16px ;font-family: Trebuchet MS, Helvetica, sans-serif; white-space: pre-wrap;}"),
                         br(),
                         dataTableOutput('dfabt1'),
                         br(),
                         textOutput('abt3'),
                         tags$style("#abt3{color:#FF1493; font-size: 16px ;font-family: Trebuchet MS, Helvetica, sans-serif; white-space: pre-wrap;}"),
                         br(),
                         dataTableOutput('dfabt2'),
                         br(),
                         textOutput('abt4'),
                         tags$style("#abt4{color:#FF1493; font-size: 16px ;font-family: Trebuchet MS, Helvetica, sans-serif; white-space: pre-wrap;}"),
                         br(),
                         downloadButton('SourceFile',label = ' Download ')
                )
                
        )
)

