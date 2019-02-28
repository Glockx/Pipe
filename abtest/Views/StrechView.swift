//
//  StrechView.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 29/01/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMobileAds

class StrechView: UIView,GADBannerViewDelegate
{
    
    enum ObfuscatedConstants {
        static let obfuscatedString: [UInt8] = [34, 17, 93, 37, 21, 28, 72, 23, 20, 22, 72, 125, 103, 122, 80, 94, 80, 80, 68, 114, 73, 73, 114, 92, 92, 87, 95, 78, 71, 84, 127, 106, 122, 87, 94, 86, 80, 67]
    }
    
    @IBOutlet var adBanner: GADBannerView!
    @IBOutlet weak var albumArtwork: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var albumDate: UILabel!
    @IBOutlet weak var colorView: UIView!
    let obfuscator = Obfuscator()
    @IBOutlet weak var turnBack: UIButton!
    static let shareInstance = StrechView()
    var view: UIView!
    var abc: String?
    
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
        turnBack.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startAds),name: NSNotification.Name(rawValue: "AlbumDetailsstartAds"), object: nil)

    }
    
    
   @objc func startAds()
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc : AlbumDetailsViewController = mainStoryboard.instantiateViewController(withIdentifier: "AlbumDetails") as! AlbumDetailsViewController
        
       
        ADTool.shareInstance.showBanner(adBanner: adBanner, rootController: vc, bannerID: "ca-app-pub-3452453039969028/3119554337", bannerSize: kGADAdSizeSmartBannerPortrait)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        adBanner.isHidden = false
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
    
    func loadViewFromNib() -> UIView
    {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "\(type(of: self))", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    @IBAction func closeView(_ sender: Any)
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "DismissItself"), object: nil)
    }
}
