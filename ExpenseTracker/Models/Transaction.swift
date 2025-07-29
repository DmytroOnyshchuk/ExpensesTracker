//
//  ExpenseCategory.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 04.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Transaction {
    var id: UUID
    var amount: Int
    var date: Date
    var note: String?
    var category: TransactionCategory
    
    init(amount: Int, category: TransactionCategory, date: Date = Date(), note: String? = nil) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
    }
}
