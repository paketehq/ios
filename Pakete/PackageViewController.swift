//
//  PackageViewController.swift
//  Pakete
//
//  Created by Royce Albert Dy on 12/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Keys
import Mixpanel
import GoogleMobileAds
import Keys

class PackageViewController: UIViewController {

    private let tableView = UITableView(frame: CGRect.zero, style: .Grouped)
    private let packageViewModel: PackageViewModel
    private let packagesViewModel: PackagesViewModel
    private var noInformationAvailableYetLabel: UILabel?
    private var nativeExpressAdView: GADNativeExpressAdView!
    private var nativeExpressAdLoaded = false

    init(packageViewModel: PackageViewModel, packagesViewModel: PackagesViewModel) {
        self.packageViewModel = packageViewModel
        self.packagesViewModel = packagesViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = self.packageViewModel.name()
        // add more bar button item
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "barButtonItemMore"), style: .Plain, target: self, action: #selector(didTapMoreButton))

        // setup native express ad view
        if IAPHelper.showAds() {
            self.nativeExpressAdView = GADNativeExpressAdView(adSize: GADAdSizeFullWidthPortraitWithHeight(80.0))
            self.nativeExpressAdView.translatesAutoresizingMaskIntoConstraints = false
            self.nativeExpressAdView.adUnitID = PaketeKeys().adMobNativeAdUnitIDKey()
            self.nativeExpressAdView.rootViewController = self
            self.nativeExpressAdView.delegate = self
            self.nativeExpressAdView.autoloadEnabled = true
        }

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.backgroundColor = ColorPalette.BlackHaze
        self.tableView.dataSource = self
        self.tableView.registerClass(PackageTrackHistoryTableViewCell.self, forCellReuseIdentifier: PackageTrackHistoryTableViewCell.reuseIdentifier)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.separatorStyle = .None
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        self.tableView.constrainEdges(toView: self.view)
        // setup table header view
        self.setupTableHeaderView()

        // bindings
        self.packageViewModel.package.asObservable()
            .subscribeNext { [unowned self] (package) -> Void in
                if package.archived {
                    // if archived then pop navigation controller
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    self.title = self.packageViewModel.name()
                    self.tableView.reloadData()
                    if package.trackHistory.isEmpty {
                        self.showNoInformationAvailableYetLabel()
                    } else {
                        self.hideNoInformationAvailableYetLabel()
                    }
                }
            }
            .addDisposableTo(self.rx_disposeBag)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // track mixpanel
        Mixpanel.sharedInstance().track("Package View")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - Methods
extension PackageViewController {
    private func setupTableHeaderView() {
        let tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 0.0))
        tableHeaderView.backgroundColor = .whiteColor()

        // tracking number label
        let trackingNumberLabel = UILabel()
        trackingNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        trackingNumberLabel.text = self.packageViewModel.trackingNumber()
        trackingNumberLabel.font = UIFont.systemFontOfSize(16.0)
        trackingNumberLabel.adjustFontToRealIPhoneSize = true
        tableHeaderView.addSubview(trackingNumberLabel)
        trackingNumberLabel.constrainEqual(.Top, to: tableHeaderView, .Top, constant: 10.0)
        trackingNumberLabel.constrainEqual(.Leading, to: tableHeaderView, .Leading, constant: 15.0)

        // courier label
        let courierLabel = UILabel()
        courierLabel.translatesAutoresizingMaskIntoConstraints = false
        courierLabel.text = self.packageViewModel.courierName()
        courierLabel.textColor = .lightGrayColor()
        courierLabel.font = UIFont.systemFontOfSize(14.0)
        courierLabel.adjustFontToRealIPhoneSize = true
        tableHeaderView.addSubview(courierLabel)
        courierLabel.constrainEqual(.Top, to: trackingNumberLabel, .Bottom)
        courierLabel.constrainEqual(.Leading, to: tableHeaderView, .Leading, constant: 15.0)

        // adjust height
        let trackingNumberSize = trackingNumberLabel.sizeThatFits(CGSize(width: tableHeaderView.frame.width - 30.0, height: CGFloat.max))
        let courierSize = courierLabel.sizeThatFits(CGSize(width: tableHeaderView.frame.width - 30.0, height: CGFloat.max))
        tableHeaderView.frame.size.height = trackingNumberSize.height + courierSize.height + 20.0

