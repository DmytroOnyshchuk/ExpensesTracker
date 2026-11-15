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
    var id: UUID
    var amount: Int
    var date: Date
    var comment: String?
    var category: TransactionCategory
    var deletedAt: Date?

    init(amount: Int, category: TransactionCategory, date: Date = Date(), note: String? = nil) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.date = date
        self.comment = note
    }
}

extension [Transaction] {
    var notDeleted: [Transaction] {
        filter { $0.deletedAt == nil }
    }

    var inTrash: [Transaction] {
        filter { $0.deletedAt != nil }
    }
}
