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

class PackageViewController: UIViewController {
    
    private let tableView = UITableView(frame: CGRect.zero, style: .Grouped)
    private let viewModel: PackageViewModel
    
    init(viewModel: PackageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = self.viewModel.name()
        
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
        self.viewModel.package.asObservable()
            .subscribeNext { (_) -> Void in
                self.tableView.reloadData()
            }
            .addDisposableTo(self.rx_disposeBag)
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
        let tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 56.5))
        tableHeaderView.backgroundColor = .whiteColor()
        
        // tracking number label
        let trackingNumberLabel = UILabel()
        trackingNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        trackingNumberLabel.text = self.viewModel.trackingNumber()
        trackingNumberLabel.font = UIFont.systemFontOfSize(16.0)
        tableHeaderView.addSubview(trackingNumberLabel)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: trackingNumberLabel, attribute: .Top, relatedBy: .Equal, toItem: tableHeaderView, attribute: .Top, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: trackingNumberLabel, attribute: .Leading, relatedBy: .Equal, toItem: tableHeaderView, attribute: .Leading, multiplier: 1.0, constant: 15.0)
        ])
        
        // courier label
        let courierLabel = UILabel()
        courierLabel.translatesAutoresizingMaskIntoConstraints = false
        courierLabel.text = self.viewModel.courierName()
        courierLabel.textColor = .lightGrayColor()
        courierLabel.font = UIFont.systemFontOfSize(14.0)
        tableHeaderView.addSubview(courierLabel)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: courierLabel, attribute: .Top, relatedBy: .Equal, toItem: trackingNumberLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: courierLabel, attribute: .Leading, relatedBy: .Equal, toItem: tableHeaderView, attribute: .Leading, multiplier: 1.0, constant: 15.0)
        ])
        
        self.tableView.tableHeaderView = tableHeaderView
    }    
}


// MARK: - UITableViewDataSource
extension PackageViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfTrackHistory()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PackageTrackHistoryTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! PackageTrackHistoryTableViewCell
        
        cell.configure(withViewModel: self.viewModel.trackHistoryViewModelAtIndexPath(indexPath))

        return cell
    }
}