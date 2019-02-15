//
//  SettingsViewController.swift
//  abtest
//
//  Created by Nijat Muzaffarli on 09/09/2018.
//  Copyright © 2018 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import Eureka
import MessageUI

class SettingsViewController: FormViewController, MFMailComposeViewControllerDelegate
{
    @IBOutlet weak var tableBottomConstrain: NSLayoutConstraint!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        loadTable()
        NotificationCenter.default.addObserver(self, selector: #selector(updateSizes), name: NSNotification.Name(rawValue: "updateUsedSize"), object: nil)
    }

   @objc func updateSizes()
    {
        let usedByPipe: LabelRow = form.rowBy(tag: "UsedbyPipe")!
        let totalUsed: LabelRow = form.rowBy(tag: "TotalFree")!
        
        totalUsed.reload()
        usedByPipe.reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if TrackTool.shareInstance.isHidden
        {
            self.tableBottomConstrain.constant = 0
            self.view.layoutSubviews()
        }
        else
        {
            UIView.animate(withDuration: 0.3, animations:
                {
                    self.tableBottomConstrain.constant = 67
                    self.view.layoutSubviews()
            })
        }
    }

    func loadTable()
    {
        form +++ Section("General")
        <<< ButtonRow()
        {
            $0.title = "Sleep Timer"
            $0.cellStyle = .default
        }.cellUpdate { cell, row in
            cell.height = ({return 50})
            cell.textLabel?.textColor = UIColor(named: "textGray")
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            cell.textLabel?.textAlignment = .left
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.image = UIImage(named: "timer")
            cell.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            let itemSize = CGSize.init(width: 20, height: 20)
            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
            let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
            cell.imageView?.image!.draw(in: imageRect)
            cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();
            cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = UIColor(named: "lightBlue")
            cell.accessoryType = .disclosureIndicator
        }.onCellSelection { cell, row in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "Timer") as! TimerViewController
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
            <<< ButtonRow(){
                $0.title = "Delete All Tracks"
                $0.cellStyle = .default
                }.cellUpdate{cell,row in
                    cell.height = ({return 50})
                    cell.textLabel?.textColor = UIColor(named: "textGray")
                    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                    cell.textLabel?.textAlignment = .left
                    cell.imageView?.contentMode = .scaleAspectFit
                    cell.imageView?.image = UIImage(named: "deleteAll")
                    cell.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
                    let itemSize = CGSize.init(width: 20, height: 20)
                    UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
                    let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
                    cell.imageView?.image!.draw(in: imageRect)
                    cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
                    UIGraphicsEndImageContext();
                    cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
                    cell.imageView?.tintColor = UIColor(named: "lightBlue")
                    cell.accessoryType = .disclosureIndicator
                }.onCellSelection{cell,row in
                    let alert = UIAlertController(title: "Delete All Tracks", message: "Are you sure to delete all tracks?", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in}
                    alert.addAction(cancel)
                    
                    let ok = UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                        
                        //hide miniplayer if on view hierarchy and stop playing
                        if !TrackTool.shareInstance.isHidden{
                            TrackTool.shareInstance.stop()
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "hidePlayerWithAnimation"), object: nil)
                            self.tableBottomConstrain.constant = 0
                            self.view.layoutSubviews()
                            TrackTool.shareInstance.isHidden = true
                        }
                        
                        for track in TrackTool.shareInstance.tracks
                        {
                            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                            let fileURL = documentsDirectory.appendingPathComponent("tracks/" + track.fileName).path
                            
//                            if FileManager().fileExists(atPath: fileURL)
//                            {
//                                self.removeAlbumArtwork(localPathName: track.fileName)
//                            }
                            for playlist in PlaylistTool.shareInstance.playlists{
                                if let index = playlist.tracks.firstIndex(where: {$0.fileName == track.fileName})
                                {
                                    playlist.tracks.remove(at: index)
                                    playlist.songCount -= 1
                                    playlist.totalTime = calculateTotalTime(tracks: playlist.tracks)
                                }
                            }
                            self.removeAlbumArtwork(localPathName: track.fileName)
                            self.removeImageLocalPath(localPathName: track.fileName + ".mp3")
                        }
                        
                        //remove all tracks from array list
                        TrackTool.shareInstance.tracks.removeAll()
                        
