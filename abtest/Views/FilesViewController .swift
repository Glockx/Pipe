//
//  FilesViewController.swift
//  abtest
//
//  Created by Nijat Muzaffarli on 09/09/2018.
//  Copyright © 2018 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import AVFoundation
import MarqueeLabel
import ViewAnimator
import SPPermission
import GoogleMobileAds
import Reachability

class FilesViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,GADBannerViewDelegate {

    enum ObfuscatedConstants {
        static let obfuscatedString: [UInt8] = [34, 17, 93, 37, 21, 28, 72, 23, 20, 22, 72, 125, 103, 122, 80, 94, 80, 80, 68, 114, 73, 73, 114, 92, 92, 87, 95, 78, 77, 82, 118, 107, 127, 85, 90, 86, 82, 64]
    }
    
    let reachability = Reachability()!
    @IBOutlet weak var tablePlaceholder: UIView!
    @IBOutlet weak var placeholderFileImage: UIImageView!
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var adBanner: GADBannerView!
    @IBOutlet var tableTopConst: NSLayoutConstraint!
    var adBannerView: GADBannerView?
    var searchTrack = [Track]()
    var searching = false
    let searchBar = UISearchBar()
    var heightAtIndexPath = NSMutableDictionary()
    var timer = Timer()
    var observerAdded = false
    var firstTime = true
    let cellReuseIdentifier = "SongCell"
    var tracks = [Track]()
    var documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    let fileManager = FileManager.default
    let obfuscator = Obfuscator()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.barTintColor = .white
        self.tabBarController?.tabBar.isTranslucent = false
        
        
        placeholderFileImage.image = placeholderFileImage.image?.withRenderingMode(.alwaysTemplate)
        placeholderFileImage.tintColor = UIColor.lightGray
        
        tableView.dataSource = self
        tableView.delegate = self
     
        self.loadTracks()
        
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
        
        if #available(iOS 11, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        }
        
        self.searchBar.delegate = self
        
