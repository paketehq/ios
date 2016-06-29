//
//  RLMExtensions.swift
//  Pakete
//
//  Created by Royce Albert Dy on 13/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

extension Results {
    func toArray() -> [Results.Generator.Element] {
        return map { $0 }
    }

    func toObservableArray() -> [Variable<Results.Generator.Element>] {
        return map { Variable($0) }
    }
}

extension List {
    func toArray() -> [List.Generator.Element] {
        return map { $0 }
    }
}
