//
//  StrechView.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 29/01/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import SnapKit

class StrechView: UIView
{
    @IBOutlet weak var albumArtwork: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var albumDate: UILabel!
    @IBOutlet weak var colorView: UIView!
    
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
