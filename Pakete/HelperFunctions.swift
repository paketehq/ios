//
//  Helpers.swift
//  Pakete
//
//  Created by Royce Albert Dy on 13/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import Foundation

let DateHelper = PKDateHelper()
class PKDateHelper {
    private let dateFormatter = NSDateFormatter()
    
    init () {
        self.dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        self.dateFormatter.timeZone = NSTimeZone(name: "UTC")
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    }
    
    func dateFromISOString(dateString: String) -> NSDate? {
        return self.dateFormatter.dateFromString(dateString)
    }
}

func isNotEmptyString(string: String) -> Bool {
    return string.isEmpty == false
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
    dispatch_get_main_queue(), closure)
}