        searchBar.placeholder = "Search"
        searchBar.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 64)
        searchBar.barStyle = .default
        searchBar.searchBarStyle = .minimal
        searchBar.isTranslucent = false
        searchBar.barTintColor = .white
        let cancelButtonAttributes = [NSAttributedStringKey.foregroundColor: UIColor.lightGray]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelButtonAttributes, for: .normal)
        tableView.tableHeaderView = searchBar
        
        if tableView.numberOfSections > 0
        {
            tableView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: UITableViewScrollPosition.top, animated: false)
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadTracks), name: Notification.Name(rawValue: "loadtracks"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(showMusicPlayer), name: Notification.Name(rawValue: "showMusicPlayer"), object: nil)
        
       // NotificationCenter.default.addObserver(self, selector: #selector(playnext), name: NSNotification.Name(rawValue: trackFinish), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableAds), name: NSNotification.Name(rawValue: "FilesViewRemoveAds"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addObser), name: NSNotification.Name(rawValue: "addobser"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(justEnteredToApp), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        //MusicPlayerTool.shared.play()
    }

    @objc func disableAds(){
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
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
    
    @objc func addObser()
    {
       // NotificationCenter.default.addObserver(self, selector: #selector(playnext), name: NSNotification.Name(rawValue: trackFinish), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        if UserDefaults.isFirstLaunch(){
            //,.contacts,.calendar,.microphone,.motion
            SPPermission.Dialog.request(with: [.camera, .photoLibrary, .mediaLibrary], on: self)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        
        if TrackTool.shareInstance.isHidden
        {
            self.tableViewBottom.constant = 0
            self.view.layoutSubviews()
        }
        else
        {
            UIView.animate(withDuration: 0.3, animations:
                {
                    self.tableViewBottom.constant = -67
                    self.view.layoutSubviews()
            })
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePlayer"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateIcon"), object: nil)
        //UIApplication.shared.statusBarView?.backgroundColor = .white
        tracks.sort { $0.fileName < $1.fileName}
        reloadPlaceHolder()
    }
    
    
    @objc func justEnteredToApp()
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePlayer"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateIcon"), object: nil)
    }
    
    
    func reloadPlaceHolder()
    {
        if tableView.numberOfSections <= 0
        {
            print("table is empty")
            tablePlaceholder.isHidden = false
        }
        else
        {
            tablePlaceholder.isHidden = true
            print("table view cell count:", tableView.numberOfSections)
        }
    }
    
    @objc func playnext()
    {
    TrackTool.shareInstance.nextTrack()
    }
    
    //listing tracks from documents folder
    @objc func loadTracks() {

        tracks = TrackTool.shareInstance.tracks.sorted { $0.album < $1.album}
        tableView.reloadData()
        reloadPlaceHolder()
    }
    
    //number of table cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {

        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int
    {
        if searching{
            return searchTrack.count
        }else{
            return tracks.count
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(5)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 47
    }
    
    private func tableView(_ tableView: UITableView, willDisplay cell: SongCell, forRowAt indexPath: IndexPath) {
        let height = NSNumber(value: Float(cell.frame.size.height))
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }

    @IBAction func showMusicLoader(_ sender: Any)
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc : SongServerViewController = mainStoryboard.instantiateViewController(withIdentifier: "SongServer") as! SongServerViewController
        self.present(vc, animated: true, completion:
            {
            self.timer.invalidate()
                if TrackTool.shareInstance.trackPlayer?.isPlaying ?? false{
                    TrackTool.shareInstance.pauseTrack()
                }
            TrackTool.shareInstance.playlist.removeAll()
            TrackTool.shareInstance.tracks.removeAll()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "hidePlayerWithAnimation"), object: nil)
            
            TrackTool.shareInstance.isHidden = true
            self.firstTime = true
            self.tableViewBottom.constant = 0
            self.tableView.layoutIfNeeded()
                
            TrackTool.shareInstance.tracks = self.tracks
            
        })
    }
    
   @objc func showMusicPlayer()
   {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc : MusicPlayerViewController = mainStoryboard.instantiateViewController(withIdentifier: "MusicControl") as! MusicPlayerViewController
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: trackFinish), object: nil)
        self.present(vc, animated: true, completion: nil)
    }
    
    //configure tableView with custom cell and track detals
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell") as! SongCell
        let track = tracks[indexPath.section]
        
        if searching
        {
            let searchsongs = searchTrack[indexPath.section]
            DispatchQueue.main.async
                {
                    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                    let fileURL = documentsDirectory.appendingPathComponent("artwork/" + searchsongs.fileName)
                    if FileManager.default.fileExists(atPath: fileURL.path)
                    {
                        let image = loadImageFromDiskWith(fileName: searchsongs.fileName)
                        
                        cell.cellimageView.image = image
                    }
                    else
                    {
                        cell.cellimageView.image = UIImage(named: "artwork")
                    }
                    cell.trackTitle.text = searchsongs.fileName
            }
        }
        else
        {
            DispatchQueue.main.async
                {
                    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                    let fileURL = documentsDirectory.appendingPathComponent("artwork/" + track.fileName)
                    
                    if FileManager.default.fileExists(atPath: fileURL.path)
                    {
                        var image = loadImageFromDiskWith(fileName: track.fileName)
                                        let imagesize = image?.size
                                        UIGraphicsBeginImageContext(imagesize!)
                                        image?.draw(in: CGRect(x: 0, y: 0, width: imagesize?.width ?? 0.0, height: imagesize?.height ?? 0.0))
                                        image = UIGraphicsGetImageFromCurrentImageContext()
                                        UIGraphicsEndImageContext();
                        cell.cellimageView.image = image
                    }
                    else{
                        cell.cellimageView.image = UIImage(named: "artwork")
                    }
            }
            cell.trackTitle.text = track.fileName
        }
        

        return cell
    }

    //make tableview row editable
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        // =================== Delete Action ==========================
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            
            
                //currently selected track from table list
                let track = self.tracks[indexPath.section]
            
            // traversing through playlists in playlist object
            for playlist in PlaylistTool.shareInstance.playlists
            {
                    //remove track from playlist
                if let index = playlist.tracks.firstIndex(where: {$0.fileName == track.fileName})
                    {
                        print(index)
                        print("contains: ",track.fileName)
                        playlist.tracks.remove(at: index)
                        print("removed", track.fileName)
                        playlist.songCount -= 1
                        playlist.totalTime = calculateTotalTime(tracks: playlist.tracks)
                        
                    }
            }
                //dump(PlaylistTool.shareInstance.playlists)
                //remove track file from documents
                self.removeImageLocalPath(localPathName: track.fileName + ".mp3")
                self.removeAlbumArtwork(localPathName: track.fileName)
                //remove track from track list
                self.tracks.remove(at: indexPath.section)
            
            // !IMPORTANT: It's should be checked that removed track is last track of array for restarting index array to first item in the list otherwise it won't play first song in the list (Dont't remove this line)
            if !TrackTool.shareInstance.isHidden
            {
                print("end index:",TrackTool.shareInstance.playlist.endIndex)
                print("current index:", TrackTool.shareInstance.findCurrentTrackIndex())
                if TrackTool.shareInstance.playlist.endIndex == TrackTool.shareInstance.findCurrentTrackIndex() + 1
                {
                    print("last track")
                    TrackTool.shareInstance.trackIndex = 0
                }
            }
            
            
                //getting section of currently selected track from table list
                let indexSet = IndexSet(arrayLiteral: indexPath.section)
                // remove section from tableView
                self.tableView.deleteSections(indexSet, with: .fade)
                
                //reload tracks array with new song list
                TrackTool.shareInstance.tracks = self.tracks
                if TrackTool.shareInstance.playlist.contains(track)
                {
                    
                    TrackTool.shareInstance.playlist.removeAll(where: {$0.fileName == track.fileName})
                }

                print("tracks count:", TrackTool.shareInstance.playlist.count)

                //reload table
                tableView.reloadData()
                self.reloadPlaceHolder()
            
                //First,checking that if miniPlayer is hidden for not playing song automaticlly
                if !TrackTool.shareInstance.isHidden
                {
                    //Getting the file path of currently playing song from Media Player for checking that is removed song being playing in the background
                    let musicPlayerCurrentSong = TrackTool.shareInstance.trackPlayer?.url
                    // Getting the file path of track from tableView
                    let indexPathCurrentSong = self.getFilePath(track: track)
                    print(indexPathCurrentSong)
                    
                    //Checking that Removed song is playing in the background
                    if(musicPlayerCurrentSong == indexPathCurrentSong)
                    {
                        // If track is playing, move to next song on the list, else don't
                        if (TrackTool.shareInstance.trackPlayer?.isPlaying)!
                        {
                            TrackTool.shareInstance.playCurrnetTrack()
                        }
                        // Update MiniPlayer
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePlayer"), object: nil)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateIcon"), object: nil)
                    }
                    else
                    {
                        // Getting trackIndex of currently playing song in the background
                        let aa = TrackTool.shareInstance.findCurrentTrackIndex()
                        // Assigning grabed trackIndex to main trackIndex
                        TrackTool.shareInstance.trackIndex = aa
                    }
                    
                    if TrackTool.shareInstance.playlist.isEmpty{
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "hidePlayerWithAnimation"), object: nil)
                        TrackTool.shareInstance.stop()
                        self.tableViewBottom.constant = 0
                        self.tableView.layoutIfNeeded()
                        TrackTool.shareInstance.isHidden = true
                    }
                }
                
                // Reload Album List
                NotificationCenter.default.post(name: Notification.Name(rawValue: "AlbumLoadTrack"), object: nil)
                //update playlist object and playlist view controller
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadPlaylistTable"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateRemovedTracks-PlaylistDetailsView"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateUsedSize"), object: nil)
            
                let DocumentsDirectorya = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
                let ArchiveURLa = DocumentsDirectorya.appendingPathComponent("Playlists")
                NSKeyedArchiver.archiveRootObject(PlaylistTool.shareInstance.playlists, toFile: ArchiveURLa.path)
                /// =================================== Update Playlists End ================================
            
                // Save changes to documents
                let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
                let ArchiveURL = DocumentsDirectory.appendingPathComponent("Tracks")
                NSKeyedArchiver.archiveRootObject(TrackTool.shareInstance.tracks, toFile: ArchiveURL.path)
        })
        deleteAction.backgroundColor = UIColor(red:0.94, green:0.20, blue:0.20, alpha:1.0)
        
        // =================== Rename Action ==========================
        let editAction = UITableViewRowAction(style: .default, title: "Rename", handler: { (action, indexPath) in
            let track = self.tracks[indexPath.section]
            let alert = UIAlertController(title: nil, message: "Please input track name.", preferredStyle: UIAlertControllerStyle.alert)
            
            
            
            let action = UIAlertAction(title: "Done", style: .default)
            {
                (alertAction) in
                
                let textField = alert.textFields![0] as UITextField
                self.renameFileLocalPath(originalName: track.fileName, newName: textField.text!)
                
                track.fileName = textField.text!
                
                if let index = self.tracks.index(of: track)
                {
                    self.tracks[index] = track
                    TrackTool.shareInstance.tracks = self.tracks
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePlayer"), object: nil)
                }
                
                for playlist in PlaylistTool.shareInstance.playlists
                {
                    if let index = playlist.tracks.firstIndex(where: {$0.uuid == track.uuid})
                    {
                        print(index)
                        playlist.tracks[index] = track
                        dump(playlist)
                    }
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "AlbumLoadTrack"), object: nil)
                //update playlist object and playlist view controller
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadPlaylistTable"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateRemovedTracks-PlaylistDetailsView"), object: nil)
                
               
                        let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
                        let ArchiveURL = DocumentsDirectory.appendingPathComponent("Tracks")
                        NSKeyedArchiver.archiveRootObject(TrackTool.shareInstance.tracks, toFile: ArchiveURL.path)
                        let ArchiveURLa = DocumentsDirectory.appendingPathComponent("Playlists")
                        NSKeyedArchiver.archiveRootObject(PlaylistTool.shareInstance.playlists, toFile: ArchiveURLa.path)
                self.tracks.sort { $0.fileName < $1.fileName}
                    tableView.reloadData()
            }
            
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in}
            
            alert.addTextField { (textField) in
                textField.text = track.fileName
            }
            
            alert.addAction(action)
            alert.addAction(cancel)
            self.present(alert, animated:true, completion: nil)
            
            
        })
        editAction.backgroundColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
        
        if searching == false{
            return [deleteAction,editAction]
        }else{
            return []
        }
        
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
    //remove file function
    func removeImageLocalPath(localPathName: String)
    {
        let filemanager = FileManager.default

        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent("tracks/")
        
        let destinationPath = fileURL.appendingPathComponent(localPathName).path
        do { try filemanager.removeItem(atPath: destinationPath)
            
            
        }
        catch { print("Not Deleted") }
    }
    //rename file
    func renameFileLocalPath(originalName: String, newName: String)
    {
        let filemanager = FileManager.default
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent("tracks/")
        
        let originalNamedes = fileURL.appendingPathComponent(originalName + ".mp3")
        let newNamedes = fileURL.appendingPathComponent(newName + ".mp3")
        
        do {
            try filemanager.moveItem(at: originalNamedes, to: newNamedes)
            print("file is renamed")
        }catch{
            print("couldn't renamed!")
            
        }
        
        let artworkUrl = documentsDirectory.appendingPathComponent("artwork/")
        
        let originalArtwork = artworkUrl.appendingPathComponent(originalName)
        let newArtwork = artworkUrl.appendingPathComponent(newName)
        
        do{
            try filemanager.moveItem(at: originalArtwork, to: newArtwork)
            print("Artwork is renamed")
        }catch{
            print("Artwork couldn't renamed!")
        }
    }
    
    
    func removeAlbumArtwork(localPathName: String)
    {
        let filemanager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let destinationPath = documentsPath.appendingPathComponent("artwork/" + localPathName)
        do { try filemanager.removeItem(atPath: destinationPath)
            print("deleted")
        }
        catch { print("Not Deleted") }
    }
    
    
    
    // <================================== searchBar Configuration Beginning ================================>
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        searchTrack = tracks.filter({$0.fileName.lowercased().contains(searchText.lowercased())})
        searchBar.showsCancelButton = true
        searching = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.endEditing(true)
        searchBar.text = ""
        searchBar.showsCancelButton = false
        tableView.reloadData()
    }
    
    // <================================== searchBar Configuration End ================================>
    
    
}



