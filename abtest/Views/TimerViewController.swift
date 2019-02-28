//
//  TimerViewController.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 12/02/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Reachability
class TimerViewController: UIViewController,GADBannerViewDelegate {

    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tabBar: UINavigationBar!
    @IBOutlet weak var timer: UIDatePicker!
    @IBOutlet var adBanner: GADBannerView!
    let reachability = Reachability()!
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
                ADTool.shareInstance.showBanner(adBanner: self.adBanner, rootController: self, bannerID: "ca-app-pub-3452453039969028/3198040414", bannerSize: kGADAdSizeSmartBannerPortrait)
            } else {
                print("Reachable via Cellular")
                ADTool.shareInstance.showBanner(adBanner: self.adBanner, rootController: self, bannerID: "ca-app-pub-3452453039969028/3198040414", bannerSize: kGADAdSizeSmartBannerPortrait)
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeAds), name: NSNotification.Name(rawValue: "SleepTimerRemoveAds"), object: nil)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        adBanner.isHidden = false
        // Reposition the banner ad to create a slide down effect
        let translateTransform = CGAffineTransform(translationX: 0, y: -adBanner.bounds.size.height)
        adBanner.transform = translateTransform
        
        
        UIView.animate(withDuration: 0.5)
        {
            self.adBanner.transform = CGAffineTransform.identity
        }
        
    }
    
    @objc func removeAds(){
        if adBanner != nil{
            adBanner.removeFromSuperview()
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        pauseButton.isHidden = TimerTool.shareInstance.stopButtonState
        startButton.isHidden = TimerTool.shareInstance.startButtonState
        stopButton.isHidden  = TimerTool.shareInstance.stopButtonState
        timeLabel.isHidden   = TimerTool.shareInstance.timeLabelState
        timer.isHidden       = TimerTool.shareInstance.timerState
        
        print(TimerTool.shareInstance.timeRemaning)
        pauseButton.setTitle(TimerTool.shareInstance.pauseButtonText, for: .normal)
        
        
        if TimerTool.shareInstance.timeRemaning != nil
        {
            timeLabel.text = astringFromTimeInterval(interval: TimerTool.shareInstance.timeRemaning)
            TimerTool.shareInstance.timer.invalidate()
            UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            TimerTool.shareInstance.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
            RunLoop.current.add(TimerTool.shareInstance.timer, forMode: RunLoopMode.commonModes)
        }
       
    }

    @IBAction func goBack(_ sender: Any)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func startTimer(_ sender: Any)
    {
       
        stopButton.isHidden = false
        TimerTool.shareInstance.stopButtonState = false
        
        timeLabel.isHidden = false
        TimerTool.shareInstance.timeLabelState = false
        
        timer.isHidden = true
        TimerTool.shareInstance.timerState = true
        
        if !TimerTool.shareInstance.timerIsOn {
             TimerTool.shareInstance.timeRemaning = timer.countDownDuration
            
            UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            TimerTool.shareInstance.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
            RunLoop.current.add(TimerTool.shareInstance.timer, forMode: RunLoopMode.commonModes)
            //3
            TimerTool.shareInstance.timerIsOn = true
            
            startButton.isHidden = true
            TimerTool.shareInstance.startButtonState = true
            
            pauseButton.isHidden = false
            TimerTool.shareInstance.pauseButtonState = false
            
            timeLabel.text = astringFromTimeInterval(interval: TimerTool.shareInstance.timeRemaning)
        }
    }
    
    @objc func timerRunning()
    {
        if TimerTool.shareInstance.timerIsOn == true
        {
            TimerTool.shareInstance.timeRemaning -= 1
            
            print(TimerTool.shareInstance.timeRemaning)
            timeLabel.text = astringFromTimeInterval(interval: TimerTool.shareInstance.timeRemaning)
            
            if TimerTool.shareInstance.timeRemaning == 0{
                exit(-1)
            }
        }
    }
    
    func astringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = (interval) % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        if hours <= 0{
            return String(format: "%02d:%02d", minutes, seconds)
        }
        else
        {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        
    }
    
    @IBAction func stopTimer(_ sender: Any)
    {
        timeLabel.isHidden = true
        TimerTool.shareInstance.timeLabelState = true
        
        timer.isHidden = false
        TimerTool.shareInstance.timerState = false
        
        stopButton.isHidden = true
        TimerTool.shareInstance.stopButtonState = true
        
        pauseButton.isHidden = true
        TimerTool.shareInstance.pauseButtonState = true
        
        startButton.isHidden = false
        TimerTool.shareInstance.startButtonState = false
        
        TimerTool.shareInstance.timer.invalidate()
        
        TimerTool.shareInstance.timerIsOn = false
        
        TimerTool.shareInstance.timeRemaning = nil
    }
    
    @IBAction func pauseTimer(_ sender: UIButton)
    {
        // if the button was selected, then deselect it.
        // otherwise if it was not selected, then select it.
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected
        {
            print("I am selected.")

            TimerTool.shareInstance.timer.invalidate()
            TimerTool.shareInstance.timerIsOn = false
            
        }
        else
        {
            print("I am deselected.")
            UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            TimerTool.shareInstance.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
            RunLoop.current.add(TimerTool.shareInstance.timer, forMode: RunLoopMode.commonModes)
            TimerTool.shareInstance.timerIsOn = true
        }
        
        if TimerTool.shareInstance.timerIsOn{
            pauseButton.setTitle("Pause", for: .normal)
            TimerTool.shareInstance.pauseButtonText = "Pause"
        }else{
            pauseButton.setTitle("Resume", for: .normal)
            TimerTool.shareInstance.pauseButtonText = "Resume"
        }
        
    }
    
}
