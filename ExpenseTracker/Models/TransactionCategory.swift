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
final class TransactionCategory {
    var id: UUID
    var name: String
    var categoryIcon: CategoryIcon
    
    var parent: TransactionCategory?
    var children: [TransactionCategory] = []
    
    init(name: String, categoryIcon: CategoryIcon, parent: TransactionCategory? = nil) {
        self.id = UUID()
        self.name = name
        self.categoryIcon = categoryIcon
        self.parent = parent
    }
    
    var isMainCategory: Bool {
        return parent == nil
    }
    
    var allSubcategories: [TransactionCategory] {
        var result: [TransactionCategory] = []
        for subcategory in children {
            result.append(subcategory)
            result.append(contentsOf: subcategory.allSubcategories)
        }
        return result
    }
}

enum IconColor: String, Codable, CaseIterable {
    case red, pink, blue, yellow, orange, purple, green
    
    var color: Color {
        switch self {
            case .red:
                return .red
            case .pink:
                return .pink
            case .blue:
                return .blue
            case .yellow:
                return .yellow
            case .orange:
                return .orange
            case .purple:
                return .purple
            case .green:
                return .green
        }
    }
}
