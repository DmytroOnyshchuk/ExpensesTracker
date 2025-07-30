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
    var isDirectory: Bool = false
    var parent: TransactionCategory?
    
    init(name: String, categoryIcon: CategoryIcon, isDirectory: Bool = false, parent: TransactionCategory? = nil) {
        self.id = UUID()
        self.name = name
        self.categoryIcon = categoryIcon
        self.isDirectory = isDirectory
        self.parent = parent
    }
    
    var isMainCategory: Bool {
        return parent == nil
    }
    
    func allSubcategories(from allCategories: [TransactionCategory]) -> [TransactionCategory] {
        var result: [TransactionCategory] = []
        let directSubcategories = allCategories.filter { $0.parent?.id == self.id }
        
        for subcategory in directSubcategories {
            result.append(subcategory)
            result.append(contentsOf: subcategory.allSubcategories(from: allCategories))
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
