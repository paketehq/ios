//
//  Package.swift
//  Pakete
//
//  Created by Royce Albert Dy on 13/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class PackageTrackHistory: Object {
    dynamic var date = Date(timeIntervalSince1970: 1)
    dynamic var status = ""

    convenience init(json: JSON) {
        self.init()
        self.status = json["status"].stringValue
        if let date = dateFromISOString(json["date"].stringValue) {
            self.date = date
        }
    }
}

class Package: Object {
    dynamic var name = ""
    dynamic var trackingNumber = ""
    dynamic var courier: Courier!
    dynamic var createdAt = Date()
    dynamic var completed = false
    dynamic var archived = false
    let trackHistory = List<PackageTrackHistory>()
    var updating = false

    convenience init(name: String, courier: Courier, json: JSON) {
        self.init()
        self.name = name
        self.courier = courier

        self.completed = json["completed"].boolValue
        self.trackingNumber = json["tracking_number"].stringValue

        for trackHistoryJSON in json["track_history"].arrayValue {
            let trackStatus = PackageTrackHistory(json: trackHistoryJSON)
            self.trackHistory.append(trackStatus)
        }
    }

    convenience init(name: String, trackingNumber: String, courier: Courier) {
        self.init()
        self.name = name
        self.courier = courier
        self.trackingNumber = trackingNumber
    }

    func latestTrackHistory() -> PackageTrackHistory? {
        return self.trackHistory.first // because package track history is sorted descending
    }

    func ignoredProperties() -> [String] { return ["updating"] }

    override static func primaryKey() -> String? { return "trackingNumber" }
}
