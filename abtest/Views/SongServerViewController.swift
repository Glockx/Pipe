//
//  SongServerViewController.swift
//  abtest
//
//  Created by Nijat Muzaffarli on 09/09/2018.
//  Copyright © 2018 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import GCDWebServer
import Alamofire
class SongServerViewController: UIViewController {
    @IBOutlet weak var LinkField: UITextField!
    
    @IBOutlet weak var progressLabel: UILabel!
    var davServer: GCDWebServer?
    var documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    
    @IBOutlet weak var serverLabel: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serverTextField.adjustsFontSizeToFitWidth = true
        // Do any additional setup after loading the view.
        initServer()
        hideKeyboardWhenTappedAround()
    }
    
    @IBOutlet weak var serverTextField: UITextField!
    
    func initServer()
    {
        davServer = GCDWebUploader(uploadDirectory: documentsPath!)
        
        
        DispatchQueue.main.async {
            self.davServer?.start(withPort: 8080, bonjourName: "web upload")
            self.serverTextField.text = self.davServer?.serverURL?.absoluteString
        }
        
    }
    
    @IBAction func TransferDone(_ sender: Any)
    {
        davServer?.stop()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadPressed(_ sender: Any)
    {
       
        startDownload(audioUrl: LinkField.text!)
    }
    
    
    func startDownload(audioUrl:String) -> Void {
        let fileUrl = self.getSaveFileUrl(fileName: audioUrl)
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(audioUrl, to:destination)
            .downloadProgress { (progress) in
                self.progressLabel.text = (String)(progress.fractionCompleted.nextDown)
            }
            .responseData { (data) in
                self.progressLabel.text = "Completed!"
        }
    }
   
    
    func getSaveFileUrl(fileName: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let nameUrl = URL(string: fileName)
        let fileURL = documentsURL.appendingPathComponent((nameUrl?.lastPathComponent)!)
        NSLog(fileURL.absoluteString)
        return fileURL;
    }
    
}

