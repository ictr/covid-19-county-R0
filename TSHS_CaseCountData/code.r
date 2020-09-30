rm(list=ls())
library("readxl")
#setwd("/usr/share/httpd/covid-19-county-R0/TSHS_CaseCountData/")
my_data = read_excel("Texas COVID-19 Case Count Data by County.xlsx", skip=2, col_names=T, n_max=254)

library(stringr)
#DATE = paste0("2020",gsub(x=colnames(my_data)[grep(x=colnames(my_data), pattern="Cases")], pattern="Cases\r\n|Cases\r\n\r\n|-", replacement=""))
DATE = paste0("2020",str_match(string=colnames(my_data)[grep(x=colnames(my_data), pattern="Cases")], pattern="(\\d+-\\d+)")[,2])
DATE = gsub(x = DATE, pattern = "-", replacement = "")
colnames(my_data)[grep(x=colnames(my_data), pattern="Cases")] = DATE

my_data = my_data[, -2]
colnames(my_data)[1] = "county"
my_data = as.data.frame(my_data)

# read new county data
new_data = read_excel("DSHS New County Data.xlsx", col_names=T, n_max=9)
new_data_date = seq(20200901,20200929,1)
colnames(new_data) = c("county", new_data_date)
new_data = as.data.frame(new_data)

counties = unique(my_data$county)

my_data$`20200929` = my_data$`20200928`

for(i in 1:length(counties)){
  county = counties[i]
  my_data_county = my_data[which(my_data$county == county),]
  new_data_county = new_data[which(new_data$county == county),]
  if(nrow(new_data_county) == 0){
    next
  } else {
    for(j in 2:29){
      date = colnames(new_data_county[j])
      current = which(colnames(my_data_county) == date)
      previous = current - 1
      my_data_county[1,current] =  my_data_county[1,previous] + new_data_county[1,j]
    }
    my_data_county$`20200929` = my_data_county$`20200928` + new_data_county[1,30]
  }
  my_data[which(my_data$county == county),] = my_data_county
}

library(reshape2)
my_data = melt(my_data)
colnames(my_data)[2:3] = c("date", "positive")

write.table(x=my_data, file="covid_19_positive.txt", quote=F, sep="\t", row.names=F)

###
library("readxl")
my_data = read_excel("Texas COVID-19 Case Count Data by County.xlsx", skip=2, col_names=T, n_max=254)

DATE = paste0("2020",gsub(x=colnames(my_data)[grep(x=colnames(my_data), pattern="Fatalities")], pattern="Fatalities.?\r\n|-", replacement=""))
colnames(my_data)[grep(x=colnames(my_data), pattern="Fatalities")] = DATE

my_data = my_data[, -2]
colnames(my_data)[1] = "county"
my_data = as.data.frame(my_data)


library(reshape2)
my_data = melt(my_data)
colnames(my_data)[2:3] = c("date", "fatalities")
write.table(x=my_data, file="covid_19_fatalities.txt", quote=F, sep="\t", row.names=F)
