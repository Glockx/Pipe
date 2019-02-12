//
//  TrackTool.swift
//  SwiftMusic
//
//  Created by K2 on 19/01/2017.
//  Copyright © 2017 K2. All rights reserved.
//

import UIKit
import MediaPlayer

let trackFinish = "trackFinish"

class TrackTool: NSObject , AVAudioPlayerDelegate{
    var trackPlayer: AVAudioPlayer?
    var isShuffled = false
    var isRepeated = false
    var isHidden = true
    static let shareInstance = TrackTool()
    var track: TrackMessage = TrackMessage()
    var tracks = [Track]()
    var currentPlaylistUiid = ""
    var playlist: [Track] = [Track]()
    
    var trackIndex = -1 {
        didSet {
            if trackIndex < 0
            {
                
                trackIndex = 0
            }
            if trackIndex > playlist.count - 1
            {
               
                trackIndex = 0
            }
        }
    }
    
    override init() {
        super.init()
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            
            try session.setActive(true)
        } catch {
            print(error)
            return
        }
    }
    

    
    func getTrackMessage() -> TrackMessage
    {
        
        if (trackIndex >= 0)
        {
            guard let temtrack = playlist[exist: trackIndex] else { return track}
            track.trackModel = temtrack
            track.currentTime = (trackPlayer?.currentTime) ?? 0
            track.totalTime = (trackPlayer?.duration) ?? 0
            track.isPlaying = (trackPlayer?.isPlaying) ?? false
            
            return track
        }else
        {
            return track
        }
        
    }
    
    // MARK - Track Tools
    func playTrack(track : Track)
    {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first  else { return }
        let fileURL = NSURL(fileURLWithPath: documentsDirectory.appendingPathComponent("tracks/").path)
        
        
        guard let path = fileURL.appendingPathComponent(track.fileName + ".mp3") else {
            return
        }
        trackIndex = playlist.index(of: track)!
        if trackPlayer?.url == path {
            trackPlayer?.play()
            
            return
        }
        
        do {
            trackPlayer = try AVAudioPlayer(contentsOf: path)
            trackPlayer?.delegate = self
        } catch {
            print(error)
            return
        }
        trackPlayer?.prepareToPlay()
        trackPlayer?.play()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePlayer"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateIcon"), object: nil)
        setupLockScreen()
    }
    
    func playCurrnetTrack ()
    {
        print("playCurrent indexTrack: ",trackIndex)
        if(trackIndex >= 0)
        {
            if let track = playlist[exist: trackIndex]
            {
                playTrack(track: track)
                setupLockScreen()
            }
        }
        else{
            return
        }
    }
    //shufle track list
    func shuffleList()
    {
        isShuffled = true
        playlist.shuffle()
        trackIndex = Int(arc4random()) % (playlist.count)
        let track = playlist[trackIndex]
        playTrack(track: track)
        setupLockScreen()
    }
    
    //sort list from current song
    func sortList()
    {
        isShuffled = false
        playlist = playlist.sorted { $0.fileName < $1.fileName }
        let track = playlist[trackIndex]
        playTrack(track: track)
        setupLockScreen()
    }
    
    func stop(){
        trackPlayer?.stop()
        stopLockScreen()
    }
    //find current index in tracks array
    func findCurrentTrackIndex() -> Int
    {
        return playlist.firstIndex(of: track.trackModel!)!
    }
    
    //replay current song
    func playCurrentTrackAgain()
    {
        trackPlayer?.currentTime = 0.0
    }
    
    //pause track
    func pauseTrack() -> () {
        trackPlayer?.pause()
        setupLockScreen()
    }
    //Play next track
    func nextTrack()
    {
        trackIndex += 1
        let track = playlist[trackIndex]
        playTrack(track: track)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePlayer"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateIcon"), object: nil)
        setupLockScreen()
    }
    //Play previous track
    func previousTrack() {
        trackIndex -= 1
        let track = playlist[trackIndex]
        playTrack(track: track)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePlayer"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateIcon"), object: nil)
        setupLockScreen()
    }
    
    //activate repeat button
    func activateRepeat()
    {
            isRepeated = true
            trackPlayer?.numberOfLoops = -1
        setupLockScreen()
    }
    //deactivate repeat button
    func deactiveRepeat()
        {
            isRepeated = false
            trackPlayer?.numberOfLoops = 0
            setupLockScreen()
        }
    
    func setProgress(currentProgress : CGFloat) {
        let progress = (trackPlayer?.currentTime)! / (trackPlayer?.duration)!
        
        if CGFloat(progress) == currentProgress {
            return
        }
        let duration = trackPlayer?.duration
        trackPlayer?.currentTime = TimeInterval(currentProgress) * duration!
        setupLockScreen()
    }
    
    func setButtonImage(button: UIButton) {
        let track = TrackTool.shareInstance.getTrackMessage()
        
        if track.isPlaying {
            return button.setBackgroundImage(UIImage(named: "Pause"), for: .normal)
        } else {
            return button.setBackgroundImage(UIImage(named: "play-button"), for: .normal)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: trackFinish), object: self, userInfo: nil)
    }
    
    func setupShuffleButton(button: UIButton){
        UIView.animate(withDuration: 0.3, animations: {
            if(button.backgroundColor == UIColor.black)
            {
                button.imageView?.tintColor = .black
               button.layer.borderColor = UIColor.white.cgColor
               button.backgroundColor = nil
                TrackTool.shareInstance.sortList()
            }
            else
            {
                button.adjustsImageWhenHighlighted = false
                button.backgroundColor = UIColor.black
                button.imageView?.tintColor = .white
                button.layer.cornerRadius = 5
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.black.cgColor
                TrackTool.shareInstance.shuffleList()
            }
        })
    }
    func setupRepeatButton(button: UIButton)
    {
        UIView.animate(withDuration: 0.3, animations: {
            if(button.backgroundColor == UIColor.black)
            {
                button.imageView?.tintColor = .black
                button.layer.borderColor = UIColor.white.cgColor
                button.backgroundColor = nil
                TrackTool.shareInstance.deactiveRepeat()
            }
            else
            {
                button.adjustsImageWhenHighlighted = false
                button.backgroundColor = UIColor.black
                button.imageView?.tintColor = .white
                button.layer.cornerRadius = 5
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.black.cgColor
                TrackTool.shareInstance.activateRepeat()
            }
        })
    }
}





extension TrackTool {
    func setupLockScreen() {
        let lockMsg = getTrackMessage()
        let centerInfo = MPNowPlayingInfoCenter.default()
        
        let artist = lockMsg.trackModel?.artist ?? ""
        var image: UIImage
        let fileName = lockMsg.trackModel?.fileName ?? ""
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent("artwork/" + lockMsg.trackModel!.fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path)
        {
            
            image = loadImageFromDiskWith(fileName: lockMsg.trackModel!.fileName)!
        } else {
            image = UIImage(named: "artwork")!
        }
        
        let artwork = MPMediaItemArtwork.init(boundsSize: (image.size), requestHandler: { (size) -> UIImage in
            return image
        })
        let currentTime = lockMsg.currentTime
        let totalTime = lockMsg.totalTime
        
        var playRate: NSNumber = 0
        
        if lockMsg.isPlaying {
            playRate = 1.0
        }
        
        centerInfo.nowPlayingInfo = [
            MPMediaItemPropertyTitle: fileName,
            MPMediaItemPropertyArtist: artist,
            MPMediaItemPropertyArtwork: artwork,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: totalTime,
            MPNowPlayingInfoPropertyPlaybackRate: playRate
        ]
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    func stopLockScreen(){
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
}
