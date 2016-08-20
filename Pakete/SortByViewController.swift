//
//  SortByViewController.swift
//  Pakete
//
//  Created by Royce Albert Dy on 30/05/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Mixpanel

class SortByViewController: UIViewController {

    private let tableView = UITableView(frame: CGRect.zero, style: .Grouped)
    private let viewModel: PackagesViewModel
    private var selectedIndexPath: NSIndexPath?

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
        self.title = "Sort By"

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SortByCell")
        self.tableView.rowHeight = 44.0
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        self.tableView.constrainEdges(toView: self.view)

        let sortByTypes = Variable(PackagesSortByType.arrayValues)
        sortByTypes.asObservable()
            .bindTo(self.tableView.rx_itemsWithCellIdentifier("SortByCell", cellType: UITableViewCell.self)) { [unowned self] (index, sortByType, cell) in
                cell.textLabel?.font = UIFont.systemFontOfSize(15.0)
                cell.textLabel?.text = sortByType.description
                cell.tintColor = .grayColor()
                if sortByType == self.viewModel.packagesSortBy() {
                    self.selectedIndexPath = NSIndexPath(forRow: index, inSection: 0)
                    cell.accessoryType = .Checkmark
                } else {
                    cell.accessoryType = .None
                }
            }
            .addDisposableTo(self.rx_disposeBag)

        self.tableView.rx_itemSelected
            .subscribeNext { [unowned self] (indexPath) -> Void in
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                let packageSortByType = sortByTypes.value[indexPath.row]
                self.viewModel.sortBy(packageSortByType)
                self.tableView.reloadData()
                self.navigationController?.popViewControllerAnimated(true)
            }
            .addDisposableTo(self.rx_disposeBag)

        // track mixpanel
        Mixpanel.sharedInstance().track("Sort By View")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
