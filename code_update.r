rm(list=ls())
library("readxl")
#setwd("/usr/share/httpd/covid-19-county-R0/TSHS_CaseCountData/")
my_data = read_excel("Texas COVID-19 New Confirmed Cases by County.xlsx", skip=2, col_names=T, n_max=254)

#my_data$`New Cases 2020-12-28` = round((my_data$`New Cases 2020-12-28` + my_data$`New Cases 2020-12-29` +
#  my_data$`New Cases 2020-12-30` + my_data$`New Cases 2020-12-31` + my_data$`New Cases 2021-01-01` +
#  my_data$`New Cases 2021-01-02` + my_data$`New Cases 2021-01-03` + my_data$`New Cases 2020-12-27` + 
#  my_data$`New Cases 2020-12-26` + my_data$`New Cases 2020-12-25` + my_data$`New Cases 2020-12-24` +
#  my_data$`New Cases 2020-12-23` + my_data$`New Cases 2020-12-22` + my_data$`New Cases 2020-12-21`) / 14)
my_data$`New Cases 2020-12-28` = round((my_data$`New Cases 2020-12-28` + my_data$`New Cases 2020-12-29` + 
  my_data$`New Cases 2020-12-30` + my_data$`New Cases 2020-12-31` + my_data$`New Cases 2021-01-01` +
  my_data$`New Cases 2021-01-02` + my_data$`New Cases 2021-01-03`)/8)
my_data$`New Cases 2020-12-29` = my_data$`New Cases 2020-12-28`
my_data$`New Cases 2020-12-30` = my_data$`New Cases 2020-12-28`
my_data$`New Cases 2020-12-31` = my_data$`New Cases 2020-12-28`
my_data$`New Cases 2021-01-01` = my_data$`New Cases 2020-12-28`
my_data$`New Cases 2021-01-02` = my_data$`New Cases 2020-12-28`
my_data$`New Cases 2021-01-03` = my_data$`New Cases 2020-12-28`
  
library(stringr)
final_data = data.frame(matrix(nrow = 254, ncol = ncol(my_data)))
DATE = str_match(string=colnames(my_data)[grep(x=colnames(my_data), pattern="New Cases")], pattern="(\\d+-\\d+-\\d+)")[,2]
DATE = gsub(x = DATE, pattern = "-", replacement = "")
colnames(final_data) = c("county", DATE)

final_data$county = my_data$County
final_data$`20200304` = my_data$`New Cases 2020-03-04`

for(i in 3:ncol(final_data)){
  final_data[,i] = final_data[,i-1] + my_data[,i]
}

library(reshape2)
final_data = melt(final_data)
colnames(final_data)[2:3] = c("date", "positive")

write.table(x=final_data, file="covid_19_positive.txt", quote=F, sep="\t", row.names=F)
