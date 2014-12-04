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
    var moviePlayer:MPMoviePlayerController!
    lazy var data = NSMutableData()
    var locationManager:CLLocationManager!
    var geocoder:CLGeocoder!
    @IBOutlet weak var tempLabel: UILabel!

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
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject])
    {
        let lastElement = locations.count - 1
        let lastLocation: CLLocation = locations[lastElement] as CLLocation
        
        println(lastLocation.horizontalAccuracy)
        if (lastLocation.horizontalAccuracy < 100)
        {
            locationManager.stopUpdatingLocation()
            println("Found accurate location. I'll stop updating it now.")
            locationManager.startMonitoringSignificantLocationChanges()
            println("Monitoring for significant changes.")
            updateWeatherInformation(lastLocation)
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
        println("\(urlPath)")
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        connection.start()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data.setData(data)
        self.decodeJSON(connection)
    }
    
    func decodeJSON(connection: NSURLConnection) {
        var err = NSErrorPointer()
        
        if let jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: err) {
            if let weather = jsonResult as? NSDictionary
            {
                let currentConditions = weather["currently"] as NSDictionary
                let currentTemp: Int = Int(round(currentConditions["temperature"] as Double))
                let currentSummary = currentConditions["summary"] as String
                let currentFeelsLike = currentConditions["apparentTemperature"] as Double
                
                tempLabel.text = "\(currentTemp)º"
            }
            else
            {
                println("Had to start updating location again.")
                locationManager.startUpdatingLocation()
            }
        }
        
    }



}

