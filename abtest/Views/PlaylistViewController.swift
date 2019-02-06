//
//  PlaylistViewController.swift
//  abtest
//
//  Created by Nijat Muzaffarli on 09/09/2018.
//  Copyright © 2018 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import SwiftyUI

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableBottomConstrain: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: Notification.Name(rawValue: "ReloadPlaylistTable"), object: nil)
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
        
    }
    
    @objc func reloadTable()
    {
        tableView.reloadData()
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
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let fileURL = documentsDirectory!.appendingPathComponent("artwork/" + "pl-ls" + String(playlists.songCount) + playlists.name)
        
        if FileManager.default.fileExists(atPath: fileURL.path)
        {
            let size = CGSize(width: 90, height: 90)
            
            let image = loadImageFromDiskWith(fileName: "pl-ls" + String(playlists.songCount) + playlists.name)
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
            PlaylistTool.shareInstance.playlists.removeAll{$0.uuid == playlist.uuid}
            
            // remove section from tableView
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            self.tableView.deleteSections(indexSet, with: .fade)
            tableView.reloadData()
            
            let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
            let ArchiveURL = DocumentsDirectory.appendingPathComponent("Playlists")
            
            NSKeyedArchiver.archiveRootObject(PlaylistTool.shareInstance.playlists, toFile: ArchiveURL.path)
            
        })
        
        deleteAction.backgroundColor = UIColor(red:0.94, green:0.20, blue:0.20, alpha:1.0)
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // <================================== tableView Configuration End ================================>
    @IBAction func goToCreation(_ sender: Any)
    {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "PlaylistCreation") as! PlaylistCreationViewController
        self.present(newViewController, animated: true)
        
    }
    
    
}

class PlaylistCell: UITableViewCell
{
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var playlistName: UILabel!
    @IBOutlet weak var detailsText: UILabel!
    
    @IBOutlet weak var totalDuration: UILabel!
    override func prepareForReuse() {
        playlistImage.image = nil
    }
}
