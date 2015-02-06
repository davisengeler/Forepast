//
//  WeatherBackground.swift
//  Forepast
//
//  Created by Davis Engeler on 12/13/14.
//  Copyright (c) 2014 Davis Engeler. All rights reserved.
//

// Move to a function in ViewController.swift

import Foundation
import MediaPlayer
import AVFoundation

class WeatherBackground {
    var fileName : String
    var fileExtension : String
    var hasVideo : Bool
    
    init(fileName : String, fileExtension : String, hasVideo : Bool) {
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.hasVideo = hasVideo
    }
    
    func prepareBackground(mainViewController : UIViewController) -> MPMoviePlayerController {
        // We don't want the videos to interrupt music playing on the devices
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error: nil)
        
        // All of these will be returning an MPMoviePlayerController, so let's set it up
        var backgroundMoviePlayer = MPMoviePlayerController()
        
        if (hasVideo) {
            // The background requested does have an associated video background, let's the file ready.
            let fileLocation = NSBundle.mainBundle().pathForResource(self.fileName, ofType: self.fileExtension)
            var url: NSURL = NSURL(fileURLWithPath: fileLocation!)!
            backgroundMoviePlayer = MPMoviePlayerController(contentURL: url)
            backgroundMoviePlayer.movieSourceType = MPMovieSourceType.File
            backgroundMoviePlayer.repeatMode = MPMovieRepeatMode.One
            
        } else {
            // The background requested does NOT yet have an associated video background. 
            // Let's prepare it without a video file and overlay the placeholder image.
            let image = UIImage(named: fileName + "." + fileExtension);
            var backgroundImage = UIImageView(image: image)
            
            // Let's also prepare a placeholder video clip.
            let fileLocation = NSBundle.mainBundle().pathForResource("placeholder", ofType: "mov")
            var url: NSURL = NSURL(fileURLWithPath: fileLocation!)!
            backgroundMoviePlayer = MPMoviePlayerController(contentURL: url)
            
            backgroundMoviePlayer.view.addSubview(backgroundImage)
            backgroundImage.frame = backgroundMoviePlayer.view.frame
            backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
            
            backgroundMoviePlayer.view.autoresizesSubviews = true
            backgroundImage.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        }
        
        // Now that the video or image has been set up, let's get the MPMoviePlayerController frame ready
        backgroundMoviePlayer.view.frame = mainViewController.view.frame
        backgroundMoviePlayer.fullscreen = false
        backgroundMoviePlayer.controlStyle = MPMovieControlStyle.None
        backgroundMoviePlayer.scalingMode = MPMovieScalingMode.AspectFill
        backgroundMoviePlayer.allowsAirPlay = false
        
        backgroundMoviePlayer.view.alpha = 0
        
        return backgroundMoviePlayer
    }
}
