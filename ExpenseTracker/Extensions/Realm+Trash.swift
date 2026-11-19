//
//  Realm+Trash.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 15.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm {
    func moveToTrash(_ transaction: Transaction) {
        guard let transaction = transaction.live else { return }
        update { transaction.deletedAt = Date() }
    }

    func moveToTrash(_ autoPayment: AutoPayment) {
        guard let autoPayment = autoPayment.live else { return }
        update { autoPayment.deletedAt = Date() }
    }

    func restore(_ autoPayment: AutoPayment) {
        guard let autoPayment = autoPayment.live else { return }
        update {
            let now = Date()
            if autoPayment.nextDate < now {
                autoPayment.skipPayments(before: now)
            }
            autoPayment.deletedAt = nil
        }
    }

    func deletePermanently(_ autoPayment: AutoPayment) {
        guard let autoPayment = autoPayment.live else { return }
        update { delete(autoPayment) }
    }

    func moveToTrash(_ account: Account) {
        guard let account = account.live else { return }
        update {
            let date = Date()
            for transaction in transactions(of: account) where transaction.deletedAt == nil {
                transaction.deletedAt = date
            }
            account.deletedAt = date
        }
    }

    func restore(_ account: Account) {
        guard let account = account.live else { return }
        update {
            let date = account.deletedAt
            for transaction in transactions(of: account) where transaction.deletedAt == date && transaction.category.deletedAt == nil {
                transaction.deletedAt = nil
            }
            account.deletedAt = nil
        }
    }

    func moveToTrash(_ category: TransactionCategory) {
        guard let category = category.live else { return }
        update {
            let date = Date()
            for transaction in transactions(of: category) where transaction.deletedAt == nil {
                transaction.deletedAt = date
            }
            category.deletedAt = date
        }
    }

    func restore(_ transaction: Transaction) {
        guard let transaction = transaction.live else { return }
        update {
            transaction.deletedAt = nil
            transaction.categoryLink?.deletedAt = nil
            transaction.account?.deletedAt = nil
        }
    }

    func restore(_ category: TransactionCategory) {
        guard let category = category.live else { return }
        update {
            let date = category.deletedAt
            for transaction in transactions(of: category) where transaction.deletedAt == date && transaction.account?.deletedAt == nil {
                transaction.deletedAt = nil
            }
            category.deletedAt = nil
        }
    }

    func deletePermanently(_ transaction: Transaction) {
        guard let transaction = transaction.live else { return }
        update { delete(transaction) }
    }

    func deletePermanently(_ category: TransactionCategory) {
        guard let category = category.live else { return }
        let categoryUuid = category.uuid
        update {
            delete(transactions(of: category))
            delete(objects(AutoPayment.self).where { $0.category.uuid == categoryUuid })
            delete(category)
        }
    }

    func deletePermanently(_ account: Account) {
        guard let account = account.live else { return }
        update {
            delete(transactions(of: account))
            delete(account)
        }
    }

    func emptyTrash() {
        update {
            delete(objects(AutoPayment.self).where { $0.deletedAt != nil || $0.category.deletedAt != nil })
            delete(objects(Transaction.self).where(Transaction.inTrashWithOwners))
            delete(objects(TransactionCategory.self).where(TransactionCategory.inTrash))
            delete(objects(Account.self).where(Account.inTrash))
        }
    }

    private func transactions(of account: Account) -> Results<Transaction> {
        let accountUuid = account.uuid
        return objects(Transaction.self).where { $0.account.uuid == accountUuid }
    }

    private func transactions(of category: TransactionCategory) -> Results<Transaction> {
        let categoryUuid = category.uuid
        return objects(Transaction.self).where { $0.categoryLink.uuid == categoryUuid }
    }
}
