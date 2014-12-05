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
    
    init ( weatherInfo : NSDictionary ) {
        self.weatherInfo = weatherInfo
        self.currentWeather = CurrentWeather(currentWeatherInfo: (weatherInfo["currently"] as NSDictionary))
    }
    
}