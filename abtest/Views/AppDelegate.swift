//
//  AppDelegate.swift
//  abtest
//
//  Created by Nijat Muzaffarli on 08/09/2018.
//  Copyright © 2018 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import MarqueeLabel
import SnapKit
import GoogleMobileAds
import Firebase
import SwiftyStoreKit
import StoreKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    enum ObfuscatedConstants {
        static let obfuscatedString: [UInt8] = [34, 17, 93, 37, 21, 28, 72, 23, 20, 22, 72, 125, 103, 122, 80, 94, 80, 80, 68, 114, 73, 73, 114, 92, 92, 87, 95, 31, 65, 86, 126, 97, 127, 81, 90, 86, 90, 69]
    }
    
    var window: UIWindow?
    var currentPlaying: MiniPlayerView!
    var hasadded = false
    let obfuscator = Obfuscator()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Creating tracks and artwork folder
        let file = URL.createFolder(folderName: "tracks")
        let folder = URL.createFolder(folderName: "artwork")
        
        //UserDefaults.standard.removeObject(forKey: "hasBeenLaunchedBeforeFlag")
        
        //Configure Admob
        GADMobileAds.configure(withApplicationID: Obfuscator().reveal(key: ObfuscatedConstants.obfuscatedString))
        
        //Configure Firebase
        FirebaseApp.configure()
        
        //Make application status bar white
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.white
        
        //Load tracks and playlists from documents
        TrackTool.shareInstance.tracks = loadSongs() ?? TrackTool.shareInstance.tracks
        PlaylistTool.shareInstance.playlists = loadPlaylists() ?? PlaylistTool.shareInstance.playlists
        
        // see notes below for the meaning of Atomic / Non-Atomic
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        
        //dump(PlaylistTool.shareInstance.playlists)
        #if DEBUG
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection10.bundle")?.load()
        #endif
        return true
    }
    
    func loadSongs() -> [Track]!
    {
        let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let ArchiveURL = DocumentsDirectory.appendingPathComponent("Tracks")
        return NSKeyedUnarchiver.unarchiveObject(withFile: ArchiveURL.path) as? [Track]
    }
    
    func loadPlaylists() -> [Playlist]!
    {
        let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let ArchiveURL = DocumentsDirectory.appendingPathComponent("Playlists")
        
        return NSKeyedUnarchiver.unarchiveObject(withFile: ArchiveURL.path) as? [Playlist]
    }
    
    func tryToDrawOnTheWindow()
    {
        currentPlaying = MiniPlayerView()
        if let window = window, let view = window.rootViewController?.view
        {

            let count = view.subviews.count
           
            if currentPlaying != nil
            {
                if !hasadded
                {
                    view.insertSubview(currentPlaying, at: count)
                    currentPlaying?.snp.makeConstraints{ (make) -> Void in
                        make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-49)
                        make.left.equalTo(view.snp.left)
                        make.right.equalTo(view.snp.right)
                        make.height.equalTo(64)
                    }
                    print("first add: \(count)" )
                    hasadded = true
                }
                else
                {
                }
            }
        }
        else
        {
            print("No root view on which to draw")
        }
    }
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool
    {
       return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool
    {
       return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

