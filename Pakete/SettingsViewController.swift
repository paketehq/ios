//
//  SettingsViewController.swift
//  Pakete
//
//  Created by Royce Albert Dy on 17/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import UIKit
import VTAcknowledgementsViewController

class SettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: CGRect.zero, style: .Grouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Settings"
        // remove back button title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        // add done bar button item
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(didTapDoneButton))

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.rowHeight = 44.0
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: self.tableView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.tableView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.tableView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.tableView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        ])
        
        // setup footer view
        let tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 17.0))
        let versionLabel = UILabel()
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        if let infoDictionary = NSBundle.mainBundle().infoDictionary,
            version = infoDictionary["CFBundleShortVersionString"],
            buildNumber = infoDictionary["CFBundleVersion"]
        {
            versionLabel.text = "\(version) (\(buildNumber))"
        }
        versionLabel.font = UIFont.systemFontOfSize(14.0)
        versionLabel.textColor = .grayColor()
        tableFooterView.addSubview(versionLabel)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: versionLabel, attribute: .CenterY, relatedBy: .Equal, toItem: tableFooterView, attribute: .CenterY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: versionLabel, attribute: .CenterX, relatedBy: .Equal, toItem: tableFooterView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        ])
        self.tableView.tableFooterView = tableFooterView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SettingsViewController {
    func didTapDoneButton() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func removeAds() {
        
    }
    
    func restorePurchases() {
        
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 2:
            return 1
        case 1:
            return 2
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.font = UIFont.systemFontOfSize(16.0)
        
        switch indexPath.section {
        case 0:
            // remove ads
            cell.textLabel?.textColor = .redColor()
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.text = "Remove Ads"
        case 1:
            cell.accessoryType = .DisclosureIndicator
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Tutorial"
            case 1:
                cell.textLabel?.text = "Report a Problem"
            default: ()
            }
        case 2:
            cell.accessoryType = .DisclosureIndicator
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Open Source Libraries"
            default: ()
            }
        default: ()
        }
        
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Support"
        case 2:
            return "About"
        default: return nil
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 0:
            // remove ads
            let alertController = UIAlertController(title: "Hate Ads?", message: nil, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Pay to Remove Ads", style: UIAlertActionStyle.Destructive, handler: { (alertAction) -> Void in
                self.removeAds()
            }))
            alertController.addAction(UIAlertAction(title: "Restore Purchases", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                self.restorePurchases()
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            alertController.view.tintColor = ColorPalette.Matisse
        case 1:
            //
            break
        case 2:
            // Open source libraries
            if let acknowledgementsViewController = VTAcknowledgementsViewController.acknowledgementsViewController() {
                acknowledgementsViewController.title = "Libraries We Use"
                acknowledgementsViewController.headerText = "The following sets forth attribution notices for third party software that may be contained in portions of the Pakete product. We thank the open source community for all of their contributions"
                self.navigationController?.pushViewController(acknowledgementsViewController, animated: true)
            }
        default: ()
        }
        
    }
}