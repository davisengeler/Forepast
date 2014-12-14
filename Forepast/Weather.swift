//
//  Weather.swift
//  Forepast
//
//  Created by Davis Engeler on 12/4/14.
//  Copyright (c) 2014 Davis Engeler. All rights reserved.
//

import Foundation

class Weather {
    // Built to accept an NSDictionary built from Forecast.IO API
    var weatherInfo : NSDictionary
    var currentWeather : CurrentlyWeather
    var forecastedWeather : ForecastedWeather
    var minutelyWeather : MinutelyWeather
    var hourlyWeather : HourlyWeather
    
    init ( weatherInfo : NSDictionary ) {
        self.weatherInfo = weatherInfo
        self.currentWeather = CurrentlyWeather(currentWeatherInfo: (weatherInfo["currently"] as NSDictionary))
        self.forecastedWeather = ForecastedWeather(dailyWeatherDictionary: (weatherInfo["daily"] as NSDictionary))
        self.minutelyWeather = MinutelyWeather(minutelyDictionary: (weatherInfo["minutely"] as NSDictionary))
        self.hourlyWeather = HourlyWeather(hourlyDictionary: (weatherInfo["hourly"] as NSDictionary))
    }
}

class CurrentlyWeather {
    var currentWeatherInfo : NSDictionary
    var temperature : Int
    var apparentTemperature : Int
    var humidity : Int
    var summary : String
    var icon : String
    
    init(currentWeatherInfo: NSDictionary) {
        self.currentWeatherInfo = currentWeatherInfo
        self.temperature = Int(round(currentWeatherInfo["temperature"] as Double))
        self.apparentTemperature = Int(round(currentWeatherInfo["apparentTemperature"] as Double))
        self.humidity = Int(currentWeatherInfo["dewPoint"] as Double) * 100
        self.summary = currentWeatherInfo["summary"] as String
        self.icon = currentWeatherInfo["icon"] as String
    }
}

class MinutelyWeather {
    var minuteData : [NSDictionary]
    var icon : String
    var summary : String
    
    init(minutelyDictionary: NSDictionary) {
        self.minuteData = minutelyDictionary["data"] as [NSDictionary]
        self.icon = minutelyDictionary["icon"] as String
        self.summary = minutelyDictionary["summary"] as String
    }
}

class HourlyWeather {
    var hourData : [NSDictionary]
    var icon : String
    var summary : String
    
    init(hourlyDictionary: NSDictionary) {
        self.hourData = hourlyDictionary["data"] as [NSDictionary]
        self.icon = hourlyDictionary["icon"] as String
        self.summary = hourlyDictionary["summary"] as String
    }
}

class ForecastedWeather {
    var summary : String
    var dayInformation : [DayInformation] = []
    
    init(dailyWeatherDictionary: NSDictionary) {
        let dailyData = dailyWeatherDictionary["data"] as [NSDictionary]
        for dayDictionary in dailyData {
            dayInformation.append(DayInformation(dayDictionary: dayDictionary))
        }
        
        self.summary = dailyWeatherDictionary["summary"] as String
    }
}

class DayInformation {
    // Prepares the information for "daily" data points
    var temperatureMax : Float
    var temperatureMin : Float
    var timecode : NSDate
    var summary : String
    var sunriseTime : NSDate
    var sunsetTime : NSDate
    var moonPhase : Float
    var precipProbability : Float
    var precipType : String?
    
    init(dayDictionary: NSDictionary) {
        self.temperatureMax = dayDictionary["temperatureMax"] as Float
        self.temperatureMin = dayDictionary["temperatureMin"] as Float
        self.timecode = NSDate(timeIntervalSince1970: dayDictionary["time"] as NSTimeInterval)
        self.sunriseTime = NSDate(timeIntervalSince1970: dayDictionary["sunriseTime"] as NSTimeInterval)
        self.sunsetTime = NSDate(timeIntervalSince1970: dayDictionary["sunsetTime"] as NSTimeInterval)
        self.moonPhase = dayDictionary["moonPhase"] as Float
        self.precipProbability = dayDictionary["precipProbability"] as Float
        self.precipType = dayDictionary["precipType"] as? String
        self.summary = dayDictionary["summary"] as String
    }
}