//pressing on table cell
extension FilesViewController {
    
 

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        tableView.deselectRow(at: indexPath, animated: true)
    
        if searching == false{
            TrackTool.shareInstance.playlist.removeAll()
            TrackTool.shareInstance.playlist = tracks
            let track = tracks[indexPath.section]
            
            TrackTool.shareInstance.playTrack(track: track)
            print("tableIndexPath: ", indexPath.section)
            let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.tryToDrawOnTheWindow()
            
            if (TrackTool.shareInstance.trackPlayer?.isPlaying)! && TrackTool.shareInstance.isHidden
            {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "showPlayer"), object: nil)
            }
            
            if firstTime
            {
                UIView.animate(withDuration: 0.3, animations:
                    {
                        self.tableViewBottom.constant = -67
                        self.view.layoutIfNeeded()
                })
                
                self.firstTime = false
                NotificationCenter.default.post(name: Notification.Name(rawValue: "showPlayer"), object: nil)
            }
            TrackTool.shareInstance.isHidden = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePlayer"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateIcon"), object: nil)
        }
        else
        {
            TrackTool.shareInstance.playlist.removeAll()
            TrackTool.shareInstance.playlist = tracks
            let track = searchTrack[indexPath.section]
            
            TrackTool.shareInstance.playTrack(track: track)
            print("tableIndexPath: ", indexPath.section)
            let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.tryToDrawOnTheWindow()
            
            if (TrackTool.shareInstance.trackPlayer?.isPlaying)! && TrackTool.shareInstance.isHidden
            {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "showPlayer"), object: nil)
            }
            
            if firstTime
            {
                UIView.animate(withDuration: 0.3, animations:
                    {
                        self.tableViewBottom.constant = -67
                        self.view.layoutIfNeeded()
                })
                
                self.firstTime = false
                NotificationCenter.default.post(name: Notification.Name(rawValue: "showPlayer"), object: nil)
            }
            TrackTool.shareInstance.isHidden = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePlayer"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateIcon"), object: nil)
        }
        
        
    }
    

    func determinePreviousPressed()
    {
        let track = TrackTool.shareInstance.getTrackMessage()
        if(TimeFormat.getFormatTime(timerInval: track.currentTime) == "0:00")
        {
            doubleTapped()
        }
        else
        {
            singleTapped()
        }
    }
    
    @objc func singleTapped() {
        
        TrackTool.shareInstance.playCurrentTrackAgain()
        //setupTrackDetails()
    }
    
    @objc func doubleTapped() {
        TrackTool.shareInstance.previousTrack()
        
    }
    
