//
//  StringExtensions.swift
//  Pakete
//
//  Created by Royce Albert Dy on 21/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import Foundation

extension String {
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.height
    }
}
