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
import Mixpanel

class AddPackageViewController: UIViewController {

    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    // static cells
    fileprivate let trackingNumberCell = TextFieldTableViewCell()
    fileprivate var extraFieldCell: TextFieldTableViewCell?
    fileprivate let nameCell = TextFieldTableViewCell()
    fileprivate let addButton = UIButton()
    fileprivate let archiveButton = UIButton()

    fileprivate var trackingNumber = Variable<String>("")
    fileprivate var name = Variable<String>("")
    fileprivate var extraField = Variable<String>("")

    fileprivate let courier: Courier
    fileprivate let viewModel: PackagesViewModel
    fileprivate var package: ObservablePackage?

    fileprivate var editPackage = false
    fileprivate var interstitialAd: GADInterstitial!

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
        self.tableView.register(TextFieldTableViewCell.self,
                                     forCellReuseIdentifier: TextFieldTableViewCell.reuseIdentifier)
        self.tableView.rowHeight = 44.0
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        self.tableView.constrainEdges(toView: self.view)
        // setup footer view buttons
        self.setupFooterView()
        // setup interstitial ad
        self.setupInterstitialAd()

        // setup static cells
        self.trackingNumberCell.textField.placeholder = "Tracking Number"
        self.trackingNumberCell.textField.keyboardType = .namePhonePad
        self.nameCell.textField.placeholder = "Description"
        self.nameCell.textField.returnKeyType = .done

        // if JRS we have extra field!
        // TODO: shouldn't be harcoded :(
        if self.courier.code == "jrs" {
            self.extraFieldCell = TextFieldTableViewCell()
            self.extraFieldCell?.textField.placeholder = "BC"
            self.extraFieldCell?.textField.keyboardType = .numberPad
        }