//    override func remoteControlReceived(with event: UIEvent?) {
//
//        guard let event = event else {
//            print("No event")
//            return
//        }
//
//        guard event.type == UIEventType.remoteControl else {
//            print("Received other control type")
//            return
//        }
//
//        switch event.subtype {
//        case UIEventSubtype.remoteControlPlay:
//            print("play")
//            TrackTool.shareInstance.playCurrnetTrack()
//        case UIEventSubtype.remoteControlPause:
//            TrackTool.shareInstance.pauseTrack()
//            //timer.invalidate()
//            print("pause")
//        case UIEventSubtype.remoteControlNextTrack:
//            TrackTool.shareInstance.nextTrack()
//            print("next")
//        case UIEventSubtype.remoteControlPreviousTrack:
//            determinePreviousPressed()
//            print("previous")
//        default:
//            print("")
//        }
//    }
}

class SongCell: UITableViewCell
{
    @IBOutlet weak var cellimageView: UIImageView!
    @IBOutlet weak var trackTitle: UILabel!

    let fileManager = FileManager.default


//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//    }

    func getFormatTime(timerInval: Float64) -> String {

        let min = Int(timerInval) / 60
        let sec = Int(timerInval) % 60
        return String(format: "%d:%02d", min, sec)
    }

    // Configure the cell...
    func configureTrackCell(track: Track) {

        
       // trackTitle.text = track.fileName
       // cellimageView.image = UIImage(data: track.artwork!)
        
        
         
        
    }

    func duration(for resource: String) -> Double {
        let asset = AVURLAsset(url: URL(fileURLWithPath: resource))
        return Double(CMTimeGetSeconds(asset.duration))
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        trackTitle.text = nil
        cellimageView.image = nil
    }

}
