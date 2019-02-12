//
//  PlaylistDetailsHeaderView.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 07/02/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import UIKit

class PlaylistDetailsHeaderView: UIView
{

    var view: UIView!
    @IBOutlet weak var playlistName: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var playlistImage: UIImageView!

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
    }
    
    @IBAction func goBack(_ sender: Any)
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "closePlaylistDetails"), object: nil)
        
    }
    
    @IBAction func editPlaylist(_ sender: Any)
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "goToUpdate"), object: nil)
    }
    
    func loadViewFromNib() -> UIView
    {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "\(type(of: self))", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

}
