//
//  Playlist.swift
//  waveRider
//
//  Created by Nicholas Barton on 10/3/17.
//  Copyright © 2017 Nick Barton. All rights reserved.
//

import Foundation

class Playlist {
    
    var uri = ""
    var url = ""
    var name = ""
    var songCount = 0
    
    init(uri:String,url:String,name:String,count:Int){
        self.uri = uri
        self.url = url
        self.name = name
        self.songCount = count
    }
    
    //Make a JSON init
    
    func printPL(){
        print("This playlist is called '\(self.name)' and has \(self.songCount) songs")
    }
    
}
