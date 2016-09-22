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
    private lazy var emptyStateLabel: UILabel = {
        let emptyStateLabel = UILabel()
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "You have no packages to track yet.\nTap the \"+\" button to track a package."
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.font = UIFont.systemFontOfSize(14.0)
        emptyStateLabel.textAlignment = .Center
        emptyStateLabel.backgroundColor = .clearColor()
        self.view.addSubview(emptyStateLabel)
        emptyStateLabel.constrainEdges(toView: self.view)
        return emptyStateLabel
    }()
    private var adBannerView: GADBannerView?

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
        self.view.addSubview(self.tableView)
        self.tableView.constrainEdges(toView: self.view)
        // refresh control
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), forControlEvents: .ValueChanged)
        self.tableView.insertSubview(self.refreshControl, atIndex: 0)

        // ad banner
        self.setupBottomAdBannerView()

        // setup bindings
        self.configureTableViewDataSource()
        self.configureNavigateOnRowTap()
        self.configureDeleteRow()
        self.configureEmptyState()
        self.tableView.rx_setDelegate(self)
            .addDisposableTo(self.rx_disposeBag)
        
        self.viewModel.showPackage.asObservable()
            .subscribeNext { [unowned self] (package) -> Void in
                self.showPackageDetails(ObservablePackage(package))
            }
            .addDisposableTo(self.rx_disposeBag)

        // Notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(hideAds), name: IAPDidPurchaseRemoveAdsNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // track mixpanel
        Mixpanel.sharedInstance().track("Packages View", properties: ["Packages Count": self.viewModel.packages.value.count])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

// MARK: - Methods
extension PackagesViewController {
    private func setupBottomAdBannerView() {
        guard IAPHelper.showAds() else { return }

        let adBannerView = GADBannerView()
        adBannerView.autoloadEnabled = true
        adBannerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(adBannerView)
        adBannerView.constrainEqual(.Bottom, to: self.view)
        adBannerView.constrainEqual(.Leading, to: self.view)
        adBannerView.constrainEqual(.Trailing, to: self.view)
        adBannerView.constrainEqual(.Height, to: nil, .NotAnAttribute, constant: 50.0)

        let keys = PaketeKeys()
        adBannerView.adUnitID = keys.adMobBannerAdUnitIDKey()
        adBannerView.rootViewController = self
        self.adBannerView = adBannerView

        // add bottom offset for ad banner view
        self.tableView.contentInset.bottom = 50.0
        self.tableView.scrollIndicatorInsets.bottom = 50.0
    }

    private func configureTableViewDataSource() {
        self.viewModel.packages
            .asDriver()
            .map { packages in
                packages.map(PackageViewModel.init)
            }
            .drive(self.tableView.rx_itemsWithCellIdentifier(PackageTableViewCell.reuseIdentifier, cellType: PackageTableViewCell.self)) { index, viewModel, cell in
                cell.configure(withViewModel: viewModel)
            }
            .addDisposableTo(self.rx_disposeBag)
    }

    private func configureNavigateOnRowTap() {
        self.tableView.rx_modelSelected(PackageViewModel.self)
            .asDriver()
            .driveNext { [unowned self] (viewModel) in
                self.showPackageDetails(viewModel.package)
            }
            .addDisposableTo(self.rx_disposeBag)

        self.tableView.rx_itemSelected
            .asDriver()
            .driveNext { [unowned self] (indexPath) in
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
            .addDisposableTo(self.rx_disposeBag)
    }

    private func configureDeleteRow() {
        self.tableView.rx_itemDeleted
            .asDriver()
            .driveNext { [unowned self] (indexPath) in
                // show action sheet
                let actionSheetController = UIAlertController(title: "Archive Package", message: "Are you sure you want to archive this package?", preferredStyle: .ActionSheet)
                actionSheetController.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: { [unowned self] (alertAction) -> Void in
                    self.viewModel.archivePackageIndexPath(indexPath)
                    // track mixpanel
                    Mixpanel.sharedInstance().track("Archived Package")
                }))
                actionSheetController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
                self.presentViewController(actionSheetController, animated: true, completion: nil)
                actionSheetController.view.tintColor = ColorPalette.Matisse
            }
            .addDisposableTo(self.rx_disposeBag)
    }

    private func configureEmptyState() {
        self.viewModel.packages
            .asDriver()
            .map { $0.isEmpty == false }
            .drive(self.emptyStateLabel.rx_hidden)
            .addDisposableTo(self.rx_disposeBag)
    }

    func applicationWillEnterForeground() {
        // force refresh
        self.viewModel.refreshPackages()
    }

    func hideAds() {
        self.adBannerView?.removeFromSuperview()
        self.adBannerView = nil
        self.tableView.contentInset.bottom = 0.0
        self.tableView.scrollIndicatorInsets.bottom = 0.0
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
        let settingsViewController = SettingsViewController(viewModel: self.viewModel)
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        self.presentViewController(settingsNavigationController, animated: true, completion: nil)
    }

    func showPackageDetails(package: ObservablePackage) {
        let packageViewModel = PackageViewModel(package: package)
        let packageViewController = PackageViewController(packageViewModel: packageViewModel, packagesViewModel: viewModel)
        self.navigationController?.pushViewController(packageViewController, animated: true)
    }

}

extension PackagesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Archive"
    }
}
