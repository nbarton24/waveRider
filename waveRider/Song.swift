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
