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

class PackagesViewController: UIViewController {
    
    private let tableView = UITableView()
    private let viewModel = PackagesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Packages"
        // remove back button title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        // add + bar button item
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "didTapAddButton")
        // add settings bar button item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: "didTapSettingsButton")
                
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.registerClass(PackageTableViewCell.self, forCellReuseIdentifier: PackageTableViewCell.reuseIdentifier)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
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
        // ad banner
        self.setupBottomAdBannerView()
        
        // bindings
        self.viewModel.packages.asObservable()
            .subscribeNext { (_) -> Void in
                self.tableView.reloadData()
            }
            .addDisposableTo(self.rx_disposeBag)
        
        self.viewModel.showPackage.asObservable()
            .subscribeNext { (package) -> Void in
                self.showPackageDetails(Variable(package))
            }
            .addDisposableTo(self.rx_disposeBag)
        
        self.viewModel.reloadPackage.asObservable()
            .subscribeNext { (package) -> Void in
                if let index = self.viewModel.packages.value.indexOf({ $0.value == package }) {
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            }
            .addDisposableTo(self.rx_disposeBag)
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

// MARK: - Methods
extension PackagesViewController {
    private func setupBottomAdBannerView() {
        let adBannerView = GADBannerView()
        adBannerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(adBannerView)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: adBannerView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: adBannerView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: adBannerView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: adBannerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50.0)
        ])
        
        let keys = PaketeKeys()
        adBannerView.adUnitID = keys.adMobAdUnitIDKey()
        adBannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        adBannerView.loadRequest(request)
        
        // add bottom offset for ad banner view
        self.tableView.contentInset.bottom = 50.0
        self.tableView.scrollIndicatorInsets.bottom = 50.0
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
        let viewModel = PackageViewModel(package: package)
        let packageViewController = PackageViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(packageViewController, animated: true)
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
            }))
            actionSheetController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
    }
}

extension PackagesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let viewModel = PackageViewModel(package: self.viewModel.packages.value[indexPath.row])
        let packageViewController = PackageViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(packageViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Archive"
    }
}
