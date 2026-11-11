//
//  ExpenseCategory.swift
//  ExpensesTracker
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
    var amount: Double
    var date: Date
    var note: String?
    var category: TransactionCategory?

    init(amount: Double, category: TransactionCategory, date: Date = Date(), note: String? = nil) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
    }
}

@Model
final class TransactionCategory {
    var id: UUID
    var name: String
    var icon: String
    private var colorName: String

    init(name: String, icon: String, colorName: String) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorName = colorName
    }

    var color: Color {
        switch colorName {
        case "red":
            .red
        case "pink":
            .pink
        case "blue":
            .blue
        case "yellow":
            .yellow
        case "orange":
            .orange
        case "purple":
            .purple
        case "green":
            .green
        default:
            .blue
        }
    }
}
