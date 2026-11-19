//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 04.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftUI

final class Transaction: Object, Identifiable {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var amount: Int = 0
    @Persisted(indexed: true) var date: Date = Date()
    @Persisted var note: String?
    @Persisted var categoryLink: TransactionCategory?
    @Persisted var deletedAt: Date?
    @Persisted var account: Account?

    var category: TransactionCategory {
        get { categoryLink ?? TransactionCategory() }
        set { categoryLink = newValue.live }
    }

    convenience init(amount: Int, category: TransactionCategory, date: Date = Date(), note: String? = nil, account: Account? = nil) {
        self.init()
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
        self.account = account?.live
    }

    var operationType: OperationType {
        category.operationType
    }

    var signedAmount: Int {
        amount * operationType.balanceSign
    }

    var displayAmount: String {
        operationType == .income ? "+" + amount.getAmount() : amount.getAmount()
    }
}

extension Transaction {
    static let notDeleted: (Query<Transaction>) -> Query<Bool> = { $0.deletedAt == nil }
    static let visible: (Query<Transaction>) -> Query<Bool> = { $0.deletedAt == nil && ($0.account == nil || $0.account.isDisabled == false) }
    static let inTrash: (Query<Transaction>) -> Query<Bool> = { $0.deletedAt != nil }

    static func listed(of operationType: OperationType, since start: Date) -> (Query<Transaction>) -> Query<Bool> {
        let raw = operationType.rawValue
        return { $0.deletedAt == nil && $0.date >= start && ($0.account == nil || $0.account.isDisabled == false) && $0.categoryLink.operationTypeRaw == raw }
    }

    static let inTrashWithOwners: (Query<Transaction>) -> Query<Bool> = { $0.deletedAt != nil || $0.categoryLink.deletedAt != nil || $0.account.deletedAt != nil }
}

extension Sequence<Transaction> {
    func of(_ operationType: OperationType) -> [Transaction] {
        filter { $0.operationType == operationType }
    }
}
