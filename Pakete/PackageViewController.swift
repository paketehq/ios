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

    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    fileprivate let packageViewModel: PackageViewModel
    fileprivate let packagesViewModel: PackagesViewModel
    fileprivate var noInformationAvailableYetLabel: UILabel?
    fileprivate var nativeExpressAdView: GADNativeExpressAdView!
    fileprivate var nativeExpressAdLoaded = false

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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "barButtonItemMore"), style: .plain, target: self, action: #selector(didTapMoreButton))

        // setup native express ad view
        if IAPHelper.showAds() {
            self.nativeExpressAdView = GADNativeExpressAdView(adSize: GADAdSizeFullWidthPortraitWithHeight(80.0))
            self.nativeExpressAdView.translatesAutoresizingMaskIntoConstraints = false
            self.nativeExpressAdView.adUnitID = PaketeKeys().adMobNativeAdUnitIDKey()
            self.nativeExpressAdView.rootViewController = self
            self.nativeExpressAdView.delegate = self
            self.nativeExpressAdView.isAutoloadEnabled = true
        }

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.backgroundColor = ColorPalette.BlackHaze
        self.tableView.dataSource = self
        self.tableView.register(PackageTrackHistoryTableViewCell.self, forCellReuseIdentifier: PackageTrackHistoryTableViewCell.reuseIdentifier)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        self.tableView.constrainEdges(toView: self.view)
        // setup table header view
        self.setupTableHeaderView()

        // bindings
        self.packageViewModel.package.asObservable()
            .subscribe(onNext: { [unowned self] (package) in
                if package.archived {
                    // if archived then pop navigation controller
                    _ = self.navigationController?.popViewController(animated: true)
                } else {
                    self.title = self.packageViewModel.name()
                    self.tableView.reloadData()
                    if package.trackHistory.isEmpty {
                        self.showNoInformationAvailableYetLabel()
                    } else {
                        self.hideNoInformationAvailableYetLabel()
                    }
                }
            })
            .addDisposableTo(self.rx_disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // track mixpanel
        Mixpanel.sharedInstance().track("Package View")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - Methods
extension PackageViewController {
    fileprivate func setupTableHeaderView() {
        let tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 0.0))
        tableHeaderView.backgroundColor = .white

        // tracking number label
        let trackingNumberLabel = UILabel()
        trackingNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        trackingNumberLabel.text = self.packageViewModel.trackingNumber()
        trackingNumberLabel.font = UIFont.systemFont(ofSize: 16.0)
        trackingNumberLabel.adjustFontToRealIPhoneSize = true
        tableHeaderView.addSubview(trackingNumberLabel)
        trackingNumberLabel.constrainEqual(.top, to: tableHeaderView, .top, constant: 10.0)
        trackingNumberLabel.constrainEqual(.leading, to: tableHeaderView, .leading, constant: 15.0)

        // courier label
        let courierLabel = UILabel()
        courierLabel.translatesAutoresizingMaskIntoConstraints = false
        courierLabel.text = self.packageViewModel.courierName()
        courierLabel.textColor = .lightGray
        courierLabel.font = UIFont.systemFont(ofSize: 14.0)
        courierLabel.adjustFontToRealIPhoneSize = true
        tableHeaderView.addSubview(courierLabel)
        courierLabel.constrainEqual(.top, to: trackingNumberLabel, .bottom)
        courierLabel.constrainEqual(.leading, to: tableHeaderView, .leading, constant: 15.0)

        // adjust height
        let trackingNumberSize = trackingNumberLabel.sizeThatFits(CGSize(width: tableHeaderView.frame.width - 30.0, height: CGFloat.greatestFiniteMagnitude))
        let courierSize = courierLabel.sizeThatFits(CGSize(width: tableHeaderView.frame.width - 30.0, height: CGFloat.greatestFiniteMagnitude))
        tableHeaderView.frame.size.height = trackingNumberSize.height + courierSize.height + 20.0

        // native ad view
        if self.nativeExpressAdLoaded {
            tableHeaderView.addSubview(self.nativeExpressAdView)
            self.nativeExpressAdView.constrainEqual(.leading, to: tableHeaderView)
            self.nativeExpressAdView.constrainEqual(.trailing, to: tableHeaderView)
            self.nativeExpressAdView.constrainEqual(.bottom, to: tableHeaderView)
            self.nativeExpressAdView.constrainEqual(.height, to: nil, .notAnAttribute, constant: 80.0)
            // adjust the tableheaderview height
            tableHeaderView.frame.size.height += self.nativeExpressAdView.frame.height
        }

        self.tableView.tableHeaderView = tableHeaderView
    }

    func didTapMoreButton() {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let latestTrackHistoryViewModel = self.packageViewModel.latestTrackHistory() {
            actionSheetController.addAction(UIAlertAction(title: "Share", style: .default, handler: { (alertAction) in
                let shareString = "\(self.packageViewModel.courierName()) \(self.packageViewModel.trackingNumber()) Status is \(latestTrackHistoryViewModel.status()) at \(latestTrackHistoryViewModel.lastUpdateDateString())"
                let activityViewController = UIActivityViewController(activityItems: [shareString], applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
                activityViewController.view.tintColor = ColorPalette.Matisse
            }))
        }
        actionSheetController.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (alertAction) in
            self.didTapEditButton()
        }))
        actionSheetController.addAction(UIAlertAction(title: "Archive", style: .destructive, handler: { (alertAction) in
            self.didTapArchiveButton()
        }))
        actionSheetController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheetController, animated: true, completion: nil)
        actionSheetController.view.tintColor = ColorPalette.Matisse
    }

    func didTapArchiveButton() {
        // show action sheet
        let actionSheetController = UIAlertController(title: "Archive Package", message: "Are you sure you want to archive this package?", preferredStyle: .actionSheet)
        actionSheetController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (alertAction) -> Void in
            // track mixpanel
            Mixpanel.sharedInstance().track("Archived Package")
            self.packagesViewModel.archivePackage(self.packageViewModel.package)
            _ = self.navigationController?.popViewController(animated: true)
        }))
        actionSheetController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(actionSheetController, animated: true, completion: nil)
        actionSheetController.view.tintColor = ColorPalette.Matisse
    }

    func didTapEditButton() {
        let editPackageViewController = AddPackageViewController(viewModel: packagesViewModel, package: self.packageViewModel.package)
        let editPackageNavigationController = UINavigationController(rootViewController: editPackageViewController)
        self.present(editPackageNavigationController, animated: true, completion: nil)
    }

    func showNoInformationAvailableYetLabel() {
        if self.noInformationAvailableYetLabel == nil {
            let noInformationAvailableYetLabel = UILabel()
            noInformationAvailableYetLabel.text = "No information available yet.\nPlease try again later."
            noInformationAvailableYetLabel.textAlignment = .center
            noInformationAvailableYetLabel.numberOfLines = 2
            noInformationAvailableYetLabel.translatesAutoresizingMaskIntoConstraints = false
            noInformationAvailableYetLabel.font = UIFont.systemFont(ofSize: 14.0)
            noInformationAvailableYetLabel.adjustFontToRealIPhoneSize = true
            self.view.addSubview(noInformationAvailableYetLabel)
            noInformationAvailableYetLabel.center(inView: self.view)
            self.noInformationAvailableYetLabel = noInformationAvailableYetLabel
        }

        self.noInformationAvailableYetLabel?.isHidden = false
    }

    func hideNoInformationAvailableYetLabel() {
        self.noInformationAvailableYetLabel?.isHidden = true
        self.tableView.isHidden = false
    }
}


// MARK: - UITableViewDataSource
extension PackageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.packageViewModel.numberOfTrackHistory()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: PackageTrackHistoryTableViewCell.reuseIdentifier, for: indexPath) as? PackageTrackHistoryTableViewCell {
            cell.configure(withViewModel: self.packageViewModel.trackHistoryViewModelAtIndexPath(indexPath))

            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - GADNativeExpressAdViewDelegate
extension PackageViewController: GADNativeExpressAdViewDelegate {
    func nativeExpressAdViewDidReceiveAd(_ nativeExpressAdView: GADNativeExpressAdView!) {
        self.nativeExpressAdLoaded = true
        // recreate table header view
        self.setupTableHeaderView()
    }
}
