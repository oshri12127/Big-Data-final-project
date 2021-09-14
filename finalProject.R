###introduction####

library(data.table)
library(dplyr)
library(ggplot2)
library(tidyr) 
library(Amelia) # Missing Data: Missings Map
library(scales) # Visualization

dt.governors = fread("united_states_governors.csv")
dt.unemploymentData1 = fread("unemployment_1980-2018.csv")
dt.unemploymentData2 = fread("Unemployment_2012-2020.csv")
dt.education = fread("EducationReport_1970-2019.csv")
dt.poverty = fread("Poverty_1980-2019.csv")
dt.crime = fread("crime_by_state_2001-2017.csv")

###Processed data###

dt.governors= dt.governors[year>=1970,.(year,state,party)]
dt.governors =dt.governors[order(decreasing = T,year),]

dt.unemployment=dt.unemploymentData1
dt.unemployment[,'2019':=dt.unemploymentData2$`2019`[match(Area,dt.unemploymentData2$Name)]]##add 2019 from dt.unemploymentData2
dt.unemployment[,'2020':=dt.unemploymentData2$`2020`[match(Area,dt.unemploymentData2$Name)]]##add 2020 from dt.unemploymentData2
dt.unemployment$Fips=NULL ##delete column Fips
dt.unemployment= data.table(gather(dt.unemployment,year,unemployment_percent,-Area)) #combine multiple columns into a single column (many years to year)

dt.education= data.table(gather(dt.education,year,education_percent,-Name)) #combine multiple columns into a single column (many years to year)

colnames(dt.poverty)<-as.character(dt.poverty[1,]) ##set header first row
dt.poverty<-dt.poverty[-1,] ##remove first row after set to header
dt.poverty= data.table(gather(dt.poverty,year,poverty_percent,-state) )#combine multiple columns into a single column (many years to year)

dt.crime= dt.crime[,.(jurisdiction,year,state_population,violent_crime_total)]
dt.crime[,crime_total_usa:= sum(violent_crime_total),by=year]##calculate the crime_total_usa by year
dt.crime[,crime_total_percent:= violent_crime_total/crime_total_usa*100]##calculate the crime_total_percent

####Handling missing values###
# Checking missing values (missing values or empty values)
print(colSums(is.na(dt.governors)|dt.governors==''))
print(colSums(is.na(dt.education)|dt.education==''))
print(colSums(is.na(dt.unemployment)|dt.unemployment==''))
print(colSums(is.na(dt.poverty)|dt.poverty==''))
print(colSums(is.na(dt.crime)|dt.crime==''))

###Data visualization###

ggplot(dt.unemployment,aes(x=year,y=unemployment_percent,color=factor(Area),group=factor(Area)))+geom_line()
ggplot(dt.poverty,aes(x=year,y=poverty_percent,color=factor(state),group=factor(state)))+geom_line()
ggplot(dt.education,aes(x=year,y=education_percent,color=factor(Name),group=factor(Name)))+geom_line()
ggplot(dt.crime,aes(x=year,y=crime_total_percent,color=factor(jurisdiction),group=factor(jurisdiction)))+geom_line()

###Exploratory data analysis###

dt.unemployment[,'party':=dt.governors$party[match(paste0(Area,year),paste0(dt.governors$state,dt.governors$year))]] ##add party column by year and state from dt.governors 
dt.education[,'party':=dt.governors$party[match(paste0(dt.education$Name,dt.education$year),paste0(dt.governors$state,dt.governors$year))]] ##add party column by year and state from dt.governors
dt.poverty[,'party':=dt.governors$party[match(paste0(dt.poverty$state,dt.poverty$year),paste0(dt.governors$state,dt.governors$year))]] ##add party column by year and state from dt.governors
dt.crime[,'party':= dt.governors$party[match(paste0(jurisdiction,year),paste0(dt.governors$state,dt.governors$year))]] ##add party column by year and state from dt.governors

###Statistical inference###




