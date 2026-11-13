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

    func remaining(after transactions: [Transaction]) -> Int {
        let spent = transactions
            .filter { $0.date > date }
            .reduce(0) { $0 + $1.amount }
        return amount - spent
    }
}
