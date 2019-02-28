//
//  AlbumsViewController.swift
//  abtest
//
//  Created by Nijat Muzaffarli on 09/09/2018.
//  Copyright © 2018 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Reachability

class AlbumsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate
{
    enum ObfuscatedConstants {
        static let obfuscatedString: [UInt8] = [34, 17, 93, 37, 21, 28, 72, 23, 20, 22, 72, 125, 103, 122, 80, 94, 80, 80, 68, 114, 73, 73, 114, 92, 92, 87, 95, 78, 66, 83, 120, 96, 119, 82, 90, 87, 86, 66]
    }
    
    @IBOutlet var tableTopConst: NSLayoutConstraint!
    @IBOutlet var adBanner: GADBannerView!
    @IBOutlet weak var tablePlaceholder: UIView!
    @IBOutlet weak var tableView: UITableView!
    let reachability = Reachability()!
    let obfuscator = Obfuscator()
    var strechView: StrechView?
    var tracks = [Track]()
    var heightAtIndexPath = NSMutableDictionary()
    @IBOutlet weak var bottomConstrain: NSLayoutConstraint!

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadTracks()
        tableView.dataSource = self
        tableView.delegate = self
        
        if #available(iOS 11, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        }
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadTracks), name: Notification.Name(rawValue: "AlbumLoadTrack"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeAds), name: Notification.Name(rawValue: "AlbumsViewRemoveAds"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = .white
        
        if TrackTool.shareInstance.isHidden
        {
            self.bottomConstrain.constant = 0
            self.view.layoutSubviews()
        }
        else
        {
            UIView.animate(withDuration: 0.3, animations:
                {
                    self.bottomConstrain.constant = 67
                    self.view.layoutSubviews()
            })
        }
        reloadPlaceholder()
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
    
    @objc func removeAds(){
        if adBanner != nil{
            adBanner.removeFromSuperview()
        }
        self.tableTopConst.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func reloadPlaceholder()
    {
        if tableView.numberOfSections <= 0
        {
            tablePlaceholder.isHidden = false
        }else{
            tablePlaceholder.isHidden = true
        }
    }
    
    @objc func loadTracks()
    {
        tracks.removeAll()
        tracks += TrackTool.shareInstance.tracks
        tracks = tracks.sorted { $0.album < $1.album}
        
        self.tableView.reloadData()
        reloadPlaceholder()
    }
    // <================================== tableView Configuration ================================>
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return 1
    }
    
    @IBAction func showMusicLoader(_ sender: Any)
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc : SongServerViewController = mainStoryboard.instantiateViewController(withIdentifier: "SongServer") as! SongServerViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        let albumcount = tracks.unique{$0.album}.count
        return albumcount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell") as! AlbumCell
        
        // Get list of each album with album name
        let trackuniqe =  tracks.unique{$0.album}
        
        // Pass list to indexpath
        let albumcountimage = trackuniqe[indexPath.section]
        
        // Add each album artwork to cellView
        DispatchQueue.main.async
        {
            
            if !(albumcountimage.album == "Unknown")
            {
                var image = loadImageFromDiskWith(fileName: albumcountimage.fileName)
                let imagesize = image?.size
                UIGraphicsBeginImageContext(imagesize!)
                image?.draw(in: CGRect(x: 0, y: 0, width: imagesize?.width ?? 0.0, height: imagesize?.height ?? 0.0))
                image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext();
                
                cell.albumArtwork.image = image
            }
            else{ cell.albumArtwork.image = UIImage(named: "artwork")}
            
           
        }
        
        //Init Album name and track count dictionary
        var counts: [String: Int] = [:]
        
        // Group Album names with occurence time in list with album name element
        tracks.forEach{counts[$0.album, default:0] += 1}
        
        // (Direct Sorting not avaiable in Swift therefore we will make sorted tuilp of dictionary)
        let sorted = counts.sorted { $0.key < $1.key }
        
        // List Names from tulip by alphabetic order
        let keysArraySorted = Array(sorted.map({ $0.key }))
        
        // List Song counts from tulip by alphabetic order of names of songs
        let valuesArraySorted = Array(sorted.map({ String($0.value) }))
        
        // Add each name and count to cellView
        cell.albumName.text = keysArraySorted[indexPath.section]
        cell.songCount.text = "Count: " + valuesArraySorted[indexPath.section]
        
        return cell
    }
    
    // Configurating album views
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let album = tracks.unique{$0.album}[indexPath.section]
        
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AlbumDetails") as! AlbumDetailsViewController
        
        if album.album == "Unknown"
        {
             newViewController.passedImage = UIImage(named: "artwork")
             newViewController.passedAlbumName = "Unknown"
             newViewController.passedArtistName = "Unknown"
             newViewController.passedDate = "Unkown"
             newViewController.passedAlbums = tracks
        }
        else
        {
            newViewController.passedAlbums = tracks
            newViewController.passedImage = loadImageFromDiskWith(fileName: album.fileName)
            newViewController.passedArtistName = album.artist
            newViewController.passedAlbumName = album.album
            newViewController.passedDate = album.recordTime
        }
        navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete Album", handler: { (action, indexPath) in
            
            tableView.beginUpdates()
            let trackuniqe =  self.tracks.unique{$0.album}
            let album = trackuniqe[indexPath.section]
            
            // grabbing album tracks from local track list
            let AlbumTracks = self.tracks.filter{$0.album == album.album}
            
            // removing each track with album artwork
            AlbumTracks.forEach{ element in
                self.removeTrackLocalPath(localPathName: element.fileName + ".mp3")
                self.removeAlbumArtwork(localPathName: element.fileName)
               
                for playlist in PlaylistTool.shareInstance.playlists
                {
                    if let index = playlist.tracks.firstIndex(where: {$0.fileName == element.fileName})
                    {
                        print(index)
                        print("contains: ", element.fileName)
                        playlist.tracks.remove(at: index)
                        print("removed: ", element.fileName)
                        playlist.songCount -= 1
                        playlist.totalTime = calculateTotalTime(tracks: playlist.tracks)
                    }
                }
                
                if TrackTool.shareInstance.playlist.contains(element){
                    TrackTool.shareInstance.playlist.removeAll(where: {$0.fileName == element.fileName})
                }
            }
            self.tracks.removeAll{ $0.album == album.album }
            // clear grabbed track list
            
            
            TrackTool.shareInstance.tracks = self.tracks
            
             // remove section from tableView
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            self.tableView.deleteSections(indexSet, with: .fade)
            
            //First,checking that if miniPlayer is hidden for not playing song automaticlly
            if !TrackTool.shareInstance.isHidden
            {
                
                if(TrackTool.shareInstance.track.trackModel?.album == album.album)
                {
                        TrackTool.shareInstance.stop()
                        TrackTool.shareInstance.playlist.removeAll()
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "hidePlayerWithAnimation"), object: nil)
                        TrackTool.shareInstance.isHidden = true
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "loadtracks"), object: nil)
                        UIView.animate(withDuration: 0.3, animations: {
                            self.bottomConstrain.constant = 0
                            self.view.layoutSubviews()
                        })
                }else{
                    TrackTool.shareInstance.playlist.removeAll{ $0.album == album.album }
                    // Getting trackIndex of currently playing song in the background
                    let aa = TrackTool.shareInstance.findCurrentTrackIndex()
                    // Assigning grabed trackIndex to main trackIndex
                    TrackTool.shareInstance.trackIndex = aa
                }
            }

            NotificationCenter.default.post(name: Notification.Name(rawValue: "loadtracks"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadPlaylistTable"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateRemovedTracks-PlaylistDetailsView"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateUsedSize"), object: nil)
            
            let DocumentsDirectorya = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
            let ArchiveURLa = DocumentsDirectorya.appendingPathComponent("Playlists")
            NSKeyedArchiver.archiveRootObject(PlaylistTool.shareInstance.playlists, toFile: ArchiveURLa.path)
            
            let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
            let ArchiveURL = DocumentsDirectory.appendingPathComponent("Tracks")
            NSKeyedArchiver.archiveRootObject(TrackTool.shareInstance.tracks, toFile: ArchiveURL.path)
            
            tableView.endUpdates()
            self.reloadPlaceholder()
        })
        
        deleteAction.backgroundColor = UIColor(red:0.94, green:0.20, blue:0.20, alpha:1.0)
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(5)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70
    }
    
    private func tableView(_ tableView: UITableView, willDisplay cell: SongCell, forRowAt indexPath: IndexPath)
    {
        let height = NSNumber(value: Float(cell.frame.size.height))
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }
    
    // <================================== tableView Configuration ================================>
    
    func removeTrackLocalPath(localPathName: String) {
        let filemanager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let destinationPath = documentsPath.appendingPathComponent("tracks/" + localPathName)
        do { try filemanager.removeItem(atPath: destinationPath)
            print("Deleted")
        }
        catch { print("Not Deleted") }
    }
    
    func removeAlbumArtwork(localPathName: String)
    {
        let filemanager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let destinationPath = documentsPath.appendingPathComponent("artwork/" + localPathName)
        do { try filemanager.removeItem(atPath: destinationPath)
            print("Deleted")
        }
        catch { print("Not Deleted") }
    }
    
    func getFilePath(track: Track) -> URL{
        let ab = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: ab)
        
        guard let path = url.appendingPathComponent("tracks/" + track.fileName + ".mp3") else
        {
            return URL(string: "")!
        }
        return path
    }
}


class AlbumCell: UITableViewCell
{
    @IBOutlet weak var albumArtwork: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var songCount: UILabel!
    
    override func prepareForReuse() {
        albumArtwork.image = nil
    }
}
