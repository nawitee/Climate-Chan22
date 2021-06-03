
temp_country<- data.table::fread("tas_1901_2020_all.csv")
temp_country<- temp_country[,c('V5','V6'):=NULL]
temp_country<-temp_country[,Region:=countrycode(temp_country$Country,origin="country.name",destination = "region")]
temp_country<- temp_country[,Region :=as.factor(Region)]
temp_country<- temp_country[, Statistics := str_sub(Statistics,1,3)]
temp_country<- temp_country[, Statistics := match(Statistics,month.abb)]
setnames(temp_country, c("Temperature - (Celsius)","Statistics"),c("AverageTemperature", "Month"))
temp_country1<- temp_country %>% filter(Year>=1950 & Year<=1980) %>% select(Year,Month,Country,Region,AverageTemperature)
temp_country2<- temp_country1 %>% group_by(Month,Country) %>% summarise(month_mean=mean(AverageTemperature))
temp_country3<- left_join(temp_country,temp_country2, by= c('Country','Month'))
temp_countryF<- temp_country3 %>% mutate(AnomalyTemp=AverageTemperature-month_mean) %>% select(Country, Region,Year,Month,AnomalyTemp)
temp_countryF_1<- temp_countryF[,pos := AnomalyTemp>=0]
temp_countryF_2<-temp_countryF_1 %>% group_by(Year,Country) %>% summarise(mean(AnomalyTemp))
temp_countryF_2<- temp_countryF_2 %>% rename(AnomalyTemp ='mean(AnomalyTemp)')
temp_countryF_2<- as.data.table(temp_countryF_2)
temp_countryF_3<-temp_countryF_2[,Countrycode:=countrycode(temp_countryF_2$Country,origin="country.name",destination = "iso2c")]
world_spdf<- readOGR(dsn=getwd(),
                     layer="TM_WORLD_BORDERS_SIMPL-0.3",
                     verbose= FALSE)


save.image("map.RData")

anom_region<- temp_countryF[,. (mean(AnomalyTemp)),by=.(Year,Month,Region)]
anom_region1<- anom_region[,.(mean(V1)),by=.(Year,Region)]
anom_region1<- setnames(anom_region1,"V1","AnomalyTemp")
anom_region1<- anom_region1[,pos := AnomalyTemp>=0]
save.image("temperature.RData")
