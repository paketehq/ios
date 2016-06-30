//
//  Helpers.swift
//  Pakete
//
//  Created by Royce Albert Dy on 13/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import Foundation
import UIKit

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

extension UIView {
    public func constrainEqual(attribute: NSLayoutAttribute, to: AnyObject?, multiplier: CGFloat = 1, constant: CGFloat = 0) {
        constrainEqual(attribute, to: to, attribute, multiplier: multiplier, constant: constant)
    }

    public func constrainEqual(attribute: NSLayoutAttribute, to: AnyObject?, _ toAttribute: NSLayoutAttribute, multiplier: CGFloat = 1, constant: CGFloat = 0) {
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .Equal, toItem: to, attribute: toAttribute, multiplier: multiplier, constant: constant)
            ]
        )
    }

    public func constrainEdgestoMarginOf(view: UIView) {
        constrainEqual(.Top, to: view, .TopMargin)
        constrainEqual(.Leading, to: view, .LeadingMargin)
        constrainEqual(.Trailing, to: view, .TrailingMargin)
        constrainEqual(.Bottom, to: view, .BottomMargin)
    }

    public func constrainEdges(toView view: UIView) {
        constrainEqual(.Top, to: view, .Top)
        constrainEqual(.Leading, to: view, .Leading)
        constrainEqual(.Trailing, to: view, .Trailing)
        constrainEqual(.Bottom, to: view, .Bottom)
    }

    public func center(inView view: UIView) {
        constrainEqual(.CenterX, to: view)
        constrainEqual(.CenterY, to: view)
    }
}
