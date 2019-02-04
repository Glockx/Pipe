//
//  MusicPlayerViewController.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 12/09/2018.
//  Copyright © 2018 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import MarqueeLabel
import SnapKit
import BCColor




//TODO: Make Artist and Track Label MarqueeLabel

class MusicPlayerViewController: UIViewController {

    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var closeView: UIButton!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var musicArtwork: UIImageView!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var finishTime: UILabel!
    @IBOutlet weak var songTrack: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var fileName: MarqueeLabel!
    @IBOutlet weak var previousSongButton: UIButton!
    @IBOutlet weak var nextSongButton: UIButton!
    @IBOutlet weak var PlayButtonContainer: UIView!
    var popupTimer = Timer()
    var trackList = [Track]()
    static var shared = MusicPlayerViewController()
    
    //TODO: Implement edit music metadata
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        UpdateGeneralViewWithSongDetails()
        
        //musicArtwork.layer.cornerRadius = 8
        //musicArtwork.layer.masksToBounds = true
        songTrack.setThumbImage(UIImage(), for: .normal)
        songTrack.setMaximumTrackImage(UIImage(named: "Lighter"), for: UIControlState.normal )
        songTrack.setMinimumTrackImage(UIImage(named: "Black"), for: UIControlState.normal )
        
       
        fileName.type = .continuous
        fileName.speed = .duration(12.0)
        fileName.fadeLength = 15.0
        fileName.labelWillBeginScroll()
        trackTitle.adjustsFontSizeToFitWidth = true
        artistLabel.adjustsFontSizeToFitWidth = true
        
        
        //Configure View Swipe Down Gesture
        let down = UISwipeGestureRecognizer(target: self, action: #selector(MusicPlayerViewController.DownSwipe))
        down.direction = .down
        view.addGestureRecognizer(down)
        
        if TrackTool.shareInstance.getTrackMessage().trackModel?.artist == nil
            {
            playButton.isUserInteractionEnabled = false
            previousSongButton.isUserInteractionEnabled = false
            nextSongButton.isUserInteractionEnabled = false
        }
        else
        {
            playButton.isUserInteractionEnabled = true
            previousSongButton.isUserInteractionEnabled = true
            nextSongButton.isUserInteractionEnabled = true
        }

        
        // set observer for UIApplication.willEnterForegroundNotification
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
   @objc override func viewDidLayoutSubviews() {
    setupViewConstrains()
    }
 
    func UpdateGeneralViewWithSongDetails()
    {
        setupTrackDetails()
        updateView()
        progressTimer()
        setupProgressSlider()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(nextPressed), name: NSNotification.Name(rawValue: trackFinish), object: nil)
        super.viewWillAppear(animated)
        if TrackTool.shareInstance.getTrackMessage().isPlaying{
            playButton.setBackgroundImage(UIImage(named: "Pause"), for: .normal)
        }else{
            playButton.setBackgroundImage(UIImage(named: "play-button"), for: .normal)
        }
        
        if TrackTool.shareInstance.isShuffled{
            shuffleButton.adjustsImageWhenHighlighted = false
            shuffleButton.backgroundColor = UIColor.black
            shuffleButton.imageView?.tintColor = .white
            shuffleButton.layer.cornerRadius = 5
            shuffleButton.layer.borderWidth = 1
            shuffleButton.layer.borderColor = UIColor.black.cgColor
        }else
        {
            shuffleButton.imageView?.tintColor = .black
            shuffleButton.layer.borderColor = UIColor.white.cgColor
            shuffleButton.backgroundColor = nil
        }
        
        if TrackTool.shareInstance.isRepeated{
            repeatButton.adjustsImageWhenHighlighted = false
            repeatButton.backgroundColor = UIColor.black
            repeatButton.imageView?.tintColor = .white
            repeatButton.layer.cornerRadius = 5
            repeatButton.layer.borderWidth = 1
            repeatButton.layer.borderColor = UIColor.black.cgColor
        }
        else
        {
            repeatButton.imageView?.tintColor = .black
            repeatButton.layer.borderColor = UIColor.white.cgColor
            repeatButton.backgroundColor = nil
        }
    }
    
    @objc func willEnterForeground() {
        
        print("just entered ")
        if TrackTool.shareInstance.getTrackMessage().isPlaying{
            playButton.setBackgroundImage(UIImage(named: "Pause"), for: .normal)
        }else{
            playButton.setBackgroundImage(UIImage(named: "play-button"), for: .normal)
        }
    }
    
