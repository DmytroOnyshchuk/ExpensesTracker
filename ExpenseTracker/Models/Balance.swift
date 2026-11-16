//
//  Balance.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 13.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class BalanceAccount {
    var uuid: UUID
    var name: String
    var amount: Int
    var checkpointDate: Date
    var sortIndex: Int
    var deletedAt: Date?

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

extension [BalanceAccount] {
    var notDeleted: [BalanceAccount] {
        filter { $0.deletedAt == nil }
    }

    var inDisplayOrder: [BalanceAccount] {
        sorted { $0.sortIndex < $1.sortIndex }
    }

    var nextSortIndex: Int {
        (map(\.sortIndex).max() ?? -1) + 1
    }

    func total(in transactions: [Transaction]) -> Int {
        reduce(0) { $0 + $1.current(in: transactions) }
    }
}
