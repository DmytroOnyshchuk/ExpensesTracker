//
//  Balance.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 13.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

struct Balance: Codable {
    var amount: Int
    var date: Date

    init(amount: Int, date: Date = Date()) {
        self.amount = amount
        self.date = date
    }
}

struct BalanceLedger {
    let checkpoint: Balance?
    let transactions: [Transaction]

    init(checkpoint: Balance?, transactions: [Transaction]) {
        self.checkpoint = checkpoint
        self.transactions = transactions
    }

    init(storedData: Data?, transactions: [Transaction]) {
        self.init(checkpoint: Balance(jsonData: storedData), transactions: transactions)
    }

    var current: Int? {
        guard let counted = countedTransactions else { return nil }

        let change = counted.reduce(0) { $0 + $1.signedAmount }
        return (checkpoint?.amount ?? .zero) + change
    }

    private var countedTransactions: [Transaction]? {
        if let checkpoint {
            return transactions.filter { $0.date > checkpoint.date }
        }
        guard let firstIncomeDate = transactions.of(.income).map(\.date).min() else { return nil }

        return transactions.filter { $0.date >= firstIncomeDate }
    }
}
