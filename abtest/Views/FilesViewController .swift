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




class FilesViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource {


    
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var heightAtIndexPath = NSMutableDictionary()
    var timer = Timer()
    var observerAdded = false
    var firstTime = true
    var isHidden = true
    let cellReuseIdentifier = "SongCell"
    var tracks = [Track]()
    var documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    let fileManager = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
     
         loadTracks()
    
        //change statusbar color back to original
        print("FirstTime:", firstTime)
        

        if #available(iOS 11, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        }
        NotificationCenter.default.addObserver(self, selector: #selector(loadTracks), name: Notification.Name(rawValue: "loadtracks"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(showMusicPlayer), name: Notification.Name(rawValue: "showMusicPlayer"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(playnext), name: NSNotification.Name(rawValue: trackFinish), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePlayer"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateIcon"), object: nil)
        print("Music Finished Observer added")
        if !firstTime {
            print("viewWillAppaer")
            
        }
        UIApplication.shared.statusBarView?.backgroundColor = .white
        tracks.sort { $0.fileName < $1.fileName}
    
        
    }
    
    
    @objc func playnext()
    {
    TrackTool.shareInstance.nextTrack()
    }
    
    @objc func loadTrack()
    {
    print("salam")
    }
    
    //listing tracks from documents folder
    @objc func loadTracks() {
        tracks.removeAll()
        TrackModel.getTracks { (tracksData: [Track]) in
            //print(tracksData)
            print("tracksData count: \(tracksData.count)")

            for track in tracksData
            {
                if tracks.contains(where: { $0.fileName == track.fileName }) {

                    //print("it contains: \(track.fileName)")
                } else {
                    tracks.append(track)
                   // print("it dosen't contains: \(track.fileName)")
                }

                //let t = tracksData[2]
                //print("Name: \(t.title), Artist: \(t.artist)")
                
            }
          
        }
        TrackTool.shareInstance.tracks = tracks.sorted { $0.fileName < $1.fileName }
        self.tableView.reloadData()

    }
    
 
    
