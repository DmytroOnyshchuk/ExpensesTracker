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
    var name: TransactionCategoryName
    var categoryIcon: CategoryIcon
    var isDirectory: Bool = false
    var parentUuid: UUID?
    var sortIndex: Int = 0

    init(name: TransactionCategoryName, categoryIcon: CategoryIcon, isDirectory: Bool = false, parentUuid: UUID? = nil, sortIndex: Int = .zero) {
        self.uuid = UUID()
        self.name = name
        self.categoryIcon = categoryIcon
        self.isDirectory = isDirectory
        self.parentUuid = parentUuid
        self.sortIndex = sortIndex
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

extension [TransactionCategory] {
    /// The order in which categories are shown: folders first, then by user-defined sort index, then by name.
    var inDisplayOrder: [TransactionCategory] {
        sorted {
            if $0.isDirectory != $1.isDirectory {
                return $0.isDirectory
            }
            if $0.sortIndex != $1.sortIndex {
                return $0.sortIndex < $1.sortIndex
            }
            return $0.name.localized < $1.name.localized
        }
    }

    /// Top-level categories, i.e. those that are not inside a folder.
    var topLevel: [TransactionCategory] {
        filter { !($0.parent(from: self)?.isDirectory ?? false) }
    }

    var nextSortIndex: Int {
        (map(\.sortIndex).max() ?? -1) + 1
    }

    func reorder(fromOffsets source: IndexSet, toOffset destination: Int, among allCategories: [TransactionCategory]) {
        let ordered = allCategories.inDisplayOrder
        if Set(ordered.map(\.sortIndex)).count != ordered.count {
            for (index, category) in ordered.enumerated() {
                category.sortIndex = index
            }
        }

        let slots = map(\.sortIndex).sorted()
        var reordered = self
        reordered.move(fromOffsets: source, toOffset: destination)
        for (category, slot) in zip(reordered, slots) {
            category.sortIndex = slot
        }
    }
}

enum IconColor: String, Codable, CaseIterable {
    case red, pink, blue, yellow, orange, purple, green, brown, white, cyan, indigo, gray, black

    var color: Color {
        ThemeManager.shared.theme.color(for: self)
    }
}
