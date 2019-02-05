//
//  SongListForPlaylistViewController.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 04/02/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import UIKit

class SongListForPlaylistViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var tracks = [Track]()
    var searchTrack = [Track]()
    var searching = false
    var checked: [Track] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tracks =  TrackTool.shareInstance.tracks.sorted { $0.fileName < $1.fileName}
        dump(tracks)
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.allowsMultipleSelection = true
        
    }
    
    @IBAction func DoneAdding(_ sender: Any)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "PlaylistCreation") as! PlaylistCreationViewController
        
        newViewController.passedTracks = checked
        dismiss(animated: true, completion: nil)
    }
    
    // <================================== tableView Configuration Beginning ================================>
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchCell
        let songs = tracks[indexPath.section]
        

      
        //checking if currently search track on search bar. If it does re-index list due to search element
        if searching
        {
            let searchsongs = searchTrack[indexPath.section]
            
            if checked.contains(searchsongs){
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
            DispatchQueue.main.async
                {
                    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                    let fileURL = documentsDirectory.appendingPathComponent("artwork/" + searchsongs.fileName)
                    
                    if FileManager.default.fileExists(atPath: fileURL.path)
                    {
                        let image = loadImageFromDiskWith(fileName: searchsongs.fileName)
                        
                        cell.artwork.image = image
                    }
                    else
                    {
                        cell.artwork.image = UIImage(named: "artwork")
                    }
                    
            }
            cell.songName.text = searchsongs.fileName
            
        }
        // Else reserve original list of tracks
        else
        {
            if checked.contains(songs){
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
            DispatchQueue.main.async
            {
                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let fileURL = documentsDirectory.appendingPathComponent("artwork/" + songs.fileName)
                
                if FileManager.default.fileExists(atPath: fileURL.path)
                {
                    let image = loadImageFromDiskWith(fileName: songs.fileName)
                    
                    cell.artwork.image = image
                }
                else
                {
                    cell.artwork.image = UIImage(named: "artwork")
                }
                
            }
            cell.songName.text = songs.fileName
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) {
            if(!checked.contains(tracks[indexPath.section])){
                cell.accessoryType = .checkmark
                checked.append(tracks[indexPath.section])
                dump(checked)
            }else{
                cell.accessoryType = .none
                checked = checked.filter({$0 != tracks[indexPath.section]})
                dump(checked)
                
           
            }
            
        }
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
    
    // <================================== tableView Configuration End ================================>
    
    
    // <================================== searchBar Configuration Beginning ================================>
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        searchTrack = tracks.filter({$0.fileName.lowercased().contains(searchText.lowercased())})
        searching = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.endEditing(true)
        searchBar.text = ""
        tableView.reloadData()
    }
    // <================================== searchBar Configuration End ================================>
    
}



class SearchCell: UITableViewCell{
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var songName: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        artwork.image = nil
    }
}
