//
//  PlaylistTool.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 03/02/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import Foundation
import UIKit
import NotificationBannerSwift
class PlaylistTool: NSObject
{
    enum UserValidationError: String, Error {
        case noFirstNameProvided = "Please insert your first name."
        case noLastNameProvided = "Please insert your last name."
        case noAgeProvided = "Please insert your age."
        case noEmailProvided = "Please insert your email."
    }
    
    static let shareInstance = PlaylistTool()
    var playlists = [Playlist]()
    
    //name: String, songCount: Int, tracks: [Track], artwork: Data?, createdDay: String, totalTime:String
    


}