    //number of table cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {

        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tracks.count
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
            TrackTool.shareInstance.pauseTrack()
            TrackTool.shareInstance.tracks.removeAll()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "hidePlayerWithAnimation"), object: nil)
                self.isHidden = false
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
        self.present(vc, animated: true, completion: nil)
    }
    
    //configure tableView with custom cell and track detals
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell") as! SongCell
        let track = tracks[indexPath.section]
        DispatchQueue.main.async {
            cell.cellimageView.image = UIImage(data: track.artwork!)
        }
        //cell.trackTitle.minimumScaleFactor = 0.5
       // cell.trackTitle.adjustsFontSizeToFitWidth = true
        cell.trackTitle.text = track.fileName
        return cell
    }

    //make tableview row editable
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        // action one
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            tableView.beginUpdates()
            
            let track = self.tracks[indexPath.section]
            self.removeImageLocalPath(localPathName: track.fileName + ".mp3")
            
            self.tracks.remove(at: indexPath.section)
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            self.tableView.deleteSections(indexSet, with: .fade)
            tableView.endUpdates()
            TrackTool.shareInstance.tracks = self.tracks
            DispatchQueue.main.async {
                
                if !self.isHidden
                {
                    let track = TrackTool.shareInstance.getTrackMessage().trackModel
                    
                       NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePlayer"), object: nil)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePlayer"), object: nil)
                        TrackTool.shareInstance.playTrack(track: track!)
                    }
                    else
                    {
                      NotificationCenter.default.post(name: Notification.Name(rawValue: "hidePlayerWithAnimation"), object: nil)
                        self.isHidden = true
                        self.firstTime = true
                        self.tableViewBottom.constant = 0
                        self.tableView.layoutIfNeeded()
                    }
            
                NotificationCenter.default.post(name: Notification.Name(rawValue: "AlbumLoadTrack"), object: nil)
                self.tableView.reloadData()
            }
        })
        deleteAction.backgroundColor = UIColor(red:0.94, green:0.20, blue:0.20, alpha:1.0)
        
        let editAction = UITableViewRowAction(style: .default, title: "Rename", handler: { (action, indexPath) in
            let track = self.tracks[indexPath.section]
            let alert = UIAlertController(title: nil, message: "Please input track name.", preferredStyle: UIAlertControllerStyle.alert)
            
            
            
            let action = UIAlertAction(title: "Done", style: .default)
            {
                (alertAction) in
                let textField = alert.textFields![0] as UITextField
                self.renameFileLocalPath(originalName: track.fileName + ".mp3", newName: textField.text! + ".mp3")
                track.fileName = textField.text!
                
                
                
                if let index = self.tracks.index(of: track){
                    self.tracks[index] = track
                    TrackTool.shareInstance.tracks = self.tracks
                   NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePlayer"), object: nil)
                }
                
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
            
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in}
            
            alert.addTextField { (textField) in
                textField.text = track.fileName
            }
            
            alert.addAction(action)
            alert.addAction(cancel)
            self.present(alert, animated:true, completion: nil)
            
            tableView.beginUpdates()
            tableView.endUpdates()
        })
        editAction.backgroundColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
        
        return [deleteAction,editAction]
    }
    
    
    
    //remove file function
    func removeImageLocalPath(localPathName: String) {
        let filemanager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let destinationPath = documentsPath.appendingPathComponent(localPathName)
        do { try filemanager.removeItem(atPath: destinationPath)
            print("Deleted")
        }
        catch { print("Not Deleted") }
    }

    func renameFileLocalPath(originalName: String, newName: String){
        let filemanager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let originalNamedes = documentsPath.appendingPathComponent(originalName)
        let newNamedes = documentsPath.appendingPathComponent(newName)
        do {try filemanager.moveItem(atPath: originalNamedes, toPath: newNamedes)
            print("file is renamed")
        }catch{print("couldn't renamed!")}
    }

    
}



//pressing on table cell
extension FilesViewController {
    
 

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let track = tracks[indexPath.section]
        TrackTool.shareInstance.playTrack(track: track)
       
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.tryToDrawOnTheWindow()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePlayer"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateIcon"), object: nil)

        if firstTime {
          
            
            UIView.animate(withDuration: 0.3, animations: {
                self.tableViewBottom.constant = -67
                self.view.layoutIfNeeded()
            })
            self.firstTime = false
             NotificationCenter.default.post(name: Notification.Name(rawValue: "showPlayer"), object: nil)
            isHidden = false
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
    
    override func remoteControlReceived(with event: UIEvent?) {

        guard let event = event else {
            print("No event")
            return
        }

        guard event.type == UIEventType.remoteControl else {
            print("Received other control type")
            return
        }

        switch event.subtype {
        case UIEventSubtype.remoteControlPlay:
            print("play")
            TrackTool.shareInstance.playCurrnetTrack()
        case UIEventSubtype.remoteControlPause:
            TrackTool.shareInstance.pauseTrack()
            //timer.invalidate()
            print("pause")
        case UIEventSubtype.remoteControlNextTrack:
            TrackTool.shareInstance.nextTrack()
            print("next")
        case UIEventSubtype.remoteControlPreviousTrack:
            determinePreviousPressed()
            print("previous")
        default:
            print("")
        }
    }
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

        
        trackTitle.text = track.fileName
        cellimageView.image = UIImage(data: track.artwork!)
        
        /*
         let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
         if let documentDirectoryURL: NSURL = urls.first as NSURL? {
         
         let playYoda = documentDirectoryURL.appendingPathComponent(track.fileName + ".mp3")
         let asset = AVURLAsset(url: playYoda!)
         let audioDuration = asset.duration
         let audioDurationSeconds = CMTimeGetSeconds(audioDuration)
         let total = getFormatTime(timerInval: audioDurationSeconds)
         time.text = total
         }
         */
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
