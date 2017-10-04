//
//  PLRandomizer.swift
//  waveRider
//
//  Created by Nicholas Barton on 9/24/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//

import Foundation

class PLRandomizer {
    
    var songs:[Song]!
    var currentSong:Song?
    var playedSongs = [Song]()
    
    var played = [Song]()
    var currentOptions = [Song]()
    var nextFour = [Song]()
    
    var currentNextSelection = 0
    
    var timer:Timer!
    var currentTimerValue = 10
    let maxTimeForTimer = 10
    let setupTime = 5
    
    init(pl:[Song]){
        self.songs = pl
        //self.timer = Timer()
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(PlayerViewController.updateTimer)), userInfo: nil, repeats: true)
    }

    func endTimer() {
        timer.invalidate()
        //finishRound()
    }

    func pauseTimer(){
        timer.invalidate()
    }

    func updateTimer(){
        if(currentTimerValue > 0){
            currentTimerValue -= 1
            //timerLabel.text = "\(currentTimerValue)"
        }
        if(currentTimerValue == setupTime){
            prepNextRound()
        }
        if (currentTimerValue == 0) {
            endTimer()
        }
    }
    
    func setupRound(){
        currentTimerValue = maxTimeForTimer
        currentNextSelection = 0

        if (nextFour.count == 0){
            fourRandom()
        }

        currentOptions = nextFour
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

        //playSong(track: currentSong!.uri)

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
    
}
