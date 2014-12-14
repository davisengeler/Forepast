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
import AVFoundation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var currentSummaryLabel: UILabel!
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var tempLabel : UILabel!
    lazy var data = NSMutableData()
    var currentBackground : MPMoviePlayerController!
    var locationManager : CLLocationManager!
    var lastLocation : CLLocation!
    var geocoder : CLGeocoder!
    var lastWeatherInfoUpdate : Int!
    var firstUpdate = true

    @IBAction func sendViewToBack(sender: AnyObject) {
        let rainBackground = WeatherBackground(fileName: "rain", fileType: "mov")
        let sunBackground = WeatherBackground(fileName: "tree-sun-loop", fileType: "mov")
        let cloudyNightBackground = WeatherBackground(fileName: "cloudy-night", fileType: "mp4")
        
        
        var newBackground : MPMoviePlayerController
        
        switch "something" {
            case "clear-day", "clear-night":
                newBackground = sunBackground.prepareBackground(self, animated: firstUpdate)
            case "overcast-day", "overcast-night":
                newBackground = cloudyNightBackground.prepareBackground(self, animated: firstUpdate)
            default:
                newBackground = rainBackground.prepareBackground(self, animated: firstUpdate)
        }
        
        let oldBackground = currentBackground
        
        self.view.insertSubview(newBackground.view, aboveSubview: oldBackground.view)
        UIView.animateWithDuration(4 as NSTimeInterval, animations: {
            newBackground.view.alpha = 1
            }, completion: {
                finished in
                if finished {
                    oldBackground.view.removeFromSuperview()
                    println(self.view.subviews.count)
                }
        })
        
        currentBackground = newBackground
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tempLabel.alpha = 0
        self.currentSummaryLabel.alpha = 0
        
        // Hides the test scroll view on the bottom
        bottomScrollView.alpha = 0
        
        // JUST TO TEST DIFFERENT BACKGROUND LOOPS
        var videoBackgroundName : String!
        var alphaValue : CGFloat!
        videoBackgroundName = "rain"
        alphaValue = 1.0
//        let rand = arc4random_uniform(10) % 2
//        if rand == 0 {
//            println(rand)
//            videoBackgroundName = "rain"
//            alphaValue = 1.0
//            
//        } else {
//            println(rand)
//            videoBackgroundName = "tree-sun-loop"
//            alphaValue = 0.7
//        }
        // -------------
        
        
        // Get the location and update the weather information
        lastWeatherInfoUpdate = 60
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.startUpdatingLocation()
        println("Started updating location")
        
        bottomScrollView.contentSize = CGSizeMake(1225.0, 128.0)
    }
    
    override func viewDidLayoutSubviews() {
        if currentBackground != nil && currentBackground.currentPlaybackRate == 0.0 {
            currentBackground.play()
            locationManager.startUpdatingLocation()
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        let fromInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        if !(fromInterfaceOrientation.isLandscape && toInterfaceOrientation.isLandscape) {
            UIView.animateWithDuration(duration, animations: {
                let newFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.height, self.view.frame.width)
                self.currentBackground.view.frame = newFrame
            })
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        // Won't update the weather info from the API if the information is less than a minute old
        println("Found a new location. \(newLocation.horizontalAccuracy)")
        lastLocation = newLocation
        if (newLocation.horizontalAccuracy < 150) ||  (Int(newLocation.timestamp.timeIntervalSinceReferenceDate) - lastWeatherInfoUpdate) > 15 {
            locationManager.stopUpdatingLocation()
            if (Int(newLocation.timestamp.timeIntervalSinceReferenceDate) - lastWeatherInfoUpdate) > 60
            {
                println("\(newLocation.horizontalAccuracy): \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
                getWeatherInformation(newLocation)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWeatherInformation(location : CLLocation)
    {
        let apiKey = "f0d31603b3649790242ecfb628ebe33c"
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let urlPath = "https://api.forecast.io/forecast/\(apiKey)/\(latitude),\(longitude)"
        println(urlPath)
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
                let weather = Weather(weatherInfo: weatherJSON)
                currentSummaryLabel.text = weather.currentWeather.summary
                tempLabel.text = "\(weather.currentWeather.temperature)º"
                currentSummaryLabel.text = weather.minutelyWeather.summary
                
                
                // TODO: Put the stuff to get the background ready here...
                let rainBackground = WeatherBackground(fileName: "rain", fileType: "mov")
                let sunBackground = WeatherBackground(fileName: "tree-sun-loop", fileType: "mov")
                let cloudyNightBackground = WeatherBackground(fileName: "cloudy-night", fileType: "mp4")
                
                
                var newBackground : MPMoviePlayerController
                
                switch weather.currentWeather.icon {
                    case "clear-day", "clear-night":
                        newBackground = sunBackground.prepareBackground(self, animated: firstUpdate)
                    case "overcast-day", "overcast-night":
                        newBackground = cloudyNightBackground.prepareBackground(self, animated: firstUpdate)
                    default:
                        newBackground = rainBackground.prepareBackground(self, animated: firstUpdate)
                }
                
                if let oldBackground = currentBackground {
                    self.view.insertSubview(newBackground.view, belowSubview: oldBackground.view)
                    newBackground.view.alpha = 1
                    UIView.animateWithDuration(1.5 as NSTimeInterval, animations: {
                            oldBackground.view.removeFromSuperview()
                    })
                } else {
                    self.view.addSubview(newBackground.view)
                    self.view.sendSubviewToBack(newBackground.view)
                        UIView.animateWithDuration(1.5 as NSTimeInterval, animations: {
                        newBackground.view.alpha = 1
                        self.tempLabel.alpha = 1
                        self.currentSummaryLabel.alpha = 1
                        self.view.backgroundColor = UIColor.blackColor()
                    })
                    firstUpdate = false
                }
                currentBackground = newBackground
            }
            else {
                retryUpdatingWeather()
            }
        } else {
            retryUpdatingWeather()
        }
        
    }
    
    func removeASubview (subview : UIView) {
        subview.removeFromSuperview()
    }
    
    func retryUpdatingWeather() {
        println("Failed to get information. Trying again: ")
        lastWeatherInfoUpdate = 60
        getWeatherInformation(lastLocation)
        locationManager.startUpdatingLocation()
    }
}

