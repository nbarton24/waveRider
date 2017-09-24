//
//  Song.swift
//  waveRider
//
//  Created by Nicholas Barton on 9/24/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//

import Foundation

class Song {
    
    var title = ""
    var uri = ""
    var album = ""
    var albumArtworkLarge = ""
    var albumArtworkSmall = ""
    var artist = ""
    var feats = [String]()
    var duration = 0
    
    init(spotName:String,spotURI:String,trackArtist:String,trackCollabs:[String],trackLength:Int,albumTitle:String,largeImage:String,smallImage:String){
        title = spotName
        uri = spotURI
        artist = trackArtist
        feats = trackCollabs
        duration = trackLength
        album = albumTitle
        albumArtworkLarge = largeImage
        albumArtworkSmall = smallImage
    }
    
    init(test:Int) {
        switch test{
            case 1:
                title = "Congratulations"
                uri = "spotify:track:3a1lNhkSLSkpJE4MSHpDu9"
                album = "Stoney (Delux)"
                albumArtworkLarge = "https://i.scdn.co/image/f244af855d54ed944974c5bd2d0a862c6829efb9"
                albumArtworkSmall = "https://i.scdn.co/image/9868b309bd47b61e045cca4addd911ccdec11961"
                artist = "Post Malone"
                feats = ["Quavo"]
                duration = 220293
                break
            case 2:
                title = "iSpy"
                uri = "spotify:track:2EEeOnHehOozLq4aS0n6SL"
                album = "iSpy - Single"
                albumArtworkLarge = "https://i.scdn.co/image/f16a925a9d2ac7f03e1fcbc226b740af06d5d65b"
                albumArtworkSmall = "https://i.scdn.co/image/fc9b988f48ebd4fc0faf3f0f9754975f0856cf2f"
                artist = "KYLE"
                feats = ["Lil Yachty"]
                duration = 253106
                break
            case 3:
                title = "T-Shirt"
                uri = "spotify:track:7KOlJ92bu51cltsD9KU5I7"
                album = "Culture"
                albumArtworkLarge = "https://i.scdn.co/image/4047ff295bb33fc7b24cac467764e014b4803e11"
                albumArtworkSmall = "https://i.scdn.co/image/ceb15db67f3b6027cabe5694f976eadd1ecd6f5a"
                artist = "Migos"
                feats = []
                duration = 242407
                break
            default:
                title = "Every Morning"
                uri = "spotify:track:6Neq7tjnknt4URNI8txFL4"
                album = "The Best of Sugar Ray"
                albumArtworkLarge = "https://i.scdn.co/image/0a196d2813afd7fc730d9ff64e27a9560ff61faa"
                albumArtworkSmall = "https://i.scdn.co/image/745511c83e9100874cee8528f5b7a8ebd1d02dd4"
                artist = "Sugar Ray"
                feats = []
                duration = 220200
            break
        }
    }
    
    func printSong(){
        print("Song Info:")
        print("Title - \(self.title)")
        print("Album - \(self.album)")
        print("Artist - \(self.artist)")
        print("Also Featuring - \(self.feats)")
        print("Song Length - \(self.duration)")
        print("Large Image - \(self.albumArtworkLarge)")
        print("Small Image - \(self.albumArtworkSmall)")
        print("Song URI - \(self.uri)")
        print("\n\n")
    }
    
}
