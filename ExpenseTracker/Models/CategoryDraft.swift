//
//  CategoryDraft.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 11.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

/// Черновик категории для формы создания и редактирования.
///
/// Форма меняет только черновик: в базу значения попадают по «Сохранить», а «Отмена» их отбрасывает.
struct CategoryDraft {
    var name: String
    var icon: CategoryIcon
    var parentUuid: UUID?

    var canSave: Bool { !name.isEmpty }

    /// Черновик новой категории.
    init() {
        self.name = L10n.editCategoryDefaultName
        self.icon = CategoryIcon(name: "cart", iconColor: .yellow)
    }

    /// Черновик с текущими значениями существующей категории.
    init(_ category: TransactionCategory) {
        self.name = category.name.localized
        self.icon = category.categoryIcon
        self.parentUuid = category.parentUuid
    }

    /// Убирает ссылку на папку, которой больше нет: такая категория показывается и сохраняется как «Без папки».
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
