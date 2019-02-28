//
//  PlaylistViewController.swift
//  abtest
//
//  Created by Nijat Muzaffarli on 09/09/2018.
//  Copyright © 2018 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import SwiftyUI
import GoogleMobileAds
import Reachability
class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,GADBannerViewDelegate {

    enum ObfuscatedConstants {
        static let obfuscatedString: [UInt8] = [34, 17, 93, 37, 21, 28, 72, 23, 20, 22, 72, 125, 103, 122, 80, 94, 80, 80, 68, 114, 73, 73, 114, 92, 92, 87, 95, 78, 76, 81, 127, 98, 123, 82, 83, 81, 85, 68]
    }
    let reachability = Reachability()!
    @IBOutlet var tableTopConst: NSLayoutConstraint!
    @IBOutlet var adBanner: GADBannerView!
    @IBOutlet weak var tableBottomConstrain: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playlistPlaceholder: UIView!
    var obfuscator = Obfuscator()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if #available(iOS 11, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        }
        //PlaylistsViewRemoveAds
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: Notification.Name(rawValue: "ReloadPlaylistTable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeAds), name: Notification.Name(rawValue: "PlaylistsViewRemoveAds"), object: nil)
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
                ADTool().showBanner(adBanner: self.adBanner, rootController: self, bannerID: Obfuscator().reveal(key: ObfuscatedConstants.obfuscatedString), bannerSize: kGADAdSizeSmartBannerPortrait)
            } else {
                print("Reachable via Cellular")
                ADTool().showBanner(adBanner: self.adBanner, rootController: self, bannerID: Obfuscator().reveal(key: ObfuscatedConstants.obfuscatedString), bannerSize: kGADAdSizeSmartBannerPortrait)
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

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = .white
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
        reloadPlaceholder()
    }
    
    @objc func removeAds(){
        if adBanner != nil{
            adBanner.removeFromSuperview()
        }
        self.tableTopConst.constant = 0
        self.view.layoutIfNeeded()
        
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
    
    func reloadPlaceholder()
    {
        if tableView.numberOfSections <= 0 {
            playlistPlaceholder.isHidden = false
        }else{
            playlistPlaceholder.isHidden = true
        }
    }
    
    @objc func reloadTable()
    {
        PlaylistTool.shareInstance.playlists = PlaylistTool.shareInstance.playlists
        tableView.reloadData()
        reloadPlaceholder()
    }
    // <================================== tableView Configuration Begining ================================>
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return PlaylistTool.shareInstance.playlists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell") as! PlaylistCell
        let playlists = PlaylistTool.shareInstance.playlists[indexPath.section]
        cell.playButton.tag = indexPath.section
        cell.playButton.addTarget(self, action: #selector(playPlaylist), for: .touchUpInside)
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let fileURL = documentsDirectory!.appendingPathComponent("artwork/" + playlists.uuid)
        
        if FileManager.default.fileExists(atPath: fileURL.path)
        {
            let size = CGSize(width: 90, height: 90)
            
            var image = loadImageFromDiskWith(fileName: playlists.uuid)
            let imagesize = image?.size
            UIGraphicsBeginImageContext(imagesize!)
            image?.draw(in: CGRect(x: 0, y: 0, width: imagesize?.width ?? 0.0, height: imagesize?.height ?? 0.0))
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            cell.playlistImage.image = image?.reSize(toFill: size)
            //print(cell.playlistImage.contentClippingRect)
        }
        else
        {
            cell.playlistImage.image = UIImage(named: "artwork")

        }
        cell.detailsText.text = "Count: " + String(playlists.songCount)
        cell.totalDuration.text = playlists.totalTime
        cell.playlistName.text = playlists.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(5)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 90
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete Playlist", handler: { (action, indexPath) in
            
            let playlist = PlaylistTool.shareInstance.playlists[indexPath.section]
            
            if TrackTool.shareInstance.currentPlaylistUiid == PlaylistTool.shareInstance.playlists[indexPath.section].uuid
            {
                TrackTool.shareInstance.stop()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "hidePlayerWithAnimation"), object: nil)
            }
            
            PlaylistTool.shareInstance.playlists.removeAll{$0.uuid == playlist.uuid}
            
            
            // remove section from tableView
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            self.tableView.deleteSections(indexSet, with: .fade)
            tableView.reloadData()
            
            
            let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
            let ArchiveURL = DocumentsDirectory.appendingPathComponent("Playlists")
            NSKeyedArchiver.archiveRootObject(PlaylistTool.shareInstance.playlists, toFile: ArchiveURL.path)
            self.reloadPlaceholder()
        })
        
        deleteAction.backgroundColor = UIColor(red:0.94, green:0.20, blue:0.20, alpha:1.0)
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let playlist = PlaylistTool.shareInstance.playlists[indexPath.section]
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "PlaylistDetailsViewController") as! PlaylistDetailsViewController
        
        newViewController.passedPlaylistName = playlist.name
        newViewController.passedPlaylist = playlist
        newViewController.passedSongCount = playlist.songCount
        newViewController.passedTimeStamp = playlist.createdDay
        newViewController.passedTotalTime = playlist.totalTime
        newViewController.passedImage = loadImageFromDiskWith(fileName: playlist.uuid)
        
        navigationController?.pushViewController(newViewController, animated: true)
    }
    
    
    
    // <================================== tableView Configuration End ================================>
    @IBAction func goToCreation(_ sender: Any)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "PlaylistCreation") as! PlaylistCreationViewController
        self.present(newViewController, animated: true)
    }
    
    @objc func playPlaylist(sender: UIButton)
    {
        print(sender.tag)
        TrackTool.shareInstance.playlist.removeAll()
        TrackTool.shareInstance.playlist = PlaylistTool.shareInstance.playlists[sender.tag].tracks
        
        let track = PlaylistTool.shareInstance.playlists[sender.tag].tracks[0]
        TrackTool.shareInstance.playTrack(track: track)
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.tryToDrawOnTheWindow()
        
        TrackTool.shareInstance.currentPlaylistUiid = PlaylistTool.shareInstance.playlists[sender.tag].uuid
        
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
}

class PlaylistCell: UITableViewCell
{
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var playlistName: UILabel!
    @IBOutlet weak var detailsText: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var totalDuration: UILabel!
    
    override func prepareForReuse() {
        playlistImage.image = nil
    }
}