    @objc func DownSwipe(){
        print("down")
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func singleTapped() {
        
        TrackTool.shareInstance.playCurrentTrackAgain()
        playButton.setBackgroundImage(UIImage(named: "Pause"), for: .normal)
        //setupTrackDetails()
    }
    
    @objc func doubleTapped() {
        TrackTool.shareInstance.previousTrack()
        playButton.setBackgroundImage(UIImage(named: "Pause"), for: .normal)
        setupTrackDetails()
    }
    @IBAction func repeatButtonPressed(_ sender: Any)
    {
        TrackTool.shareInstance.setupRepeatButton(button: repeatButton)
    }
    
    @objc func setupViewConstrains()
    {
        resetButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view).offset(30)
            make.right.equalTo(view).offset(-20)
            //make.bottom.equalTo(view).offset(-20)
        }
        colorView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(view)
            make.bottom.equalTo(view).dividedBy(1.90)
            make.right.equalTo(view)
        }
        musicArtwork.snp.makeConstraints { (make) -> Void in

            make.height.lessThanOrEqualTo(colorView).offset(-70)
            make.width.lessThanOrEqualTo(colorView).offset(-65)
            make.bottom.equalTo(colorView).offset(20)
            make.centerX.equalTo(colorView)
        }
        closeView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(colorView.snp.topMargin).offset(5)
            make.centerX.equalTo(colorView)
            make.width.equalTo(colorView).multipliedBy(0.09)
            make.height.equalTo(colorView).multipliedBy(0.09)
        }
        fileName.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(musicArtwork.snp.top).offset(-5)
            make.centerX.equalTo(musicArtwork)
            make.width.equalTo(musicArtwork.snp.width).offset(-60)
        }
        artistLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(colorView.snp.bottom).offset(35)
            make.centerX.equalTo(colorView)
            make.width.equalTo(view).offset(-130)
        }
        trackTitle.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(artistLabel.snp.bottom)
            make.centerX.equalTo(artistLabel)
            make.width.equalTo(artistLabel.snp.width)
        }
        songTrack.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(trackTitle.snp.bottom).offset(20)
            make.centerX.equalTo(trackTitle)
            make.width.equalTo(artistLabel.snp.width)
        }
        finishTime.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(songTrack.snp.bottom).offset(-17)
            make.right.equalTo(songTrack.snp.right).offset(2)
        }
        totalTime.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(songTrack.snp.bottom).offset(-17)
            make.left.equalTo(songTrack.snp.left).offset(-2)
        }
        playButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(songTrack.snp.bottom).offset(20)
            make.centerX.equalTo(songTrack.snp.centerX)
            make.width.equalTo(colorView).multipliedBy(0.17)
            make.height.equalTo(colorView).multipliedBy(0.17)
        }
        nextSongButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(playButton.snp.right).offset(30)
            make.centerY.equalTo(playButton)
            make.width.equalTo(colorView).multipliedBy(0.09)
            make.height.equalTo(colorView).multipliedBy(0.09)
        }
        previousSongButton.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(playButton.snp.left).offset(-30)
            make.centerY.equalTo(playButton)
            make.width.equalTo(colorView).multipliedBy(0.09)
            make.height.equalTo(colorView).multipliedBy(0.09)
        }
        shuffleButton.snp.makeConstraints{(make) -> Void in
            make.left.equalTo(nextSongButton.snp.right).offset(20)
            make.centerY.equalTo(playButton)
            make.width.equalTo(colorView).multipliedBy(0.09)
            make.height.equalTo(colorView).multipliedBy(0.1)        }
        repeatButton.snp.makeConstraints{(make) -> Void in
            make.right.equalTo(previousSongButton.snp.left).offset(-20)
            make.centerY.equalTo(playButton)
            make.width.equalTo(colorView).multipliedBy(0.09)
            make.height.equalTo(colorView).multipliedBy(0.1)
        }
    }
    @IBAction func resetConstrains(_ sender: Any)
    {
        resetButton.snp.removeConstraints()
        colorView.snp.removeConstraints()
        musicArtwork.snp.removeConstraints()
        closeView.snp.removeConstraints()
        fileName.snp.removeConstraints()
        artistLabel.snp.removeConstraints()
        trackTitle.snp.removeConstraints()
        songTrack.snp.removeConstraints()
        finishTime.snp.removeConstraints()
        totalTime.snp.removeConstraints()
        playButton.snp.removeConstraints()
        nextSongButton.snp.removeConstraints()
        previousSongButton.snp.removeConstraints()
        shuffleButton.snp.removeConstraints()
        repeatButton.snp.removeConstraints()
        view.layoutIfNeeded()
        view.layoutSubviews()
    }
    
    func determinePreviousPressed()
    {
        if(totalTime.text == "0:00")
        {
            doubleTapped()
        }
        else{singleTapped()
            
        }
    }
    
    @IBAction func previousPressed(_ sender: Any)
    {
       determinePreviousPressed()
      updateView()
    }

    
    func updateView() {

        if let colors = musicArtwork.image?.getColors() {
            UIView.animate(withDuration: 0.5, animations: {
               
                
                self.colorView.backgroundColor = colors.backgroundColor
                self.fileName.textColor = colors.primaryColor
                UIApplication.shared.statusBarView?.backgroundColor = colors.backgroundColor
            })
        }


    }
     @IBAction func playPausePressed(_ sender: Any)
    {
        let track = TrackTool.shareInstance.getTrackMessage()
        
       
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let destinationPath = documentsPath.appendingPathComponent((track.trackModel?.fileName)! + ".mp3")
        
        getSongBitrate(audioURL: URL(fileURLWithPath: destinationPath), duration: Int(track.totalTime)) { (bitrate) in
            print(bitrate)
        }
        
        if track.isPlaying {
            playButton.setBackgroundImage(UIImage(named: "play-button"), for: .normal)
            TrackTool.shareInstance.pauseTrack()
            playButton.isEnabled = true
        }
        else
        {
            playButton.setBackgroundImage(UIImage(named: "Pause"), for: .normal)
            TrackTool.shareInstance.playCurrnetTrack()
            playButton.isEnabled = true
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateIcon"), object: nil)
        updateView()
    }
   

    @IBAction func musicTrackSilded(_ sender: Any)
    {
        songTrack.value = (sender as AnyObject).value
        TrackTool.shareInstance.setProgress(currentProgress: CGFloat(self.songTrack.value))
        
    }

    @objc @IBAction func nextPressed(_ sender: Any)
    {
        playButton.setBackgroundImage(UIImage(named: "Pause"), for: .normal)
        TrackTool.shareInstance.nextTrack()
        setupTrackDetails()
        updateView()
    }
    @IBAction func shufflePressed(_ sender: Any)
    {
        TrackTool.shareInstance.setupShuffleButton(button: shuffleButton)
        setupTrackDetails()
        TrackTool.shareInstance.setButtonImage(button: playButton)
        updateView()
    }
    
    @IBAction func closeView(_ sender: Any)
    {
       dismiss(animated: true, completion: nil)
        
        NotificationCenter.default.removeObserver(self)
    }

    func setupTrackDetails() {
        let track = TrackTool.shareInstance.getTrackMessage()

        guard track.trackModel != nil else {
            return print("no song")
        }

        trackTitle.text = track.trackModel?.title
        artistLabel.text = track.trackModel?.artist
        fileName.text = track.trackModel?.fileName
        
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent("artwork/" + (track.trackModel?.fileName)!)
        if FileManager.default.fileExists(atPath: fileURL.path)
        {
            musicArtwork.image = loadImageFromDiskWith(fileName: (track.trackModel?.fileName)!)
        }
        else{
            musicArtwork.image = UIImage(named: "artwork")
        }
    }

    func progressTimer() {
        popupTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            timer in
            let track = TrackTool.shareInstance.getTrackMessage()
            let status = UIApplication.shared.applicationState
            if status == .background {

            }

            if track.isPlaying {
                // print(track.currentTime, track.totalTime)
                self.songTrack.value = Float(track.currentTime / track.totalTime)
                self.totalTime.text = TimeFormat.getFormatTime(timerInval: track.currentTime)
                self.finishTime.text = "-\(TimeFormat.getFormatTime(timerInval: (track.totalTime - track.currentTime)))"
            } else {
                return
            }
        }
    }

    func setupProgressSlider() {
        let track = TrackTool.shareInstance.getTrackMessage()
        songTrack.value = Float(track.currentTime / track.totalTime)
        totalTime.text = TimeFormat.getFormatTime(timerInval: track.currentTime)
        finishTime.text = "-\(TimeFormat.getFormatTime(timerInval: (track.totalTime - track.currentTime)))"
    }
}

extension MusicPlayerViewController
{
    override func remoteControlReceived(with event: UIEvent?) {

        guard let event = event else {
            print("No event")
            return
        }

        guard event.type == UIEventType.remoteControl else {
            print("Received other control type")
            return
        }
        switch event.subtype {
        case UIEventSubtype.remoteControlPlay:

            TrackTool.shareInstance.playCurrnetTrack()
        case UIEventSubtype.remoteControlPause:
            TrackTool.shareInstance.pauseTrack()
            
        case UIEventSubtype.remoteControlNextTrack:
            TrackTool.shareInstance.nextTrack()
            
        case UIEventSubtype.remoteControlPreviousTrack:
            determinePreviousPressed()
            TrackTool.shareInstance.setupLockScreen()
            
        default:
            print("")
        }
        setupTrackDetails()
    }
    /*
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        TrackTool.shareInstance.nextTrack()
        setupTrackDetails()
    }
 */

}

