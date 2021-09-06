
library(data.table)
library(dplyr)
library(ggplot2)

dt.president = fread("1976-2020-president.csv")
dt.education = fread("EducationReport.csv")
dt.mortality = fread("US county-level mortality.csv")
dt.unemployment = fread("UnemploymentReport.csv")