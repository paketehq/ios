//
//  Token.swift
//  Pakete
//
//  Created by Royce Albert Dy on 06/04/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import Foundation
import UIKit
import Security
import CryptoSwift
import Keys

struct Token {

    private var randomIV: NSData!
    private var key: NSData!

    init() {
        let keys = PaketeKeys()
        if keys.paketeAPIKey().characters.count == 16 {
            self.key = keys.paketeAPIKey().dataUsingEncoding(NSUTF8StringEncoding)
        } else {
            self.key = "1234567890123456".dataUsingEncoding(NSUTF8StringEncoding)
        }
        self.randomIV = generateRandomIV()
    }

    func tokenString() -> String {
        return self.base64GeneratedEncryptedString()
    }

}

private extension Token {
    func generateRandomIV() -> NSData {
        if let data = NSMutableData(length: self.key.length) {
            let result = SecRandomCopyBytes(kSecRandomDefault, self.key.length, UnsafeMutablePointer<UInt8>(data.mutableBytes))
            guard result == errSecSuccess else {
                fatalError("SECURITY FAILURE: Could not generate secure random numbers: \(result).")
            }

            return data
        } else {
            fatalError("key is empty")
        }
    }

    func base64GeneratedEncryptedString() -> String {
        guard let deviceId = UIDevice.currentDevice().identifierForVendor?.UUIDString else { return "" }
        let timeInterval = NSDate().timeIntervalSince1970
        let nonce = deviceId + ":\(timeInterval)"
        if let nonceData = nonce.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let encrypted = try nonceData.encrypt(AES(key: self.key.arrayOfBytes(), iv: self.randomIV.arrayOfBytes()))
                let encryptedBase64 = encrypted.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))

                let base64IVString = self.randomIV.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                return "\(base64IVString):\(encryptedBase64)"
            } catch {
                fatalError("can't generate encrypted string")
            }
        } else {
            fatalError("nonce data is nil")
        }
    }
}
