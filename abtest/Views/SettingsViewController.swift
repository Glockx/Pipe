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
class SettingsViewController: FormViewController, MFMailComposeViewControllerDelegate
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadTable()
    }


    func loadTable()
    {
        form +++ Section()
        <<< ButtonRow()
        {
            $0.title = "Sleep Timer"
            $0.cellStyle = .default
        }.cellUpdate { cell, row in
            cell.textLabel?.textColor = .black
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
            cell.textLabel?.textAlignment = .left
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.image = UIImage(named: "timer")

            let itemSize = CGSize.init(width: 30, height: 30)
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

            +++ Section(header: "General", footer: "")
        <<< ButtonRow() {
            $0.title = "Send Feedback"
            $0.cellStyle = .default
        }.cellUpdate { cell, row in
            cell.textLabel?.textColor = .black
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
            cell.textLabel?.textAlignment = .left
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.image = UIImage(named: "email")
            let itemSize = CGSize.init(width: 30, height: 30)
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
                $0.title = "Report Bugs & Issues"
                $0.cellStyle = .default
                }.cellUpdate { cell, row in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
                    cell.textLabel?.textAlignment = .left
                    cell.imageView?.contentMode = .scaleAspectFit
                    cell.imageView?.image = UIImage(named: "bug")
                    let itemSize = CGSize.init(width: 30, height: 30)
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

    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        mailComposerVC.setToRecipients(["nicat7546@gmail.com"])
        mailComposerVC.setSubject("Pipe Feedback")
        mailComposerVC.setMessageBody("", isHTML: false)

        return mailComposerVC
    }


    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
