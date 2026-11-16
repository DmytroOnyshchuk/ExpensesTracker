//
//  TransactionDraft.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 12.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

struct TransactionDraft {
    var category: TransactionCategory
    var amount: Int
    var date: Date
    var note: String

    var canSave: Bool { amount != .zero }

    init(_ transaction: Transaction) {
        self.category = transaction.category
        self.amount = transaction.amount
        self.date = transaction.date
        self.note = transaction.note ?? ""
    }

    func apply(to transaction: Transaction) {
        transaction.category = category
        transaction.amount = amount
        transaction.date = date
        transaction.note = note.isBlank ? nil : note
    }
}
