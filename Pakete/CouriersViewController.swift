//
//  CouriersViewController.swift
//  Pakete
//
//  Created by Royce Albert Dy on 14/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Mixpanel

class CouriersViewController: UIViewController {

    private let tableView = UITableView(frame: CGRect.zero, style: .Grouped)
    private let viewModel: PackagesViewModel

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
        self.title = "Couriers"
        // add Cancel bar button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(didTapCancelButton))
        // remove back button title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CourierCell")
        self.tableView.rowHeight = 44.0
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        self.tableView.constrainEdges(toView: self.view)

        self.viewModel.couriers.asObservable()
            .bindTo(self.tableView.rx_itemsWithCellIdentifier("CourierCell", cellType: UITableViewCell.self)) { (_, courier, cell) in
                cell.textLabel?.font = UIFont.systemFontOfSize(16.0)
                cell.textLabel?.text = courier.name
            }
            .addDisposableTo(self.rx_disposeBag)

        self.tableView.rx_itemSelected
            .subscribeNext { [unowned self] (indexPath) -> Void in
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
            .addDisposableTo(self.rx_disposeBag)

        self.tableView.rx_modelSelected(Courier)
            .subscribeNext { [unowned self] courier in
                let addPackageViewController = AddPackageViewController(viewModel: self.viewModel, courier: courier)
                self.navigationController?.pushViewController(addPackageViewController, animated: true)
            }
            .addDisposableTo(self.rx_disposeBag)

        // track mixpanel
        Mixpanel.sharedInstance().track("Couriers View")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension CouriersViewController {
    func didTapCancelButton() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
