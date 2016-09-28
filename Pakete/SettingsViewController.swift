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
    case lastUpdated
    case dateAdded
    case name

    var description: String {
        switch self {
        case .lastUpdated:
            return "Last Updated"
        case .dateAdded:
            return "Date Added"
        case .name:
            return "Name"
        }
    }

    static var arrayValues: [PackagesSortByType] {
        return [.lastUpdated, .dateAdded, .name]
    }
}

class SettingsViewController: UIViewController {

    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    fileprivate let viewModel: PackagesViewModel
    fileprivate let groupByDeliveredSwitch = UISwitch()

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
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        // add done bar button item
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButton))
        // group by delivered switch
        self.groupByDeliveredSwitch.onTintColor = ColorPalette.Matisse
        self.groupByDeliveredSwitch.isOn = self.viewModel.packagesGroupByDelivered()
        self.groupByDeliveredSwitch.addTarget(self, action: #selector(groupByDeliveredSwitchValueDidChange), for: .valueChanged)

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.rowHeight = 44.0
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        self.tableView.constrainEdges(toView: self.view)

        // setup header view
        self.setupTableHeaderView()
        // setup footer view
        let tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 17.0))
        let versionLabel = UILabel()
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        if let infoDictionary = Bundle.main.infoDictionary,
            let version = infoDictionary["CFBundleShortVersionString"],
            let buildNumber = infoDictionary["CFBundleVersion"] {
            versionLabel.text = "\(version) (\(buildNumber))"
        }
        versionLabel.font = UIFont.systemFont(ofSize: 14.0)
        versionLabel.textColor = .gray
        tableFooterView.addSubview(versionLabel)
        versionLabel.center(inView: tableFooterView)
        self.tableView.tableFooterView = tableFooterView

        // track mixpanel
        Mixpanel.sharedInstance().track("Settings View")
    }

    override func viewWillAppear(_ animated: Bool) {
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
        self.dismiss(animated: true, completion: nil)
    }

    func didTapRemoveAdsButton() {
        // remove ads
        let alertController = UIAlertController(title: "Hate Ads?", message: "Remove Ads for $0.99 only", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Pay to Remove Ads", style: UIAlertActionStyle.destructive, handler: { (alertAction) -> Void in
            self.removeAds()
        }))
        alertController.addAction(UIAlertAction(title: "Restore Purchases", style: UIAlertActionStyle.default, handler: { (alertAction) -> Void in
            self.restorePurchases()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        alertController.view.tintColor = ColorPalette.Matisse
    }

    func groupByDeliveredSwitchValueDidChange() {
        self.viewModel.groupByDelivered(self.groupByDeliveredSwitch.isOn)
    }

    fileprivate func removeAds() {
        SVProgressHUD.show(withStatus: "Purchasing Remove Ads...")
        IAPHelper.purchaseRemoveAds { (success) in
            if success {
                SVProgressHUD.dismiss()
                // remove remove ads table header view
                self.tableView.tableHeaderView = nil
            } else {
                SVProgressHUD.showError(withStatus: "Purchase Failed. Please try again.")
            }
        }
    }

    fileprivate func restorePurchases() {
        SVProgressHUD.show()
        IAPHelper.restorePurchases { [unowned self] (results) in
            if results.restoreFailedProducts.isEmpty == false {
                SVProgressHUD.showError(withStatus: "Restore Failed. Please try again.")
            } else if results.restoredProductIds.isEmpty == false {
                // remove remove ads table header view
                self.tableView.tableHeaderView = nil
                SVProgressHUD.showSuccess(withStatus: "Restored Purchases!")
            } else {
                SVProgressHUD.showInfo(withStatus: "Nothing to Restore.")
            }
        }
    }

    fileprivate func setupTableHeaderView() {
        if IAPHelper.showAds() == false { return }

        let tableHeaderView = UIView()
        let headerText = UILabel()
        headerText.font = UIFont.systemFont(ofSize: 14.0)
        headerText.numberOfLines = 0
        headerText.textAlignment = .center
        headerText.textColor = .gray
        headerText.text = "We may be an ad-supported app, but we understand some would prefer Pakete without ads. Get an ad-free experience and help bring new features to the app for only $0.99. A single purchase works across all of your iOS devices forever. We appreciate your support!"
        headerText.frame.size = headerText.sizeThatFits(CGSize(width: self.view.frame.width - 30.0, height: CGFloat.greatestFiniteMagnitude))
        headerText.frame.origin.y = 15.0
        headerText.frame.origin.x = 15.0
        tableHeaderView.addSubview(headerText)
        // add remove ads button
        let removeAdsButton = UIButton()
        removeAdsButton.backgroundColor = .white
        removeAdsButton.setTitle("Remove Ads", for: .normal)
        removeAdsButton.setTitleColor(.red, for: .normal)
        removeAdsButton.titleLabel?.textAlignment = .center
        removeAdsButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        removeAdsButton.frame.size.width = self.view.frame.size.width + 1.0
        removeAdsButton.layer.borderColor = UIColor.lightGray.cgColor
        removeAdsButton.layer.borderWidth = 0.5
        removeAdsButton.frame.size.height = 44.0
        removeAdsButton.frame.origin.y = headerText.frame.maxY + 10.0
        removeAdsButton.addTarget(self, action: #selector(didTapRemoveAdsButton), for: .touchUpInside)
        tableHeaderView.addSubview(removeAdsButton)

        tableHeaderView.frame.size.width = self.view.frame.width
        tableHeaderView.frame.size.height = headerText.frame.height + removeAdsButton.frame.height + 40.0
        self.tableView.tableHeaderView = tableHeaderView
    }

    fileprivate func didTapTweetAboutPakete() {
        let composer = TWTRComposer()
        composer.setText(Constants.App.ShareMessage + " " + Constants.App.URL)
        // Called from a UIViewController
        composer.show(from: self) { _ in }
    }

    fileprivate func didTapTellYourFriendsAboutPakete() {
        let content = FBSDKShareLinkContent()
        content.contentURL = URL(string: Constants.App.URL)
        FBSDKShareDialog.show(from: self, with: content, delegate: nil)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15.0)

        switch (indexPath as NSIndexPath).section {
        case 0:
            cell.accessoryType = .disclosureIndicator
            switch (indexPath as NSIndexPath).row {
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
            switch (indexPath as NSIndexPath).row {
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
            switch (indexPath as NSIndexPath).row {
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
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                // Sort by
                let sortByViewController = SortByViewController(viewModel: self.viewModel)
                self.navigationController?.pushViewController(sortByViewController, animated: true)
            case 1:
                // Group by delivered
                self.groupByDeliveredSwitch.isOn = !self.groupByDeliveredSwitch.isOn
                self.groupByDeliveredSwitchValueDidChange()
            default: ()
            }
        case 1:
            switch (indexPath as NSIndexPath).row {
            case 0:
                // Rate Pakete
                Appirater.forceShowPrompt(false)
            case 1:
                // Contact the Pakete Team
                Smooch.show()
            default: ()
            }
        case 2:
            switch (indexPath as NSIndexPath).row {
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

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = UIFont.systemFont(ofSize: 14)
        headerLabel.numberOfLines = 0
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.textColor = .gray
        headerView.addSubview(headerLabel)
        headerLabel.constrainEqual(.top, to: headerView)
        headerLabel.constrainEqual(.leading, to: headerView, .leading, constant: 15.0)
        headerLabel.constrainEqual(.trailing, to: headerView, .trailing, constant: -15.0)

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let title = self.tableView(tableView, titleForHeaderInSection: section) else { return 0.0 }
        return title.heightWithConstrainedWidth(self.view.frame.width - 30.0, font: UIFont.systemFont(ofSize: 13.0)) + 10.0
    }
}
