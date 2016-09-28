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

    fileprivate let tableView = UITableView()
    fileprivate let viewModel = PackagesViewModel()
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate lazy var emptyStateLabel: UILabel = {
        let emptyStateLabel = UILabel()
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "You have no packages to track yet.\nTap the \"+\" button to track a package."
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.font = UIFont.systemFont(ofSize: 14.0)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.backgroundColor = .clear
        self.view.addSubview(emptyStateLabel)
        emptyStateLabel.constrainEdges(toView: self.view)
        return emptyStateLabel
    }()
    fileprivate var adBannerView: GADBannerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Packages"
        // remove back button title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        // add + bar button item
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        // add settings bar button item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "barButtonItemSettings"), style: .plain, target: self, action: #selector(didTapSettingsButton))

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.register(PackageTableViewCell.self, forCellReuseIdentifier: PackageTableViewCell.reuseIdentifier)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 54.0
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        self.tableView.constrainEdges(toView: self.view)
        // refresh control
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.tableView.insertSubview(self.refreshControl, at: 0)

        // ad banner
        self.setupBottomAdBannerView()

        // setup bindings
        self.configureTableViewDataSource()
        self.configureNavigateOnRowTap()
        self.configureDeleteRow()
        self.configureEmptyState()
        self.tableView.rx.setDelegate(self)
            .addDisposableTo(self.rx_disposeBag)

        self.viewModel.showPackage.asObservable()
            .subscribe(onNext: { [unowned self] (package) in
                self.showPackageDetails(ObservablePackage(package))
            })
            .addDisposableTo(self.rx_disposeBag)

        // Notification
        NotificationCenter.default.addObserver(self, selector: #selector(hideAds), name: NSNotification.Name(rawValue: IAPDidPurchaseRemoveAdsNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // track mixpanel
        Mixpanel.sharedInstance().track("Packages View", properties: ["Packages Count": self.viewModel.packages.value.count])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

// MARK: - Methods
extension PackagesViewController {
    fileprivate func setupBottomAdBannerView() {
        guard IAPHelper.showAds() else { return }

        let adBannerView = GADBannerView()
        adBannerView.isAutoloadEnabled = true
        adBannerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(adBannerView)
        adBannerView.constrainEqual(.bottom, to: self.view)
        adBannerView.constrainEqual(.leading, to: self.view)
        adBannerView.constrainEqual(.trailing, to: self.view)
        adBannerView.constrainEqual(.height, to: nil, .notAnAttribute, constant: 50.0)

        let keys = PaketeKeys()
        adBannerView.adUnitID = keys.adMobBannerAdUnitIDKey()
        adBannerView.rootViewController = self
        self.adBannerView = adBannerView

        // add bottom offset for ad banner view
        self.tableView.contentInset.bottom = 50.0
        self.tableView.scrollIndicatorInsets.bottom = 50.0
    }

    fileprivate func configureTableViewDataSource() {
        self.viewModel.packages
            .asDriver()
            .map { packages in
                packages.map(PackageViewModel.init)
            }
            .drive(self.tableView.rx.items(cellIdentifier: PackageTableViewCell.reuseIdentifier, cellType: PackageTableViewCell.self)) { index, viewModel, cell in
                cell.configure(withViewModel: viewModel)
            }
            .addDisposableTo(self.rx_disposeBag)
    }

    fileprivate func configureNavigateOnRowTap() {
        self.tableView.rx.modelSelected(PackageViewModel.self)
            .asDriver()
            .drive(onNext: { [unowned self] (viewModel) in
                self.showPackageDetails(viewModel.package)
            })
            .addDisposableTo(self.rx_disposeBag)

        self.tableView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [unowned self] (indexPath) in
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            .addDisposableTo(self.rx_disposeBag)
    }

    fileprivate func configureDeleteRow() {
        self.tableView.rx.itemDeleted
            .asDriver()
            .drive(onNext: { [unowned self] (indexPath) in
                // show action sheet
                let actionSheetController = UIAlertController(title: "Archive Package", message: "Are you sure you want to archive this package?", preferredStyle: .actionSheet)
                actionSheetController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [unowned self] (alertAction) -> Void in
                    self.viewModel.archivePackageIndexPath(indexPath)
                    // track mixpanel
                    Mixpanel.sharedInstance().track("Archived Package")
                    }))
                actionSheetController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(actionSheetController, animated: true, completion: nil)
                actionSheetController.view.tintColor = ColorPalette.Matisse
            })
            .addDisposableTo(self.rx_disposeBag)
    }

    fileprivate func configureEmptyState() {
        self.viewModel.packages
            .asDriver()
            .map { $0.isEmpty == false }
            .drive(self.emptyStateLabel.rx.hidden)
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
        self.present(couriersNavigationController, animated: true, completion: nil)
    }

    func didTapSettingsButton() {
        let settingsViewController = SettingsViewController(viewModel: self.viewModel)
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        self.present(settingsNavigationController, animated: true, completion: nil)
    }

    func showPackageDetails(_ package: ObservablePackage) {
        let packageViewModel = PackageViewModel(package: package)
        let packageViewController = PackageViewController(packageViewModel: packageViewModel, packagesViewModel: viewModel)
        self.navigationController?.pushViewController(packageViewController, animated: true)
    }

}

extension PackagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Archive"
    }
}
