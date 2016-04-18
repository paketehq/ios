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

class PackageViewController: UIViewController {
    
    private let tableView = UITableView(frame: CGRect.zero, style: .Grouped)
    private let packageViewModel: PackageViewModel
    private let packagesViewModel: PackagesViewModel
    private var noInformationAvailableYetLabel: UILabel?
    
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
        // add edit bar button item
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(didTapEditButton))
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.backgroundColor = ColorPalette.BlackHaze
        self.tableView.dataSource = self
        self.tableView.registerClass(PackageTrackHistoryTableViewCell.self, forCellReuseIdentifier: PackageTrackHistoryTableViewCell.reuseIdentifier)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.separatorStyle = .None
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: self.tableView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.tableView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.tableView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.tableView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        ])
        // setup table header view
        self.setupTableHeaderView()
        
        // bindings
        self.packageViewModel.package.asObservable()
            .subscribeNext { (package) -> Void in
                if package.archived {
                    // if archived then pop navigation controller
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    self.title = self.packageViewModel.name()
                    self.tableView.reloadData()
                    if package.trackHistory.count > 0 {
                        self.hideNoInformationAvailableYetLabel()
                    } else {
                        self.showNoInformationAvailableYetLabel()
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
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: trackingNumberLabel, attribute: .Top, relatedBy: .Equal, toItem: tableHeaderView, attribute: .Top, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: trackingNumberLabel, attribute: .Leading, relatedBy: .Equal, toItem: tableHeaderView, attribute: .Leading, multiplier: 1.0, constant: 15.0)
        ])
        
        // courier label
        let courierLabel = UILabel()
        courierLabel.translatesAutoresizingMaskIntoConstraints = false
        courierLabel.text = self.packageViewModel.courierName()
        courierLabel.textColor = .lightGrayColor()
        courierLabel.font = UIFont.systemFontOfSize(14.0)
        courierLabel.adjustFontToRealIPhoneSize = true
        tableHeaderView.addSubview(courierLabel)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: courierLabel, attribute: .Top, relatedBy: .Equal, toItem: trackingNumberLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: courierLabel, attribute: .Leading, relatedBy: .Equal, toItem: tableHeaderView, attribute: .Leading, multiplier: 1.0, constant: 15.0)
        ])
        
        // adjust height
        let trackingNumberSize = trackingNumberLabel.sizeThatFits(CGSize(width: tableHeaderView.frame.width - 30.0, height: CGFloat.max))
        let courierSize = courierLabel.sizeThatFits(CGSize(width: tableHeaderView.frame.width - 30.0, height: CGFloat.max))
        tableHeaderView.frame.size.height = trackingNumberSize.height + courierSize.height + 20.0
        
        self.tableView.tableHeaderView = tableHeaderView
    }
    
    func didTapEditButton() {
        let editPackageViewController = AddPackageViewController(viewModel: packagesViewModel, package: self.packageViewModel.package)
        let editPackageNavigationController = UINavigationController(rootViewController: editPackageViewController)
        self.presentViewController(editPackageNavigationController, animated: true, completion: nil)
    }
    
    func showNoInformationAvailableYetLabel() {
        if self.noInformationAvailableYetLabel == nil {
            self.noInformationAvailableYetLabel = UILabel()
            self.noInformationAvailableYetLabel?.text = "No information available yet.\nPlease try again later."
            self.noInformationAvailableYetLabel?.textAlignment = .Center
            self.noInformationAvailableYetLabel?.numberOfLines = 2
            self.noInformationAvailableYetLabel?.translatesAutoresizingMaskIntoConstraints = false
            self.noInformationAvailableYetLabel?.font = UIFont.systemFontOfSize(14.0)
            self.noInformationAvailableYetLabel?.adjustFontToRealIPhoneSize = true
            self.view.addSubview(self.noInformationAvailableYetLabel!)
            NSLayoutConstraint.activateConstraints([
                NSLayoutConstraint(item: self.noInformationAvailableYetLabel!, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: self.noInformationAvailableYetLabel!, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: -15.0),
                NSLayoutConstraint(item: self.noInformationAvailableYetLabel!, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
            ])
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
        let cell = tableView.dequeueReusableCellWithIdentifier(PackageTrackHistoryTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! PackageTrackHistoryTableViewCell
        
        cell.configure(withViewModel: self.packageViewModel.trackHistoryViewModelAtIndexPath(indexPath))

        return cell
    }
}