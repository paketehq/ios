//
//  PackageViewModel.swift
//  Pakete
//
//  Created by Royce Albert Dy on 15/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import Foundation
import RxSwift
import NSDate_TimeAgo

protocol PackageViewModelType {
    func status() -> String
    func lastUpdateDateString() -> String
}

struct PackageViewModel: PackageViewModelType {
    
    var package: Variable<Package>
    
    init(package: Variable<Package>) {
        self.package = package
    }
    
    func name() -> String {
        return self.package.value.name.capitalizedString
    }
    
    func status() -> String {
        guard let latestTrackHistory = self.package.value.latestTrackHistory() else { return "No information available yet" }
        return latestTrackHistory.status
    }
    
    func lastUpdateDateString() -> String {
        guard let latestTrackHistory = self.package.value.latestTrackHistory() else { return "" }
        return latestTrackHistory.date.timeAgoSimple()
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
    
    func completed() -> Bool {
        return self.package.value.completed
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
    
    private let packageTrackHistory: PackageTrackHistory

    init(packageTrackHistory: PackageTrackHistory) {
        self.packageTrackHistory = packageTrackHistory
    }
    
    func status() -> String {
        return self.packageTrackHistory.status
    }
    
    func lastUpdateDateString() -> String {
        return self.packageTrackHistory.date.timeAgo()
    }
}