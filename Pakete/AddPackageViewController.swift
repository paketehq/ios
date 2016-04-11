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
import GoogleMobileAds
import Keys

class AddPackageViewController: UIViewController {
    
    private let tableView = UITableView(frame: CGRect.zero, style: .Grouped)
    // static cells
    private let trackingNumberCell = TextFieldTableViewCell()
    private var extraFieldCell: TextFieldTableViewCell?
    private let nameCell = TextFieldTableViewCell()
    private let addButton = UIButton()
    private let archiveButton = UIButton()

    private var trackingNumber = Variable<String>("")
    private var name = Variable<String>("")
    private var extraField = Variable<String>("")

    private let courier: Courier
    private let viewModel: PackagesViewModel
    private var package: ObservablePackage?
    
    private var editPackage = false
    private var interstitialAd: GADInterstitial!
    
    init(viewModel: PackagesViewModel, courier: Courier) {
        self.viewModel = viewModel
        self.courier = courier
        super.init(nibName: nil, bundle: nil)
    }
    
    init(viewModel: PackagesViewModel, package: ObservablePackage) {
        self.viewModel = viewModel
        self.package = package
        self.courier = package.value.courier
        self.editPackage = true
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
        // setup footer view buttons
        self.setupFooterView()
        // setup interstitial ad
        self.setupInterstitialAd()
        
        // setup static cells
        self.trackingNumberCell.textField.placeholder = "Code"
        self.trackingNumberCell.textField.keyboardType = .NamePhonePad
        self.nameCell.textField.placeholder = "Name"
        self.nameCell.textField.returnKeyType = .Done
        
        // if JRS we have extra field!
        // TODO: shouldn't be harcoded :(
        if self.courier.code == "jrs" {
            self.extraFieldCell = TextFieldTableViewCell()
            self.extraFieldCell?.textField.placeholder = "BC"
            self.extraFieldCell?.textField.keyboardType = .NumberPad
        }
        
        // add cancel button if edit package
        if editPackage, let package = self.package {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(didTapCancelButton))
            // populate textfields
            self.nameCell.textField.text = package.value.name
            // if JRS split the tracking number to get BC
            if self.courier.code == "jrs" {
                // split tracking number to get BC
                let trackingNumbers = self.package?.value.trackingNumber.componentsSeparatedByString("-")
                self.trackingNumberCell.textField.text = trackingNumbers?.first
                self.extraFieldCell?.textField.text = trackingNumbers?.last
            } else {
                self.trackingNumberCell.textField.text = package.value.trackingNumber
            }
            
            // disable tracking number cell
            self.trackingNumberCell.textField.enabled = false
            self.trackingNumberCell.textField.textColor = .lightGrayColor()
            self.extraFieldCell?.textField.enabled = false
            self.extraFieldCell?.textField.textColor = .lightGrayColor()
        }
        
        // bindings
        self.trackingNumberCell.textField.rx_text
            .bindTo(self.trackingNumber)
            .addDisposableTo(self.rx_disposeBag)
        
        self.nameCell.textField.rx_text
            .bindTo(self.name)
            .addDisposableTo(self.rx_disposeBag)
        
        self.extraFieldCell?.textField.rx_text
            .bindTo(self.extraField)
            .addDisposableTo(self.rx_disposeBag)

        let trackingNumberIsValid = self.trackingNumber.asObservable()
            .map(isNotEmptyString)
        
        let nameIsValid = self.name.asObservable()
            .map(isNotEmptyString)
        
        var formValidations = [trackingNumberIsValid, nameIsValid]
        if self.extraFieldCell != nil {
            let extraFieldIsValid = self.extraField.asObservable().map(isNotEmptyString)
            formValidations.append(extraFieldIsValid)
        }
        
        // observe if form is valid
        let formIsValid = formValidations.combineLatestAnd()
        formIsValid.bindTo(self.addButton.rx_enabled)
            .addDisposableTo(rx_disposeBag)
        formIsValid.map({ $0 ? 1.0 : 0.5 })
            .bindTo(self.addButton.rx_alpha)
            .addDisposableTo(self.rx_disposeBag)
        