                        //update playlist list and playlist details view
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadPlaylistTable"), object: nil)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "closePlaylistDetails"), object: nil)
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "AlbumLoadTrack"), object: nil)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "DismissItself"), object: nil)
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "loadtracks"), object: nil)
                        
                        // save playlist changes
                        let DocumentsDirectorya = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
                        let ArchiveURLa = DocumentsDirectorya.appendingPathComponent("Playlists")
                        NSKeyedArchiver.archiveRootObject(PlaylistTool.shareInstance.playlists, toFile: ArchiveURLa.path)
                        /// =================================== Update Playlists End ================================
                        
                        // Save changes to documents
                        let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
                        let ArchiveURL = DocumentsDirectory.appendingPathComponent("Tracks")
                        NSKeyedArchiver.archiveRootObject(TrackTool.shareInstance.tracks, toFile: ArchiveURL.path)
                        
                        self.updateSizes()
                    })
                    
                    alert.addAction(ok)
                    
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true)
                    })
            }
            
            <<< ButtonRow(){
                $0.title = "Delete All Playlists"
                $0.cellStyle = .default
                }.cellUpdate{cell,row in
                    cell.height = ({return 50})
                    cell.textLabel?.textColor = UIColor(named: "textGray")
                    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                    cell.textLabel?.textAlignment = .left
                    cell.imageView?.contentMode = .scaleAspectFit
                    cell.imageView?.image = UIImage(named: "deletePlaylist")
                    cell.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
                    let itemSize = CGSize.init(width: 20, height: 20)
                    UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
                    let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
                    cell.imageView?.image!.draw(in: imageRect)
                    cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
                    UIGraphicsEndImageContext();
                    cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
                    cell.imageView?.tintColor = UIColor(named: "lightBlue")
                    cell.accessoryType = .disclosureIndicator
                }.onCellSelection{cell,row in
                    
                    let alert = UIAlertController(title: "Delete All Playlists", message: "Are you sure to delete all playlists?", preferredStyle: .alert)
                    
                    let ok = UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                        
                        //checking if any playlist is being played, if statement is true stop track and hide mini player.
                        if !TrackTool.shareInstance.currentPlaylistUiid.isEmpty
                        {
                            TrackTool.shareInstance.stop()
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "hidePlayerWithAnimation"), object: nil)
                            self.tableBottomConstrain.constant = 0
                            self.view.layoutSubviews()
                            TrackTool.shareInstance.isHidden = true
                        }
                        
                        // for each playlist in the playlist array, check if they have artwork. If it does delete than.
                        for playlist in PlaylistTool.shareInstance.playlists
                        {
                            
                            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                            let fileURL = documentsDirectory.appendingPathComponent("artwork/" + playlist.uuid).path
                            
                            if FileManager().fileExists(atPath: fileURL)
                            {
                                self.removeAlbumArtwork(localPathName: playlist.uuid)
                            }
                            
                        }
                        
                        //remove all playlists
                        PlaylistTool.shareInstance.playlists.removeAll()
                        
                        //update playlist list and playlist details view
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadPlaylistTable"), object: nil)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "closePlaylistDetails"), object: nil)
                        
                        // save updates
                        let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
                        let ArchiveURLa = DocumentsDirectory.appendingPathComponent("Playlists")
                        NSKeyedArchiver.archiveRootObject(PlaylistTool.shareInstance.playlists, toFile: ArchiveURLa.path)
                        
                        self.updateSizes()
                    })
                    
                    alert.addAction(ok)
                    
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in}
                    
                    alert.addAction(cancel)
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true)
                    })
            }
            
            +++ Section(header: "Feedback", footer: "")
            <<< ButtonRow(){
                $0.title = "Share"
                $0.cellStyle = .default
                }.cellUpdate{cell, row in
                    cell.height = ({return 50})
                    cell.textLabel?.textColor = UIColor(named: "textGray")
                    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                    cell.textLabel?.textAlignment = .left
                    cell.imageView?.contentMode = .scaleAspectFit
                    cell.imageView?.image = UIImage(named: "share")
                    let itemSize = CGSize.init(width: 20, height: 20)
                    UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
                    let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
                    cell.imageView?.image!.draw(in: imageRect)
                    cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
                    UIGraphicsEndImageContext();
                    cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
                    cell.imageView?.tintColor = UIColor(named: "lightBlue")
                    cell.accessoryType = .disclosureIndicator
                }.onCellSelection{cell,row in
                    //TODO: Change Link Of Website
                    let activityVC = UIActivityViewController(activityItems: ["Pipe Music Player: \n \nhttps://itunes.apple.com/us/app/dailyw/id1295015357?ls=1&mt=8"], applicationActivities: nil)
                    activityVC.popoverPresentationController?.sourceView = self.view
                    
                    self.present(activityVC, animated: true, completion: nil)
            }
            
            
        <<< ButtonRow()
            {
            $0.title = "Send Feedback"
            $0.cellStyle = .default
        }.cellUpdate { cell, row in
            cell.height = ({return 50})
            cell.textLabel?.textColor = UIColor(named: "textGray")
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            cell.textLabel?.textAlignment = .left
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.image = UIImage(named: "email")
            let itemSize = CGSize.init(width: 20, height: 20)
            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
            let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
            cell.imageView?.image!.draw(in: imageRect)
            cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();
            cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = UIColor(named: "lightBlue")
            cell.accessoryType = .disclosureIndicator
        }.onCellSelection { cell, row in

            let mailComposeViewController = self.configureMailController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {

            }
        }
            
            <<< ButtonRow()
                {
                $0.title = "Report Problem"
                $0.cellStyle = .default
                }.cellUpdate { cell, row in
                    cell.height = ({return 50})
                    cell.textLabel?.textColor = UIColor(named: "textGray")
                    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                    cell.textLabel?.textAlignment = .left
                    cell.imageView?.contentMode = .scaleAspectFit
                    cell.imageView?.image = UIImage(named: "bug")
                    let itemSize = CGSize.init(width: 20, height: 20)
                    UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
                    let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
                    cell.imageView?.image!.draw(in: imageRect)
                    cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
                    UIGraphicsEndImageContext();
                    cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
                    cell.imageView?.tintColor = UIColor(named: "lightBlue")
                    cell.accessoryType = .disclosureIndicator
                }.onCellSelection { cell, row in
                    guard let url = URL(string: "https://form.jotform.me/90441652592458") else { return }
                    UIApplication.shared.open(url)
            }
            
            +++ Section(header: "Storage", footer: "- Used by Pipe* indicator only includes app documents such as: tracks, artworks and etc.")
            <<< LabelRow()
                {
                    $0.title = "Device Storage: "
                }.cellUpdate{cell,row in
                    cell.height = ({return 30})
                    let main_string = "- Device Storage: " + UIDevice.current.totalDiskSpaceInGB
                    let string_to_color = UIDevice.current.totalDiskSpaceInGB
                    
                    let range = (main_string as NSString).range(of: string_to_color)
                    
                    let attribute = NSMutableAttributedString.init(string: main_string)
                    attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.darkGray , range: range)
                    
                    cell.textLabel?.attributedText = attribute
                    cell.textLabel?.textColor = .lightGray
                    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            }
            
            <<< LabelRow("TotalFree").cellUpdate{cell,row in
                cell.height = ({return 30})
                let main_string = "- Used Total Storage: " + UIDevice.current.usedDiskSpaceInGB
                let string_to_color = UIDevice.current.usedDiskSpaceInGB
                let range = (main_string as NSString).range(of: string_to_color)
                let attribute = NSMutableAttributedString.init(string: main_string)
                attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.darkGray , range: range)
                
                cell.textLabel?.attributedText = attribute
                cell.textLabel?.textColor = .lightGray
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            }
            
            <<< LabelRow("UsedbyPipe")
                {
                    $0.title = "- Used by Pipe: "
                }.cellUpdate{cell,row in
                    var size:Int64 = 0
                    cell.height = ({return 30})
                    cell.textLabel?.textColor = .lightGray
                    let documentsPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                    do{
                        size =  Int64(try FileManager().allocatedSizeOfDirectory(at: documentsPathURL!))
                        print(size)
                    }catch{
                        print("error")
                    }
                    
                    let main_string = "- Used by Pipe: " + UIDevice().MBFormatter(size) + " MB"
                    let string_to_color = UIDevice().MBFormatter(size) + " MB"
                    
                    let range = (main_string as NSString).range(of: string_to_color)
                    
                    let attribute = NSMutableAttributedString.init(string: main_string)
                    attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.darkGray , range: range)
                    
                    cell.textLabel?.attributedText = attribute
                    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            }
            
            +++ Section(){
                $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.footer?.height = { CGFloat.leastNormalMagnitude }
                
            }
        <<< LabelRow() {
            if let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
                if let bundle = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
                    {
                    $0.title = "Pipe - " + version + " - Build: " + bundle
                }
                $0.cellStyle = .default

            }
        }.cellUpdate { cell, row in
            //cell.height = ({return 20})
            cell.textLabel?.textColor = .lightGray
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
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
    
    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        mailComposerVC.setToRecipients(["nicat7546@gmail.com"])
        mailComposerVC.setSubject("Pipe Feedback")
        mailComposerVC.setMessageBody("", isHTML: false)

        return mailComposerVC
    }


    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
