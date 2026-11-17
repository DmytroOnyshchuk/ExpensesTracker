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
    var uuid: UUID = UUID()
    var name: TransactionCategoryName
    var categoryIcon: CategoryIcon
    var isDirectory: Bool = false
    var parentUuid: UUID?
    var sortIndex: Int = 0
    var budget: Int = 0
    var deletedAt: Date?
    var operationTypeRaw: String = OperationType.outcome.rawValue

    @Relationship(deleteRule: .cascade, inverse: \Transaction.category)
    var transactions: [Transaction] = []

    @Relationship(deleteRule: .cascade, inverse: \AutoPayment.category)
    var autoPayments: [AutoPayment] = []

    var operationType: OperationType {
        get { OperationType(rawValue: operationTypeRaw) ?? .outcome }
        set { operationTypeRaw = newValue.rawValue }
    }
    
    init(
        name: TransactionCategoryName,
        categoryIcon: CategoryIcon,
        isDirectory: Bool = false,
        parentUuid: UUID? = nil,
        sortIndex: Int = .zero,
        operationType: OperationType = .outcome
    ) {
        self.uuid = UUID()
        self.name = name
        self.categoryIcon = categoryIcon
        self.isDirectory = isDirectory
        self.parentUuid = parentUuid
        self.sortIndex = sortIndex
        self.operationTypeRaw = operationType.rawValue
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
    var notDeleted: [TransactionCategory] {
        filter { $0.deletedAt == nil }
    }

    var inTrash: [TransactionCategory] {
        filter { $0.deletedAt != nil }
    }

    func of(_ operationType: OperationType) -> [TransactionCategory] {
        filter { $0.operationType == operationType }
    }

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
    case red, pink, blue, yellow, orange, purple, green, brown, white, cyan, indigo, gray, black, mint, teal
    
    static let primary: [IconColor] = [.red, .blue, .yellow, .purple]
    
    var color: Color {
        switch self {
        case .red: .red
        case .yellow: .yellow
        case .cyan: .cyan
        case .purple: .purple
        case .pink: .pink
        case .brown:.brown
        case .orange: .orange
        case .green: .green
        case .blue: .blue
        case .indigo: .indigo
        case .white: .white
        case .gray: .gray
        case .black: .black
        case .mint: .mint
        case .teal: .teal
        }
    }
}
