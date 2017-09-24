//
//  PlayerViewController.swift
//  waveRider
//
//  Created by Nicholas Barton on 9/24/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//

import UIKit
import SafariServices
import AVFoundation

class PlayerViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {

    //--------------------------------------
    // MARK: Constants
    //--------------------------------------
    
    let kClientID = "23f7a5d0f79742c78618dea3d62569ef"
    let kClientSecret = "08bc405800204b3fa7c7ca0a8e94566d"
    let kRedirectURL = "waverider://returnAfterLogin"
    
    let kDefaultTrack = "spotify:track:6ScJMrlpiLfZUGtWp4QIVt"
    
    //--------------------------------------
    // MARK: Variables
    //--------------------------------------
    
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    
    // Initialzed in either updateAfterFirstLogin: (if first time login) or in viewDidLoad (when there is a check for a session object in User Defaults
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    
    //--------------------------------------
    // MARK: iOS System Methods
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n\nPlayback View Controller\n")
        setup()
        // Do any additional setup after loading the view.
    }

    func setup(){
        // Set up session
        let userDefaults = UserDefaults.standard
        
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = firstTimeSession
            print("Session has been set")
            initializaPlayer(authSession: session)
        }else{
            print("No session could be found")
            //TODO: Create new session if none found
        }
        
        
    }
    
    //--------------------------------------
    // MARK: Spotify Methods
    //--------------------------------------
    
    func initializaPlayer(authSession:SPTSession){
        if self.player == nil {
            print("Player is nil coming in")
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            print("Player Logged in - \(self.player!.loggedIn)")
            if let _ = self.player?.playbackState{
                print("Player has playback state")
                
            }else {
                print("Player has no playback state")
                playSong(track:kDefaultTrack)
            }
            //print("Player State - \(self.player!.playbackState.isPlaying)")
            
            //TODO: What if they aren't logged in?
            
            /*try! player?.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)*/
        }else{
            print("Player is not nil coming in")
            //TODO: How is the player not nil?
            //TODO: Handle the situation where player is not nil
        }
        
    }
    
    func playSong(track:String){
        
        self.player?.playSpotifyURI(track, startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error == nil) {
                print("playing!")
            }else{
                print("Error - \(error)")
            }
            
        })
    }
    
}
