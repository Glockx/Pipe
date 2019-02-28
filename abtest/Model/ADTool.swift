//
//  ADTool.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 20/02/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import Foundation
import GoogleMobileAds
import SwiftKeychainWrapper


class ADTool: NSObject,GADBannerViewDelegate
{
    static let shareInstance = ADTool()
    
    
    var hasPurchasedNoAds = KeychainWrapper.standard.bool(forKey: "test") ?? false
    
    func showBanner(adBanner: GADBannerView,rootController: UIViewController,bannerID: String,bannerSize: GADAdSize)
    {
        if !hasPurchasedNoAds
        {
            
            adBanner.adSize = bannerSize
            adBanner.adUnitID = bannerID
            adBanner.delegate = rootController as? GADBannerViewDelegate
            adBanner.rootViewController = rootController
            adBanner.load(GADRequest())
        }
    }
    
}
