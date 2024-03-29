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
    
    enum TimeOfDay {
        case Morning; case MidDay; case Afternoon; case Evening; case Night; case Other;
    }
    
    func timeOfDay() -> TimeOfDay {
        var timeOfDay: TimeOfDay
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        var hour = components.hour
        
        if (7 <= hour && hour < 9) {
            return TimeOfDay.Morning
        } else if (9 <= hour && hour < 12) {
            return TimeOfDay.MidDay
        } else if (12 <= hour && hour < 18) {
            return TimeOfDay.Afternoon
        } else if (18 <= hour && hour < 20) {
            return TimeOfDay.Evening
        } else if (20 <= hour || hour < 7) {
            return TimeOfDay.Night
        }
        else {
            return TimeOfDay.Other
        }
    }
    
    func screenEdgePanGestureAction(sender: AnyObject) {
        println("Started to swipe in")
        if sender.state == UIGestureRecognizerState.Began {
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            UIView.animateWithDuration(0.04, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                var currentFrame = self.currentBackground.view.frame
                currentFrame.origin.x = sender.locationInView(self.view).x
                self.currentBackground.view.frame = currentFrame
            }, completion: nil)
        } else if sender.state == UIGestureRecognizerState.Ended {
            if (sender.locationInView(self.view).x >= (self.view.frame.width / 2))
            {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    self.currentBackground.view.frame.origin.x = (self.view.frame.width - 10)
                    }, completion: nil)
            } else {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    self.currentBackground.view.frame.origin.x = 0
                    }, completion: nil)
            }
        }
    }

    @IBAction func sendViewToBack(sender: AnyObject) {
        // TODO: Put the stuff to get the background ready here...rotat
        let rainBackground = WeatherBackground(fileName: "rain", fileExtension: "mov", hasVideo: true)
        let sunBackground = WeatherBackground(fileName: "tree-sun-loop", fileExtension: "mov", hasVideo: true)
        let cloudyNightBackground = WeatherBackground(fileName: "cloudy-night", fileExtension: "mp4", hasVideo: true)
        let clearBackground = WeatherBackground(fileName: "launch", fileExtension: "png", hasVideo: true)
        let partyCloudyBackground = WeatherBackground(fileName: "partly-cloudy", fileExtension: "jpg", hasVideo: false)
        
        
        var background: MPMoviePlayerController?
        
        switch "overcast-day" {
        case "clear-day", "clear-night":
            background = sunBackground.prepareBackground(self)
        case "overcast-day", "overcast-night":
            background = partyCloudyBackground.prepareBackground(self)
        default:
            background = rainBackground.prepareBackground(self)
        }
        
        if self.currentBackground != nil
        {
            UIView.animateWithDuration(1.5, animations: { () -> Void in
                self.currentBackground.view.alpha = 0
                background!.view.alpha = 0;
                self.view.addSubview(background!.view)
                self.view.sendSubviewToBack(background!.view)
                })
            
            self.currentBackground = background;
            self.currentBackground.play()
        }
        else {
            self.currentBackground = background;
            self.currentBackground.view.alpha = 0;
            self.view.addSubview(self.currentBackground.view)
            self.view.sendSubviewToBack(self.currentBackground.view)
            self.currentBackground.play()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var screenEdgePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "screenEdgePanGestureAction:")
        screenEdgePanGestureRecognizer.minimumNumberOfTouches = 1
        self.view.addGestureRecognizer(screenEdgePanGestureRecognizer)
        
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
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerLoadStateDidChange:", name: MPMoviePlayerNowPlayingMovieDidChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerNowPlayingMovieDidChangeNotification, object: nil)
    }
    
    
    func moviePlayerLoadStateDidChange(notification : NSNotification)
    {
        UIView.animateWithDuration(1.5 as NSTimeInterval, animations: {
            self.currentBackground.view.alpha = 0.8
        })
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
                let rain_Background = WeatherBackground(fileName: "rain", fileExtension: "mov", hasVideo: true)
                let sun_Background = WeatherBackground(fileName: "tree-sun-loop", fileExtension: "mov", hasVideo: true)
                let cloudy_night_Background = WeatherBackground(fileName: "cloudy-night", fileExtension: "mp4", hasVideo: true)
                let clear_day_Background = WeatherBackground(fileName: "partly-cloudy", fileExtension: "jpg", hasVideo: false)
                let clear_night_Background = WeatherBackground(fileName: "clear-night", fileExtension: "jpg", hasVideo: false)
                let overcast_day_Background = WeatherBackground(fileName: "overcast", fileExtension: "jpg", hasVideo: false)
                let clear_evening_Background = WeatherBackground(fileName: "clear-evening", fileExtension: "jpg", hasVideo: false)
                
                var background: MPMoviePlayerController?
                
                switch weather.currentWeather.icon {
                case "clear-day":
                    if (timeOfDay() == TimeOfDay.Evening) {
                        background = clear_evening_Background.prepareBackground(self)
                    } else {
                        background = clear_day_Background.prepareBackground(self)
                    }
                case "clear-night":
                    if (timeOfDay() == TimeOfDay.Evening) {
                        background = clear_evening_Background.prepareBackground(self)
                    } else {
                        background = clear_night_Background.prepareBackground(self)
                    }
                case "rain":
                    background = rain_Background.prepareBackground(self)
                case "wind":
                    if (timeOfDay() == TimeOfDay.Night) {
                        background = cloudy_night_Background.prepareBackground(self)
                    } else {
                        background = sun_Background.prepareBackground(self)
                    }
                case "partly-cloudy-night":
                    background = cloudy_night_Background.prepareBackground(self)
                case "partly-cloudy-day":
                    background = overcast_day_Background.prepareBackground(self)
                default:
                    background = rain_Background.prepareBackground(self)
                    println("No valid backgrounds found, using the rain one since it looks good.")
                }
                
                if self.currentBackground != nil
                {
                    background!.view.alpha = 0;
                    self.view.addSubview(background!.view)
                    self.view.sendSubviewToBack(background!.view)
                    
                    UIView.animateWithDuration(1.5, animations: { () -> Void in
                        self.currentBackground.view.alpha = 0
                    })
                    
                    self.currentBackground = background;
                    self.currentBackground.play()
                }
                else {
                    self.currentBackground = background;
                    self.currentBackground.view.alpha = 0;
                    self.view.addSubview(self.currentBackground.view)
                    self.view.sendSubviewToBack(self.currentBackground.view)
                    self.currentBackground.play()
                    
                    UIView.animateWithDuration(1.5 as NSTimeInterval, animations: {
                        self.tempLabel.alpha = 1
                        self.currentSummaryLabel.alpha = 1
                        self.view.backgroundColor = UIColor.blackColor()
                    })
                }
            }
            else {
                retryUpdatingWeather()
            }
        } else {
            retryUpdatingWeather()
        }
        
    }
    
    
    func retryUpdatingWeather() {
        println("Failed to get information. Trying again: ")
        lastWeatherInfoUpdate = 60
        getWeatherInformation(lastLocation)
        locationManager.startUpdatingLocation()
    }
}

