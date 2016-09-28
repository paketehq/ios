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

    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    fileprivate let viewModel: PackagesViewModel

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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelButton))
        // remove back button title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CourierCell")
        self.tableView.rowHeight = 44.0
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        self.tableView.constrainEdges(toView: self.view)

        self.viewModel.couriers
            .asDriver()
            .drive(self.tableView.rx.items(cellIdentifier: "CourierCell", cellType: UITableViewCell.self)) { (_, courier, cell) in
                cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
                cell.textLabel?.text = courier.name
            }
            .addDisposableTo(self.rx_disposeBag)

        self.tableView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [unowned self] (indexPath) in
                self.tableView.deselectRow(at: indexPath, animated: true)
                let courier = self.viewModel.couriers.value[indexPath.row]
                let addPackageViewController = AddPackageViewController(viewModel: self.viewModel, courier: courier)
                self.navigationController?.pushViewController(addPackageViewController, animated: true)
            })
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
        self.dismiss(animated: true, completion: nil)
    }
}
