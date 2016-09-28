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

private let IAPRemoveAdsKey = "IAPRemoveAdsKey"

// Temporary to remove soon
let IAPDidPurchaseRemoveAdsNotification = "IAPDidPurchaseRemoveAdsNotification"

let IAPHelper = PKIAPHelper()

class PKIAPHelper {

    func verifyReceipt() {
        // only verify if we won't be showing ads :D
        guard self.showAds() == false else { return }

        SwiftyStoreKit.verifyReceipt { (result) in
            if case .success(_) = result {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPDidPurchaseRemoveAdsNotification), object: nil)
                UserDefaults.standard.set(true, forKey: IAPRemoveAdsKey)
            } else {
                UserDefaults.standard.set(false, forKey: IAPRemoveAdsKey)
            }
            UserDefaults.standard.synchronize()
        }
    }

    func purchaseRemoveAds(_ completion: @escaping (_ success: Bool) -> ()) {
        SwiftyStoreKit.purchaseProduct(Constants.IAP.RemoveAdsIAPId) { result in
            switch result {
            case .success(_):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPDidPurchaseRemoveAdsNotification), object: nil)
                completion(true)
            case .error(_):
                completion(false)
            }
        }
    }

    func restorePurchases(_ completion: @escaping (_ results: SwiftyStoreKit.RestoreResults) -> ()) {
        SwiftyStoreKit.restorePurchases() { results in
            if results.restoreFailedProducts.isEmpty == false {
                UserDefaults.standard.set(false, forKey: IAPRemoveAdsKey)
            } else if results.restoredProductIds.isEmpty == false {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPDidPurchaseRemoveAdsNotification), object: nil)
                UserDefaults.standard.set(true, forKey: IAPRemoveAdsKey)
            }
            UserDefaults.standard.synchronize()
            completion(results)
        }
    }

    func showAds() -> Bool {
        return !UserDefaults.standard.bool(forKey: IAPRemoveAdsKey)
    }
}
