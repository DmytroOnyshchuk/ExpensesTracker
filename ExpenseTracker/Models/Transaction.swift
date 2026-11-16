//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 04.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Transaction {
    #Index<Transaction>([\.date], [\.deletedAt, \.date])

    var id: UUID = UUID()
    var amount: Int = 0
    var date: Date = Date()
    var note: String?
    var category: TransactionCategory
    var deletedAt: Date?
    var account: BalanceAccount?

    init(amount: Int, category: TransactionCategory, date: Date = Date(), note: String? = nil, account: BalanceAccount? = nil) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
        self.account = account
    }

    var operationType: OperationType {
        category.operationType
    }

    var signedAmount: Int {
        amount * operationType.balanceSign
    }

    var displayAmount: String {
        operationType == .income ? "+" + amount.getAmount() : amount.getAmount()
    }
}

extension [Transaction] {
    var notDeleted: [Transaction] {
        filter { $0.deletedAt == nil }
    }

    var inTrash: [Transaction] {
        filter { $0.deletedAt != nil }
    }

    func of(_ operationType: OperationType) -> [Transaction] {
        filter { $0.operationType == operationType }
    }
}
