//
//  PlaylistCreationViewController.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 03/02/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import UIKit

class PlaylistCreationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func cancelCreation(_ sender: Any)
    {
        navigationController?.popViewController(animated: true)
        print("salam")
    }
}
