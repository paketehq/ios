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
    func status() -> String
}

struct PackageViewModel: PackageViewModelType {

    let package: Variable<Package>

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

    func trackingNumber() -> String {
        return self.package.value.trackingNumber.uppercaseString
    }

    func courierName() -> String {
        return self.package.value.courier?.name ?? ""
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

    func latestTrackHistory() -> PackageTrackHistoryViewModel? {
        if let latestTrackHistory = self.package.value.latestTrackHistory() {
            return PackageTrackHistoryViewModel(packageTrackHistory: latestTrackHistory)
        }
        return nil
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
        return stringFromDate(self.packageTrackHistory.date, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
    }
}
