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
    @IBOutlet weak var tableBottom: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var NavigationBar: UINavigationItem!
    @IBOutlet weak var tableView: IntrinsicTableView!
    @IBOutlet weak var playlistName: UITextField!
    @IBOutlet weak var imageChangeButton: UIButton!
    @IBOutlet weak var playlistImage: UIImageView!
    /// Value in range 0...100 %
    typealias Percentage = Float
    var loadedImage: UIImage?
    var isCreationMode = false
    var playlistInit: Playlist? = nil
    var passedTracks = [Track]()
    var passedPlaylist: Playlist?
    var passedPlaylistName = ""
    var passedPlaylistImage: UIImage?
    let picker = UIImagePickerController()
    var selected = [Track]()
    var updatedPlaylist: Playlist?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //image picker delegate
        picker.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if isCreationMode{
            playlistName.text = passedPlaylistName
            playlistImage.image = passedPlaylistImage
            NavigationBar.title = "Update Playlist"
            loadedImage = loadImageFromDiskWith(fileName: (passedPlaylist?.uuid)!)
        }
        
        tableView.isEditing = false
        
        tableView.remembersLastFocusedIndexPath = true
        
        //customize playlist textfiled style
        playlistName.setBottomBorder(withColor: .lightGray)
       // self.hideKeyboardWhenTappedAround()
        
        print("is creation mode active: ", isCreationMode)
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        UIApplication.shared.statusBarView?.backgroundColor = .white
        tableView.reloadData()
    }
    
    @IBAction func deleteSelectedTracks(_ sender: UIButton)
    {

        //sender.isSelected = !sender.isSelected
        if !sender.isHidden{
            
            UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
                sender.isHidden = true
                sender.alpha = 1
                
            })
        }
        
        for track in selected{
            selected.removeAll(where: {$0.fileName == track.fileName})
            passedTracks.removeAll(where: {$0.fileName == track.fileName})
        }
        
        self.tableView.visibleCells.forEach {
            $0.accessoryType = .none
        }
        
        UIView.animate(withDuration: 0.3, animations:
            {
            self.tableBottom.constant = 0
            self.view.layoutSubviews()
        })
        
        tableView.reloadData()
    }
    
    @IBAction func reorderPressed(_ sender: UIButton)
    {
        
        sender.isSelected = !sender.isSelected
        
        if passedTracks.count > 2
        {
            sender.isUserInteractionEnabled = true
            if sender.isSelected {
                UIView.animate(withDuration: 0.3, animations: {
                    self.tableView.isEditing = true
                    sender.tintColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
                })
                
            }else
            {
                UIView.animate(withDuration: 0.3, animations: {
                    self.tableView.isEditing = false
                    sender.tintColor = .lightGray
                })
                
            }
        }
        else
        {
            sender.isUserInteractionEnabled = false
        }
        
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
            if isCreationMode == false{
                initPlaylist(handleComplete: saveData)
                
                self.dismiss(animated: true, completion: nil)
            }else{
                updatePlaylist(handleComplete: saveData)
                performSegue(withIdentifier: "fuckingUnwind2", sender: self)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadPlaylistDetailsView"), object: nil)
            }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadPlaylistTable"), object: nil)
          
            
            UIApplication.shared.keyWindow?.endEditing(true)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destVc = segue.destination as! PlaylistDetailsViewController
        
        destVc.passedPlaylistName = playlistName.text!
        destVc.passedSongCount = passedTracks.count
        destVc.passedPlaylist?.tracks = passedTracks
        destVc.passedImage = playlistImage.image
        destVc.passedTotalTime = calculateTotalTime(tracks: passedTracks)
    }
    
    
    // Updating Current Playlist
    func updatePlaylist(handleComplete:(()->()))
    {
        if playlistImage.image != nil
        {
            
            if (doImagesHaveSameMeta(image1: (loadedImage?.cgImage)!, image2: playlistImage.image!.cgImage!))
            {
                print("images are same")
            }else
            {
                print("Images are not same")
                removePlaylistAlbumArtwork(localPathName: (passedPlaylist?.uuid)!)
                saveImage(imageName: (passedPlaylist?.uuid)!, image: playlistImage.image!)
            }
        }
    
        
        //Get total time of songs in the list
        let totalTime = calculateTotalTime(tracks: passedTracks)
        
        
        playlistInit = Playlist.init(name: playlistName.text!, songCount: passedTracks.count, tracks: passedTracks, artwork: nil, createdDay: (passedPlaylist?.createdDay)!, totalTime: totalTime,uuid : (passedPlaylist?.uuid)!)
       
        if let row = PlaylistTool.shareInstance.playlists.firstIndex(where: {$0.uuid == passedPlaylist?.uuid})
        {
            PlaylistTool.shareInstance.playlists[row] = playlistInit!
            updatedPlaylist = playlistInit!
            //dump(PlaylistTool.shareInstance.playlists[row])
        }
        
        handleComplete()
    }
    
    // Creating New Playlist
    func initPlaylist(handleComplete:(()->()))
    {
        
        // TimeStamp
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let timeStamp = formatter.string(from: date)
        
        let uuid = NSUUID().uuidString.lowercased()
        
        print("uuid1: ",uuid)
        if playlistImage.image != nil
        {
            
            saveImage(imageName: uuid, image: playlistImage.image!)
        }
        
        
        //Get total time of songs in the list
        let totalTime = calculateTotalTime(tracks: passedTracks)
        
        playlistInit = Playlist.init(name: playlistName.text!, songCount: passedTracks.count, tracks: passedTracks, artwork: nil, createdDay: timeStamp, totalTime: totalTime,uuid : uuid)
        PlaylistTool.shareInstance.playlists.append(playlistInit!)
       // dump(PlaylistTool.shareInstance.playlists)
        
        handleComplete()
    }
    
    
    
    
    func removePlaylistAlbumArtwork(localPathName: String)
    {
        let filemanager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let destinationPath = documentsPath.appendingPathComponent("artwork/" + localPathName)
        do { try filemanager.removeItem(atPath: destinationPath)
            print("Deleted")
        }
        catch { print("Not Deleted") }
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
        newViewController.isEditingMode = true
        newViewController.passedTracks = passedTracks
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
                    var image = loadImageFromDiskWith(fileName: tracks.fileName)
                    let imagesize = image?.size
                    UIGraphicsBeginImageContext(imagesize!)
                    image?.draw(in: CGRect(x: 0, y: 0, width: imagesize?.width ?? 0.0, height: imagesize?.height ?? 0.0))
                    image = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext();
                    
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            //getting section of currently selected track from table list
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            
            self.passedTracks.remove(at: indexPath.section)
            // remove section from tableView
            self.tableView.deleteSections(indexSet, with: .fade)
        })
        deleteAction.backgroundColor = UIColor(red:0.94, green:0.20, blue:0.20, alpha:1.0)
        return [deleteAction]
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let cell = tableView.cellForRow(at: indexPath)
        {
            if(!selected.contains(passedTracks[indexPath.section]))
            {
                cell.accessoryType = .checkmark
                selected.append(passedTracks[indexPath.section])
            }
            else
            {
                cell.accessoryType = .none
                selected = selected.filter({$0 != passedTracks[indexPath.section]})
            }
            
        }
        
        if selected.count > 0 && deleteButton.alpha == 0
        {
            self.deleteButton.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.tableBottom.constant = 62
                self.deleteButton.alpha = 1
                self.view.layoutSubviews()
            })
            
        }
        
        
        if selected.count <= 0 {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.tableBottom.constant = 0
                self.deleteButton.alpha = 0
                self.view.layoutSubviews()
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4)
            {
                self.deleteButton.isHidden = true
            }
        }
        print(selected.count)
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
    
    enum error: Error{
        case error
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
