//
//  WeatherBackground.swift
//  Forepast
//
//  Created by Davis Engeler on 12/13/14.
//  Copyright (c) 2014 Davis Engeler. All rights reserved.
//

import Foundation
import MediaPlayer
import AVFoundation

class WeatherBackground {
    var fileName : String
    var fileType : String
    
    init(fileName : String, fileType : String) {
        self.fileName = fileName
        self.fileType = fileType
    }
    
    func prepareBackground(mainViewController : UIViewController, animated : Bool) -> MPMoviePlayerController {
        // Sets up the object for the background image.
        let fileLocation = NSBundle.mainBundle().pathForResource(self.fileName, ofType: self.fileType)
        var url: NSURL = NSURL(fileURLWithPath: fileLocation!)!
        var backgroundMoviePlayer = MPMoviePlayerController(contentURL: url)
        backgroundMoviePlayer.view.frame = mainViewController.view.frame
        backgroundMoviePlayer.fullscreen = false
        backgroundMoviePlayer.controlStyle = MPMovieControlStyle.None
        backgroundMoviePlayer.repeatMode = MPMovieRepeatMode.One
        backgroundMoviePlayer.scalingMode = MPMovieScalingMode.AspectFill
        backgroundMoviePlayer.allowsAirPlay = false
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error: nil)
        
        backgroundMoviePlayer.view.alpha = 0
        
        println("Background alpha: \(backgroundMoviePlayer.view.alpha)")
        
        return backgroundMoviePlayer
    }
}
