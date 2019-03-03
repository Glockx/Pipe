//
//  SettingsViewController.swift
//  abtest
//
//  Created by Nijat Muzaffarli on 09/09/2018.
//  Copyright © 2018 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import Eureka
import MessageUI
import GoogleMobileAds
import SwiftyStoreKit
import SwiftKeychainWrapper
import PMAlertController
import Reachability
import KRProgressHUD

class SettingsViewController: FormViewController, MFMailComposeViewControllerDelegate, GADBannerViewDelegate
{

    enum ObfuscatedConstants {
        static let obfuscatedString: [UInt8] = [34, 17, 93, 37, 21, 28, 72, 23, 20, 22, 72, 125, 103, 122, 80, 94, 80, 80, 68, 114, 73, 73, 114, 92, 92, 87, 95, 78, 66, 82, 127, 107, 118, 81, 90, 84, 80, 66]
    }
    let reachability = Reachability()!
    @IBOutlet var tableTopConst: NSLayoutConstraint!
    @IBOutlet var adBanner: GADBannerView!
    @IBOutlet weak var tableBottomConstrain: NSLayoutConstraint!
    let obfuscator = Obfuscator()
    var price: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0)
        
        loadTable()
        
        KRProgressHUD.set(activityIndicatorViewColors: [UIColor(hexFromString: "#0575E6"), UIColor(hexFromString: "#2B32B2")])
        KRProgressHUD.set(duration: 0.1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSizes), name: NSNotification.Name(rawValue: "updateUsedSize"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAdLabel), name: NSNotification.Name(rawValue: "updateAdLabel"), object: nil)
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
                ADTool().showBanner(adBanner: self.adBanner, rootController: self, bannerID: Obfuscator().reveal(key: ObfuscatedConstants.obfuscatedString), bannerSize: kGADAdSizeSmartBannerPortrait)
                let row: ButtonRow = self.form.rowBy(tag: "buy")!
                row.disabled = false
                row.evaluateDisabled()
                row.reload()
                
            } else {
                print("Reachable via Cellular")
                ADTool().showBanner(adBanner: self.adBanner, rootController: self, bannerID: Obfuscator().reveal(key: ObfuscatedConstants.obfuscatedString), bannerSize: kGADAdSizeSmartBannerPortrait)
                let row: ButtonRow = self.form.rowBy(tag: "buy")!
                row.disabled = false
                row.evaluateDisabled()
                row.reload()
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            let row: ButtonRow = self.form.rowBy(tag: "buy")!
            row.disabled = true
            row.evaluateDisabled()
            row.reload()
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    @objc func updateSizes()
    {
        let usedByPipe: LabelRow = form.rowBy(tag: "UsedbyPipe")!
        let totalUsed: LabelRow = form.rowBy(tag: "TotalFree")!

        totalUsed.reload()
        usedByPipe.reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if TrackTool.shareInstance.isHidden
            {
            self.tableBottomConstrain.constant = 0
            self.view.layoutSubviews()
        }
        else
        {
            UIView.animate(withDuration: 0.3, animations:
                    {
                        self.tableBottomConstrain.constant = 67
                        self.view.layoutSubviews()
                })
        }
    }
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        if !ADTool.shareInstance.hasPurchasedNoAds
            {
            let row: ButtonRow = form.rowBy(tag: "buy")!

            row.cell.contentView.applyGradientToCell(colours: [UIColor(hexFromString: "#0575E6"), UIColor(hexFromString: "#2B32B2")], bounds: row.cell)

            row.reload()
        }

    }

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        adBanner.isHidden = false
        // Reposition the banner ad to create a slide down effect
        let translateTransform = CGAffineTransform(translationX: 0, y: -adBanner.bounds.size.height)
        adBanner.transform = translateTransform


        UIView.animate(withDuration: 0.5)
        {
            self.adBanner.transform = CGAffineTransform.identity
            self.tableTopConst.constant = 50
            self.view.layoutIfNeeded()
        }

    }
    
    @objc func updateAdLabel()
    {
        if !ADTool.shareInstance.hasPurchasedNoAds
        {
            let row: ButtonRow = form.rowBy(tag: "buy")!
            row.title = ADTool.shareInstance.priceLabel
            row.reload()
        }
    }

    func loadTable()
    {
        form +++ Section("General")
        <<< ButtonRow()
        {
            $0.title = "Sleep Timer"
            $0.cellStyle = .default
        }.cellUpdate { cell, row in

            cell.height = ({ return 50 })
            cell.textLabel?.textColor = UIColor(named: "textGray")
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            cell.textLabel?.textAlignment = .left
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.image = UIImage(named: "timer")
            cell.backgroundColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0)
            let itemSize = CGSize.init(width: 20, height: 20)
            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
            let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
            cell.imageView?.image!.draw(in: imageRect)
            cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();
            cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = UIColor(named: "lightBlue")
            cell.accessoryType = .disclosureIndicator

        }.onCellSelection { cell, row in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "Timer") as! TimerViewController
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
        <<< ButtonRow() {
            $0.title = "Delete All Tracks"
            $0.cellStyle = .default
        }.cellUpdate { cell, row in
            cell.height = ({ return 50 })
            cell.textLabel?.textColor = UIColor(named: "textGray")
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            cell.textLabel?.textAlignment = .left
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.image = UIImage(named: "deleteAll")
            cell.backgroundColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0)
            let itemSize = CGSize.init(width: 20, height: 20)
            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
            let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
            cell.imageView?.image!.draw(in: imageRect)
            cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();
            cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = UIColor(named: "lightBlue")
            cell.accessoryType = .disclosureIndicator
        }.onCellSelection { cell, row in
            let alert = UIAlertController(title: "Delete All Tracks", message: "Are you sure to delete all tracks?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            alert.addAction(cancel)

            let ok = UIAlertAction(title: "Delete", style: .destructive, handler: { action in

                //hide miniplayer if on view hierarchy and stop playing
                if !TrackTool.shareInstance.isHidden {
                    TrackTool.shareInstance.stop()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "hidePlayerWithAnimation"), object: nil)
                    self.tableBottomConstrain.constant = 0
                    self.view.layoutSubviews()
                    TrackTool.shareInstance.isHidden = true
                }

                for track in TrackTool.shareInstance.tracks
                {
                    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                    _ = documentsDirectory.appendingPathComponent("tracks/" + track.fileName).path

//                            if FileManager().fileExists(atPath: fileURL)
//                            {
//                                self.removeAlbumArtwork(localPathName: track.fileName)
//                            }
                    for playlist in PlaylistTool.shareInstance.playlists {
                        if let index = playlist.tracks.firstIndex(where: { $0.fileName == track.fileName })
                            {
                            playlist.tracks.remove(at: index)
                            playlist.songCount -= 1
                            playlist.totalTime = calculateTotalTime(tracks: playlist.tracks)
                        }
                    }
                    self.removeAlbumArtwork(localPathName: track.fileName)
                    self.removeImageLocalPath(localPathName: track.fileName + ".mp3")
                }

                //remove all tracks from array list
                TrackTool.shareInstance.tracks.removeAll()

                //update playlist list and playlist details view
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadPlaylistTable"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "closePlaylistDetails"), object: nil)

                NotificationCenter.default.post(name: Notification.Name(rawValue: "AlbumLoadTrack"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "DismissItself"), object: nil)

                NotificationCenter.default.post(name: Notification.Name(rawValue: "loadtracks"), object: nil)

                // save playlist changes
                let DocumentsDirectorya = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
                let ArchiveURLa = DocumentsDirectorya.appendingPathComponent("Playlists")
                NSKeyedArchiver.archiveRootObject(PlaylistTool.shareInstance.playlists, toFile: ArchiveURLa.path)
                /// =================================== Update Playlists End ================================

                // Save changes to documents
                let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
                let ArchiveURL = DocumentsDirectory.appendingPathComponent("Tracks")
                NSKeyedArchiver.archiveRootObject(TrackTool.shareInstance.tracks, toFile: ArchiveURL.path)

                self.updateSizes()
            })

            alert.addAction(ok)

            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
        }

        <<< ButtonRow() {
            $0.title = "Delete All Playlists"
            $0.cellStyle = .default
        }.cellUpdate { cell, row in
            cell.height = ({ return 50 })
            cell.textLabel?.textColor = UIColor(named: "textGray")
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            cell.textLabel?.textAlignment = .left
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.image = UIImage(named: "deletePlaylist")
            cell.backgroundColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0)
            let itemSize = CGSize.init(width: 20, height: 20)
            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
            let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
            cell.imageView?.image!.draw(in: imageRect)
            cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();
            cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = UIColor(named: "lightBlue")
            cell.accessoryType = .disclosureIndicator
        }.onCellSelection { cell, row in

            let alert = UIAlertController(title: "Delete All Playlists", message: "Are you sure to delete all playlists?", preferredStyle: .alert)

            let ok = UIAlertAction(title: "Delete", style: .destructive, handler: { action in

                //checking if any playlist is being played, if statement is true stop track and hide mini player.
                if !TrackTool.shareInstance.currentPlaylistUiid.isEmpty
                    {
                    TrackTool.shareInstance.stop()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "hidePlayerWithAnimation"), object: nil)
                    self.tableBottomConstrain.constant = 0
                    self.view.layoutSubviews()
                    TrackTool.shareInstance.isHidden = true
                }

                // for each playlist in the playlist array, check if they have artwork. If it does delete than.
                for playlist in PlaylistTool.shareInstance.playlists
                {

                    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                    let fileURL = documentsDirectory.appendingPathComponent("artwork/" + playlist.uuid).path

                    if FileManager().fileExists(atPath: fileURL)
                        {
                        self.removeAlbumArtwork(localPathName: playlist.uuid)
                    }

                }

                //remove all playlists
                PlaylistTool.shareInstance.playlists.removeAll()

                //update playlist list and playlist details view
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadPlaylistTable"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "closePlaylistDetails"), object: nil)

                // save updates
                let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
                let ArchiveURLa = DocumentsDirectory.appendingPathComponent("Playlists")
                NSKeyedArchiver.archiveRootObject(PlaylistTool.shareInstance.playlists, toFile: ArchiveURLa.path)

                self.updateSizes()
            })

            alert.addAction(ok)

            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }

            alert.addAction(cancel)
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
        }

            +++ Section(header: "Advertisement", footer: "")
        <<< ButtonRow("buy")
        { row in

            
            if !ADTool.shareInstance.hasPurchasedNoAds
            {
                row.title = ADTool.shareInstance.priceLabel
            } else {
                row.title = "Thanks For Purchase"
                row.disabled = true
            }
            
            if row.title == "Remove Ads"{
                 row.disabled = true
            }
            
            row.cellStyle = .default

        }.cellUpdate { cell, row in
            //[UIColor(hexFromString: "#0052D4"),UIColor(hexFromString: "#65C7F7"),UIColor(hexFromString: "#9CECFB")]

            cell.height = ({ return 70 })
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 24)
            cell.textLabel?.textAlignment = .center

            if ADTool.shareInstance.hasPurchasedNoAds {
                cell.backgroundColor = .lightGray
                cell.textLabel?.textColor = .white
            }
            
            if (row.title?.isEmpty)!{
                ADTool.shareInstance.CheckNetworkAndGetPrices()
                row.title = ADTool.shareInstance.priceLabel
            }

        }.onCellSelection { cell, row in
            if !row.isDisabled {
                KRProgressHUD.showOn(self).show()
                SwiftyStoreKit.retrieveProductsInfo(["com.nicat.PipeMusicPlayer.removeAds"]) { result in
                    if let product = result.retrievedProducts.first {
                        SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                            switch result {
                            case .success(let purchase):

                                let appleValidator = AppleReceiptValidator(service: .production , sharedSecret: "2aa94d5d749a47a9be58dd6348452bc2")
                                SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                                    switch result {
                                    case .success(let receipt):
                                        let productId = "com.nicat.PipeMusicPlayer.removeAds"
                                        // Verify the purchase of Consumable or NonConsumable
                                        let purchaseResult = SwiftyStoreKit.verifyPurchase(
                                            productId: productId,
                                            inReceipt: receipt)
                                        
                                        switch purchaseResult {
                                        case .purchased(let receiptItem):
                                            print("\(productId) is purchased: \(receiptItem)")
                                            print("Purchase Success: \(purchase.productId)")
                                            let alertVC = PMAlertController(title: "Awesome!", description: "Thank You For Purchase", image: UIImage(named: "shopping-cart"), style: .alert)
                                            alertVC.alertTitle.textColor = UIColor(named: "lightBlue")
                                            alertVC.alertTitle.font = alertVC.alertTitle.font.withSize(24)
                                            alertVC.dismissWithBackgroudTouch = true
                                            
                                            alertVC.addAction(PMAlertAction(title: "Close", style: .cancel, action: { () -> Void in
                                                print("Capture action Cancel")
                                                KRProgressHUD.dismiss()
                                            }))
                                            
                                            self.present(alertVC, animated: true, completion: nil)
                                            
                                            for layer in cell.contentView.layer.sublayers! {
                                                if layer.name == "gradient" {
                                                    layer.removeFromSuperlayer()
                                                }
                                            }
                                            cell.backgroundColor = .lightGray
                                            cell.textLabel?.textColor = .white
                                            cell.textLabel!.text = "Thanks For Purchase"
                                            row.title = "Thanks For Purchase"
                                            
                                            print("purchase pressed")
                                            self.removeAds()
                                            ADTool.shareInstance.hasPurchasedNoAds = true
                                            KeychainWrapper.standard.set(true, forKey: "test")
                                            row.disabled = true
                                            row.evaluateDisabled()
                                            print(row.isDisabled)
                                            
                                        case .notPurchased:
                                            print("The user has never purchased \(productId)")
                                        }
                                    case .error(let error):
                                        print("Receipt verification failed: \(error)")
                                    }
                                }
                            case .error(let error):
                                switch error.code {
                                case .unknown: print("Unknown error. Please contact support")
                                self.showError(title: "Error", descriptiion: "Unknown error. Please contact support", image: UIImage(named: "error")!, style: .alert)
                                case .clientInvalid: print("Not allowed to make the payment")
                                self.showError(title: "Error", descriptiion: "Not allowed to make the payment", image: UIImage(named: "error")!, style: .alert)
                                case .paymentCancelled:
                                    self.showError(title: "Canceled", descriptiion: "The payment is canceled", image: UIImage(named: "cancel-sub")!, style: .alert)
                                case .paymentInvalid: print("The purchase identifier was invalid")
                                self.showError(title: "Error", descriptiion: "The purchase identifier was invalid", image: UIImage(named: "error")!, style: .alert)
                                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                                self.showError(title: "Error", descriptiion: "The device is not allowed to make the payment", image: UIImage(named: "error")!, style: .alert)
                                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                                self.showError(title: "Error", descriptiion: "The product is not available in the current storefront", image: UIImage(named: "error")!, style: .alert)
                                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                                self.showError(title: "Error", descriptiion: "Access to cloud service information is not allowed", image: UIImage(named: "error")!, style: .alert)
                                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                                self.showError(title: "Error", descriptiion: "Could not connect to the network", image: UIImage(named: "error")!, style: .alert)
                                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                                self.showError(title: "Error", descriptiion: "User has revoked permission to use this cloud service", image: UIImage(named: "error")!, style: .alert)
                                default: print((error as NSError).localizedDescription)
                                }
                            }
                        }
                    }
                }
            }
        }

        <<< ButtonRow()
        {
            $0.title = "Restore In App Purchase"
        }.cellUpdate { cell, row in

            cell.height = ({ return 60 })
            cell.textLabel?.textColor = UIColor(named: "textGray")
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            cell.textLabel?.textAlignment = .left
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.image = UIImage(named: "restore")
            let itemSize = CGSize.init(width: 20, height: 20)
            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
            let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
            cell.imageView?.image!.draw(in: imageRect)
            cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();
            cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = UIColor(named: "lightBlue")
            cell.accessoryType = .disclosureIndicator
        }.onCellSelection { cell, row in
            print("restore purchase")
            
            if !ADTool.shareInstance.hasPurchasedNoAds
            {
                KRProgressHUD.showOn(self).show()
                SwiftyStoreKit.restorePurchases(atomically: true) { results in
                    if results.restoreFailedPurchases.count > 0 {
                        print("Restore Failed: \(results.restoreFailedPurchases)")
                        self.showError(title: "Restore Failed", descriptiion: "An error happened during the restoration process", image: UIImage(named: "error")!, style: .alert)
                    }
                    else if results.restoredPurchases.count > 0 {
                        print("Restore Success: \(results.restoredPurchases)")
                        
                        let alertVC = PMAlertController(title: "Your Purchase Has Restored!", description: "Thank You For Purchase", image: UIImage(named: "restored"), style: .alert)
                        alertVC.alertTitle.textColor = UIColor(named: "lightBlue")
                        alertVC.alertTitle.font = alertVC.alertTitle.font.withSize(24)
                        alertVC.dismissWithBackgroudTouch = true
                        
                        alertVC.addAction(PMAlertAction(title: "Close", style: .cancel, action: { () -> Void in
                            print("Capture action Cancel")
                            KRProgressHUD.dismiss()
                        }))
                        
                        self.present(alertVC, animated: true, completion: nil)
                        self.removeAds()
                        ADTool.shareInstance.hasPurchasedNoAds = true
                         KeychainWrapper.standard.set(true, forKey: "test")
                        
                        let arow: ButtonRow = self.form.rowBy(tag: "buy")!
                        
                        for layer in arow.cell.contentView.layer.sublayers! {
                            if layer.name == "gradient" {
                                layer.removeFromSuperlayer()
                            }
                        }
                        
                        arow.title = "Thanks For Purchase"
                        arow.cell.backgroundColor = .lightGray
                        arow.cell.textLabel?.textColor = .white
                        arow.disabled = true
                        arow.evaluateDisabled()
                        print(arow.isDisabled)
                        arow.reload()
                        
                    }
                    else {
                        print("Nothing to Restore")
                        self.showError(title: "Upss..", descriptiion: "No purchase has been done with your Apple ID", image: UIImage(named: "error")!, style: .alert)
                    }
                }
            }else
            {
                let alertVC = PMAlertController(title: "Your Purchase Already Restored!", description: "Thank You For Purchase", image: UIImage(named: "restored"), style: .alert)
                alertVC.alertTitle.textColor = UIColor(named: "lightBlue")
                alertVC.alertTitle.font = alertVC.alertTitle.font.withSize(24)
                alertVC.dismissWithBackgroudTouch = true
                
                alertVC.addAction(PMAlertAction(title: "Close", style: .cancel, action: { () -> Void in
                    print("Capture action Cancel")
                    KRProgressHUD.dismiss()
                }))
                self.present(alertVC, animated: true, completion: nil)
            }
        }

            +++ Section(header: "Feedback", footer: "")
        <<< ButtonRow() {
            $0.title = "Share"
            $0.cellStyle = .default
        }.cellUpdate { cell, row in
            cell.height = ({ return 50 })
            cell.textLabel?.textColor = UIColor(named: "textGray")
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            cell.textLabel?.textAlignment = .left
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.image = UIImage(named: "share")
            let itemSize = CGSize.init(width: 20, height: 20)
            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
            let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
            cell.imageView?.image!.draw(in: imageRect)
            cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();
            cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = UIColor(named: "lightBlue")
            cell.accessoryType = .disclosureIndicator
        }.onCellSelection { cell, row in
            
            let activityVC = UIActivityViewController(activityItems: ["Pipe - Offline Music Player: \n \nhttp://itunes.apple.com/app/id1454346153"], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view

            self.present(activityVC, animated: true, completion: nil)
        }


        <<< ButtonRow()
        {
            $0.title = "Send Feedback"
            $0.cellStyle = .default
        }.cellUpdate { cell, row in
            cell.height = ({ return 50 })
            cell.textLabel?.textColor = UIColor(named: "textGray")
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            cell.textLabel?.textAlignment = .left
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.image = UIImage(named: "email")
            let itemSize = CGSize.init(width: 20, height: 20)
            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
            let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
            cell.imageView?.image!.draw(in: imageRect)
            cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();
            cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = UIColor(named: "lightBlue")
            cell.accessoryType = .disclosureIndicator
        }.onCellSelection { cell, row in

            let mailComposeViewController = self.configureMailController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {

            }
        }

        <<< ButtonRow()
        {
            $0.title = "Report Problem"
            $0.cellStyle = .default
        }.cellUpdate { cell, row in
            cell.height = ({ return 50 })
            cell.textLabel?.textColor = UIColor(named: "textGray")
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            cell.textLabel?.textAlignment = .left
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.image = UIImage(named: "bug")
            let itemSize = CGSize.init(width: 20, height: 20)
            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
            let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
            cell.imageView?.image!.draw(in: imageRect)
            cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();
            cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = UIColor(named: "lightBlue")
            cell.accessoryType = .disclosureIndicator
        }.onCellSelection { cell, row in
            guard let url = URL(string: "https://form.jotform.me/90441652592458") else { return }
            UIApplication.shared.open(url)
        }

            <<< ButtonRow(){
                $0.title = "Changelogs"
                $0.cellStyle = .default
                }.cellUpdate{ cell, row in
                    
                    cell.height = ({ return 50 })
                    cell.textLabel?.textColor = UIColor(named: "textGray")
                    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                    cell.textLabel?.textAlignment = .left
                    cell.imageView?.contentMode = .scaleAspectFit
                    cell.imageView?.image = UIImage(named: "changelist")
                    let itemSize = CGSize.init(width: 20, height: 20)
                    UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
                    let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
                    cell.imageView?.image!.draw(in: imageRect)
                    cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
                    UIGraphicsEndImageContext();
                    cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
                    cell.imageView?.tintColor = UIColor(named: "lightBlue")
                    cell.accessoryType = .disclosureIndicator
                }.onCellSelection { cell, row in
                    guard let url = URL(string: "https://headwayapp.co/pipe-offline-music-player-changelog") else { return }
                    UIApplication.shared.open(url)
            }
            
            +++ Section(header: "Storage", footer: "- Used by Pipe* indicator only includes app documents such as: tracks, artworks and etc.")
        <<< LabelRow()
        {
            $0.title = "Device Storage: "
        }.cellUpdate { cell, row in
            cell.height = ({ return 30 })
            let main_string = "- Device Storage: " + UIDevice.current.totalDiskSpaceInGB
            let string_to_color = UIDevice.current.totalDiskSpaceInGB

            let range = (main_string as NSString).range(of: string_to_color)

            let attribute = NSMutableAttributedString.init(string: main_string)
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.darkGray, range: range)

            cell.textLabel?.attributedText = attribute
            cell.textLabel?.textColor = .lightGray
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        }

        <<< LabelRow("TotalFree").cellUpdate { cell, row in
            cell.height = ({ return 30 })
            let main_string = "- Used Total Storage: " + UIDevice.current.usedDiskSpaceInGB
            let string_to_color = UIDevice.current.usedDiskSpaceInGB
            let range = (main_string as NSString).range(of: string_to_color)
            let attribute = NSMutableAttributedString.init(string: main_string)
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.darkGray, range: range)

            cell.textLabel?.attributedText = attribute
            cell.textLabel?.textColor = .lightGray
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        }

        <<< LabelRow("UsedbyPipe")
        {
            $0.title = "- Used by Pipe: "
        }.cellUpdate { cell, row in
            var size: Int64 = 0
            cell.height = ({ return 30 })
            cell.textLabel?.textColor = .lightGray
            let documentsPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            do {
                size = Int64(try FileManager().allocatedSizeOfDirectory(at: documentsPathURL!))
                //print(size)
            } catch {
                print("error")
            }

            let main_string = "- Used by Pipe: " + UIDevice().MBFormatter(size) + " MB"
            let string_to_color = UIDevice().MBFormatter(size) + " MB"

            let range = (main_string as NSString).range(of: string_to_color)

            let attribute = NSMutableAttributedString.init(string: main_string)
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.darkGray, range: range)

            cell.textLabel?.attributedText = attribute
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        }

            +++ Section() {
                $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.footer?.height = { CGFloat.leastNormalMagnitude }

        }
        <<< LabelRow() {
            if let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
                if let bundle = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
                    {
                    $0.title = "Pipe - " + version + " - Build: " + bundle
                }
                $0.cellStyle = .default

            }
        }.cellUpdate { cell, row in
            //cell.height = ({return 20})
            cell.textLabel?.textColor = .lightGray
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        }
    }


    func removeAlbumArtwork(localPathName: String)
    {
        let filemanager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let destinationPath = documentsPath.appendingPathComponent("artwork/" + localPathName)
        do { try filemanager.removeItem(atPath: destinationPath)
            print("deleted")
        }
        catch { print("Not Deleted") }
    }

    //remove file function
    func removeImageLocalPath(localPathName: String)
    {
        let filemanager = FileManager.default


        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent("tracks/")

        let destinationPath = fileURL.appendingPathComponent(localPathName).path
        do { try filemanager.removeItem(atPath: destinationPath)


        }
        catch { print("Not Deleted") }
    }

    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        mailComposerVC.setToRecipients(["nicat7546@gmail.com"])
        mailComposerVC.setSubject("Pipe Feedback")
        mailComposerVC.setMessageBody("", isHTML: false)

        return mailComposerVC
    }

    func removeAds()
    {
        // remove FilesView Ad banner and restore tableView top constrain
        NotificationCenter.default.post(name: Notification.Name(rawValue: "FilesViewRemoveAds"), object: nil)
        
        //remove AlbumDetails Ad banner
        NotificationCenter.default.post(name: Notification.Name(rawValue: "DismissItself"), object: nil)
        
        // remove AlbumsView Ad banner and restore tableView top constrain
        NotificationCenter.default.post(name: Notification.Name(rawValue: "AlbumsViewRemoveAds"), object: nil)
        
        // remove PlaylistsView Ad banner and restore tableView top constrain
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PlaylistsViewRemoveAds"), object: nil)
        
        //remove PlaylistDetails Ad banner
        NotificationCenter.default.post(name: Notification.Name(rawValue: "closePlaylistDetails"), object: nil)
        
        //remove MusicPlayer Ad banner
        NotificationCenter.default.post(name: Notification.Name(rawValue: "MusicPlayerRemoveAds"), object: nil)
        
        //remove SleepTimer Ad banner
        NotificationCenter.default.post(name: Notification.Name(rawValue: "SleepTimerRemoveAds"), object: nil)
        
        //remove Settings ad Banner and restore tableView top constrain
        if self.adBanner != nil {
            self.adBanner.removeFromSuperview()
        }
        self.tableTopConst.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }


    func colorWithGradient(frame: CGRect, colors: [UIColor]) -> UIColor {

        // create the background layer that will hold the gradient
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.frame = frame

        // we create an array of CG colors from out UIColor array
        let cgColors = colors.map({ $0.cgColor })

        backgroundGradientLayer.colors = cgColors
        backgroundGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        backgroundGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        UIGraphicsBeginImageContext(backgroundGradientLayer.bounds.size)
        backgroundGradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return UIColor(patternImage: backgroundColorImage!)
    }
    
    func showError(title: String,descriptiion: String,image: UIImage,style: PMAlertControllerStyle)
    {
        
        let alertVC = PMAlertController(title: title, description: descriptiion, image: image, style: style)
        alertVC.alertTitle.textColor = .red
        alertVC.alertTitle.font = alertVC.alertTitle.font.withSize(24)
        alertVC.dismissWithBackgroudTouch = true
        
        alertVC.addAction(PMAlertAction(title: "Close", style: .cancel, action: { () -> Void in
            KRProgressHUD.dismiss()
        }))
        
        self.present(alertVC, animated: true, completion: nil)
    }
}
