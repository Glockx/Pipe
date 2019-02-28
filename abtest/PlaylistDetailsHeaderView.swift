//
//  PlaylistDetailsHeaderView.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 07/02/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import GoogleMobileAds
class PlaylistDetailsHeaderView: UIView,GADBannerViewDelegate
{
    enum ObfuscatedConstants {
        static let obfuscatedString: [UInt8] = [34, 17, 93, 37, 21, 28, 72, 23, 20, 22, 72, 125, 103, 122, 80, 94, 80, 80, 68, 114, 73, 73, 114, 92, 92, 87, 95, 78, 77, 82, 118, 107, 127, 85, 90, 86, 82, 64]
    }
    
    var view: UIView!
    let obfuscator = Obfuscator()
    @IBOutlet weak var playlistName: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var playlistImage: UIImageView!

    @IBOutlet var adBanner: GADBannerView!
    @IBOutlet weak var songCount: UILabel!
    
    @IBOutlet weak var editPlaylistButton: UIButton!
    @IBOutlet weak var goBackButton: UIButton!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setupInit()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setupInit()
    }
    
    func setupInit()
    {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
         NotificationCenter.default.addObserver(self, selector: #selector(startAds),name: NSNotification.Name(rawValue: "PlaylistDetailsstartAds"), object: nil)
    }
    
    @IBAction func goBack(_ sender: Any)
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "closePlaylistDetails"), object: nil)
        
    }
    
    @IBAction func editPlaylist(_ sender: Any)
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "goToUpdate"), object: nil)
    }
    
    @objc func startAds()
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc : PlaylistDetailsViewController = mainStoryboard.instantiateViewController(withIdentifier: "PlaylistDetailsViewController") as! PlaylistDetailsViewController
        
        ADTool.shareInstance.showBanner(adBanner: adBanner, rootController: vc, bannerID: obfuscator.reveal(key: ObfuscatedConstants.obfuscatedString), bannerSize: kGADAdSizeSmartBannerPortrait)
    }
    
    func loadViewFromNib() -> UIView
    {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "\(type(of: self))", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

}
