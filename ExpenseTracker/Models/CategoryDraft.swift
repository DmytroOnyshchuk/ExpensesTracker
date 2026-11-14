//
//  CategoryDraft.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 11.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

/// Category draft for the create and edit form.
///
/// The form changes only the draft: values reach the store on Save, and Cancel discards them.
struct CategoryDraft {
    var name: String
    var icon: CategoryIcon
    var parentUuid: UUID?

    var canSave: Bool { !name.isEmpty }

    /// Draft of a new category.
    init() {
        self.name = L10n.editCategoryDefaultName
        self.icon = CategoryIcon(name: "cart.fill", iconColor: .yellow)
    }

    /// Draft with the current values of an existing category.
    init(_ category: TransactionCategory) {
        self.name = category.name.localized
        self.icon = category.categoryIcon
        self.parentUuid = category.parentUuid
    }

    /// Drops the reference to a folder that no longer exists: such a category is shown and saved as having no parent.
    mutating func dropMissingParent(in categories: [TransactionCategory]) {
        guard !categories.contains(where: { $0.uuid == parentUuid }) else { return }
        parentUuid = nil
    }

    func apply(to category: TransactionCategory) {
        category.name = category.name.renamed(to: name)
        category.categoryIcon = icon
        category.parentUuid = parentUuid
    }

    func makeCategory() -> TransactionCategory {
        TransactionCategory(name: .custom(name), categoryIcon: icon, parentUuid: parentUuid)
    }
}
