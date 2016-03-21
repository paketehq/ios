//
//  StringExtensions.swift
//  Pakete
//
//  Created by Royce Albert Dy on 21/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import Foundation

extension String {
    // http://stackoverflow.com/a/29284909/748184
    func toUppercaseAtSentenceBoundary() -> String {
        var result = ""
        self.uppercaseString.enumerateSubstringsInRange(self.characters.indices, options: .BySentences) { (sub, _, _, _)  in
            result += String(sub!.characters.prefix(1))
            result += String(sub!.characters.dropFirst(1)).lowercaseString
        }
        return result
    }
}