        // native ad view
        if self.nativeExpressAdLoaded {
            tableHeaderView.addSubview(self.nativeExpressAdView)
            self.nativeExpressAdView.constrainEqual(.Leading, to: tableHeaderView)
            self.nativeExpressAdView.constrainEqual(.Trailing, to: tableHeaderView)
            self.nativeExpressAdView.constrainEqual(.Bottom, to: tableHeaderView)
            self.nativeExpressAdView.constrainEqual(.Height, to: nil, .NotAnAttribute, constant: 80.0)
            // adjust the tableheaderview height
            tableHeaderView.frame.size.height += self.nativeExpressAdView.frame.height
        }

        self.tableView.tableHeaderView = tableHeaderView
    }

    func didTapMoreButton() {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        if let latestTrackHistoryViewModel = self.packageViewModel.latestTrackHistory() {
            actionSheetController.addAction(UIAlertAction(title: "Share", style: .Default, handler: { (alertAction) in
                let shareString = "\(self.packageViewModel.courierName()) \(self.packageViewModel.trackingNumber()) Status is \(latestTrackHistoryViewModel.status()) at \(latestTrackHistoryViewModel.lastUpdateDateString())"
                let activityViewController = UIActivityViewController(activityItems: [shareString], applicationActivities: nil)
                self.presentViewController(activityViewController, animated: true, completion: nil)
                activityViewController.view.tintColor = ColorPalette.Matisse
            }))
        }
        actionSheetController.addAction(UIAlertAction(title: "Edit", style: .Default, handler: { (alertAction) in
            self.didTapEditButton()
        }))
        actionSheetController.addAction(UIAlertAction(title: "Archive", style: .Destructive, handler: { (alertAction) in
            self.didTapArchiveButton()
        }))
        actionSheetController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        actionSheetController.view.tintColor = ColorPalette.Matisse
    }

    func didTapArchiveButton() {
        // show action sheet
        let actionSheetController = UIAlertController(title: "Archive Package", message: "Are you sure you want to archive this package?", preferredStyle: .ActionSheet)
        actionSheetController.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: { (alertAction) -> Void in
            // track mixpanel
            Mixpanel.sharedInstance().track("Archived Package")
            self.packagesViewModel.archivePackage(self.packageViewModel.package)
            self.navigationController?.popViewControllerAnimated(true)
        }))
        actionSheetController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        actionSheetController.view.tintColor = ColorPalette.Matisse
    }

    func didTapEditButton() {
        let editPackageViewController = AddPackageViewController(viewModel: packagesViewModel, package: self.packageViewModel.package)
        let editPackageNavigationController = UINavigationController(rootViewController: editPackageViewController)
        self.presentViewController(editPackageNavigationController, animated: true, completion: nil)
    }

    func showNoInformationAvailableYetLabel() {
        if self.noInformationAvailableYetLabel == nil {
            let noInformationAvailableYetLabel = UILabel()
            noInformationAvailableYetLabel.text = "No information available yet.\nPlease try again later."
            noInformationAvailableYetLabel.textAlignment = .Center
            noInformationAvailableYetLabel.numberOfLines = 2
            noInformationAvailableYetLabel.translatesAutoresizingMaskIntoConstraints = false
            noInformationAvailableYetLabel.font = UIFont.systemFontOfSize(14.0)
            noInformationAvailableYetLabel.adjustFontToRealIPhoneSize = true
            self.view.addSubview(noInformationAvailableYetLabel)
            noInformationAvailableYetLabel.center(inView: self.view)
            self.noInformationAvailableYetLabel = noInformationAvailableYetLabel
        }

        self.noInformationAvailableYetLabel?.hidden = false
    }

    func hideNoInformationAvailableYetLabel() {
        self.noInformationAvailableYetLabel?.hidden = true
        self.tableView.hidden = false
    }
}


// MARK: - UITableViewDataSource
extension PackageViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.packageViewModel.numberOfTrackHistory()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(PackageTrackHistoryTableViewCell.reuseIdentifier, forIndexPath: indexPath) as? PackageTrackHistoryTableViewCell {
            cell.configure(withViewModel: self.packageViewModel.trackHistoryViewModelAtIndexPath(indexPath))

            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - GADNativeExpressAdViewDelegate
extension PackageViewController: GADNativeExpressAdViewDelegate {
    func nativeExpressAdViewDidReceiveAd(nativeExpressAdView: GADNativeExpressAdView!) {
        self.nativeExpressAdLoaded = true
        // recreate table header view
        self.setupTableHeaderView()
    }
}
