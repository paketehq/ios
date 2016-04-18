//
//  PackagesViewController.swift
//  Pakete
//
//  Created by Royce Albert Dy on 12/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import GoogleMobileAds
import Keys
import Mixpanel

class PackagesViewController: UIViewController {
    
    private let tableView = UITableView()
    private let viewModel = PackagesViewModel()
    private let refreshControl = UIRefreshControl()
    private var emptyStateLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Packages"
        // remove back button title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        // add + bar button item
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(didTapAddButton))
        // add settings bar button item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "barButtonItemSettings"), style: .Plain, target: self, action: #selector(didTapSettingsButton))
                
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.registerClass(PackageTableViewCell.self, forCellReuseIdentifier: PackageTableViewCell.reuseIdentifier)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 54.0
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: self.tableView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.tableView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.tableView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.tableView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        ])
        // refresh control
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), forControlEvents: .ValueChanged)
        self.tableView.insertSubview(self.refreshControl, atIndex: 0)
        
        // ad banner
        self.setupBottomAdBannerView()
        
        // bindings
        self.viewModel.packages.asObservable()
            .subscribeNext { (packages) -> Void in
                self.tableView.reloadData()
                if packages.count == 0 { self.showEmptyStateLabel() } else { self.hideEmptyStateLabel() }
            }
            .addDisposableTo(self.rx_disposeBag)
        
        self.viewModel.showPackage.asObservable()
            .subscribeNext { (package) -> Void in
                self.showPackageDetails(ObservablePackage(package))
            }
            .addDisposableTo(self.rx_disposeBag)
    }
        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        // track mixpanel
        Mixpanel.sharedInstance().track("Packages View")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - Methods
extension PackagesViewController {
    private func setupBottomAdBannerView() {
        let adBannerView = GADBannerView()
        adBannerView.autoloadEnabled = true
        adBannerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(adBannerView)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: adBannerView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: adBannerView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: adBannerView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: adBannerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50.0)
        ])
        
        let keys = PaketeKeys()
        adBannerView.adUnitID = keys.adMobBannerAdUnitIDKey()
        adBannerView.rootViewController = self
        
        // add bottom offset for ad banner view
        self.tableView.contentInset.bottom = 50.0
        self.tableView.scrollIndicatorInsets.bottom = 50.0
    }
    
    func didPullToRefresh() {
        self.viewModel.refreshPackages()
        self.refreshControl.endRefreshing()
    }
    
    func didTapAddButton() {
        let couriersViewController = CouriersViewController(viewModel: self.viewModel)
        let couriersNavigationController = UINavigationController(rootViewController: couriersViewController)
        self.presentViewController(couriersNavigationController, animated: true, completion: nil)
    }
    
    func didTapSettingsButton() {
        let settingsViewController = SettingsViewController()
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        self.presentViewController(settingsNavigationController, animated: true, completion: nil)
    }
    
    func showPackageDetails(package: ObservablePackage) {
        let packageViewModel = PackageViewModel(package: package)
        let packageViewController = PackageViewController(packageViewModel: packageViewModel, packagesViewModel: viewModel)
        self.navigationController?.pushViewController(packageViewController, animated: true)
    }
    
    func showEmptyStateLabel() {
        if self.emptyStateLabel == nil {
            self.emptyStateLabel = UILabel()
            self.emptyStateLabel?.translatesAutoresizingMaskIntoConstraints = false
            self.emptyStateLabel?.text = "You have no packages to track yet.\nTap the \"+\" button to track a package."
            self.emptyStateLabel?.numberOfLines = 0
            self.emptyStateLabel?.font = UIFont.systemFontOfSize(14.0)
            self.emptyStateLabel?.textAlignment = .Center
            self.emptyStateLabel?.backgroundColor = .whiteColor()
            self.view.addSubview(self.emptyStateLabel!)
            NSLayoutConstraint.activateConstraints([
                NSLayoutConstraint(item: self.emptyStateLabel!, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.emptyStateLabel!, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.emptyStateLabel!, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.emptyStateLabel!, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 1.0, constant: 0.0),
            ])
        } else {
            self.emptyStateLabel?.hidden = false
        }
    }
    
    func hideEmptyStateLabel() {
        self.emptyStateLabel?.hidden = true
    }
}

extension PackagesViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.packages.value.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PackageTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! PackageTableViewCell
        
        let viewModel = PackageViewModel(package: self.viewModel.packages.value[indexPath.row])
        cell.configure(withViewModel: viewModel)
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // show action sheet
            let actionSheetController = UIAlertController(title: "Archive Package", message: "Are you sure you want to archive this package?", preferredStyle: .ActionSheet)
            actionSheetController.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: { (alertAction) -> Void in
                self.viewModel.archivePackageIndexPath(indexPath)
                // track mixpanel
                Mixpanel.sharedInstance().track("Archived Package")
            }))
            actionSheetController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
            self.presentViewController(actionSheetController, animated: true, completion: nil)
            actionSheetController.view.tintColor = ColorPalette.Matisse
        }
    }
}

extension PackagesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.showPackageDetails(self.viewModel.packages.value[indexPath.row])
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Archive"
    }
}
