//
//  SongServerViewController.swift
//  abtest
//
//  Created by Nijat Muzaffarli on 09/09/2018.
//  Copyright © 2018 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import GCDWebServer

class SongServerViewController: UIViewController
{
    
    @IBOutlet weak var browserImage: UIImageView!
    
    @IBOutlet weak var LinkField: UITextField!
    @IBOutlet weak var progressLabel: UILabel!
    var davServer: GCDWebUploader?
    var documentsPath = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.path
    
    @IBOutlet weak var serverLabel: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        browserImage.image = browserImage.image?.withRenderingMode(.alwaysTemplate)
//        browserImage.tintColor = UIColor.lightGray
        serverTextField.adjustsFontSizeToFitWidth = true
        DispatchQueue.main.async
            {
        GCDWebUploaderTool.shareInstance.startServer
            {
                self.serverTextField.text = GCDWebUploaderTool.shareInstance.davServer?.serverURL?.absoluteString
            }
        }
        hideKeyboardWhenTappedAround()
        
    }
    
    @IBOutlet weak var serverTextField: UITextField!

    var filePath: String {
        //1 - manager lets you examine contents of a files and folders in your app; creates a directory to where we are saving it
        let manager = FileManager.default
        //2 - this returns an array of urls from our documentDirectory and we take the first path
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        print("this is the url path in the documentDirectory \(String(describing: url))")
        //3 - creates a new path component and creates a new file called "Data" which is where we will store our Data array.
        return (url!.appendingPathComponent("Data").path)
    }
    
    private func saveData()
    {
        let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let ArchiveURL = DocumentsDirectory.appendingPathComponent("Tracks")
        
        NSKeyedArchiver.archiveRootObject(TrackTool.shareInstance.tracks, toFile: ArchiveURL.path)
    }
    
    func loadSongs(handleComplete:(()->()))
    {
       
        TrackTool.shareInstance.tracks.removeAll()
        TrackModel.getTracks { (tracksData: [Track]) in
            for track in tracksData
            {
                if TrackTool.shareInstance.tracks.contains(where: { $0.fileName == track.fileName })
                {
                    
                }
                else
                {
                    TrackTool.shareInstance.tracks.append(track)
                }
            }
        }
        handleComplete()
    }
    
    @IBAction func TransferDone(_ sender: Any)
    {
        GCDWebUploaderTool.shareInstance.stopServer()
        loadSongs(handleComplete: saveData)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "loadtracks"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "AlbumLoadTrack"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateUsedSize"), object: nil)
        dismiss(animated: true, completion: nil)
    }
}

