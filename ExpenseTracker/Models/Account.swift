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
    var checkpointDate: Date = Date()
    var sortIndex: Int = 0
    var deletedAt: Date?
    var typeRaw: String = AccountType.wallet.rawValue
    
    var type: AccountType {
        get { AccountType(rawValue: typeRaw) ?? .wallet }
        set { typeRaw = newValue.rawValue }
    }
    
    @Relationship(deleteRule: .nullify, inverse: \Transaction.account)
    var transactions: [Transaction] = []

    init(name: String, amount: Int = .zero, checkpointDate: Date = Date(), sortIndex: Int = .zero) {
        self.uuid = UUID()
        self.name = name
        self.amount = amount
        self.checkpointDate = checkpointDate
        self.sortIndex = sortIndex
    }

    func current(in transactions: [Transaction]) -> Int {
        let change = transactions
            .filter { $0.account?.uuid == uuid && $0.date > checkpointDate }
            .reduce(0) { $0 + $1.signedAmount }
        return amount + change
    }

    func setAmount(_ newAmount: Int) {
        amount = newAmount
        checkpointDate = Date()
    }
}

extension [Account] {
    var notDeleted: [Account] {
        filter { $0.deletedAt == nil }
    }

    var inDisplayOrder: [Account] {
        sorted { $0.sortIndex < $1.sortIndex }
    }

    var nextSortIndex: Int {
        (map(\.sortIndex).max() ?? -1) + 1
    }

    func total(in transactions: [Transaction]) -> Int {
        reduce(0) { $0 + $1.current(in: transactions) }
    }
}