        if editPackage {
            self.nameCell.textField.becomeFirstResponder()
        } else {
            self.trackingNumberCell.textField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true) // hide keyboard
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - Methods
extension AddPackageViewController {
    func setupInterstitialAd() {
        let keys = PaketeKeys()
        self.interstitialAd = GADInterstitial(adUnitID: keys.adMobInterstitialAdUnitIDKey())
        self.interstitialAd.delegate = self
        let request = GADRequest()
        // Requests test ads on test devices.
        request.testDevices = [kGADSimulatorID]
        self.interstitialAd.loadRequest(request)
    }
    
    func setupFooterView() {
        let tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 44.0))
        // add Add button
        self.addButton.translatesAutoresizingMaskIntoConstraints = false
        self.addButton.setTitle((editPackage ? "Update Package" : "Add Package"), forState: .Normal)
        self.addButton.backgroundColor = ColorPalette.Matisse
        self.addButton.setTitleColor(.whiteColor(), forState: .Normal)
        if editPackage {
            self.addButton.addTarget(self, action: #selector(didTapUpdateButton), forControlEvents: .TouchUpInside)
        } else {
            self.addButton.addTarget(self, action: #selector(didTapAddButton), forControlEvents: .TouchUpInside)
        }
        tableFooterView.addSubview(self.addButton)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: self.addButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 44.0),
            NSLayoutConstraint(item: self.addButton, attribute: .Top, relatedBy: .Equal, toItem: tableFooterView, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.addButton, attribute: .Leading, relatedBy: .Equal, toItem: tableFooterView, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.addButton, attribute: .Trailing, relatedBy: .Equal, toItem: tableFooterView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        ])
        
        if editPackage {
            // add archive package button
            self.archiveButton.translatesAutoresizingMaskIntoConstraints = false
            self.archiveButton.setTitle("Archive Package", forState: .Normal)
            self.archiveButton.backgroundColor = .redColor()
            self.archiveButton.setTitleColor(.whiteColor(), forState: .Normal)
            self.archiveButton.addTarget(self, action: #selector(didTapArchiveButton), forControlEvents: .TouchUpInside)
            tableFooterView.addSubview(self.archiveButton)
            NSLayoutConstraint.activateConstraints([
                NSLayoutConstraint(item: self.archiveButton, attribute: .Top, relatedBy: .Equal, toItem: self.addButton, attribute: .Bottom, multiplier: 1.0, constant: 10.0),
                NSLayoutConstraint(item: self.archiveButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 44.0),
                NSLayoutConstraint(item: self.archiveButton, attribute: .Leading, relatedBy: .Equal, toItem: tableFooterView, attribute: .Leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.archiveButton, attribute: .Trailing, relatedBy: .Equal, toItem: tableFooterView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
            ])
            // adjust height
            tableFooterView.frame.size.height = 98.0
        }
        
        self.tableView.tableFooterView = tableFooterView
    }
    
    func didTapCancelButton() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
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
                alertController.view.tintColor = ColorPalette.Matisse
            } else {
                let alertController = UIAlertController(title: "Hey!", message: "This package already exists!", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                alertController.view.tintColor = ColorPalette.Matisse
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
                    // show interstitial ad
                    if self.interstitialAd.isReady {
                        self.interstitialAd.presentFromRootViewController(self)
                    } else {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                case .Error(let error):
                    // focus back to tracking number textfield
                    self.trackingNumberCell.textField.becomeFirstResponder()
                    
                    // show error
                    let error = error as NSError
                    let alertController = UIAlertController(title: "Sorry!", message: error.localizedFailureReason, preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    alertController.view.tintColor = ColorPalette.Matisse
                default: ()
                }
            })
            .addDisposableTo(self.rx_disposeBag)
    }
    
    func didTapUpdateButton() {
        self.viewModel.updatePackageName(self.name.value, package: self.package!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didTapArchiveButton() {
        // show action sheet
        let actionSheetController = UIAlertController(title: "Archive Package", message: "Are you sure you want to archive this package?", preferredStyle: .ActionSheet)
        actionSheetController.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: { (alertAction) -> Void in
            if let package = self.package {
                self.viewModel.archivePackage(package)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }))
        actionSheetController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        actionSheetController.view.tintColor = ColorPalette.Matisse
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

// MARK: - GADInterstitialDelegate
extension AddPackageViewController: GADInterstitialDelegate {
    func interstitialWillDismissScreen(ad: GADInterstitial!) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func interstitialWillLeaveApplication(ad: GADInterstitial!) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}