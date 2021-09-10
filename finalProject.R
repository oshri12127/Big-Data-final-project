
library(data.table)
library(dplyr)
library(ggplot2)

dt.governors = fread("united_states_governors.csv")

dt.governors= dt.governors[year>=1970,.(year,state,party)]
dt.governors =dt.governors[order(decreasing = T,year),]