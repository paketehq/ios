//
//  SettingsViewController.swift
//  Pakete
//
//  Created by Royce Albert Dy on 17/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import UIKit
import Mixpanel
import SwiftyStoreKit
import SVProgressHUD
import Appirater
import TwitterKit
import FBSDKShareKit

enum PackagesSortByType: Int {
    case LastUpdated
    case DateAdded
    case Name

    var description: String {
        switch self {
        case LastUpdated:
            return "Last Updated"
        case DateAdded:
            return "Date Added"
        case Name:
            return "Name"
        }
    }

    static var arrayValues: [PackagesSortByType] {
        return [.LastUpdated, .DateAdded, .Name]
    }
}

class SettingsViewController: UIViewController {

    private let tableView = UITableView(frame: CGRect.zero, style: .Grouped)
    private let viewModel: PackagesViewModel
    private let groupByDeliveredSwitch = UISwitch()

    init(viewModel: PackagesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Settings"
        // remove back button title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        // add done bar button item
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(didTapDoneButton))
        // group by delivered switch
        self.groupByDeliveredSwitch.onTintColor = ColorPalette.Matisse
        self.groupByDeliveredSwitch.on = self.viewModel.packagesGroupByDelivered()
        self.groupByDeliveredSwitch.addTarget(self, action: #selector(groupByDeliveredSwitchValueDidChange), forControlEvents: .ValueChanged)

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
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

        // setup header view
        self.setupTableHeaderView()
        // setup footer view
        let tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 17.0))
        let versionLabel = UILabel()
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        if let infoDictionary = NSBundle.mainBundle().infoDictionary,
            version = infoDictionary["CFBundleShortVersionString"],
            buildNumber = infoDictionary["CFBundleVersion"] {
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

        // track mixpanel
        Mixpanel.sharedInstance().track("Settings View")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
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

    func didTapRemoveAdsButton() {
        // remove ads
        let alertController = UIAlertController(title: "Hate Ads?", message: "Remove Ads for $0.99 only", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Pay to Remove Ads", style: UIAlertActionStyle.Destructive, handler: { (alertAction) -> Void in
            self.removeAds()
        }))
        alertController.addAction(UIAlertAction(title: "Restore Purchases", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
            self.restorePurchases()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        alertController.view.tintColor = ColorPalette.Matisse
    }

    func groupByDeliveredSwitchValueDidChange() {
        self.viewModel.groupByDelivered(self.groupByDeliveredSwitch.on)
    }

    private func removeAds() {
        SVProgressHUD.showWithStatus("Purchasing Remove Ads...")
        IAPHelper.purchaseRemoveAds { (success) in
            if success {
                SVProgressHUD.dismiss()
                // remove remove ads table header view
                self.tableView.tableHeaderView = nil
            } else {
                SVProgressHUD.showErrorWithStatus("Purchase Failed. Please try again.")
            }
        }
    }

    private func restorePurchases() {
        SVProgressHUD.show()
        IAPHelper.restorePurchases { (results) in
            if results.restoreFailedProducts.isEmpty == false {
                SVProgressHUD.showErrorWithStatus("Restore Failed. Please try again.")
            } else if results.restoredProductIds.isEmpty == false {
                // remove remove ads table header view
                self.tableView.tableHeaderView = nil
                SVProgressHUD.showSuccessWithStatus("Restored Purchases!")
            } else {
                SVProgressHUD.showInfoWithStatus("Nothing to Restore.")
            }
        }
    }

    private func setupTableHeaderView() {
        if IAPHelper.showAds() == false { return }

        let tableHeaderView = UIView()
        let headerText = UILabel()
        headerText.font = UIFont.systemFontOfSize(14.0)
        headerText.numberOfLines = 0
        headerText.textAlignment = .Center
        headerText.textColor = .grayColor()
        headerText.text = "We may be an ad-supported app, but we understand some would prefer Pakete without ads. Get an ad-free experience and help bring new features to the app for only $0.99. A single purchase works across all of your iOS devices forever. We appreciate your support!"
        headerText.frame.size = headerText.sizeThatFits(CGSize(width: self.view.frame.width - 30.0, height: CGFloat.max))
        headerText.frame.origin.y = 15.0
        headerText.frame.origin.x = 15.0
        tableHeaderView.addSubview(headerText)
        // add remove ads button
        let removeAdsButton = UIButton()
        removeAdsButton.backgroundColor = .whiteColor()
        removeAdsButton.setTitle("Remove Ads", forState: .Normal)
        removeAdsButton.setTitleColor(.redColor(), forState: .Normal)
        removeAdsButton.titleLabel?.textAlignment = .Center
        removeAdsButton.titleLabel?.font = UIFont.systemFontOfSize(15.0)
        removeAdsButton.frame.size.width = self.view.frame.size.width + 1.0
        removeAdsButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        removeAdsButton.layer.borderWidth = 0.5
        removeAdsButton.frame.size.height = 44.0
        removeAdsButton.frame.origin.y = headerText.frame.maxY + 10.0
        removeAdsButton.addTarget(self, action: #selector(didTapRemoveAdsButton), forControlEvents: .TouchUpInside)
        tableHeaderView.addSubview(removeAdsButton)

        tableHeaderView.frame.size.width = self.view.frame.width
        tableHeaderView.frame.size.height = headerText.frame.height + removeAdsButton.frame.height + 40.0
        self.tableView.tableHeaderView = tableHeaderView
    }

    private func didTapTweetAboutPakete() {
        let composer = TWTRComposer()
        composer.setText(Constants.App.ShareMessage + " " + Constants.App.URL)
        // Called from a UIViewController
        composer.showFromViewController(self) { _ in }
    }

    private func didTapTellYourFriendsAboutPakete() {
        let content = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: Constants.App.URL)
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // Sort by, Group by delivered
            return 2
        case 1: // Rate Pakete, Contact the Pakete Team
            return 2
        case 2: // Tweet about Pakete, Tell your friends about Pakete
            return 2
        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: "Cell")
        }
        cell.textLabel?.font = UIFont.systemFontOfSize(15.0)
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(15.0)

        switch indexPath.section {
        case 0:
            cell.accessoryType = .DisclosureIndicator
            switch indexPath.row {
            case 0:
                // Sort by
                cell.imageView?.image = UIImage(named: "sortBy")
                cell.textLabel?.text = "Sort by"
                cell.detailTextLabel?.text = self.viewModel.packagesSortBy().description
            case 1:
                // Group by delivered
                cell.accessoryView = self.groupByDeliveredSwitch
                cell.imageView?.image = UIImage(named: "groupBy")
                cell.textLabel?.text = "Group by Delivered"
            default: ()
            }
        case 1:
            switch indexPath.row {
            case 0:
                // Rate Pakete
                cell.imageView?.image = UIImage(named: "ratePaketeIcon")
                cell.textLabel?.text = "Rate Pakete"
            case 1:
                // Contact the Pakete Team
                cell.imageView?.image = UIImage(named: "contactPaketeTeamIcon")
                cell.textLabel?.text = "Contact the Pakete Team"
            default: ()
            }
        case 2:
            switch indexPath.row {
            case 0:
                // Tweet about Pakete
                cell.imageView?.image = UIImage(named: "twitterIcon")
                cell.textLabel?.text = "Tweet about Pakete"
            case 1:
                // Tell your friends about Pakete
                cell.imageView?.image = UIImage(named: "facebookIcon")
                cell.textLabel?.text = "Tell your friends about Pakete"
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
        case 0:
            return "Packages"
        case 1:
            return "We'd love to know how we can make Pakete even better and would appreciate if you leave a review on the App Store."
        case 2:
            return "Tell your Friends"
        default: return nil
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                // Sort by
                let sortByViewController = SortByViewController(viewModel: self.viewModel)
                self.navigationController?.pushViewController(sortByViewController, animated: true)
            case 1:
                // Group by delivered
                self.groupByDeliveredSwitch.on = !self.groupByDeliveredSwitch.on
                self.groupByDeliveredSwitchValueDidChange()
            default: ()
            }
        case 1:
            switch indexPath.row {
            case 0:
                // Rate Pakete
                Appirater.forceShowPrompt(false)
            case 1:
                // Contact the Pakete Team
                Smooch.show()
            default: ()
            }
        case 2:
            switch indexPath.row {
            case 0:
                // Tweet about Pakete
                self.didTapTweetAboutPakete()
            case 1:
                // Tell your friends about Pakete
                self.didTapTellYourFriendsAboutPakete()
            default: ()
            }
        default: ()
        }

    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = UIFont.systemFontOfSize(14)
        headerLabel.numberOfLines = 0
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.textColor = .grayColor()
        headerView.addSubview(headerLabel)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: headerLabel, attribute: .Leading, relatedBy: .Equal, toItem: headerView, attribute: .Leading, multiplier: 1.0, constant: 15.0),
            NSLayoutConstraint(item: headerLabel, attribute: .Trailing, relatedBy: .Equal, toItem: headerView, attribute: .Trailing, multiplier: 1.0, constant: -15.0),
            NSLayoutConstraint(item: headerLabel, attribute: .Top, relatedBy: .Equal, toItem: headerView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        ])

        return headerView
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let title = self.tableView(tableView, titleForHeaderInSection: section) else { return 0.0 }
        return title.heightWithConstrainedWidth(self.view.frame.width - 30.0, font: UIFont.systemFontOfSize(13.0)) + 10.0
    }
}
