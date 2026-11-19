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

    func moveToTrash(_ autoPayment: AutoPayment) {
        autoPayment.deletedAt = Date()
        try? save()
    }

    func restore(_ autoPayment: AutoPayment) {
        let now = Date()
        if autoPayment.nextDate < now {
            autoPayment.skipPayments(before: now)
        }
        autoPayment.deletedAt = nil
        try? save()
    }

    func deletePermanently(_ autoPayment: AutoPayment) {
        delete(autoPayment)
        try? save()
    }

    func moveToTrash(_ account: Account) {
        let date = Date()
        for transaction in transactions(of: account) where transaction.deletedAt == nil {
            transaction.deletedAt = date
        }
        account.deletedAt = date
        try? save()
    }

    func restore(_ account: Account) {
        let date = account.deletedAt
        for transaction in transactions(of: account) where transaction.deletedAt == date && transaction.category.deletedAt == nil {
            transaction.deletedAt = nil
        }
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
        transaction.account?.deletedAt = nil
        try? save()
    }

    func restore(_ category: TransactionCategory) {
        let date = category.deletedAt
        for transaction in transactions(of: category) where transaction.deletedAt == date && transaction.account?.deletedAt == nil {
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

    func deletePermanently(_ account: Account) {
        for transaction in transactions(of: account) {
            delete(transaction)
        }
        delete(account)
        try? save()
    }

    func emptyTrash() {
        let autoPayments = (try? fetch(FetchDescriptor<AutoPayment>(predicate: AutoPayment.inTrash))) ?? []
        for autoPayment in autoPayments {
            delete(autoPayment)
        }
        let transactions = (try? fetch(FetchDescriptor<Transaction>(predicate: Transaction.inTrashWithOwners))) ?? []
        for transaction in transactions {
            delete(transaction)
        }
        let categories = (try? fetch(FetchDescriptor<TransactionCategory>(predicate: TransactionCategory.inTrash))) ?? []
        for category in categories {
            delete(category)
        }
        let accounts = (try? fetch(FetchDescriptor<Account>(predicate: Account.inTrash))) ?? []
        for account in accounts {
            delete(account)
        }
        try? save()
    }

    private func transactions(of account: Account) -> [Transaction] {
        let accountUuid = account.uuid
        let descriptor = FetchDescriptor<Transaction>(predicate: #Predicate { $0.account?.uuid == accountUuid })
        return (try? fetch(descriptor)) ?? []
    }

    private func transactions(of category: TransactionCategory) -> [Transaction] {
        let categoryUuid = category.uuid
        let descriptor = FetchDescriptor<Transaction>(predicate: #Predicate { $0.category.uuid == categoryUuid })
        return (try? fetch(descriptor)) ?? []
    }
}
