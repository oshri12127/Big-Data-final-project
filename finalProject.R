library(data.table)
library(dplyr)
library(ggplot2)
library(tidyr) 
library(Amelia) # Missing Data: Missings Map
library(mclust)
#install.packages('e1071', dependencies=TRUE)

##Introduction-The Data

dt.governors = fread("united_states_governors.csv")
dt.unemploymentData1 = fread("unemployment_1980-2018.csv")
dt.unemploymentData2 = fread("Unemployment_2012-2020.csv")
dt.poverty = fread("Poverty_1980-2019.csv")
dt.crime = fread("crime_by_state_2001-2017.csv")

###Processed data###

dt.governors = dt.governors[year>=1980,.(year,state,party)]
dt.governors = dt.governors[order(decreasing = T,year),]
# since we want to exam the difference between the largest parties
# we will trim those who aren't relevant 
dt.governors$party[dt.governors$party !='Democrat' & dt.governors$party!='Republican'] = "Other"

dt.unemployment=dt.unemploymentData1
dt.unemployment[,'2019':=dt.unemploymentData2$`2019`[match(Area,dt.unemploymentData2$Name)]]##add 2019 from dt.unemploymentData2
#dt.unemployment[,'2020':=dt.unemploymentData2$`2020`[match(Area,dt.unemploymentData2$Name)]]##add 2020 from dt.unemploymentData2
dt.unemployment$Fips=NULL ##delete column Fips
dt.unemployment= data.table(gather(dt.unemployment,year,unemployment_percent,-Area)) #combine multiple columns into a single column (many years to year)

colnames(dt.poverty) = as.character(dt.poverty[1,]) ##set header first row
dt.poverty = dt.poverty[-1,] ##remove first row after set to header
dt.poverty = data.table(gather(dt.poverty,year,poverty_percent,-state) )#combine multiple columns into a single column (many years to year)

dt.crime = dt.crime[,.(jurisdiction,year,state_population,violent_crime_total)]
dt.crime[,crime_total_usa:= sum(violent_crime_total),by=year]##calculate the crime_total_usa by year
#dt.crime[,crime_total_percent:= violent_crime_total/crime_total_usa*100]##calculate the crime_total_percent
dt.crime[,crime_total_percent:= violent_crime_total/state_population*100]##calculate the crime_total_percent

###Exploratory data analysis###

dt.unemployment[,'party':=dt.governors$party[match(paste0(Area,year),paste0(dt.governors$state,dt.governors$year))]] ##add party column by year and state from dt.governors 
dt.poverty[,'party':=dt.governors$party[match(paste0(dt.poverty$state,dt.poverty$year),paste0(dt.governors$state,dt.governors$year))]] ##add party column by year and state from dt.governors
dt.crime[,'party':= dt.governors$party[match(paste0(jurisdiction,year),paste0(dt.governors$state,dt.governors$year))]] ##add party column by year and state from dt.governors

####Handling missing values###
# Checking missing values (missing values or empty values)
missmap(dt.unemployment)
dt.unemployment = dt.unemployment[!(is.na(dt.unemployment$party)),]
missmap(dt.crime)
dt.crime = dt.crime[!(is.na(dt.crime$party)),]
missmap(dt.poverty)
dt.poverty = dt.poverty[!(is.na(dt.poverty$party)),]

###Data visualization###

ggplot(dt.poverty,aes(x=year,y=poverty_percent,color=factor(party),group=factor(state)))+geom_line(size=1) + scale_colour_manual(values = c("dodgerblue3", "black", "firebrick1"))+facet_wrap(~state)
ggplot(dt.crime,aes(x=year,y=crime_total_percent,color=factor(party),group=factor(jurisdiction)))+geom_line(size=1) + scale_colour_manual(values = c("dodgerblue3", "black", "firebrick1"))+facet_wrap(~jurisdiction) 
ggplot(dt.unemployment,aes(x=year,y=unemployment_percent,color=factor(party),group=factor(Area)))+geom_line(size=2) + scale_colour_manual(values = c("dodgerblue3", "black", "firebrick1"))+facet_wrap(~Area) 

###Statistical inference###

##poverty
dt.poverty[,'delta':=c(-diff(poverty_percent), 0), by = "state"][]
dt.poverty[,'avg_delta':=sum(delta)/.N, by = "year"]
dt.poverty[party=='Democrat', avg_delta_party:=sum(delta)/.N, by = "year"]
dt.poverty[party=='Republican', avg_delta_party:=sum(delta)/.N, by = "year"]

