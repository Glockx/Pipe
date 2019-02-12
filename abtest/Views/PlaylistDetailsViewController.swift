//
//  PlaylistDetailsViewController.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 07/02/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import BCColor

class PlaylistDetailsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
{

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableBottomConst: NSLayoutConstraint!
    var HeaderView: PlaylistDetailsHeaderView?
    var passedPlaylistName = ""
    var passedTimeStamp = ""
    var passedImage: UIImage!
    var passedSongCount = 0
    var passedPlaylist: Playlist?
    var passedTotalTime = ""
    var statusBarColor: UIColor?
    var lbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let size = CGSize(width: 176, height: 166)
        //Adding Playlist Detail Header view to header view of tableView
        HeaderView = PlaylistDetailsHeaderView()
        HeaderView?.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 300)
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.tableHeaderView = HeaderView
        tableView.addSubview(HeaderView!)
        
        // Adding total time to the footer view of tableView
        addTotalTimeToTableView()
        
        // passing Details to PlaylistDetailsHeaderView
        HeaderView?.playlistName.text = passedPlaylistName
        HeaderView?.songCount.text = String(passedSongCount) + " Songs"
        
        if passedImage != nil{
            HeaderView?.playlistImage.image = passedImage.reSize(toFill: size)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeItSelf), name: Notification.Name(rawValue: "closePlaylistDetails"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToUpdate), name: Notification.Name(rawValue: "goToUpdate"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadItself), name: Notification.Name(rawValue: "reloadPlaylistDetailsView"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateRemovedTracks), name: Notification.Name(rawValue: "updateRemovedTracks-PlaylistDetailsView"), object: nil)
        
        // Checking that if mini player bar is on view hierarchy, if it does re-sizing table view according to size of miniPlayer view
        if TrackTool.shareInstance.isHidden
        {
            self.tableBottomConst.constant = 0
            self.view.layoutSubviews()
        }
        else
        {
            UIView.animate(withDuration: 0.3, animations:
                {
                    self.tableBottomConst.constant = -67
                    self.view.layoutSubviews()
            })
        }
    }
    
    
    @IBAction func unwindToVC2(segue:UIStoryboardSegue) {}
    
    @objc func reloadItself()
    {
        print("reloaded")
        
        passedPlaylist?.tracks = (passedPlaylist?.tracks)!
        let size = CGSize(width: 176, height: 166)
        HeaderView?.playlistName.text = passedPlaylistName
        HeaderView?.songCount.text = String(passedSongCount) + " Songs"
        if passedImage != nil
        {
            HeaderView?.playlistImage.image = passedImage?.reSize(toFill: size)
        }else{
            HeaderView?.playlistImage.image = UIImage(named: "artwork")
        }
        
        lbl.text = passedTotalTime
        tableView.reloadData()
    }
    
    
    @objc func updateRemovedTracks()
    {
        
        let playlist = PlaylistTool.shareInstance.playlists.first(where: {$0.uuid == passedPlaylist?.uuid})!
        print(playlist.uuid)
        HeaderView?.songCount.text = String(playlist.tracks.count) + " Songs"
        
        passedPlaylist?.tracks = playlist.tracks
        lbl.text = calculateTotalTime(tracks: playlist.tracks)
        self.tableView.reloadData()
        //dump(playlist.tracks)
    }
    
    @objc func goToUpdate()
    {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "PlaylistCreation") as! PlaylistCreationViewController
        
        newViewController.passedPlaylist = passedPlaylist
        newViewController.passedPlaylistName = passedPlaylistName
        newViewController.passedPlaylistImage = loadImageFromDiskWith(fileName: (passedPlaylist?.uuid)!)
        newViewController.passedTracks = (passedPlaylist?.tracks)!
        newViewController.isCreationMode = true
        
        if TrackTool.shareInstance.currentPlaylistUiid == passedPlaylist?.uuid
        {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "hidePlayerWithAnimation"), object: nil)
            TrackTool.shareInstance.stop()
            tableBottomConst.constant = 0
            view.layoutSubviews()
            TrackTool.shareInstance.isHidden = true
        }
        
        self.present(newViewController, animated: true, completion: nil)
    }
    
    
    @objc func buttonAction(_ sender: UIButton!) {
        print("Button tapped")
    }
    
    
    func addTotalTimeToTableView()
    {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 25))
        //        customView.backgroundColor = .white
        
        lbl = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 20))
        lbl.textAlignment = .center //For center alignment
        lbl.text = passedTotalTime
        lbl.textColor = .lightGray
        lbl.font = UIFont.systemFont(ofSize: 17)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(lbl)
        tableView.tableFooterView = customView
        
        lbl.centerXAnchor.constraint(equalTo: tableView.tableFooterView!.centerXAnchor).isActive = true
        lbl.centerYAnchor.constraint(equalTo: tableView.tableFooterView!.centerYAnchor).isActive = true
        lbl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        lbl.widthAnchor.constraint(equalToConstant: tableView.bounds.width).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        if TrackTool.shareInstance.isHidden
        {
            self.tableBottomConst.constant = 0
            self.view.layoutSubviews()
        }
        else
        {
            UIView.animate(withDuration: 0.3, animations:
                {
                    self.tableBottomConst.constant = -67
                    self.view.layoutSubviews()
            })
        }
    }
    
    
    @objc func closeItSelf()
    {
       
        navigationController?.popViewController(animated: true)
    }
    
    // <============================== TableView Setup ==============================>
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return 1
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        
        return (passedPlaylist?.tracks.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return CGFloat(1)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistDetailsCell") as! PlaylistDetailsCell
        
        let grabbedPlaylist = passedPlaylist?.tracks[indexPath.section]
        
        if !(grabbedPlaylist?.album == "Unknown")
        {
         // <===================== Getting Track Number of All Tracks =====================>
        let indexOfTracks = (passedPlaylist?.tracks.firstIndex(of: grabbedPlaylist!))! + 1
        
        // Format Track Numbers With leading "0" such as 01, 02, 03  .....
        let formatedindex = String(format: "%02d", indexOfTracks)
        cell.trackNumber.text = formatedindex
        
        // <===================== Getting Names of All Tracks =====================>
        let indexOfTrackNames = grabbedPlaylist?.title
        cell.TrackName.text = indexOfTrackNames
        
        // <===================== Getting Artist of All Tracks =====================>
        let indexOfTrackArtist = grabbedPlaylist?.artist
        cell.artistName.text = indexOfTrackArtist
        
        // <===================== Getting Artwork of All Tracks =====================>
        let indexOfTrackArtwork = grabbedPlaylist?.fileName
        DispatchQueue.main.async
            {
        var image = loadImageFromDiskWith(fileName: indexOfTrackArtwork!)
        
        let imagesize = image?.size
        UIGraphicsBeginImageContext(imagesize!)
        image?.draw(in: CGRect(x: 0, y: 0, width: imagesize?.width ?? 0.0, height: imagesize?.height ?? 0.0))
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        cell.artwork.image = image
        }
    }
        else
        {
            // <===================== Getting Track Number of All Tracks =====================>
            let indexOfTracks = (passedPlaylist?.tracks.firstIndex(of: grabbedPlaylist!))! + 1
            
            // Format Track Numbers With leading "0" such as 01, 02, 03  .....
            let formatedindex = String(format: "%02d", indexOfTracks)
            cell.trackNumber.text = formatedindex
            
                // <===================== Getting Names of All Tracks =====================>
            let indexOfTrackNames = grabbedPlaylist?.fileName
            cell.TrackName.text = indexOfTrackNames
            
            // <===================== Getting Artist of All Tracks =====================>
            let indexOfTrackArtist = grabbedPlaylist?.artist
            cell.artistName.text = indexOfTrackArtist
            
            // <===================== Getting Artwork of All Tracks =====================>
            let indexOfTrackArtwork = grabbedPlaylist?.fileName
            
            DispatchQueue.main.async
                {
                    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                    let fileURL = documentsDirectory.appendingPathComponent("artwork/" + indexOfTrackArtwork!)
                    
                    if FileManager.default.fileExists(atPath: fileURL.path)
                    {
                        var image = loadImageFromDiskWith(fileName: indexOfTrackArtwork!)
                        
                        let imagesize = image?.size
                        UIGraphicsBeginImageContext(imagesize!)
                        image?.draw(in: CGRect(x: 0, y: 0, width: imagesize?.width ?? 0.0, height: imagesize?.height ?? 0.0))
                        image = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext();
                        
                        cell.artwork.image = image
                    }else{
                        cell.artwork.image = UIImage(named: "artwork")
                    }
            }
        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        TrackTool.shareInstance.playlist.removeAll()
        TrackTool.shareInstance.playlist = passedPlaylist!.tracks
        
        let track = passedPlaylist?.tracks[indexPath.section]
        TrackTool.shareInstance.playTrack(track: track!)
        
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.tryToDrawOnTheWindow()
        
        TrackTool.shareInstance.currentPlaylistUiid = passedPlaylist!.uuid
        
        UIView.animate(withDuration: 0.3, animations:
            {
                self.tableBottomConst.constant = -67
                self.view.layoutSubviews()
        })
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePlayer"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateIcon"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "showPlayer"), object: nil)
        TrackTool.shareInstance.isHidden = false
    }
    // <=============================================================================>
    
    
}


class PlaylistDetailsCell: UITableViewCell
{
    @IBOutlet weak var trackNumber: UILabel!
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var TrackName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    override func prepareForReuse()
    {
        artwork.image = nil
    }
}
