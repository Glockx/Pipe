//
//  GCDWebUploaderTool.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 27/02/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import Foundation
import GCDWebServer


class GCDWebUploaderTool: NSObject
{
    static let shareInstance = GCDWebUploaderTool()
    var davServer: GCDWebUploader?
    
    
    func startServer(handleComplete:(()->()))
    {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent("tracks/").path
        
        davServer = GCDWebUploader(uploadDirectory: fileURL)
        davServer?.allowedFileExtensions = ["mp3","flac"]
        
        self.davServer?.start(withPort: 8080, bonjourName: "web upload")
        handleComplete()
    }
    
    func stopServer(){
        davServer?.stop()
    }
}
