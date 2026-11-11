//
//  TransactionCategory.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 04.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class TransactionCategory {
    var uuid: UUID
    var name: String
    var categoryIcon: CategoryIcon
    var isDirectory: Bool = false
    var parentUuid: UUID?

    init(name: String, categoryIcon: CategoryIcon, isDirectory: Bool = false, parentUuid: UUID? = nil) {
        self.uuid = UUID()
        self.name = name
        self.categoryIcon = categoryIcon
        self.isDirectory = isDirectory
        self.parentUuid = parentUuid
    }

    var isMainCategory: Bool {
        parentUuid == nil
    }

    func parent(from allCategories: [TransactionCategory]) -> TransactionCategory? {
        allCategories.first { $0.uuid == parentUuid }
    }

    func allSubcategories(from allCategories: [TransactionCategory]) -> [TransactionCategory] {
        allCategories.filter { !$0.isDirectory }.filter { $0.parentUuid == uuid }
    }
}

enum IconColor: String, Codable, CaseIterable {
    case red, pink, blue, yellow, orange, purple, green, brown, white, cyan, indigo, gray, black

    var color: Color {
        switch self {
        case .red:
            .red
        case .pink:
            .pink
        case .blue:
            .blue
        case .yellow:
            .yellow
        case .orange:
            .orange
        case .purple:
            .purple
        case .green:
            .green
        case .brown:
            .brown
        case .white:
            .white
        case .cyan:
            .cyan
        case .indigo:
            .indigo
        case .gray:
            .gray
        case .black:
            .black
        }
    }
}
