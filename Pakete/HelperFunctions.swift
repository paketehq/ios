//
//  Helpers.swift
//  Pakete
//
//  Created by Royce Albert Dy on 13/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import Foundation

private let dateHelper = PKDateHelper()
class PKDateHelper {
    let dateFormatter = NSDateFormatter()

    init () {
        self.dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        self.dateFormatter.timeZone = NSTimeZone.localTimeZone()
    }
}

func dateFromISOString(dateString: String) -> NSDate? {
    dateHelper.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateHelper.dateFormatter.dateFromString(dateString)
}

func stringFromDate(date: NSDate, dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle) -> String {
    dateHelper.dateFormatter.dateStyle = dateStyle
    dateHelper.dateFormatter.timeStyle = timeStyle
    return dateHelper.dateFormatter.stringFromDate(date)
}

func isNotEmptyString(string: String) -> Bool {
    return string.isEmpty == false
}

func delay(delay: Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
    dispatch_get_main_queue(), closure)
}
