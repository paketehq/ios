//
//  UILabelExtensions.swift
//  Pakete
//
//  Created by Royce Albert Dy on 11/04/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import Foundation

extension UILabel {
    var adjustFontToRealIPhoneSize: Bool {
        set {
            if newValue {
                let currentFont = self.font
                var sizeScale: CGFloat = 1.0

                if DeviceType.iPhone6 {
                    sizeScale = 1.1
                } else if DeviceType.iPhone6Plus {
                    sizeScale = 1.2
                }

                self.font = currentFont?.withSize((currentFont?.pointSize)! * sizeScale)
            }
        }

        get {
            return false
        }
    }
}

// TO DO: Transfer somewhere
struct ScreenSize {
    static let ScreenWidth = UIScreen.main.bounds.size.width
    static let ScreenHeight = UIScreen.main.bounds.size.height
    static let ScreenMaxLength = max(ScreenSize.ScreenWidth, ScreenSize.ScreenHeight)
    static let ScreenMinLength = min(ScreenSize.ScreenHeight, ScreenSize.ScreenHeight)
}

struct DeviceType {
    static let iPhone4 =  UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.ScreenMaxLength < 568.0
    static let iPhone5 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.ScreenMaxLength == 568.0
    static let iPhone6 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.ScreenMaxLength == 667.0
    static let iPhone6Plus = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.ScreenMaxLength == 736.0
}
