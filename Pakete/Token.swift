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

    fileprivate var randomIV: Data!
    fileprivate var key: Data!

    init() {
        let keys = PaketeKeys()
        if keys.paketeAPIKey().characters.count == 16 {
            self.key = keys.paketeAPIKey().data(using: String.Encoding.utf8)
        } else {
            self.key = "1234567890123456".data(using: String.Encoding.utf8)
        }
        self.randomIV = generateRandomIV()
    }

    func tokenString() -> String {
        return self.base64GeneratedEncryptedString()
    }

}

private extension Token {
    func generateRandomIV() -> Data {
        var key = Data(count: self.key.count)
        _ = key.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, self.key.count, bytes)
        }
        return key
    }

    func base64GeneratedEncryptedString() -> String {
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else { return "" }
        let timeInterval = Date().timeIntervalSince1970
        let nonce = deviceId + ":\(timeInterval)"
        if let nonceData = nonce.data(using: String.Encoding.utf8) {
            do {
                let encrypted = try nonceData.encrypt(cipher: AES(key: self.key.bytes, iv: self.randomIV.bytes))
                let encryptedBase64 = encrypted.base64EncodedString()
                let base64IVString = self.randomIV.base64EncodedString()
                return "\(base64IVString):\(encryptedBase64)"
            } catch {
                fatalError("can't generate encrypted string")
            }
        } else {
            fatalError("nonce data is nil")
        }
    }
}
