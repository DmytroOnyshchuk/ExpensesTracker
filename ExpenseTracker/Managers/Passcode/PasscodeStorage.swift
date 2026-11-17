//
//  PasscodeStorage.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 17.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import CryptoKit
import Foundation
import Security

enum PasscodeStorage {
    enum State {
        case present
        case missing
        case unavailable
    }

    private static let saltLength = 16
    private static let account = "passcode"

    private static var service: String {
        (Bundle.main.bundleIdentifier ?? "ExpenseTracker") + ".passcode"
    }

    private static var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }

    static var state: State {
        var query = baseQuery
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        switch SecItemCopyMatching(query as CFDictionary, nil) {
        case errSecSuccess: return .present
        case errSecItemNotFound: return .missing
        default: return .unavailable
        }
    }

    @discardableResult
    static func save(_ passcode: String) -> Bool {
        var salt = Data(count: saltLength)
        let status = salt.withUnsafeMutableBytes { buffer in
            SecRandomCopyBytes(kSecRandomDefault, saltLength, buffer.baseAddress!)
        }
        guard status == errSecSuccess else { return false }

        delete()

        var query = baseQuery
        query[kSecValueData as String] = salt + hash(passcode, salt: salt)
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    static func verify(_ passcode: String) -> Bool {
        var query = baseQuery
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true

        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let stored = result as? Data,
              stored.count > saltLength
        else { return false }

        let salt = stored.prefix(saltLength)
        return Data(stored.dropFirst(saltLength)) == hash(passcode, salt: Data(salt))
    }

    static func delete() {
        SecItemDelete(baseQuery as CFDictionary)
    }

    private static func hash(_ passcode: String, salt: Data) -> Data {
        Data(SHA256.hash(data: salt + Data(passcode.utf8)))
    }
}
