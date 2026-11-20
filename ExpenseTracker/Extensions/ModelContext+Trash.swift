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
    func add(_ transaction: Transaction) {
        insert(transaction)
        transaction.addToBalance()
    }

    func recalculateBalances() {
        let accounts = (try? fetch(FetchDescriptor<Account>())) ?? []
        let changes = ((try? fetch(FetchDescriptor<Transaction>(predicate: Transaction.notDeleted))) ?? []).balanceChanges
        for account in accounts {
            account.balance = account.amount + (changes[account.uuid] ?? .zero)
        }
    }

    func periodStarts(of period: StatisticsPeriod, matching predicate: (Date) -> Predicate<Transaction>) -> [Date] {
        var starts: [Date] = []
        var bound = Date.distantFuture
        while true {
            var descriptor = FetchDescriptor<Transaction>(predicate: predicate(bound), sortBy: [SortDescriptor(\.date, order: .reverse)])
            descriptor.fetchLimit = 1
            guard let date = (try? fetch(descriptor))?.first?.date else { return starts }
            let start = min(period.interval(containing: date).start, date)
            starts.append(start)
            bound = start
        }
    }

    func moveToTrash(_ transaction: Transaction) {
        transaction.removeFromBalance()
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
            transaction.removeFromBalance()
            transaction.deletedAt = date
        }
        account.deletedAt = date
        try? save()
    }

    func restore(_ account: Account) {
        let date = account.deletedAt
        for transaction in transactions(of: account) where transaction.deletedAt == date && transaction.category.deletedAt == nil {
            transaction.deletedAt = nil
            transaction.addToBalance()
        }
        account.deletedAt = nil
        try? save()
    }

    func moveToTrash(_ category: TransactionCategory) {
        let date = Date()
        for transaction in transactions(of: category) where transaction.deletedAt == nil {
            transaction.removeFromBalance()
            transaction.deletedAt = date
        }
        category.deletedAt = date
        try? save()
    }

    func restore(_ transaction: Transaction) {
        transaction.removeFromBalance()
        transaction.deletedAt = nil
        transaction.category.deletedAt = nil
        transaction.account?.deletedAt = nil
        transaction.addToBalance()
        try? save()
    }

    func restore(_ category: TransactionCategory) {
        let date = category.deletedAt
        for transaction in transactions(of: category) where transaction.deletedAt == date && transaction.account?.deletedAt == nil {
            transaction.deletedAt = nil
            transaction.addToBalance()
        }
        category.deletedAt = nil
        try? save()
    }

    func deletePermanently(_ transaction: Transaction) {
        transaction.removeFromBalance()
        delete(transaction)
        try? save()
    }

    func deletePermanently(_ category: TransactionCategory) {
        for transaction in transactions(of: category) {
            transaction.removeFromBalance()
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
            transaction.removeFromBalance()
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
