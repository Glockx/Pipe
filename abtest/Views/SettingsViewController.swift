//
//  SettingsViewController.swift
//  abtest
//
//  Created by Nijat Muzaffarli on 09/09/2018.
//  Copyright © 2018 Nijat Muzaffarli. All rights reserved.
//

import UIKit
import Eureka

class SettingsViewController: FormViewController
{


    override func viewDidLoad()
    {
        super.viewDidLoad()

        form +++ Section()
        <<< ButtonRow()
            {
                $0.title = "Sleep Timer"
                $0.cellStyle = .default
            }.cellUpdate{ cell,row in
                cell.textLabel?.textColor = .black
                cell.textLabel?.font =  UIFont.systemFont(ofSize: 18)
                cell.textLabel?.textAlignment = .left
                cell.imageView?.contentMode = .scaleAspectFit
                cell.imageView?.image = UIImage(named: "timer")
                let itemSize = CGSize.init(width: 30, height: 30)
                UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
                let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
                cell.imageView?.image!.draw(in: imageRect)
                cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
                UIGraphicsEndImageContext();
                cell.accessoryType = .disclosureIndicator
            }.onCellSelection{  cell, row in
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "Timer") as! TimerViewController
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
            +++ Section()
        <<< LabelRow() {
            if let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
                if let bundle = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
                    {
                    $0.title = "Pipe - " + version + " - Build: " + bundle
                }
                $0.cellStyle = .default

            }
        }.cellUpdate { cell, row in
            cell.textLabel?.textColor = .lightGray
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        }
    }

}
