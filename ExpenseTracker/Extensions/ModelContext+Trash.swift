//
//  ModelContext+Trash.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 15.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import SwiftData

extension ModelContext {
    func moveToTrash(_ transaction: Transaction) {
        transaction.deletedAt = Date()
        try? save()
    }

    func remove(_ account: Account) {
        account.deletedAt = Date()
        try? save()
    }

    func restore(_ account: Account) {
        account.deletedAt = nil
        try? save()
    }

    func moveToTrash(_ category: TransactionCategory) {
        let date = Date()
        for transaction in transactions(of: category) where transaction.deletedAt == nil {
            transaction.deletedAt = date
        }
        category.deletedAt = date
        try? save()
    }

    func restore(_ transaction: Transaction) {
        transaction.deletedAt = nil
        transaction.category.deletedAt = nil
        try? save()
    }

    func restore(_ category: TransactionCategory) {
        let date = category.deletedAt
        for transaction in transactions(of: category) where transaction.deletedAt == date {
            transaction.deletedAt = nil
        }
        category.deletedAt = nil
        try? save()
    }

    func deletePermanently(_ transaction: Transaction) {
        delete(transaction)
        try? save()
    }

    func deletePermanently(_ category: TransactionCategory) {
        for transaction in transactions(of: category) {
            delete(transaction)
        }
        delete(category)
        try? save()
    }

    func emptyTrash() {
        let transactions = (try? fetch(FetchDescriptor<Transaction>())) ?? []
        for transaction in transactions where transaction.deletedAt != nil || transaction.category.deletedAt != nil {
            delete(transaction)
        }
        let categories = (try? fetch(FetchDescriptor<TransactionCategory>())) ?? []
        for category in categories.inTrash {
            delete(category)
        }
        try? save()
    }

    private func transactions(of category: TransactionCategory) -> [Transaction] {
        let categoryUuid = category.uuid
        let descriptor = FetchDescriptor<Transaction>(predicate: #Predicate { $0.category.uuid == categoryUuid })
        return (try? fetch(descriptor)) ?? []
    }
}
