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
import SwiftyStoreKit
import Reachability
class ADTool: NSObject,GADBannerViewDelegate
{
    
    static let shareInstance = ADTool()
    var priceLabel = ""
    //
    var hasPurchasedNoAds = KeychainWrapper.standard.bool(forKey: "test") ?? false
    var reachability = Reachability()!
    
    func GetPrice()
    {
        if !hasPurchasedNoAds{
            SwiftyStoreKit.retrieveProductsInfo(["com.nicat.PipeMusicPlayer.removeAds"]) { result in
                if let product = result.retrievedProducts.first {
                    let priceString = product.localizedPrice!
                    print("Product: \(product.localizedDescription), price: \(priceString)")
                    self.priceLabel = "Remove Ads " + "(\(priceString))"
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAdLabel"), object: nil)
                }
                else if let invalidProductId = result.invalidProductIDs.first {
                    print("Invalid product identifier: \(invalidProductId)")
                    self.priceLabel = invalidProductId
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAdLabel"), object: nil)
                }
                else {
                    print("Error: \(result.error)")
                }
            }
        }
    }
    
    func CheckNetworkAndGetPrices()
    {
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
                self.GetPrice()
            } else {
                print("Reachable via Cellular")
                self.GetPrice()
            }
        }
        
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            self.priceLabel = "Remove Ads"
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    
    func SetupPriceString() -> String
    {
            return self.priceLabel
    }
    
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
