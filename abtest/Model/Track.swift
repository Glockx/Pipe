//
//  Track.swift
//  abtest
//
//  Created by Nijat Muzaffarli on 10/09/2018.
//  Copyright © 2018 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import Foundation


enum TrackPropertyKeys: String
{
    case title
    case artist
    case fileName
    case album
    case recordTime
}

class Track: NSObject, NSCoding
{
    
    var title: String
    var artist: String
    var fileName: String
    var artwork: Data?
    var album:  String
    var recordTime: String
    
    
    init(title: String, artist: String, fileName: String, artwork: Data?, album: String,recordTime: String)
    {
        self.title = title
        self.artist = artist
        self.fileName = fileName
        self.artwork = artwork
        self.album = album
        self.recordTime = recordTime
    }
  
    // MARK: NSCoding
    
    // Loading
    required convenience init?(coder aDecoder: NSCoder) {
        guard let title = aDecoder.decodeObject(forKey: TrackPropertyKeys.title.rawValue) as? String,
        let artist = aDecoder.decodeObject(forKey: TrackPropertyKeys.artist.rawValue) as? String,
        let fileName = aDecoder.decodeObject(forKey: TrackPropertyKeys.fileName.rawValue) as? String,
        let album = aDecoder.decodeObject(forKey: TrackPropertyKeys.album.rawValue) as? String,
        let recordTime = aDecoder.decodeObject(forKey: TrackPropertyKeys.recordTime.rawValue) as? String
            else {return nil}
        self.init(title: title, artist: artist, fileName: fileName, artwork: nil, album: album, recordTime: recordTime)
    }
    
    // Saving
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: TrackPropertyKeys.title.rawValue)
        aCoder.encode(artist, forKey: TrackPropertyKeys.artist.rawValue)
        aCoder.encode(fileName, forKey: TrackPropertyKeys.fileName.rawValue)
        aCoder.encode(album, forKey: TrackPropertyKeys.album.rawValue)
        aCoder.encode(recordTime, forKey: TrackPropertyKeys.recordTime.rawValue)
    }
    
}


