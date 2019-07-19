#read data in

ticks<-read.csv("data/Tick_collection_data.csv", header=T, na.strings="NA")
researchers<-read.csv("data/Tick_collection_data_researchers.csv", header=T, na.strings="NA")
weather<-read.csv("data/tick_weather.csv", header=T, na.strings="NA")
#we're going to estimate the temperature during the sample time period from the daily max min

#to do this, we'll have to pull max mins from the prism database and then interpolate with chillR

library(prism)
library(chillR)
library(lubridate)

#first convert date format
ticks$ISODate<-mdy(ticks$Date)
researchers$ISODate<-mdy(researchers$Date)
weather$ISODate<-mdy(weather$Date)

weather$Year<-year(weather$ISODate)
weather$Month<-month(weather$ISODate)
weather$Day<-mday(weather$ISODate)

weather_standingrock<-weather[which(weather$WeatherStation=="KentStandingRock"),]
weather_fieldstone<-weather[which(weather$WeatherStation=="Fieldstone"),]
weather_CVNPhudson<-weather[which(weather$WeatherStation=="CVNPHudson"),]

hourly_weather_standingrock<-make_all_day_table(weather_standingrock)
hourtemps_standingrock<-stack_hourly_temps(hourly_weather_standingrock, latitude=41.2)$hourtemps
hourtemps_standingrock$Date<-ISOdate(hourtemps_standingrock$Year,
                                     hourtemps_standingrock$Month,
                                     hourtemps_standingrock$Day,
                                     hourtemps_standingrock$Hour)

hourly_weather_fieldstone<-make_all_day_table(weather_fieldstone)
hourtemps_fieldstone<-stack_hourly_temps(hourly_weather_fieldstone, latitude=41.2)$hourtemps
hourtemps_fieldstone$Date<-ISOdate(hourtemps_fieldstone$Year,
                                     hourtemps_fieldstone$Month,
                                     hourtemps_fieldstone$Day,
                                     hourtemps_fieldstone$Hour)

hourly_weather_CVNPhudson<-make_all_day_table(weather_CVNPhudson)
hourtemps_CVNPhudson<-stack_hourly_temps(hourly_weather_CVNPhudson, latitude=41.2)$hourtemps
hourtemps_CVNPhudson$Date<-ISOdate(hourtemps_CVNPhudson$Year,
                                   hourtemps_CVNPhudson$Month,
                                   hourtemps_CVNPhudson$Day,
                                   hourtemps_CVNPhudson$Hour)

hourly_weather<-rbind(hourtemps_standingrock, hourtemps_fieldstone, hourtemps_CVNPhudson)

write.csv(hourly_weather, file="interpolated_weather.csv")

plot(hourtemps_CVNPhudson$Temp~hourtemps_CVNPhudson$Date,type="l",col="red",lwd=3,
     xlab="Date",ylab="Temperature (°C)",xaxs="i")
