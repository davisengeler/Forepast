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
    var moviePlayer : MPMoviePlayerController!
    var locationManager : CLLocationManager!
    var lastLocation : CLLocation!
    var geocoder : CLGeocoder!
    var lastWeatherInfoUpdate : Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // THIS IS JUST TO TEST DIFFERENT BACKGROUND LOOPS
        var videoBackgroundName : String!
        var alphaValue : CGFloat!
        let rand = arc4random_uniform(10) % 2
        if rand == 0 {
            println(rand)
            videoBackgroundName = "Night-Cloud-Loop-Blur"
            alphaValue = 1.0
            
        } else {
            println(rand)
            videoBackgroundName = "tree-sun-loop"
            alphaValue = 0.7
        }
        // -------------
        
        // Sets up the object for the background image.
        let fileLocation = NSBundle.mainBundle().pathForResource(videoBackgroundName, ofType: "mov")
        var url: NSURL = NSURL(fileURLWithPath: fileLocation!)!
        moviePlayer = MPMoviePlayerController(contentURL: url)
        moviePlayer.view.frame = self.view.frame
        self.view.addSubview(moviePlayer.view)
        moviePlayer.fullscreen = false
        moviePlayer.controlStyle = MPMovieControlStyle.None
        moviePlayer.repeatMode = MPMovieRepeatMode.One
        moviePlayer.scalingMode = MPMovieScalingMode.AspectFill
        moviePlayer.allowsAirPlay = false
        moviePlayer.view.alpha = alphaValue
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error: nil)
        self.view.sendSubviewToBack(moviePlayer.view)
        
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
        if moviePlayer != nil && moviePlayer.currentPlaybackRate == 0.0 {
            moviePlayer.play()
            locationManager.startUpdatingLocation()
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        let fromInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        if !(fromInterfaceOrientation.isLandscape && toInterfaceOrientation.isLandscape) {
            UIView.animateWithDuration(duration, animations: {
                let newFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.height, self.view.frame.width)
                self.moviePlayer.view.frame = newFrame
            })
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        // Won't update the weather info from the API if the information is less than a minute old
        println("Found a new location. \(lastWeatherInfoUpdate)")
        lastLocation = newLocation
        if (newLocation.horizontalAccuracy < 150) ||  (Int(newLocation.timestamp.timeIntervalSinceReferenceDate) - lastWeatherInfoUpdate) > 15 {
            locationManager.stopUpdatingLocation()
            if (Int(newLocation.timestamp.timeIntervalSinceReferenceDate) - lastWeatherInfoUpdate) > 60
            {
                println("\(newLocation.horizontalAccuracy): \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
                getWeatherInformation(newLocation)
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
                currentSummaryLabel.text = "Currently \(weather.currentWeather.summary.lowercaseString). \(weather.dailyWeather.summary)"
                println("Updated the weather information")
                println("Summary: \(weather.dailyWeather.summary)")
            }
            else {
                println("Failed to get information. Trying again: ")
                print(err)
                lastWeatherInfoUpdate = 60
                getWeatherInformation(lastLocation)
                locationManager.startUpdatingLocation()
            }
        } else {
            println("Failed to get information. Trying again: ")
            print(err)
            lastWeatherInfoUpdate = 60
            getWeatherInformation(lastLocation)
            locationManager.startUpdatingLocation()
        }
        
    }
}

