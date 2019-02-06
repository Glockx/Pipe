//
//  PlaylistCreationViewController.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 03/02/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import AVFoundation
import NotificationBannerSwift

class PlaylistCreationViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: IntrinsicTableView!
    @IBOutlet weak var playlistName: UITextField!
    @IBOutlet weak var imageChangeButton: UIButton!
    @IBOutlet weak var playlistImage: UIImageView!
    
    var playlistInit: Playlist? = nil
    var passedTracks = [Track]()
    let picker = UIImagePickerController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //image picker delegate
        picker.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isEditing = true
        tableView.remembersLastFocusedIndexPath = true
        //customize playlist textfiled style
        playlistName.setBottomBorder(withColor: .lightGray)
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        UIApplication.shared.statusBarView?.backgroundColor = .white
        tableView.reloadData()
    }
    
    
    @IBAction func savePlaylist(_ sender: Any)
    {
        
        if playlistName.text!.isEmpty || passedTracks.isEmpty
        {
            if (playlistName.text?.isEmpty)! {
                let banner = StatusBarNotificationBanner(title: "Playlist Title Is Missing",style: .warning)
                banner.show()
            }else if passedTracks.isEmpty
            {
                let banner = StatusBarNotificationBanner(title: "Please Add Song To The Playlist",style: .warning)
                banner.show()
            }
        }
        else
        {
            
            initPlaylist(handleComplete: saveData)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadPlaylistTable"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func initPlaylist(handleComplete:(()->()))
    {
        
        // TimeStamp
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let timeStamp = formatter.string(from: date)
        
        let uuid = NSUUID().uuidString.lowercased()
        if playlistImage.image != nil
        {
            saveImage(imageName: "pl-ls" + String(passedTracks.count) + playlistName.text!, image: playlistImage.image!)
        }
        
        
        //Get total time of songs in the list
        let totalTime = calculateTotalTime(tracks: passedTracks)
        
        playlistInit = Playlist.init(name: playlistName.text!, songCount: passedTracks.count, tracks: passedTracks, artwork: nil, createdDay: timeStamp, totalTime: totalTime,uuid : uuid)
        PlaylistTool.shareInstance.playlists.append(playlistInit!)
        dump(PlaylistTool.shareInstance.playlists)
        
        handleComplete()
    }
    
    private func saveData()
    {
        let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let ArchiveURL = DocumentsDirectory.appendingPathComponent("Playlists")
        
        NSKeyedArchiver.archiveRootObject(PlaylistTool.shareInstance.playlists, toFile: ArchiveURL.path)
    }

    @IBAction func cancelCreation(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showSongList(_ sender: Any)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SongList") as! SongListForPlaylistViewController
        
        newViewController.checked = passedTracks
        self.present(newViewController, animated: true, completion:nil)
        
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {}
    
    // <============================== TableView Setup ==============================>
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        
        return passedTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCreationCell") as! PlaylisCreationTableCell
        
        let tracks = passedTracks[indexPath.section]
        
        DispatchQueue.main.async
            {
                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let fileURL = documentsDirectory.appendingPathComponent("artwork/" + tracks.fileName)
                
                if FileManager.default.fileExists(atPath: fileURL.path)
                {
                    let image = loadImageFromDiskWith(fileName: tracks.fileName)
                    
                    cell.artwork.image = image
                }
                else
                {
                    cell.artwork.image = UIImage(named: "artwork")
                }
                
        }
        cell.trackName.text = tracks.fileName
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        
        let tracks = passedTracks[sourceIndexPath.section]
        passedTracks.remove(at: sourceIndexPath.section)
        passedTracks.insert(tracks, at: destinationIndexPath.section)
        tableView.reloadData()
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(5)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44
    }
    
     func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
     func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // <=============================================================================>
    
    
    // <============================== Image Picker Setup ==============================>
    @IBAction func changePlaylistImage(_ sender: Any)
    {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have perission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            playlistImage.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    // <=============================================================================>
    
    

    // Close keyboaed when click to Done
    @IBAction func done(_ sender: UITextField)
    {
        sender.resignFirstResponder()
    }
    
}

class PlaylisCreationTableCell: UITableViewCell
{
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var trackName: UILabel!
    
    
    override func prepareForReuse() {
        imageView?.image = nil
    }
}
