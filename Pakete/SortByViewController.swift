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

    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    fileprivate let viewModel: PackagesViewModel
    fileprivate var selectedIndexPath: IndexPath?

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
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SortByCell")
        self.tableView.rowHeight = 44.0
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        self.tableView.constrainEdges(toView: self.view)

        let sortByTypes = Variable(PackagesSortByType.arrayValues)
        sortByTypes.asDriver()
            .drive(self.tableView.rx.items(cellIdentifier: "SortByCell", cellType: UITableViewCell.self)) { [unowned self] (index, sortByType, cell) in
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
                cell.textLabel?.text = sortByType.description
                cell.tintColor = .gray
                if sortByType == self.viewModel.packagesSortBy() {
                    self.selectedIndexPath = IndexPath(row: index, section: 0)
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
            .addDisposableTo(self.rx_disposeBag)

        self.tableView.rx.itemSelected
            .asDriver()
            .drive(onNext: { (indexPath) in
                self.tableView.deselectRow(at: indexPath, animated: true)
                let packageSortByType = sortByTypes.value[indexPath.row]
                self.viewModel.sortBy(packageSortByType)
                self.tableView.reloadData()
                _ = self.navigationController?.popViewController(animated: true)
            })
            .addDisposableTo(self.rx_disposeBag)

        // track mixpanel
        Mixpanel.sharedInstance().track("Sort By View")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
