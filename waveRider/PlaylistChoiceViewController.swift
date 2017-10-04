//
//  PlaylistChoiceViewController.swift
//  waveRider
//
//  Created by Nicholas Barton on 10/3/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//

import UIKit
import SafariServices
import AVFoundation

class PlaylistChoiceViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate, UITableViewDelegate, UITableViewDataSource {

    //--------------------------------------
    // MARK: Constants
    //--------------------------------------
    
    let kClientID = "23f7a5d0f79742c78618dea3d62569ef"
    let kClientSecret = "08bc405800204b3fa7c7ca0a8e94566d"
    let kRedirectURL = "waverider://returnAfterLogin"
    
    //--------------------------------------
    // MARK: Variables
    //--------------------------------------
    
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    
    // Initialzed in either updateAfterFirstLogin: (if first time login) or in viewDidLoad (when there is a check for a session object in User Defaults
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    
    var spotPlaylists = [Playlist]()

    var finishedLoadingPlaylists = false
    
    //--------------------------------------
    // MARK: Variables
    //--------------------------------------
    
    @IBOutlet weak var playlistTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSession()
        sendPlaylistsRequest()
        
        repeat{
            //print("waiting..")
        }while(!finishedLoadingPlaylists)
        
        playlistTable.reloadData()
        // Do any additional setup after loading the view.
    }
    
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
    
    func sendPlaylistsRequest(){
        
        var request:URLRequest?
        let urlString = "https://api.spotify.com/v1/users/npbarton33/playlists"
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
                        self.parseJSONforSongs(input: json)
                    }catch let error as NSError {
                        print("error- \(error)")
                    }
                }else{
                    print("Fetch encountered an error - \(err?.localizedDescription)")
                }
                self.finishedLoadingPlaylists = true
            }.resume()
        }
    }

    func parseJSONforSongs(input:[String:Any]){
        //print(input)
        if let playlists = input["items"] as? [[String:AnyObject]] {
            for i in 0..<playlists.count{
                //print(playlists[i])
                var plName = ""
                var plURI = ""
                var plURL = ""
                var plCount = 0
                
                if let playlistName = playlists[i]["name"] as? String{
                    plName = playlistName
                }
                if let playlistURI = playlists[i]["uri"] as? String{
                    plURI = playlistURI
                }
                if let playlistURL = playlists[i]["href"] as? String{
                    plURL = playlistURL
                }
                if let playlistTracks = playlists[i]["tracks"] as? [String:Any]{
                    if let trackCount = playlistTracks["total"] as? Int {
                        plCount = trackCount
                    }
                }
                let currentPlaylist = Playlist(uri: plURI, url:plURL, name: plName, count: plCount)
                spotPlaylists.append(currentPlaylist)
            }
        }else {
            print("could not parse playlist list")
        }
    }
    
    //--------------------------------------
    // MARK: TableView Functions
    //--------------------------------------

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let currentPL = spotPlaylists[indexPath.row]
        cell.textLabel?.text = "\(currentPL.name) - (\(currentPL.songCount))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (spotPlaylists[indexPath.row].songCount > 5){
            spotPlaylists[indexPath.row].printPL()
            let pvc = PlayerViewController()
            pvc.passedPlaylist = spotPlaylists[indexPath.row]
            self.present(pvc, animated: true, completion: nil)
        }else{
            print("Not enough songs to use playlist '\(spotPlaylists[indexPath.row].name)'")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spotPlaylists.count
    }

}
