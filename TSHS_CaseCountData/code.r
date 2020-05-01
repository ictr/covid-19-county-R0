library("readxl")
my_data = read_excel("Texas COVID-19 Case Count Data by County.xlsx", skip=2, col_names=T, n_max=254)

DATE = paste0("2020",gsub(x=colnames(my_data)[grep(x=colnames(my_data), pattern="Cases")], pattern="Cases \r\n|-", replacement=""))
colnames(my_data)[grep(x=colnames(my_data), pattern="Cases")] = DATE

my_data = my_data[, -2]
colnames(my_data)[1] = "County_Name"
my_data = as.data.frame(my_data)


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
colnames(my_data)[1] = "County_Name"
my_data = as.data.frame(my_data)


library(reshape2)
my_data = melt(my_data)
colnames(my_data)[2:3] = c("date", "fatalities")
write.table(x=my_data, file="covid_19_fatalities.txt", quote=F, sep="\t", row.names=F)
