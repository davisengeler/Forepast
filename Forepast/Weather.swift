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
    var currentWeather : CurrentWeather
    var dailyWeather : DailyWeather
    
    init ( weatherInfo : NSDictionary ) {
        self.weatherInfo = weatherInfo
        self.currentWeather = CurrentWeather(currentWeatherInfo: (weatherInfo["currently"] as NSDictionary))
        self.dailyWeather = DailyWeather(dailyWeatherInfo: (weatherInfo["daily"] as NSDictionary))
    }
    
}

class CurrentWeather {
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

class DailyWeather {
    var dailyWeatherInfo : NSDictionary
    var summary : String
    
    init(dailyWeatherInfo: NSDictionary) {
        self.dailyWeatherInfo = dailyWeatherInfo
        self.summary = dailyWeatherInfo["summary"] as String
    }
    
}