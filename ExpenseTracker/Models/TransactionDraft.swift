//
//  TransactionDraft.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 12.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

struct TransactionDraft: Equatable {
    var category: TransactionCategory
    var amount: Int
    var date: Date
    var note: String
    var account: Account?

    var canSave: Bool { amount != .zero }

    init(_ transaction: Transaction) {
        self.category = transaction.category
        self.amount = transaction.amount
        self.date = transaction.date
        self.note = transaction.note ?? ""
        self.account = transaction.account
    }

    func apply(to transaction: Transaction) {
        if let category = category.live {
            transaction.category = category
        }
        transaction.amount = amount
        transaction.date = date
        transaction.note = note.isBlank ? nil : note
        transaction.account = account?.live
    }

    static func == (lhs: TransactionDraft, rhs: TransactionDraft) -> Bool {
        lhs.category.uuid == rhs.category.uuid && lhs.amount == rhs.amount && lhs.date == rhs.date && lhs.note == rhs.note && lhs.account?.uuid == rhs.account?.uuid
    }
}
