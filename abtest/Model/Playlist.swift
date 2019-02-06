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
    case tracks
    case createdDay
    case totalTime
}

class Playlist: NSObject,NSCoding
{
    var name: String
    var songCount: Int
    var tracks: [Track]
    var artwork: Data?
    var createdDay: String
    var totalTime: String
    var uuid: String
    
    init(name: String, songCount: Int, tracks: [Track], artwork: Data?, createdDay: String, totalTime:String, uuid: String)
    {
        self.name = name
        self.songCount = songCount
        self.tracks = tracks
        self.artwork = artwork
        self.createdDay = createdDay
        self.totalTime = totalTime
        self.uuid = uuid
    }
    
    // MARK: NSCoding
    
    // Loading
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name =    aDecoder.decodeObject(forKey: PlaylistPropertyKeys.name.rawValue) as? String,
        let tracks =        aDecoder.decodeObject(forKey: "tracks") as? [Track],
        let createdDay =    aDecoder.decodeObject(forKey: PlaylistPropertyKeys.createdDay.rawValue) as? String,
        let totalTime =     aDecoder.decodeObject(forKey: PlaylistPropertyKeys.totalTime.rawValue) as? String,
        let uuid = aDecoder.decodeObject(forKey: "uuid") as? String
        else {return nil}
        let songCount = aDecoder.decodeInteger(forKey: "songCount")
        self.init(name: name, songCount: songCount, tracks: tracks, artwork: nil, createdDay: createdDay, totalTime: totalTime, uuid: uuid)
    }
    
    // Saving
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(name, forKey: PlaylistPropertyKeys.name.rawValue)
        aCoder.encode(songCount, forKey: "songCount")
        aCoder.encode(tracks, forKey: "tracks")
        aCoder.encode(createdDay, forKey: PlaylistPropertyKeys.createdDay.rawValue)
        aCoder.encode(totalTime, forKey: PlaylistPropertyKeys.totalTime.rawValue)
        aCoder.encode(uuid, forKey: "uuid")
    }
}
