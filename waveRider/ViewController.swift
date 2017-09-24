//
//  ViewController.swift
//  waveRider
//
//  Created by Nicholas Barton on 9/24/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//

import UIKit
import SafariServices
import AVFoundation

class ViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate{

    //--------------------------------------
    // MARK: Constants
    //--------------------------------------
    
    let kClientID = "23f7a5d0f79742c78618dea3d62569ef"
    let kClientSecret = "08bc405800204b3fa7c7ca0a8e94566d"
    let kRedirectURL = "waverider://returnAfterLogin"
    
    //--------------------------------------
    // MARK: Variables
    //--------------------------------------
    
    // Variables
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    
    // Initialzed in either updateAfterFirstLogin: (if first time login) or in viewDidLoad (when there is a check for a session object in User Defaults
    var player: SPTAudioStreamingController?
    var loginUrl: URL?

    var playlistSongs = [Song]()
    
    //--------------------------------------
    // MARK: iOS System Methods
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: nil)
    }
    
    //--------------------------------------
    // MARK: Spotify Methods
    //--------------------------------------

    func initializaPlayer(authSession:SPTSession){
        if self.player == nil {
            
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player?.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
        }else{
            //TODO: Handle situation where player not initialized
            print("Player not initialized successfully")
        }
        
    }
    
    func updateAfterFirstLogin () {
        
        //loginButton.isHidden = true
        let userDefaults = UserDefaults.standard
        
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = firstTimeSession
            
            initializaPlayer(authSession: session)
        }else{
            print("Nah.")
        }
        
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
//        self.player?.playSpotifyURI("spotify:track:6ScJMrlpiLfZUGtWp4QIVt", startingWith: 0, startingWithPosition: 0, callback: { (error) in
//            if (error == nil) {
//                print("playing!")
//            }else{
//                print("Error - \(error)")
//            }
//            
//        })
//        
//        self.player?.setIsPlaying(false, callback: {error in
//            if (error == nil) {
//                print("paused!")
//            }else{
//                print("Error - \(error)")
//            }
//        })
        
    }
    
    //--------------------------------------
    // MARK: Action Methods
    //--------------------------------------
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        print("Button Pressed")
        if UIApplication.shared.openURL(loginUrl!) {
            if (auth.canHandle(auth.redirectURL)) {
                // TODO - build in error handling
            }else{
                
            }
        }
    }
    
    @IBAction func showViewButtonPressed(_ sender: Any) {
        
        let pvc = PlayerViewController()
        self.present(pvc, animated: true, completion: nil)
        
    }
    
    
    
    //--------------------------------------
    // MARK: My Methods
    //--------------------------------------
    
    func setup () {
        // insert redirect your url and client ID below
        let redirectURL = kRedirectURL // put your redirect URL here
        let clientID = kClientID // put your client ID here
        auth.redirectURL     = URL(string: redirectURL)
        auth.clientID        = clientID
        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = auth.spotifyWebAuthenticationURL()
        
    }

//End VC
}

