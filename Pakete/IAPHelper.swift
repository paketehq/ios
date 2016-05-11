//
//  IAPHelper.swift
//  Pakete
//
//  Created by Royce Albert Dy on 11/05/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

private let RemoveAdsIAPId = "ph.pakete.iap.RemoveAds"
private let IAPRemoveAdsKey = "IAPRemoveAdsKey"

let IAPHelper = PKIAPHelper()

class PKIAPHelper {
    
    private var removeAdsProduct: SKProduct?
    
    func removeAdsProductInfo(completion: (product: SKProduct?) -> ()) {
        if let removeAdsProduct = self.removeAdsProduct {
            completion(product: removeAdsProduct)
            return
        }
        
        SwiftyStoreKit.retrieveProductsInfo([RemoveAdsIAPId]) { result in
            if let product = result.retrievedProducts.first {
                self.removeAdsProduct = product
                completion(product: product)
            } else {
                completion(product: nil)
            }
        }
    }
    
    func verifyReceipt() {
        // only verify if we won't be showing ads :D
        guard self.showAds() == false else { return }
        
        SwiftyStoreKit.verifyReceipt { (result) in
            if case .Success(_) = result {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: IAPRemoveAdsKey)
            } else {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: IAPRemoveAdsKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func purchaseRemoveAds(completion: (success: Bool) -> ()) {
        SwiftyStoreKit.purchaseProduct(RemoveAdsIAPId) { result in
            switch result {
            case .Success(_):
                completion(success: true)
            case .Error(_):
                completion(success: false)
            }
        }
    }
    
    func restorePurchases(completion: (results: SwiftyStoreKit.RestoreResults) -> ()) {
        SwiftyStoreKit.restorePurchases() { results in
            if results.restoreFailedProducts.count > 0 {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: IAPRemoveAdsKey)
            } else if results.restoredProductIds.count > 0 {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: IAPRemoveAdsKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
            completion(results: results)
        }
    }
    
    func showAds() -> Bool {
        return !NSUserDefaults.standardUserDefaults().boolForKey(IAPRemoveAdsKey)
    }
}