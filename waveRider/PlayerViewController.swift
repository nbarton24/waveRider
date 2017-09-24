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
    let kShort1 = "spotify:track:5Wd3b5eWkd81bTPdgb0n8G"
    let kSecondTrack = "spotify:track:0w3Q14i073jLoew1hgJkwD"
    let kShort2 = "spotify:track:094hgOWjEloDccp0WNftCH"
    
    //--------------------------------------
    // MARK: Variables
    //--------------------------------------
    
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    
    // Initialzed in either updateAfterFirstLogin: (if first time login) or in viewDidLoad (when there is a check for a session object in User Defaults
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    
    var songs = [Song]()
    var currentSong:Song?
    var playedSongs = [Song]()
    
    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    
    //--------------------------------------
    // MARK: iOS System Methods
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n\nPlayback View Controller\n")
        
        let song1 = Song(test: 1)
        let song2 = Song(test: 2)
        let song3 = Song(test: 3)
        let song4 = Song(test: 0)
        
        songs.append(song1)
        songs.append(song2)
        songs.append(song3)
        songs.append(song4)
        
        setup()
        // Do any additional setup after loading the view.
    }

    //--------------------------------------
    // MARK: Spotify Setup Methods
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
                //playSong(track:kShort1)
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
    // MARK: Spotify Playback Methods
    //--------------------------------------
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        print("Song \(trackUri) started")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        print("Song \(trackUri) Stopped")
    }
    
    func audioStreamingDidSkip(toNextTrack audioStreaming: SPTAudioStreamingController!) {
        print("Skipped To Next Track")
        playNextSong()
    }
    
    //--------------------------------------
    // MARK: Application Methods
    //--------------------------------------
    
    func playSong(track:String){
        
        self.player?.playSpotifyURI(track, startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error == nil) {
                print("playing!")
                
            }else{
                print("Error - \(error)")
            }
            
        })
        
//        let when = DispatchTime.now()+4
//        DispatchQueue.main.asyncAfter(deadline:when){
//            self.player!.skipNext(nil)
//        }
        
    }
    
    func updateUI(){
        if let _ = currentSong {
            songArtistLabel.text = currentSong!.artist
            songTitleLabel.text = currentSong!.title
        }
        
    }
    
    func changePlaybackState(){
        if let pbs = self.player?.playbackState{
            self.player!.setIsPlaying((!pbs.isPlaying), callback: nil)
        }else{
            playNextSong()
        }
    }
    
    func playNextSong(){
        if currentSong != nil {
            playedSongs.append(currentSong!)
        }
        
        if(songs.count > 0){
            currentSong = songs.first!
            songs.removeFirst()
            playSong(track: currentSong!.uri)
            updateUI()
        }else{
            print("No more songs in playlist")
        }
    }
    
    func playLastSong(){
        // TODO: Build this
        if (playedSongs.count>0){
            print("Functionality not yet available")
        }else{
            print("No songs have been played")
        }
    }
    
    //--------------------------------------
    // MARK: UI Methods
    //--------------------------------------
    
    @IBAction func playPauseButton(_ sender: Any) {
        print("play/pause")
        changePlaybackState()
    }
    
    @IBAction func nextTrackButton(_ sender: Any) {
        if let _ = self.player {
            self.player!.skipNext(nil)
        }
    }
    
    @IBAction func lastTrackButton(_ sender: Any) {
        print("last track")
    }
    
    
    
}