ggplot(data = dt.poverty[year>2000], aes(x=year, y=delta)) + geom_boxplot(aes(fill=party)) + scale_fill_manual(values=c("dodgerblue3","lightgrey","firebrick1")) 
ggplot(data = dt.poverty[year<2000], aes(x=year, y=delta)) + geom_boxplot(aes(fill=party))+ scale_fill_manual(values=c("dodgerblue3","lightgrey","firebrick1"))

dt.povertyAvgDelta = dt.poverty[,.(year, party, avg_delta_party)]
dt.povertyAvgDelta = dt.povertyAvgDelta[!dt.povertyAvgDelta$party=="Other",]
#dt.povertyAvgDelta$avg_delta_party = lapply(dt.povertyAvgDelta$avg_delta_party, signif, 5)
dt.povertyAvgDelta = distinct(dt.povertyAvgDelta, year, party, .keep_all = TRUE)

ggplot(dt.povertyAvgDelta,aes(x=year,y=avg_delta_party,color=factor(party),group=factor(party)))+geom_line() + scale_colour_manual(values = c("dodgerblue3", "firebrick1"))

##crime
dt.crime[,'delta':=c(-0,diff(crime_total_percent)), by = "jurisdiction"][]
dt.crime[,'avg_delta':=sum(delta)/.N, by = "year"]
dt.crime[party=='Democrat', avg_delta_party:=sum(delta)/.N, by = "year"]
dt.crime[party=='Republican', avg_delta_party:=sum(delta)/.N, by = "year"]

ggplot(data = dt.crime, aes(x=year, y=delta)) + geom_boxplot(aes(fill=party)) + scale_fill_manual(values=c("dodgerblue3","lightgrey","firebrick1")) 

dt.crimeAvgDelta = dt.crime[,.(year, party, avg_delta_party)]
dt.crimeAvgDelta = dt.crimeAvgDelta[!dt.crimeAvgDelta$party=="Other",]
#dt.crimeAvgDelta$avg_delta_party = lapply(dt.povertyAvgDelta$avg_delta_party, signif, 5)
dt.crimeAvgDelta = distinct(dt.crimeAvgDelta, year, party, .keep_all = TRUE)

ggplot(dt.crimeAvgDelta,aes(x=year,y=avg_delta_party,color=factor(party),group=factor(party)))+geom_line() + scale_colour_manual(values = c("dodgerblue3", "firebrick1"))

##unemployment
dt.unemployment[,'delta':=c(-0,diff(unemployment_percent)), by = "Area"][]
dt.unemployment[,'avg_delta':=sum(delta)/.N, by = "year"]
dt.unemployment[party=='Democrat', avg_delta_party:=sum(delta)/.N, by = "year"]
dt.unemployment[party=='Republican', avg_delta_party:=sum(delta)/.N, by = "year"]

ggplot(data = dt.unemployment[year>2000], aes(x=year, y=delta)) + geom_boxplot(aes(fill=party)) + scale_fill_manual(values=c("dodgerblue3","lightgrey","firebrick1")) 
ggplot(data = dt.unemployment[year<2000], aes(x=year, y=delta)) + geom_boxplot(aes(fill=party))+ scale_fill_manual(values=c("dodgerblue3","lightgrey","firebrick1"))

dt.unemploymentAvgDelta = dt.unemployment[,.(year, party, avg_delta_party)]
dt.unemploymentAvgDelta = dt.unemploymentAvgDelta[!dt.unemploymentAvgDelta$party=="Other",]
#dt.unemploymentAvgDelta$avg_delta_party = lapply(dt.unemploymentAvgDelta$avg_delta_party, signif, 5)
dt.unemploymentAvgDelta = distinct(dt.unemploymentAvgDelta, year, party, .keep_all = TRUE)

ggplot(dt.unemploymentAvgDelta,aes(x=year,y=avg_delta_party,color=factor(party),group=factor(party)))+geom_line() + scale_colour_manual(values = c("dodgerblue3", "firebrick1"))

# check the trends right after change in government??

###Clustering###
dt.povertyAvgDelta = dt.povertyAvgDelta[!(year == "1980"),]
#dt.povertyAvgDelta$avg_delta_party = as.factor(dt.povertyAvgDelta$avg_delta_party)
k=kmeans(dt.povertyAvgDelta$avg_delta_party,2)
print(k)
print(adjustedRandIndex(k$cluster,dt.povertyAvgDelta$party))
# 0.3711137

#3
pca=prcomp(dt,scale.=T ,center=T)
summary(pca)
screeplot(pca,type = "lines",col=3)
# need 5 dim for 80% variance, the elbow method suggests taking 4 or 5 dims.

