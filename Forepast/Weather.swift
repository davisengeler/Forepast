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
    
    init ( weatherInfo : NSDictionary ) {
        self.weatherInfo = weatherInfo
        self.currentWeather = CurrentlyWeather(currentWeatherInfo: (weatherInfo["currently"] as NSDictionary))
        self.forecastedWeather = ForecastedWeather(dailyWeatherDictionary: (weatherInfo["daily"] as NSDictionary))
        self.minutelyWeather = MinutelyWeather(minutelyDictionary: (weatherInfo["minutely"] as NSDictionary))
    }
}

class CurrentlyWeather {
    var currentWeatherInfo : NSDictionary
    var temperature : Int
    var apparentTemperature : Int
    var humidity : Int
    var summary : String
    
    init(currentWeatherInfo: NSDictionary) {
        self.currentWeatherInfo = currentWeatherInfo
        self.temperature = Int(round(currentWeatherInfo["temperature"] as Double))
        self.apparentTemperature = Int(round(currentWeatherInfo["apparentTemperature"] as Double))
        self.humidity = Int(currentWeatherInfo["dewPoint"] as Double) * 100
        self.summary = currentWeatherInfo["summary"] as String
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

class ForecastedWeather {
    var dailyData : [NSDictionary]
    var summary : String
    
    init(dailyWeatherDictionary: NSDictionary) {
        self.dailyData = dailyWeatherDictionary["data"] as [NSDictionary]
        self.summary = dailyWeatherDictionary["summary"] as String
    }
}