//
//  Observable+Operators.swift
//  Pakete
//
//  Created by Royce Albert Dy on 31/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import RxSwift
import RxCocoa

extension CollectionType where Generator.Element: DriverConvertibleType, Generator.Element.E: BooleanType {

    func combineLatestAnd() -> Driver<Bool> {
        return combineLatest { bools -> Bool in
            bools.reduce(true, combine: { (memo, element) in
                return memo && element.boolValue
            })
        }
    }

    func combineLatestOr() -> Driver<Bool> {
        return combineLatest { bools in
            bools.reduce(false, combine: { (memo, element) in
                return memo || element.boolValue
            })
        }
    }
}
