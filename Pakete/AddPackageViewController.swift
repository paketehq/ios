//
//  AddPackageViewController.swift
//  Pakete
//
//  Created by Royce Albert Dy on 13/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SVProgressHUD

class AddPackageViewController: UIViewController {
    
    private let tableView = UITableView(frame: CGRect.zero, style: .Grouped)
    // static cells
    private let trackingNumberCell = TextFieldTableViewCell()
    private var extraFieldCell: TextFieldTableViewCell?
    private let nameCell = TextFieldTableViewCell()
    private let addButton = UIButton()
    
    private var trackingNumber = Variable<String>("")
    private var name = Variable<String>("")
    private var extraField = Variable<String>("")

    private let courier: Courier
    private let viewModel: PackagesViewModel
    
    init(viewModel: PackagesViewModel, courier: Courier) {
        self.viewModel = viewModel
        self.courier = courier
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = self.courier.name

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.reuseIdentifier)
        self.tableView.rowHeight = 44.0
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: self.tableView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.tableView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.tableView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.tableView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        ])
        // add Add button
        let tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 44.0))
        self.addButton.translatesAutoresizingMaskIntoConstraints = false
        self.addButton.setTitle("Add Package", forState: .Normal)
        self.addButton.setTitleColor(UIColor(red:0, green:0.46, blue:1, alpha:1), forState: .Normal)
        self.addButton.addTarget(self, action: #selector(didTapAddButton), forControlEvents: .TouchUpInside)
        tableFooterView.addSubview(self.addButton)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: self.addButton, attribute: .Top, relatedBy: .Equal, toItem: tableFooterView, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.addButton, attribute: .Bottom, relatedBy: .Equal, toItem: tableFooterView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.addButton, attribute: .Leading, relatedBy: .Equal, toItem: tableFooterView, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.addButton, attribute: .Trailing, relatedBy: .Equal, toItem: tableFooterView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        ])
        self.tableView.tableFooterView = tableFooterView
        
        // setup static cells
        self.trackingNumberCell.textField.placeholder = "Code"
        self.trackingNumberCell.textField.keyboardType = .NamePhonePad
        self.nameCell.textField.placeholder = "Name"
        
        // if JRS we have extra field!
        // TODO: shouldn't be harcoded :(
        if self.courier.code == "jrs" {
            self.extraFieldCell = TextFieldTableViewCell()
            self.extraFieldCell?.textField.placeholder = "BC"
            self.extraFieldCell?.textField.keyboardType = .NumberPad
            
            self.extraFieldCell?.textField.rx_text
                .bindTo(self.extraField)
                .addDisposableTo(self.rx_disposeBag)
        }
        
        // bindings
        self.trackingNumberCell.textField.rx_text
            .bindTo(self.trackingNumber)
            .addDisposableTo(self.rx_disposeBag)
        
        self.nameCell.textField.rx_text
            .bindTo(self.name)
            .addDisposableTo(self.rx_disposeBag)

        let trackingNumberIsValid = self.trackingNumber.asObservable()
            .map(isNotEmptyString)
        
        let nameIsValid = self.name.asObservable()
            .map(isNotEmptyString)
        
        let extraFieldIsValid = self.extraFieldCell == nil ? Variable(true).asObservable() : self.extraField.asObservable()
            .map(isNotEmptyString)
        
        // observe if form is valid
        let formIsValid = Observable.combineLatest(trackingNumberIsValid, nameIsValid, extraFieldIsValid) { $0 && $1 && $2 }
        formIsValid.map({ $0 ? 1.0 : 0.0 })
            .bindTo(self.addButton.rx_alpha)
            .addDisposableTo(self.rx_disposeBag)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // only if still empty
        if self.trackingNumberCell.textField.text!.isEmpty {
            self.trackingNumberCell.textField.becomeFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - Methods
extension AddPackageViewController {
    func didTapAddButton() {
        let trackingNumber = self.extraFieldCell == nil ? self.trackingNumber.value : self.trackingNumber.value + "-" + self.extraField.value
        if let existingPackage = self.viewModel.packageWithTrackingNumber(trackingNumber, courier: self.courier) {
            // package already exists!
            // check if already archived
            if existingPackage.archived {
                let alertController = UIAlertController(title: "Hey!", message: "This package has already been archived! Would you like to unarchive this package?", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (alertAction) -> Void in
                    // unarchive package
                    self.viewModel.unarchivePackage(existingPackage)
                    // dismiss
                    self.dismissViewControllerAnimated(true, completion: nil)
                }))
                alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Hey!", message: "This package already exists!", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }

            return
        }
        
        // hide keyboard
        self.view.endEditing(true)
        SVProgressHUD.showWithMaskType(.Black)
        
        self.viewModel.addPackage(trackingNumber, courier: self.courier, name: self.name.value)
            .subscribe({ (event) -> Void in
                SVProgressHUD.dismiss()
                switch event {
                case .Next(_):
                    self.dismissViewControllerAnimated(true, completion: nil)
                case .Error(let error):
                    // focus back to tracking number textfield
                    self.trackingNumberCell.textField.becomeFirstResponder()
                    
                    // show error
                    let error = error as NSError
                    let alertController = UIAlertController(title: "Sorry!", message: error.localizedFailureReason, preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                default: ()
                }
            })
            .addDisposableTo(self.rx_disposeBag)
    }
}

// MARK: - UITableViewDataSource
extension AddPackageViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.extraFieldCell == nil ? 2 : 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: return self.trackingNumberCell
        case 1: return self.extraFieldCell ?? self.nameCell
        case 2: return self.nameCell
        default: ()
            fatalError("invalid indexpath")
        }
    }
}