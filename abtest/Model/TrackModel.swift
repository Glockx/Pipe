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
        let existingTracks = TrackModel().loadSongs() ?? TrackTool.shareInstance.tracks
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent("tracks/").path
        do {
            print("Load Data")
            let fileFromBundle = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: fileURL), includingPropertiesForKeys: nil, options: [])
            let mp3FileNames = fileFromBundle.map{ $0.deletingPathExtension().lastPathComponent }
            
            var filteredmp3FileNames: Set<String> = []
            let map = existingTracks.map{$0.fileName}
            filteredmp3FileNames = Set(map).symmetricDifference(mp3FileNames)
            dump(filteredmp3FileNames)
            
            
            var tracks = TrackModel().loadSongs() ?? TrackTool.shareInstance.tracks
            var sortedTracks = [Track]()
            var title:String = "Unknown"
            var artist:String = "Unknown"
            var artwork: Data?
            var album: String = "Unknown"
            var recordTime: String = ""
            
            
            for path in filteredmp3FileNames
            {
                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first  else { return }
                let fileURL = NSURL(fileURLWithPath: documentsDirectory.appendingPathComponent("tracks/").path)
                
                let pathComponent = fileURL.appendingPathComponent(path + ".mp3")
                
               
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
                let uuid = NSUUID().uuidString.lowercased()
                let track = Track(title: title, artist: artist, fileName: path, artwork: nil,album: album,recordTime: recordTime,uuid: uuid)
                
                tracks.append(track)
                sortedTracks = tracks.sorted { $0.fileName < $1.fileName }
            }
            
            print("Tracks: \(tracks.count)")
            result(tracks)
        } catch let error{
            print(error)
        }
    }
    
    internal func loadSongs() -> [Track]!
    {
        let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let ArchiveURL = DocumentsDirectory.appendingPathComponent("Tracks")
        return NSKeyedUnarchiver.unarchiveObject(withFile: ArchiveURL.path) as? [Track]
    }
    
}
