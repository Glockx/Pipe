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
        
        form +++ Section("Section1")
            <<< TextRow(){ row in
                row.title = "Text Row"
                row.placeholder = "Enter text here"
            }
            <<< PhoneRow(){
                $0.title = "Phone Row"
                $0.placeholder = "And numbers here"
            }
            +++ Section()
            <<< LabelRow(){row in
                
                }.cellUpdate{cell,row in
                    if let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String{
                        if let bundle = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
                        {
                            cell.textLabel?.text = "Pipe - " + version + " - Build: " + bundle
                        }
                    }
                    cell.textLabel?.textAlignment = NSTextAlignment.center
                cell.textLabel?.textColor = .darkGray
        }
    }
    
}
