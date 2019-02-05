//
//  PlaylistCreationViewController.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 03/02/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import UIKit

class PlaylistCreationViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: IntrinsicTableView!
    @IBOutlet weak var playlistName: UITextField!
    @IBOutlet weak var imageChangeButton: UIButton!
    @IBOutlet weak var playlistImage: UIImageView!
    var passedTracks = [Track]()
    let picker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //image picker delegate
        picker.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //customize playlist textfiled style
        playlistName.setBottomBorder(withColor: .lightGray)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        UIApplication.shared.statusBarView?.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        
        //viewHeight.constant = tableView.frame.size.height + (5 * 44)  
//        containerbOTTOM.constant = tableView.contentSize.height
//        view.layoutSubviews()
        super.viewDidAppear(true)
    }
    
    
    @IBAction func cancelCreation(_ sender: Any)
    {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func showSongList(_ sender: Any)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SongList") as! SongListForPlaylistViewController
        
        self.present(newViewController, animated: true, completion:nil)
        
    }
    
    
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
        
        return cell
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
    
}
