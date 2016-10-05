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
    let dateFormatter = DateFormatter()

    init () {
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormatter.timeZone = TimeZone.autoupdatingCurrent
    }
}

func dateFromISOString(_ dateString: String) -> Date? {
    dateHelper.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateHelper.dateFormatter.date(from: dateString)
}

func stringFromDate(_ date: Date, dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
    dateHelper.dateFormatter.dateStyle = dateStyle
    dateHelper.dateFormatter.timeStyle = timeStyle
    return dateHelper.dateFormatter.string(from: date)
}

func isNotEmptyString(_ string: String) -> Bool {
    return string.isEmpty == false
}

func delay(_ delay: Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

extension UIView {
    public func constrainEqual(_ attribute: NSLayoutAttribute, to: AnyObject?, multiplier: CGFloat = 1, constant: CGFloat = 0) {
        constrainEqual(attribute, to: to, attribute, multiplier: multiplier, constant: constant)
    }

    public func constrainEqual(_ attribute: NSLayoutAttribute, to: AnyObject?, _ toAttribute: NSLayoutAttribute, multiplier: CGFloat = 1, constant: CGFloat = 0) {
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: to, attribute: toAttribute, multiplier: multiplier, constant: constant)
            ]
        )
    }

    public func constrainEdgestoMarginOf(_ view: UIView) {
        constrainEqual(.top, to: view, .topMargin)
        constrainEqual(.leading, to: view, .leadingMargin)
        constrainEqual(.trailing, to: view, .trailingMargin)
        constrainEqual(.bottom, to: view, .bottomMargin)
    }

    public func constrainEdges(toView view: UIView) {
        constrainEqual(.top, to: view, .top)
        constrainEqual(.leading, to: view, .leading)
        constrainEqual(.trailing, to: view, .trailing)
        constrainEqual(.bottom, to: view, .bottom)
    }

    public func center(inView view: UIView) {
        constrainEqual(.centerX, to: view)
        constrainEqual(.centerY, to: view)
    }
}
