//
//  AlbumsViewController.swift
//  abtest
//
//  Created by Nijat Muzaffarli on 09/09/2018.
//  Copyright © 2018 Nijat Muzaffarli. All rights reserved.
//

import UIKit

class AlbumsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
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
        
       NotificationCenter.default.addObserver(self, selector: #selector(loadTracks), name: Notification.Name(rawValue: "AlbumLoadTrack"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    }
    
    
    @objc func loadTracks()
    {
        tracks.removeAll()
        tracks += TrackTool.shareInstance.tracks
        tracks = tracks.sorted { $0.album < $1.album}
        
        self.tableView.reloadData()
        
    }
    // <================================== tableView Configuration ================================>
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return 1
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
            var AlbumTracks = self.tracks.filter{$0.album == album.album}
            
            // removing each track with album artwork
            AlbumTracks.forEach{ element in
                self.removeTrackLocalPath(localPathName: element.fileName + ".mp3")
                self.removeAlbumArtwork(localPathName: element.fileName)
               
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
            let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
            let ArchiveURL = DocumentsDirectory.appendingPathComponent("Tracks")
            NSKeyedArchiver.archiveRootObject(TrackTool.shareInstance.tracks, toFile: ArchiveURL.path)
            
            tableView.endUpdates()
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
        let destinationPath = documentsPath.appendingPathComponent(localPathName)
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
        
        guard let path = url.appendingPathComponent(track.fileName + ".mp3") else
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