//
//  MiniPlayerViewClass.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 25/01/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import MarqueeLabel
import ViewAnimator

class MiniPlayerView: UIView
{
    var view: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var albumArtwork: UIImageView!
    @IBOutlet weak var artistLabel: MarqueeLabel!
    @IBOutlet weak var trackLabel: MarqueeLabel!
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var progressView: UIProgressView!
    var timer = Timer()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setupInit()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setupInit()
    }
    
    func setupInit()
    {
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayer), name: Notification.Name(rawValue: "updatePlayer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayButtonIcon), name: Notification.Name(rawValue: "updateIcon"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPlayer), name: Notification.Name(rawValue: "showPlayer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HidePlayer), name: Notification.Name(rawValue: "hidePlayer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HidePlayerWithAnimation), name: Notification.Name(rawValue: "hidePlayerWithAnimation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeMiniPlayer), name: Notification.Name(rawValue: "removeMiniPlayer"), object: nil)
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
       
        
        progressView.transform = CGAffineTransform(scaleX: 1, y: 1)
        
        trackLabel.type = .continuous
        trackLabel.speed = .duration(12.0)
        trackLabel.fadeLength = 18.0
        
        artistLabel.type = .continuous
        artistLabel.speed = .duration(12.0)
        artistLabel.fadeLength = 18.0
    }
    
    
    func loadViewFromNib() -> UIView
    {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "\(type(of: self))", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    
    @objc func showPlayer()
    {
        let animation = AnimationType.from(direction: .bottom, offset: 250)
        if containerView.isHidden
        {
            mainView.isHidden = false
            containerView.isHidden = false
            containerView.animate(animations: [animation])
            mainView.animate(animations: [animation])
        }
    }
    
    @objc func HidePlayer()
    {
        if !containerView.isHidden
        {
            mainView.isHidden = true
            containerView.isHidden = true
        }
    }
    
    @objc func HidePlayerWithAnimation()
    {
        let animation = AnimationType.from(direction: .bottom, offset: -250)
        if !containerView.isHidden
        {
            mainView.isHidden = true
            containerView.isHidden = true
            containerView.animate(animations: [animation])
            mainView.animate(animations: [animation])
        }
    }
    
    @objc func removeMiniPlayer()
    {
        mainView.removeFromSuperview()
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.hasadded = false
    }
    
    @IBAction func musicViewPopUpPressed(_ sender: Any)
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "showMusicPlayer"), object: nil)
        
       //self.timer.invalidate()
    }
    
    @IBAction func playOrPausePressed(_ sender: Any)
    {
        let track = TrackTool.shareInstance.getTrackMessage()
        if track.isPlaying
        {
            playButton.setImage(UIImage(named: "play-button"), for: .normal)
            TrackTool.shareInstance.pauseTrack()
            timer.invalidate()
        }
        else
        {
            playButton.setImage(UIImage(named: "Pause"), for: .normal)
            TrackTool.shareInstance.playCurrnetTrack()
            startProgressTimer()
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any)
    {
        TrackTool.shareInstance.nextTrack()
        let track = TrackTool.shareInstance.getTrackMessage()
        if track.isPlaying
        {
            playButton.setImage(UIImage(named: "Pause"), for: .normal)
            timer.invalidate()
        }
        else
        {
            playButton.setImage(UIImage(named: "play-button"), for: .normal)
            
        }
        updatePlayer()
        startProgressTimer()
    }
    
    
    
}


extension MiniPlayerView
{
    @objc func updatePlayer()
    {
        
        let message = TrackTool.shareInstance.getTrackMessage()
        
        // Checking track model make sure is not empty
        guard message.trackModel != nil else {
            return
        }
        trackLabel.text = message.trackModel?.fileName
        artistLabel.text = message.trackModel?.artist
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent("artwork/" + (message.trackModel?.fileName)!)
        if FileManager.default.fileExists(atPath: fileURL.path)
        {
            albumArtwork.image = loadImageFromDiskWith(fileName: (message.trackModel?.fileName)!)
        }
        else{
            albumArtwork.image = UIImage(named: "artwork")
        }
        
        startProgressTimer()
    }
    
    func startProgressTimer()
    {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            timer in
            let track = TrackTool.shareInstance.getTrackMessage()
            if track.isPlaying {
                self.progressView.setProgress(Float(track.currentTime / track.totalTime), animated: false)
            } else {
                return
            }
            // if Repeat mode is and song replayed update the lockscreen otherwise same song will be played and lockscreen music info center details are not gonna change
            if TrackTool.shareInstance.isRepeated && TrackTool.shareInstance.trackPlayer!.currentTime < 1.0 {
                TrackTool.shareInstance.setupLockScreen()
            }
            
        }
    }
    
    @objc func updatePlayButtonIcon(){
        let track = TrackTool.shareInstance.getTrackMessage()
        
        if track.isPlaying
        {
            playButton.setImage(UIImage(named: "Pause"), for: .normal)
        }else{
            playButton.setImage(UIImage(named: "play-button"), for: .normal)
        }
    }
}

class PassthroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains(where: {
            !$0.isHidden && $0.point(inside: self.convert(point, to: $0), with: event)
        })
    }
}
