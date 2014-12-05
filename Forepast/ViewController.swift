//
//  ViewController.swift
//  Forepast
//
//  Created by Davis Engeler on 12/1/14.
//  Copyright (c) 2014 Davis Engeler. All rights reserved.
//

import UIKit
import CoreLocation
import MediaPlayer

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var currentSummaryLabel: UILabel!
    var moviePlayer: MPMoviePlayerController!
    lazy var data = NSMutableData()
    var locationManager:CLLocationManager!
    var geocoder:CLGeocoder!
    @IBOutlet weak var tempLabel: UILabel!
    var lastWeatherInfoUpdate : Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let fileLocation = NSBundle.mainBundle().pathForResource("Night-Cloud-Loop-Blur", ofType: "mov")
        var url: NSURL = NSURL(fileURLWithPath: fileLocation!)!
        moviePlayer = MPMoviePlayerController(contentURL: url)
        moviePlayer.view.frame = self.view.frame
        self.view.addSubview(moviePlayer.view)
        moviePlayer.fullscreen = false
        moviePlayer.controlStyle = MPMovieControlStyle.None
        moviePlayer.repeatMode = MPMovieRepeatMode.One
        moviePlayer.scalingMode = MPMovieScalingMode.AspectFill
        self.view.sendSubviewToBack(moviePlayer.view)
        
        println(moviePlayer)
        
        lastWeatherInfoUpdate = 60
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        println("Started updating location")
    }
    
    override func viewDidLayoutSubviews() {
        if moviePlayer != nil {
            moviePlayer.play()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        // Won't update the weather info from the API if the information is less than a minute old
        if (newLocation.horizontalAccuracy < 150) {
            manager.stopUpdatingLocation()
            locationManager.stopUpdatingLocation()
            if (Int(newLocation.timestamp.timeIntervalSinceReferenceDate) - lastWeatherInfoUpdate) > 60
            {
                updateWeatherInformation(newLocation)
            }
        }
        
        //        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {
        //
        //            (placemarks, error)->Void in
        //
        //            if (error != nil) {
        //                println("Reverse geocoder failed with error" + error.localizedDescription)
        //                return
        //            }
        //
        //            if placemarks.count > 0 {
        //                let pm = placemarks[0] as CLPlacemark
        //                let areaOfInterest : NSString = pm.areasOfInterest[0] as NSString
        //
        //                self.myTextView.text = pm.locality + ", " + pm.subLocality + ": " + areaOfInterest
        //            } else {
        //                println("Problem with the data received from geocoder")
        //            }
        //            
        //        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateWeatherInformation(location : CLLocation)
    {
        let apiKey = "f0d31603b3649790242ecfb628ebe33c"
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let urlPath = "https://api.forecast.io/forecast/\(apiKey)/\(latitude),\(longitude)"
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        lastWeatherInfoUpdate = Int(location.timestamp.timeIntervalSinceReferenceDate)
        connection.start()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data.setData(data)
        self.decodeJSON(connection)
    }
    
    func decodeJSON(connection: NSURLConnection) {
        var err = NSErrorPointer()
        
        if let jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: err) {
            if let weatherJSON = jsonResult as? NSDictionary {
//                let currentConditions = weather["currently"] as NSDictionary
//                let currentTemp: Int = Int(round(currentConditions["temperature"] as Double))
//                let currentSummary = currentConditions["summary"] as String
//                let currentFeelsLike = currentConditions["apparentTemperature"] as Double
                let weather = Weather(weatherInfo: weatherJSON)
                currentSummaryLabel.text = weather.currentWeather.summary
                tempLabel.text = "\(weather.currentWeather.temperature)º"
                println("Updated the weather information")
            }
            else {
                println("Failed to get information. Trying again.")
                lastWeatherInfoUpdate = 60
                locationManager.startUpdatingLocation()
            }
        } else {
            println("Failed to get information. Trying again.")
            lastWeatherInfoUpdate = 60
            locationManager.startUpdatingLocation()
        }
        
    }
}

