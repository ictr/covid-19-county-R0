rm(list=ls())
library("readxl")
#setwd("/usr/share/httpd/covid-19-county-R0/TSHS_CaseCountData/")
my_data = read_excel("Texas COVID-19 Case Count Data by County.xlsx", skip=2, col_names=T, n_max=254)

library(stringr)
#DATE = paste0("2020",gsub(x=colnames(my_data)[grep(x=colnames(my_data), pattern="Cases")], pattern="Cases\r\n|Cases\r\n\r\n|-", replacement=""))
DATE = paste0("2020",str_match(string=colnames(my_data)[grep(x=colnames(my_data), pattern="Cases")], pattern="(\\d+-\\d+)")[,2])
DATE[301:(ncol(my_data)-1)] = paste0("2021",str_match(string=colnames(my_data[,302:ncol(my_data)])[grep(x=colnames(my_data[,302:ncol(my_data)]), pattern="Cases")], pattern="(\\d+-\\d+)")[,2])
DATE = gsub(x = DATE, pattern = "-", replacement = "")
colnames(my_data)[grep(x=colnames(my_data), pattern="Cases")] = DATE

my_data = my_data[, -2]
colnames(my_data)[1] = "county"
my_data = as.data.frame(my_data)

gap = round((my_data[,311] - my_data[,297])/15)
for(i in 297:ncol(my_data)){
  my_data[,i] = my_data[,i-1] + gap
}

# calculate new daily cases after specified days
selected_date = which(colnames(my_data) == "202101011")
## daily new cases dataframe
if((ncol(my_data)-selected_date) >= 1){
  daily_new_cases = data.frame(matrix(nrow = 254, ncol = (ncol(my_data) - selected_date)))
  colnames(daily_new_cases) = colnames(my_data)[(selected_date+1):ncol(my_data)]
  for(i in 1:(ncol(my_data)-selected_date)){
    daily_new_cases[,i] = my_data[,selected_date+i] - my_data[,selected_date+i-1]
  }
}

# read new county data
new_data = read_excel("DSHS New County Data.xlsx", col_names=T, n_max=9)
new_data_date = seq(20200901,20200930,1)
new_data_date_oct = seq(20201001,20201031,1)
new_data_date_nov = seq(20201101,20201130,1)
new_data_date_dec = seq(20201201,20201231,1)
new_data_date_jan = seq(20210101,20210111,1)
new_data_date = append(new_data_date, new_data_date_oct)
new_data_date = append(new_data_date, new_data_date_nov)
new_data_date = append(new_data_date, new_data_date_dec)
new_data_date = append(new_data_date, new_data_date_jan)
colnames(new_data) = c("county", new_data_date)
new_data = as.data.frame(new_data)


new_data$`20201227` = round((new_data$`20201227`+new_data$`20201228`+new_data$`20201229`+new_data$`20201230`+new_data$`20201231`+
  new_data$`20210101`+new_data$`20210102`+new_data$`20210103`+new_data$`20210104`+new_data$`20210105`+new_data$`20210106`+new_data$`20210107`
  +new_data$`20210108`+new_data$`20210109`+new_data$`20210110`+new_data$`20210111`)/16)
new_data$`20201228` = new_data$`20201227`
new_data$`20201229` = new_data$`20201227`
new_data$`20201230` = new_data$`20201227`
new_data$`20201231` = new_data$`20201227`
new_data$`20210101` = new_data$`20201227`
new_data$`20210102` = new_data$`20201227`
new_data$`20210103` = new_data$`20201227`
new_data$`20210104` = new_data$`20201227`
new_data$`20210105` = new_data$`20201227`
new_data$`20210106` = new_data$`20201227`
new_data$`20210107` = new_data$`20201227`
new_data$`20210108` = new_data$`20201227`
new_data$`20210109` = new_data$`20201227`
new_data$`20210110` = new_data$`20201227`
new_data$`20210111` = new_data$`20201227`

counties = unique(my_data$county)

for(i in 1:length(counties)){
  county = counties[i]
  my_data_county = my_data[which(my_data$county == county),]
  new_data_county = new_data[which(new_data$county == county),]
  if(nrow(new_data_county) == 0){
    next
  } else {
    for(j in 2:ncol(new_data)){
      date = colnames(new_data_county[j])
      current = which(colnames(my_data_county) == date)
      previous = current - 1
      my_data_county[1,current] =  my_data_county[1,previous] + new_data_county[1,j]
    }
  }
  my_data[which(my_data$county == county),] = my_data_county
}

# update data after Nov.2
if((ncol(my_data)-selected_date) >= 1){
  for(i in 1:(ncol(my_data)-selected_date)){
    my_data[,selected_date+i] = my_data[,selected_date+i-1] + daily_new_cases[,i]
  }
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
