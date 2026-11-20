//
//  Account.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 13.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import SwiftData

enum AccountType: String, Codable {
    case wallet
    case bank
}

@Model
final class Account {
    var uuid: UUID = UUID()
    var name: String = String()
    var amount: Int = 0
    var balance: Int = 0
    var checkpointDate: Date = Date()
    var sortIndex: Int = 0
    var deletedAt: Date?
    var typeRaw: String = AccountType.wallet.rawValue
    var isDisabled: Bool = false
    
    var type: AccountType {
        get { AccountType(rawValue: typeRaw) ?? .wallet }
        set { typeRaw = newValue.rawValue }
    }
    
    @Relationship(deleteRule: .nullify, inverse: \AutoPayment.account)
    var autoPayments: [AutoPayment] = []

    init(name: String, amount: Int = .zero, checkpointDate: Date = Date(), sortIndex: Int = .zero) {
        self.uuid = UUID()
        self.name = name
        self.amount = amount
        self.balance = amount
        self.checkpointDate = checkpointDate
        self.sortIndex = sortIndex
    }

    func setAmount(_ newAmount: Int) {
        amount = newAmount
        balance = newAmount
        checkpointDate = Date()
    }
}

extension Account {
    static let notDeleted = #Predicate<Account> { $0.deletedAt == nil }
    static let available = #Predicate<Account> { $0.deletedAt == nil && !$0.isDisabled }
    static let inTrash = #Predicate<Account> { $0.deletedAt != nil }
}

extension [Account] {
    var enabled: [Account] {
        filter { !$0.isDisabled }
    }

    var inDisplayOrder: [Account] {
        sorted { $0.sortIndex < $1.sortIndex }
    }

    var nextSortIndex: Int {
        (map(\.sortIndex).max() ?? -1) + 1
    }

    var total: Int {
        reduce(0) { $0 + $1.balance }
    }
}

extension [Transaction] {
    var balanceChanges: [UUID: Int] {
        reduce(into: [:]) { result, transaction in
            guard let account = transaction.account, transaction.date > account.checkpointDate else { return }
            result[account.uuid, default: .zero] += transaction.signedAmount
        }
    }
}
