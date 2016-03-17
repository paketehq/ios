//
//  Courier.swift
//  Pakete
//
//  Created by Royce Albert Dy on 13/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class Courier: Object {
    dynamic var name = ""
    dynamic var code = ""
    
    convenience init(json: JSON) {
        self.init()
        self.name = json["name"].stringValue
        self.code = json["code"].stringValue
    }
    
    override static func primaryKey() -> String? { return "code" }
}