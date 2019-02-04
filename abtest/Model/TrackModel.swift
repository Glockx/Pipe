//
//  TrackModel.swift
//  SwiftMusic
//
//  Created by K2 on 19/01/2017.
//  Copyright © 2017 K2. All rights reserved.
//

import UIKit
import AVFoundation

class TrackModel: NSObject
{
    class func getTracks(result : ([Track]) ->()) {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        
        do {
            print("Load Data")
            let fileFromBundle = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: documentsPath!), includingPropertiesForKeys: nil, options: [])
            let mp3Files = fileFromBundle.filter{ $0.pathExtension == "mp3" }
            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
            
            var tracks = [Track]()
            var sortedTracks = [Track]()
            var title:String = "Unknown"
            var artist:String = "Unknown"
            var artwork: Data?
            var album: String = "Unknown"
            var recordTime: String = ""
            
            
            for path in mp3FileNames {
                
                let ab = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                let url = NSURL(fileURLWithPath: ab)
                let pathComponent = url.appendingPathComponent(path + ".mp3")
                
                let playerItem = AVPlayerItem(url: pathComponent!)
                let metadataList = playerItem.asset.metadata
                
                title = "Unknown"
                artist = "Unknown"
                album = "Unknown"
                artwork = nil
                
                
                for item in metadataList {
                    
                    guard let key = item.commonKey?.rawValue, let value = item.value else
                    {
                        continue
                    }
                    
                    switch key {
                    case "title": title = value as! String
                    case "artist":artist = value as! String
                    case "albumName": album = value as! String
                    case "artwork": artwork = value as? Data
                    
                    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                    
                    let fileName = path
                    let fileURL = documentsDirectory.appendingPathComponent("artwork/" + fileName)
                    
                    if (artwork!.count > 0 && !FileManager.default.fileExists(atPath: fileURL.path))
                    {
                        saveImage(imageName: path, image: UIImage(data: artwork!)!)
                    }
                        
                    case "creationDate":recordTime = value as! String
                    default:
                        continue
                    }

                    
                }
                
                let track = Track(title: title, artist: artist, fileName: path, artwork: nil,album: album,recordTime: recordTime)
                
                tracks.append(track)
                sortedTracks = tracks.sorted { $0.fileName < $1.fileName }
            }
            
            print("Tracks: \(tracks.count)")
            result(sortedTracks)
        } catch let error{
            print(error)
        }
    }
}
