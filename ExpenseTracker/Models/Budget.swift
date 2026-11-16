//
//  Budget.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 16.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

struct Budget: Codable {
    var monthly: Int?

    mutating func setMonthly(_ amount: Int) {
        monthly = amount > .zero ? amount : nil
    }
}

struct BudgetProgress {
    let spent: Int
    let limit: Int?

    var remaining: Int? {
        limit.map { $0 - spent }
    }

    var isExceeded: Bool {
        (remaining ?? .zero) < .zero
    }

    var fraction: Double {
        guard let limit, limit > .zero else { return .zero }
        return min(max(spent.asDouble / limit.asDouble, .zero), 1)
    }

    var statusTitle: String? {
        guard let remaining else { return nil }
        return remaining < .zero ? L10n.budgetExceeded((-remaining).getAmount()) : L10n.budgetLeft(remaining.getAmount())
    }
}

struct CategoryBudget: Identifiable {
    let category: TransactionCategory
    let progress: BudgetProgress

    var id: UUID { category.uuid }

    static func rows(
        from transactions: [Transaction],
        categories: [TransactionCategory]
    ) -> [CategoryBudget] {
        let directories = Dictionary(
            categories.filter(\.isDirectory).map { ($0.uuid, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let spent: [UUID: Int] = transactions.reduce(into: [:]) { result, transaction in
            let owner = transaction.category.parentUuid.flatMap { directories[$0] } ?? transaction.category
            result[owner.uuid, default: .zero] += transaction.amount
        }

        return categories.topLevel.inDisplayOrder.map { category in
            CategoryBudget(
                category: category,
                progress: BudgetProgress(spent: spent[category.uuid] ?? .zero, limit: category.budget > .zero ? category.budget : nil)
            )
        }
    }
}
