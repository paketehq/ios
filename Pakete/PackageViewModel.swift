//
//  PackageViewModel.swift
//  Pakete
//
//  Created by Royce Albert Dy on 15/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import Foundation
import RxSwift

protocol PackageViewModelType {
    var dateFormatter: NSDateFormatter { get }
    func status() -> String
    func lastUpdateDateString() -> String
}

struct PackageViewModel: PackageViewModelType {
    
    var dateFormatter: NSDateFormatter
    var package: Variable<Package>
    
    init(package: Variable<Package>) {
        self.package = package
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.locale = NSLocale.currentLocale()
        self.dateFormatter.doesRelativeDateFormatting = true
        self.dateFormatter.dateStyle = .ShortStyle
    }
    
    func name() -> String {
        return self.package.value.name.capitalizedString
    }
    
    func status() -> String {
        guard let latestTrackHistory = self.package.value.latestTrackHistory() else { return "" }
        return latestTrackHistory.status.capitalizedString
    }
    
    func lastUpdateDateString() -> String {
        guard let latestTrackHistory = self.package.value.latestTrackHistory() else { return "" }
        return self.dateFormatter.stringFromDate(latestTrackHistory.date)
    }
    
    func trackingNumber() -> String {
        return self.package.value.trackingNumber.uppercaseString
    }
    
    func courierName() -> String {
        return self.package.value.courier?.name.capitalizedString ?? ""
    }
    
    func numberOfTrackHistory() -> Int {
        return self.package.value.trackHistory.count
    }
    
    func updating() -> Bool {
        return self.package.value.updating
    }
    
    func trackHistoryViewModelAtIndexPath(indexPath: NSIndexPath) -> PackageTrackHistoryViewModel {
        let packageTrackHistory = self.package.value.trackHistory[indexPath.row]
        return PackageTrackHistoryViewModel(packageTrackHistory: packageTrackHistory)
    }
}

struct PackageTrackHistoryViewModel: PackageViewModelType {
    
    var dateFormatter: NSDateFormatter
    private let packageTrackHistory: PackageTrackHistory

    init(packageTrackHistory: PackageTrackHistory) {
        self.packageTrackHistory = packageTrackHistory
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.locale = NSLocale.currentLocale()
        self.dateFormatter.doesRelativeDateFormatting = true
        self.dateFormatter.dateStyle = .MediumStyle
    }
    
    func status() -> String {
        return self.packageTrackHistory.status.capitalizedString
    }
    
    func lastUpdateDateString() -> String {
        return self.dateFormatter.stringFromDate(self.packageTrackHistory.date)
    }
}