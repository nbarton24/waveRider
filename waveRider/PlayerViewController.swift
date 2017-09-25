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
    
    //Songs//
    var songs = [Song]()
    var currentSong:Song?
    var playedSongs = [Song]()
    
    var finishedLoadingPlaylist = false
    
    var played = [Song]()
    var currentOptions = [Song]()
    var nextFour = [Song]()
    
    var currentNextSelection = 0
    
    var song1 = Song()
    var song2 = Song()
    var song3 = Song()
    var song4 = Song()
    
    //Timer//
    var timer = Timer()
    var currentTimerValue = 10
    let maxTimeForTimer = 10
    let setupTime = 5
    
    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    
    @IBOutlet weak var albumArtworkImageView: UIImageView!
    
    //Voting
    @IBOutlet weak var votingView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    //--------------------------------------
    // MARK: iOS System Methods
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n\nPlayback View Controller\n")
        setupSession()
        votingView.isHidden = true
        
        albumArtworkImageView.image = #imageLiteral(resourceName: "defCover")
        
        finishedLoadingPlaylist = false
        setupPlaylist()
        print("There are \(songs.count) songs in the playlist")
        repeat{
            //print("waiting..")
        }while(!finishedLoadingPlaylist)
        setupRound()
        
        print("doing something else")
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
            }
            
            //TODO: What if they aren't logged in?
            
            /*try! player?.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)*/
        }else{
            print("Player is not nil coming in")
            //TODO: How is the player not nil?
            //TODO: Handle the situation where player is not nil
        }
        
    }
    
    func setupSession(){
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
    // MARK: Spotify Player Callback Methods
    //--------------------------------------
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        print("Song \(trackUri) started")
        updateUI()
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
    
    func sendTracksRequest(url:String){
        
        var request:URLRequest?
        let urlString = url
        let urlToSend = URL(string: urlString)
        let accessToken = session.accessToken
        if let _ = urlToSend, let _ = accessToken {
            request = URLRequest(url: urlToSend!)
            //print("Access token - \(accessToken!)")
            request!.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
            //Accept: application/json
            request!.setValue("application/json", forHTTPHeaderField: "Accept")
            request!.httpMethod = "GET"
        }
        
        if let _ = request {
            let session = URLSession.shared
            session.dataTask(with: request!) { (data,response,err) in
                if (err == nil){
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                        
                        //print("JSON Data From Response - \n\(json)")
                        self.parseJSONforSongs(input: json)
                    }catch let error as NSError {
                        print("error- \(error)")
                    }
                }else{
                    print("Fetch encountered an error - \(err?.localizedDescription)")
                }
                }.resume()
        }
    }
    
    func setupPlaylist(){
        let currentUser = "npbarton33"
        let currentPlaylist = "68EfLref6wQOgbTDF1tzJ0"
        
        let requestString = "https://api.spotify.com/v1/users/\(currentUser)/playlists/\(currentPlaylist)/tracks?fields=items(track(uri,name,duration_ms,album(name,images),artists(name)))"
        
        sendTracksRequest(url: requestString)
    }
    
    func parseJSONforSongs(input:[String:Any]){
        
        
        if let tracks = input["items"] as? [[String:AnyObject]] {
            songs = []
            for i in 0..<tracks.count{
                let track = tracks[i]["track"] as? [String:Any]
                if let currentTrack = track{
                    let songFromTrack = Song(track: currentTrack)
                    songs.append(songFromTrack)
                }
            }
        }else {
            print("could not parse song list")
        }
        finishedLoadingPlaylist = true
        //displayPlaylistSongs()
    }
    
    func displayPlaylistSongs(){
        print("There are \(songs.count) songs in the playlist")
//        for song in songs{
//            song.printSong()
//        }
    }
    
    //--------------------------------------
    // MARK: Voting Methods
    //--------------------------------------
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(PlayerViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func endTimer() {
        timer.invalidate()
        finishRound()
    }
    
    func pauseTimer(){
        
    }
    
    func updateTimer(){
        if(currentTimerValue > 0){
            currentTimerValue -= 1
            timerLabel.text = "\(currentTimerValue)"
        }
        if(currentTimerValue == setupTime){
            prepNextRound()
        }
        if (currentTimerValue == 0) {
            endTimer()
        }
    }
    
    func setupRound(){
        //print("There are \(songs.count) songs in the playlist")
        currentTimerValue = maxTimeForTimer
        currentNextSelection = 0
        timerLabel.text = "\(currentTimerValue)"
        
        if (nextFour.count == 0){
            fourRandom()
        }
        
        currentOptions = nextFour
        
        //Update view and variables
        song1 = currentOptions[0]
        button1.setTitle("\(currentOptions[0].title)", for: .normal)
        song2 = currentOptions[1]
        button2.setTitle("\(currentOptions[1].title)", for: .normal)
        song3 = currentOptions[2]
        button3.setTitle("\(currentOptions[2].title)", for: .normal)
        song4 = currentOptions[3]
        button4.setTitle("\(currentOptions[3].title)", for: .normal)
        
        //Start timer
        startTimer()
    }
    func finishRound(){
        
        //Set "winner" to be currentSong
        if (currentNextSelection == 0){
            //No votes were cast, select random one from list of nextFour
            //print("No song selected when timer ended. Picking random from list")
            currentNextSelection = Int(arc4random_uniform(UInt32(currentOptions.count)))+1
            currentSong = currentOptions[currentNextSelection-1]
        }else{
            print("Song \(currentNextSelection) was selected (\(currentOptions[currentNextSelection-1].title))")
            currentSong = currentOptions[currentNextSelection-1]
        }
        
        playSong(track: currentSong!.uri)
        
        //Update label of "Currently playing" with the currentSong
        if let _ = currentSong{
            //nowPlayingLabel.text = "Now Playing: Song \(currentSong!)"
            played.append(currentSong!)
            currentOptions.remove(at: (currentNextSelection-1))
        }else{
            //nowPlayingLabel.text = "ERROR: No Song Selected"
        }
        
        //Shuffle in "losers" after next four songs are selected
        for i in 0..<currentOptions.count{
            songs.append(currentOptions[i])
        }
        
        //Dat new song tho
        setupRound()
    }
    
    func prepNextRound(){
        fourRandom()
    }
    
    func fourRandom(){
        //Get 4 random songs
        print("Counts - songs: \(songs.count) Played: \(played.count) ")
        if(songs.count == 5){
            print("Shuffling")
            addToShuffle()
        }
        
        nextFour = []
        for _ in 0..<4{
            let random = arc4random_uniform(UInt32(songs.count))
            let randomSong = songs[Int(random)]
            songs.remove(at: Int(random))
            nextFour.append(randomSong)
        }
    }
    
    func addToShuffle(){
        var numToGet = 0
        if(played.count%2 == 0){
            numToGet = (played.count/2)
        }else{
            numToGet = ((played.count-1)/2)
        }
        for _ in 0..<numToGet {
            songs.append(played[0])
            played.remove(at: 0)
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
            //self.player!.skipNext(nil)
        }
    }
    
    @IBAction func lastTrackButton(_ sender: Any) {
        votingView.isHidden = false
    }
    
    @IBAction func dismissVotingView(_ sender: Any) {
        votingView.isHidden = true
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        print("button pressed")
        switch sender {
        case button1:
            currentNextSelection = 1
            break
        case button2:
            currentNextSelection = 2
            break
        case button3:
            currentNextSelection = 3
            break
        case button4:
            currentNextSelection = 4
            break
        default:
            currentNextSelection = 0
        }
        
        print("Current Selection is Song \(currentNextSelection)")
        
    }
    
    
}
