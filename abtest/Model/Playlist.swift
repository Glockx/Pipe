//
//  Playlist.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 03/02/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import Foundation
import UIKit

enum PlaylistPropertyKeys: String
{
    case name
    case songCount
    case tracks
    case createdDay
    case totalTime
}

class Playlist: NSObject,NSCoding{
    
    var name: String
    var songCount: Int
    var tracks: [Track]
    var artwork: Data?
    var createdDay: String
    var totalTime: String
    
    init(name: String, songCount: Int, tracks: [Track], artwork: Data?, createdDay: String, totalTime:String){
        self.name = name
        self.songCount = songCount
        self.tracks = tracks
        self.artwork = artwork
        self.createdDay = createdDay
        self.totalTime = totalTime
    }
    // MARK: NSCoding
    
    // Loading
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PlaylistPropertyKeys.name.rawValue) as? String,
        let songCount = aDecoder.decodeObject(forKey: PlaylistPropertyKeys.songCount.rawValue)as? Int,
        let tracks = aDecoder.decodeObject(of: Track.self, forKey: PlaylistPropertyKeys.tracks.rawValue),
        let createdDay = aDecoder.decodeObject(forKey: PlaylistPropertyKeys.createdDay.rawValue) as? String,
        let totalTime = aDecoder.decodeObject(forKey: PlaylistPropertyKeys.totalTime.rawValue) as? String
        else {return nil}
        self.init(name: name, songCount: songCount, tracks: [tracks], artwork: nil, createdDay: createdDay, totalTime: totalTime)
    }
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(name, forKey: PlaylistPropertyKeys.name.rawValue)
        aCoder.encode(songCount, forKey: PlaylistPropertyKeys.songCount.rawValue)
        aCoder.encode(tracks, forKey: PlaylistPropertyKeys.tracks.rawValue)
        aCoder.encode(createdDay, forKey: PlaylistPropertyKeys.createdDay.rawValue)
        aCoder.encode(totalTime, forKey: PlaylistPropertyKeys.totalTime.rawValue)
    }
}
