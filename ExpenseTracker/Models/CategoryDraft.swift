//
//  CategoryDraft.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 11.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

struct CategoryDraft {
    var name: String
    var icon: CategoryIcon
    var parentUuid: UUID?
    var operationType: OperationType = .outcome

    var canSave: Bool { !name.isEmpty }

    init(operationType: OperationType = .outcome) {
        self.operationType = operationType
        self.name = String()
        self.icon = CategoryIcon(name: "cart.fill", iconColor: .yellow)
    }

    init(_ category: TransactionCategory) {
        self.name = category.name.localized
        self.icon = category.categoryIcon
        self.parentUuid = category.parentUuid
        self.operationType = category.operationType
    }

    mutating func dropMissingParent(in categories: [TransactionCategory]) {
        guard !categories.contains(where: { $0.uuid == parentUuid && $0.operationType == operationType }) else { return }
        parentUuid = nil
    }

    func apply(to category: TransactionCategory) {
        category.name = category.name.renamed(to: name)
        category.categoryIcon = icon
        category.parentUuid = parentUuid
    }

    func makeCategory() -> TransactionCategory {
        TransactionCategory(name: .custom(name), categoryIcon: icon, parentUuid: parentUuid, operationType: operationType)
    }
}