        // add cancel button if edit package
        if self.editPackage, let package = self.package {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelButton))
            // populate textfields
            self.nameCell.textField.text = package.value.name
            // if JRS split the tracking number to get BC
            if self.courier.code == "jrs" {
                // split tracking number to get BC
                let trackingNumbers = self.package?.value.trackingNumber.characters.split { $0 == "-" }.map(String.init)
                self.trackingNumberCell.textField.text = trackingNumbers?.first
                self.extraFieldCell?.textField.text = trackingNumbers?.last
            } else {
                self.trackingNumberCell.textField.text = package.value.trackingNumber
            }

            // disable tracking number cell
            self.trackingNumberCell.textField.isEnabled = false
            self.trackingNumberCell.textField.textColor = .lightGray
            self.extraFieldCell?.textField.isEnabled = false
            self.extraFieldCell?.textField.textColor = .lightGray
        }

        // bindings
        self.trackingNumberCell.textField.rx.text
            .asDriver()
            .drive(self.trackingNumber)
            .addDisposableTo(self.rx_disposeBag)

        self.nameCell.textField.rx.text
            .asDriver()
            .drive(self.name)
            .addDisposableTo(self.rx_disposeBag)

        self.extraFieldCell?.textField.rx.text
            .asDriver()
            .drive(self.extraField)
            .addDisposableTo(self.rx_disposeBag)

        let trackingNumberIsValid = self.trackingNumber.asDriver()
            .map(isNotEmptyString)

        let nameIsValid = self.name.asDriver()
            .map(isNotEmptyString)

        var formValidations = [trackingNumberIsValid, nameIsValid]
        if self.extraFieldCell != nil {
            let extraFieldIsValid = self.extraField.asDriver().map(isNotEmptyString)
            formValidations.append(extraFieldIsValid)
        }

        // observe if form is valid
        let formIsValid = formValidations
            .map { $0.asObservable() }
            .combineLatest { (items) -> Bool in
                return !items.contains(false)
            }
            .asDriver(onErrorJustReturn: false)

        formIsValid.drive(self.addButton.rx.enabled)
            .addDisposableTo(rx_disposeBag)
        formIsValid.map({ $0 ? 1.0 : 0.5 })
            .drive(self.addButton.rx.alpha)
            .addDisposableTo(self.rx_disposeBag)

        if editPackage {
            self.nameCell.textField.becomeFirstResponder()
        } else {
            self.trackingNumberCell.textField.becomeFirstResponder()
        }

        // track mixpanel
        Mixpanel.sharedInstance().track("Add Package View")
    }

    override func viewWillDisappear(_ animated: Bool) {
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
        self.interstitialAd.load(request)
    }

    func setupFooterView() {
        let tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 44.0))
        // add Add button
        self.addButton.translatesAutoresizingMaskIntoConstraints = false
        self.addButton.setTitle((editPackage ? "Update Package" : "Add Package"), for: UIControlState())
        self.addButton.backgroundColor = ColorPalette.Matisse
        self.addButton.setTitleColor(.white, for: .normal)
        if editPackage {
            self.addButton.addTarget(self, action: #selector(didTapUpdateButton), for: .touchUpInside)
        } else {
            self.addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        }
        tableFooterView.addSubview(self.addButton)
        self.addButton.constrainEqual(.top, to: tableFooterView)
        self.addButton.constrainEqual(.leading, to: tableFooterView)
        self.addButton.constrainEqual(.trailing, to: tableFooterView)
        self.addButton.constrainEqual(.height, to: nil, .notAnAttribute, constant: 44.0)

        if editPackage {
            // add archive package button
            self.archiveButton.translatesAutoresizingMaskIntoConstraints = false
            self.archiveButton.setTitle("Archive Package", for: UIControlState())
            self.archiveButton.backgroundColor = .red
            self.archiveButton.setTitleColor(.white, for: .normal)
            self.archiveButton.addTarget(self, action: #selector(didTapArchiveButton), for: .touchUpInside)
            tableFooterView.addSubview(self.archiveButton)
            self.archiveButton.constrainEqual(.top, to: self.addButton, .bottom, constant: 10.0)
            self.archiveButton.constrainEqual(.leading, to: tableFooterView)
            self.archiveButton.constrainEqual(.trailing, to: tableFooterView)
            self.archiveButton.constrainEqual(.height, to: nil, .notAnAttribute, constant: 44.0)
            // adjust height
            tableFooterView.frame.size.height = 98.0
        }

        self.tableView.tableFooterView = tableFooterView
    }

    func didTapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }

    func didTapAddButton() {
        let trackingNumber = self.extraFieldCell == nil ? self.trackingNumber.value : self.trackingNumber.value + "-" + self.extraField.value
        if let existingPackage = self.viewModel.packageWithTrackingNumber(trackingNumber, courier: self.courier) {
            // package already exists!
            // check if already archived
            if existingPackage.archived {
                let alertController = UIAlertController(title: "Hey!", message: "This package has already been archived! Would you like to unarchive this package?", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) -> Void in
                    // unarchive package
                    self.viewModel.unarchivePackage(existingPackage)
                    // dismiss
                    self.dismiss(animated: true, completion: nil)
                }))
                alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                alertController.view.tintColor = ColorPalette.Matisse
            } else {
                let alertController = UIAlertController(title: "Hey!", message: "This package already exists!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                alertController.view.tintColor = ColorPalette.Matisse
            }

            return
        }

        // hide keyboard
        self.view.endEditing(true)
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.black)

        let package = Package(name: self.name.value, trackingNumber: trackingNumber, courier: self.courier)
        self.viewModel.trackPackage(ObservablePackage(package))
            .map { [unowned self] observablePackage in
                SVProgressHUD.dismiss()
                // track mixpanel
                Mixpanel.sharedInstance().track("Added Package", properties: ["Courier": self.courier.name])
                // show interstitial ad
                if self.interstitialAd.isReady && IAPHelper.showAds() {
                    self.interstitialAd.present(fromRootViewController: self)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
                // add to package list
                self.viewModel.addPackage(observablePackage)
                // show package
                self.viewModel.showPackage.onNext(observablePackage.value)
            }
            .subscribe(onError: { [unowned self] (error) in
                SVProgressHUD.dismiss()
                // focus back to tracking number textfield
                self.trackingNumberCell.textField.becomeFirstResponder()

                // show error
                let error = error as NSError
                let alertController = UIAlertController(title: "Sorry!", message: error.localizedFailureReason, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                alertController.view.tintColor = ColorPalette.Matisse
            })
            .addDisposableTo(rx_disposeBag)
    }

    func didTapUpdateButton() {
        if let package = self.package {
            self.viewModel.updatePackageName(self.name.value, package: package)
        }
        self.dismiss(animated: true, completion: nil)
    }

    func didTapArchiveButton() {
        // show action sheet
        let actionSheetController = UIAlertController(title: "Archive Package", message: "Are you sure you want to archive this package?", preferredStyle: .actionSheet)
        actionSheetController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (alertAction) -> Void in
            if let package = self.package {
                // track mixpanel
                Mixpanel.sharedInstance().track("Archived Package")
                self.viewModel.archivePackage(package)
                self.dismiss(animated: true, completion: nil)
            }
        }))
        actionSheetController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(actionSheetController, animated: true, completion: nil)
        actionSheetController.view.tintColor = ColorPalette.Matisse
    }
}

// MARK: - UITableViewDataSource
extension AddPackageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.extraFieldCell == nil ? 2 : 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).row {
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
    func interstitialWillDismissScreen(_ adInterstitial: GADInterstitial!) {
        self.dismiss(animated: false, completion: nil)
    }

    func interstitialWillLeaveApplication(_ adInterstitial: GADInterstitial!) {
        self.dismiss(animated: false, completion: nil)
    }
}
