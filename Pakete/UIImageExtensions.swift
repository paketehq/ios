//
//  UIImageExtensions.swift
//  Pakete
//
//  Created by Royce Albert Dy on 31/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import UIKit

extension UIImage {
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = image, let cgImage = image.cgImage {
            self.init(cgImage: cgImage)
        } else {
            fatalError("Can't create image")
        }
    }
}
