
library(data.table)
library(dplyr)
library(ggplot2)

dt.governors = fread("united_states_governors.csv")
dt.unemploymentData1 = fread("unemployment_1980-2018.csv")
dt.unemploymentData2 = fread("Unemployment_2012-2020.csv")
dt.education = fread("EducationReport_1970-2019.csv")

dt.governors= dt.governors[year>=1970,.(year,state,party)]
dt.governors =dt.governors[order(decreasing = T,year),]

colnames(dt.education)<-as.character(dt.education[1,]) ##set header first row
dt.education<-dt.education[-1,] ##remove first row after set to header

dt.unemployment=dt.unemploymentData1
dt.unemployment[,'2019':=dt.unemploymentData2$`2019`,by=dt.unemployment$Name,]##add 2019 from dt.unemploymentData2
dt.unemployment[,'2020':=dt.unemploymentData2$`2020`,by=dt.unemployment$Name,]##add 2020 from dt.unemploymentData2
