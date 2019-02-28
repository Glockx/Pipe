//
//  AlbumDetailsViewController.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 29/01/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import BCColor
import GoogleMobileAds
import Reachability
class AlbumDetailsViewController: UIViewController,GADBannerViewDelegate
{
    let screen = UIScreen.main.bounds
    var strechView: StrechView?
    let reachability = Reachability()!
    @IBOutlet var tableTopConst: NSLayoutConstraint!
    @IBOutlet var adBanner: GADBannerView!
    @IBOutlet weak var tableBottomConstrain: NSLayoutConstraint!
    var passedAlbumName = ""
    var passedArtistName = ""
    var passedImage: UIImage!
    var passedDate = ""
    var passedAlbums = [Track]()
    var AlbumTracks = [Track]()
    var statusBarColor: UIColor?
    @IBOutlet weak var tableView: UITableView!
    let imageView = UIImageView()
    
    override func viewDidLoad()
    {
       
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //make statusbar transparent
        //(UIApplication.shared.value(forKey: "statusBar") as? UIView)?.backgroundColor = .clear
        
        //setup header album info view
        strechView = StrechView()
        
        if !ADTool.shareInstance.hasPurchasedNoAds{
             strechView?.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 240)
        }else{
             strechView?.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 200)
        }
       
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.tableHeaderView = strechView
        tableView.addSubview(strechView!)
        
        //setup passed variables to headerview
        strechView?.albumName.text = passedAlbumName
        strechView?.artistName.text = passedArtistName
        strechView?.albumArtwork.image = passedImage
        strechView?.albumDate.text = passedDate
        
        // adding album tracks to album object
        AlbumTracks = passedAlbums.filter{$0.album == passedAlbumName}
        
        if let colors = strechView?.albumArtwork.image?.getColors()
        {
            statusBarColor = colors.backgroundColor
            strechView?.colorView.backgroundColor = colors.backgroundColor
            UIApplication.shared.statusBarView?.backgroundColor = colors.backgroundColor
            strechView?.albumName.textColor = colors.primaryColor
            strechView?.artistName.textColor = colors.secondaryColor
            strechView?.albumDate.textColor = colors.minorColor
        }
        
        if (strechView?.colorView.backgroundColor?.isDark)!
        {
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
            strechView?.turnBack.tintColor = .white
        }else{
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
            strechView?.turnBack.tintColor = .black
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(dissmisItself), name: Notification.Name(rawValue: "DismissItself"), object: nil)
        
        if TrackTool.shareInstance.isHidden
        {
            self.tableBottomConstrain.constant = 0
            self.view.layoutSubviews()
        }
        else
        {
            UIView.animate(withDuration: 0.3, animations:
                {
                    self.tableBottomConstrain.constant = -67
                    self.view.layoutSubviews()
            })
        }
        
//        adBanner.adSize = kGADAdSizeSmartBannerPortrait
//        adBanner.adUnitID = "ca-app-pub-3452453039969028/3119554337"
//        adBanner.delegate = self
//        adBanner.rootViewController = self
//        adBanner.load(GADRequest())
        
       
        
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
            self.tableTopConst.constant = 50
            self.view.layoutIfNeeded()
        }
        
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (statusBarColor != nil){
            UIApplication.shared.statusBarView?.backgroundColor = statusBarColor
        }
        if (strechView?.colorView.backgroundColor?.isDark)!
        {
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
            strechView?.turnBack.tintColor = .white
        }else{
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
            strechView?.turnBack.tintColor = .black
        }
        
        if TrackTool.shareInstance.isHidden
        {
            self.tableBottomConstrain.constant = 0
            self.view.layoutSubviews()
        }
        else
        {
            UIView.animate(withDuration: 0.3, animations:
                {
                    self.tableBottomConstrain.constant = -67
                    self.view.layoutSubviews()
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
        UIApplication.shared.statusBarView?.backgroundColor = .white
    }
    
    @objc func dissmisItself()
    {
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
        UIApplication.shared.statusBarView?.backgroundColor = .white
        navigationController?.popViewController(animated: true)
       
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "AlbumDetailsstartAds"), object: nil)
            } else {
                print("Reachable via Cellular")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "AlbumDetailsstartAds"), object: nil)
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
    }
    
    //                             <===================== TableView Configuration Section Begining =====================>
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        
        // Return to track count in album
        let count = AlbumTracks.count
        
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return CGFloat(1)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumSongs", for: indexPath) as! albumSongsCell
        let grabedAlbumtracks = AlbumTracks[indexPath.section]
        
        
        cell.songDuration.text = calculateSongDuration(track: grabedAlbumtracks)
        
        
        // Checking if album name is equal to Unknown, if it dosen't set tracks names related to track names in Album, else, file name in album.
        if !(passedAlbumName == "Unknown")
        {
            
            // <===================== Getting Track Number of All Album Tracks =====================>
            let indexOfTracks = AlbumTracks.firstIndex(of: grabedAlbumtracks)! + 1
            
            // Format Track Numbers With leading "0" such as 01, 02, 03  .....
            let formatedindex = String(format: "%02d", indexOfTracks)
            cell.songCount.text = formatedindex
            
            // <===================== Getting Names of All Album Tracks =====================>
            let indexOfTrackNames = grabedAlbumtracks.title
            cell.songName.text = indexOfTrackNames
            
            // <===================== Getting Artist of All Album Tracks =====================>
            let indexOfTrackArtist = grabedAlbumtracks.artist
            cell.artistName.text = indexOfTrackArtist
            return cell
        }
        else
        {
            // <===================== Getting Track Number of All Album Tracks =====================>
            let indexOfTracks = AlbumTracks.firstIndex(of: grabedAlbumtracks)! + 1
            // Format Track Numbers With leading "0" such as 01, 02, 03  .....
            let formatedindex = String(format: "%02d", indexOfTracks)
            cell.songCount.text = formatedindex
            
            // <===================== Getting Names of All Album Tracks =====================>
            let indexOfTrackNames = grabedAlbumtracks.fileName
            cell.songName.text = indexOfTrackNames
            
            // <===================== Getting Artist of All Album Tracks =====================>
            let indexOfTrackArtist = grabedAlbumtracks.artist
            cell.artistName.text = indexOfTrackArtist
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        TrackTool.shareInstance.playlist.removeAll()
        TrackTool.shareInstance.playlist = AlbumTracks
        
        let track = AlbumTracks[indexPath.section]
        TrackTool.shareInstance.playTrack(track: track)
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.tryToDrawOnTheWindow()
        
        UIView.animate(withDuration: 0.3, animations:
            {
                self.tableBottomConstrain.constant = -67
                self.view.layoutSubviews()
        })
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePlayer"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateIcon"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "showPlayer"), object: nil)
        TrackTool.shareInstance.isHidden = false
    }
    
    //                             <===================== TableView Configuration Section End =====================>
}






class albumSongsCell: UITableViewCell
{
    @IBOutlet weak var songCount: UILabel!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var songDuration: UILabel!
}

extension AlbumDetailsViewController: UITableViewDelegate, UITableViewDataSource
{

    
}
